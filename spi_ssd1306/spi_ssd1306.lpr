program spi_ssd1306;
{$MODE OBJFPC}
{$H+}
{$MEMORY 10000,10000}
uses
  pico_spi_c,
  ssd1306_spi_c,
  pico_gpio_c,
  pico_timer_c,
  pico_c,
  Fonts.BitstreamVeraSansMono13x24;

var
  ssd1306 : TSSD1306_SPI;
  i : integer;

begin
  gpio_init(TPicoPin.LED);
  gpio_set_dir(TPicoPin.LED,TGPIODirection.GPIO_OUT);

  spi_init(spi0,1000000);
  gpio_set_function(TPicoPin.GP5_SPI0_CS, GPIO_FUNC_SPI);
  gpio_set_function(TPicoPin.GP6_SPI0_SCK, GPIO_FUNC_SPI);
  gpio_set_function(TPicoPin.GP7_SPI0_TX, GPIO_FUNC_SPI);

  ssd1306.Initialize(spi0,TPicoPin.GP9,TPicoPin.GP8,ScreenSize128x64x1);
  ssd1306.InitSequence;
  ssd1306.setFont(BitstreamVeraSansMono13x24);

  repeat
    gpio_put(TPicoPin.LED,true);
    ssd1306.ForegroundColor := clBlack;
    ssd1306.BackgroundColor := clWhite;
    ssd1306.ClearScreen;
    ssd1306.drawText('Hello',0,0);
    ssd1306.updateScreen;
    busy_wait_us_32(1000000);
    gpio_put(TPicoPin.LED,false);
    ssd1306.ForegroundColor := clWhite;
    ssd1306.BackgroundColor := clBlack;
    ssd1306.ClearScreen;
    ssd1306.drawText('FreePascal',0,ssd1306.ScreenInfo.Height-BitstreamVeraSansMono13x24.Height);
    ssd1306.updateScreen;
    busy_wait_us_32(1000000);
  until 1=0;
end.
