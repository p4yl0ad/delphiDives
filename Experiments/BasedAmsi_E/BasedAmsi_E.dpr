program BasedAmsi_E;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Vcl.Controls,
  Windows,
  Math,
  Vcl.Forms;

var
  HDLLInst : THandle;
  Addy : pointer;


begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    HDLLInst := SafeLoadLibrary ('amsi.dll');
    Addy := GetProcAddress (HDLLInst, 'SetData');

    WriteLn(Format ('Address: %p', [
    GetProcAddress (HDLLInst, 'SetData')]));

    //WriteLn(Format ('Address: %p',  Addy));
    FreeLibrary (HDLLInst);



    WriteLn(IntToHex (DWORD ( GetProcAddress (GetModuleHandle ('amsi.dll'), 'MessageBoxA')), 8));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
