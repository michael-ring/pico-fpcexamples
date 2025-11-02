unit pico_semaphore;

{$mode ObjFPC}{$H+}

interface

uses
  pico_c;

type
    semDataArray = array[0..19] of uint32;

{$L multicore_sync.c.obj}
{$L sem.c.obj}
{$L critical_section.c.obj}
{$L lock_core.c.obj}
{$L mutex.c.obj}


procedure write_data_with_sem(dataIn:array of uint32);cdecl;external;

function read_data_with_sem:semDataArray;cdecl;external;

implementation

end.

