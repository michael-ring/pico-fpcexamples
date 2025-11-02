unit pico_system;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

var
  AICR               : uint32 absolute PPB_BASE+$0ED0C ;

procedure reboot();

implementation

procedure reboot;
begin
  AICR:=$5FA0004;
end;

end.

