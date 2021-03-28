program spi_st7789;
{$MODE OBJFPC}
{$H+}
{$MEMORY 20000,20000}
uses
  pico_spi_c,
  st7789_spi_c,
  CustomDisplay,
  pico_gpio_c,
  pico_timer_c,
  pico_c,
  Fonts.BitstreamVeraSansMono13x24;

var
  st7789 : Tst7789_SPI;
begin
  gpio_init(TPicoPin.LED);
  gpio_set_dir(TPicoPin.LED,TGPIODirection.GPIO_OUT);

  spi_init(spi,40000000);
  gpio_set_function(TPicoPin.SPI_CS,  TGPIOFunction.GPIO_FUNC_SPI);
  gpio_set_function(TPicoPin.SPI_SCK, TGPIOFunction.GPIO_FUNC_SPI);
  gpio_set_function(TPicoPin.SPI_TX,  TGPIOFunction.GPIO_FUNC_SPI);

  st7789.Initialize(spi,TPicoPin.GP16,TPicoPin.None,ScreenSize240x240x16);
  //st7789.Initialize(spi,TPicoPin.GP16,TPicoPin.None,ScreenSize240x135x16);
  st7789.setFontInfo(BitstreamVeraSansMono13x24);

  repeat
    gpio_put(TPicoPin.LED,true);
    st7789.ForegroundColor := clWhite;
    st7789.BackgroundColor := clRed;
    st7789.SetRotation(TDisplayRotation.None);
    st7789.ClearScreen;
    st7789.drawText('Red',0,0,clWhite);
    st7789.drawCircle(50,50,20);
    busy_wait_us_32(1500000);

    gpio_put(TPicoPin.LED,false);
    st7789.ForegroundColor := clWhite;
    st7789.BackgroundColor := clGreen;
    st7789.SetRotation(TDisplayRotation.Right);
    st7789.ClearScreen;
    st7789.drawText('Lime',0,0,clWhite);
    st7789.fillCircle(50,50,50);
    busy_wait_us_32(1500000);

    gpio_put(TPicoPin.LED,true);
    st7789.ForegroundColor := clWhite;
    st7789.BackgroundColor := clBlue;
    st7789.SetRotation(TDisplayRotation.UpsideDown);
    st7789.ClearScreen;
    st7789.drawText('Blue',0,0,clWhite);
    st7789.drawRoundRect(20,20,50,50,20);
    busy_wait_us_32(1500000);

    gpio_put(TPicoPin.LED,false);
    st7789.ForegroundColor := clWhite;
    st7789.BackgroundColor := clLtGray;
    st7789.SetRotation(TDisplayRotation.Left);
    st7789.ClearScreen;
    st7789.drawText('LightGrey',0,0,clWhite);
    st7789.drawLine(0,0,100,100);
    st7789.drawLine(0,0,100,50);
    st7789.drawLine(0,0,50,100);
    busy_wait_us_32(1500000);
  until 1=0;
end.
