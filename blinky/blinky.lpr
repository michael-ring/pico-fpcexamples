program blinky;
{$MODE OBJFPC}
{$H+}

uses
  pico_gpio_c,
  pico_timer_c;

const
  LED_PIN=25;
begin
  gpio_init(LED_PIN);
  gpio_set_dir(LED_PIN,TGPIODirection.GPIO_OUT);
  repeat
    gpio_put(LED_PIN,true);
    busy_wait_us_32(500000);
    gpio_put(LED_PIN,false);
    busy_wait_us_32(500000);
  until 1=0;
end.
