program BasedAmsi_E;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  //Vcl.Controls,
  Windows,
  Vcl.Forms;

var
  HDLLInst : THandle;


{https://github.com/rasta-mouse/AmsiScanBufferBypass/blob/main/AmsiBypass.cs}

begin
  try
    // Load amsi.dll , find AmsiScanBuffer
    HDLLInst := SafeLoadLibrary('C:\\Windows\\System32\\amsi.dll');
    WriteLn(
      Format(
        'amsi.dll base address: %p',[GetProcAddress(HDLLInst,'AmsiScanBuffer')]
      )
    );
    FreeLibrary (HDLLInst);



    //WriteLn(IntToHex (DWORD ( GetProcAddress (GetModuleHandle ('amsi.dll'), 'MessageBoxA')), 8));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
