program i2c_ssd1306;
{$MODE OBJFPC}
{$H+}
{$MEMORY 10000,10000}
uses
  ssd1306_i2c_c,
  pico_gpio_c,
  pico_i2c_c,
  pico_timer_c,
  pico_c,
  Fonts.BitstreamVeraSansMono13x24;

var
  ssd1306 : TSSD1306_I2C;

begin
  gpio_init(TPicoPin.LED);
  gpio_set_dir(TPicoPin.LED,TGPIODirection.GPIO_OUT);

  i2c_init(i2cInst, 400000);
  gpio_set_function(TPicoPin.I2C_SDA, GPIO_FUNC_I2C);
  gpio_set_function(TPicoPin.I2C_SCL, GPIO_FUNC_I2C);
  gpio_pull_up(TPicoPin.I2C_SDA);
  gpio_pull_up(TPicoPin.I2C_SCL);

  ssd1306.Initialize(i2cInst,$3c,TPicoPin.None,ScreenSize128x64x1);
  //ssd1306.Initialize(i2cInst,$3c,TPicoPin.None,ScreenSize128x32x1);
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
