program pwm;
{
  This file is part of pico-fpcsamples
  Copyright (c) 2021 -  Michael Ring

  This program is free software: you can redistribute it and/or modify it under the terms of the FPC modified GNU
  Library General Public License for more

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the FPC modified GNU Library General Public
  License for more details.
}

{$MODE OBJFPC}
{$H+}
{$MEMORY 10000,10000}

uses
  pico_c,
  pico_gpio_c,
  pico_timer_c,
  pico_pwm_c;
var
  slice_num : longWord;
  config : Tpwm_config;
  fade : longWord;
begin
  gpio_set_function(TPicoPin.LED, TGPIO_Function.GPIO_FUNC_PWM);
  slice_num := pwm_gpio_to_slice_num(TPicoPin.LED);
  config := pwm_get_default_config();
  pwm_config_set_clkdiv(config, 4);
  pwm_init(slice_num, config, true);
  while true do
    for fade := 0 to 255 do
    begin
      pwm_set_gpio_level(TPicoPin.LED, fade * fade);
      busy_wait_us_32(5000);
    end;
end.
