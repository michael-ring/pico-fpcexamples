unit pico_gpio_c;
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
  pico_c;
{$IF DEFINED(DEBUG) or DEFINED(DEBUG_GPIO)}
{$L gpio.c-debug.obj}
{$L __noinline__gpio.c-debug.obj}
{$ELSE}
{$L gpio.c.obj}
{$L __noinline__gpio.c.obj}
{$ENDIF}

type
  TPinIdentifier=-1..28;
  {$IF DEFINED(FPC_MCU_TINY_2040)}
  TPicoPin = record
  const
    None=-1;
    GP0=   0;  GP0_SPI0_RX=    0;  GP0_I2C0_SDA=  0;  GP0_UART0_TX=   0;                UART_TX = 0;
    GP1=   1;  GP1_SPI0_CS=    1;  GP1_I2C0_SCL=  1;  GP1_UART0_RX=   1;                UART_RX = 1;
    GP2=   2;  GP2_SPI0_SCK=   2;  GP2_I2C1_SDA=  2;  GP2_UART0_CTS=  2;                I2C_SDA = 2;
    GP3=   3;  GP3_SPI0_TX=    3;  GP3_I2C1_SCL=  3;  GP3_UART0_RTS=  3;                I2C_SCL = 3;
    GP4=   4;  GP4_SPI0_RX=    4;  GP4_I2C0_SDA=  4;  GP4_UART1_TX=   4;                SPI_RX  = 4;
    GP5=   5;  GP5_SPI0_CS=    5;  GP5_I2C0_SCL=  5;  GP5_UART1_RX=   5;                SPI_CS  = 5;
    GP6=   6;  GP6_SPI0_SCK=   6;  GP6_I2C1_SDA=  6;  GP6_UART1_CTS=  6;                SPI_SCK = 6;
    GP7=   7;  GP7_SPI0_TX=    7;  GP7_I2C1_SDL=  7;  GP7_UART1_RTS=  7;                SPI_TX  = 7;

    GP18= 18;  GP18_LED_R=    18;                                                       LED_R=   18;
    GP19= 19;  GP19_LED_G=    19; LED_G=        19;                                     LED=     19;
    GP20= 20;  GP20_LED_B=    20;                                                       LED_B=   20;
    GP23= 23;  GP23_USER_SW=  23;                                                       USER_SW= 23;
    GP26= 26;  GP26_SPI1_SCK= 26; GP26_I2C1_SDA= 26; GP26_UART1_CTS= 26; GP26_ADC0= 26; ADC0=    26;
    GP27= 27;  GP27_SPI1_TX=  27; GP27_I2C1_SCL= 27; GP27_UART1_RTS= 27; GP27_ADC1= 27; ADC1=    27;
    GP28= 28;  GP28_SPI1_RX=  28; GP28_I2C0_ADA= 28; GP28_UART0_TX=  28; GP28_ADC2= 28; ADC2=    28;
    GP29= 29;  GP29_SPI1_CS=  29; GP29_I2C0_SCL= 29; GP29_UART0_RX=  29; GP29_ADC3= 29; ADC3=    29;
  end;
  {$ELSEIF DEFINED(FPC_MCU_QTPY_RP2040)}
  TPicoPin = record
  const
    None=-1;
    GP3=   3;  GP3_SPI0_TX=    3;  GP3_I2C1_SCL=  3;  GP3_UART0_RTS=  3;                SPI_TX=   3;
    GP4=   4;  GP4_SPI0_RX=    4;  GP4_I2C0_SDA=  4;  GP4_UART1_TX=   4;                SPI_RX=   4;
    GP6=   6;  GP6_SPI0_SCK=   6;  GP6_I2C1_SDA=  6;  GP6_UART1_CTS=  6;                SPI_SCK=  6;
    GP9=   9;  GP9_SPI1_CS=    9;  GP9_I2C0_SCL=  9;  GP9_UART1_RX=   9;                UART_RX = 9;
    //There is no single LED on QTPY RP2040, so define an unused pin so that code compiles
                                                                                             LED=10;
    GP11= 11;                                                                       NEOPIXEL_PWR=11;
    GP12= 12;                                                                           NEOPIXEL=12;
    GP20= 20;  GP20_SPI0_RX=  20; GP20_I2C0_SDA= 20; GP20_UART1_TX=  20;                UART_TX= 20;
    GP24= 24;  GP24_SPI1_RX=  24; GP24_I2C0_SDA= 24; GP24_UART1_TX=  24;                I2C_SDA= 24;
    GP25= 25;  GP25_SPI1_CS=  25; GP25_I2C0_SCL= 25; GP25_UART1_RX=  25;                I2C_SCL= 25;
    GP26= 26;  GP26_SPI1_SCK= 26; GP26_I2C1_SDA= 26; GP26_UART1_CTS= 26; GP26_ADC0= 26; ADC0=    26;
    GP27= 27;  GP27_SPI1_TX=  27; GP27_I2C1_SCL= 27; GP27_UART1_RTS= 27; GP27_ADC1= 27; ADC1=    27;
    GP28= 28;  GP28_SPI1_RX=  28; GP28_I2C0_ADA= 28; GP28_UART0_TX=  28; GP28_ADC2= 28; ADC2=    28;
    GP29= 29;  GP29_SPI1_CS=  29; GP29_I2C0_SCL= 29; GP29_UART0_RX=  29; GP29_ADC3= 29; ADC3=    29;
  end;
  {$ELSEIF DEFINED(FPC_MCU_FEATHER_RP2040)}
  TPicoPin = record
const
    None=-1;
    GP0=   0;  GP0_SPI0_RX=    0;  GP0_I2C0_SDA=  0;  GP0_UART0_TX=   0;                 UART_TX= 0;
    GP1=   1;  GP1_SPI0_CS=    1;  GP1_I2C0_SCL=  1;  GP1_UART0_RX=   1;                 UART_RX= 1;
    GP2=   2;  GP2_SPI0_SCK=   2;  GP2_I2C1_SDA=  2;  GP2_UART0_CTS=  2;                 I2C_SDA= 2;
    GP3=   3;  GP3_SPI0_TX=    3;  GP3_I2C1_SCL=  3;  GP3_UART0_RTS=  3;                 I2C_SCL= 3;

    GP6=   6;  GP6_SPI0_SCK=   6;  GP6_I2C1_SDA=  6;  GP6_UART1_CTS=  6; 
    GP7=   7;  GP7_SPI0_TX=    7;  GP7_I2C1_SDL=  7;  GP7_UART1_RTS=  7;
    GP8=   8;  GP8_SPI1_RX=    8;  GP8_I2C0_SDA=  8;  GP8_UART1_TX=   8;
    GP9=   9;  GP9_SPI1_CS=    9;  GP9_I2C0_SCL=  9;  GP9_UART1_RX=   9;

    GP10= 10;  GP10_SPI1_SCK= 10; GP10_I2C1_SDA= 10; GP10_UART1_CTS= 10; 
    GP11= 11;  GP11_SPI1_TX=  11; GP11_I2C1_SDL= 11; GP11_UART1_RTS= 11;
    GP12= 12;  GP12_SPI1_RX=  12; GP12_I2C0_SDA= 12; GP12_UART0_TX=  12;
    GP13= 13;  GP13_LED=      13;                                                       LED=     13;
    GP16= 16;  GP16_NEOPIXEL= 16;                                                       NEOPIXEL=16;
    GP18= 18;  GP18_SPI0_SCK= 18; GP18_I2C1_SDA= 18; GP18_UART0_CTS= 18;                SPI_SCK= 18;
    GP19= 19;  GP19_SPI0_TX=  19; GP19_I2C1_SCL= 19; GP19_UART0_RTS= 19;                SPI_TX=  19;
    GP20= 20;  GP20_SPI0_RX=  20; GP20_I2C0_SDA= 20; GP20_UART1_TX=  20;                SPI_RX=  20;
    GP26= 26;  GP26_SPI1_SCK= 26; GP26_I2C1_SDA= 26; GP26_UART1_CTS= 26; GP26_ADC0= 26; ADC0=    26;
    GP27= 27;  GP27_SPI1_TX=  27; GP27_I2C1_SCL= 27; GP27_UART1_RTS= 27; GP27_ADC1= 27; ADC1=    27;
    GP28= 28;  GP28_SPI1_RX=  28; GP28_I2C0_ADA= 28; GP28_UART0_TX=  28; GP28_ADC2= 28; ADC2=    28;
    GP29= 29;  GP29_SPI1_CS=  29; GP29_I2C0_SCL= 29; GP29_UART0_RX=  29; GP29_ADC3= 29; ADC3=    29;
  end;
  {$ELSEIF DEFINED(FPC_MCU_ITSYBITSY_RP2040)}
  TPicoPin = record
const
    None=-1;
    GP0=   0;  GP0_SPI0_RX=    0;  GP0_I2C0_SDA=  0;  GP0_UART0_TX=   0;                UART_TX = 0;
    GP1=   1;  GP1_SPI0_CS=    1;  GP1_I2C0_SCL=  1;  GP1_UART0_RX=   1;                UART_RX = 1;

    GP2=   2;  GP2_SPI0_SCK=   2;  GP2_I2C1_SDA=  2;  GP2_UART0_CTS=  2;                I2C_SDA = 2;
    GP3=   3;  GP3_SPI0_TX=    3;  GP3_I2C1_SCL=  3;  GP3_UART0_RTS=  3;                I2C_SCL = 3;
    GP4=   4;  GP4_SPI0_RX=    4;  GP4_I2C0_SDA=  4;  GP4_UART1_TX=   4; 
    GP5=   5;  GP5_SPI0_CS=    5;  GP5_I2C0_SCL=  5;  GP5_UART1_RX=   5; 

    GP6=   6;  GP6_SPI0_SCK=   6;  GP6_I2C1_SDA=  6;  GP6_UART1_CTS=  6;
    GP7=   7;  GP7_SPI0_TX=    7;  GP7_I2C1_SDL=  7;  GP7_UART1_RTS=  7;
    GP8=   8;  GP8_SPI1_RX=    8;  GP8_I2C0_SDA=  8;  GP8_UART1_TX=   8;
    GP9=   9;  GP9_SPI1_CS=    9;  GP9_I2C0_SCL=  9;  GP9_UART1_RX=   9;

    GP10= 10;  GP10_SPI1_SCK= 10; GP10_I2C1_SDA= 10; GP10_UART1_CTS= 10;
    GP11= 11;  GP11_LED=      11;                                                       LED    = 11; 
    GP12= 12;  GP12_SPI1_RX=  12; GP12_I2C0_SDA= 12; GP12_UART0_TX=  12;
    GP13= 13;  GP13_SPI1_CS=  13; GP13_I2C0_SCL= 13; GP13_UART0_RX=  13;

    GP14= 14;  GP14_SPI1_SCK= 14; GP14_I2C1_SDA= 14; GP14_UART0_CTS= 14;
    GP15= 15;  GP15_SPI1_TX=  15; GP15_I2C1_SDL= 15; GP15_UART0_RTS= 15; 
    GP16= 16;  GP16_SPI1_RX=  16; GP16_I2C0_SDA= 16; GP16_UART0_TX=  16;                
    GP17= 17;  GP17_SPI1_CS=  17; GP17_I2C0_SCL= 17; GP17_UART0_RX=  17;                

    GP18= 18;  GP18_SPI0_SCK= 18; GP18_I2C1_SDA= 18; GP18_UART0_CTS= 18;                SPI_SCK= 18;
    GP19= 19;  GP19_SPI0_TX=  19; GP19_I2C1_SCL= 19; GP19_UART0_RTS= 19;                SPI_TX=  19;

    GP20= 20;  GP20_SPI0_RX=  20; GP20_I2C0_SDA= 20; GP20_UART1_TX=  20;                SPI_RX=  20;
    GP21= 21;  GP21_SPI0_CS=  21; GP21_I2C0_SCL= 21; GP21_UART1_RX=  21;                SPI_CS=  21; 
    GP22= 22;  GP22_SPI0_SCK= 22; GP22_I2C1_SDA= 22; GP22_UART1_CTS= 22;
    GP25= 25;  GP25_LED=      25;                                                       LED=     25;
    GP26= 26;  GP26_SPI1_SCK= 26; GP26_I2C1_SDA= 26; GP26_UART1_CTS= 26; GP26_ADC0= 26; ADC0=    26;
    GP27= 27;  GP27_SPI1_TX=  27; GP27_I2C1_SCL= 27; GP27_UART1_RTS= 27; GP27_ADC1= 27; ADC1=    27;
    GP28= 28;  GP28_SPI1_RX=  28; GP28_I2C0_ADA= 28; GP28_UART0_TX=  28; GP28_ADC2= 28; ADC2=    28;
  end;
  {$ELSE}
  TPicoPin = record
  const
    None=-1;
    GP0=   0;  GP0_SPI0_RX=    0;  GP0_I2C0_SDA=  0;  GP0_UART0_TX=   0;                UART_TX = 0;
    GP1=   1;  GP1_SPI0_CS=    1;  GP1_I2C0_SCL=  1;  GP1_UART0_RX=   1;                UART_RX = 1;

    GP2=   2;  GP2_SPI0_SCK=   2;  GP2_I2C1_SDA=  2;  GP2_UART0_CTS=  2;
    GP3=   3;  GP3_SPI0_TX=    3;  GP3_I2C1_SCL=  3;  GP3_UART0_RTS=  3;
    GP4=   4;  GP4_SPI0_RX=    4;  GP4_I2C0_SDA=  4;  GP4_UART1_TX=   4;                I2C_SDA = 4;
    GP5=   5;  GP5_SPI0_CS=    5;  GP5_I2C0_SCL=  5;  GP5_UART1_RX=   5;                I2C_SCL = 5;

    GP6=   6;  GP6_SPI0_SCK=   6;  GP6_I2C1_SDA=  6;  GP6_UART1_CTS=  6;
    GP7=   7;  GP7_SPI0_TX=    7;  GP7_I2C1_SDL=  7;  GP7_UART1_RTS=  7;
    GP8=   8;  GP8_SPI1_RX=    8;  GP8_I2C0_SDA=  8;   GP8_UART1_TX=  8;
    GP9=   9;  GP9_SPI1_CS=    9;  GP9_I2C0_SCL=  9;   GP9_UART1_RX=  9;

    GP10= 10;  GP10_SPI1_SCK= 10; GP10_I2C1_SDA= 10; GP10_UART1_CTS= 10;
    GP11= 11;  GP11_SPI1_TX=  11; GP11_I2C1_SDL= 11; GP11_UART1_RTS= 11;
    GP12= 12;  GP12_SPI1_RX=  12; GP12_I2C0_SDA= 12;  GP12_UART0_TX= 12;
    GP13= 13;  GP13_SPI1_CS=  13; GP13_I2C0_SCL= 13;  GP13_UART0_RX= 13;

    GP14= 14;  GP14_SPI1_SCK= 14; GP14_I2C1_SDA= 14; GP14_UART0_CTS= 14;
    GP15= 15;  GP15_SPI1_TX=  15; GP15_I2C1_SDL= 15; GP15_UART0_RTS= 15;
    GP16= 16;  GP16_SPI1_RX=  16; GP16_I2C0_SDA= 16; GP16_UART0_TX=  16;                SPI_RX= 16;
    GP17= 17;  GP17_SPI1_CS=  17; GP17_I2C0_SCL= 17; GP17_UART0_RX=  17;                SPI_CS= 17;

    GP18= 18;  GP18_SPI0_SCK= 18; GP18_I2C1_SDA= 18; GP18_UART0_CTS= 18;                SPI_SCK= 18;
    GP19= 19;  GP19_SPI0_TX=  19; GP19_I2C1_SCL= 19; GP19_UART0_RTS= 19;                SPI_TX=  19;

    GP20= 20;  GP20_SPI0_RX=  20; GP20_I2C0_SDA= 20; GP20_UART1_TX=  20;
    GP21= 21;  GP21_SPI0_CS=  21; GP21_I2C0_SCL= 21; GP21_UART1_RX=  21;
    GP22= 22;  GP22_SPI0_SCK= 22; GP22_I2C1_SDA= 22; GP22_UART1_CTS= 22;
    GP25= 25;  GP25_LED=      25;                                                       LED=     25;
    GP26= 26;  GP26_SPI1_SCK= 26; GP26_I2C1_SDA= 26; GP26_UART1_CTS= 26; GP26_ADC0= 26; ADC0=    26;
    GP27= 27;  GP27_SPI1_TX=  27; GP27_I2C1_SCL= 27; GP27_UART1_RTS= 27; GP27_ADC1= 27; ADC1=    27;
    GP28= 28;  GP28_SPI1_RX=  28; GP28_I2C0_ADA= 28; GP28_UART0_TX=  28; GP28_ADC2= 28; ADC2=    28;
  end;
  {$ENDIF}

  var
  {$IF DEFINED(FPC_MCU_TINY_2040)}
    uart : TUART_Registers absolute UART0_BASE;
    spi  : TSPI_Registers absolute SPI0_BASE;
    i2c  : TI2C_Registers absolute I2C0_BASE;
  {$ELSEIF DEFINED(FPC_MCU_QTPY_RP2040)}
    uart : TUART_Registers absolute UART1_BASE;
    spi  : TSPI_Registers absolute SPI0_BASE;
    i2c  : TI2C_Registers absolute I2C0_BASE;
  {$ELSEIF DEFINED(FPC_MCU_FEATHER_RP2040)}
    uart : TUART_Registers absolute UART1_BASE;
    spi  : TSPI_Registers absolute SPI0_BASE;
    i2c  : TI2C_Registers absolute I2C1_BASE;
  {$ELSEIF DEFINED(FPC_MCU_ITZYBITZY_RP2040)}
    uart : TUART_Registers absolute UART1_BASE;
    spi  : TSPI_Registers absolute SPI0_BASE;
    i2c  : TI2C_Registers absolute I2C1_BASE;
  {$ELSE}
    uart : TUART_Registers absolute UART0_BASE;
    spi  : TSPI_Registers absolute SPI0_BASE;
    i2c  : TI2C_Registers absolute I2C0_BASE;
  {$ENDIF}
    
type
  (*! \brief  GPIO function definitions for use with function select
   *  \ingroup hardware_gpio
   * \brief GPIO function selectors
   *
   * Each GPIO can have one function selected at a time. Likewise, each peripheral input (e.g. UART0 RX) should only be
   * selected on one GPIO at a time. If the same peripheral input is connected to multiple GPIOs, the peripheral sees the logical
   * OR of these GPIO inputs.
   *
   * Please refer to the datasheet for more information on GPIO function selection.
   *)
  TGPIO_Function = (
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
    GPIO_FUNC_NULL = $1f
  );

  TGPIO_Direction = (
    GPIO_IN=0,
    GPIO_OUT=1
  );

  (*! \brief  GPIO Interrupt level definitions (GPIO events)
   *  \ingroup hardware_gpio
   *  \brief GPIO Interrupt levels
   *
   * An interrupt can be generated for every GPIO pin in 4 scenarios:
   *
   * * Level High: the GPIO pin is a logical 1
   * * Level Low: the GPIO pin is a logical 0
   * * Edge High: the GPIO has transitioned from a logical 0 to a logical 1
   * * Edge Low: the GPIO has transitioned from a logical 1 to a logical 0
   *
   * The level interrupts are not latched. This means that if the pin is a logical 1 and the level high interrupt is active, it will
   * become inactive as soon as the pin changes to a logical 0. The edge interrupts are stored in the INTR register and can be
   * cleared by writing to the INTR register.
   *)
  TGPIO_IRQ_level = (
    GPIO_IRQ_LEVEL_LOW = $1,
    GPIO_IRQ_LEVEL_HIGH = $2,
    GPIO_IRQ_EDGE_FALL = $4,
    GPIO_IRQ_EDGE_RISE = $8
  );

(*! Callback function type for GPIO events
 *  \ingroup hardware_gpio
 *
 * \param gpio Which GPIO caused this interrupt
 * \param event_mask Which events caused this interrupt. See \ref gpio_irq_level for details.
 * \sa gpio_set_irq_enabled_with_callback()
 * \sa gpio_set_irq_callback()
 *)
 TGPIO_Irq_callback = procedure (gpio:TPinIdentifier; events:longWord);

  TGPIO_Override = (
    GPIO_OVERRIDE_NORMAL = 0,      ///< peripheral signal selected via \ref gpio_set_function
    GPIO_OVERRIDE_INVERT = 1,      ///< invert peripheral signal selected via \ref gpio_set_function
    GPIO_OVERRIDE_LOW = 2,         ///< drive low/disable output
    GPIO_OVERRIDE_HIGH = 3        ///< drive high/enable output
  );

(*! \brief Slew rate limiting levels for GPIO outputs
 *  \ingroup hardware_gpio
 *
 * Slew rate limiting increases the minimum rise/fall time when a GPIO output
 * is lightly loaded, which can help to reduce electromagnetic emissions.
 * \sa gpio_set_slew_rate
 *)
  TGPIO_slew_rate = (
    GPIO_SLEW_RATE_SLOW = 0,  ///< Slew rate limiting enabled
    GPIO_SLEW_RATE_FAST = 1   ///< Slew rate limiting disabled
  );

(*! \brief Drive strength levels for GPIO outputs
 *  \ingroup hardware_gpio
 *
 * Drive strength levels for GPIO outputs.
 * \sa gpio_set_drive_strength
 *)
  TGPIO_drive_strength = (
    GPIO_DRIVE_STRENGTH_2MA = 0, ///< 2 mA nominal drive strength
    GPIO_DRIVE_STRENGTH_4MA = 1, ///< 4 mA nominal drive strength
    GPIO_DRIVE_STRENGTH_8MA = 2, ///< 8 mA nominal drive strength
    GPIO_DRIVE_STRENGTH_12MA = 3 ///< 12 mA nominal drive strength
  );

  procedure check_gpio_param(gpio:TPinIdentifier); cdecl; external name '__noinline__check_gpio_param';

  // ----------------------------------------------------------------------------
  // Pad Controls + IO Muxing
  // ----------------------------------------------------------------------------
  // Declarations for gpio.c

  (*
  Select GPIO function
param:
  gpio GPIO number
  fn Which GPIO function select to use from list \ref gpio_function
*)
procedure gpio_set_function(gpio:TPinIdentifier; fn:TGPIO_Function); cdecl; external;

(*! \brief Determine current GPIO function
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \return Which GPIO function is currently selected from list \ref gpio_function
 *)
function gpio_get_function(gpio:TPinIdentifier):TGPIO_Function; cdecl; external;

(*
  Select up and down pulls on specific GPIO
param:
  gpio GPIO number
  up If true set a pull up on the GPIO
  down If true set a pull down on the GPIO
note:
  On the RP2040, setting both pulls enables a "bus keep" function,
  i.e. a weak pull to whatever is current high/low state of GPIO.
*)
procedure gpio_set_pulls(gpio:TPinIdentifier;const up,down:boolean); cdecl; external;

(*
  Set specified GPIO to be pulled up.
param:
  gpio GPIO number
*)
procedure gpio_pull_up(gpio:TPinIdentifier); cdecl; external name '__noinline__gpio_pull_up';

(*
  Determine if the specified GPIO is pulled up.
param:
  gpio GPIO number
return:
  return true if the GPIO is pulled up
*)
function gpio_is_pulled_up(gpio:TPinIdentifier):boolean; cdecl; external name '__noinline__gpio_is_pulled_up';

(*
  Set specified GPIO to be pulled down.
param:
  gpio GPIO number
*)
procedure gpio_pull_down(gpio:TPinIdentifier); cdecl; external name '__noinline__gpio_pull_down';

(*
  Determine if the specified GPIO is pulled down.
param:
  gpio GPIO number
return:
  return true if the GPIO is pulled down
*)
function gpio_is_pulled_down(gpio:TPinIdentifier):boolean; cdecl; external name '__noinline__gpio_is_pulled_down';

(*
  Disable pulls on specified GPIO
param:
  gpio GPIO number
*)
procedure gpio_disable_pulls(gpio:TPinIdentifier); cdecl; external name '__noinline__gpio_disable_pulls';

(*! \brief Set GPIO IRQ override
 *  \ingroup hardware_gpio
 *
 * Optionally invert a GPIO IRQ signal, or drive it high or low
 *
 * \param gpio GPIO number
 * \param value See \ref gpio_override
 *)
procedure gpio_set_irqover(gpio:TPinIdentifier;value : longWord);cdecl; external;

(*
  Set GPIO output override
param:
  gpio GPIO number
  value See gpio_override
*)
procedure gpio_set_outover(gpio:TPinIdentifier; value : longWord);cdecl; external;

(*
  Select GPIO input override
param:
  gpio GPIO number
  value See gpio_override
*)
procedure gpio_set_inover(gpio:TPinIdentifier; value : longWord);cdecl; external;

(*
  Select GPIO output enable override
param:
  gpio GPIO number
  value See gpio_override
*)
procedure gpio_set_oeover(gpio:TPinIdentifier; value : longWord);cdecl; external;

(*
  Enable GPIO input
param:
  gpio GPIO number
  enabled true to enable input on specified GPIO
*)
procedure gpio_set_input_enabled(gpio:TPinIdentifier; enabled:boolean);cdecl; external;

(*! \brief Enable/disable GPIO input hysteresis (Schmitt trigger)
 *  \ingroup hardware_gpio
 *
 * Enable or disable the Schmitt trigger hysteresis on a given GPIO. This is
 * enabled on all GPIOs by default. Disabling input hysteresis can lead to
 * inconsistent readings when the input signal has very long rise or fall
 * times, but slightly reduces the GPIO's input delay.
 *
 * \sa gpio_is_input_hysteresis_enabled
 * \param gpio GPIO number
 * \param enabled true to enable input hysteresis on specified GPIO
 *)
procedure gpio_set_input_hysteresis_enabled(gpio:TPinIdentifier; enabled:boolean);cdecl; external;

(*! \brief Determine whether input hysteresis is enabled on a specified GPIO
 *  \ingroup hardware_gpio
 *
 * \sa gpio_set_input_hysteresis_enabled
 * \param gpio GPIO number
 *)
function gpio_is_input_hysteresis_enabled(gpio:TPinIdentifier):boolean;cdecl; external;


(*! \brief Set slew rate for a specified GPIO
 *  \ingroup hardware_gpio
 *
 * \sa gpio_get_slew_rate
 * \param gpio GPIO number
 * \param slew GPIO output slew rate
 *)
procedure gpio_set_slew_rate(gpio:TPinIdentifier; slew : Tgpio_slew_rate);cdecl; external;

(*! \brief Determine current slew rate for a specified GPIO
 *  \ingroup hardware_gpio
 *
 * \sa gpio_set_slew_rate
 * \param gpio GPIO number
 * \return Current slew rate of that GPIO
 *)
function gpio_get_slew_rate(gpio:TPinIdentifier) : Tgpio_slew_rate;cdecl; external;

(*! \brief Set drive strength for a specified GPIO
 *  \ingroup hardware_gpio
 *
 * \sa gpio_get_drive_strength
 * \param gpio GPIO number
 * \param drive GPIO output drive strength
 *)
procedure gpio_set_drive_strength(gpio:TPinIdentifier; drive : Tgpio_drive_strength); cdecl; external;

(*! \brief Determine current slew rate for a specified GPIO
 *  \ingroup hardware_gpio
 *
 * \sa gpio_set_drive_strength
 * \param gpio GPIO number
 * \return Current drive strength of that GPIO
 *)
 function gpio_get_drive_strength(gpio:TPinIdentifier):Tgpio_drive_strength; cdecl; external;

(*
  Enable or disable interrupts for specified GPIO
note:
  The IO IRQs are independent per-processor. This configures IRQs for
  the processor that calls the function.
param:
  gpio GPIO number
  events Which events will cause an interrupt
  enabled Enable or disable flag

  Events is a bitmask of the following:
  bit | interrupt
  ----|----------
    0 | Low level
    1 | High level
    2 | Edge low
    3 | Edge high
*)
procedure gpio_set_irq_enabled(gpio:TPinIdentifier; events : longWord; enabled:boolean);cdecl; external;

(*! \brief Set the generic callback used for GPIO IRQ events for the current core
 *  \ingroup hardware_gpio
 *
 * This function sets the callback used for all GPIO IRQs on the current core that are not explicitly
 * hooked via \ref gpio_add_raw_irq_handler or other gpio_add_raw_irq_handler_ functions.
 *
 * This function is called with the GPIO number and event mask for each of the (not explicitly hooked)
 * GPIOs that have events enabled and that are pending (see \ref gpio_get_irq_event_mask).
 *
 * \note The IO IRQs are independent per-processor. This function affects
 * the processor that calls the function.
 *
 * \param callback default user function to call on GPIO irq. Note only one of these can be set per processor.
 *)
procedure gpio_set_irq_callback(callback : Tgpio_irq_callback); cdecl; external;

(*! \brief Convenience function which performs multiple GPIO IRQ related initializations
 *  \ingroup hardware_gpio
 *
 * This method is a slightly eclectic mix of initialization, that:
 *
 * \li Updates whether the specified events for the specified GPIO causes an interrupt on the calling core based
 * on the enable flag.
 *
 * \li Sets the callback handler for the calling core to callback (or clears the handler if the callback is NULL).
 *
 * \li Enables GPIO IRQs on the current core if enabled is true.
 *
 * This method is commonly used to perform a one time setup, and following that any additional IRQs/events are enabled
 * via \ref gpio_set_irq_enabled. All GPIOs/events added in this way on the same core share the same callback; for multiple
 * independent handlers for different GPIOs you should use \ref gpio_add_raw_irq_handler and related functions.
 *
 * This method is equivalent to:
 *
 * \code{.c}
 * gpio_set_irq_enabled(gpio, event_mask, enabled);
 * gpio_set_irq_callback(callback);
 * if (enabled) irq_set_enabled(IO_IRQ_BANK0, true);
 * \endcode
 *
 * \note The IO IRQs are independent per-processor. This method affects only the processor that calls the function.
 *
 * \param gpio GPIO number
 * \param event_mask Which events will cause an interrupt. See \ref gpio_irq_level for details.
 * \param enabled Enable or disable flag
 * \param callback user function to call on GPIO irq. if NULL, the callback is removed
 *)
procedure gpio_set_irq_enabled_with_callback(gpio:TPinIdentifier; events:longWord; enabled:boolean; callback : TGPIO_Irq_callback);cdecl; external;

(*
  Enable dormant wake up interrupt for specified GPIO
  This configures IRQs to restart the XOSC or ROSC when they are
  disabled in dormant mode
param:
  gpio GPIO number
  events Which events will cause an interrupt. See \ref gpio_set_irq_enabled for details.
  enabled Enable/disable flag
 *)
procedure gpio_set_dormant_irq_enabled(gpio:TPinIdentifier; events:longWord;enabled:boolean);cdecl; external;

(*! \brief Return the current interrupt status (pending events) for the given GPIO
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 * \return Bitmask of events that are currently pending for the GPIO. See \ref gpio_irq_level for details.
 * \sa gpio_acknowledge_irq
 *)
function gpio_get_irq_event_mask(gpio:TPinIdentifier): longWord; cdecl; external name '__noinline__gpio_get_irq_event_mask';

(*! \brief Acknowledge a GPIO interrupt for the specified events on the calling core
 *  \ingroup hardware_gpio
 *
 * \note This may be called with a mask of any of valid bits specified in \ref gpio_irq_level, however
 * it has no effect on \a level sensitive interrupts which remain pending while the GPIO is at the specified
 * level. When handling \a level sensitive interrupts, you should generally disable the interrupt (see
 * \ref gpio_set_irq_enabled) and then set it up again later once the GPIO level has changed (or to catch
 * the opposite level).
 *
 * \param gpio GPIO number
 *
 * \note For callbacks set with \ref gpio_set_irq_enabled_with_callback, or \ref gpio_set_irq_callback, this function is called automatically.
 * \param event_mask Bitmask of events to clear. See \ref gpio_irq_level for details.
 *)
procedure gpio_acknowledge_irq(gpio:TPinIdentifier;events:longWord);cdecl; external;

(*! \brief Adds a raw GPIO IRQ handler for the specified GPIOs on the current core
 *  \ingroup hardware_gpio
 *
 * In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
 * it is possible to add explicit GPIO IRQ handlers which are called independent of the default callback. The order
 * relative to the default callback can be controlled via the order_priority parameter (the default callback has the priority
 * \ref GPIO_IRQ_CALLBACK_ORDER_PRIORITY which defaults to the lowest priority with the intention of it running last).
 *
 * This method adds such an explicit GPIO IRQ handler, and disables the "default" callback for the specified GPIOs.
 *
 * \note Multiple raw handlers should not be added for the same GPIOs, and this method will assert if you attempt to.
 *
 * A raw handler should check for whichever GPIOs and events it handles, and acknowledge them itself; it might look something like:
 *
 * \code{.c}
 * void my_irq_handler(void) {
 *     if (gpio_get_irq_event_mask(my_gpio_num) & my_gpio_event_mask) {
 *        gpio_acknowledge_irq(my_gpio_num, my_gpio_event_mask);
 *       // handle the IRQ
 *     }
 *     if (gpio_get_irq_event_mask(my_gpio_num2) & my_gpio_event_mask2) {
 *        gpio_acknowledge_irq(my_gpio_num2, my_gpio_event_mask2);
 *       // handle the IRQ
 *     }
 * }
 * \endcode
 *
 * @param gpio_mask a bit mask of the GPIO numbers that will no longer be passed to the default callback for this core
 * @param handler the handler to add to the list of GPIO IRQ handlers for this core
 * @param order_priority the priority order to determine the relative position of the handler in the list of GPIO IRQ handlers for this core.
 *)
procedure gpio_add_raw_irq_handler_with_order_priority_masked(gpio_mask: longWord; handler : TIRQ_Handler; order_priority : byte); cdecl; external;

(*! \brief Adds a raw GPIO IRQ handler for a specific GPIO on the current core
 *  \ingroup hardware_gpio
 *
 * In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
 * it is possible to add explicit GPIO IRQ handlers which are called independent of the default callback. The order
 * relative to the default callback can be controlled via the order_priority parameter(the default callback has the priority
 * \ref GPIO_IRQ_CALLBACK_ORDER_PRIORITY which defaults to the lowest priority with the intention of it running last).
 *
 * This method adds such a callback, and disables the "default" callback for the specified GPIO.
 *
 * \note Multiple raw handlers should not be added for the same GPIO, and this method will assert if you attempt to.
 *
 * A raw handler should check for whichever GPIOs and events it handles, and acknowledge them itself; it might look something like:
 *
 * \code{.c}
 * void my_irq_handler(void) {
 *     if (gpio_get_irq_event_mask(my_gpio_num) & my_gpio_event_mask) {
 *        gpio_acknowledge_irq(my_gpio_num, my_gpio_event_mask);
 *       // handle the IRQ
 *     }
 * }
 * \endcode
 *
 * @param gpio the GPIO number that will no longer be passed to the default callback for this core
 * @param handler the handler to add to the list of GPIO IRQ handlers for this core
 * @param order_priority the priority order to determine the relative position of the handler in the list of GPIO IRQ handlers for this core.
 *)
procedure gpio_add_raw_irq_handler_with_order_priority(gpio:TPinIdentifier;  handler: Tirq_handler; order_priority : byte); cdecl; external name '__noinline__gpio_add_raw_irq_handler_with_order_priority';

(*! \brief Adds a raw GPIO IRQ handler for the specified GPIOs on the current core
 *  \ingroup hardware_gpio
 *
 * In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
 * it is possible to add explicit GPIO IRQ handlers which are called independent of the default event callback.
 *
 * This method adds such a callback, and disables the "default" callback for the specified GPIOs.
 *
 * \note Multiple raw handlers should not be added for the same GPIOs, and this method will assert if you attempt to.
 *
 * A raw handler should check for whichever GPIOs and events it handles, and acknowledge them itself; it might look something like:
 *
 * \code{.c}
 * void my_irq_handler(void) {
 *     if (gpio_get_irq_event_mask(my_gpio_num) & my_gpio_event_mask) {
 *        gpio_acknowledge_irq(my_gpio_num, my_gpio_event_mask);
 *       // handle the IRQ
 *     }
 *     if (gpio_get_irq_event_mask(my_gpio_num2) & my_gpio_event_mask2) {
 *        gpio_acknowledge_irq(my_gpio_num2, my_gpio_event_mask2);
 *       // handle the IRQ
 *     }
 * }
 * \endcode
 *
 * @param gpio_mask a bit mask of the GPIO numbers that will no longer be passed to the default callback for this core
 * @param handler the handler to add to the list of GPIO IRQ handlers for this core
 *)
procedure gpio_add_raw_irq_handler_masked(gpio_mask : longWord; handler: Tirq_handler); cdecl; external;

(*! \brief Adds a raw GPIO IRQ handler for a specific GPIO on the current core
 *  \ingroup hardware_gpio
 *
 * In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
 * it is possible to add explicit GPIO IRQ handlers which are called independent of the default event callback.
 *
 * This method adds such a callback, and disables the "default" callback for the specified GPIO.
 *
 * \note Multiple raw handlers should not be added for the same GPIO, and this method will assert if you attempt to.
 *
 * A raw handler should check for whichever GPIOs and events it handles, and acknowledge them itself; it might look something like:
 *
 * \code{.c}
 * void my_irq_handler(void) {
 *     if (gpio_get_irq_event_mask(my_gpio_num) & my_gpio_event_mask) {
 *        gpio_acknowledge_irq(my_gpio_num, my_gpio_event_mask);
 *       // handle the IRQ
 *     }
 * }
 * \endcode
 *
 * @param gpio the GPIO number that will no longer be passed to the default callback for this core
 * @param handler the handler to add to the list of GPIO IRQ handlers for this core
 *)
procedure gpio_add_raw_irq_handler(gpio:TPinIdentifier; handler: Tirq_handler); cdecl; external name '__noinline__gpio_add_raw_irq_handler';

(*! \brief Removes a raw GPIO IRQ handler for the specified GPIOs on the current core
 *  \ingroup hardware_gpio
 *
 * In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
 * it is possible to add explicit GPIO IRQ handlers which are called independent of the default event callback.
 *
 * This method removes such a callback, and enables the "default" callback for the specified GPIOs.
 *
 * @param gpio_mask a bit mask of the GPIO numbers that will now be passed to the default callback for this core
 * @param handler the handler to remove from the list of GPIO IRQ handlers for this core
 *)
procedure gpio_remove_raw_irq_handler_masked(gpio_mask : longWord; handler: Tirq_handler); cdecl; external;

(*! \brief Removes a raw GPIO IRQ handler for the specified GPIO on the current core
 *  \ingroup hardware_gpio
 *
 * In addition to the default mechanism of a single GPIO IRQ event callback per core (see \ref gpio_set_irq_callback),
 * it is possible to add explicit GPIO IRQ handlers which are called independent of the default event callback.
 *
 * This method removes such a callback, and enables the "default" callback for the specified GPIO.
 *
 * @param gpio the GPIO number that will now be passed to the default callback for this core
 * @param handler the handler to remove from the list of GPIO IRQ handlers for this core
 *)
procedure gpio_remove_raw_irq_handler(gpio:TPinIdentifier; handler: Tirq_handler); cdecl; external name '__noinline__gpio_remove_raw_irq_handler';


(*
  Initialise a GPIO for (enabled I/O and set func to GPIO_FUNC_SIO)
  Clear the output enable (i.e. set to input)
  Clear any output value.
param:
  gpio GPIO number
*)
procedure gpio_init(gpio:TPinIdentifier{GPIO number});cdecl; external;

(*! \brief Resets a GPIO back to the NULL function, i.e. disables it.
 *  \ingroup hardware_gpio
 *
 * \param gpio GPIO number
 *)
procedure gpio_deinit(gpio:TPinIdentifier);cdecl; external;

(*
  Initialise multiple GPIOs (enabled I/O and set func to GPIO_FUNC_SIO)
  Clear the output enable (i.e. set to input)
  Clear any output value.
param:
  gpio_mask Mask with 1 bit per GPIO number to initialize
*)
procedure gpio_init_mask(gpio_mask : longWord);cdecl; external;

(*
  Get state of a single specified GPIO
param:
  gpio GPIO number
return:
  Current state of the GPIO. 0 for low, non-zero for high
*)
function gpio_get(gpio:TPinIdentifier):boolean; cdecl; external name '__noinline__gpio_get';

(*
  Get raw value of all GPIOs
return:
  Bitmask of raw GPIO values, as bits 0-29
*)
function gpio_get_all():longWord; cdecl; external name '__noinline__gpio_get_all';

(*
  Drive high every GPIO appearing in mask
param:
  mask Bitmask of GPIO values to set, as bits 0-29
*)
procedure gpio_set_mask(mask:longWord); cdecl; external name '__noinline__gpio_set_mask';

(*
  Drive low every GPIO appearing in mask
param:
  mask Bitmask of GPIO values to clear, as bits 0-29
*)
procedure gpio_clr_mask(mask : longWord); cdecl; external name '__noinline__gpio_clr_mask';

(*
  Toggle every GPIO appearing in mask
param:
  mask Bitmask of GPIO values to toggle, as bits 0-29
*)
procedure gpio_xor_mask(mask:longWord);  cdecl; external name '__noinline__gpio_xor_mask';

(*
  Drive GPIO high/low depending on parameters
param:
  mask Bitmask of GPIO values to change, as bits 0-29
  value Value to set
note:
  For each 1 bit in \p mask, drive that pin to the value given by
  corresponding bit in \p value, leaving other pins unchanged.
  Since this uses the TOGL alias, it is concurrency-safe with e.g. an IRQ
  bashing different pins from the same core.
*)
procedure gpio_put_masked(mask:longWord; value:longWord); cdecl; external name '__noinline__gpio_put_masked';

(*
  Drive all pins simultaneously
param:
  value Bitmask of GPIO values to change, as bits 0-29
*)
procedure gpio_put_all(value:longWord); cdecl; external name '__noinline__gpio_put_all';

(*
  Drive a single GPIO high/low
param:
  gpio GPIO number
  value If false clear the GPIO, otherwise set it.
*)
procedure gpio_put(gpio:TPinIdentifier; value:boolean); cdecl; external name '__noinline__gpio_put';

(*! \brief Determine whether a GPIO is currently driven high or low
 *  \ingroup hardware_gpio
 *
 * This function returns the high/low output level most recently assigned to a
 * GPIO via gpio_put() or similar. This is the value that is presented outward
 * to the IO muxing, *not* the input level back from the pad (which can be
 * read using gpio_get()).
 *
 * To avoid races, this function must not be used for read-modify-write
 * sequences when driving GPIOs -- instead functions like gpio_put() should be
 * used to atomically update GPIOs. This accessor is intended for debug use
 * only.
 *
 * \param gpio GPIO number
 * \return true if the GPIO output level is high, false if low.
 *)
function gpio_get_out_level(gpio:TPinIdentifier) : boolean; cdecl; external name '__noinline__gpio_get_out_level';

(*
  Set a number of GPIOs to output
  Switch all GPIOs in "mask" to output
param:
  mask Bitmask of GPIO to set to output, as bits 0-29
*)
procedure gpio_set_dir_out_masked(mask:longWord);cdecl; external name '__noinline__gpio_set_dir_out_masked';

(*
  Set a number of GPIOs to input
param:
  mask Bitmask of GPIO to set to input, as bits 0-29
*)
procedure gpio_set_dir_in_masked(mask:longWord); cdecl; external name '__noinline__gpio_set_dir_out_masked';

(*
  Set multiple GPIO directions
param:
  mask Bitmask of GPIO to set to input, as bits 0-29
  value Values to set
note:
  For each 1 bit in "mask", switch that pin to the direction given by
  corresponding bit in "value", leaving other pins unchanged.
  E.g. gpio_set_dir_masked(0x3, 0x2); -> set pin 0 to input, pin 1 to output,
  simultaneously.
*)
procedure gpio_set_dir_masked(mask:longWord; value:longWord); cdecl; external name '__noinline__gpio_set_dir_masked';

(*
  Set direction of all pins simultaneously.
param:
  values individual settings for each gpio; for GPIO N, bit N is 1 for out, 0 for in
*)
procedure gpio_set_dir_all_bits(values:longWord); cdecl; external name '__noinline__gpio_set_dir_all_bits';

(*
  Set a single GPIO direction
param:
  gpio GPIO number
  out true for out, false for in
*)
procedure gpio_set_dir(gpio:TPinIdentifier; &out:TGPIO_Direction);cdecl; external name '__noinline__gpio_set_dir';

(*
  Check if a specific GPIO direction is OUT
param:
  gpio GPIO number
return:
  return true if the direction for the pin is OUT
*)
function gpio_is_dir_out(gpio:TPinIdentifier):boolean; cdecl; external name '__noinline__gpio_is_dir_out';

(*
  Get a specific GPIO direction
param:
gpio GPIO number
return:
  return 1 for out, 0 for in
*)
function gpio_get_dir(gpio:TPinIdentifier):TGPIO_Direction; cdecl; external name '__noinline__gpio_get_dir';

procedure gpio_debug_pins_init(); cdecl; external;

implementation
begin
end.
