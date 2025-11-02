unit pico_disable_int_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}{$H+}
{$O-}

interface

{$L disable_interrupt.c.obj}

procedure disable_interrupts; cdecl; external;
procedure enable_interrupts;cdecl;external;



implementation
end.


