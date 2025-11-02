unit pico_watchdog_c;

{$mode ObjFPC}{$H+}

{$L watchdog.c.obj}

interface

uses
  pico_c;

{
 enable watchog with a period of delay_ms,
 watchdog is waiting during debug if PauseOnDebug is true
}
procedure watchdog_enable(delay_ms:longWord;PauseOnDebug:boolean);cdecl; external;

{
 reload the watchdog
}
procedure watchdog_update;cdecl;external;

{
 the result of function is true if a reset is due to the watchdog
}
function watchdog_caused_reboot:boolean;cdecl;external;

implementation

end.

