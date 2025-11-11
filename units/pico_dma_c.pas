unit pico_dma_c;

{$mode ObjFPC}{$H+}


interface

uses
  SysUtils;

{$IF DEFINED(DEBUG)}
{$L __noinline__dma.c-debug.obj }
{$L dma.c-debug.obj}
{$ELSE}
{$L __noinline__dma.c.obj }
{$L dma.c.obj}
{$ENDIF}

type
  dreq_num_rp2040 =  (
     DREQ_PIO0_TX0 = 0,
     DREQ_PIO0_TX1 = 1,
     DREQ_PIO0_TX2 = 2,
     DREQ_PIO0_TX3 = 3,
     DREQ_PIO0_RX0 = 4,
     DREQ_PIO0_RX1 = 5,
     DREQ_PIO0_RX2 = 6,
     DREQ_PIO0_RX3 = 7,
     DREQ_PIO1_TX0 = 8,
     DREQ_PIO1_TX1 = 9,
     DREQ_PIO1_TX2 = 10,
     DREQ_PIO1_TX3 = 11,
     DREQ_PIO1_RX0 = 12,
     DREQ_PIO1_RX1 = 13,
     DREQ_PIO1_RX2 = 14,
     DREQ_PIO1_RX3 = 15,
     DREQ_SPI0_TX = 16,
     DREQ_SPI0_RX = 17,
     DREQ_SPI1_TX = 18,
     DREQ_SPI1_RX = 19,
     DREQ_UART0_TX = 20,
     DREQ_UART0_RX = 21,
     DREQ_UART1_TX = 22,
     DREQ_UART1_RX = 23,
     DREQ_PWM_WRAP0 = 24,
     DREQ_PWM_WRAP1 = 25,
     DREQ_PWM_WRAP2 = 26,
     DREQ_PWM_WRAP3 = 27,
     DREQ_PWM_WRAP4 = 28,
     DREQ_PWM_WRAP5 = 29,
     DREQ_PWM_WRAP6 = 30,
     DREQ_PWM_WRAP7 = 31,
     DREQ_I2C0_TX = 32,
     DREQ_I2C0_RX = 33,
     DREQ_I2C1_TX = 34,
     DREQ_I2C1_RX = 35,
     DREQ_ADC = 36,
     DREQ_XIP_STREAM = 37,
     DREQ_XIP_SSITX = 38,
     DREQ_XIP_SSIRX = 39,
     DREQ_DMA_TIMER0 = 59,
     DREQ_DMA_TIMER1 = 60,
     DREQ_DMA_TIMER2 = 61,
     DREQ_DMA_TIMER3 = 62,
     DREQ_FORCE = 63,
     DREQ_COUNT );

  dma_address_update_type = (
     DMA_ADDRESS_UPDATE_NONE = 0,
     DMA_ADDRESS_UPDATE_INCREMENT = 1 );

const
  DMA_SIZE_8 = 0;
  DMA_SIZE_16 = 1;
  DMA_SIZE_32 = 2;

  DMA_CHANNEL0 = 0;
  DMA_CHANNEL1 = 1;
  DMA_CHANNEL2 = 2;
  DMA_CHANNEL3 = 3;
  DMA_CHANNEL4 = 4;
  DMA_CHANNEL5 = 5;
  DMA_CHANNEL6 = 6;
  DMA_CHANNEL7 = 7;
  DMA_CHANNEL8 = 8;
  DMA_CHANNEL9 = 9;
  DMA_CHANNEL10 = 10;
  DMA_CHANNEL11 = 11;

var
  dma_reload_count_to : array[0..11] of uint32;

// Mark a dma channel as used.
procedure dma_channel_claim(channel : byte); cdecl; external;

// Mark multiple dma channels as used.
procedure dma_claim_mask (channel_mask : uint32); cdecl; external;

// Mark a dma channel as used.
procedure dma_channel_unclaim(channel : byte); cdecl; external;

// Mark multiple dma channels as no longer used.
procedure dma_unclaim_mask (channel_mask : uint32); cdecl; external;

// Claim a free dma channel.
function dma_claim_unused_channel (required : boolean):byte; cdecl; external;

// Determine if a dma channel is claimed.
function dma_channel_is_claimed(channel : byte):boolean; cdecl; external;

// get dma channel default configuration ( inline function )
function __noinline__dma_channel_get_default_config(channel : byte):uint32; cdecl; external;
function dma_channel_get_default_config(channel : byte):uint32;

//set a channel configuration
procedure dma_channel_set_config (channel:byte ;var dma_channel_config : uint32 ; trigger : boolean); cdecl; external;

// Set the DMA initial read address.
procedure dma_channel_set_read_addr (channel : byte ; const read_addr : array of uint32 ;  trigger : boolean); cdecl; external;

// Set the DMA initial write address.
procedure dma_channel_set_write_addr (channel : byte ; const write_addr : array of uint32 ;  trigger : boolean); cdecl; external;

// Encode the specified transfer length into an "encoded_transfer_length" value suitable for the referenced methods.
function dma_encode_transfer_count (transfer_count : byte):uint32; cdecl; external;

// Encode the specified transfer length, along with a flag to indicate the DMA transfer should be self-triggering,
// into an "encoded_transfer_length" value suitable for the referenced methods.
function dma_encode_transfer_count_with_self_trigger (transfer_count : byte):uint32; cdecl; external;

// Return an endless transfer as an "encoded_transfer_length" value suitable for the referenced methods.
function dma_encode_endless_transfer_count:uint32; cdecl; external;

// Set the number of bus transfers the channel will do.
procedure dma_channel_set_transfer_count (channel:byte; encoded_transfer_count:uint32; trigger:boolean); cdecl; external;

// Configure all DMA parameters and optionally start transfer.
procedure dma_channel_configure (channel:byte; var dma_channel_config : uint32 ; const write_addr : array of uint32 ; const read_addr : array of uint32 ; encoded_transfer_count:uint32; trigger:boolean ); cdecl; external;

// Start a DMA transfer from a buffer immediately.
procedure dma_channel_transfer_from_buffer_now (channel:byte; const read_addr : array of uint32 ; encoded_transfer_count:uint32); cdecl; external;

// Start a DMA transfer to a buffer immediately.
procedure dma_channel_transfer_to_buffer_now (channel:byte; const write_addr : array of uint32 ; encoded_transfer_count:uint32); cdecl; external;

// Start one or more channels simultaneously.
procedure  dma_start_channel_mask (chan_mask:uint32); cdecl; external;

// Start a single DMA channel.
procedure dma_channel_start (channel:byte); cdecl; external;

// Stop a DMA transfer.
procedure dma_channel_abort (channel:byte); cdecl; external;

// Enable single DMA channel’s interrupt via DMA_IRQ_0.
procedure dma_channel_set_irq0_enabled (channel:byte;enabled:boolean); cdecl; external;

// Enable multiple DMA channels' interrupts via DMA_IRQ_0.
procedure  dma_set_irq0_channel_mask_enabled (chan_mask:uint32; enabled:boolean); cdecl; external;

// Enable single DMA channel’s interrupt via DMA_IRQ_1.
procedure dma_channel_set_irq1_enabled (channel:byte;enabled:boolean); cdecl; external;

// Enable multiple DMA channels' interrupts via DMA_IRQ_1.
procedure dma_set_irq1_channel_mask_enabled (chan_mask:uint32; enabled:boolean); cdecl; external;

// Enable single DMA channel interrupt on either DMA_IRQ_0 or DMA_IRQ_1.
procedure dma_irqn_set_channel_enabled (irq_index:byte; channel:byte; enabled:boolean); cdecl; external;

// Enable multiple DMA channels' interrupt via either DMA_IRQ_0 or DMA_IRQ_1.
procedure dma_irqn_set_channel_mask_enabled (irq_index:byte; chan_mask:uint32; enabled:boolean); cdecl; external;

// Determine if a particular channel is a cause of DMA_IRQ_0.
function dma_channel_get_irq0_status (channel:byte):boolean; cdecl; external;

// Determine if a particular channel is a cause of DMA_IRQ_1.
function dma_channel_get_irq1_status (channel:byte):boolean; cdecl; external;

// Determine if a particular channel is a cause of DMA_IRQ_N.
function dma_irqn_get_channel_status (irq_index:byte; channel:byte):boolean; cdecl; external;

// Acknowledge a channel IRQ, resetting it as the cause of DMA_IRQ_0.
procedure dma_channel_acknowledge_irq0 (channel:byte); cdecl; external;

// Acknowledge a channel IRQ, resetting it as the cause of DMA_IRQ_1.
procedure dma_channel_acknowledge_irq1 (channel:byte); cdecl; external;

// Acknowledge a channel IRQ, resetting it as the cause of DMA_IRQ_N.
procedure  dma_irqn_acknowledge_channel (irq_index:byte; channel:byte); cdecl; external;

// Check if DMA channel is busy.
function dma_channel_is_busy (channel:byte):boolean; cdecl; external;

// Wait for a DMA channel transfer to complete.
procedure  dma_channel_wait_for_finish_blocking (channel:byte); cdecl; external;

// Enable the DMA sniffing targeting the specified channel.
procedure dma_sniffer_enable (channel:byte; mode:byte; force_channel_enable:boolean); cdecl; external;

// Enable the Sniffer byte swap function.
procedure  dma_sniffer_set_byte_swap_enabled (swap:boolean); cdecl; external;

// Enable the Sniffer output invert function.
procedure  dma_sniffer_set_output_invert_enabled (invert:boolean); cdecl; external;

// Enable the Sniffer output bit reversal function.
procedure  dma_sniffer_set_output_reverse_enabled (reverse:boolean); cdecl; external;

// Disable the DMA sniffer.
procedure  dma_sniffer_disable; cdecl; external;

// Set the sniffer’s data accumulator with initial value.
procedure dma_sniffer_set_data_accumulator (seed_value:uint32); cdecl; external;

// Get the sniffer’s data accumulator value.
function dma_sniffer_get_data_accumulator:uint32; cdecl; external;

// Mark a dma timer as used.
procedure dma_timer_claim (timer:byte); cdecl; external;

// Mark a dma timer as no longer used.
procedure dma_timer_unclaim (timer:byte); cdecl; external;

// Claim a free dma timer.
function dma_claim_unused_timer (required:boolean):integer; cdecl; external;

// Determine if a dma timer is claimed.
function dma_timer_is_claimed (timer:byte):boolean; cdecl; external;

// Set the multiplier for the given DMA timer.
procedure dma_timer_set_fraction (timer:byte; numerator:uint16; denominator:uint16 ); cdecl; external;

// Return the DREQ number for a given DMA timer.
function dma_get_timer_dreq (timer_num:byte):byte; cdecl; external;

// Return DMA_IRQ_<irqn>
function dma_get_irq_num (irq_index:byte):byte; cdecl; external;

// Performs DMA channel cleanup after use.
procedure dma_channel_cleanup (channel:byte); cdecl; external;

// DMA registers configuration

    // set DMA transfer size
    procedure dma_set_transfer_data_size(channel:byte; size : byte);

    // set auto increment on read buffer
    procedure dma_set_read_increment(channel:byte; state:boolean);

    // set auto increment on write buffer
    procedure dma_set_write_increment(channel:byte; state:boolean);

    // set initial write address
    procedure dma_set_write_address(channel:byte; address:pointer);

    // set initial read address
    procedure dma_set_read_address(channel:byte; address: pointer);

    // set size of transfer
    procedure dma_set_count_of(channel:byte; count:uint32);

    // define CHAIN_TO channel
    procedure dma_chain_to(channel:byte; chain_to_channel:byte);

implementation

function dma_channel_get_default_config(channel : byte):uint32;
begin
  result:=__noinline__dma_channel_get_default_config(channel);
end;

procedure dma_set_transfer_data_size(channel:byte; size : byte);
begin
  DMA.ch[channel].al1_ctrl:=(DMA.ch[channel].al1_ctrl and $fffffff3) or (size << 2);
end;

procedure dma_set_read_increment(channel:byte; state:boolean);
begin
  if state then
     DMA.ch[channel].al1_ctrl:=(DMA.ch[channel].al1_ctrl and ($ffffffff-16)) or (1 << 4)
  else
     DMA.ch[channel].al1_ctrl:=(DMA.ch[channel].al1_ctrl and ($ffffffff-16));
end;

procedure dma_set_write_increment(channel:byte; state:boolean);
begin
  if state then
     DMA.ch[channel].al1_ctrl:=(DMA.ch[channel].al1_ctrl and ($ffffffff-32)) or (1 << 5)
  else
     DMA.ch[channel].al1_ctrl:=(DMA.ch[channel].al1_ctrl and ($ffffffff-32));
end;

procedure dma_set_write_address(channel:byte; address:pointer);
begin
  DMA.ch[channel].al1_write_addr:=uint32(address);
end;

procedure dma_set_read_address(channel:byte; address: pointer);
begin
  DMA.ch[channel].al1_read_addr := uint32(address);
end;

procedure dma_set_count_of(channel:byte; count:uint32);
begin
  DMA.ch[channel].al1_transfer_count_trig:=count;
  dma_reload_count_to[channel]:=count;
end;

procedure dma_chain_to(channel:byte; chain_to_channel:byte);
begin
  DMA.ch[channel].al1_ctrl:=(DMA.ch[channel].al1_ctrl and ($ffffffff-78)) or (chain_to_channel << 11);
end;

end.

