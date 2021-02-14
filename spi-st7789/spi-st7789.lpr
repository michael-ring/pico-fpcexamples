program spi_st7789;
{$MODE OBJFPC}
{$H+}

uses
  pico_gpio_c,
  pico_uart_c,
  pico_timer_c,
  pico_c,
  ust7789;

const
  BAUD_RATE=115200;
  UART_TX_PIN=0;
  UART_RX_PIN=1;
  LED_PIN=25;

  PIN_MISO=16;
  PIN_CS=  17;
  PIN_SCK= 18;
  PIN_MOSI=19;
  PIN_DC  =20;
  PIN_RST =21;

var
  st7789 : TST7789;

begin
  gpio_init(LED_PIN);
  gpio_set_dir(LED_PIN,TGPIODirection.GPIO_OUT);

  uart_init(uart0, BAUD_RATE);
  gpio_set_function(UART_TX_PIN, GPIO_FUNC_UART);
  gpio_set_function(UART_RX_PIN, GPIO_FUNC_UART);

  st7789.init(spi0,pin_Mosi,pin_Miso,pin_SCK,pin_CS,pin_DC,pin_RST);
  repeat
    gpio_put(LED_PIN,true);
    uart_puts(uart0, 'App running...');
    busy_wait_us_32(500000);
    gpio_put(LED_PIN,false);
    busy_wait_us_32(500000);
  until 1=0;
end.
