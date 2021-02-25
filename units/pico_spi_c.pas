unit pico_spi_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}{$H+}
interface
uses
  pico_c;

{$IF DEFINED(DEBUG) or DEFINED(DEBUG_SPI)}
{$L spi.c-debug.obj}
{$ELSE}
{$L spi.c.obj}
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
    SPI_DATABITS_FOUR=3,
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

procedure spi_init(var spi : TSPI_Registers; baudrate:longWord); cdecl; external;
procedure spi_deinit(var spi : TSPI_Registers); cdecl; external;
function spi_set_baudrate(var spi : TSPI_Registers; baudrate:longWord):longWord; cdecl; external;
procedure spi_set_format(var spi : TSPI_Registers; data_bits:TSPI_DataBits; cpol : Tspi_cpol; cpha : Tspi_cpha; order : Tspi_order);
procedure spi_set_slave(var spi : TSPI_Registers; slave:boolean);
function spi_is_writable(var spi : TSPI_Registers):longWord;
function spi_is_readable(var spi : TSPI_Registers):longWord;
function spi_write_read_blocking(var spi : TSPI_Registers; var src : array of byte; var dst : array of byte;len:longWord):longInt; cdecl; external;
function spi_write_blocking(var spi : TSPI_Registers; var src : array of byte;len:longWord):longInt; cdecl; external;
function spi_read_blocking(var spi : TSPI_Registers; repeated_tx_data : byte; var dst : array of byte; len:longWord): longInt; cdecl; external;
function spi_write16_read16_blocking(var spi : TSPI_Registers; var src : array of word; var dst : array of word;len : longWord): longInt; cdecl; external;
function spi_write16_blocking(var spi : TSPI_Registers; var src : array of word; len:longWord):longInt ; cdecl; external;
function spi_read16_blocking(var spi : TSPI_Registers; var src : array of word; var dst : array of word;len : longWord):longInt; cdecl; external;

implementation

procedure spi_set_format(var spi : TSPI_Registers; data_bits:TSPI_DataBits; cpol : Tspi_cpol; cpha : Tspi_cpha; order : Tspi_order);
begin
  //invalid_params_if(SPI, data_bits < 4 || data_bits > 16);
  //invalid_params_if(SPI, order != SPI_MSB_FIRST);
  //invalid_params_if(SPI, cpol != SPI_CPOL_0 && cpol != SPI_CPOL_1);
  //invalid_params_if(SPI, cpha != SPI_CPHA_0 && cpha != SPI_CPHA_1);
  hw_write_masked(spi.cr0,
        longWord(data_bits) shl 0 + longWord(cpol) shl 6 + longWord(cpha) shl 7,
        %1111 shl 0 + 1 shl 6 + 1 shl 7);
end;

procedure spi_set_slave(var spi : TSPI_Registers; slave:boolean);
begin
  if slave = true then
    hw_set_bits(spi.cr1, 1 shl 2)
  else
    hw_clear_bits(spi.cr1, 1 shl 2);
end;

function spi_is_writable(var spi : TSPI_Registers):longWord;
begin
  result := (spi.sr and $00000002) shr 1;
end;

function spi_is_readable(var spi : TSPI_Registers):longWord;
begin
  result := (spi.sr and $00000004) shr 2;
end;

end.
