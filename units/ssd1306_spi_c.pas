unit ssd1306_spi_c;
{$MODE OBJFPC}
{$H+}

interface
uses
  CustomDisplay_c,
  CustomSPIDisplay_c,
  pico_c;
const
  ScreenSize128x64x1: TScreenInfo =
    (Width: 128; Height: 64; Depth: TDisplayBitDepth.OneBit);
  ScreenSize128x32x1: TScreenInfo =
    (Width: 128; Height: 32; Depth: TDisplayBitDepth.OneBit);
  ScreenSize96x16x1: TScreenInfo =
    (Width: 96; Height: 16; Depth: TDisplayBitDepth.OneBit);
  ScreenSize64x48x1: TScreenInfo =
    (Width: 64; Height: 48; Depth: TDisplayBitDepth.OneBit);

type
  TSSD1306_SPI = object(TCustomSPIDisplay)
    FExternalVCC : boolean;
    FrameBuffer : array of byte;
    procedure InitSequence;
    procedure ClearScreen;
    procedure setFont(const TheFontInfo : TFontInfo);
    function setDrawArea(X,Y,Width,Height : word):longWord;
    procedure drawText(const TheText : String; x,y : longWord);
    procedure setPixel(const x,y : byte);
    procedure clearPixel(const x,y : byte);
    procedure updateScreen;
  end;

implementation
const
  CMD_SET_LOW_COLUMN = $00;
  CMD_EXTERNAL_VCC = $01;
  CMD_SWITCH_CAP_VCC = $02;
  CMD_SET_HIGH_COLUMN = $10;

  CMD_MEMORY_MODE = $20;
  CMD_COLUMN_ADDRESS = $21;
  CMD_PAGE_ADDRESS   = $22;
  CMD_RIGHT_HORIZONTAL_SCROLL = $26;
  CMD_LEFT_HORIZONTAL_SCROLL = $27;
  CMD_VERTICAL_AND_RIGHT_HORIZONTAL_SCROLL = $29;
  CMD_VERTICAL_AND_LEFT_HORIZONTAL_SCROLL = $2A;
  CMD_DEACTIVATE_SCROLL = $2E;
  CMD_ACTIVATE_SCROLL = $2F;
  CMD_SET_START_LINE = $40;
  CMD_SET_CONTRAST = $81;
  CMD_CHARGE_PUMP = $8D;
  CMD_SEGMENT_REMAP = $A0;
  CMD_SET_VERTICAL_SCROLL_AREA = $A3;
  CMD_DISPLAY_ALL_ON_RESUME = $A4;
  CMD_DISPLAY_ALL_ON =$A5;
  CMD_NORMAL_DISPLAY = $A6;
  CMD_INVERT_DISPLAY = $A7;
  CMD_SET_MULTIPLEX_RATIO = $A8;
  CMD_DISPLAY_OFF = $AE;
  CMD_DISPLAY_ON = $AF;
  CMD_SET_PAGE_START = $B0;
  CMD_COM_SCAN_INC = $C0;
  CMD_COM_SCAN_DEC = $C8;
  CMD_SET_DISPLAY_OFFSET = $D3;
  CMD_SET_DISPLAY_CLOCK_DIV = $D5;
  CMD_SET_PRECHARGE = $D9;
  CMD_SET_COM_PINS = $DA;
  CMD_SET_VCOM_DETECT = $DB;
  CMD_NOP = $E3;
var
  FontInfo : TFontInfo;

procedure TSSD1306_SPI.InitSequence;
begin
  SetLength(FrameBuffer,(ScreenInfo.Width * ScreenInfo.Height div 8)+1);
  FExternalVCC := false;
  //Set Display off
  WriteCommand(CMD_DISPLAY_OFF);

  // Set Display Clock Divide Ratio / OSC Frequency
  WriteCommand(CMD_SET_DISPLAY_CLOCK_DIV,$80);

  // Set Multiplex Ratio
  WriteCommand(CMD_SET_MULTIPLEX_RATIO,ScreenInfo.Height-1);

  // Set Display Offset
  WriteCommand(CMD_SET_DISPLAY_OFFSET,$00);

  // Set Display Start Line
  WriteCommand(CMD_SET_START_LINE or $00);

  // Set Charge Pump
  if FExternalVCC then
    WriteCommand(CMD_CHARGE_PUMP,$10)
  else
    WriteCommand(CMD_CHARGE_PUMP,$14);

  WriteCommand(CMD_MEMORY_MODE,$00);

  // Set Segment Re-Map
  WriteCommand(CMD_SEGMENT_REMAP or $01);

  // Set Com Output Scan Direction
  WriteCommand(CMD_COM_SCAN_DEC);

  // Set COM Hardware Configuration
  if (ScreenInfo = ScreenSize128x32x1) then
  begin
    WriteCommand(CMD_SET_COM_PINS,$02);
    WriteCommand(CMD_SET_CONTRAST,$8F)
  end
  else if (ScreenInfo = ScreenSize128x64x1) then
  begin
    WriteCommand(CMD_SET_COM_PINS,$12);
    if FExternalVCC then
      WriteCommand(CMD_SET_CONTRAST,$9F)
    else
      WriteCommand(CMD_SET_CONTRAST,$CF);
  end
  else if (ScreenInfo = ScreenSize96x16x1) then
  begin
    WriteCommand(CMD_SET_COM_PINS,$02);
    if FExternalVCC then
      WriteCommand(CMD_SET_CONTRAST,$10)
    else
      WriteCommand(CMD_SET_CONTRAST,$AF);
  end;

   // Set Pre-Charge Period
  if FExternalVCC then
    WriteCommand(CMD_SET_PRECHARGE,$22)
  else
    WriteCommand(CMD_SET_PRECHARGE,$F1);

  // Set VCOMH Deselect Level
  WriteCommand(CMD_SET_VCOM_DETECT,$40);

  // Set all pixels OFF
  WriteCommand(CMD_DISPLAY_ALL_ON_RESUME);

  // Set display not inverted
  WriteCommand(CMD_NORMAL_DISPLAY);
  WriteCommand(CMD_DEACTIVATE_SCROLL);
  // Set display On
  WriteCommand(CMD_DISPLAY_ON);
end;

procedure TSSD1306_SPI.clearScreen;
var
  i : integer;
begin
  setDrawArea(0,0,ScreenInfo.Width,ScreenInfo.Height);
  //Increase Performance by writing larger chunks of data
  if BackgroundColor = clBlack then
    for i := Low(FrameBuffer) to High(FrameBuffer) do
      FrameBuffer[i] := 0
  else
    for i := Low(FrameBuffer)+1 to High(FrameBuffer) do
      FrameBuffer[i] := $ff;
  WriteData(FrameBuffer);
end;

procedure TSSD1306_SPI.setFont(const TheFontInfo : TFontInfo);
begin
  FontInfo := TheFontInfo;
end;

function TSSD1306_SPI.setDrawArea(X,Y,Width,Height : word):longWord;
begin
  {$PUSH}
  {$WARN 4079 OFF}
  Result := 0;
  if (X >=ScreenInfo.Width) or (Y >=ScreenInfo.Height) then
    exit;

  if X+Width >ScreenInfo.Width then
    Width := ScreenInfo.Width-X;
  if Y+Height >ScreenInfo.Height then
    Height := ScreenInfo.Height-Y;
  WriteCommand(CMD_MEMORY_MODE,$01);
  WriteCommand(CMD_PAGE_ADDRESS,Y shr 3,(Y+Height{%H-}-1) shr 3);
  WriteCommand(CMD_COLUMN_ADDRESS,X,X+Width{%H-}-1);
  Result := Width*Height shr 3;
  {$POP}
end;

procedure TSSD1306_SPI.drawText(const TheText : String; x,y : longWord);
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
    if (x+i*fontInfo.Width <= ScreenInfo.Width) and (y+fontInfo.Height <= ScreenInfo.Height) then
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
              setPixel(x+i*FontInfo.Width+x1,y+y1)
            else
              clearPixel(x+i*FontInfo.Width+x1,y+y1);
          end;
      end
    end;
  end;
end;

procedure TSSD1306_SPI.setPixel(const x,y : byte);
var
  offset : longWord;
begin
  if (x >= ScreenInfo.Width) or (y >= ScreenInfo.Height) then
    exit;
  Offset := (y div 8)+x*(ScreenInfo.Height div 8)+1;
  if ForegroundColor=clWhite then
    FrameBuffer[Offset] := FrameBuffer[Offset] or (1 shl (y mod 8))
  else
    FrameBuffer[Offset] := FrameBuffer[Offset] and (not(1 shl (y mod 8)));
end;

procedure TSSD1306_SPI.clearPixel(const x,y : byte);
var
  offset : longWord;
begin
  if (x >= ScreenInfo.Width) or (y >= ScreenInfo.Height) then
    exit;
  Offset := (y div 8)+x*(ScreenInfo.Height div 8)+1;
  if ForegroundColor=clBlack then
    FrameBuffer[Offset] := FrameBuffer[Offset] or (1 shl (y mod 8))
  else
    FrameBuffer[Offset] := FrameBuffer[Offset] and (not(1 shl (y mod 8)));
end;

procedure TSSD1306_SPI.updateScreen;
begin
  setDrawArea(0,0,ScreenInfo.Width,ScreenInfo.Height);
  WriteData(FrameBuffer);
end;

{$WARN 5028 OFF}
begin
end.
