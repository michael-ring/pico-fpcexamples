unit CustomSPIDisplay_c;
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
  customdisplay_c,
  pico_gpio_c,
  pico_timer_c,
  pico_spi_c,
  pico_c;

type
  TCustomSPIDisplay = object(TCustomDisplay)
  private
      FpSPI : ^TSPI_Registers;
  public
    procedure BeginTransaction;
    procedure EndTransaction;
    procedure WriteCommand(const command : byte);
    procedure WriteCommand(const command,param1 : byte);
    procedure WriteCommand(const command,param1,param2 : byte);
    procedure WriteCommand(const command,param1,param2,param3 : byte);

    procedure WriteData(var data : array of byte; Count:longInt=-1);
    procedure WriteBuffer(const buffer: pointer; Count : longInt);

    procedure Initialize(var SPI : TSpi_Registers;const aPinDC : TPinIdentifier;const aPinRST : TPinIdentifier;aScreenInfo : TScreenInfo);
    procedure Reset;
  end;

implementation

procedure TCustomSPIDisplay.Initialize(var SPI : TSpi_Registers;const aPinDC : TPinIdentifier;const aPinRST : TPinIdentifier;aScreenInfo : TScreenInfo);
begin
  FpSPI := @SPI;
  FPinDC := aPinDC;
  FPinRST := aPinRST;
  FScreenInfo :=  aScreenInfo;
  FBackgroundColor := clBlack;
  FForegroundColor := clWhite;

  if APinDC > -1 then
  begin
    gpio_init(APinDC);
    gpio_set_dir(APinDC,TGPIODirection.GPIO_OUT);
    gpio_put(APinDC,true);
  end;
  if APinRST > -1 then
  begin
    gpio_init(APinRST);
    gpio_set_dir(APinRST,TGPIODirection.GPIO_OUT);
    gpio_put(APinRST,true);
  end;
end;

procedure TCustomSPIDisplay.Reset;
begin
  if FPinDC > -1 then
    gpio_put(FPinDC,true);
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

procedure TCustomSPIDisplay.BeginTransaction;
begin
  //FpSPI^.BeginTransaction;
end;

procedure TCustomSPIDisplay.EndTransaction;
begin
  //FpSPI^.EndTransaction;
end;

procedure TCustomSPIDisplay.WriteCommand(const command: Byte);
var
  data: array[0..0] of byte;
begin
  data[0] := command;
  gpio_put(FPinDC,false);
  spi_write_blocking(FpSPI^,data,1);
end;

procedure TCustomSPIDisplay.WriteCommand(const command,param1: Byte);
var
  data : array[0..1] of byte;
begin
  data[0]:= command;
  data[1]:= param1;
  spi_write_blocking(FpSPI^,data,2);
end;

procedure TCustomSPIDisplay.WriteCommand(const command,param1,param2: Byte);
var
  data : array[0..2] of byte;
begin
  data[0]:= command;
  data[1]:= param1;
  data[2]:= param2;
  spi_write_blocking(FpSPI^,data,3);
end;

procedure TCustomSPIDisplay.WriteCommand(const command,param1,param2,param3: Byte);
var
  data : array[0..3] of byte;
begin
  data[0]:= command;
  data[1]:= param1;
  data[2]:= param2;
  data[3]:= param3;
  spi_write_blocking(FpSPI^,data,4);
end;

procedure TCustomSPIDisplay.WriteData(var data: array of byte;Count:longInt=-1);
begin
  if count = -1 then
    count := High(data)+1;
  spi_write_blocking(FpSPI^,data,count);
end;

procedure TCustomSPIDisplay.WriteBuffer(const buffer: pointer; Count : longInt);
type
  TByteArray = array of byte;
  pByteArray = ^TByteArray;
begin
  spi_write_blocking(FpSPI^,pByteArray(buffer)^,Count);
end;

end.
