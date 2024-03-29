// -------------------------------------------------- //
// This file is autogenerated by pioasm; do not edit! //
// -------------------------------------------------- //

// ----------- //
// apa102_mini //
// ----------- //

const apa102_mini_wrap_target=0;
const apa102_mini_wrap=1;

const apa102_mini_program_instructions : array [0..1] of word = (
           //     .wrap_target
    $6001, //  0: out    pins, 1         side 0     
    $b042  //  1: nop                    side 1     
           //     .wrap
);

const apa102_mini_program : Tpio_program = (
    instructions : @apa102_mini_program_instructions[0];
    length : 2;
    origin : -1;
);

function apa102_mini_program_get_default_config(offset : longWord):Tpio_sm_config;
begin
  Result := pio_get_default_sm_config();
  sm_config_set_wrap(Result, offset + apa102_mini_wrap_target, offset + apa102_mini_wrap);
  sm_config_set_sideset(Result, 1, false, false);
end;


procedure apa102_mini_program_init(var pio : TPIO_Registers;sm : longWord; offset : longWord;
        baud : longWord; pin_clk : longWord; pin_din : longWord);
var
  c : Tpio_sm_config;
  &div : real;
begin
  pio_sm_set_pins_with_mask(pio, sm, longword(-1), (1 shl pin_clk) or (1 shl pin_din));
  pio_sm_set_pindirs_with_mask(pio, sm, longword(-1), (1 shl pin_clk) or (1 shl pin_din));
  pio_gpio_init(pio, pin_clk);
  pio_gpio_init(pio, pin_din);
  c := apa102_mini_program_get_default_config(offset);
  sm_config_set_out_pins(c, pin_din, 1);
  sm_config_set_sideset_pins(c, pin_clk);
  // Shift to right, autopull with threshold 32
  sm_config_set_out_shift(c, false, true, 32);
  // Deeper FIFO as we're not doing any RX
  sm_config_set_fifo_join(c, PIO_FIFO_JOIN_TX);
  // We transmit 1 bit every 2 execution cycles
  &div := clock_get_hz(clk_sys) / (2 * baud);
  sm_config_set_clkdiv(c, &div);
  pio_sm_init(pio, sm, offset, c);
  pio_sm_set_enabled(pio, sm, true);
end;


// ------------- //
// apa102_rgb555 //
// ------------- //

const apa102_rgb555_wrap_target=0;
const apa102_rgb555_wrap=14;

const apa102_rgb555_offset_pixel_out=0;
const apa102_rgb555_offset_bit_run=9;

const apa102_rgb555_program_instructions : array [0..14] of word = (
           //     .wrap_target
    $80e0, //  0: pull   ifempty block              
    $e022, //  1: set    x, 2                       
    $40e5, //  2: in     osr, 5                     
    $6065, //  3: out    null, 5                    
    $4063, //  4: in     null, 3                    
    $0042, //  5: jmp    x--, 2                     
    $4048, //  6: in     y, 8                       
    $a0d6, //  7: mov    isr, ::isr                 
    $6061, //  8: out    null, 1                    
    $e03f, //  9: set    x, 31                      
    $e000, // 10: set    pins, 0                    
    $a606, // 11: mov    pins, isr              [6] 
    $e001, // 12: set    pins, 1                    
    $46c1, // 13: in     isr, 1                 [6] 
    $004a  // 14: jmp    x--, 10                    
           //     .wrap
);

const apa102_rgb555_program : Tpio_program = (
    instructions : @apa102_rgb555_program_instructions[0];
    length : 15;
    origin : -1;
);

function apa102_rgb555_program_get_default_config(offset : longWord):Tpio_sm_config;
begin
  Result := pio_get_default_sm_config();
  sm_config_set_wrap(Result, offset + apa102_rgb555_wrap_target, offset + apa102_rgb555_wrap);
end;
