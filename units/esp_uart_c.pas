unit esp_uart_c;
interface
uses
  pico_timer_c,
  pico_gpio_c,
  pico_uart_c;

type
  Tesp_uart = object
  private
    FpEspUart : ^TUART_Registers;
    FpinReset : TPinIdentifier;
    espConnected : boolean;
    wifiConnected : boolean;
    scriptsHash : string;
  private
    procedure flushReceiver;
    procedure enterRaw;
    procedure writeRawLine(line : string);
    function executeRaw(timeout : longWord = 2000000):string;
  public
  type
    TResponse = record
      status : word;
      content : string;
    end;
    constructor initialize(var espuart : TUART_Registers; const pinReset : TPinIdentifier; const startupDelay : longWord = 200000);
    function connect(const ssid,password : String; timeout : longWord = 5000000):boolean;
    procedure createFile(fileName : String; content : array of string);
    function runScript(content : array of string;timeout : longWord = 2000000):string;
    function get(const url:string; const headers : array of string; timeout : longWord = 5000000):TResponse;
  end;

implementation
const
  bootpy : array of string = (
  'import gc',
  'gc.collect()'
  );
  mainpy : array of string = (
  'import ubinascii',
  'import hashlib',
  'f=open("boot.py","r")',
  'hash=hashlib.sha256(f.read())',
  'f.close()',
  'f=open("main.py")',
  'hash.update(f.read())',
  'f.close()',
  'print("hash:"+ubinascii.hexlify(hash.digest()).decode())'
  );
  bootscriptsHash : string = 'hash:27b00a8d3296347303a909445f4156c70453fa790778f803a912b8b4e5f28f1c';

constructor tEsp_uart.initialize(var espUart : TUART_Registers; const pinReset : TPinIdentifier; const startupDelay : longWord = 200000);
var
  ch : char;
  promptFound : boolean;
  startupLog,
  pythonEnvironment : string;
begin
  FpEspUart := @espUart;
  espConnected := false;
  wifiConnected := false;
  gpio_init(pinReset);
  gpio_set_dir(pinReset,TGPIO_Direction.GPIO_OUT);
  gpio_put(pinReset,false);
  busy_wait_us_32(20000);
  gpio_put(pinReset,true);
  //disable fifo so that we start clean after the startup log of esp
  uart_set_fifo_enabled(FpEspUart^,false);
  busy_wait_us_32(startupDelay);
  //re-enable fifo's now that startup logging is over
  uart_set_fifo_enabled(FpEspUart^,true);
  promptFound := false;
  startupLog := '';
  scriptsHash := '';
  pythonEnvironment := '';
  while uart_is_readable_within_us(FpEspUart^,1000000) = true do
  begin
    ch := uart_getc(FpEspUart^);
    if ch = #13 then
    begin
      uart_getc(FpEspUart^);
      if (length(startupLog) > 0) and (pos('hash:',startupLog) > 0) then
        scriptsHash := copy(startupLog,pos('hash:',startupLog),length(startupLog));
      if (length(startupLog) > 0) and (pos('MicroPython',startupLog) >0) then
        pythonEnvironment := copy(startupLog,pos('MicroPython',startupLog),length(startupLog));
      startupLog := '';
    end;
    startupLog := startupLog + ch;
  end;
  if (length(startupLog) > 0) and (pos('>>>',startupLog) >0) then
    promptFound := true;
  if ((scriptsHash = '') or (scriptsHash <> bootscriptsHash)) and (pythonEnvironment <> '') then
  begin
    if promptFound = false then
    begin
      startupLog := '';
      uart_putc(FpEspUart^,#3);
      while uart_is_readable_within_us(FpEspUart^,100000) = true do
      begin
        ch := uart_getc(FpEspUart^);
        startupLog := startupLog + ch;
      end;
      if pos('>>> ',startupLog) > 0 then
        promptFound := true;
    end;
    if promptFound = true then
    begin
      createFile('main.py',mainpy);
      createFile('boot.py',bootpy);
      scriptsHash := bootscriptsHash;
    end;
  end;
  if (promptFound = true) and (pythonEnvironment <> '') and (scriptsHash = bootscriptsHash) then
    espConnected := true;
end;

procedure TEsp_uart.createFile(fileName : String; content : array of string);
var
  ch : char;
  line : string;
begin
  enterRaw;
  writeRawLine('f=open("'+fileName+'","w")');
  for line in content do
    writeRawLine(line);
  flushReceiver;
  writeRawLine('f.close()');
  executeRaw();
end;

procedure TEsp_uart.flushReceiver;
var
  ch : char;
begin
  while uart_is_readable_within_us(FpEspUart^,50000) = true do
  begin
    ch := uart_getc(FpEspUart^);
  end;
end;

procedure TEsp_uart.enterRaw;
begin
  uart_puts(fpEspUart^,#1);
  flushReceiver;
end;

procedure TEsp_uart.writeRawLine(line : string);
begin
  uart_puts(FpEspUart^,line+#13#10);
  flushReceiver;
end;

function TEsp_uart.executeRaw(timeout : longWord = 2000000):string;
var
  ch : char;
begin
  uart_puts(fpEspUart^,#4);
  result := '';
  while uart_is_readable_within_us(FpEspUart^,timeout) = true do
  begin
    ch := uart_getc(FpEspUart^);
    result := result + ch;
  end;
end;

function TEsp_uart.runScript(content : array of string;timeout : longWord = 2000000):string;
var
  ch : char;
  line : string;
begin
  enterRaw;
  for line in content do
  begin
    writeRawLine(line+#13#10);
  end;
  flushReceiver;
  uart_puts(fpEspUart^,#4);
  result := executeRaw(timeout);
end;

function Tesp_uart.connect(const ssid,password : String; timeout : longWord = 5000000):boolean;
var
  res : string;
begin
  result := false;
  wifiConnected := false;
  if espConnected = false then
    exit;
  enterRaw;
  writeRawLine('import network');
  writeRawLine('wlan = network.WLAN(network.STA_IF)');
  writeRawLine(  'wlan.active(True)');
  writeRawLine(  'if not wlan.isconnected():');
  writeRawLine('  wlan.connect("'+ssid+'", "'+password+'")');
  writeRawLine('  while not wlan.isconnected():');
  writeRawLine('    pass');
  writeRawLine('print(wlan.isconnected())');
  res := executeRaw(timeout);
  if pos('True',res) > 0 then
    wifiConnected := true
  else
    wifiConnected := false;
  result := wifiConnected;
end;

function Tesp_uart.get(const url:string; const headers : array of string; timeout : longWord = 5000000):TResponse;
var
  res : string;
  errorPos : byte;
begin
  result.status := 502;
  result.content := 'not connected to WiFi';
  if wifiConnected = false then
    exit;
  enterRaw;
  writeRawLine('import gc');
  writeRawLine('gc.collect()');
  writeRawLine('import urequests');
  writeRawLine('response = urequests.get("'+url+'")');
  writeRawLine('print(str(response.status_code)+str(response.json()))');
  writeRawLine('response.close()');
  writeRawLine('gc.collect()');
  res := executeRaw(timeout);
  val(copy(res,1,pos(':',res)),result.status,errorPos);
  result.content := copy(res,pos(':',res),length(res));
end;

end.
