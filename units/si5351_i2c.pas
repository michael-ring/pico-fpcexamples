{*
 * Copyright (C) 2024 Jean-Pierre Mandon <jp.mandon@gmail.com>
 * based on the c libray from Jason Milldrum <milldrum@gmail.com>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *}

unit si5351_i2c;

{$mode ObjFPC}{$H+}
interface

uses
  pico_i2c_c;

type
  Tsi5351_pll = (
    SI5351_PLLA,
    SI5351_PLLB
    );

  Tsi5351_clock = (
    SI5351_CLK0=0,
    SI5351_CLK1=1,
    SI5351_CLK2=2,
    SI5351_CLK3=3,
    SI5351_CLK4=4,
    SI5351_CLK5=5,
    SI5351_CLK6=6,
    SI5351_CLK7=7 );

  Tsi5351_clock_disable = (
    SI5351_CLK_DISABLE_LOW=0,
    SI5351_CLK_DISABLE_HIGH=1,
    SI5351_CLK_DISABLE_HI_Z=2,
    SI5351_CLK_DISABLE_NEVER=3 );

  Tsi5351_drive = (
    SI5351_DRIVE_2MA=0,
    SI5351_DRIVE_4MA=1,
    SI5351_DRIVE_6MA=2,
    SI5351_DRIVE_8MA=3 );

  TSi5351Frac = packed record
    a:uint16;
    b:uint32;
    c:uint32;
    end;

  TSi5351RegSet = packed record
    p1:uint32 ;
    p2:uint32 ;
    p3:uint32 ;
    end;

procedure si5351_init(xtal_load_c:byte; ref_osc_freq:uint32);
procedure si5351_set_correction(corr:uint32);
procedure si5351_set_freq(freq:uint64; clk:Tsi5351_clock);
procedure si5351_set_ms(clk : Tsi5351_clock ; frac:TSi5351Frac ; int_mode : uint8 ; r_div : uint8 ; div_by_4 : uint8 );
procedure si5351_set_int(clk : Tsi5351_clock ; enable : uint8 );
procedure si5351_set_ms_div(clk : Tsi5351_clock ; r_div : uint8 ; div_by_4 : uint8 );
procedure si5351_set_pll( frac:TSi5351Frac; target_pll:Tsi5351_pll);
procedure si5351_pll_reset(target_pll:Tsi5351_pll );
procedure si5351_output_enable( clk : Tsi5351_clock ; enable : uint8);
procedure si5351_drive_strength(clk : Tsi5351_clock ; drive : Tsi5351_drive );
procedure si5351_set_clock_invert( clk: Tsi5351_clock ; inv: uint8 );
procedure si5351_set_clock_disable( clk: Tsi5351_clock ; dis_state: Tsi5351_clock_disable );
function si5351_write(addr:byte;data:byte):byte;
function si5351_write_bulk(addr:byte;len:byte;var data:array of byte):byte;
function si5351_read(addr:byte;out data_value:byte):byte;

const
    SI5351_BUS_BASE_ADDR       = $60       ;
    SI5351_XTAL_FREQ           = 25000000  ;
    SI5351_PLL_FIXED	       = 900000000 ;

    SI5351_CRYSTAL_LOAD_REG    = 183       ;
    SI5351_CRYSTAL_LOAD_MASK   = (3<<6)    ;
    SI5351_CRYSTAL_LOAD_6PF    = (1<<6)    ;
    SI5351_CRYSTAL_LOAD_8PF    = (2<<6)    ;
    SI5351_CRYSTAL_LOAD_10PF   = (3<<6)    ;
    SI5351_PLLA_PARAMETERS     = 26        ;
    SI5351_PLLB_PARAMETERS     = 34        ;
    SI5351_PLL_RESET_REG       = 177       ;
    SI5351_PLL_RESET_B	       = (1<<7)    ;
    SI5351_PLL_RESET_A	       = (1<<5)    ;

    SI5351_PLL_VCO_MIN	       = 600000000 ;
    SI5351_PLL_VCO_MAX	       = 900000000 ;
    SI5351_MULTISYNTH_MIN_FREQ = 1000000   ;
    SI5351_MULTISYNTH_DIVBY4_FREQ  = 150000000                    ;
    SI5351_MULTISYNTH_MAX_FREQ	   = 160000000                    ;
    SI5351_MULTISYNTH67_MAX_FREQ   = SI5351_MULTISYNTH_DIVBY4_FREQ;
    SI5351_CLKOUT_MIN_FREQ	   = 8000                         ;
    SI5351_CLKOUT_MAX_FREQ	   = SI5351_MULTISYNTH_MAX_FREQ   ;
    SI5351_CLKOUT67_MAX_FREQ	   = SI5351_MULTISYNTH67_MAX_FREQ ;

    SI5351_CLK0_CTRL		   = 16                           ;
    SI5351_CLK1_CTRL		   = 17                           ;
    SI5351_CLK2_CTRL		   = 18                           ;
    SI5351_CLK3_CTRL		   = 19                           ;
    SI5351_CLK4_CTRL		   = 20                           ;
    SI5351_CLK5_CTRL		   = 21                           ;
    SI5351_CLK6_CTRL		   = 22                           ;
    SI5351_CLK7_CTRL		   = 23                           ;
    SI5351_CLK_POWERDOWN	   = (1<<7)                       ;
    SI5351_CLK_INTEGER_MODE	   = (1<<6)                       ;
    SI5351_CLK_PLL_SELECT	   = (1<<5)                       ;
    SI5351_CLK_INVERT		   = (1<<4)                       ;
    SI5351_CLK_INPUT_MASK	   = (3<<2)                       ;
    SI5351_CLK_INPUT_XTAL	   = (0<<2)                       ;
    SI5351_CLK_INPUT_CLKIN	   = (1<<2)                       ;

    SI5351_CLK3_0_DISABLE_STATE	   = 24                           ;
    SI5351_CLK7_4_DISABLE_STATE	   = 25                           ;

    SI5351_CLK0_PARAMETERS	   = 42                           ;
    SI5351_CLK1_PARAMETERS	   = 50                           ;
    SI5351_CLK2_PARAMETERS	   = 58                           ;
    SI5351_CLK3_PARAMETERS	   = 66                           ;
    SI5351_CLK4_PARAMETERS	   = 74                           ;
    SI5351_CLK5_PARAMETERS	   = 82                           ;
    SI5351_CLK6_PARAMETERS	   = 90                           ;
    SI5351_CLK7_PARAMETERS	   = 91                           ;
    SI5351_CLK6_7_OUTPUT_DIVIDER   = 92                           ;
    SI5351_OUTPUT_CLK_DIV_MASK	   = (7 << 4)                     ;
    SI5351_OUTPUT_CLK6_DIV_MASK	   = (7 << 0)                     ;
    SI5351_OUTPUT_CLK_DIV_SHIFT	   = 4                            ;
    SI5351_OUTPUT_CLK_DIV6_SHIFT   = 0                            ;
    SI5351_OUTPUT_CLK_DIV_1	   = 0                            ;
    SI5351_OUTPUT_CLK_DIV_2	   = 1                            ;
    SI5351_OUTPUT_CLK_DIV_4	   = 2                            ;
    SI5351_OUTPUT_CLK_DIV_8	   = 3                            ;
    SI5351_OUTPUT_CLK_DIV_16	   = 4                            ;
    SI5351_OUTPUT_CLK_DIV_32	   = 5                            ;
    SI5351_OUTPUT_CLK_DIV_64	   = 6                            ;
    SI5351_OUTPUT_CLK_DIV_128	   = 7                            ;
    SI5351_OUTPUT_CLK_DIVBY4	   = (3<<2)                       ;

    SI5351_OUTPUT_ENABLE_CTRL	   = 3                            ;

implementation

var
  msg            : array of byte                ;
  xtal_freq      : longword = SI5351_XTAL_FREQ  ;
  ref_correction : int32                        ;

  {*
   * si5351_init(xtal_load_c:byte; ref_osc_freq:uint32);
   *
   * Setup communications to the Si5351 and set the crystal
   * load capacitance.
   *
   * xtal_load_c - Crystal load capacitance. Use the SI5351_CRYSTAL_LOAD_*PF
   * defines as constant
   * ref_osc_freq - Crystal/reference oscillator frequency in 1 Hz increments.
   * Defaults to 25000000 if a 0 is used here.
   *
   *}

procedure si5351_init(xtal_load_c:byte; ref_osc_freq:uint32);
begin
    si5351_write(SI5351_CRYSTAL_LOAD_REG,xtal_load_c);
    if (ref_osc_freq <> 0) then
  	xtal_freq := ref_osc_freq
    else xtal_freq := 25000000;
    // Initialize the CLK outputs according to flowchart in datasheet
    // First, turn them off
    si5351_write(16, $80); //CLK0 Power down
    si5351_write(17, $80); //CLK1 Power down
    si5351_write(18, $80); //CLK2 Power down
    // Turn the clocks back on...
    si5351_write(16, $0c); //CLK0 set Multisynth0 as source
    si5351_write(17, $0c); //CLK1 set Multisynth1 as source
    si5351_write(18, $0c); //CLK2 set Multisynth2 as source
    // Then reset the PLLs
    si5351_pll_reset(SI5351_PLLA);
    si5351_pll_reset(SI5351_PLLB);
end;

{*
 * si5351_set_correction(corr:uint32);
 *
 * Use this to set the oscillator correction factor to
 * EEPROM. This value is a signed 32-bit integer of the
 * parts-per-10 million value that the actual oscillation
 * frequency deviates from the specified frequency.
 *
 * The frequency calibration is done as a one-time procedure.
 * Any desired test frequency within the normal range of the
 * Si5351 should be set, then the actual output frequency
 * should be measured as accurately as possible. The
 * difference between the measured and specified frequencies
 * should be calculated in Hertz, then multiplied by 10 in
 * order to get the parts-per-10 million value.
 *
 * Since the Si5351 itself has an intrinsic 0 PPM error, this
 * correction factor is good across the entire tuning range of
 * the Si5351. Once this calibration is done accurately, it
 * should not have to be done again for the same Si5351 and
 * crystal.
 *}
procedure si5351_set_correction(corr:uint32);
begin
  ref_correction := corr;
end;

{*
 * si5351_set_pll(frac:TSi5351Frac; target_pll:Tsi5351_pll);
 *
 * Set the specified PLL to a specific oscillation frequency by
 * using the TSi5351Frac struct to specify the synth divider ratio.
 *
 * frac - PLL fractional divider values
 * target_pll - Which PLL to set
 *     (use the Tsi5351_pll type)
 *}

procedure si5351_set_pll( frac:TSi5351Frac; target_pll:Tsi5351_pll);
var
        pll_reg : TSi5351RegSet        ;
        params  : array of byte        ;
        i       : byte = 0             ;
        temp    : byte                 ;
begin
  {$PUSH}
  {$WARN 5091 off : Local variable "$1" of a managed type does not seem to be initialized}
  setlength(params,8);
  {$POP}
  // Calculate parameters
  {$PUSH}
  {$WARN 4081 off : Converting the operands to "$1" before doing the multiply could prevent overflow errors.}
  {$WARN 4079 off : Converting the operands to "$1" before doing the add could prevent overflow errors.}
  pll_reg.p1 := 128 * frac.a + ((128 * frac.b) div frac.c) - 512;
  pll_reg.p2 := 128 * frac.b - frac.c * ((128 * frac.b) div frac.c);
  pll_reg.p3 := frac.c;
  {$POP}
  // Derive the register values to write
  // Prepare an array for parameters to be written to

  // Registers 26-27 for PLLA
  temp := ((pll_reg.p3 >> 8) AND $FF);
  params[i] := temp;
  inc(i);

  temp := uint8(pll_reg.p3 AND $FF);
  params[i] := temp;
  inc(i);

  // Register 28 for PLLA
  temp := uint8((pll_reg.p1 >> 16) AND $03);
  params[i] := temp;
  inc(i);

  // Registers 29-30 for PLLA
  temp := uint8((pll_reg.p1 >> 8) AND $FF);
  params[i] := temp;
  inc(i);

  temp := uint8(pll_reg.p1 AND $FF);
  params[i] := temp;
  inc(i);

  // Register 31 for PLLA
  temp := uint8((pll_reg.p3 >> 12) AND $F0);
  temp := temp +uint8((pll_reg.p2 >> 16) AND $0F);
  params[i] := temp;
  inc(i);

  // Registers 32-33 for PLLA
  temp := uint8((pll_reg.p2 >> 8) AND $FF);
  params[i] := temp;
  inc(i);

  temp := uint8(pll_reg.p2 AND $FF);
  params[i] := temp;
  inc(i);

  // Write the parameters
  if (target_pll = SI5351_PLLA) then
    si5351_write_bulk(SI5351_PLLA_PARAMETERS, i, params)
  else
    if (target_pll = SI5351_PLLB) then
       si5351_write_bulk(SI5351_PLLB_PARAMETERS, i, params);
end;

{*
 * si5351_set_freq(freq:uint64; clk:Tsi5351_clock);
 *
 * Uses SI5351_PLL_FIXED (900 MHz) for PLLA.
 * All multisynths are assigned to PLLA using this function.
 * PLLA is set to 900 MHz.
 * Restricted to outputs from 1 to 150 MHz.
 * If you need frequencies outside that range, use set_pll()
 * and set_ms() to set the synth dividers manually.
 *
 * freq - Output frequency in Hz
 * clk - Clock output
 *   (use the Tsi5351_clock type)
 *}

procedure si5351_set_freq(freq:uint64; clk:Tsi5351_clock);
var
     pll_frac, ms_frac : TSi5351Frac;
begin
	// Lower bounds check
	if(freq < SI5351_MULTISYNTH_MIN_FREQ) then
		freq := SI5351_MULTISYNTH_MIN_FREQ;
	// Upper bounds check
	if(freq > SI5351_MULTISYNTH_DIVBY4_FREQ) then
		freq := SI5351_MULTISYNTH_DIVBY4_FREQ;
	// Set the PLL
	pll_frac.a := uint16(SI5351_PLL_FIXED div xtal_freq);
	if (ref_correction < 0) then
		pll_frac.b := uint32((pll_frac.a * uint32(ref_correction * -1)) div 10)
	else
            begin
		pll_frac.b := 1000000 - uint32((pll_frac.a * uint32(ref_correction)) div 10);
		dec(pll_frac.a);
            end;

	pll_frac.c := 1000000;
	si5351_set_pll(pll_frac, SI5351_PLLA);

	// Set the MS
	ms_frac.a := uint16(SI5351_PLL_FIXED div freq);
	ms_frac.b := uint32(((SI5351_PLL_FIXED MOD freq) * 1000000) div freq);
	ms_frac.c := 1000000;
	si5351_set_ms(clk, ms_frac, 0, SI5351_OUTPUT_CLK_DIV_1, 0);
end;

{*
 * si5351_set_ms(clk : Tsi5351_clock ; frac:TSi5351Frac ; int_mode : uint8 ; r_div : uint8 ; div_by_4 : uint8 );
 *
 * Set the specified multisynth parameters.
 *
 * clk - Clock output
 *   (use the Tsi5351_clock type)
 * frac - Synth fractional divider values
 * int_mode - Set integer mode
 *  Set to 1 to enable, 0 to disable
 * r_div - Desired r_div ratio
 * div_by_4 - Set Divide By 4 mode
 *   Set to 1 to enable, 0 to disable
 *}

procedure si5351_set_ms(clk : Tsi5351_clock ; frac:TSi5351Frac ; int_mode : uint8 ; r_div : uint8 ; div_by_4 : uint8 );
var
        ms_reg  : TSi5351RegSet             ;
        params  : array of byte             ;
        i       : byte = 0                  ;
        temp    : byte                      ;
        reg_val : byte                      ;
begin
  {$PUSH}
  {$WARN 5091 off : Local variable "$1" of a managed type does not seem to be initialized}
        setlength(params,8);
  {$POP}
	// Calculate parameters
	if (div_by_4 = 1) then
        begin
		ms_reg.p3 := 1;
		ms_reg.p2 := 0;
		ms_reg.p1 := 0;
	end
	else
	begin
        {$PUSH}
        {$WARN 4081 off : Converting the operands to "$1" before doing the multiply could prevent overflow errors.}
        {$WARN 4079 off : Converting the operands to "$1" before doing the add could prevent overflow errors.}
		ms_reg.p1 := (128 * frac.a) + ((128 * frac.b) DIV frac.c) - 512;
		ms_reg.p2 := (128 * frac.b) - (frac.c * ((128 * frac.b) DIV frac.c));
		ms_reg.p3 := frac.c;
        {$POP}
        end;

	// Registers 42-43 for CLK0
	temp := uint8((ms_reg.p3 >> 8) AND $FF);
	params[i] := temp;
        inc(i);

	temp := uint8(ms_reg.p3 AND $FF);
	params[i] := temp;
        inc(i);

        // debug test registre 16
        temp:=si5351_read(16, reg_val);
	// Register 44 for CLK0
	si5351_read((SI5351_CLK0_PARAMETERS + 2) + (uint8(clk) * 8), reg_val);
	reg_val := reg_val and not($03);
	temp := reg_val OR (uint8((ms_reg.p1 >> 16) AND $03));
	params[i] := temp;
        inc(i);

	// Registers 45-46 for CLK0
	temp := uint8((ms_reg.p1 >> 8) AND $FF);
	params[i] := temp;
        inc(i);

	temp := uint8(ms_reg.p1 AND $FF);
	params[i] := temp;
        inc(i);

	// Register 47 for CLK0
	temp := uint8((ms_reg.p3 >> 12) and $F0);
	temp := temp + uint8((ms_reg.p2 >> 16) and $0F);
	params[i] := temp;
        inc(i);

	// Registers 48-49 for CLK0
	temp := uint8((ms_reg.p2 >> 8) and $FF);
	params[i] := temp;
        inc(i);

	temp := uint8(ms_reg.p2 and $FF);
	params[i] := temp;
        inc(i);

	// Write the parameters
	case (clk) of
	          SI5351_CLK0:
			si5351_write_bulk(SI5351_CLK0_PARAMETERS, i, params);
		  SI5351_CLK1:
			si5351_write_bulk(SI5351_CLK1_PARAMETERS, i, params);
		  SI5351_CLK2:
			si5351_write_bulk(SI5351_CLK2_PARAMETERS, i, params);
		  SI5351_CLK3:
			si5351_write_bulk(SI5351_CLK3_PARAMETERS, i, params);
		  SI5351_CLK4:
			si5351_write_bulk(SI5351_CLK4_PARAMETERS, i, params);
		  SI5351_CLK5:
			si5351_write_bulk(SI5351_CLK5_PARAMETERS, i, params);
		  SI5351_CLK6:
			si5351_write_bulk(SI5351_CLK6_PARAMETERS, i, params);
		  SI5351_CLK7:
			si5351_write_bulk(SI5351_CLK7_PARAMETERS, i, params);
	end;

	si5351_set_int(clk, int_mode);
	si5351_set_ms_div(clk, r_div, div_by_4);
end;


procedure si5351_set_ms_div(clk : Tsi5351_clock ; r_div : uint8 ; div_by_4 : uint8 );
var
        reg_val : uint8 = 0 ;
        reg_addr: uint8 = 0 ;
begin
	case (clk) of
		SI5351_CLK0:
			reg_addr := SI5351_CLK0_PARAMETERS + 2;
		SI5351_CLK1:
			reg_addr := SI5351_CLK1_PARAMETERS + 2;
		SI5351_CLK2:
			reg_addr := SI5351_CLK2_PARAMETERS + 2;
		SI5351_CLK3:
			reg_addr := SI5351_CLK3_PARAMETERS + 2;
		SI5351_CLK4:
			reg_addr := SI5351_CLK4_PARAMETERS + 2;
		SI5351_CLK5:
			reg_addr := SI5351_CLK5_PARAMETERS + 2;
		SI5351_CLK6:
			reg_addr := SI5351_CLK6_PARAMETERS + 2;
		SI5351_CLK7:
			reg_addr := SI5351_CLK7_PARAMETERS + 2;
	end;



	// Clear the relevant bits
	reg_val := reg_val and $7c;

	if (div_by_4 = 0) then
		reg_val := reg_val and SI5351_OUTPUT_CLK_DIVBY4
	else
		reg_val := reg_val or SI5351_OUTPUT_CLK_DIVBY4;

	reg_val := reg_val or (r_div << SI5351_OUTPUT_CLK_DIV_SHIFT);

	si5351_write(reg_addr, reg_val);
end;

{*
 * si5351_set_int(clk : Tsi5351_clock ; enable : uint8);
 *
 * clk - Clock output
 *   (use the Tsi5351_clock type)
 * enable - Set to 1 to enable, 0 to disable
 *
 * Set the indicated multisynth into integer mode.
 *}

procedure si5351_set_int(clk : Tsi5351_clock ; enable : uint8 );
var
        reg_val : uint8 ;
begin
	si5351_read(SI5351_CLK0_CTRL + uint8(clk), reg_val);

	if (enable = 1) then
		reg_val := reg_val or SI5351_CLK_INTEGER_MODE
	else
		reg_val := reg_val and not(SI5351_CLK_INTEGER_MODE);

	si5351_write(SI5351_CLK0_CTRL + uint8(clk), reg_val);
end;

{*
 * si5351_pll_reset(target_pll:Tsi5351_pll;)
 *
 * target_pll - Which PLL to reset
 *     (use the Tsi5351_pll type)
 *
 * Apply a reset to the indicated PLL.
 *}

procedure si5351_pll_reset(target_pll:Tsi5351_pll );
begin
  if(target_pll = SI5351_PLLA) then
    	si5351_write(SI5351_PLL_RESET_REG, SI5351_PLL_RESET_A)
	else
          if(target_pll = SI5351_PLLB) then
	    si5351_write(SI5351_PLL_RESET_REG, SI5351_PLL_RESET_B);
end;

{*
 * si5351_output_enable(clk : Tsi5351_clock ; enable : uint8);
 *
 * Enable or disable a chosen clock
 * clk - Clock output
 *   (use the Tsi5351_clock type)
 * enable - Set to 1 to enable, 0 to disable
 *}

procedure si5351_output_enable( clk : Tsi5351_clock ; enable : uint8);
var
        reg_val : uint8 ;
begin
        si5351_read(SI5351_OUTPUT_ENABLE_CTRL, reg_val);
	if (enable = 1) then
		reg_val := reg_val and not(1<<uint8(clk))
	else
		reg_val := reg_val or (1<<uint8(clk));

	si5351_write(SI5351_OUTPUT_ENABLE_CTRL, reg_val);
end;

{*
 * si5351_drive_strength(clk : Tsi5351_clock ; drive : Tsi5351_drive );
 *
 * Sets the drive strength of the specified clock output
 *
 * clk - Clock output
 *   (use the Tsi5351_clock type)
 * drive - Desired drive level
 *   (use the Tsi5351_drive type)
 *}

procedure si5351_drive_strength(clk : Tsi5351_clock ; drive : Tsi5351_drive );
var
        reg_val : uint8      ;
        mask    : uint8 = $03;
begin
        si5351_read(SI5351_CLK0_CTRL + uint8(clk), reg_val);
        reg_val := reg_val and not(mask);

	case (drive) of

	SI5351_DRIVE_2MA: reg_val := reg_val or $00;
        SI5351_DRIVE_4MA: reg_val := reg_val or $01;
        SI5351_DRIVE_6MA: reg_val := reg_val or $02;
        SI5351_DRIVE_8MA: reg_val := reg_val or $03;
	end;

	si5351_write(SI5351_CLK0_CTRL + uint8(clk), reg_val);
end;

{*
 * si5351_set_clock_invert(clk: Tsi5351_clock ; inv: uint8 );
 *
 * clk - Clock output
 *   (use the Tsi5351_clock type)
 * inv - Set to 1 to enable, 0 to disable
 *
 * Enable to invert the clock output waveform.
 *}

procedure si5351_set_clock_invert( clk: Tsi5351_clock ; inv: uint8 );
	var
          reg_val : uint8 ;
begin
	si5351_read(SI5351_CLK0_CTRL + uint8(clk), reg_val);

	if (inv = 1) then reg_val := reg_val or SI5351_CLK_INVERT
	else reg_val := reg_val and not(SI5351_CLK_INVERT);
	si5351_write(SI5351_CLK0_CTRL + uint8(clk), reg_val);
end;

{*
 * si5351_set_clock_disable(enum si5351_clock clk, enum si5351_clock_disable dis_state)
 *
 * clk - Clock output
 *   (use the Tsi5351_clock type)
 * dis_state - Desired state of the output upon disable
 *   (use the Tsi5351_clock_disable type)
 *
 * Set the state of the clock output when it is disabled. Per page 27
 * of AN619 (Registers 24 and 25), there are four possible values: low,
 * high, high impedance, and never disabled.
 *}

procedure si5351_set_clock_disable( clk: Tsi5351_clock ; dis_state: Tsi5351_clock_disable );
	var
           reg_val, reg : uint8 ;
begin
	if ((clk >= SI5351_CLK0) and (clk <= SI5351_CLK3)) then reg := SI5351_CLK3_0_DISABLE_STATE
	else
            if ((clk >= SI5351_CLK0) and (clk <= SI5351_CLK3)) then reg := SI5351_CLK7_4_DISABLE_STATE;

	si5351_read(reg, reg_val);

	if ((clk >= SI5351_CLK0) and (clk <= SI5351_CLK3)) then
        begin
		reg_val := reg_val and not(3 << (uint8(clk) * 2));
		reg_val := reg_val or (uint8(dis_state) << (uint8(clk) * 2));
	end
	else
            if ((clk >= SI5351_CLK0) and (clk <= SI5351_CLK3)) then
            begin
		reg_val :=reg_val and not(3 << ((uint8(clk) - 4) * 2));
		reg_val :=reg_val or (uint8(dis_state) << ((uint8(clk) - 4) * 2));
            end;

	si5351_write(reg, reg_val);
end;

function si5351_write(addr:byte;data:byte):byte;
begin
    setlength(msg,2);
    msg[0]:=addr;
    msg[1]:=data;
    si5351_write:=i2c_write_timeout_us(i2c0inst,SI5351_BUS_BASE_ADDR,msg,2,false,1000);
end;

function si5351_write_bulk(addr:byte;len:byte;var data:array of byte):byte;
var
  i : integer;
begin
    setlength(msg,len+1);
    msg[0]:=addr;
    for i:=0 to len do
        msg[i+1]:=data[i];
    si5351_write_bulk:=i2c_write_timeout_us(i2c0inst,SI5351_BUS_BASE_ADDR,msg,len+1,false,1000);
end;

function si5351_read(addr:byte;out data_value:byte):byte;
var
  msg        : array of byte;
  ret_value  : byte         ;
begin
    {$PUSH}
    {$WARN 5091 off : Local variable "$1" of a managed type does not seem to be initialized}
    setlength(msg,1);
    {$POP}
    msg[0]:=addr;
    i2c_write_blocking(i2c0inst,SI5351_BUS_BASE_ADDR,msg,1,false);
    ret_value:=i2c_read_timeout_us(i2c0inst,SI5351_BUS_BASE_ADDR,msg,1,false,1000);
    data_value:=msg[0];
    si5351_read:=ret_value;
end;

end.

