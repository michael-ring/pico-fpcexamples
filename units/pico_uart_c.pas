unit pico_uart_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}{$H+}
interface
{$WARN 5023 off : Unit "$1" not used in $2}
uses
  pico_timer_c,
  pico_c;

{$IF DEFINED(DEBUG) or DEFINED(DEBUG_UART)}
{$L uart.c-debug.obj}
{$L __noinline__uart.c-debug.obj}
{$ELSE}
{$L uart.c.obj}
{$L __noinline__uart.c.obj}
{$ENDIF}

type
  TUart_Inst = pointer;

  TUARTParity = (
    UART_PARITY_NONE,
    UART_PARITY_EVEN,
    UART_PARITY_ODD
  );
  TUARTStopBits = (
    UART_STOPBITS_ONE=1,
    UART_STOPBITS_TWO=2
  );

  TUARTDataBits = (
    UART_DATABITS_FIVE=0,
    UART_DATABITS_SIX=1,
    UART_DATABITS_SEVEN=2,
    UART_DATABITS_EIGHT=3
  );

  (*! \brief Convert UART instance to hardware instance number
   *  \ingroup hardware_uart
   *
   * \param uart UART instance
   * \return Number of UART, 0 or 1.
   *)
  function uart_get_index(uart : TUart_Inst) : longWord; cdecl; external name '__noinline__uart_get_index';

  function uart_get_instance(instance : longWord) : Tuart_inst; cdecl; external name '__noinline__uart_get_instance';

  function uart_get_hw(uart: Tuart_inst): TUART_Registers; cdecl; external name '__noinline__uart_get_hw';

(*
  Initialise a UART
  Put the UART into a known state, and enable it. Must be called before other functions.
param
  uart UART instance. uart0 or uart1
  baudrate Baudrate of UART in Hz
return
  Actual set baudrate
note
  There is no guarantee that the baudrate requested will be possible, the nearest will be chosen,
  and this function will return the configured baud rate.
*)
function uart_init(var uart:TUART_Registers; baudrate:longWord):longWord; cdecl; external;

(*
  DeInitialise a UART
  Disable the UART if it is no longer used. Must be reinitialised before
  being used again.
param
  uart UART instance. uart0 or uart1
*)
procedure uart_deinit(var uart : TUART_Registers); cdecl; external;

(*
  Set UART baud rate
  Set baud rate as close as possible to requested, and return actual rate selected.
param
  uart UART instance. uart0 or uart1
  baudrate Baudrate in Hz
 *)
function uart_set_baudrate(var uart : TUART_Registers; baudrate:longWord):longWord; cdecl; external;

(*
  Set UART flow control CTS/RTS
param
  uart UART instance. \ref uart0 or \ref uart1
  cts If true enable flow control of TX  by clear-to-send input
  rts If true enable assertion of request-to-send output by RX flow control
*)
procedure uart_set_hw_flow(var uart:TUART_Registers; cts:boolean; rts:boolean); cdecl; external name '__noinline__uart_set_hw_flow';

(*
  Set UART data format
  Configure the data format (bits etc() for the UART
param
  uart UART instance. \ref uart0 or \ref uart1
  data_bits Number of bits of data. 5..8
  stop_bits Number of stop bits 1..2
  parity Parity option.
fixed for sdk 1.5.5 jp.mandon 2024
*)
procedure uart_set_format(var uart:TUART_Registers; data_bits:longword; stop_bits:longword; parity:TUARTParity);cdecl;external;
(*
  Setup UART interrupts
  Enable the UART's interrupt output. An interrupt handler will need to be installed prior to calling
 this function.
param
  uart UART instance. \ref uart0 or \ref uart1
  rx_has_data If true an interrupt will be fired when the RX FIFO contain data.
  tx_needs_data If true an interrupt will be fired when the TX FIFO needs data.
*)
procedure uart_set_irq_enables(var uart:TUART_Registers; rx_has_data:boolean; tx_needs_data : boolean); cdecl; external name '__noinline__uart_set_irq_enables';

(*
  Test if specific UART is enabled
param
  uart UART instance. \ref uart0 or \ref uart1
return
  true if the UART is enabled
*)
function uart_is_enabled(var uart:TUART_Registers): boolean; cdecl; external name '__noinline__uart_is_enabled';

(*
  Enable/Disable the FIFOs on specified UART
param
  uart UART instance. \ref uart0 or \ref uart1
  enabled true to enable FIFO (default), false to disable
*)
procedure uart_set_fifo_enabled(var uart:TUART_Registers; enabled:boolean); cdecl; external;

(*
  Determine if space is available in the TX FIFO
param
  uart UART instance. \ref uart0 or \ref uart1
return
  false if no space available, true otherwise
*)
function uart_is_writable(var uart:TUART_Registers):boolean; cdecl; external name '__noinline__uart_is_writable';

(*
  Wait for the UART TX fifo to be drained
param
  uart UART instance. \ref uart0 or \ref uart1
*)
procedure uart_tx_wait_blocking(var uart:TUART_Registers); cdecl; external name '__noinline__uart_tx_wait_blocking';

(*
  Determine whether data is waiting in the RX FIFO
param
  uart UART instance. \ref uart0 or \ref uart1
return
  0 if no data available, otherwise the number of bytes, at least, that can be read
note
  HW limitations mean this function will return either 0 or 1.
*)
function uart_is_readable(var uart:TUART_Registers):boolean; cdecl; external name '__noinline__uart_is_readable';

(*
  Write to the UART for transmission.
  This function will block until all the data has been sent to the UART
param
  uart UART instance. \ref uart0 or \ref uart1
  src The bytes to send
  len The number of bytes to send
*)
procedure uart_write_blocking(var uart:TUART_Registers; var src:TByteArray;len:longWord); cdecl; external name '__noinline__uart_write_blocking';

(*
  Read from the UART
  This function will block until all the data has been received from the UART
param
  uart UART instance. \ref uart0 or \ref uart1
  dst Buffer to accept received bytes
  len The number of bytes to receive.
*)
procedure uart_read_blocking(var uart:TUART_Registers; var dst : TByteArray; len : longWord); cdecl; external name '__noinline__uart_read_blocking';

(*
  Write single character to UART for transmission.
  This function will block until all the character has been sent
param
  uart UART instance. \ref uart0 or \ref uart1
  c The character  to send
*)
procedure uart_putc_raw(var uart:TUART_Registers; c : Char); cdecl; external name '__noinline__uart_putc_raw';

(*
  Write single character to UART for transmission, with optional CR/LF conversions
  This function will block until the character has been sent
param
  uart UART instance. \ref uart0 or \ref uart1
  c The character  to send
*)
procedure uart_putc(var uart:TUART_Registers; c : Char); cdecl; external name '__noinline__uart_putc';

(*
  Write string to UART for transmission, doing any CR/LF conversions
  This function will block until the entire string has been sent
param
  uart UART instance. \ref uart0 or \ref uart1
  s The null terminated string to send
*)
procedure uart_puts(var uart:TUART_Registers; s : string); cdecl; external name '__noinline__uart_puts';

(*
  Read a single character to UART
  This function will block until the character has been read
param
  uart UART instance. \ref uart0 or \ref uart1
return
  The character read.
*)
function uart_getc(var uart:TUART_Registers):Char; cdecl; external name '__noinline__uart_getc';

(*
  Assert a break condition on the UART transmission.
param
  uart UART instance. \ref uart0 or \ref uart1
  en Assert break condition (TX held low) if true. Clear break condition if false.
*)
procedure uart_set_break(var uart:TUART_Registers; en : boolean); cdecl; external name '__noinline__uart_set_break';

(*
  Set CR/LF conversion on UART
param
  uart UART instance. \ref uart0 or \ref uart1
  translate If true, convert line feeds to carriage return on transmissions
*)
procedure uart_set_translate_crlf(var uart:TUART_Registers; translate:boolean); cdecl; external;

(*
  Wait for the default UART'S TX fifo to be drained
 *)
//procedure uart_default_tx_wait_blocking;

(*! \brief Wait for the default UART's TX FIFO to be drained
 *  \ingroup hardware_uart
 *)
procedure uart_default_tx_wait_blocking() ; cdecl; external name '__noinline__uart_default_tx_wait_blocking';
(*
  Wait for up to a certain number of microseconds for the RX FIFO to be non empty
param
  uart UART instance. \ref uart0 or \ref uart1
  us the number of microseconds to wait at most (may be 0 for an instantaneous check)
return
  true if the RX FIFO became non empty before the timeout, false otherwise
*)
function uart_is_readable_within_us(var uart:TUART_Registers; us:longWord):boolean; cdecl; external;

(*! \brief Return the DREQ to use for pacing transfers to/from a particular UART instance
 *  \ingroup hardware_uart
 *
 * \param uart UART instance. \ref uart0 or \ref uart1
 * \param is_tx true for sending data to the UART instance, false for receiving data from the UART instance
 *)
function uart_get_dreq(uart : Tuart_inst; is_tx : boolean): longWord; cdecl; external name '__noinline__uart_get_dreq';

implementation

{
procedure uart_set_format(var uart:TUART_Registers; data_bits:TUARTDataBits; stop_bits:TUARTStopBits; parity:TUARTParity);
begin
  case
end;
}

begin
end.
