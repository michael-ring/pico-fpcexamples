program gpio_irq;

{$MODE OBJFPC}
{$H+}
{$MEMORY 4096,4096}

// gpio IRQ demo
// jean-Pierre MANDON 2024
{
this is a demo of the use of IRQ on GPIO
signal on the GP16 pin is

+3.3V ___________        _______________
                 |      |
                 |      |
0V               |______|
                 <-  t ->

The goal is to measure the pulse width ( t ) with an accuracy of 100 µS
}

uses
    pico_c,
    pico_gpio_c,pico_timer_c,pico_irq_c;

const
    signalPin = TPicoPin.GP17;

var
    TimeEllapsed   : uint32=0       ;
    waitRisingEdge : boolean        ;
    pulseWidth     : uint32=0      ;

procedure IO_IRQ_BANK0_Handler; public name 'IO_IRQ_BANK0_Handler';
var
  event          : uint32         ;
begin
  // get event handler
  event:=gpio_get_irq_event_mask(signalPin);
  // acknowledge event
  gpio_acknowledge_irq(signalPin,event);
  // if event is falling edge
  if (event=uint32(TGPIO_IRQ_level.GPIO_IRQ_EDGE_FALL)) and (not waitRisingEdge) then
     begin
       // set interrupt on the next rising edge
       gpio_set_irq_enabled(signalPin,uint32(TGPIO_IRQ_level.GPIO_IRQ_EDGE_RISE),true);
       waitRisingEdge:=true;
     end;
  // if event is rising edge
  if (event=uint32(TGPIO_IRQ_level.GPIO_IRQ_EDGE_RISE)) and waitRisingEdge then
       begin
       // set interrupt on the next falling edge
       gpio_set_irq_enabled(signalPin,uint32(TGPIO_IRQ_level.GPIO_IRQ_EDGE_FALL),true);
       waitRisingEdge:=false;
       end;
end;


begin
    // init GPIO
    gpio_init(signalPin);
    gpio_set_dir(signalPin,TGPIO_Direction.GPIO_IN);
    gpio_pull_up(signalPin);
    // set IRQ enabled on signalPin and falling edge
    gpio_set_irq_enabled(signalPin,uint32(TGPIO_IRQ_level.GPIO_IRQ_EDGE_FALL),true);
    // enable GPIO IRQ
    irq_set_enabled(TIRQn_Enum.IO_IRQ_BANK0);
    while (true) do
          if waitRisingEdge then
               begin
               busy_wait_us(100);
               inc(TimeEllapsed);
               end
          else if TimeEllapsed<>0 then
                    begin
                    // pulseWidth variable is the last pulse width measured
                    pulseWidth:=TimeEllapsed;
                    TimeEllapsed:=0;
                    end;
end.

