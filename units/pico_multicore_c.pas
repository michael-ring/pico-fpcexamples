unit pico_multicore_c;
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
{$L multicore.c-debug.obj}
{$ELSE}
{$L multicore.c.obj         }
{$L mutex.c.obj             }
{$L lock_core.c.obj         }
{$L pheap.c.obj             }
{$L time.c.obj              }
{$ENDIF}

// Reset core 1 to its initial state
procedure multicore_reset_core1;cdecl;external;

// Run code on core 1
// Wake up core 1 and enter the given function with default stack
procedure multicore_launch_core1(entry:pointer);cdecl;external;

// Run code on core 1
// Wake up core 1 and enter the given function with defined stack and with stack protection
procedure multicore_launch_core1_with_stack(entry:pointer;stack_bottom:pointer;stack_size_bytes:uint32);cdecl;external;

// Run code on core 1
// Wake up core 1 and enter the given function with defined stack and without stack protection
procedure multicore_launch_core1_raw(entry:pointer;stack_bottom:pointer;stack_size_bytes:uint32);cdecl;external;

// Request the other core to pause in a known state and wait for it to do so
procedure multicore_lockout_start_blocking;cdecl;external;

// Release the other core from a locked out state amd wait for it to acknowledge
procedure multicore_lockout_end_blocking;cdecl;external;

function multicore_lockout_start_timeout_us(timeout:uint64):uint32;cdecl;external;

function multicore_lockout_end_timeout_us(timeout:uint64):boolean;cdecl;external;


implementation


end.

