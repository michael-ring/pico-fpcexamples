unit st7789_spi_c;
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
  TST7789_SPI = object(TCustomDisplay16BitsSPI)
      FMotorolaMode : boolean;
    protected
      procedure InitSequence; virtual;
    public
      const
        // Physical Width is up to 240 Pixel Physical Height goes up to 320 Pixel
        ScreenSize240x135x16: TPhysicalScreenInfo =
          (Width: 135; Height: 240; Depth: TDisplayBitDepth.SixteenBits;ColorOrder: TDisplayColorOrder.RGB;ColStart : (40,53,40,52); RowStart : (52,40,53,40));
        ScreenSize240x240x16: TPhysicalScreenInfo =
          (Width: 240; Height: 240; Depth: TDisplayBitDepth.SixteenBits;ColorOrder: TDisplayColorOrder.RGB;ColStart : (0,0,80,0); RowStart : (0,0,0,80));
        ScreenSize280x240x16: TPhysicalScreenInfo =
          (Width: 240; Height: 280; Depth: TDisplayBitDepth.SixteenBits;ColorOrder: TDisplayColorOrder.RGB;ColStart : (20,0,20,0); RowStart : (0,20,0,20));
        ScreenSize320x172x16: TPhysicalScreenInfo =
          (Width: 172; Height: 320; Depth: TDisplayBitDepth.SixteenBits;ColorOrder: TDisplayColorOrder.RGB;ColStart : (0,34,0,34); RowStart : (34,0,34 ,0));
        ScreenSize320x240x16: TPhysicalScreenInfo =
          (Width: 240; Height: 320; Depth: TDisplayBitDepth.SixteenBits;ColorOrder: TDisplayColorOrder.RGB;ColStart : (0,0,0,0); RowStart : (0,0,0,0));

    (*
      Sets the rotation of a display in steps of 90 Degrees.
      Usefull when you have no control on how the display is mounted.
    param:
      displayRotation
    *)
    procedure setRotation(const DisplayRotation : TDisplayRotation); virtual;

    (*
      Sets the active drawing area and switches to data mode
    param:
      X,Y Top Left coordinate of paint Area
      Width, Height: Width and Height of Drawing Area
    return:
      Returns the number of Pixels that are included in the Area
    *)
    function setDrawArea(const X,Y,Width,Height : word):longWord; virtual;

    (*
      Sets a single Pixel on the display by drawing currently selected ForegroundColor or provided color
    param:
      x,y : Position of the pixel
      color: Color of the Pixel
    note:
      Drawing single pixel creates a relatively high overhead, so do not overdo single pixel paining
    *)
    procedure drawPixel(const x,y : word; const fgColor : TColor = clForeground); virtual;
  end;

implementation
const
  ST7789_MADCTL_MY =  $80;
  ST7789_MADCTL_MX =  $40;
  ST7789_MADCTL_MV =  $20;
  ST7789_MADCTL_RGB = $00;
  ST7789_MADCTL_BGR = $08;

  // ST7789 specific commands used in init
  ST7789_NOP        = $00;
  ST7789_SWRESET    = $01;
  ST7789_RDDID      = $04;
  ST7789_RDDST      = $09;

  ST7789_RDDPM      = $0A;      // Read display power mode
  ST7789_RDD_MADCTL = $0B;      // Read display MADCTL
  ST7789_RDD_COLMOD = $0C;      // Read display pixel format
  ST7789_RDDIM      = $0D;      // Read display image mode
  ST7789_RDDSM      = $0E;      // Read display signal mode
  ST7789_RDDSR      = $0F;      // Read display self-diagnostic result (ST7789V)

  ST7789_SLPIN      = $10;
  ST7789_SLPOUT     = $11;
  ST7789_PTLON      = $12;
  ST7789_NORON      = $13;

  ST7789_INVOFF     = $20;
  ST7789_INVON      = $21;
  ST7789_GAMSET     = $26;      // Gamma set
  ST7789_DISPOFF    = $28;
  ST7789_DISPON     = $29;
  ST7789_CASET      = $2A;
  ST7789_RASET      = $2B;
  ST7789_RAMWR      = $2C;
  ST7789_RGBSET     = $2D;      // Color setting for 4096, 64K and 262K colors
  ST7789_RAMRD      = $2E;

  ST7789_PTLAR      = $30;
  ST7789_VSCRDEF    = $33;      // Vertical scrolling definition (ST7789V)
  ST7789_TEOFF      = $34;      // Tearing effect line off
  ST7789_TEON       = $35;      // Tearing effect line on
  ST7789_MADCTL     = $36;      // Memory data access control
  ST7789_IDMOFF     = $38;      // Idle mode off
  ST7789_IDMON      = $39;      // Idle mode on
  ST7789_RAMWRC     = $3C;      // Memory write continue (ST7789V)
  ST7789_RAMRDC     = $3E;      // Memory read continue (ST7789V)
  ST7789_COLMOD     = $3A;

  ST7789_RAMCTRL    = $B0;      // RAM control
  ST7789_RGBCTRL    = $B1;      // RGB control
  ST7789_PORCTRL    = $B2;      // Porch control
  ST7789_FRCTRL1    = $B3;      // Frame rate control
  ST7789_PARCTRL    = $B5;      // Partial mode control
  ST7789_GCTRL      = $B7;      // Gate control
  ST7789_GTADJ      = $B8;      // Gate on timing adjustment
  ST7789_DGMEN      = $BA;      // Digital gamma enable
  ST7789_VCOMS      = $BB;      // VCOMS setting
  ST7789_LCMCTRL    = $C0;      // LCM control
  ST7789_IDSET      = $C1;      // ID setting
  ST7789_VDVVRHEN   = $C2;      // VDV and VRH command enable
  ST7789_VRHS       = $C3;      // VRH set
  ST7789_VDVSET     = $C4;      // VDV setting
  ST7789_VCMOFSET   = $C5;      // VCOMS offset set
  ST7789_FRCTR2     = $C6;      // FR Control 2
  ST7789_CABCCTRL   = $C7;      // CABC control
  ST7789_REGSEL1    = $C8;      // Register value section 1
  ST7789_REGSEL2    = $CA;      // Register value section 2
  ST7789_PWMFRSEL   = $CC;      // PWM frequency selection
  ST7789_PWCTRL1    = $D0;      // Power control 1
  ST7789_VAPVANEN   = $D2;      // Enable VAP/VAN signal output
  ST7789_CMD2EN     = $DF;      // Command 2 enable
  ST7789_PVGAMCTRL  = $E0;      // Positive voltage gamma control
  ST7789_NVGAMCTRL  = $E1;      // Negative voltage gamma control
  ST7789_DGMLUTR    = $E2;      // Digital gamma look-up table for red
  ST7789_DGMLUTB    = $E3;      // Digital gamma look-up table for blue
  ST7789_GATECTRL   = $E4;      // Gate control
  ST7789_SPI2EN     = $E7;      // SPI2 enable
  ST7789_PWCTRL2    = $E8;      // Power control 2
  ST7789_EQCTRL     = $E9;      // Equalize time control
  ST7789_PROMCTRL   = $EC;      // Program control
  ST7789_PROMEN     = $FA;      // Program mode enable
  ST7789_NVMSET     = $FC;      // NVM setting
  ST7789_PROMACT    = $FE;      // Program action

  ST7789_COLOR_MODE_16bit =$55;
  ST7789_COLOR_MODE_18bit =$66;

const
  DELAY=$80;
  ST7789_Init_Sequence : array of byte = (
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
    $E0, $10, $02, $1C, $07, $12, $37, $32, $29, $2D, $29, $25, $2B, $39, $00, $01, $03, $10, // _GMCTRP1 Gamma
    $E1, $10, $03, $1D, $07, $06, $2E, $2C, $29, $2D, $2E, $2E, $37, $3F, $00, $00, $02, $10, // _GMCTRN1
    $13, 0 or DELAY, $0A, // _NORON
    $29, 0 or DELAY, $64, // _DISPON
    // $36, $01, $C0,  // _MADCTL Default rotation plus BGR encoding
    $36, $01, $C8,      // _MADCTL Default rotation plus RGB encoding
    $21, $00      // _INVON
    );

procedure TST7789_SPI.InitSequence;
begin
  InitSequenceEx(ST7789_Init_Sequence);
end;

procedure TST7789_SPI.setRotation(const displayRotation : TDisplayRotation);
var
  ColMode : byte;
begin
  colStart := PhysicalScreenInfo.ColStart[byte(displayRotation)];
  rowStart := PhysicalScreenInfo.RowStart[byte(displayRotation)];
  if PhysicalScreenInfo.ColorOrder = TDisplayColorOrder.RGB then
    colMode := ST7789_MADCTL_RGB
  else
    colMode := ST7789_MADCTL_BGR;

  case displayRotation of
    TDisplayRotation.None:
    begin
      FScreenWidth := PhysicalScreenInfo.Width;
      FScreenHeight := PhysicalScreenInfo.Height;
      WriteCommandBytes(ST7789_MADCTL,[colMode]);
    end;
    TDisplayRotation.Right: begin
      FScreenWidth := PhysicalScreenInfo.Height;
      FScreenHeight := PhysicalScreenInfo.Width;
      WriteCommandBytes(ST7789_MADCTL,[ST7789_MADCTL_MX + ST7789_MADCTL_MV + colMode]);
    end;
    TDisplayRotation.UpsideDown:
    begin
      FScreenWidth := PhysicalScreenInfo.Width;
      FScreenHeight := PhysicalScreenInfo.Height;
      WriteCommandBytes(ST7789_MADCTL,[ST7789_MADCTL_MX + ST7789_MADCTL_MY + colMode]);
    end;
    TDisplayRotation.Left: begin
      FScreenWidth := PhysicalScreenInfo.Height;
      FScreenHeight := PhysicalScreenInfo.Width;
      WriteCommandBytes(ST7789_MADCTL,[ST7789_MADCTL_MV + ST7789_MADCTL_MY + colMode]);
    end;
  end;
end;

function TST7789_SPI.setDrawArea(const X,Y,Width,Height : word):longWord;
begin
  {$PUSH}
  {$WARN 4079 OFF}
  Result := 0;
  if (X >=ScreenWidth) or (Y >=ScreenHeight) then
    exit;

  WriteCommandWords(ST7789_CASET,[X+rowStart,X+rowStart+Width-1]);
  WriteCommandWords(ST7789_RASET,[Y+colStart,Y+colStart+Height-1]);
  WriteCommand(ST7789_RAMWR);
  Result := Width*Height;
  {$POP}
end;

procedure TST7789_SPI.drawPixel(const x,y : word; const fgColor : TColor = clForeground);
var
  _fgColor : word;
begin
  if (x >= ScreenWidth) or (y >= ScreenHeight) then
    exit;
  WriteCommandWords(ST7789_CASET,[X+rowStart,X+rowStart]);
  WriteCommandWords(ST7789_RASET,[Y+colStart,Y+colStart]);
  WriteCommand(ST7789_RAMWR);
  _fgColor := color24to16(fgColor);
  WriteData(hi(_fgColor));
  WriteData(lo(_fgColor));
end;

{$WARN 5028 OFF}
begin
end.
