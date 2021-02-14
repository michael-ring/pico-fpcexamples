unit pico_i2c_c;
(*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *)

{$mode objfpc}{$H+}
interface
uses
  pico_c;

{$L i2c.c.obj}

type Ti2c_inst = record
  hw : TI2C_Registers;
  restart_on_next : boolean;
end;

function i2c_init(var i2c : TI2C_Registers;baudrate:longWord):longWord; external;
procedure i2c_deinit(var i2c : TI2C_Registers); external;
function i2c_set_baudrate(var i2c : TI2C_Registers; baudrate:longWord):longWord; external;
procedure i2c_set_slave_mode(var i2c : TI2C_Registers; slave:boolean; addr:byte); external;

function i2c_hw_index(var i2c : TI2C_Registers):longWord;
begin
  invalid_params_if(I2C, i2c != (&i2c0_inst) && i2c != (&i2c1_inst));
  return i2c == (&i2c1_inst) ? 1 : 0;
end;

function i2c_write_blocking_until(var i2c : TI2C_Registers; addr : byte; src : TByteArray; len : word; nostop:boolean; until : Tabsolute_time):longInt; external;
function i2c_read_blocking_until(var i2c : TI2C_Registers; addr : byte; var dst : TByteArray; len: word; nostop : boolean; until : Tabsolute_time):longInt; external;
function i2c_write_timeout_us(var i2c : TI2C_Registers, addr : byte; src : TByteArray; len : word; nostop : boolean; timeout_us:longWord):longInt;
begin
  result := i2c_write_blocking_until(i2c, addr, src, len, nostop, make_timeout_time_us(timeout_us));
end;

function i2c_write_timeout_per_char_us(var i2c : TI2C_Registers; addr : byte ;  src : TByteArray; len : word; nostop : boolean; timeout_per_char_us : longWord;):longInt; external;
function i2c_read_timeout_us(var i2c : TI2C_Registers; addr : byte; var dst : TByteArray; len : word; nostop : boolean; timeout_us : longWord):longInt;
begin
  result := i2c_read_blocking_until(i2c,addr,dst,len,nostop,make_timeout_time_us(timeout_us));
end;

function i2c_read_timeout_per_char_us(var i2c : TI2C_Registers; addr : byte; var dst : TByteArray; len : word; nostop : boolean; timeout_per_char_us: longWord):longInt; external;
function i2c_write_blocking(var i2c : TI2C_Registers; addr : byte;src : TByteArray;len : word ;nostop : boolean):longInt; external;
function i2c_read_blocking(var i2c : TI2C_Registers; addr : byte; var dst : TBytearray; len . word; nostop:boolean):longInt; external;
function i2c_get_write_available(var i2c : TI2C_Registers): longWord;
const
  IC_TX_BUFFER_DEPTH = 32;
begin
  result := IC_TX_BUFFER_DEPTH - i2c.txflr;
end;

function i2c_get_read_available(var i2c : TI2C_Registers):longWord;
begin 
  result := i2c.rxflr;
end;

procedure i2c_write_raw_blocking(var i2c : TI2C_Registers, src : TByteArray; len : word);
var
  i : longWord;
begin
  for i := 0 to len-1 do
  begin
    repeat
    until i2c_get_write_available(i2c);
    i2c.data_cmd := src[i];
  end;
end;

procedure i2c_read_raw_blocking(var i2c : TI2C_Registers; var dst : TByteArray; len:word);
begin
  for i := 0 to len-1 do
  begin
    repeat
    until i2c_get_read_available(i2c);
    dst[i] := i2c.data_cmd;
  end;
end;

implementation

end.
