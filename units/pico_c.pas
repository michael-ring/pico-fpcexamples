unit pico_c;
{$mode objfpc}{$H+}
{$L platform.c.obj}
{$L clocks.c.obj}
{$L xosc.c.obj}
{$L pll.c.obj}
{$L watchdog.c.obj}
{$L irq.c.obj}
{$LinkLib gcc,static}

interface
uses
  heapmgr;

type 
  TByteArray = array [0..32767] of Byte;

(** \struct datetime_t
 *  \ingroup util_datetime
 *  \brief Structure containing date and time information
 *
 *    When setting an RTC alarm, set a field to -1 tells
 *    the RTC to not match on this field
 *)
type Tdatetime = record
  year:word;    ///< 0..4095
  month: 1..12;    ///< 1..12, 1 is January
  day: 1..31;      ///< 1..28,29,30,31 depending on month
  dotw: 0..6;     ///< 0..6, 0 is Sunday
  hour: 0..23;     ///< 0..23
  min: 0..59;      ///< 0..59
  sec: 0..59;      ///< 0..59
end;

type
  Tabsolute_time = record
    _private_us_since_boot : int64;
  end;


procedure clocks_init; external;
procedure runtime_init;
procedure hard_assertion_failure; public name 'hard_assertion_failure';
procedure __unhandled_user_irq; public name '__unhandled_user_irq';

(*! fn to_us_since_boot
 * \brief convert an absolute_time_t into a number of microseconds since boot.
 * \param t the number of microseconds since boot
 * \return an absolute_time_t value equivalent to t
 *)
function to_us_since_boot(t :  Tabsolute_time):int64;

(*! fn update_us_since_boot
 * \brief update an absolute_time_t value to represent a given number of microseconds since boot
 * \param t the absolute time value to update
 * \param us_since_boot the number of microseconds since boot to represent
 *)
procedure update_us_since_boot(var t : Tabsolute_time; us_since_boot:int64);

(*! \brief Atomically set the specified bits to 1 in a HW register
 *  \ingroup hardware_base
 *
 * \param addr Address of writable register
 * \param mask Bit-mask specifying bits to set
 *)
procedure hw_set_bits(var register : longWord; mask : longWord);

(*! \brief Atomically clear the specified bits to 0 in a HW register
 *  \ingroup hardware_base
 *
 * \param addr Address of writable register
 * \param mask Bit-mask specifying bits to clear
 *)
procedure hw_clear_bits(var register : longWord;mask:longWord);

(*! \brief Atomically flip the specified bits in a HW register
 *  \ingroup hardware_base
 *
 * \param addr Address of writable register
 * \param mask Bit-mask specifying bits to invert
 *)
procedure hw_xor_bits(var register : longWord;mask:longWord);

(*! \brief Set new values for a sub-set of the bits in a HW register
 *  \ingroup hardware_base
 *
 * Sets destination bits to values specified in \p values, if and only if corresponding bit in \p write_mask is set
 *
 * Note: this method allows safe concurrent modification of *different* bits of
 * a register, but multiple concurrent access to the same bits is still unsafe.
 *
 * \param addr Address of writable register
 * \param values Bits values
 * \param write_mask Mask of bits to change
 *)
procedure hw_write_masked(var register : longWord; values : longWord; write_mask:longWord);

implementation
procedure hard_assertion_failure;
begin
end;

procedure __unhandled_user_irq;
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
//var
//  ptr : pLongWord;
//  offset : longWord;
begin
//  offset := $2000;
//  ptr := pLongWord(pointer(@Register) + offset);
//  ptr^ := mask;
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
var
  temp : longWord;
begin
  Register := (Register and not write_mask) or values;
end;


begin
  runtime_init;
end.

