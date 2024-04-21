program i2c_si5351;

{*
 * Copyright (C) 2024 Jean-Pierre Mandon <jp.mandon@gmail.com> call sign F6HOJ
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *}

{$mode objfpc}
{$H+}
{$MEMORY 16384 16384}

{
 the SI5351 is a I2C programmable any-frequency CMOS clock generator + vcxo.
 it is used in ham radio material as Variable Frequency oscillator
}

uses
    pico_gpio_c,
    pico_i2c_c,si5351_i2c;

const
    enable = 1;
    disable = 0;

// main

begin
  // configure I2C
  i2c_init(i2c0inst, 100000);
  gpio_set_function(TPicoPin.GP21_I2C0_SCL, TGPIO_Function.GPIO_FUNC_I2C);
  gpio_set_function(TPicoPin.GP20_I2C0_SDA, TGPIO_Function.GPIO_FUNC_I2C);
  gpio_pull_up(TPicoPin.GP20_I2C0_SDA);
  gpio_pull_up(TPicoPin.GP21_I2C0_SCL);
  // init SI5351
  si5351_init(SI5351_CRYSTAL_LOAD_8PF, 25000000);      // define XTAL used on the SI5351 board
  si5351_set_correction(1572);                         // set frequency correction
  si5351_set_freq(20000000,SI5351_CLK0);               // set output clock 0 to 20 Mhz
  si5351_drive_strength(SI5351_CLK0,SI5351_DRIVE_2MA); // set signal strength to 2 mA on a 1500 ohms load
  si5351_output_enable(SI5351_CLK0,disable);            // enable signal output 0
  si5351_set_freq(14000000,SI5351_CLK1);               // set output clock 1 to 14 Mhz
  si5351_drive_strength(SI5351_CLK1,SI5351_DRIVE_2MA); // set signal strength to 2 mA
  si5351_set_clock_invert(SI5351_CLK1,enable);         // invert signal on clock 1 ( phase 180° )
  si5351_output_enable(SI5351_CLK1,enable);            // enable signal output 1
  repeat
  until (1=0);
end.

