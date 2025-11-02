unit pico_adc_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}{$H+}
interface
uses
  pico_c;

{$IF DEFINED(DEBUG) or DEFINED(DEBUG_ADC)}
{$L adc.c-debug.obj}
{$L __noinline__adc.c-debug.obj}
{$ELSE}
{$L adc.c.obj}
{$L __noinline__adc.c.obj}
{$ENDIF}

(*
  Initialise the ADC HW
*)
procedure adc_init; cdecl; external;

(*
  Initialise the gpio for use as an ADC pin
  Prepare a GPIO for use with ADC, by disabling all digital functions.
param
  gpio The GPIO number to use. Allowable GPIO numbers are 26 to 29 inclusive.
*)
procedure adc_gpio_init(gpio:longWord); cdecl ; external name '__noinline__adc_gpio_init';

(*
  ADC input select
  Select an ADC input. 0...3 are GPIOs 26...29 respectively.
  Input 4 is the onboard temperature sensor.
param
  input Input to select.
*)
procedure adc_select_input(input : longWord); cdecl ; external name '__noinline__adc_select_input';

(*! \brief  Get the currently selected ADC input channel
 *  \ingroup hardware_adc
 *
 * \return The currently selected input channel. 0...3 are GPIOs 26...29 respectively. Input 4 is the onboard temperature sensor.
 *)
function adc_get_selected_input:longWord; cdecl ; external name '__noinline__adc_get_selected_input';

(*
  Round Robin sampling selector
  This function sets which inputs are to be run through in round robin mode.
  Value between 0 and 0x1f (bit 0 to bit 4 for GPIO 26 to 29 and temperature sensor input respectively)
param
  input_mask A bit pattern indicating which of the 5 inputs are to be sampled. Write a value of 0 to disable round robin sampling.
*)
procedure adc_set_round_robin(input_mask : longWord); cdecl ; external name '__noinline__adc_set_round_robin';

(*
  Enable the onboard temperature sensor
param
  enable Set true to power on the onboard temperature sensor, false to power off.
*)
procedure adc_set_temp_sensor_enabled(enable: boolean); cdecl ; external name '__noinline__adc_set_temp_sensor_enabled';

(*
  Perform a single conversion
  Performs an ADC conversion, waits for the result, and then returns it.
return
  Result of the conversion.
*)
function adc_read:word; cdecl ; external name '__noinline__adc_read';

(*
  Enable or disable free-running sampling mode
param
  run false to disable, true to enable free running conversion mode.
*)
procedure adc_run(run:boolean); cdecl ; external name '__noinline__adc_run';

(*
  Set the ADC Clock divisor
 Period of samples will be (1 + div) cycles on average. Note it takes 96 cycles to perform a conversion,
  so any period less than that will be clamped to 96.
param
  clkdiv If non-zero, conversion will be started at intervals rather than back to back.
*)
procedure adc_set_clkdiv(clkdiv : real); cdecl ; external name '__noinline_adc_set_clkdiv';

(*
  Setup the ADC FIFO
  FIFO is 4 samples long, if a conversion is completed and the FIFO is full the result is dropped.
param
  en Enables write each conversion result to the FIFO
  dreq_en Enable DMA requests when FIFO contains data
  dreq_thresh Threshold for DMA requests/FIFO IRQ if enabled.
  err_in_fifo If enabled, bit 15 of the FIFO contains error flag for each sample
  byte_shift Shift FIFO contents to be one byte in size (for byte DMA) - enables DMA to byte buffers.
*)
procedure adc_fifo_setup(en : boolean; dreq_en : boolean; dreq_thresh : word; err_in_fifo:boolean; byte_shift:boolean); cdecl ; external name '__noinline__adc_fifo_setup';

(*
  Check FIFO empty state
return
  Returns true if the fifo is empty
*)
function adc_fifo_is_empty: boolean; cdecl ; external name '__noinline__adc_fifo_is_empty';

(*
  Get number of entries in the ADC FIFO
  The ADC FIFO is 4 entries long. This function will return how many samples are currently present.
*)
function adc_fifo_get_level: byte; cdecl ; external name '__noinline__adc_fifo_get_level';

(*
  Get ADC result from FIFO
  Pops the latest result from the ADC FIFO.
*)
function adc_fifo_get:word;cdecl ; external name '__noinline__adc_fifo_get';

(*
  Wait for the ADC FIFO to have data.
  Blocks until data is present in the FIFO
*)
function adc_fifo_get_blocking: word; cdecl ; external name '__noinline__adc_fifo_get_blocking';

(*
  Drain the ADC FIFO
  Will wait for any conversion to complete then drain the FIFO discarding any results.
*)
procedure adc_fifo_drain; cdecl ; external name '__noinline__adc_fifo_drain';

(*
  Enable/Disable ADC interrupts.
param
  enabled Set to true to enable the ADC interrupts, false to disable
*)
procedure adc_irq_set_enabled(enabled:boolean); cdecl ; external name '__noinline__adc_irq_set_enabled';

implementation

begin
end.
