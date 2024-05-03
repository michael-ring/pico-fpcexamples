program nixieclock;
{$MODE OBJFPC}
{$H+}
{$MEMORY 40000,40000}
uses
  pico_spi_c,
  st7789_spi_c,
  CustomDisplay,
  pico_gpio_c,
  pico_clocks_c,
  pico_timer_c,
  pico_pio_c,
  pico_c,
  Images.NixieNice;

  // This include file is generated with pioasm out of the ws2812.pio file
  // pioasm -o freepascal ws2812.pio >ws2812.inc
  {$I ws2812.inc}

  procedure put_pixel(r, g, b: byte);
  begin
    pio_sm_put_blocking(pio0, 0, (g shl 24) or (r shl 16) or (b shl 8));
  end;

var
  digits: array[1..6] of Tst7789_SPI;
  numbers: array[0..9] of TImageInfo;
  i, offset, sm: longword;

begin
  //LCD Backlight
  gpio_init(TPicoPin.GP12);
  gpio_set_dir(TPicoPin.GP12, TGPIO_Direction.GPIO_OUT);
  gpio_put(TPicoPin.GP12, False);

  sm := 0;
  offset := pio_add_program(pio0, ws2812_program);
  ws2812_program_init(pio0, sm, offset, TPicoPin.GP22, 800000, False);

  gpio_init(TPicoPin.GP5);
  gpio_set_dir(TPicoPin.GP5, TGPIO_Direction.GPIO_OUT);
  gpio_put(TPicoPin.GP5, True);

  gpio_init(TPicoPin.GP1);
  gpio_set_dir(TPicoPin.GP1, TGPIO_Direction.GPIO_OUT);
  gpio_put(TPicoPin.GP1, True);

  gpio_init(TPicoPin.GP0);
  gpio_set_dir(TPicoPin.GP0, TGPIO_Direction.GPIO_OUT);
  gpio_put(TPicoPin.GP0, True);

  gpio_init(TPicoPin.GP4);
  gpio_set_dir(TPicoPin.GP4, TGPIO_Direction.GPIO_OUT);
  gpio_put(TPicoPin.GP4, True);

  gpio_init(TPicoPin.GP3);
  gpio_set_dir(TPicoPin.GP3, TGPIO_Direction.GPIO_OUT);
  gpio_put(TPicoPin.GP3, True);

  gpio_init(TPicoPin.GP2);
  gpio_set_dir(TPicoPin.GP2, TGPIO_Direction.GPIO_OUT);
  gpio_put(TPicoPin.GP2, True);

  for i := 1 to 6 do
    put_pixel(30, 0, 0);

  spi_init(spi1, 30000000);
  gpio_set_function(TPicoPin.GP10, TGPIO_Function.GPIO_FUNC_SPI);
  gpio_set_function(TPicoPin.GP11, TGPIO_Function.GPIO_FUNC_SPI);
  {$PUSH}
  {$WARN 5090 off : Variable "$1" of a managed type does not seem to be initialized}
  digits[1].Initialize(spi1, TPicoPin.GP8, TPicoPin.GP5, TPicoPin.GP12,
    TST7789_SPI.ScreenSize240x135x16);
  digits[2].Initialize(spi1, TPicoPin.GP8, TPicoPin.GP1, TPicoPin.GP12,
    TST7789_SPI.ScreenSize240x135x16);
  digits[3].Initialize(spi1, TPicoPin.GP8, TPicoPin.GP0, TPicoPin.GP12,
    TST7789_SPI.ScreenSize240x135x16);
  digits[4].Initialize(spi1, TPicoPin.GP8, TPicoPin.GP4, TPicoPin.GP12,
    TST7789_SPI.ScreenSize240x135x16);
  digits[5].Initialize(spi1, TPicoPin.GP8, TPicoPin.GP3, TPicoPin.GP12,
    TST7789_SPI.ScreenSize240x135x16);
  digits[6].Initialize(spi1, TPicoPin.GP8, TPicoPin.GP2, TPicoPin.GP12,
    TST7789_SPI.ScreenSize240x135x16);
  {$POP}
  numbers[0] := zero135x240x16;
  numbers[1] := one135x240x16;
  numbers[2] := two135x240x16;
  numbers[3] := three135x240x16;
  numbers[4] := four135x240x16;
  numbers[5] := five135x240x16;
  numbers[6] := six135x240x16;
  numbers[7] := seven135x240x16;
  numbers[8] := eight135x240x16;
  numbers[9] := nine135x240x16;
  digits[3].drawImage(0, 0, dp135x240x16);
  repeat
    digits[1].drawImage(0, 0, numbers[0]);
    digits[2].drawImage(0, 0, numbers[1]);
    digits[4].drawImage(0, 0, numbers[2]);
    digits[5].drawImage(0, 0, numbers[3]);
    digits[6].drawImage(0, 0, numbers[4]);
    busy_wait_us_32(1500000);
    digits[1].drawImage(0, 0, numbers[5]);
    digits[2].drawImage(0, 0, numbers[6]);
    digits[4].drawImage(0, 0, numbers[7]);
    digits[5].drawImage(0, 0, numbers[8]);
    digits[6].drawImage(0, 0, numbers[9]);
    busy_wait_us_32(1500000);
  until 1 = 0;
end.
