program Blinky;
{$L platform.c.obj}
{$L gpio.c.obj}
{$L clocks.c.obj}
{$L xosc.c.obj}
{$L pll.c.obj}
{$L watchdog.c.obj}
{$LinkLib gcc,static}

procedure clocks_init; external;
procedure gpio_init(gpio : longWord); external;

procedure runtime_init;
const
  RESETS_SAFE_BITS=     %1111111111100110110111111;
  RESETS_PRECLOCK_BITS= %0001111000100110110111110;
  RESETS_POSTCLOCK_BITS=%1110000111000000000000001;
begin
  resets.reset_set := RESETS_SAFE_BITS;
  resets.reset_clr := RESETS_PRECLOCK_BITS;
  repeat
  until (resets.reset_done and RESETS_PRECLOCK_BITS) = RESETS_PRECLOCK_BITS;
  clocks_init;
  resets.reset_clr := RESETS_POSTCLOCK_BITS;
  repeat
  until (resets.reset_done and RESETS_POSTCLOCK_BITS) = RESETS_POSTCLOCK_BITS;
end;

procedure gpio_set_dir(gpio : longWord; &out : longbool);
var
  mask : longWord;
begin
  mask := 1 shl  gpio;
  if out = true then
    sio.gpio_oe_set := mask
  else
    sio.gpio_oe_clr := mask;
end;

procedure gpio_put(gpio : longWord; value : boolean);
var
  mask : longWord;
begin
  mask := 1 shl gpio;
  if value=true then
    sio.gpio_set := mask
  else
    sio.gpio_clr := mask;
end;

const
  LED_PIN=25;
  GPIO_OUT=true;
var
  i : longWord;
begin
  runtime_init;
  gpio_init(LED_PIN);
  gpio_set_dir(LED_PIN,GPIO_OUT);
  repeat
    gpio_put(LED_PIN,true);
    for i := 0 to 3000000 do ;
    gpio_put(LED_PIN,false);
    for i := 0 to 3000000 do ;
  until 1=0;
end.
