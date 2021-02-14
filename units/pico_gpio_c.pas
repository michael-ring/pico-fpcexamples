unit pico_gpio_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}{$H+}
interface
uses
  pico_c;
{$L gpio.c.obj}

type
  TGPIODirection = (
    GPIO_IN=0,
    GPIO_OUT=1
  );
  TGPIOFunction = (
    GPIO_FUNC_XIP = 0,
    GPIO_FUNC_SPI = 1,
    GPIO_FUNC_UART = 2,
    GPIO_FUNC_I2C = 3,
    GPIO_FUNC_PWM = 4,
    GPIO_FUNC_SIO = 5,
    GPIO_FUNC_PIO0 = 6,
    GPIO_FUNC_PIO1 = 7,
    GPIO_FUNC_GPCK = 8,
    GPIO_FUNC_USB = 9,
    GPIO_FUNC_NULL = $0f
  );

  TGPIOIRQ_level = (
    GPIO_IRQ_LEVEL_LOW = $1,
    GPIO_IRQ_LEVEL_HIGH = $2,
    GPIO_IRQ_EDGE_FALL = $4,
    GPIO_IRQ_EDGE_RISE = $8
  );

  TGPIOIrq_callback = procedure (gpio:longWord; events:longWord);

  TGPIOOverride = (
    GPIO_OVERRIDE_NORMAL = 0,
    GPIO_OVERRIDE_INVERT = 1,
    GPIO_OVERRIDE_LOW = 2,
    GPIO_OVERRIDE_HIGH = 3
  );

(*! \brief Select GPIO function
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \param fn Which GPIO function select to use from list \ref gpio_function
 *)
procedure gpio_set_function(gpio:longWord; fn:TGPIOFunction); external;

function gpio_get_function(gpio:longWord):TGPIOFunction; external;

(*! \brief Select up and down pulls on specific GPIO
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \param up If true set a pull up on the GPIO
 * \param down If true set a pull down on the GPIO
 *
 * \note On the RP2040, setting both pulls enables a "bus keep" function,
 * i.e. a weak pull to whatever is current high/low state of GPIO.
 *)
procedure gpio_set_pulls(gpio : longWord;const up,down:boolean); external;

(*! \brief Set specified GPIO to be pulled up.
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 *)
procedure gpio_pull_up(gpio : longWord);

(*! \brief Determine if the specified GPIO is pulled up.
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \return true if the GPIO is pulled up
 *)
function gpio_is_pulled_up(gpio:longWord):boolean;

(*! \brief Set specified GPIO to be pulled down.
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 *)
procedure gpio_pull_down(gpio: longWord);

(*! \brief Determine if the specified GPIO is pulled down.
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \return true if the GPIO is pulled down
 *)
function gpio_is_pulled_down(gpio: longWord):boolean;

(*! \brief Disable pulls on specified GPIO
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 *)
procedure gpio_disable_pulls(gpio: longWord);

(*! \brief Set GPIO output override
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \param value See \ref gpio_override
 *)
procedure gpio_set_outover(gpio: longWord; value : longWord);external;

(*! \brief Select GPIO input override
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \param value See \ref gpio_override
 *)
procedure gpio_set_inover(gpio: longWord; value : longWord);external;

(*! \brief Select GPIO output enable override
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \param value See \ref gpio_override
 *)
procedure gpio_set_oeover(gpio: longWord; value : longWord);external;

(*! \brief Enable GPIO input
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \param enabled true to enable input on specified GPIO
 *)
procedure gpio_set_input_enabled(gpio: longWord; enabled:boolean);external;

(*! \brief Enable or disable interrupts for specified GPIO
 *  \ingroup hardware_gpio
 *
 * \note The IO IRQs are independent per-processor. This configures IRQs for
 * the processor that calls the function.
 *
 * \param gpio GPIO number
 * \param events Which events will cause an interrupt
 * \param enabled Enable or disable flag
 *
 * Events is a bitmask of the following:
 *
 * bit | interrupt
 * ----|----------
 *   0 | Low level
 *   1 | High level
 *   2 | Edge low
 *   3 | Edge high
 *)
procedure gpio_set_irq_enabled(gpio: longWord; events : longWord; enabled:boolean);external;

(*! \brief Enable interrupts for specified GPIO
 *  \ingroup hardware_gpio
 *
 * \note The IO IRQs are independent per-processor. This configures IRQs for
 * the processor that calls the function.
 *
 * \param gpio GPIO number
 * \param events Which events will cause an interrupt See \ref gpio_set_irq_enabled for details.
 * \param enabled Enable or disable flag
 * \param callback user function to call on GPIO irq. Note only one of these can be set per processor.
 *
 * \note Currently the GPIO parameter is ignored, and this callback will be called for any enabled GPIO IRQ on any pin.
 *
 *)
procedure gpio_set_irq_enabled_with_callback(gpio: longWord; events:longWord; enabled:boolean; callback : TGPIOIrq_callback);external;

(*! \brief Enable dormant wake up interrupt for specified GPIO
 *  \ingroup hardware_gpio
 *
 * This configures IRQs to restart the XOSC or ROSC when they are
 * disabled in dormant mode
 *
 * \param gpio GPIO number
 * \param events Which events will cause an interrupt. See \ref gpio_set_irq_enabled for details.
 * \param enabled Enable/disable flag
 *)
procedure gpio_set_dormant_irq_enabled(gpio: longWord; events:longWord;enabled:boolean);external;

(*! \brief Acknowledge a GPIO interrupt
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \param events Bitmask of events to clear. See \ref gpio_set_irq_enabled for details.
  *
 *)
procedure gpio_acknowledge_irq(gpio: longWord;events:longWord);external;

(*! \brief Initialise a GPIO for (enabled I/O and set func to GPIO_FUNC_SIO)
 *  \ingroup hardware_gpio
 *
 * Clear the output enable (i.e. set to input)
 * Clear any output value.
 *
 * \param gpio GPIO number
 *)
{Initialise a GPIO for (enabled I/O and set func to GPIO_FUNC_SIO)}
procedure gpio_init(gpio: longWord{GPIO number});external;

(*! \brief Initialise multiple GPIOs (enabled I/O and set func to GPIO_FUNC_SIO)
 *  \ingroup hardware_gpio
 *
 * Clear the output enable (i.e. set to input)
 * Clear any output value.
 *
 * \param gpio_mask Mask with 1 bit per GPIO number to initialize
 *)
procedure gpio_init_mask(gpio_mask : longWord);external;

(*! \brief Get state of a single specified GPIO
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \return Current state of the GPIO. 0 for low, non-zero for high
 *)
function gpio_get(gpio: longWord):boolean;

(*! \brief Get raw value of all GPIOs
 *  \ingroup hardware_gpio
 *
 * \return Bitmask of raw GPIO values, as bits 0-29
 *)
function gpio_get_all():longWord;

(*! \brief Drive high every GPIO appearing in mask
 *  \ingroup hardware_gpio
 *
 * \param mask Bitmask of GPIO values to set, as bits 0-29
 *)
procedure gpio_set_mask(mask:longWord);

(*! \brief Drive low every GPIO appearing in mask
 *  \ingroup hardware_gpio
 *
 * \param mask Bitmask of GPIO values to clear, as bits 0-29
 *)
procedure gpio_clr_mask(mask : longWord);

(*! \brief Toggle every GPIO appearing in mask
 *  \ingroup hardware_gpio
 *
 * \param mask Bitmask of GPIO values to toggle, as bits 0-29
 *)
procedure gpio_xor_mask(mask:longWord);

(*! \brief Drive GPIO high/low depending on parameters
 *  \ingroup hardware_gpio
 *
 * \param mask Bitmask of GPIO values to change, as bits 0-29
 * \param value Value to set
 *
 * For each 1 bit in \p mask, drive that pin to the value given by
 * corresponding bit in \p value, leaving other pins unchanged.
 * Since this uses the TOGL alias, it is concurrency-safe with e.g. an IRQ
 * bashing different pins from the same core.
 *)
procedure gpio_put_masked(mask:longWord; value:longWord);

(*! \brief Drive all pins simultaneously
 *  \ingroup hardware_gpio
 *
 * \param value Bitmask of GPIO values to change, as bits 0-29
 *)
procedure gpio_put_all(value:longWord);

(*! \brief Drive a single GPIO high/low
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \param value If false clear the GPIO, otherwise set it.
 *)
procedure gpio_put(gpio:longWord; value:boolean);

(*! \brief Set a number of GPIOs to output
 *  \ingroup hardware_gpio
 *
 * Switch all GPIOs in "mask" to output
 *
 * \param mask Bitmask of GPIO to set to output, as bits 0-29
 *)
procedure gpio_set_dir_out_masked(mask:longWord);

(*! \brief Set a number of GPIOs to input
 *  \ingroup hardware_gpio
 *
 * \param mask Bitmask of GPIO to set to input, as bits 0-29
 *)
procedure gpio_set_dir_in_masked(mask:longWord);

(*! \brief Set multiple GPIO directions
 *  \ingroup hardware_gpio
 *
 * \param mask Bitmask of GPIO to set to input, as bits 0-29
 * \param value Values to set
 *
 * For each 1 bit in "mask", switch that pin to the direction given by
 * corresponding bit in "value", leaving other pins unchanged.
 * E.g. gpio_set_dir_masked(0x3, 0x2); -> set pin 0 to input, pin 1 to output,
 * simultaneously.
 *)
procedure gpio_set_dir_masked(mask:longWord; value:longWord);

(*! \brief Set direction of all pins simultaneously.
 *  \ingroup hardware_gpio
 *
 * \param values individual settings for each gpio; for GPIO N, bit N is 1 for out, 0 for in
 *)
procedure gpio_set_dir_all_bits(values:longWord);

(*! \brief Set a single GPIO direction
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \param out true for out, false for in
 *)
procedure gpio_set_dir(gpio:longWord; &out:TGPIODirection);

(*! \brief Check if a specific GPIO direction is OUT
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \return true if the direction for the pin is OUT
 *)
function gpio_is_dir_out(gpio:longWord):boolean;

(*! \brief Get a specific GPIO direction
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \return 1 for out, 0 for in
 *)
function gpio_get_dir(gpio:longWord):TGPIODirection;

procedure gpio_debug_pins_init(); external;

implementation

procedure gpio_pull_up(gpio: longWord);
begin
  gpio_set_pulls(gpio, true, false);
end;

function gpio_is_pulled_up(gpio: longWord):boolean;
begin
  result := (padsbank0.io[gpio]) and $08 <> 0;
end;

procedure gpio_pull_down(gpio: longWord);
begin
  gpio_set_pulls(gpio, false, true);
end;

function gpio_is_pulled_down(gpio: longWord):boolean;
begin
  result := (padsbank0.io[gpio]) and $04 <> 0;
end;

procedure gpio_disable_pulls(gpio: longWord);
begin
  gpio_set_pulls(gpio, false, false);
end;

function gpio_get(gpio: longWord):boolean;
begin
  result := (sio.gpio_in and (1 shl gpio)) <> 0;
end;

function gpio_get_all():longWord;
begin
  result := sio.gpio_in;
end;

procedure gpio_set_mask(mask:longWord);
begin
  sio.gpio_set := mask;
end;

procedure gpio_clr_mask(mask:longWord);
begin
  sio.gpio_clr := mask;
end;

procedure gpio_xor_mask(mask:longWord);
begin
  sio.gpio_togl := mask;
end;

procedure gpio_put_masked(mask:longWord; value:longWord);
begin
  sio.gpio_togl := (sio.gpio_out xor value) and mask;
end;

procedure gpio_put_all(value:longWord);
begin
  sio.gpio_out := value;
end;

procedure gpio_put(gpio:longWord; value:boolean);
begin
  if value = true then
    gpio_set_mask(1 shl gpio)
  else
    gpio_clr_mask(1 shl gpio);
end;

procedure gpio_set_dir_out_masked(mask:longWord);
begin
  sio.gpio_oe_set := mask;
end;

procedure gpio_set_dir_in_masked(mask:longWord);
begin
  sio.gpio_oe_clr := mask;
end;

procedure gpio_set_dir_masked(mask:longWord; value:longWord);
begin
  sio.gpio_oe_togl := (sio.gpio_oe xor value) and mask;
end;

procedure gpio_set_dir_all_bits(values:longWord);
begin
  sio.gpio_oe := values;
end;

procedure gpio_set_dir(gpio:longWord; &out:TGPIODirection);
begin
  if &out = TGPIODirection.GPIO_OUT then
    gpio_set_dir_out_masked(1 shl gpio)
  else
    gpio_set_dir_in_masked(1 shl gpio);
end;

function gpio_is_dir_out(gpio : longWord):boolean;
begin
  result := sio.gpio_oe and (1 shl gpio) <> 0;
end;

function gpio_get_dir(gpio:longWord):TGPIODirection;
begin
  result := TGPIODirection(gpio_is_dir_out(gpio));
end;

end.
