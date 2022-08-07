program pio_apa102;
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

// This include file is generated with pioasm out of the apa102.pio file
// pioasm -o freepascal apa102.pio >apa102.inc
{$I apa102.inc}

// Global brightness value 0->31
const
  BRIGHTNESS = 16;
  N_LEDS = 8;
  SERIAL_FREQ = (5 * 1000 * 1000);


procedure put_start_frame(var pio : TPIO_Registers; sm : longWord);
begin
  pio_sm_put_blocking(pio, sm, 0);
end;

procedure put_end_frame(var pio : TPIO_Registers; sm : longWord);
begin
  pio_sm_put_blocking(pio, sm, longWord(-1));
end;

procedure put_rgb888(var pio : TPIO_Registers; sm : longWord; r,g,b : byte);
begin
  pio_sm_put_blocking(pio, sm,
                      %111 shl 29 or                  // magic
                      (BRIGHTNESS and $1f) shl 24 or  // global brightness parameter
                      b shl 16 or
                      g shl 8 or
                      r shl 0
  );
end;

var
  i : longWord;
  sm : longWord;
  offset : longWord;
begin
  sm := 0;
  offset := pio_add_program(pio0, apa102_mini_program);
  apa102_mini_program_init(pio0, sm, offset, SERIAL_FREQ, TPicoPin.GP2, TPicoPin.GP3);

  while true do
  begin
    put_start_frame(pio0, sm);
    for i := 0 to N_LEDS - 1 do
      put_rgb888(pio0, sm, i*24,i*24,i*24);
    put_end_frame(pio0, sm);
    busy_wait_us_32(500000);
    put_start_frame(pio0, sm);
    for i := N_LEDS - 1 downto 0 do
      put_rgb888(pio0, sm, i*24,i*24,i*24);
    put_end_frame(pio0, sm);
    busy_wait_us_32(500000);
  end;
end.
