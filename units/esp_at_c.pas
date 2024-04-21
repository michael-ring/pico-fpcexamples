unit esp_at_c;

{$mode ObjFPC}{$H+}
{$SCOPEDENUMS ON}
interface
uses
  pico_gpio_c;
type
  TESP_at_StatusCode=(OK,ERROR,INITIALIZING,ATCMDDETECTED,ATFIRMWAREWRONGVERSION,BROWNOUT,TIMEOUT,CONNECTED);

  TResponse = record
    Status : word;
    Encoding : String;
    Headers : array of String;
    Content : String;
  end;

  TSerialResponse = record
    ESPStatus : TESP_at_StatusCode;
    Content : array of String;
  end;


  TESP_at = object
  private
    fpUart : ^TUART_Registers;
    fESPStatus : TESP_at_StatusCode;
    fssid : string;
    fpassword : string;
    fVersion : string;
    fUserAgent : String;
    fAccept : String;
    fNTPServer : String;
  public
  const
    ESP_AT_SUPPORTED_VERSIONS: array of string = ('2.1.0','v3.2.0.0(MINI-1)');
    (*
  Initialise the connection to the GPS
  Must be called before other functions.
param
  uart UART instance. uart0 or uart1
  baudrate Baudrate of UART in Hz
    *)
    constructor init(var uart : TUART_Registers;const pinReset : TPinIdentifier;const ssid,password : string; const BaudRate:longWord=115200);
    function sendSimpleCommand(const atCommand : string;const TimeOut : longWord = 1000000) : boolean;
    function sendCommand(const atCommand : string;const TimeOut : longWord = 1000000) : TSerialResponse;
    function waitForLine(const aLine : string;const TimeOut : longWord = 1000000) : TSerialResponse;

    function get(const url : string;const headers : array of string; const TimeOut : longWord = 10000000):TResponse;
    (*
  Property that refects the current status of the connection to the GPS
  The property is only updated after a successful poll for data.
return
  A TGPSStatusCode which can be INITIALIZING,SERIALDETECTED,GPSDETECTED,POSITIONFIX
    *)
    property espstatus : TESP_at_StatusCode read fespStatus;
    property version : string read fVersion;
    property accept : string read fAccept write fAccept;
    property userAgent : string read fUserAgent write fUserAgent;
    property NTPServer : string read fNTPServer write fNTPServer;
  end;

implementation
uses
  pico_timer_c,
  pico_uart_c;

function TicksInBetween(const InitTicks, EndTicks: longWord): longWord;
begin
  Result := EndTicks - InitTicks;
  if longWord(not Result) < Result then
    Result := longWord(not Result);
end;

function TESP_at.sendSimpleCommand(const atCommand : string;const TimeOut : longWord = 1000000) : boolean;
var
  serialResponse : TSerialResponse;
begin
  result := false;
  serialResponse := sendCommand(atCommand,timeOut);
  if serialResponse.ESPStatus <> TESP_at_StatusCode.OK then
    exit;
  if length(serialResponse.Content) > 0 then
    if serialResponse.Content[length(serialResponse.Content)-1] = 'OK' then
      result := true;
end;

function TESP_at.sendCommand(const atCommand : string;const TimeOut : longWord = 1000000) : TSerialResponse;
var
  line : String;
  c : char;
  startTime : longWord;
begin
  {$PUSH}
  {$WARN 5093 off : Function result variable of a managed type does not seem to be initialized}
  setlength(result.Content,0);
  {$POP}
  result.ESPStatus := TESP_at_StatusCode.TIMEOUT;
  //Make sure rx fifos are empty
  while uart_is_readable_within_us(fpUart^,10000) do
    uart_getc(fpUart^);

  uart_puts(fpUart^,atcommand+#13#10);
  startTime := time_us_32;
  line := '';
  repeat
    if uart_is_readable(fpUart^) then
    begin
      c := uart_getc(fpUart^);
      if c=#10 then
        continue;
      if c = #13 then
      begin
        if length(line) = 0 then
          continue;
        //do not save the line with the command echo
        if line <> atCommand then
        begin
          setlength(result.content,length(result.content)+1);
          result.content[length(result.content)-1] := line;
        end;
        if line = 'OK' then
        begin
          result.espstatus := TESP_at_StatusCode.OK;
          exit;
        end;
        if line = 'ERROR' then
        begin
          result.espstatus := TESP_at_StatusCode.ERROR;
          exit;
        end;
        if pos('Brownout detector was triggered'+#13,line) > 0  then
        begin
          result.espstatus := TESP_at_StatusCode.BROWNOUT;
          exit
        end;
        line := '';
        continue;
      end;
      line := line + c;
    end;
  until TicksInBetween(startTime,time_us_32) > timeOut;
end;

function TESP_at.waitForLine(const aLine : string;const TimeOut : longWord = 1000000) : TSerialResponse;
var
  line : String;
  c : char;
  startTime : longWord;
  brownout : byte;
begin
  {$PUSH}
  {$WARN 5093 off : Function result variable of a managed type does not seem to be initialized}
  setLength(result.content,0);
  {$POP}
  result.ESPStatus := TESP_at_StatusCode.TIMEOUT;
  brownout := 0;
  startTime := time_us_32;
  line := '';
  repeat
    if uart_is_readable(fpUart^) then
    begin
      c := uart_getc(fpUart^);
      if c=#10 then
        continue;
      if c = #13 then
      begin
        if length(line) = 0 then
          continue;
        setlength(result.content,length(result.content)+1);
        result.content[length(result.content)-1] := line;
        if line = aLine then
        begin
          result.espstatus := TESP_at_StatusCode.OK;
          exit;
        end;
        if pos('Brownout detector was triggered'+#13,line) > 0 then
        begin
          inc(brownout);
          if brownout = 4 then
          begin
            result.espstatus := TESP_at_StatusCode.BROWNOUT;
            exit
          end;
        end;
        line := '';
        continue;
      end;
      line := line + c;
    end;
  until TicksInBetween(startTime,time_us_32) > timeOut;
end;

constructor TESP_at.init(var uart : TUART_Registers;const pinReset : TPinIdentifier;const ssid,password : string; const Baudrate : longWord=115200);
var
  count : byte;
  serialResponse : TSerialResponse;
  supportedVersion,currentVersion : string;
begin
  fpUart := @uart;
  uart_set_baudrate(fpUart^,Baudrate);
  fESPStatus := TESP_at_StatusCode.INITIALIZING;
  fssid := ssid;
  fpassword := password;
  fAccept := '*/*';
  fNTPServer:= 'us.pool.ntp.org';
  count := 0;
  repeat
    busy_wait_us_32(500000);
    inc(count)
  until (sendSimpleCommand('AT') = true) or (count = 10);
  serialResponse :=  sendCommand('AT+CIPSTATUS');
  if not ((length(serialResponse.content)=2) and (serialResponse.content[1] = 'OK') and ((serialResponse.content[0] = 'STATUS:0'))) then
  begin
    //We are in some active state, reset esp
    sendSimpleCommand('AT+RST');
    serialResponse := waitForLine('ready',5000000);
  end;

  if sendSimpleCommand('ATE0') = true then
  begin
    fESPStatus := TESP_at_StatusCode.ATCMDDETECTED;
    serialResponse := sendCommand('AT+GMR');
    if length(serialResponse.content) <> 5 then
      exit;
    fVersion := copy(serialResponse.content[3],pos(':',serialResponse.content[3])+1,999);
    supportedVersion := '';
    for currentVersion in ESP_AT_SUPPORTED_VERSIONS do
    begin
      if pos(currentVersion,fVersion) = 1 then
        supportedVersion := version;
    end;
    if supportedVersion = '' then
    begin
      fESPStatus := TESP_at_StatusCode.ATFIRMWAREWRONGVERSION;
      exit;
    end;
    fUserAgent := 'ESP_AT/'+supportedVersion;
    //Operate in Station Mode
    if not sendSimpleCommand('AT+CWMODE=1,0') then
      exit;
    //Change Country Info to Country Info of AP
    if not sendSimpleCommand('AT+CWCOUNTRY=0,"CN",1,13') then
      exit;
    //Do not automagically reconnect after reboot
    if not sendSimpleCommand('AT+CWAUTOCONN=0') then
      exit;

    //Use only one SSL connection at a time, needed for ssl passthrough mode
    if not sendSimpleCommand('AT+CIPMUX=0') then
      exit;
  end;
  fESPStatus := TESP_at_StatusCode.ATCMDDETECTED;
end;

function TESP_at.get(const url : string;const headers : array of string; const TimeOut : longWord = 10000000):TResponse;
var
  serialResponse : TSerialResponse;
  protocol,host,port,params : string;
  line : string;
begin
  serialResponse := sendCommand('AT+CIPSTATUS');
  result.Status := 500;
  if (length(serialResponse.content)=2) and (serialResponse.content[1] = 'OK') and ((serialResponse.content[0] = 'STATUS:0') or (serialResponse.content[0] = 'STATUS:1')) then
  begin
    //We are not yet connected to WiFi
    serialResponse := sendCommand('AT+CWJAP="'+fssid+'","'+fPassword+'"',5000000);
    serialResponse :=  sendCommand('AT+CIPSTATUS');
    //Sync with NTP Server for SSL Certificates
    sendSimpleCommand('AT+CIPSNTPCFG=1,1,"us.pool.ntp.org"');
  end;
  if (length(serialResponse.content)=2) and (serialResponse.content[1] = 'OK') and ((serialResponse.content[0] = 'STATUS:2') or (serialResponse.content[0] = 'STATUS:4')) then
  begin
    //We are connected to WiFi
    if lowercase(copy(url,1,7))='http://' then
    begin
      host := copy(url,8,999);
      //protocol := 'TCP';
      protocol := '1';
      port := '80';
    end
    else if lowercase(copy(url,1,8))='https://' then
    begin
      host := copy(url,9,999);
      //protocol := 'SSL';
      protocol := '2';
      port := '443';
    end
    else
      exit;
    if host = '' then
      exit;
    params := copy(host,pos('/',host),999);
    if params <> '' then
      host := copy(host,1,pos('/',host)-1)
    else
      params:='/';
    if pos(':',host) > 0 then
    begin
      port := copy(host,pos(':',host)+1,999);
      host := copy(host,1,pos(':',host)-1);
    end;
    if port = '' then
      exit;
    serialResponse :=  sendCommand('AT+HTTPCLIENT=2,1,"'+url+'","'+host+'","'+params+'",'+protocol,Timeout);
    result.Content := '';
    for line in serialResponse.Content do
      if pos('+HTTPCLIENT:',line)=1 then
        result.content := result.content + copy(line,pos(',',line)+1,999);
  end;
end;

end.
