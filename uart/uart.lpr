program Blinky;
{$L gpio.c.obj}
{$L uart.c.obj}
{$L clocks.c.obj}
{$L xosc.c.obj}
{$L pll.c.obj}
{$L watchdog.c.obj}
{$L platform.c.obj}
{$LinkLib gcc,static}
procedure clocks_init; external;
procedure gpio_init(gpio : longWord); external;
procedure gpio_set_function(gpio:longWord;fn:longWord); external;
function uart_init(var uart : TUART_Registers; baudrate:longWord) : longWord; external;

function uart_is_writable(var uart : TUART_Registers):boolean;
begin
   result := (uart.fr and (1 shl 5)) = 0;
end;

procedure uart_puts(var uart : TUART_Registers; const s : string);
var
  i : longWord;
begin
  for i := 1 to length(s) do
  begin
    repeat
    until uart_is_writable(uart);
    uart.dr := longWord(s[i]);
  end;
end;

procedure runtime_init;
const
  RESETS_SAFE_BITS=     %1111111111100110110111111;
  RESETS_PRECLOCK_BITS= %0001111000100110110111110;
  RESETS_POSTCLOCK_BITS=%1110000111000000000000001;
begin
  resets.reset_set := RESETS_SAFE_BITS;
  resets.reset_clr := RESETS_PRECLOCK_BITS;
  repeat
  until (resets.reset_done and RESETS_PRECLOCK_BITS) = RESETS_PRECLOCK_BITS;
  clocks_init;
  resets.reset_clr := RESETS_POSTCLOCK_BITS;
  repeat
  until (resets.reset_done and RESETS_POSTCLOCK_BITS) = RESETS_POSTCLOCK_BITS;
end;
const
  BAUD_RATE=115200;
  UART_TX_PIN=0;
  UART_RX_PIN=1;
  GPIO_FUNC_UART=2;
var
  i : integer;
begin
  runtime_init;
  uart_init(uart0, BAUD_RATE);
  gpio_set_function(UART_TX_PIN, GPIO_FUNC_UART);
  gpio_set_function(UART_RX_PIN, GPIO_FUNC_UART);
  repeat
    uart_puts(uart0, 'Hello, UART!'+#13+#10);
    for i := 0 to 300000 do ;
  until 1=0;
end.
