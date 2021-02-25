unit CustomDisplay_c;
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
  pico_gpio_c,
  pico_i2c_c,
  pico_c;
type
  TDisplayBitDepth = (OneBit=1,TwoBits=2,SixteenBits=16);

  TFontData = array [0..MaxInt-1] of byte;
  TRowBuffer = array [0..MaxInt-1] of byte;
  TFontInfo = record
    Width,Height : Word;
    BitsPerPixel : byte;
    BytesPerChar : Word;
    Charmap : String;
    pFontData : ^TFontData;
    pRowBuffer : ^TRowBuffer;
  end;

  TScreenInfo = record
    { The coordinate in 2D space. }
    Width, Height: Word;
    Depth : TDisplayBitDepth;
    class operator =(a,b : TScreenInfo) : boolean;
  end;

type TCustomDisplay = object
  protected
    FScreenInfo : TScreenInfo;
    FPinCS : TPinIdentifier;
    FPinDC : TPinIdentifier;
    FPinRST : TPinIdentifier;
    FForegroundColor : TColor;
    FBackgroundColor : TColor;
    FNativeForegroundColor : longWord;
    FNativeBackgroundColor : longWord;
    procedure setPinDC(const PinIdentifier : TPinIdentifier);
    procedure setPinRST(const PinIdentifier : TPinIdentifier);
    procedure setScreenInfo(const ScreenInfo : TScreenInfo);
    procedure CalculateAntialiasColors(out AntiAliasColors : array of word);
    procedure setForegroundColor(const ForegroundColor : TColor);
    procedure setBackgroundColor(const BackgroundColor : TColor);
  public
    property ForegroundColor: TColor read FForegroundColor write setForegroundColor;
    property BackgroundColor : TColor read FBackgroundColor write setBackgroundColor;
    property PinRST : TPinIdentifier read FPinRST write setPinRST;
    property PinDC : TPinIdentifier read FPinDC write setPinDC;
    property ScreenInfo : TScreenInfo read FScreenInfo write setScreenInfo;
end;

implementation

class operator TScreenInfo.= (a,b : TScreenInfo) : boolean;
begin
  Result := (a.Width = b.Width) and (a.Height = b.Height) and (a.Depth = b.Depth);
end;

procedure TCustomDisplay.setPinRST(const PinIdentifier : TPinIdentifier);
begin
  FPinRST := PinIdentifier;
end;

procedure TCustomDisplay.setPinDC(const PinIdentifier : TPinIdentifier);
begin
  FPinDC := PinIdentifier;
end;

procedure TCustomDisplay.setScreenInfo(const ScreenInfo : TScreenInfo);
begin
  FScreenInfo := ScreenInfo;
end;

procedure TCustomDisplay.setForegroundColor(const ForegroundColor : TColor);
begin
  FForegroundColor := ForegroundColor;
  if FScreenInfo.Depth = TDisplayBitDepth.SixteenBits then
    FNativeForegroundColor := ((ForegroundColor shr 19) and %11111) or ((ForegroundColor shr 5) and %11111100000)  or ((ForegroundColor shl 8) and %1111100000000000)
  else if FScreenInfo.Depth = TDisplayBitDepth.OneBit then
    if ForegroundColor = 0 then
      FNativeForegroundColor := 0
    else
      FNativeForegroundColor := $ff;
end;

procedure TCustomDisplay.setBackgroundColor(const BackgroundColor : TColor);
begin
  FBackgroundColor := BackgroundColor;
  if FScreenInfo.Depth = TDisplayBitDepth.SixteenBits then
    FNativeBackgroundColor := ((BackgroundColor shr 19) and %11111) or ((BackgroundColor shr 5) and %11111100000)  or ((BackgroundColor shl 8) and %1111100000000000)
  else if FScreenInfo.Depth = TDisplayBitDepth.OneBit then
    if BackgroundColor = 0 then
      FNativeBackgroundColor := 0
    else
      FNativeBackgroundColor := $ff;
end;

procedure TCustomDisplay.CalculateAntialiasColors(out AntiAliasColors : array of word);
begin
  AntiAliasColors[%00] := ((BackgroundColor shr 19) and %11111) or ((BackgroundColor shr 5) and %11111100000)  or ((BackgroundColor shl 8) and %1111100000000000);
  AntiAliasColors[%11] := ((ForegroundColor shr 19) and %11111) or ((ForegroundColor shr 5) and %11111100000)  or ((ForegroundColor shl 8) and %1111100000000000);

  //Set some simple defaults (effectively kills antialiasing)
  AntiAliasColors[%01] := AntiAliasColors[%00];
  AntiAliasColors[%10] := AntiAliasColors[%11];

  case BackgroundColor of
    clWhite:
      case ForeGroundColor of
        clBlack : begin
                    AntiAliasColors[%01] := 20 + 42 shl 5 + 20 shl 11;
                    AntiAliasColors[%10] := 10 + 21 shl 5 + 10 shl 11;
                  end;
        clBlue : begin
                    AntiAliasColors[%01] := 31 + 40 shl 5 + 20 shl 11;
                    AntiAliasColors[%10] := 31 + 20 shl 5 + 10 shl 11;
                  end;
        clLime : begin
                    AntiAliasColors[%01] := 20 + 63 shl 5 + 20 shl 11;
                    AntiAliasColors[%10] := 10 + 63 shl 5 + 10 shl 11;
                  end;
        clGreen : begin
                    AntiAliasColors[%01] := 20 + 63 shl 5 + 20 shl 11;
                    AntiAliasColors[%10] := 10 + 47 shl 5 + 10 shl 11;
                  end;
        clRed : begin
                    AntiAliasColors[%01] := 20 + 40 shl 5 + 31 shl 11;
                    AntiAliasColors[%10] := 10 + 20 shl 5 + 31 shl 11;
                  end;
      end;

    clBlack: begin
      case ForeGroundColor of
        clWhite : begin
                    AntiAliasColors[%01] := 10 + 21 shl 5 + 10 shl 11;
                    AntiAliasColors[%10] := 20 + 42 shl 5 + 20 shl 11;
                  end;
        clBlue : begin
                    AntiAliasColors[%01] := 10 +  0 shl 5 +  0 shl 11;
                    AntiAliasColors[%10] := 20 +  0 shl 5 +  0 shl 11;
                  end;
        clLime : begin
                    AntiAliasColors[%01] :=  0 + 21 shl 5 +  0 shl 11;
                    AntiAliasColors[%10] :=  0 + 42 shl 5 +  0 shl 11;
                  end;
        clGreen : begin
                    AntiAliasColors[%01] :=  0 + 10 shl 5 +  0 shl 11;
                    AntiAliasColors[%10] :=  0 + 20 shl 5 +  0 shl 11;
                  end;
        clRed : begin
                    AntiAliasColors[%01] :=  0 +  0 shl 5 + 10 shl 11;
                    AntiAliasColors[%10] :=  0 +  0 shl 5 + 20 shl 11;
                  end;
      end;
    end;
  end;
end;

end.
