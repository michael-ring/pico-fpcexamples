unit pico_spi_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)
{$mode objfpc}
{$H+}
{$modeswitch advancedrecords}
{$SCOPEDENUMS ON}
{$WARN 3187 off : C arrays are passed by reference}
interface
uses
  pico_c;

{$IF DEFINED(DEBUG) or DEFINED(DEBUG_SPI)}
{$L spi.c-debug.obj}
{$L __noinline__spi.c-debug.obj}
{$ELSE}
{$L spi.c.obj}
{$L __noinline__spi.c.obj}
{$ENDIF}

type
  TSPI_cpha = (
    SPI_CPHA_0 = 0,
    SPI_CPHA_1 = 1
  );

  TSPI_cpol = (
    SPI_CPOL_0 = 0,
    SPI_CPOL_1 = 1
  );

  TSPI_order = (
    SPI_LSB_FIRST = 0,
    SPI_MSB_FIRST = 1
  );

  TSPI_DataBits = (
    SPI_DATABITS_FOUR=4,
    SPI_DATABITS_FIVE,
    SPI_DATABITS_SIX,
    SPI_DATABITS_SEVEN,
    SPI_DATABITS_EIGHT,
    SPI_DATABITS_NINE,
    SPI_DATABITS_TEN,
    SPI_DATABITS_ELEVEN,
    SPI_DATABITS_TWELVE,
    SPI_DATABITS_THIRTEEN,
    SPI_DATABITS_FOURTEEN,
    SPI_DATABITS_FIVETEEN,
    SPI_DATABITS_SIXTEEN
  );
(*
  Initialise SPI instances
  Puts the SPI into a known state, and enable it. Must be called before other functions.
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
  baudrate Baudrate required in Hz
note
  There is no guarantee that the baudrate requested will be possible, the nearest will be chosen,
  and this function does not return any indication of this. You can use the \ref spi_set_baudrate function
  which will return the actual baudrate selected if this is important.
*)
procedure spi_init(var spi : TSPI_Registers; baudrate:longWord); cdecl; external;

(*
  Deinitialise SPI instances
  Puts the SPI into a disabled state. Init will need to be called to reenable the device functions.
param
  spi SPI instance specifier, either spi0 or spi1
*)
procedure spi_deinit(var spi : TSPI_Registers); cdecl; external;

(*
  Set SPI baudrate
  Set SPI frequency as close as possible to baudrate, and return the actual achieved rate.
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
  baudrate Baudrate required in Hz, should be capable of a bitrate of at least 2Mbps, or higher, depending on system clock settings.
return
  The actual baudrate set
*)
function spi_set_baudrate(var spi : TSPI_Registers; baudrate:longWord):longWord; cdecl; external;

(*! \brief Get SPI baudrate
 *  \ingroup hardware_spi
 *
 * Get SPI baudrate which was set by \see spi_set_baudrate
 *
 * \param spi SPI instance specifier, either \ref spi0 or \ref spi1
 * \return The actual baudrate set
 *)
function spi_get_baudrate(var spi : TSPI_Registers): longWord; cdecl; external name '__noinline__spi_get_baudrate';

(*! \brief Convert SPI instance to hardware instance number
 *  \ingroup hardware_spi
 *
 * \param spi SPI instance
 * \return Number of SPI, 0 or 1.
 *)
function spi_get_index(var spi : TSPI_Registers) : longWord; cdecl; external name '__noinline__spi_get_index';

function spi_get_hw(var spi : TSPI_Registers) : TSPI_Registers; cdecl; external name '__noinline__spi_get_hw';

function spi_get_const_hw(var spi : TSPI_Registers) : TSPI_Registers; cdecl; external name '__noinline__spi_get_const_hw';

(*
  Configure SPI
  Configure how the SPI serialises and deserialises data on the wire
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
  data_bits Number of data bits per transfer. Valid values 4..16.
  cpol SSPCLKOUT polarity, applicable to Motorola SPI frame format only.
  cpha SSPCLKOUT phase, applicable to Motorola SPI frame format only
  order Must be SPI_MSB_FIRST, no other values supported on the PL022
*)
procedure spi_set_format(var spi : TSPI_Registers; data_bits:TSPI_DataBits; cpol : Tspi_cpol; cpha : Tspi_cpha; order : Tspi_order); cdecl; external name '__noinline__spi_set_format';

(*
  Set SPI master/slave
  Configure the SPI for master- or slave-mode operation. By default,
  spi_init() sets master-mode.
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
  slave true to set SPI device as a slave device, false for master.
*)
procedure spi_set_slave(var spi : TSPI_Registers; slave:boolean); cdecl; external name '__noinline__spi_set_slave';

(*
  Check whether a write can be done on SPI device
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
return
  0 if no space is available to write. Non-zero if a write is possible
note
  Although the controllers each have a 8 deep TX FIFO, the current HW implementation can only return 0 or 1
  rather than the space available.
*)
function spi_is_writable(var spi : TSPI_Registers):longWord; cdecl; external name '__noinline__spi_is_writable';

(*
  Check whether a read can be done on SPI device
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
return
  Non-zero if a read is possible i.e. data is present
note
  Although the controllers each have a 8 deep RX FIFO, the current HW implementation can only return 0 or 1
  rather than the data available.
*)
function spi_is_readable(var spi : TSPI_Registers):longWord; cdecl; external name '__noinline__spi_is_readable';

(*! \brief Check whether SPI is busy
 *  \ingroup hardware_spi
 *
 * \param spi SPI instance specifier, either \ref spi0 or \ref spi1
 * \return true if SPI is busy
 *)
function spi_is_busy(var spi : TSPI_Registers) : boolean; cdecl; external name '__noinline__spi_is_busy';

(*
  Write/Read to/from an SPI device
  Write len bytes from src to SPI. Simultaneously read len bytes from SPI to dst.
  Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
  src Buffer of data to write
  dst Buffer for read data
  len Length of BOTH buffers
return
  Number of bytes written/read
*)
function spi_write_read_blocking(var spi : TSPI_Registers; const src : array of byte; out dst : array of byte;len:longWord):longInt; cdecl; external;

(*
  Write to an SPI device, blocking
  Write len bytes from src to SPI, and discard any data received back
  Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
  src Buffer of data to write
  len Length of src
return
  Number of bytes written/read
*)
function spi_write_blocking(var spi : TSPI_Registers; const src : array of byte;len:longWord):longInt; cdecl; external;

(*
  Read from an SPI device
  Read len bytes from SPI to dst.
  Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
  repeated_tx_data is output repeatedly on TX as data is read in from RX.
  Generally this can be 0, but some devices require a specific value here,
  e.g. SD cards expect 0xff
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
  repeated_tx_data Buffer of data to write
  dst Buffer for read data
  len Length of buffer \p dst
 return
  Number of bytes written/read
*)
function spi_read_blocking(var spi : TSPI_Registers; repeated_tx_data : byte; out dst : array of byte; len:longWord): longInt; cdecl; external;

(*
  Write/Read half words to/from an SPI device
  Write len halfwords from src to SPI. Simultaneously read len halfwords from SPI to dst.
  Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
  src Buffer of data to write
  dst Buffer for read data
  len Length of BOTH buffers in halfwords
return
  Number of halfwords written/read
note
  SPI should be initialised with 16 data_bits using spi_set_format first, otherwise this function will
  only read/write 8 data_bits.
*)
function spi_write16_read16_blocking(var spi : TSPI_Registers; const src : array of word; out dst : array of word;len : longWord): longInt; cdecl; external;

(*
  Write to an SPI device
  Write len halfwords from src to SPI. Discard any data received back.
  Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
  src Buffer of data to write
  len Length of buffers
return
  Number of halfwords written/read
note
  SPI should be initialised with 16 data_bits using \ref spi_set_format first, otherwise this function will
  only write 8 data_bits.
*)
function spi_write16_blocking(var spi : TSPI_Registers; const src : array of word; len:longWord):longInt ; cdecl; external;

(*
  Read from an SPI device
  Read len halfwords from SPI to dst.
  Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
  repeated_tx_data is output repeatedly on TX as data is read in from RX.
  Generally this can be 0, but some devices require a specific value here,
  e.g. SD cards expect 0xff
param
  spi SPI instance specifier, either spi0 or spi1
  repeated_tx_data Buffer of data to write
  dst Buffer for read data
  len Length of buffer dst in halfwords
return
  Number of halfwords written/read
note
  SPI should be initialised with 16 data_bits using spi_set_format first, otherwise this function will
  only read 8 data_bits.
*)
function spi_read16_blocking(var spi : TSPI_Registers; const src : array of word; out dst : array of word;len : longWord):longInt; cdecl; external;

function spi_get_dreq(spi : TSPI_Registers; is_tx : boolean): longWord; cdecl; external name '__noinline__spi_get_dreq';

(*
  Write to an SPI device, blocking
  Write len words from src to SPI starting with hi(word), and discard any data received back
  Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
  src Buffer of data to write
  len Length of src
return
  Number of bytes written/read
*)
function spi_write_blocking_hl(var spi : TSPI_Registers; constref src : array of word; len : longWord):longInt;

(*
  Write to an SPI device, blocking
  Write len words from src to SPI starting with lo(word), and discard any data received back
  Blocks until all data is transferred. No timeout, as SPI hardware always transfers at a known data rate.
param
  spi SPI instance specifier, either \ref spi0 or \ref spi1
  src Buffer of data to write
  len Length of src
return
  Number of bytes written/read
*)
function spi_write_blocking_lh(var spi : TSPI_Registers; constref src : array of word; len : longWord):longInt;

implementation

  // Write len bytes directly from src to the SPI, and discard any data received back
  function spi_write_blocking_hl(var spi : TSPI_Registers; constref src : array of word; len : longWord):longInt;
  var
    i : longWord;
  begin
    // Write to TX FIFO whilst ignoring RX, then clean up afterward. When RX
    // is full, PL022 inhibits RX pushes, and sets a sticky flag on
    // push-on-full, but continues shifting. Safe if SSPIMSC_RORIM is not set.
    for i := 0 to len - 1 do
    begin
      repeat
      until (spi.sr and (1 shl 1)) <> 0;
      spi.dr :=longWord(hi(src[i]));
      repeat
      until (spi.sr and (1 shl 1)) <> 0;
      spi.dr :=longWord(lo(src[i]));
    end;
    // Drain RX FIFO, then wait for shifting to finish (which may be *after*
    // TX FIFO drains), then drain RX FIFO again
    while (spi.sr and (1 shl 2))  <> 0 do
      result := spi.dr;
    repeat
    until (spi.sr and ( 1 shl 4)) = 0;

    while (spi.sr and (1 shl 2))  <> 0 do
      result := spi.dr;

    // Don't leave overrun flag set
    spi.icr := 1 shl 0;

    result := len;
  end;

// Write len bytes directly from src to the SPI, and discard any data received back
function spi_write_blocking_lh(var spi : TSPI_Registers; constref src : array of word; len : longWord):longInt;
var
  i : longWord;
begin
  // Write to TX FIFO whilst ignoring RX, then clean up afterward. When RX
  // is full, PL022 inhibits RX pushes, and sets a sticky flag on
  // push-on-full, but continues shifting. Safe if SSPIMSC_RORIM is not set.
  for i := 0 to len - 1 do
  begin
    repeat
    until (spi.sr and (1 shl 1)) <> 0;
    spi.dr :=longWord(lo(src[i]));
    repeat
    until (spi.sr and (1 shl 1)) <> 0;
    spi.dr :=longWord(hi(src[i]));
  end;
  // Drain RX FIFO, then wait for shifting to finish (which may be *after*
  // TX FIFO drains), then drain RX FIFO again
  while (spi.sr and (1 shl 2))  <> 0 do
    result := spi.dr;
  repeat
  until (spi.sr and ( 1 shl 4)) = 0;

  while (spi.sr and (1 shl 2))  <> 0 do
    result := spi.dr;

  // Don't leave overrun flag set
  spi.icr := 1 shl 0;

  result := len;
end;

begin
end.
