program uart;
{$MODE OBJFPC}
{$H+}

uses
  pico_uart_c,
  pico_gpio_c,
  pico_timer_c;
const
  BAUD_RATE=115200;
  UART_TX_PIN=0;
  UART_RX_PIN=1;
  LED_PIN=25;
begin
  gpio_init(LED_PIN);
  gpio_set_dir(LED_PIN,TGPIODirection.GPIO_OUT);
  uart_init(uart0, BAUD_RATE);
  gpio_set_function(UART_TX_PIN, TGPIOFunction.GPIO_FUNC_UART);
  gpio_set_function(UART_RX_PIN, TGPIOFunction.GPIO_FUNC_UART);
  repeat
    gpio_put(LED_PIN,true);
    uart_puts(uart0, 'Hello, UART!'+#13+#10);
    busy_wait_us_32(500000);    
    gpio_put(LED_PIN,false);
    busy_wait_us_32(500000);    
  until 1=0;
end.
