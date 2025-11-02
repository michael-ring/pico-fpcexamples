unit pico_irq_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}
{$H+}
{$L irq_handler_chain.S.obj}

interface

{$IF DEFINED(DEBUG) or DEFINED(DEBUG_IRQ)}
{$L irq.c-debug.obj}
{$ELSE}
{$L irq.c.obj}
{$ENDIF}

procedure irq_set_enabled(irq_number:TIRQn_Enum);cdecl;external;
procedure irq_set_enabled(irq_number:TIRQn_Enum;enable:boolean);cdecl;external;
function irq_is_enabled(irq_number:TIRQn_Enum):boolean;cdecl;external;
procedure irq_set_mask_enabled(mask:uint32;enable:boolean);cdecl;external;
procedure irq_set_priority(irq_number:TIRQn_Enum;priotiry:uint8);cdecl;external;
procedure irq_handler_chain_slots;cdecl;external;
procedure irq_handler_chain_first_slot;cdecl;external;
	
implementation

end.	
