unit esp_nina_c;

{$mode ObjFPC}{$H+}
{$SCOPEDENUMS ON}
interface

uses
  pico_gpio_c;

type
  TESP_nina_StatusCode=(OK,ERROR,INITIALIZING,ATCMDDETECTED,ATFIRMWAREWRONGVERSION,BROWNOUT,TIMEOUT,CONNECTED);

  TResponse = record
    Status : word;
    Encoding : String;
    Headers : array of String;
    Content : String;
  end;

  TSerialResponse = record
    ESPStatus : TESP_nina_StatusCode;
    Content : array of String;
  end;

  TESP_nina = object
  private
    fpSPI : ^TSPI_Registers;
    fcs_pin : TPinIdentifier;
    fready_pin : TPinIdentifier;
    freset_pin : TPinIdentifier;
    fgpio0_pin : TPinIdentifier;

    fssid : string;
    fpassword : string;
    fVersion : string;
    fUserAgent : String;
    fAccept : String;
    fNTPServer : String;
  public
  const
    SOCKET_CLOSED = 0;
    SOCKET_LISTEN = 1;
    SOCKET_SYN_SENT = 2;
    SOCKET_SYN_RCVD = 3;
    SOCKET_ESTABLISHED = 4;
    SOCKET_FIN_WAIT_1 = 5;
    SOCKET_FIN_WAIT_2 = 6;
    SOCKET_CLOSE_WAIT = 7;
    SOCKET_CLOSING = 8;
    SOCKET_LAST_ACK = 9;
    SOCKET_TIME_WAIT = 10;

    WL_NO_SHIELD = $FF;
    WL_NO_MODULE = $FF;
    WL_IDLE_STATUS = 0;
    WL_NO_SSID_AVAIL = 1;
    WL_SCAN_COMPLETED = 2;
    WL_CONNECTED = 3;
    WL_CONNECT_FAILED = 4;
    WL_CONNECTION_LOST = 5;
    WL_DISCONNECTED = 6;
    WL_AP_LISTENING = 7;
    WL_AP_CONNECTED = 8;
    WL_AP_FAILED = 9;

    (*
  Initialise the connection to the GPS
  Must be called before other functions.
param
  uart UART instance. uart0 or uart1
  baudrate Baudrate of UART in Hz
    *)
    constructor init(var spi : TSPI_Registers;const cs_pin,ready_pin : TPinIdentifier; const reset_pin : TPinIdentifier = TPicoPin.None; const gpio0_pin : TPinIdentifier = TPicoPin.None);
    procedure reset;
    function wait_for_ready : boolean;
    property version : string read fVersion;
    property accept : string read fAccept write fAccept;
    property userAgent : string read fUserAgent write fUserAgent;
  end;

implementation
uses
  pico_timer_c,
  pico_spi_c;

const
  _SET_NET_CMD = $10;
  _SET_PASSPHRASE_CMD = $11;
  _SET_AP_NET_CMD = $18;
  _SET_AP_PASSPHRASE_CMD = $19;
  _SET_DEBUG_CMD = $1A;

  _GET_CONN_STATUS_CMD = $20;
  _GET_IPADDR_CMD = $21;
  _GET_MACADDR_CMD = $22;
  _GET_CURR_SSID_CMD = $23;
  _GET_CURR_BSSID_CMD = $24;
  _GET_CURR_RSSI_CMD = $25;
  _GET_CURR_ENCT_CMD = $26;

  _SCAN_NETWORKS = $27;
  _START_SERVER_TCP_CMD = $28;
  _GET_SOCKET_CMD = $3F;
  _GET_STATE_TCP_CMD = $29;
  _DATA_SENT_TCP_CMD = $2A;
  _AVAIL_DATA_TCP_CMD = $2B;
  _GET_DATA_TCP_CMD = $2C;
  _START_CLIENT_TCP_CMD = $2D;
  _STOP_CLIENT_TCP_CMD = $2E;
  _GET_CLIENT_STATE_TCP_CMD = $2F;
  _DISCONNECT_CMD = $30;
  _GET_IDX_RSSI_CMD = $32;
  _GET_IDX_ENCT_CMD = $33;
  _REQ_HOST_BY_NAME_CMD = $34;
  _GET_HOST_BY_NAME_CMD = $35;
  _START_SCAN_NETWORKS = $36;
  _GET_FW_VERSION_CMD = $37;
  _SEND_UDP_DATA_CMD = $39;
  _GET_TIME = $3B;
  _GET_IDX_BSSID_CMD = $3C;
  _GET_IDX_CHAN_CMD = $3D;
  _PING_CMD = $3E;

  _SEND_DATA_TCP_CMD = $44;
  _GET_DATABUF_TCP_CMD = $45;
  _INSERT_DATABUF_TCP_CMD = $46;
  _SET_ENT_IDENT_CMD = $4A;
  _SET_ENT_UNAME_CMD = $4B;
  _SET_ENT_PASSWD_CMD = $4C;
  _SET_ENT_ENABLE_CMD = $4F;
  _SET_CLI_CERT = $40;
  _SET_PK = $41;

  _SET_PIN_MODE_CMD = $50;
  _SET_DIGITAL_WRITE_CMD = $51;
  _SET_ANALOG_WRITE_CMD = $52;
  _SET_DIGITAL_READ_CMD = $53;
  _SET_ANALOG_READ_CMD = $54;

  _START_CMD = $E0;
  _END_CMD = $EE;
  _ERR_CMD = $EF;
  _REPLY_FLAG = 1 << 7;
  _CMD_FLAG = 0;

function TicksInBetween(const InitTicks, EndTicks: longWord): longWord;
begin
  Result := EndTicks - InitTicks;
  if longWord(not Result) < Result then
    Result := longWord(not Result);
end;

constructor TESP_nina.init(var spi : TSPI_Registers;const cs_pin,ready_pin : TPinIdentifier; const reset_pin : TPinIdentifier = TPicoPin.None; const gpio0_pin : TPinIdentifier = TPicoPin.None);
var
  count : byte;
  serialResponse : TSerialResponse;
begin
  fpSPI := @spi;
  spi_set_baudrate(fpSpi^,8000000);
  fssid := '';
  fpassword := '';
  fcs_pin := cs_pin;
  gpio_init(fcs_pin);
  gpio_set_dir(fcs_pin,TGPIO_Direction.GPIO_OUT);

  fready_pin:=ready_pin;
  gpio_init(fready_pin);
  gpio_set_dir(fready_pin,TGPIO_Direction.GPIO_IN);

  freset_pin:=reset_pin;
  if freset_pin <> TPicoPin.None then
  begin
    gpio_init(freset_pin);
    gpio_set_dir(freset_pin,TGPIO_Direction.GPIO_IN);
  end;

  fgpio0_pin:=gpio0_pin;
  if freset_pin <> TPicoPin.None then
  begin
    gpio_init(fgpio0_pin);
    gpio_set_dir(fgpio0_pin,TGPIO_Direction.GPIO_OUT);
    gpio_pull_up(fgpio0_pin);
  end;
end;

procedure TESP_nina.reset;
begin
  if fgpio0_pin <> TPicoPin.None then
  begin
    gpio_set_dir(fgpio0_pin,TGPIO_Direction.GPIO_OUT);
    gpio_put(fgpio0_pin,true);
  end;
  if freset_pin <> TPicoPin.None then
  begin
    gpio_put(freset_pin,false);
    busy_wait_us_32(10000);
    gpio_put(freset_pin,true);
  end;
  busy_wait_us_32(750000);
  if fgpio0_pin <> TPicoPin.None then
  begin
    gpio_set_dir(fgpio0_pin,TGPIO_Direction.GPIO_IN);
    gpio_pull_up(fgpio0_pin);
  end;
end;

function TESP_nina.wait_for_ready : boolean;
var
  startTime : longWord;
begin
  result := false;
  startTime := time_us_32;
  repeat
    if not gpio_get(fready_pin) then
    begin
      result := true;
      break;
    end;
  until TicksInBetween(startTime,time_us_32) > 10000000;
end;

function _send_command(const cmd : byte; params : array of string);
begin

end;

end.
