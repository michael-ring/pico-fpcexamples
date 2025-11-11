program dma_memory_transfer;

{$MODE OBJFPC}
{$MEMORY 4096,4096}

uses
    pico_c,
    pico_dma_c;

// this example show how to transfer data from read_zone array
// to write_zone array with DMA

var
   config     : uint32;
   read_zone  : array[0..4] of byte = (1,2,3,4,5);
   write_zone : array[0..4] of byte = (0,0,0,0,0);
   i : integer;

begin
  for i:=0 to 4 do
      write_zone[i]:=0;
  config:= dma_channel_get_default_config(DMA_CHANNEL0);
  DMA.ch[DMA_CHANNEL0].al1_ctrl:=config;                        // set default config
  dma_set_transfer_data_size(DMA_CHANNEL0,DMA_SIZE_8);          // set word size
  dma_set_read_increment(DMA_CHANNEL0,true);                    // set auto increment for reading
  dma_set_write_increment(DMA_CHANNEL0,true);                   // set auto increment for writing
  dma_set_read_address(DMA_CHANNEL0,@read_zone);                // set read address
  dma_set_write_address(DMA_CHANNEL0,@write_zone);              // set write address
  dma_set_count_of(DMA_CHANNEL0,SizeOf(read_zone));             // set number of byte to transfer and start DMA

  while True do;                                                // Transfer is done
end.

