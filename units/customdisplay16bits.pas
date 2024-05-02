unit CustomDisplay16bits;

{$mode ObjFPC}{$H+}

interface

uses
  CustomDisplay,
  pico_timer_c,
  pico_gpio_c,
  pico_spi_c,
  pico_c;

type
  TCustomDisplay16Bits = object(TCustomDisplay)
  protected
    (*
      Convert a RGB Value consisting of 8 bits per color to 16Bit Value in 565 format
    *)
    function color24to16(color888: TColor): word;

    (*
      Convert a RGB Value consisting of 8 bits per color to 16Bit Value in 565 format and Swaps High/Low Byte
    *)
    //function color24to16S(color888:TColor):word;

  public
    procedure clearScreen; virtual;

    (*
      Draws a Text on the display
    param:
      TheText The String to draw
      x,y Top left position of string to draw
    *)
    procedure drawText(const TheText: string; const x, y: word; const fgColor: TColor = clForeground; const bgColor: TColor = clTransparent); virtual;

    (*
      Draws a vertical line on the display
    param:
      x,y : Start position of the line
      height: height of line in pixels
      fgColor: color to use for painting the line
    *)
    procedure drawFastVLine(const x, y: word; Height: word; const fgColor: TColor = clForeground); virtual;

    (*
      Draws a horizontal line on the display
    param:
      x,y : Start position of the line
      width: width of line
      fgColor: color to use for painting the line
    *)
    procedure drawFastHLine(const x, y: word; Width: word; const fgColor: TColor = clForeground); virtual;

    procedure fillRect(const x, y, Width, Height: word; const fgColor: TColor = clForeground); virtual;
  end;

  TCustomDisplay16BitsSPI = object(TCustomDisplay16Bits)
  private
    FpSPI: ^TSPI_Registers;
    FPinDC: TPinIdentifier;
    FPinRST: TPinIdentifier;
    FPinSoftCS: TPinIdentifier;
    FMotorolaMode : boolean;
  protected
    procedure WriteCommand(const command: byte); virtual;
    procedure WriteCommandBytes(const command: byte; constref Data: array of byte; Count: longint = -1); virtual;
    procedure WriteCommandWords(const command: byte; constref Data: array of word; Count: longint = -1); virtual;
    procedure WriteData(const Data: byte); virtual;
    procedure WriteDataBytes(constref Data: array of byte; Count: longint = -1); virtual;
    procedure WriteDataWords(constref Data: array of word; Count: longint = -1); virtual;
    procedure InitSequenceEx(const aInitSequence : array of byte); virtual;
    procedure InitSequence; virtual; abstract;
  public
  (*
      Initializes the display
    param
      SPI     The SPI Interface to use
      aPinDC  Pin used for switching between Communication between Data and Command Mode
      aPinRST Pin used to reset the display, not needed by all displays, pass TNativePin.None when not needed
      aPhysicalScreenInfo Information about Width/Height and Bitdepth of the connected screen
    note
      The SPI interface needs to be pre-initialized to required Parameters
      The extra Pins do not need to be initialized
    *)
    constructor Initialize(var SPI: TSpi_Registers; const aPinDC: TPinIdentifier; const aPinSoftCS: TPinIdentifier; const aPinRST: TPinIdentifier; aPhysicalScreenInfo: TPhysicalScreenInfo;aMotorolaMode : boolean = False);
  end;

implementation

procedure TCustomDisplay16Bits.drawFastHLine(const x, y: word; Width: word; const fgColor: TColor = clForeground);
var
  i: integer;
  _fgColor, _width, _height: word;
  buffer: array[1..320] of word;
begin
  if clipToScreen(x, y, Width, 1, _width, _height) = False then
    exit;
  if fgColor = clForeground then
    _fgColor := color24to16(foregroundColor)
  else
    _fgColor := color24to16(fgColor);

  setDrawArea(x, y, _width, _height);

  for i := 1 to _width do
    buffer[i] := _fgColor;
  WriteDataWords(buffer, _width);
end;

procedure TCustomDisplay16Bits.drawFastVLine(const x, y: word; Height: word; const fgColor: TColor = clForeground);
var
  i: integer;
  _fgColor, _width, _height: word;
  buffer: array[1..320] of word;
begin
  if clipToScreen(x, y, 1, Height, _width, _height) = False then
    exit;
  if fgColor = clForeground then
    _fgColor := color24to16(foregroundColor)
  else
    _fgColor := color24to16(fgColor);

  setDrawArea(x, y, 1, _height);

  for i := 1 to _height do
    buffer[i] := _fgColor;
  WriteDataWords(buffer, _height);
end;

procedure TCustomDisplay16Bits.fillRect(const x, y, Width, Height: word; const fgColor: TColor = clForeground);
var
  i: word;
  _fgColor, _width, _height: word;
  buffer: array[1..320] of word;
begin
  if clipToScreen(x, y, Width, Height, _width, _height) = False then
    exit;
  if fgColor = clForeground then
    _fgColor := color24to16(foregroundColor)
  else
    _fgColor := color24to16(fgColor);

  if _width > _height then
  begin
    for i := 1 to _width do
      buffer[i] := _fgColor;
    for i := 0 to _Height - 1 do
    begin
      SetDrawArea(x, y, _width, y);
      WriteDataWords(buffer, _width);
    end;
  end
  else
  begin
    for i := 1 to _height do
      buffer[i] := _fgColor;
    for i := 0 to _Width - 1 do
    begin
      SetDrawArea(x, y, x, _height);
      WriteDataWords(buffer, _height);
    end;
  end;
end;

procedure TCustomDisplay16Bits.clearScreen;
var
  i: integer;
  _bgColor: word;
  buffer: array[1..320] of word;
begin
  _bgColor := color24to16(FBackgroundColor);
  for i := 1 to ScreenWidth do
    buffer[i] := _bgColor;
  SetDrawArea(0, 0, ScreenWidth, ScreenHeight);
  for i := 1 to ScreenHeight do
  begin
    //SetDrawArea(0,i-1,ScreenWidth,1);
    WriteDataWords(buffer, ScreenWidth);
  end;
end;


procedure TCustomDisplay16Bits.drawText(const TheText: string; const x, y: word; const fgColor: TColor = clForeground; const bgColor: TColor = clTransparent);
var
  i: longword;
  charstart, pixelPos: longword;
  fx, fy: longword;
  divFactor, pixel, pixels: byte;
  AntialiasColors: array[0..3] of TColor;
begin
  divFactor := 8;
  if FontInfo.BitsPerPixel = 2 then
  begin
    CalculateAntialiasColors(fgColor, bgColor, AntialiasColors);
    divFactor := 4;
  end;
  for i := 1 to length(TheText) do
  begin
    if (x + (i - 1) * fontInfo.Width <= ScreenWidth) and (y <= ScreenHeight) then
    begin
      charstart := pos(TheText[i], FontInfo.Charmap) - 1;
      if charstart > 0 then
      begin
        for fy := 0 to FontInfo.Height - 1 do
        begin
          pixelPos := charStart * fontInfo.BytesPerChar + fy * (fontInfo.BytesPerChar div fontInfo.Height);
          for fx := 0 to FontInfo.Width - 1 do
          begin
            pixels := FontInfo.pFontData^[pixelPos + (fx div divFactor)];
            if FontInfo.BitsPerPixel = 2 then
            begin
              pixel := (pixels shr ((3 - (fx and %11)) * 2)) and %11;
              if (pixel > 0) then
                drawPixel(x + (i - 1) * fontInfo.Width + fx, y + fy,
                  AntialiasColors[pixel])
              else
              if (bgColor <> clTransparent) then
                drawPixel(x + (i - 1) * fontInfo.Width + fx, y + fy, AntialiasColors[0]);
            end
            else
            begin
              pixel := (pixels shr ((7 - (fx and %111)))) and %1;
              if (pixel = 1) then
                drawPixel(x + (i - 1) * fontInfo.Width + fx, y + fy, fgColor)
              else
              if bgColor <> clTransparent then
                drawPixel(x + (i - 1) * fontInfo.Width + fx, y + fy, bgColor);
            end;
          end;
        end;
      end
      else
      if bgColor <> clTransparent then
        fillRect(x + (i - 1) * fontInfo.Width, y, fontInfo.Width,
          fontInfo.Height, bgColor);
    end;
  end;
end;

function TCustomDisplay16Bits.color24to16(color888: TColor): word;
var
  red, green, blue: byte;
begin
  Red := (color888 shr (16 + 3)) and $1f;
  Green := (color888 shr (8 + 2)) and $3f;
  Blue := (color888 shr (0 + 3)) and $1f;
  //if PhysicalScreenInfo.ColorOrder = TDisplayColorOrder.RGB then
  Result := (Red shl 11) + (Green shl 5) + Blue;
  //else
  //  Result := (Blue shl 11) + (Green shl 5) + Red;
end;

(*function TCustomDisplay16Bits.color24to16S(color888:TColor):word;
var
  red,green,blue : byte;
begin
  Red := (color888 shr (16+3)) and $1f;
  Green := (color888 shr (8+2)) and $3f;
  Blue := (color888 shr (0+3)) and $1f;
  Result := (Red shl 11) + (Green shl 5) + Blue;
  Result := (Result shr 8) + (Result shl 8);
end;
*)

constructor TCustomDisplay16BitsSPI.Initialize(var SPI: TSpi_Registers; const aPinDC: TPinIdentifier; const aPinSoftCS: TPinIdentifier; const aPinRST: TPinIdentifier;
  aPhysicalScreenInfo: TPhysicalScreenInfo;aMotorolaMode : boolean = False);
begin
  FpSPI := @SPI;
  FPinDC := aPinDC;
  FPinRST := aPinRST;
  FMotorolaMode := aMotorolaMode;
  PhysicalScreenInfo := aPhysicalScreenInfo;
  if APinDC > -1 then
  begin
    gpio_init(APinDC);
    gpio_set_dir(APinDC, TGPIO_Direction.GPIO_OUT);
    gpio_put(APinDC, False);
  end;
  if APinRST > -1 then
  begin
    gpio_init(APinRST);
    gpio_set_dir(APinRST, TGPIO_Direction.GPIO_OUT);
    gpio_put(APinRST, True);
  end;
  if APinSoftCS > -1 then
  begin
    gpio_init(APinSoftCS);
    gpio_set_dir(APinSoftCS, TGPIO_Direction.GPIO_OUT);
    gpio_put(APinSoftCS, True);
  end;
    if FMotorolaMode = true then
      spi_set_format(FpSPI^,TSPI_DataBits.SPI_DATABITS_EIGHT,Tspi_cpol.SPI_CPOL_1,Tspi_cpha.SPI_CPHA_1,Tspi_order.SPI_MSB_FIRST)
    else
      spi_set_format(FpSPI^,TSPI_DataBits.SPI_DATABITS_EIGHT,Tspi_cpol.SPI_CPOL_0,Tspi_cpha.SPI_CPHA_0,Tspi_order.SPI_MSB_FIRST);

  InitSequence;
end;

procedure TCustomDisplay16BitsSPI.InitSequenceEx(const aInitSequence : array of byte);
const
  DELAY = $80;
var
  pos: longword;
  dataCount: longword;
  hasDelay: boolean;
  command: byte;
begin
  pos := 0;
  repeat
    command := aInitSequence[pos];
    Inc(pos);
    dataCount := aInitSequence[pos];

    if dataCount >= DELAY then
    begin
      dataCount := datacount and $7f;
      hasDelay := True;
    end
    else
      hasDelay := False;

    if datacount = 0 then
    begin
      WriteCommand(command);
      Inc(pos);
    end;
    if dataCount > 0 then
    begin
      Inc(pos);
      writeCommandBytes(command, aInitSequence[pos], datacount);
      pos := pos + datacount;
    end;
    if hasDelay then
    begin
      busy_wait_ms(aInitSequence[pos]);
      Inc(pos);
    end;
  until pos >= longword(length(aInitSequence));

  setRotation(TDisplayRotation.None);
  ForegroundColor := clBlack;
  BackgroundColor := clWhite;
end;

procedure TCustomDisplay16BitsSPI.WriteCommand(const command: byte);
var
  Data: array[0..0] of byte;
begin
  Data[0] := command;
  gpio_put(FPinDC, False);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, False);
  spi_write_blocking(FpSPI^, Data, 1);
  gpio_put(FPinDC, True);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, True);
end;

procedure TCustomDisplay16BitsSPI.WriteCommandBytes(const command: byte; constref Data: array of byte; Count: longint = -1);
var
  _data: array[0..0] of byte;
begin
  if Count = -1 then
    Count := High(Data) + 1;
  _data[0] := command;
  gpio_put(FPinDC, False);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, False);
  spi_write_blocking(FpSPI^, _data, 1);
  gpio_put(FPinDC, True);
  spi_write_blocking(FpSPI^, Data, Count);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, True);
end;

procedure TCustomDisplay16BitsSPI.WriteCommandWords(const command: byte; constref Data: array of word; Count: longint = -1);
var
  _data: array[0..0] of byte;
begin
  if Count = -1 then
    Count := High(Data) + 1;
  _data[0] := command;
  gpio_put(FPinDC, False);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, False);
  spi_write_blocking(FpSPI^, _data, 1);
  gpio_put(FPinDC, True);
  spi_write_blocking_HL(FpSPI^, Data, Count);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, True);
end;

procedure TCustomDisplay16BitsSPI.WriteData(const Data: byte);
var
  _data: array[0..0] of byte;
begin
  _data[0] := Data;
  gpio_put(FPinDC, True);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, False);
  spi_write_blocking(FpSPI^, _data, 1);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, True);
end;

procedure TCustomDisplay16BitsSPI.WriteDataBytes(constref Data: array of byte; Count: longint = -1);
begin
  if Count = -1 then
    Count := High(Data) + 1;
  gpio_put(FPinDC, True);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, False);
  spi_write_blocking(FpSPI^, Data, Count);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, True);
end;

procedure TCustomDisplay16BitsSPI.WriteDataWords(constref Data: array of word; Count: longint = -1);
begin
  if Count = -1 then
    Count := High(Data) + 1;
  gpio_put(FPinDC, True);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, False);
  spi_write_blocking_HL(FpSPI^, Data, Count);
  if FPinSoftCS > -1 then
    gpio_put(FPinSoftCS, True);
end;

end.
