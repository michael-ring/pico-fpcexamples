unit pico_dma_c;

{$mode ObjFPC}{$H+}





interface

uses
  Classes, SysUtils;

{$IF DEFINED(DEBUG)}
{$L __noinline__dma.c-debug.obj }
{$L dma.c-debug.obj}
{$ELSE}
{$L __noinline__dma.c.obj }
{$L dma.c.obj}
{$ENDIF}

const
  DMA_SIZE_8=0;
  DMA_SIZE_16=1;
  DMA_SIZE_32=2;


implementation

end.

