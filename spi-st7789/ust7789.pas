unit ust7789;

{$mode ObjFPC}{$H+}

interface
uses
  pico_gpio_c,
  pico_timer_c,
  pico_spi_c,
  pico_c;

(**
 *Color of pen
 *If you want to use another color, you can choose one in RGB565 format.
 *)

const
  WHITE =     $FFFF;
  BLACK =     $0000;
  BLUE =      $001F;
  RED =       $F800;
  MAGENTA =   $F81F;
  GREEN =     $07E0;
  CYAN =      $7FFF;
  YELLOW =    $FFE0;
  GRAY =      $8430;
  BRED =      $F81F;
  GRED =      $FFE0;
  GBLUE =     $07FF;
  BROWN =     $BC40;
  BRRED =     $FC07;
  DARKBLUE =  $01CF;
  LIGHTBLUE = $7D7C;
  GRAYBLUE =  $5458;

  LIGHTGREEN =$841F;
  LGRAY =     $C618;
  LGRAYBLUE = $A651;
  LBBLUE =    $2B12;

type
  TST7789 = object
  private
    fpspi :  ^TSPI_Registers;
    fpinCS,fPinDC,fpinRST : longWord;
    fWidth,fHeight,
    fXShift,fYShift: word;
    procedure RST_Clr;
    procedure RST_Set;
    procedure DC_Clr;
    procedure DC_Set;
    procedure Select;
    procedure UnSelect;
    procedure WriteCommand(const cmd:byte);
    procedure WriteData(constref buff : array of byte; buff_size : longWord);
    procedure WriteDataByte(data : byte);
    procedure WriteDataWord(data : word);
  public
    constructor init(var spi : TSPI_Registers;const pinMosi,pinMiso,pinSCK,pinCS,pinDC,pinRST : longWord);
    procedure Fill_Color(color:word);
    procedure SetAddressWindow(const x0,y0,x1,y1 : word);
    procedure SetRotation(const rotation : byte);
  end;

implementation
const
  // Control Registers and constant codes */
  {%H-}ST7789_NOP     =$00;
  {%H-}ST7789_SWRESET =$01;
  {%H-}ST7789_RDDID   =$04;
  {%H-}ST7789_RDDST   =$09;

  {%H-}ST7789_SLPIN   =$10;
  ST7789_SLPOUT  =$11;
  {%H-}ST7789_PTLON   =$12;
  ST7789_NORON   =$13;

  {%H-}ST7789_INVOFF  =$20;
  ST7789_INVON   =$21;
  {%H-}ST7789_DISPOFF =$28;
  ST7789_DISPON  =$29;
  ST7789_CASET   =$2A;
  ST7789_RASET   =$2B;
  ST7789_RAMWR   =$2C;
  {%H-}ST7789_RAMRD   =$2E;

  {%H-}ST7789_PTLAR   =$30;
  ST7789_COLMOD  =$3A;
  ST7789_MADCTL  =$36;

(**
 * Memory Data Access Control Register ($36H)
 * MAP:     D7  D6  D5  D4  D3  D2  D1  D0
 * param:   MY  MX  MV  ML  RGB MH  -   -
 *
 *)

// Page Address Order ('0': Top to Bottom, '1': the opposite) */
  ST7789_MADCTL_MY  =$80;
// Column Address Order ('0': Left to Right, '1': the opposite) */
  ST7789_MADCTL_MX  =$40;
// Page/Column Order ('0' = Normal Mode, '1' = Reverse Mode) */
  ST7789_MADCTL_MV  =$20;
// Line Address Order ('0' = LCD Refresh Top to Bottom, '1' = the opposite) */
  {%H-}ST7789_MADCTL_ML  =$10;
// RGB/BGR Order ('0' = RGB, '1' = BGR) */
  ST7789_MADCTL_RGB =$00;

  {%H-}ST7789_RDID1   = $DA;
  {%H-}ST7789_RDID2   = $DB;
  {%H-}ST7789_RDID3   = $DC;
  {%H-}ST7789_RDID4   = $DD;

// Advanced options */
(**
 * Caution: Do not operate these settings
 * You know what you are doing
 *)

  ST7789_COLOR_MODE_16bit =$55;    //  RGB565 (16bit)
  {%H-}ST7789_COLOR_MODE_18bit =$66;    //  RGB666 (18bit)


  procedure TST7789.RST_Clr;
  begin
    //HAL_GPIO_WritePin(ST7789_RST_PORT, ST7789_RST_PIN, GPIO_PIN_RESET)
  end;
  procedure TST7789.RST_Set;
  begin
    //HAL_GPIO_WritePin(ST7789_RST_PORT, ST7789_RST_PIN, GPIO_PIN_SET
  end;

  procedure TST7789.DC_Clr;
  begin
    //HAL_GPIO_WritePin(ST7789_DC_PORT, ST7789_DC_PIN, GPIO_PIN_RESET)
  end;

  procedure TST7789.DC_Set;
  begin
    //HAL_GPIO_WritePin(ST7789_DC_PORT, ST7789_DC_PIN, GPIO_PIN_SET
  end;

  procedure TST7789.Select;
  begin
    //HAL_GPIO_WritePin(ST7789_CS_PORT, ST7789_CS_PIN, GPIO_PIN_RESET
  end;

  procedure TST7789.UnSelect;
  begin
    //HAL_GPIO_WritePin(ST7789_CS_PORT, ST7789_CS_PIN, GPIO_PIN_SET
  end;

  constructor TST7789.init(var spi : TSPI_Registers;const pinMosi,pinMiso,pinSCK,pinCS,pinDC,pinRST : longWord);
  begin
    fpspi := @spi;
    fpinCS := pinCS;
    fpinDC := pinDC;
    fpinRST := pinRST;
    fWidth := 240;
    fHeight := 240;

    spi_init(spi0, 5000000);
    gpio_set_function(pinMosi, GPIO_FUNC_SPI);
    gpio_set_function(pinMiso, GPIO_FUNC_SPI);
    gpio_set_function(pinSCK,  GPIO_FUNC_SPI);

    gpio_init(pinCS);
    gpio_set_dir(pinCS, GPIO_OUT);
    gpio_put(pinCS, true);

    gpio_init(pinDC);
    gpio_set_dir(pinDC, GPIO_OUT);
    gpio_put(pinDC, true);

    gpio_init(pinRST);
    gpio_set_dir(pinRST, GPIO_OUT);
    gpio_put(pinRST, true);

    busy_wait_us_32(25000);
    RST_Clr;
    busy_wait_us_32(25000);
    RST_Set;
    busy_wait_us_32(50000);

    WriteCommand(ST7789_COLMOD);		//	Set color mode
    WriteDataByte(ST7789_COLOR_MODE_16bit);
    WriteCommand($B2);				//	Porch control
    WriteData([$0C, $0C, $00, $33, $33], 5);
    SetRotation(0);	//	MADCTL (Display Rotation)

    // Internal LCD Voltage generator settings
    WriteCommand($B7);				//	Gate Control
    WriteDataByte($35);			//	Default value
    WriteCommand($BB);				//	VCOM setting
    WriteDataByte($19);			//	0.725v (default 0.75v for =$20)
    WriteCommand($C0);				//	LCMCTRL
    WriteDataByte ($2C);			//	Default value
    WriteCommand ($C2);				//	VDV and VRH command Enable
    WriteDataByte ($01);			//	Default value
    WriteCommand ($C3);				//	VRH set
    WriteDataByte ($12);			//	+-4.45v (defalut +-4.1v for =$0B)
    WriteCommand ($C4);				//	VDV set
    WriteDataByte ($20);			//	Default value
    WriteCommand ($C6);				//	Frame rate control in normal mode
    WriteDataByte ($0F);			//	Default value (60HZ)
    WriteCommand ($D0);				//	Power control
    WriteDataByte ($A4);			//	Default value
    WriteDataByte ($A1);			//	Default value
    //**************** Division line ****************/

    WriteCommand($E0);
    WriteData([$D0,$04,$0D,$11,$13,$2B,$3F,$54,$4C,$18,$0D,$0B,$1F,$23],14);

    WriteCommand($E1);
    WriteData([$D0,$04,$0C,$11,$13,$2C,$3F,$44,$51,$2F,$1F,$1F,$20,$23],14);

    WriteCommand (ST7789_INVON);		//	Inversion ON
    WriteCommand (ST7789_SLPOUT);	//	Out of sleep mode
    WriteCommand (ST7789_NORON);		//	Normal Display on
    WriteCommand (ST7789_DISPON);	//	Main screen turned on

    busy_wait_us_32(50000);
    Fill_Color(BLACK);				//	Fill with Black.
  end;

  (**
 * @brief Fill the DisplayWindow with single color
 * @param color -> color to Fill with
 * @return none
 *)
  procedure TST7789.Fill_Color(color:word);
  var
    i,j : word;
  begin
    SetAddressWindow(0, 0, fWidth - 1, fHeight - 1);
    Select();
    for i := 0 to fWidth - 1 do
      for j := 0 to fHeight - 1 do
        WriteData([color shr 8,color and $ff],2);
    UnSelect();
  end;

  (**
 * @brief Write command to ST7789 controller
 * @param cmd -> command to write
 * @return none
 *)
procedure TST7789.WriteCommand(const cmd:byte);
begin
  Select;
  DC_Clr;
  //HAL_SPI_Transmit(&ST7789_SPI_PORT, &cmd, sizeof(cmd), HAL_MAX_DELAY);
  UnSelect;
end;

(**
 * @brief Write data to ST7789 controller
 * @param buff -> pointer of data buffer
 * @param buff_size -> size of the data buffer
 * @return none
 *)
procedure TST7789.WriteData(constref buff : array of byte; buff_size : longWord);
begin
  Select;
  DC_Set;
  // split data in small chunks because HAL can't send more than 64K at once

  while buff_size > 0 do
  begin
    //		uint16_t chunk_size = buff_size > 65535 ? 65535 : buff_size;
    //		HAL_SPI_Transmit(&ST7789_SPI_PORT, buff, chunk_size, HAL_MAX_DELAY);
    //		buff += chunk_size;
    //		buff_size -= chunk_size;
  end;
  UnSelect;
end;

(**
 * @brief Write data to ST7789 controller, simplify for 8bit data.
 * data -> data to write
 * @return none
 *)
procedure TST7789.WriteDataByte(data : byte);
begin
  Select;
  DC_Set;
  //HAL_SPI_Transmit(&ST7789_SPI_PORT, &data, sizeof(data), HAL_MAX_DELAY);
  UnSelect;
end;

(**
 * @brief Write data to ST7789 controller, simplify for 8bit data.
 * data -> data to write
 * @return none
 *)
procedure TST7789.WriteDataWord(data : word);
begin
  Select;
  DC_Set;
  //HAL_SPI_Transmit(&ST7789_SPI_PORT, &data, sizeof(data), HAL_MAX_DELAY);
  UnSelect;
end;
(**
 * @brief Set the rotation direction of the display
 * @param m -> rotation parameter(please refer it in st7789.h)
 * @return none
 *)
procedure TST7789.SetRotation(const rotation : byte);
begin
  WriteCommand(ST7789_MADCTL);	// MADCTL
  case rotation of
    0: WriteDataByte(ST7789_MADCTL_MX + ST7789_MADCTL_MY + ST7789_MADCTL_RGB);
    1: WriteDataByte(ST7789_MADCTL_MY + ST7789_MADCTL_MV + ST7789_MADCTL_RGB);
    2: WriteDataByte(ST7789_MADCTL_RGB);
    3: WriteDataByte(ST7789_MADCTL_MX + ST7789_MADCTL_MV + ST7789_MADCTL_RGB);
  end;
end;

(**
 * @brief Set address of DisplayWindow
 * @param xi&yi -> coordinates of window
 * @return none
 *)
procedure TST7789.SetAddressWindow(const x0,y0,x1,y1 : word);
var
  x_start,x_end,y_start,y_end : word;
begin
  Select;
  x_start := x0 + fXShift;
  x_end := x1 + fXShift;
  y_start := y0 + fYShift;
  y_end := y1 + fYShift;

  // Column Address set
  WriteCommand(ST7789_CASET);
  WriteData([x_start shr 8,x_start and $ff,x_end shr 8,x_end and $ff],4);

  // Row Address set
  WriteCommand(ST7789_RASET);
  WriteData([y_start shr 8,y_start and $ff,y_end shr 8,y_end and $ff],4);
  // Write to RAM
  WriteCommand(ST7789_RAMWR);
  UnSelect;
end;

end.

