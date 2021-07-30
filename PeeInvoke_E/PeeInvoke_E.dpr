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
//https://docs.microsoft.com/en-us/archive/msdn-magazine/2017/may/c-use-modern-c-to-access-the-windows-registry
//https://ros-diffs.reactos.narkive.com/wdRw0dFa/01-08-ntoskrnl-in-addition-to-the-hard-error-port-reference-also-the-process-that-handles-the-hard
//https://coderoad.ru/9897693/%D0%9A%D0%B0%D0%BA-%D0%BE%D1%82%D0%BE%D0%B1%D1%80%D0%B0%D0%B7%D0%B8%D1%82%D1%8C-%D0%B2%D1%81%D0%BF%D0%BB%D1%8B%D0%B2%D0%B0%D1%8E%D1%89%D0%B5%D0%B5-%D0%BE%D0%BA%D0%BD%D0%BE-%D1%81%D0%BE%D0%BE%D0%B1%D1%89%D0%B5%D0%BD%D0%B8%D1%8F-%D0%BE%D1%82-%D0%B4%D1%80%D0%B0%D0%B9%D0%B2%D0%B5%D1%80%D0%B0-%D1%80%D0%B5%D0%B6%D0%B8%D0%BC-kernel


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