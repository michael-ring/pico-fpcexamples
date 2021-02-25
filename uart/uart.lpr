program uart;
{$MODE OBJFPC}
{$H+}

uses
  pico_uart_c,
  pico_gpio_c,
  pico_timer_c;
const
  BAUD_RATE=115200;
begin
  gpio_init(TPicoPin.LED);
  gpio_set_dir(TPicoPin.LED,TGPIODirection.GPIO_OUT);
  uart_init(uart0, BAUD_RATE);
  gpio_set_function(TPicoPin.GP0_UART0_TX, TGPIOFunction.GPIO_FUNC_UART);
  gpio_set_function(TPicoPin.GP1_UART0_RX, TGPIOFunction.GPIO_FUNC_UART);
  repeat
    gpio_put(TPicoPin.LED,true);
    uart_puts(uart0, 'Hello, UART!'+#13+#10);
    busy_wait_us_32(500000);    
    gpio_put(TPicoPin.LED,false);
    busy_wait_us_32(500000);    
  until 1=0;
end.
