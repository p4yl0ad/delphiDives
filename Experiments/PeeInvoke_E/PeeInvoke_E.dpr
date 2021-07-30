program PeeInvoke_E;
{$APPTYPE CONSOLE}

{$R *.res}

{
http://docwiki.embarcadero.com/RADStudio/Sydney/en/Using_Inline_Assembly_Code
https://jhalon.github.io/utilizing-syscalls-in-csharp-1/
https://github.com/hfiref0x/SyscallTables/blob/master/Binary/syscalls.md
https://gist.github.com/michel-pi/6faf624ae843c6d3f381d4f913f79fd4
https://www.evilsocket.net/2014/02/11/On-Windows-syscall-mechanism-and-syscall-numbers-extraction-methods/
}

//NtCreateFile
{
  mov r10,rcx
  mov eax,55h
  syscall
  ret
}
//function BasicInlineAsm(): boolean;
//asm
//  mov r10,rcx
//  mov eax,55h
//  syscall
//  ret
//end;


//https://www.unknowncheats.me/forum/general-programming-and-reversing/455993-concealing-invoking-messagebox-library-user32-dll.html


//http://undocumented.ntinternals.net/index.html?page=UserMode%2FUndocumented%20Functions%2FError%2FNtRaiseHardError.html
//https://gist.github.com/michel-pi/6faf624ae843c6d3f381d4f913f79fd4
//https://offensivedefence.co.uk/posts/dinvoke-syscalls/

{
Pseudocode

load ntdll.dll //https://stackoverflow.com/questions/49207263/c-sharp-how-to-p-invoke-ntraiseharderror

[DllImport("ntdll.dll")]
private static extern uint NtRaiseHardError(
    uint ErrorStatus,
    uint NumberOfParameters,
    uint UnicodeStringParameterMask,
    IntPtr Parameters,
    uint ValidResponseOption,
    out uint Response
);

}

//https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-erref/596a1078-e883-4972-9bbc-49e60bebca55
//STATUS_SUCCESS
//ErrorStatus := $00000000

//https://www.drbob42.com/Delphi/headconv.htm
//implicit linking
//Explicit linking


//https://stackoverflow.com/questions/49207263/c-sharp-how-to-p-invoke-ntraiseharderror


uses
  SysUtils,
  Windows;

function ntRaiseHardError_MsgBox(
  ARegNo: integer;
  APrinterID: integer;
  ASlipNo: integer) : string; stdcall;


function LoadAndFind(libtofind: PWideChar ): Pointer;
var
  lib : THandle;
  ntrhe : Pointer;

begin
  lib := LoadLibrary(libtofind);
  if (lib <> 0) then begin
    ntrhe := GetProcAddress(lib,'NtRaiseHardError');
    WriteLn(Format('[+] NtRaiseHardError base address: %p',[ntrhe]));
    Result := ntrhe;
  end;
end;

function ConstructMessage(amessage, acaption: string): Boolean;
var
  atype: integer;

begin
  atype := 66;

end;



begin
var
  ntrheres : Pointer;

  try
    ntrheres := LoadAndFind('ntdll.dll');

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;
end.