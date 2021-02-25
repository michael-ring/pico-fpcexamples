unit pico_i2c_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}{$H+}
interface
uses
  pico_time_c,
  pico_c;

{$IF DEFINED(DEBUG) or DEFINED(DEBUG_I2C)}
{$L i2c.c-debug.obj}
{$ELSE}
{$L i2c.c.obj}
{$ENDIF}

type Ti2c_inst = record
  hw : ^TI2C_Registers;
  restart_on_next : boolean;
end;

function i2c_init(var i2c : TI2C_Inst;baudrate:longWord):longWord; cdecl; external;
procedure i2c_deinit(var i2c : TI2C_Inst); cdecl; external;
function i2c_set_baudrate(var i2c : TI2C_Inst; baudrate:longWord):longWord; cdecl; external;
procedure i2c_set_slave_mode(var i2c : TI2C_Inst; slave:boolean; addr:byte); cdecl ; external;
function i2c_write_blocking_until(var i2c : TI2C_Inst; addr : byte; const src : array of byte; len : word; nostop:boolean; &until : Tabsolute_time):longInt; cdecl; external;
function i2c_read_blocking_until(var i2c : TI2C_Inst; addr : byte; out dst : array of byte; len: word; nostop : boolean; &until : Tabsolute_time):longInt; cdecl; external;
function i2c_write_timeout_us(var i2c : TI2C_Inst; addr : byte; const src : array of byte; len : word; nostop : boolean; timeout_us:longWord):longInt;
function i2c_write_timeout_per_char_us(var i2c : TI2C_Inst; addr : byte ;  src : array of byte; len : word; nostop : boolean; timeout_per_char_us : longWord):longInt; cdecl; external;
function i2c_read_timeout_us(var i2c : TI2C_Inst; addr : byte; out dst : array of byte; len : word; nostop : boolean; timeout_us : longWord):longInt;
function i2c_read_timeout_per_char_us(var i2c : TI2C_Inst; addr : byte; out dst : array of byte; len : word; nostop : boolean; timeout_per_char_us: longWord):longInt; cdecl; external;
function i2c_write_blocking(var i2c : TI2C_Inst; addr : byte;const src : array of byte;len : word ;nostop : boolean):longInt; cdecl; external;
function i2c_read_blocking(var i2c : TI2C_Inst; addr : byte; out dst : array of byte; len : word; nostop:boolean):longInt; cdecl; external;
function i2c_get_write_available(var i2c : TI2C_Inst): longWord;
function i2c_get_read_available(var i2c : TI2C_Inst):longWord;
procedure i2c_write_raw_blocking(var i2c : TI2C_Inst; src : array of byte; len : word);
procedure i2c_read_raw_blocking(var i2c : TI2C_Inst; out dst : array of byte; len:word);

var
  I2C0Inst,
  I2C1Inst : TI2C_Inst;

implementation

function i2c_write_timeout_us(var i2c : TI2C_Inst; addr : byte; const src : array of byte; len : word; nostop : boolean; timeout_us:longWord):longInt;
begin
  result := i2c_write_blocking_until(i2c, addr, src, len, nostop, make_timeout_time_us(timeout_us));
end;

function i2c_read_timeout_us(var i2c : TI2C_Inst; addr : byte; out dst : array of byte; len : word; nostop : boolean; timeout_us : longWord):longInt;
begin
  result := i2c_read_blocking_until(i2c,addr,dst,len,nostop,make_timeout_time_us(timeout_us));
end;

function i2c_get_write_available(var i2c : TI2C_Inst): longWord;
const
  IC_TX_BUFFER_DEPTH = 32;
begin
  result := IC_TX_BUFFER_DEPTH - i2c.hw^.txflr;
end;

function i2c_get_read_available(var i2c : TI2C_Inst):longWord;
begin
  result := i2c.hw^.rxflr;
end;

procedure i2c_write_raw_blocking(var i2c : TI2C_Inst; src : array of byte; len : word);
var
  i : longWord;
begin
  for i := 0 to len-1 do
  begin
    repeat
    until i2c_get_write_available(i2c) > 0;
    i2c.hw^.data_cmd := src[i];
  end;
end;

procedure i2c_read_raw_blocking(var i2c : TI2C_Inst; out dst : array of byte; len:word);
var
  i : longWord;
begin
  for i := 0 to len-1 do
  begin
    repeat
    until i2c_get_read_available(i2c) > 0;
    dst[i] := i2c.hw^.data_cmd;
  end;
end;

begin
  I2C0Inst.hw := @I2C0;
  I2C0Inst.restart_on_next := False;
  I2C1Inst.hw := @I2C1;
  I2C1Inst.restart_on_next := False;
end.
