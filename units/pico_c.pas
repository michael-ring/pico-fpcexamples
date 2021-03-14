unit pico_c;
{$mode objfpc}{$H+}
{$IF DEFINED(DEBUG) or DEFINED(DEBUG_CORE)}
{$L platform.c-debug.obj}
{$L clocks.c-debug.obj}
{$L xosc.c-debug.obj}
{$L pll.c-debug.obj}
{$L watchdog.c-debug.obj}
{$L irq.c-debug.obj}
{$ELSE}
{$L platform.c.obj}
{$L clocks.c.obj}
{$L xosc.c.obj}
{$L pll.c.obj}
{$L watchdog.c.obj}
{$L irq.c.obj}
{$ENDIF}
{$LinkLib gcc-armv6m,static}

interface
uses
  heapmgr;

type 
  TByteArray = array of Byte;
  TColor = -$7FFFFFFF-1..$7FFFFFFF;

TPoint2px = record
  X:word;
  Y:Word;
end;

const
  clBlack   = TColor($000000);
  clMaroon  = TColor($000080);
  clGreen   = TColor($008000);
  clOlive   = TColor($008080);
  clNavy    = TColor($800000);
  clPurple  = TColor($800080);
  clTeal    = TColor($808000);
  clGray    = TColor($808080);
  clSilver  = TColor($C0C0C0);
  clRed     = TColor($0000FF);
  clLime    = TColor($00FF00);
  clYellow  = TColor($00FFFF);
  clBlue    = TColor($FF0000);
  clFuchsia = TColor($FF00FF);
  clAqua    = TColor($FFFF00);
  clLtGray  = TColor($C0C0C0);
  clDkGray  = TColor($808080);
  clWhite   = TColor($FFFFFF);

(*
  Structure containing date and time information
  When setting an RTC alarm, set a field to -1 tells</b>
  the RTC to not match on this field
*)
type Tdatetime = record
  year:word;    //< 0..4095
  month: 1..12;    //< 1..12, 1 is January
  day: 1..31;      //< 1..28,29,30,31 depending on month
  dotw: 0..6;     //< 0..6, 0 is Sunday
  hour: 0..23;     //< 0..23
  min: 0..59;      //< 0..59
  sec: 0..59;      //< 0..59
end;

type
  Tabsolute_time = record
    _private_us_since_boot : int64;
  end;


procedure clocks_init; cdecl; external;
procedure runtime_init;
procedure hard_assertion_failure; public name 'hard_assertion_failure';
procedure __unhandled_user_irq; public name '__unhandled_user_irq';
procedure __assert_func; public name '__assert_func';

(*
  convert an absolute_time_t into a number of microseconds since boot.
param:
  t the number of microseconds since boot
return:
  return an absolute_time_t value equivalent to t
*)
function to_us_since_boot(t :  Tabsolute_time):int64;

(*
  update an absolute_time_t value to represent a given number of microseconds since boot
param:
  t the absolute time value to update
  us_since_boot the number of microseconds since boot to represent
*)
procedure update_us_since_boot(var t : Tabsolute_time; us_since_boot:int64);

(*
  Atomically set the specified bits to 1 in a HW register
param:
  addr Address of writable register
  mask Bit-mask specifying bits to set
*)
procedure hw_set_bits(var register : longWord; mask : longWord);

(*
  Atomically clear the specified bits to 0 in a HW register
param:
  addr Address of writable register
  mask Bit-mask specifying bits to clear
*)
procedure hw_clear_bits(var register : longWord;mask:longWord);

(*
  Atomically flip the specified bits in a HW register
param:
  addr Address of writable register
  mask Bit-mask specifying bits to invert
*)
procedure hw_xor_bits(var register : longWord;mask:longWord);

(*
  Set new values for a sub-set of the bits in a HW register
  Note: this method allows safe concurrent modification of *different* bits of
  a register, but multiple concurrent access to the same bits is still unsafe.
param:
  addr Address of writable register
  values Bits values
  write_mask Mask of bits to change
*)
procedure hw_write_masked(var register : longWord; values : longWord; write_mask:longWord);

implementation
procedure hard_assertion_failure;
begin
end;

procedure __unhandled_user_irq;
begin
end;

procedure __assert_func;
begin
end;

function to_us_since_boot(t : Tabsolute_time):int64;
begin
  result := t._private_us_since_boot;
end;

procedure update_us_since_boot(var t : Tabsolute_time; us_since_boot:int64);
begin
  t._private_us_since_boot := us_since_boot;
end;

procedure runtime_init;
const
  RESETS_SAFE_BITS=     %1111111111100110110111111;
  RESETS_PRECLOCK_BITS= %0001111000100110110111110;
  RESETS_POSTCLOCK_BITS=%1110000111000000000000001;
begin
  hw_set_bits(resets.reset,RESETS_SAFE_BITS);
  hw_clear_bits(resets.reset,RESETS_PRECLOCK_BITS);
  repeat
  until (resets.reset_done and RESETS_PRECLOCK_BITS) = RESETS_PRECLOCK_BITS;
  clocks_init;
  hw_clear_bits(resets.reset,RESETS_POSTCLOCK_BITS);
  repeat
  until (resets.reset_done and RESETS_POSTCLOCK_BITS) = RESETS_POSTCLOCK_BITS;
end;

procedure hw_set_bits(var Register : longWord; mask:longWord);
begin
  pLongWord(pointer(@Register)+$2000)^ := mask;
end;

procedure hw_clear_bits(var Register : longWord; mask:longWord);
begin
  pLongWord(pointer(@Register) + $3000)^ := mask;
end;

procedure hw_xor_bits(var Register : longWord; mask:longWord);
begin
  pLongWord(pointer(@Register) + $1000)^ := mask;
end;

procedure hw_write_masked(var Register : longWord; values : longWord; write_mask:longWord);
begin
  Register := (Register and not write_mask) or values;
end;

begin
  runtime_init;
end.

