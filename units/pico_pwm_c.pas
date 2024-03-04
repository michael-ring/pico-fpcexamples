unit pico_pwm_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}
{$H+}
{$modeswitch advancedrecords}
{$SCOPEDENUMS ON}

interface
uses
  pico_gpio_c;

{$IF DEFINED(DEBUG) or DEFINED(DEBUG_PWM)}
{$L __noinline__pwm.c-debug.obj}
{$ELSE}
{$L __noinline__pwm.c.obj}
{$ENDIF}

(** \file hardware/pwm.h
 *  \defgroup hardware_pwm hardware_pwm
 *
 * Hardware Pulse Width Modulation (PWM) API
 *
 * The RP2040 PWM block has 8 identical slices. Each slice can drive two PWM output signals, or
 * measure the frequency or duty cycle of an input signal. This gives a total of up to 16 controllable
 * PWM outputs. All 30 GPIOs can be driven by the PWM block.
 *
 * The PWM hardware functions by continuously comparing the input value to a free-running counter. This produces a
 * toggling output where the amount of time spent at the high output level is proportional to the input value. The fraction of
 * time spent at the high signal level is known as the duty cycle of the signal.
 *
 * The default behaviour of a PWM slice is to count upward until the wrap value (\ref pwm_config_set_wrap) is reached, and then
 * immediately wrap to 0. PWM slices also offer a phase-correct mode, where the counter starts to count downward after
 * reaching TOP, until it reaches 0 again.
 *
 * \subsection pwm_example Example
 * \addtogroup hardware_pwm
 * \include hello_pwm.c
 *)

(** \brief PWM Divider mode settings
 *   \ingroup hardware_pwm
 *
 *)
type
  Tpwm_clkdiv_mode = (
    PWM_DIV_FREE_RUNNING = 0, ///< Free-running counting at rate dictated by fractional divider
    PWM_DIV_B_HIGH = 1,       ///< Fractional divider is gated by the PWM B pin
    PWM_DIV_B_RISING = 2,     ///< Fractional divider advances with each rising edge of the PWM B pin
    PWM_DIV_B_FALLING = 3    ///< Fractional divider advances with each falling edge of the PWM B pin
  );

  Tpwm_chan = (
    PWM_CHAN_A = 0,
    PWM_CHAN_B = 1
  );

 Tpwm_config = record
    csr : longWord;
    &div : longWord;
    top : longWord;
  end;

procedure check_slice_num_param(slice_num : longWord) cdecl; external name '__noinline__check_slice_num_param';

(** \brief Determine the PWM slice that is attached to the specified GPIO
 *  \ingroup hardware_pwm
 *
 * \return The PWM slice number that controls the specified GPIO.
 *)
function pwm_gpio_to_slice_num(gpio : TPinIdentifier):longWord; cdecl; external name '__noinline__pwm_gpio_to_slice_num';

(** \brief Determine the PWM channel that is attached to the specified GPIO.
 *  \ingroup hardware_pwm
 *
 * Each slice 0 to 7 has two channels, A and B.
 *
 * \return The PWM channel that controls the specified GPIO.
 *)
function pwm_gpio_to_channel(gpio : TPinIdentifier):longWord; cdecl; external name '__noinline__pwm_gpio_to_channel';

(** \brief Set phase correction in a PWM configuration
 *  \ingroup hardware_pwm
 *
 * \param c PWM configuration struct to modify
 * \param phase_correct true to set phase correct modulation, false to set trailing edge
 *
 * Setting phase control to true means that instead of wrapping back to zero when the wrap point is reached,
 * the PWM starts counting back down. The output frequency is halved when phase-correct mode is enabled.
 *)
procedure pwm_config_set_phase_correct(var c : Tpwm_config; phase_correct: boolean); cdecl; external name '__noinline__pwm_config_set_phase_correct';

(** \brief Set PWM clock divider in a PWM configuration
 *  \ingroup hardware_pwm
 *
 * \param c PWM configuration struct to modify
 * \param div Value to divide counting rate by. Must be greater than or equal to 1.
 *
 * If the divide mode is free-running, the PWM counter runs at clk_sys / div.
 * Otherwise, the divider reduces the rate of events seen on the B pin input (level or edge)
 * before passing them on to the PWM counter.
 *)
procedure pwm_config_set_clkdiv(var c : Tpwm_config; &div : real); cdecl; external name '__noinline__pwm_config_set_clkdiv';

(** \brief Set PWM clock divider in a PWM configuration using an 8:4 fractional value
 *  \ingroup hardware_pwm
 *
 * \param c PWM configuration struct to modify
 * \param integer 8 bit integer part of the clock divider. Must be greater than or equal to 1.
 * \param fract 4 bit fractional part of the clock divider
 *
 * If the divide mode is free-running, the PWM counter runs at clk_sys / div.
 * Otherwise, the divider reduces the rate of events seen on the B pin input (level or edge)
 * before passing them on to the PWM counter.
 *)
procedure pwm_config_set_clkdiv_int_frac(var c : Tpwm_config; &integer : byte; fract : byte); cdecl; external name '__noinline__pwm_config_set_clkdiv_int_frac';

(** \brief Set PWM clock divider in a PWM configuration
 *  \ingroup hardware_pwm
 *
 * \param c PWM configuration struct to modify
 * \param div Integer value to reduce counting rate by. Must be greater than or equal to 1.
 *
 * If the divide mode is free-running, the PWM counter runs at clk_sys / div.
 * Otherwise, the divider reduces the rate of events seen on the B pin input (level or edge)
 * before passing them on to the PWM counter.
 *)
procedure pwm_config_set_clkdiv_int(var c : Tpwm_config; &div : longWord); cdecl; external name '__noinline__pwm_config_set_clkdiv_int';

(** \brief Set PWM counting mode in a PWM configuration
 *  \ingroup hardware_pwm
 *
 * \param c PWM configuration struct to modify
 * \param mode PWM divide/count mode
 *
 * Configure which event gates the operation of the fractional divider.
 * The default is always-on (free-running PWM). Can also be configured to count on
 * high level, rising edge or falling edge of the B pin input.
 *)
procedure pwm_config_set_clkdiv_mode(var c : Tpwm_config; mode : Tpwm_clkdiv_mode); cdecl; external name '__noinline__pwm_config_set_clkdiv_mode';

(** \brief Set output polarity in a PWM configuration
 *  \ingroup hardware_pwm
 *
 * \param c PWM configuration struct to modify
 * \param a true to invert output A
 * \param b true to invert output B
 *)
procedure pwm_config_set_output_polarity(var c : Tpwm_config; a : boolean; b:boolean); cdecl; external name '__noinline__pwm_config_set_output_polarity';

(** \brief Set PWM counter wrap value in a PWM configuration
 *  \ingroup hardware_pwm
 *
 * Set the highest value the counter will reach before returning to 0. Also known as TOP.
 *
 * \param c PWM configuration struct to modify
 * \param wrap Value to set wrap to
 *)
procedure pwm_config_set_wrap(var c : Tpwm_config; wrap : word); cdecl; external name '__noinline__pwm_config_set_wrap';

(** \brief Initialise a PWM with settings from a configuration object
 *  \ingroup hardware_pwm
 *
 * Use the \ref pwm_get_default_config() function to initialise a config structure, make changes as
 * needed using the pwm_config_* functions, then call this function to set up the PWM.
 *
 * \param slice_num PWM slice number
 * \param c The configuration to use
 * \param start If true the PWM will be started running once configured. If false you will need to start
 *  manually using \ref pwm_set_enabled() or \ref pwm_set_mask_enabled()
 *)
procedure pwm_init(slice_num : longWord; var c : Tpwm_config; start : boolean); cdecl; external name '__noinline__pwm_init';

(** \brief Get a set of default values for PWM configuration
 *  \ingroup hardware_pwm
 *
 * PWM config is free-running at system clock speed, no phase correction, wrapping at 0xffff,
 * with standard polarities for channels A and B.
 *
 * \return Set of default values.
 *)
function pwm_get_default_config : Tpwm_config; cdecl; external name '__noinline__pwm_get_default_config';

(** \brief Set the current PWM counter wrap value
 *  \ingroup hardware_pwm
 *
 * Set the highest value the counter will reach before returning to 0. Also
 * known as TOP.
 *
 * The counter wrap value is double-buffered in hardware. This means that,
 * when the PWM is running, a write to the counter wrap value does not take
 * effect until after the next time the PWM slice wraps (or, in phase-correct
 * mode, the next time the slice reaches 0). If the PWM is not running, the
 * write is latched in immediately.
 *
 * \param slice_num PWM slice number
 * \param wrap Value to set wrap to
 *)
procedure pwm_set_wrap(slice_num : longWord; wrap : word); cdecl; external name '__noinline__pwm_set_wrap';

(** \brief Set the current PWM counter compare value for one channel
 *  \ingroup hardware_pwm
 *
 * Set the value of the PWM counter compare value, for either channel A or channel B.
 *
 * The counter compare register is double-buffered in hardware. This means
 * that, when the PWM is running, a write to the counter compare values does
 * not take effect until the next time the PWM slice wraps (or, in
 * phase-correct mode, the next time the slice reaches 0). If the PWM is not
 * running, the write is latched in immediately.
 *
 * \param slice_num PWM slice number
 * \param chan Which channel to update. 0 for A, 1 for B.
 * \param level new level for the selected output
 *)

procedure pwm_set_chan_level(slice_num : longWord; chan : longWord; level : word); cdecl; external name '__noinline__pwm_set_chan_level';

(** \brief Set PWM counter compare values
 *  \ingroup hardware_pwm
 *
 * Set the value of the PWM counter compare values, A and B.
 *
 * The counter compare register is double-buffered in hardware. This means
 * that, when the PWM is running, a write to the counter compare values does
 * not take effect until the next time the PWM slice wraps (or, in
 * phase-correct mode, the next time the slice reaches 0). If the PWM is not
 * running, the write is latched in immediately.
 *
 * \param slice_num PWM slice number
 * \param level_a Value to set compare A to. When the counter reaches this value the A output is deasserted
 * \param level_b Value to set compare B to. When the counter reaches this value the B output is deasserted
 *)
procedure pwm_set_both_levels(slice_num : longWord; level_a : word; level_b: word); cdecl; external name '__noinline__pwm_set_both_levels';

(** \brief Helper function to set the PWM level for the slice and channel associated with a GPIO.
 *  \ingroup hardware_pwm
 *
 * Look up the correct slice (0 to 7) and channel (A or B) for a given GPIO, and update the corresponding
 * counter compare field.
 *
 * This PWM slice should already have been configured and set running. Also be careful of multiple GPIOs
 * mapping to the same slice and channel (if GPIOs have a difference of 16).
 *
 * The counter compare register is double-buffered in hardware. This means
 * that, when the PWM is running, a write to the counter compare values does
 * not take effect until the next time the PWM slice wraps (or, in
 * phase-correct mode, the next time the slice reaches 0). If the PWM is not
 * running, the write is latched in immediately.
 *
 * \param gpio GPIO to set level of
 * \param level PWM level for this GPIO
 *)
procedure pwm_set_gpio_level(gpio : TPinIdentifier; level : word); cdecl; external name '__noinline__pwm_set_gpio_level';

(** \brief Get PWM counter
 *  \ingroup hardware_pwm
 *
 * Get current value of PWM counter
 *
 * \param slice_num PWM slice number
 * \return Current value of the PWM counter
 *)
function pwm_get_counter(slice_num : longWord):word; cdecl; external name '__noinline__pwm_get_counter';

(** \brief Set PWM counter
 *  \ingroup hardware_pwm
 *
 * Set the value of the PWM counter
 *
 * \param slice_num PWM slice number
 * \param c Value to set the PWM counter to
 *
 *)
procedure pwm_set_counter(slice_num : longWord; c : word); cdecl; external name '__noinline__pwm_set_counter';

(** \brief Advance PWM count
 *  \ingroup hardware_pwm
 *
 * Advance the phase of a running the counter by 1 count.
 *
 * This function will return once the increment is complete.
 *
 * \param slice_num PWM slice number
 *)
procedure pwm_advance_count(slice_num : longWord); cdecl; external name '__noinline__pwm_advance_count';

(** \brief Retard PWM count
 *  \ingroup hardware_pwm
 *
 * Retard the phase of a running counter by 1 count
 *
 * This function will return once the retardation is complete.
 *
 * \param slice_num PWM slice number
 *)
procedure pwm_retard_count(slice_num : longWord); cdecl; external name '__noinline__pwm_retard_count';

(** \brief Set PWM clock divider using an 8:4 fractional value
 *  \ingroup hardware_pwm
 *
 * Set the clock divider. Counter increment will be on sysclock divided by this value, taking into account the gating.
 *
 * \param slice_num PWM slice number
 * \param integer  8 bit integer part of the clock divider
 * \param fract 4 bit fractional part of the clock divider
 *)
procedure pwm_set_clkdiv_int_frac(slice_num : longWord; &integer : byte; fract : byte); cdecl; external name '__noinline__pwm_set_clkdiv_int_frac';

(** \brief Set PWM clock divider
 *  \ingroup hardware_pwm
 *
 * Set the clock divider. Counter increment will be on sysclock divided by this value, taking into account the gating.
 *
 * \param slice_num PWM slice number
 * \param divider Floating point clock divider,  1.f <= value < 256.f
 *)
procedure pwm_set_clkdiv(slice_num : longWord; divider: real); cdecl; external name '__noinline__pwm_set_clkdiv';

(** \brief Set PWM output polarity
 *  \ingroup hardware_pwm
 *
 * \param slice_num PWM slice number
 * \param a true to invert output A
 * \param b true to invert output B
 *)
procedure pwm_set_output_polarity(slice_num : longWord; a : boolean; b:boolean); cdecl; external name '__noinline__pwm_set_output_polarity';

(** \brief Set PWM divider mode
 *  \ingroup hardware_pwm
 *
 * \param slice_num PWM slice number
 * \param mode Required divider mode
 *)
procedure pwm_set_clkdiv_mode(slice_num : longWord;mode : Tpwm_clkdiv_mode); cdecl; external name '__noinline__pwm_set_clkdiv_mode';

(** \brief Set PWM phase correct on/off
 *  \ingroup hardware_pwm
 *
 * \param slice_num PWM slice number
 * \param phase_correct true to set phase correct modulation, false to set trailing edge
 *
 * Setting phase control to true means that instead of wrapping back to zero when the wrap point is reached,
 * the PWM starts counting back down. The output frequency is halved when phase-correct mode is enabled.
 *)
procedure pwm_set_phase_correct(slice_num : longWord; phase_correct : boolean); cdecl; external name '__noinline__pwm_set_phase_correct';

(** \brief Enable/Disable PWM
 *  \ingroup hardware_pwm
 *
 * When a PWM is disabled, it halts its counter, and the output pins are left
 * high or low depending on exactly when the counter is halted. When
 * re-enabled the PWM resumes immediately from where it left off.
 *
 * If the PWM's output pins need to be low when halted:
 *
 * - The counter compare can be set to zero whilst the PWM is enabled, and
 *   then the PWM disabled once both pins are seen to be low
 *
 * - The GPIO output overrides can be used to force the actual pins low
 *
 * - The PWM can be run for one cycle (i.e. enabled then immediately disabled)
 *   with a TOP of 0, count of 0 and counter compare of 0, to force the pins
 *   low when the PWM has already been halted. The same method can be used
 *   with a counter compare value of 1 to force a pin high.
 *
 * Note that, when disabled, the PWM can still be advanced one count at a time
 * by pulsing the PH_ADV bit in its CSR. The output pins transition as though
 * the PWM were enabled.
 *
 * \param slice_num PWM slice number
 * \param enabled true to enable the specified PWM, false to disable.
 *)
procedure pwm_set_enabled(slice_num : longWord; enabled: boolean); cdecl; external name '__noinline__pwm_set_enabled';

(** \brief Enable/Disable multiple PWM slices simultaneously
 *  \ingroup hardware_pwm
 *
 * \param mask Bitmap of PWMs to enable/disable. Bits 0 to 7 enable slices 0-7 respectively
 *)
procedure pwm_set_mask_enabled(mask : longWord); cdecl; external name '__noinline__pwm_set_mask_enabled';

(*! \brief  Enable PWM instance interrupt
 *  \ingroup hardware_pwm
 *
 * Used to enable a single PWM instance interrupt.
 *
 * \param slice_num PWM block to enable/disable
 * \param enabled true to enable, false to disable
 *)
procedure pwm_set_irq_enabled(slice_num : longWord; enabled:boolean); cdecl; external name '__noinline__pwm_set_irq_enabled';

(*! \brief  Enable multiple PWM instance interrupts
 *  \ingroup hardware_pwm
 *
 * Use this to enable multiple PWM interrupts at once.
 *
 * \param slice_mask Bitmask of all the blocks to enable/disable. Channel 0 = bit 0, channel 1 = bit 1 etc.
 * \param enabled true to enable, false to disable
 *)
procedure pwm_set_irq_mask_enabled(slice_mask : longWord; enabled:boolean); cdecl; external name '__noinline__pwm_set_irq_mask_enabled';

(*! \brief  Clear a single PWM channel interrupt
 *  \ingroup hardware_pwm
 *
 * \param slice_num PWM slice number
 *)
procedure pwm_clear_irq(slice_num : longWord); cdecl; external name '__noinline__pwm_clear_irq';

(*! \brief  Get PWM interrupt status, raw
 *  \ingroup hardware_pwm
 *
 * \return Bitmask of all PWM interrupts currently set
 *)
function pwm_get_irq_status_mask: longWord; cdecl; external name '__noinline__pwm_get_irq_status_mask';

(*! \brief  Force PWM interrupt
 *  \ingroup hardware_pwm
 *
 * \param slice_num PWM slice number
 *)
procedure pwm_force_irq(slice_num : longWord); cdecl; external name '__noinline__pwm_force_irq';

(*! \brief Return the DREQ to use for pacing transfers to a particular PWM slice
 *  \ingroup hardware_pwm
 *
 * \param slice_num PWM slice number
 *)
function pwm_get_dreq(slice_num : longWord):longWord; cdecl; external name '__noinline__pwm_get_dreq';

implementation

end.

