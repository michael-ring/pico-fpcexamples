unit ST7735_spi_c;
{$mode objfpc}
{$H+}
{$modeswitch advancedrecords}
{$SCOPEDENUMS ON}


interface

uses
  CustomDisplay,
  CustomDisplay16Bits,
  pico_c;

type
  TST7735_SPI = object(TCustomDisplay16BitsSPI)
  protected
    procedure InitSequence; virtual;
  public
  const
    // Physical Width is up to 128 Pixel Physical Height goes up to 160 Pixel
    ScreenSize80x160x16: TPhysicalScreenInfo =
      (Width: 80; Height: 160; Depth: TDisplayBitDepth.SixteenBits; ColorOrder: TDisplayColorOrder.BGR; ColStart: (1, 26, 1, 26); RowStart: (26, 1, 26, 1));
    ScreenSize128x128x16: TPhysicalScreenInfo =
      (Width: 128; Height: 128; Depth: TDisplayBitDepth.SixteenBits; ColorOrder: TDisplayColorOrder.BGR; ColStart: (3, 2, 1, 2); RowStart: (2, 3, 2, 1));
    ScreenSize128x160x16RGB: TPhysicalScreenInfo =
      (Width: 128; Height: 160; Depth: TDisplayBitDepth.SixteenBits; ColorOrder: TDisplayColorOrder.RGB; ColStart: (0, 0, 0, 0); RowStart: (0, 0, 0, 0));

    (*
      Sets the rotation of a display in steps of 90 Degrees.
      Usefull when you have no control on how the display is mounted.
    param:
      displayRotation
    *)
    procedure setRotation(const DisplayRotation: TDisplayRotation); virtual;

    (*
      Sets the active drawing area and switches to data mode
    param:
      X,Y Top Left coordinate of paint Area
      Width, Height: Width and Height of Drawing Area
    return:
      Returns the number of Pixels that are included in the Area
    *)
    function setDrawArea(const X, Y, Width, Height: word): longword; virtual;

    (*
      Sets a single Pixel on the display by drawing currently selected ForegroundColor or provided color
    param:
      x,y : Position of the pixel
      color: Color of the Pixel
    note:
      Drawing single pixel creates a relatively high overhead, so do not overdo single pixel paining
    *)
    procedure drawPixel(const x, y: word; const fgColor: TColor = clForeground); virtual;
  end;

  TST7735R_SPI = object(TST7735_SPI)
  protected
    procedure InitSequence; virtual;
  end;

  TST7735S_SPI = object(TST7735_SPI)
  protected
    procedure InitSequence; virtual;
  end;


implementation

const
  ST7735_MADCTL_MY = $80;
  ST7735_MADCTL_MX = $40;
  ST7735_MADCTL_MV = $20;
  ST7735_MADCTL_ML = $10;
  ST7735_MADCTL_MH = $04;
  ST7735_MADCTL_RGB = $00;
  ST7735_MADCTL_BGR = $08;

  ST7735_NOP = $00;
  ST7735_SWRESET = $01;
  ST7735_RDDID = $04;
  ST7735_RDDST = $09;

  ST7735_SLPIN = $10;
  ST7735_SLPOUT = $11;
  ST7735_PTLON = $12;
  ST7735_NORON = $13;

  ST7735_INVOFF = $20;
  ST7735_INVON = $21;
  ST7735_DISPOFF = $28;
  ST7735_DISPON = $29;
  ST7735_CASET = $2A;
  ST7735_RASET = $2B;
  ST7735_RAMWR = $2C;
  ST7735_RAMRD = $2E;

  ST7735_PTLAR = $30;
  ST7735_COLMOD = $3A;
  ST7735_MADCTL = $36;

  ST7735_FRMCTR1 = $B1;
  ST7735_FRMCTR2 = $B2;
  ST7735_FRMCTR3 = $B3;
  ST7735_INVCTR = $B4;
  ST7735_DISSET5 = $B6;

  ST7735_PWCTR1 = $C0;
  ST7735_PWCTR2 = $C1;
  ST7735_PWCTR3 = $C2;
  ST7735_PWCTR4 = $C3;
  ST7735_PWCTR5 = $C4;
  ST7735_VMCTR1 = $C5;

  ST7735_RDID1 = $DA;
  ST7735_RDID2 = $DB;
  ST7735_RDID3 = $DC;
  ST7735_RDID4 = $DD;
  ST7735_PWCTR6 = $FC;

  ST7735_GMCTRP1 = $E0;
  ST7735_GMCTRN1 = $E1;

const
  DELAY = $80;
  ST7735_Init_Sequence: array of byte = (
    $01, $00 or DELAY, $32,  // _SWRESET and Delay 50ms
    $11, $00 or DELAY, $FF,  // _SLPOUT
    $3A, $01 or DELAY, $05, $0A,  // _COLMOD
    $B1, $03 or DELAY, $00, $06, $03, $0A,  // _FRMCTR1
    $36, $01, $08,  // _MADCTL
    $B6, $02, $15, $02,  // _DISSET5
    // 1 clk cycle nonoverlap, 2 cycle gate, rise, 3 cycle osc equalize, Fix on VTL
    $B4, $01, $00,  // _INVCTR line inversion
    $C0, $02 or DELAY, $02, $70, $0A,  // _PWCTR1 GVDD = 4.7V, 1.0uA, 10 ms delay
    $C1, $01, $05,  // _PWCTR2 VGH = 14.7V, VGL = -7.35V
    $C2, $02, $01, $02,  // _PWCTR3 Opamp current small, Boost frequency
    $C5, $02 or DELAY, $3C, $38, $0A,  // _VMCTR1
    $FC, $02, $11, $15,  // _PWCTR6
    $E0, $10, $09, $16, $09, $20, $21, $1B, $13, $19, $17, $15, $1E, $2B, $04, $05, $02, $0E,  // _GMCTRP1 Gamma
    $E1, $10 or DELAY, $0B, $14, $08, $1E, $22, $1D, $18, $1E, $1B, $1A, $24, $2B, $06, $06, $02, $0F, $0A,  // _GMCTRN1
    $13, $00 or DELAY, $0a,  // _NORON
    $29, $00 or DELAY, $FF  // _DISPON
    );

  ST7735R_Init_Sequence: array of byte = (
    $01, $80, $96,  // SWRESET and Delay 150ms
    $11, $80, $ff,  // SLPOUT and Delay
    $b1, $03, $01, $2C, $2D,  // _FRMCTR1
    $b2, $03, $01, $2C, $2D,  // _FRMCTR2
    $b3, $06, $01, $2C, $2D, $01, $2C, $2D,  // _FRMCTR3
    $b4, $01, $07,  // _INVCTR line inversion
    $c0, $03, $a2, $02, $84,  // _PWCTR1 GVDD = 4.7V, 1.0uA
    $c1, $01, $c5,  // _PWCTR2 VGH=14.7V, VGL=-7.35V
    $c2, $02, $0a, $00,  // _PWCTR3 Opamp current small, Boost frequency
    $c3, $02, $8a, $2a,
    $c4, $02, $8a, $ee,
    $c5, $01, $0e,  // _VMCTR1 VCOMH = 4V, VOML = -1.1V
    $20, $00,  // _INVOFF
    $36, $01, $18,  // _MADCTL bottom to top refresh
    // 1 clk cycle nonoverlap, 2 cycle gate rise, 3 sycle osc equalie,
    // fix on VTL
    $3a, $01, $05,  // COLMOD - 16bit color
    $e0, $10, $02, $1c, $07, $12, $37, $32, $29, $2d, $29, $25, $2B, $39, $00, $01, $03, $10,  // _GMCTRP1 Gamma
    $e1, $10, $03, $1d, $07, $06, $2E, $2C, $29, $2D, $2E, $2E, $37, $3F, $00, $00, $02, $10,  // _GMCTRN1
    $13, $80, $0a,  // _NORON
    $29, $80, $64  // _DISPON
    );

  ST7735S_Init_Sequence: array of byte = (
    // sw reset
    $01, 0 or DELAY, $96, //150ms
    // SLPOUT and Delay
    $11, 0 or DELAY, $FF, //255ms
    $B1, $03, $01, $2C, $2D,      // _FRMCTR1
    $B3, $06, $01, $2C, $2D, $01, $2C, $2D,     // _FRMCTR3
    $B4, $01, $07, // _INVCTR line inversion
    $C0, $03, $A2, $02, $84, // _PWCTR1 GVDD = 4.7V, 1.0uA
    $C1, $01, $C5, // _PWCTR2 VGH=14.7V, VGL=-7.35V
    $C2, $02, $0A, $00, // _PWCTR3 Opamp current small, Boost frequency
    $C3, $02, $8A, $2A,
    $C4, $02, $8A, $EE,
    $C5, $01, $0E, // _VMCTR1 VCOMH = 4V, VOML = -1.1V
    $20, $00, // _INVOFF
    $36, $01, $18, // _MADCTL bottom to top refresh
    // 1 clk cycle nonoverlap, 2 cycle gate rise, 3 cycle osc equalie,
    // fix on VTL
    $3A, $01, $05, // COLMOD - 16bit color
    $E0, $10, $02, $1C, $07, $12, $37, $32, $29, $2D, $29, $25, $2B,
    $39, $00, $01, $03, $10, // _GMCTRP1 Gamma
    $E1, $10, $03, $1D, $07, $06, $2E, $2C, $29, $2D, $2E, $2E, $37,
    $3F, $00, $00, $02, $10, // _GMCTRN1
    $13, 0 or DELAY, $0A, // _NORON
    $29, 0 or DELAY, $64, // _DISPON
    // $36, $01, $C0,  // _MADCTL Default rotation plus BGR encoding
    $36, $01, $C8,      // _MADCTL Default rotation plus RGB encoding
    $21, $00      // _INVON
    );

procedure TST7735_SPI.setRotation(const displayRotation: TDisplayRotation);
var
  ColMode: byte;
begin
  colStart := PhysicalScreenInfo.ColStart[byte(displayRotation)];
  rowStart := PhysicalScreenInfo.RowStart[byte(displayRotation)];
  if PhysicalScreenInfo.ColorOrder = TDisplayColorOrder.RGB then
    colMode := ST7735_MADCTL_RGB
  else
    colMode := ST7735_MADCTL_BGR;
  case displayRotation of
    TDisplayRotation.None:
    begin
      FScreenWidth := PhysicalScreenInfo.Width;
      FScreenHeight := PhysicalScreenInfo.Height;
      WriteCommandBytes(ST7735_MADCTL, [ST7735_MADCTL_MX + ST7735_MADCTL_MY + colMode]);
    end;
    TDisplayRotation.Right: begin
      FScreenWidth := PhysicalScreenInfo.Height;
      FScreenHeight := PhysicalScreenInfo.Width;
      WriteCommandBytes(ST7735_MADCTL, [ST7735_MADCTL_MY + ST7735_MADCTL_MV + colMode]);
    end;
    TDisplayRotation.UpsideDown:
    begin
      FScreenWidth := PhysicalScreenInfo.Width;
      FScreenHeight := PhysicalScreenInfo.Height;
      WriteCommandBytes(ST7735_MADCTL, [colMode]);
    end;
    TDisplayRotation.Left: begin
      FScreenWidth := PhysicalScreenInfo.Height;
      FScreenHeight := PhysicalScreenInfo.Width;
      WriteCommandBytes(ST7735_MADCTL, [ST7735_MADCTL_MX + ST7735_MADCTL_MV + colMode]);
    end;
  end;
end;

function TST7735_SPI.setDrawArea(const X, Y, Width, Height: word): longword;
begin
  {$PUSH}
  {$WARN 4079 OFF}
  Result := 0;
  WriteCommandWords(ST7735_CASET, [X + rowStart, X + rowStart + Width - 1]);
  WriteCommandWords(ST7735_RASET, [Y + colStart, Y + colStart + Height - 1]);
  WriteCommand(ST7735_RAMWR);
  Result := Width * Height;
  {$POP}
end;

procedure TST7735_SPI.drawPixel(const x, y: word; const fgColor: TColor = clForeground);
var
  _fgColor: word;
begin
  if (x >= ScreenWidth) or (y >= ScreenHeight) then
    exit;
  WriteCommandWords(ST7735_CASET, [X + rowStart, X + rowStart]);
  WriteCommandWords(ST7735_RASET, [Y + colStart, Y + colStart]);
  WriteCommand(ST7735_RAMWR);
  _fgColor := color24to16(fgColor);
  WriteData(hi(_fgColor));
  WriteData(lo(_fgColor));
end;

procedure TST7735_SPI.InitSequence;
begin
  InitSequenceEx(ST7735_Init_Sequence);
end;

procedure TST7735R_SPI.InitSequence;
begin
  InitSequenceEx(ST7735R_Init_Sequence);
end;

procedure TST7735S_SPI.InitSequence;
begin
  InitSequenceEx(ST7735S_Init_Sequence);
end;

{$WARN 5028 OFF}
begin
end.
