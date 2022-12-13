program uart_irq;
{$mode objfpc}
{$H+}
{$MEMORY 10000,10000}

// UART0 default pins TX=GP0,RX=GP1
// UART1 default pins TX=GP4,RX=GP5

uses
  pico_uart_c,
  pico_gpio_c,
  pico_timer_c,
  pico_irq_c;

const
  BAUD_RATE=115200;

var
  received_string : string;

// UART1 IRQ handler
procedure UART1_IRQ_Handler; public name 'UART1_IRQ_Handler';
var
  caractere : char;
begin
  caractere:=uart_getc(uart1);
  received_string+=caractere;
end;

begin
  gpio_init(TPicoPin.LED);
  gpio_set_dir(TPicoPin.LED,TGPIODirection.GPIO_OUT);
  gpio_put(TPicoPin.LED,true);

  uart_init(uart1, BAUD_RATE);
  uart_set_format(uart1, TUARTDataBits.UART_DATABITS_EIGHT, TUARTStopBits.UART_STOPBITS_ONE, TUARTParity.UART_PARITY_NONE);
  gpio_set_function(TPicoPin.GP4_UART1_TX, TGPIOFunction.GPIO_FUNC_UART);
  gpio_set_function(TPicoPin.GP5_UART1_RX, TGPIOFunction.GPIO_FUNC_UART);
  uart_set_fifo_enabled(uart1,false);
  // enable RX uart1 irq
  uart_set_irq_enables(uart1,true,false);
  // enable uart1 irq
  irq_set_enabled(TIRQn_Enum.UART1_IRQ);

  received_string:='';

  repeat
    uart_puts(uart1, 'Hello, UART! '+received_string+#13+#10);
    if received_string<>'' then received_string:='';
    busy_wait_us_32(500000);
  until 1=0;
end.

