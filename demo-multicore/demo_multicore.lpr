program demo_multicore;

{
  This file is part of pico-fpcsamples
  Copyright (c) 2021 -  Michael Ring
  added by jean-pierre MANDON (c) 2022
  This program is free software: you can redistribute it and/or modify it under the terms of the FPC modified GNU
  Library General Public License for more
  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the FPC modified GNU Library General Public
  License for more details.
}

{$mode objfpc}
{$H+}
{$MEMORY 4096,4096}

uses
  pico_multicore_c,
  pico_timer_c,
  pico_gpio_c;

var
  stack_bottom_core1 : uint32=$40000;
  {
  |----------$42000------------|
  |                            |
  |                            |
  |       stack CORE 0         |  4096 bytes
  |                            |
  |                            |
  |----------$41000------------|
  |                            |
  |                            |
  |       stack CORE 1         |  4096 bytes
  |                            |
  |                            |
  |----------$40000------------|
  }

procedure core1_entry;
begin
  repeat                                                // blink the core 1 LED
     gpio_put(TPicoPin.LED,true);
     busy_wait_us_32(500000);
     gpio_put(TPicoPin.LED,false);
     busy_wait_us_32(500000);
  until 1=0;
end;

begin
  multicore_reset_core1;                                // first stop core 1
  gpio_init(TPicoPin.LED);                              // LED is updated by core 1
  gpio_set_dir(TPicoPin.LED,TGPIODirection.GPIO_OUT);
  gpio_init(15);
  gpio_set_dir(15,TGPIODirection.GPIO_OUT);             // LED on GPIO15 is updated by core 0
  gpio_put(TPicoPin.LED,false);
  gpio_put(15,false);

  multicore_launch_core1_with_stack(@core1_entry,@stack_bottom_core1,$1000);      // launch core1

  // blink the core 0 LED ( GPIO15 )
  repeat
     gpio_put(15,true);
     busy_wait_us_32(500000);
     gpio_put(15,false);
     busy_wait_us_32(500000);
  until 1=0;

end.

