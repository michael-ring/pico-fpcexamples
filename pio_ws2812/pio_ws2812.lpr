program pio_ws2812;
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
  pico_clocks_c,
  pico_timer_c,
  pico_pio_c;

// This include file is generated with pioasm out of the ws2812.pio file
// pioasm -o freepascal ws2812.pio >ws2812.inc
{$I ws2812.inc}

const
  NUM_PIXEL=8;

procedure put_pixel(r,g,b : byte);
begin
  pio_sm_put_blocking(pio0, 0, (g shl 24) or (r shl 16) or (b shl 8) );
end;

var
  sm : longWord;
  i : longWord;
  offset : longWord;
begin
  gpio_init(TPicoPin.LED);
  gpio_set_dir(TPicoPin.LED,TGPIODirection.GPIO_OUT);
  sm := 0;
  offset := pio_add_program(pio0, ws2812_program);
  ws2812_program_init(pio0, sm, offset, TPicoPin.GP2, 800000, false);
  while true do
  begin
    gpio_put(TPicoPin.LED,true);
    for i := 1 to NUM_PIXEL do
      put_pixel(255,255,255);
    busy_wait_us_32(500000);
    gpio_put(TPicoPin.LED,false);
    for i := 1 to NUM_PIXEL do
      put_pixel(0,0,0);
    busy_wait_us_32(500000);
  end;
end.
