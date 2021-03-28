unit CustomDisplayFrameBuffer1Bit;

{$mode ObjFPC}{$H+}

interface

uses
  CustomDisplay;

type
  TCustomDisplayFrameBuffer1Bit = object(TCustomDisplay)
  private
    FrameBuffer : array of byte;
    i2cHack : byte;
  protected
    procedure enablei2cHack;
  public
    constructor Initialize;
    procedure clearScreen; virtual;
    procedure updateScreen;
    procedure drawPixel(const x,y : word; const color:TColor); virtual;
    procedure drawText(const TheText : String; const x,y : word; const Color : TColor); virtual;
    procedure setForegroundColor(const color : TColor); virtual;
    procedure setBackgroundColor(const color : TColor); virtual;
    procedure setRotation(const DisplayRotation : TDisplayRotation); virtual;
    procedure drawFastVLine(const  x, y : word ; height : word; const color : TColor=-1); virtual;
    procedure drawFastHLine(const  x, y : word; width : word; const color : TColor=-1); virtual;
    procedure fillRect(const x,y,width,height : word; const color : TColor = -1); virtual;
    procedure setPhysicalScreenInfo(screenInfo : TPhysicalScreenInfo); virtual;
  end;

implementation
constructor TCustomDisplayFrameBuffer1Bit.Initialize;
begin
  inherited;
  i2cHack := 0;
end;

procedure TCustomDisplayFrameBuffer1Bit.enableI2CHack;
begin
  i2chack := 1;
end;

procedure TCustomDisplayFrameBuffer1Bit.setPhysicalScreenInfo(screenInfo : TPhysicalScreenInfo);
begin
  inherited;
  setLength(FrameBuffer,screenInfo.Width*screenInfo.Height div 8+i2cHack);
end;

procedure TCustomDisplayFrameBuffer1Bit.setForegroundColor(const color : TColor);
begin
  FForegroundColor := color;
  if color = clBlack then
    FNativeForegroundColor := 0
  else
    FNativeForegroundColor := $ff;
end;

procedure TCustomDisplayFrameBuffer1Bit.setBackgroundColor(const color : TColor);
begin
  FBackgroundColor := color;
  if color = clBlack then
    FNativeBackgroundColor := 0
  else
    FNativeBackgroundColor := $ff;
end;

procedure TCustomDisplayFrameBuffer1Bit.setRotation(const DisplayRotation : TDisplayRotation);
begin
  FRotation := DisplayRotation;
  if (DisplayRotation = TDisplayRotation.None) or (DisplayRotation = TDisplayRotation.UpsideDown) then
  begin
    FScreenWidth := PhysicalScreenInfo.Width;
    FScreenHeight := PhysicalScreenInfo.Height;
  end
  else
  begin
    FScreenWidth := PhysicalScreenInfo.Height;
    FScreenHeight := PhysicalScreenInfo.Width;
  end;
end;

procedure TCustomDisplayFrameBuffer1Bit.drawFastVLine(const  x, y : word ; height : word; const color : TColor=-1);
var
  i : word;
begin
  for i := y to y + height do
    DrawPixel(x,i,color);
end;

procedure TCustomDisplayFrameBuffer1Bit.drawFastHLine(const  x, y : word; width : word; const color : TColor=-1);
var
  i : word;
begin
  for i := x to x + width do
    DrawPixel(i,y,color);
end;

procedure TCustomDisplayFrameBuffer1Bit.fillRect(const x,y,width,height : word; const color : TColor = -1);
var
  i,j : word;
begin
  for i := x to word(x + width) -1 do
    for j := y to height -1 do
      DrawPixel(i,j,color);
end;


procedure TCustomDisplayFrameBuffer1Bit.clearScreen;
var
  i : integer;
begin
  if BackgroundColor = clBlack then
    for i := Low(FrameBuffer) to High(FrameBuffer) do
      FrameBuffer[i] := 0
  else
    for i := Low(FrameBuffer) to High(FrameBuffer) do
      FrameBuffer[i] := $ff;
end;

procedure TCustomDisplayFrameBuffer1Bit.drawText(const TheText : String; const x,y : word; const Color: TColor);
var
  i : longWord;
  theChar : char;
  charStart : word;
  lineOffset : byte;
  x1,y1 : byte;
  xline : byte;
begin
  lineOffset := FontInfo.BytesPerChar div FontInfo.Height;
  for i := 0 to length(TheText)-1 do
  begin
    //only compute when char is completely visible
    if (x+i*fontInfo.Width <= ScreenWidth) and (y+fontInfo.Height <= ScreenHeight) then
    begin
      theChar := TheText[i+1];
      charstart := pos(theChar,FontInfo.Charmap)-1;
      //The char was found in the list of a available chars
      if charStart > 0 then
      begin
        for x1 := 0 to FontInfo.Width-1 do
          for y1 := 0 to FontInfo.Height-1 do
          begin
            xline := FontInfo.pFontData^[charStart*FontInfo.BytesPerChar+(x1 div 8)+y1*lineOffset];
            if xline and (%10000000 shr (x1 and %111)) <> 0 then
              drawPixel(x+i*FontInfo.Width+x1,y+y1,Color)
            else
              drawPixel(x+i*FontInfo.Width+x1,y+y1,BackgroundColor);
          end;
      end
    end;
  end;
end;

procedure TCustomDisplayFrameBuffer1Bit.drawPixel(const x,y : word; const Color : TColor);
var
  offset : longWord;
  _x,_y : word;
begin
  if (x >= ScreenWidth) or (y >= ScreenHeight) then
    exit;

  if Rotation = TDisplayRotation.None then
  begin
    _x := x;
    _y := y;
  end
  else if Rotation = TDisplayRotation.Right then
  begin
    _x := screenWidth - y - 1;
    _y := x;
  end
  else if Rotation = TDisplayRotation.Left then
  begin
    _x := y;
    _y := screenHeight - x - 1;
  end
  else
  begin
    _x := screenWidth - x - 1;
    _y := screenHeight - y - 1;
  end;

  Offset := (_y div 8)+_x*(ScreenHeight div 8);
  //Offset := _x + (y div 8) * ScreenWidth;
  if Color <> clBlack then
    FrameBuffer[Offset+I2CHack] := FrameBuffer[Offset+I2CHack] or (1 shl (_y and %111))
  else
    FrameBuffer[Offset+I2CHack] := FrameBuffer[Offset+I2CHack] and (not(1 shl (_y and %111)));
end;

procedure TCustomDisplayFrameBuffer1Bit.updateScreen;
begin
  setDrawArea(0,0,PhysicalScreenInfo.Width,PhysicalScreenInfo.Height);
  WriteData(FrameBuffer);
end;

end.

