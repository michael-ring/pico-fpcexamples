unit pico_sync_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}{$H+}
{$O-}

interface

//{$IF DEFINED(DEBUG) or DEFINED(DEBUG_PIO)}
//{$L sync.c-debug.obj}
//{$ELSE}
{$L sync.c.obj}
//{$ENDIF}

type
  Tspin_lock = longWord;

(*
  Release all spin locks
 *)
procedure spin_locks_reset; cdecl; external;

(*
  Initialise a spin lock The spin lock is initially unlocked
param
  lock_num The spin lock number
return
  The spin lock instance
 *)

function spin_lock_init(lock_num : longWord): Tspin_lock; cdecl; external;
(*
  Return a spin lock number from the _striped_ range
  Returns a spin lock number in the range PICO_SPINLOCK_ID_STRIPED_FIRST to PICO_SPINLOCK_ID_STRIPED_LAST
  in a round robin fashion. This does not grant the caller exclusive access to the spin lock, so the caller
  must:

  -# Abide (with other callers) by the contract of only holding this spin lock briefly (and with IRQs disabled - the default via \ref spin_lock_blocking()),
  and not whilst holding other spin locks.
  -# Be OK with any contention caused by the - brief due to the above requirement - contention with other possible users of the spin lock.
return
  lock_num a spin lock number the caller may use (non exclusively)
 *)
function next_striped_spin_lock_num(): longWord ; cdecl; external;
(*
  Mark a spin lock as used
  Method for cooperative claiming of hardware. Will cause a panic if the spin lock
  is already claimed. Use of this method by libraries detects accidental
  configurations that would fail in unpredictable ways.
param
  lock_num the spin lock number
*)
procedure spin_lock_claim(lock_num : longWord); cdecl; external;

(*
  Mark multiple spin locks as used
  Method for cooperative claiming of hardware. Will cause a panic if any of the spin locks
  are already claimed. Use of this method by libraries detects accidental
  configurations that would fail in unpredictable ways.
param
  lock_num_mask Bitfield of all required spin locks to claim (bit 0 == spin lock 0, bit 1 == spin lock 1 etc)
*)
procedure spin_lock_claim_mask(mask : longWord); cdecl; external;

(*
  Mark a spin lock as no longer used
  Method for cooperative claiming of hardware.
param
  lock_num the spin lock number to release
*)
procedure spin_lock_unclaim(lock_num : longWord); cdecl; external;

(*
  Claim a free spin lock
param
  required if true the function will panic if none are available
return
  the spin lock number or -1 if required was false, and none were free
*)
function spin_lock_claim_unused(required : boolean):longInt; cdecl; external;

(*
  Determine if a spin lock is claimed
param
  lock_num the spin lock number
return
  true if claimed, false otherwise
*)
function spin_lock_is_claimed(lock_num : longWord):boolean; cdecl; external;


implementation
end.


