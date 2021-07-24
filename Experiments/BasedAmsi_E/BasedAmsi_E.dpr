program BasedAmsi_E;
{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  Vcl.Forms;

var
  amsee,kersee : THandle;
  amsibaseaddr, kernbaseaddr : pointer;

{http://docwiki.embarcadero.com/RADStudio/Sydney/en/Libraries_and_Packages_(Delphi)}
{https://github.com/rasta-mouse/AmsiScanBufferBypass/blob/main/AmsiBypass.cs}
//x86-64 ret 0xC3
//x86-64 patch 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3


begin
  try
    // Load amsi.dll , find AmsiScanBuffer
    amsee := SafeLoadLibrary('C:\\Windows\\System32\\amsi.dll');
    if amsee <> 0 then
    begin
      amsibaseaddr := GetProcAddress(amsee,'AmsiScanBuffer');
      WriteLn(Format('amsi.dll base address: %p',[amsibaseaddr]));
    end;

    kersee := SafeLoadLibrary('C:\\Windows\\System32\\kernel32.dll');
    if kersee <> 0 then
    begin
      kernbaseaddr := GetProcAddress(kersee,'GetProcAddress');
      WriteLn(Format('kernel32.dll base address: %p',[kernbaseaddr]));
    end

    else
    begin
    WriteLn('Failed to load');
    end


    //procedure VirtualProtect
    finally

      FreeLibrary(amsee);
    end;
    end.



    //WriteLn(IntToHex (DWORD ( GetProcAddress (GetModuleHandle ('amsi.dll'), 'MessageBoxA')), 8));
  //except
    //on E: Exception do
      //Writeln(E.ClassName, ': ', E.Message);
  //end;
//end.
