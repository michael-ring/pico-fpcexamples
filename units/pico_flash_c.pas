unit pico_flash_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)
{$mode ObjFPC}
{$H+}

interface
uses
    pico_c;

{$IF DEFINED(DEBUG) or DEFINED(DEBUG_IRQ)}
{$L flash.c-debug.obj}
{$ELSE}
{$L flash.c.obj}
{$ENDIF}

type
  TFlashMemory = record
  flashContents : array[0..255] of byte;
  end;

  TFlashUID = array[0..7] of byte;

const
  XIP_BASE      = $10000000;
  FLASH_SECTOR_SIZE = 4096;
  FLASH_PAGE_SIZE = 256;

var
  flashMemory : TFlashMemory absolute XIP_BASE;

// erase one or more sector in flash
// flash_offs is the position in the flash aligned to a 4096 byte flash sector
// count is a multiple of FLASH_SECTOR_SIZE
procedure flash_range_erase(flash_offs:uint32;count:uint32 );cdecl;external;

// program one or more sector in flash
// flash_offs is the position in the flash aligned to a 4096 byte flash sector
// data point on data to be written
// count is a multiple of FLASH_PAGE_SIZE
procedure flash_range_program(flash_offs:uint32;data:array of uint8;count:uint32);cdecl;external;

procedure flash_do_cmd(txbuff : array of byte;rxbuff : array of byte;size : uint32);cdecl;external;

// get the unique identifier of the flash memory
function flash_get_unique_id:TFlashUID;cdecl;

implementation

function flash_get_unique_id:TFlashUID;cdecl;
const
  FLASH_RUID_CMD = $4b;
  FLASH_RUID_DUMMY_BYTES = 4;
  FLASH_RUID_DATA_BYTES = 8;
  FLASH_RUID_TOTAL_BYTES = 13;
var
  txbuf : array[0..12] of byte;
  rxbuf : array[0..12] of byte;
  i : byte;
begin
  txbuf[0]:=FLASH_RUID_CMD;
  flash_do_cmd(txbuf,rxbuf,FLASH_RUID_TOTAL_BYTES);
  for i:=0 to 7 do
      flash_get_unique_id[i]:=rxbuf[i+5];
end;

end.

