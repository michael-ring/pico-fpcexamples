program Blinky;
{$L gpio.c.obj}
{$L adc.c.obj}
{$L uart.c.obj}
{$L adc.c.obj}
{$L clocks.c.obj}
{$L xosc.c.obj}
{$L pll.c.obj}
{$L watchdog.c.obj}
{$L platform.c.obj}
{$LinkLib gcc,static}

procedure clocks_init; external;
procedure gpio_init(gpio : longWord); external;
procedure gpio_set_function(gpio:longWord;fn:longWord); external;
procedure gpio_set_pulls(gpio:longWord;up,down:longBool); external;
procedure gpio_set_input_enabled(gpio:longWord;enabled:longBool); external;

function uart_init(var uart : TUART_Registers; baudrate:longWord) : longWord; external;
procedure adc_init; external;

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

procedure gpio_disable_pulls(gpio:longWord);
begin
  gpio_set_pulls(gpio, false, false);
end;

procedure adc_gpio_init(gpio:longWord);
const
  GPIO_FUNC_NULL=0;
begin
  if (gpio >=26) and (gpio <=29) then
  begin
    // Select NULL function to make output driver hi-Z
    gpio_set_function(gpio, GPIO_FUNC_NULL);
    // Also disable digital pulls and digital receiver
    gpio_set_pulls(gpio,false,false);
    gpio_set_input_enabled(gpio, false);
  end;
end;

procedure adc_select_input(input:longWord);
begin
  if input < 4 then 
    adc.cs_set := input shl 12;
end;

function adc_read():word;
begin
  adc.cs_set := 1 shl 2; //ADC_CS_START_ONCE_BITS
  repeat
  until adc.cs and ( 1 shl 8) <> 0; //ADC_CS_READY_BITS
  result := adc.result;
end;

procedure adc_set_temp_sensor_enabled(enable:longBool);
begin
  if enable = true then
    adc.cs_set := 1 shl 1 //ADC_CS_TS_EN_BITS
  else
    adc.cs_clr := 1 shl 1; //ADC_CS_TS_EN_BITS
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
  value,value2 : word;
  valuetext : string;
begin
  runtime_init;
  uart_init(uart0, BAUD_RATE);
  gpio_set_function(UART_TX_PIN, GPIO_FUNC_UART);
  gpio_set_function(UART_RX_PIN, GPIO_FUNC_UART);
  adc_init;
  // Make sure GPIO is high-impedance, no pullups etc
  adc_gpio_init(26);
  repeat
    // Select ADC input 0 (GPIO26)
    adc_select_input(0);
    value := adc_read;
    adc_select_input(3);
    value2 := adc_read;
    uart_puts(uart0, 'Pin 26 raw value is ');
    //uart_puts(uart0,valuetext);
    uart_puts(uart0, ' chip temperature raw value is ');
    //str(value2,valuetext);
    //uart_puts(uart0,valuetext);
    uart_puts(uart0,#13#10);
    for i := 0 to 300000 do ;
  until 1=0;
end.
