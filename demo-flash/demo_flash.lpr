program demo_flash;

{$mode objfpc}
{$H+}
{$MEMORY 10000,10000}

uses
    pico_flash_c;

var
  i : byte;
  memoryValue : array[0..255] of byte;
  uid : array[0..7] of byte;
  wrdata : array[0..255] of byte;
  rddata : array[0..255] of byte;

const
  offset = 0;

begin
  // Read 256 bytes of flash memory starting at address XIP_BASE
  for i:=0 to 255 do
      memoryValue[i]:=flashMemory.flashContents[i+offset];
  // Read Pico unique identifier
  uid:=flash_get_unique_id;
  // erasing one sector at offset 256k
  flash_range_erase(256*1024,FLASH_SECTOR_SIZE );
  // writing 256 bytes in flash ( FLASH_PAGE_SIZE )
  for i:=0 to 255 do
      wrdata[i]:=255-i;
  flash_range_program(256*1024,wrdata,FLASH_PAGE_SIZE);
  // verify data
  for i:=0 to 255 do
      rddata[i]:=flashMemory.flashContents[i+(256*1024)];
  repeat until 1=0;
end.

