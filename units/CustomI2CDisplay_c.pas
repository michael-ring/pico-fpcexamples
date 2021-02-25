unit CustomI2CDisplay_c;
{$MODE OBJFPC}
{$modeswitch advancedrecords}
{$H+}
{
  This file is part of Pascal Microcontroller Board Framework (MBF)
  Copyright (c) 2015 -  Michael Ring
  based on Pascal eXtended Library (PXL)
  Copyright (c) 2000 - 2015  Yuriy Kotsarenko

  This program is free software: you can redistribute it and/or modify it under the terms of the FPC modified GNU
  Library General Public License for more

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the FPC modified GNU Library General Public
  License for more details.
}
{$WARN 6058 off : Call to subroutine "$1" marked as inline is not inlined}
interface
uses
  CustomDisplay_c,
  pico_gpio_c,
  pico_timer_c,
  pico_i2c_c,
  pico_c;

type
  TCustomI2CDisplay = object(TCustomDisplay)
  private
      FpI2C : ^TI2C_Inst;
      FDisplayAddress : byte;
  public
    procedure WriteCommand(const command : byte);
    procedure WriteCommand(const command,param1 : byte);
    procedure WriteCommand(const command,param1,param2 : byte);
    procedure WriteCommand(const command,param1,param2,param3 : byte);

    procedure WriteData(var data : array of byte; Count:longInt=-1);
    procedure WriteBuffer(const buffer: pointer; Count : longInt);

    procedure Initialize(var I2C : TI2C_Inst;const aDisplayAddress : byte;const aPinRST : TPinIdentifier;aScreenInfo : TScreenInfo);
    procedure Reset;
  end;

implementation

procedure TCustomI2CDisplay.Initialize(var I2C : TI2C_Inst;const aDisplayAddress : byte;const aPinRST : TPinIdentifier;aScreenInfo : TScreenInfo);
begin
  FpI2C := @I2C;
  FDisplayAddress := aDisplayAddress;
  FPinRST := aPinRST;
  FScreenInfo :=  aScreenInfo;
  FBackgroundColor := clBlack;
  FForegroundColor := clWhite;

  if aPinRST > -1 then
  begin
    gpio_init(aPinRST);
    gpio_set_dir(aPinRST,TGPIODirection.GPIO_OUT);
    gpio_put(aPinRST,true);
  end;
end;

procedure TCustomI2CDisplay.Reset;
begin
  if FPinRST > -1 then
  begin
    gpio_put(FPinRST,true);
    busy_wait_us_32(100000);
    gpio_put(FPinRST,false);
    busy_wait_us_32(100000);
    gpio_put(FPinRST,true);
    busy_wait_us_32(200000);
  end;
end;

procedure TCustomI2CDisplay.WriteCommand(const command: Byte);
var
  data : array[0..1] of byte;
begin
  data[0]:= $80;
  data[1]:= command;
  i2c_write_blocking(FpI2C^,FDisplayAddress,data,2,false);
end;

procedure TCustomI2CDisplay.WriteCommand(const command,param1: Byte);
var
  data : array[0..1] of byte;
begin
  data[0]:= $80;
  data[1]:= command;
  i2c_write_blocking(FpI2C^,FDisplayAddress,data,2,false);
  data[1]:= param1;
  i2c_write_blocking(FpI2C^,FDisplayAddress,data,2,false);
end;

procedure TCustomI2CDisplay.WriteCommand(const command,param1,param2: Byte);
var
  data : array[0..1] of byte;
begin
  data[0]:= $80;
  data[1]:= command;
  i2c_write_blocking(FpI2C^,FDisplayAddress,data,2,false);
  data[1]:= param1;
  i2c_write_blocking(FpI2C^,FDisplayAddress,data,2,false);
  data[1]:= param2;
  i2c_write_blocking(FpI2C^,FDisplayAddress,data,2,false);
end;

procedure TCustomI2CDisplay.WriteCommand(const command,param1,param2,param3: Byte);
var
  data : array[0..1] of byte;
begin
  data[0]:= $80;
  data[1]:= command;
  i2c_write_blocking(FpI2C^,FDisplayAddress,data,2,false);
  data[1]:= param1;
  i2c_write_blocking(FpI2C^,FDisplayAddress,data,2,false);
  data[1]:= param2;
  i2c_write_blocking(FpI2C^,FDisplayAddress,data,2,false);
  data[1]:= param3;
  i2c_write_blocking(FpI2C^,FDisplayAddress,data,2,false);
end;

procedure TCustomI2CDisplay.WriteData(var data: array of byte;Count:longInt=-1);
begin
  if count = -1 then
    count := High(data)+1;
  data[0] := $40;
  i2c_write_blocking(FpI2C^,FDisplayAddress,data,count,false);
end;

procedure TCustomI2CDisplay.WriteBuffer(const buffer: pointer; Count : longInt);
type
  TByteArray = array of byte;
  pByteArray = ^TByteArray;
begin
  pByte(buffer)^ := $40;
  i2c_write_blocking(FpI2C^,FDisplayAddress,pByteArray(buffer)^,Count,false);
end;

end.
