unit CustomDisplay16bits;

{$mode ObjFPC}{$H+}

interface

uses
  CustomDisplay;

type
  TCustomDisplay16Bits = object(TCustomDisplay)
  private
    (*
      Convert a RGB Value consisting of 8 bits per color to 16Bit Value in 565 firmat
    *)
    function color24to16(color888:TColor):word;

    (*
      Convert a RGB Value consisting of 8 bits per color to 16Bit Value in 565 format and Swaps High/Low Byte
    *)
    function color24to16S(color888:TColor):word;

  public
    procedure clearScreen; virtual;

    (*
      Draws a Text on the display
    param:
      TheText The String to draw
      x,y Top left position of string to draw
    *)
    procedure drawText(const TheText : String; const x,y : word; const Color : TColor); virtual;

    (*
      Sets the Foreground color that gets used in Routines that do not explicitly allow you to set a color for painting
      param:
        color
    *)
    procedure setForegroundColor(const color : TColor); virtual;

    (*
      Sets the Background color that gets used in Routines that do not explicitly allow you to set a color for background
    param:
      color
    *)
    procedure setBackgroundColor(const color : TColor); virtual;

    (*
      Draws a vertical line on the display
    param:
      x,y : Start position of the line
      height: height of line in pixels
      color: color to use for painting the line
    *)
    procedure drawFastVLine(const  x, y : word ; height : word; const color : TColor=-1); virtual;

    (*
      Draws a horizontal line on the display
    param:
      x,y : Start position of the line
      width: width of line
      color: color to use for painting the line
    *)
    procedure drawFastHLine(const  x, y : word; width : word; const color : TColor=-1); virtual;


    procedure fillRect(const x,y,width,height : word; const color : TColor = -1); virtual;
  end;

implementation

procedure TCustomDisplay16Bits.setForegroundColor(const color : TColor);
begin
  FForegroundColor := color;
  FNativeForegroundColor := color24to16S(color);
end;

procedure TCustomDisplay16Bits.setBackgroundColor(const color : TColor);
begin
  FBackgroundColor := color;
  FNativeBackgroundColor := color24to16S(color);
end;

procedure TCustomDisplay16Bits.drawFastHLine(const x,y : word; width : word; const color : TColor=-1);
type
  bufferArray = array[1..640] of byte;
  pBufferArray = ^bufferArray;
var
  i : integer;
  _color : word;
  buffer : array[1..320] of word;
begin
  if (x >= ScreenWidth) or (y >= ScreenHeight) then
    exit;
  if x+width >= ScreenWidth then
    width := ScreenWidth-x-1;
  setDrawArea(X,Y,width,1);
  _color := color24to16S(color);
  for i := 1 to width do
    buffer[i] := _color;
  WriteData(pBufferArray(@buffer)^,width * 2);
end;

procedure TCustomDisplay16Bits.drawFastVLine(const x,y : word; height : word; const color : TColor=-1);
type
  bufferArray = array[1..640] of byte;
  pBufferArray = ^bufferArray;
var
  i : integer;
  _color : word;
  buffer : array[1..320] of word;
begin
  if (x >= ScreenWidth) or (y >= ScreenHeight) then
    exit;
  if y+height >= ScreenHeight then
    height := ScreenHeight-y-1;
  setDrawArea(X,Y,1,height);
  _color := color24to16S(color);
  for i := 1 to height do
    buffer[i] := _color;
  WriteData(pBufferArray(@buffer)^,height * 2);
end;

procedure TCustomDisplay16Bits.fillRect(const x,y,width,height : word; const color : TColor = -1);
var
  i,j : word;
begin
  for i := x to x + width -1 do
    for j := y to height -1 do
      DrawPixel(i,j,color);
end;


procedure TCustomDisplay16Bits.clearScreen;
type
  bufferArray = array[1..480] of byte;
  pBufferArray = ^bufferArray;
var
  i : integer;
  buffer : array[1..240] of word;
begin
  for i := 1 to ScreenWidth do
    buffer[i] := FNativeBackgroundColor;
  SetDrawArea(0,0,ScreenWidth,ScreenHeight);
  for i := 1 to ScreenHeight do
    WriteData(pBufferArray(@buffer)^,ScreenWidth * 2);
end;


procedure TCustomDisplay16Bits.drawText(const TheText : String; const x,y : word; const Color : TColor);
type
  bufferArray = array of byte;
  pBufferArray = ^bufferArray;
var
  i,j : longWord;
  charstart,pixelPos : longWord;
  fx,fy : longWord;
  PixelBuffer : array of word;
  divFactor,pixel,pixels : byte;
  AntialiasColors : array[0..3] of word;
begin
  SetLength(PixelBuffer,FontInfo.Width*FontInfo.Height);
  divFactor := 8;
  if FontInfo.BitsPerPixel = 2 then
  begin
    CalculateAntialiasColors(AntialiasColors);
    divFactor := 4;
  end;
  for i := 1 to length(TheText) do
  begin
    if (x+i*fontInfo.Width <= ScreenWidth) and (y+fontInfo.Height <= ScreenHeight) then
    begin
      charstart := pos(TheText[i],FontInfo.Charmap)-1;
      if charstart > 0 then
      begin
        for fy := 0 to FontInfo.Height-1 do
        begin
          pixelPos := charStart * fontInfo.BytesPerChar+fy*(fontInfo.BytesPerChar div fontInfo.Height);
          for fx := 0 to FontInfo.width-1 do
          begin
            pixels := FontInfo.pFontData^[pixelPos + (fx div divFactor)];
            if FontInfo.BitsPerPixel = 2 then
            begin
              pixel := (pixels shr ((3-(fx and %11)) * 2)) and %11;
              PixelBuffer[fy*FontInfo.Width+fx] := AntialiasColors[pixel];
            end
            else
            begin
              pixel := (pixels shr ((7-(fx and %111)))) and %1;
              if pixel = 0 then
                PixelBuffer[fy*FontInfo.Width+fx] := FNativeBackgroundColor
              else
                PixelBuffer[fy*FontInfo.Width+fx] := FNativeForegroundColor
            end;
          end;
        end;
      end
      else
      begin
        for j := 0 to FontInfo.Width*FontInfo.Height-1 do
          PixelBuffer[j] := FNativeBackgroundColor;
      end;
      SetDrawArea(x+(i-1)*fontInfo.Width,y,FontInfo.Width,FontInfo.Height);
      WriteData(pbufferArray(@PixelBuffer)^,length(pixelbuffer)*2);
    end;
  end;
end;

function TCustomDisplay16Bits.color24to16(color888:TColor):word;
var
  red,green,blue : byte;
begin
  Red := (color888 shr (16+3)) and $1f;
  Green := (color888 shr (8+2)) and $3f;
  Blue := (color888 shr (0+3)) and $1f;
  Result := (Red shl 11) + (Green shl 5) + Blue;
end;

function TCustomDisplay16Bits.color24to16S(color888:TColor):word;
var
  red,green,blue : byte;
begin
  Red := (color888 shr (16+3)) and $1f;
  Green := (color888 shr (8+2)) and $3f;
  Blue := (color888 shr (0+3)) and $1f;
  Result := (Red shl 11) + (Green shl 5) + Blue;
  Result := (Result shr 8) + (Result shl 8);
end;

end.

