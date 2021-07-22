(******************************************************************************
*   CopyRight (c) By GanHuaXin 2002
*   All Right Reserved
*   Email : huiyugan@263.net
*   Date    :
*       New Develop   : 2002-x-x
*       Modified      : 2001-05-26
******************************************************************************)

unit untInjectCode;

interface

uses
  Windows, Sysutils;

function LoadDllToProcess(hProcess:Thandle;
                          strDllName:PChar;
                          var dllHandle:HModule):BOOL;
function UnLoadDllFromProcess(hProcess:THandle;
                              hLibModule: HModule;
                              var bOK:BOOL):BOOL;

implementation

type
  TLoadLibraryA = function (lpLibFileName: PAnsiChar): HMODULE; stdcall;
  TLoadInjectInfo = Record
    fnLoadLibraryA : TLoadLibraryA;
    szDllName : array[0..255] of AnsiChar;
    hDLL : HModule;
    InjectCode : array [0..99] of byte;
  end;
  PLoadInjectInfo = ^TLoadInjectInfo;

  TMessageBeep = function (uType: UINT): BOOL; stdcall;
  TFreeLibrary = function (hLibModule: HMODULE): BOOL; stdcall;
  TFreeInjectInfo = Record
    fnFreeLibrary : TFreeLibrary;
    hLibModule : HMODULE;
    fnMessageBeep : TMessageBeep;
    uBeep : UINT;
    InjectCode : array[0..99] of byte;
  end;
  PFreeInjectInfo = ^TFreeInjectInfo;

function RemoteLoadFunc(p : PLoadInjectInfo):DWORD;stdcall;
begin
  Result := DWORD(p.fnLoadLibraryA(p.szDllName));
end;

function RemoteFreeFunc(p : PFreeInjectInfo):DWORD;stdcall;
begin
  p.fnMessageBeep(p.uBeep);
  Result := DWORD(p.fnFreeLibrary(p.hLibModule));
end;

function LoadDllToProcess(hProcess:THandle;
                          strDllName:PChar;
                          var dllHandle:HModule):BOOL;
var
  pCode : ^Byte;
  i : Integer;
  InjectInfo : TLoadInjectInfo;
  pRemoteCode : PLoadInjectInfo;
  dwCount : DWORD;
  dwThreadID : DWORD;
  hThread : THandle;
  dwExitCode : DWORD;

begin
  result := TRUE;
  dllHandle := 0;
try
  pCode := Addr(RemoteLoadFunc);

  for i:=0 to SizeOf(InjectInfo.InjectCode) - 1 do begin
    InjectInfo.InjectCode[i] := pCode^;
    Inc(pCode);
  end;

  InjectInfo.fnLoadLibraryA := GetProcAddress(GetModuleHandle('Kernel32.dll'),
                                    'LoadLibraryA');
  for i:=0 to strlen(strDllName) do begin
    InjectInfo.szDllName[i] := strDllName[i];
  end;
  InjectInfo.szDllName[strlen(strDllName)] := Char(0);

  pRemoteCode := nil;
  pRemoteCode := VirtualAllocEx( hProcess,
                            nil,
                            SizeOf(TLoadInjectInfo),
                            MEM_COMMIT,
                            PAGE_EXECUTE_READWRITE);
  if (pRemoteCode = nil) then
    RaiseLastWin32Error;

  if not WriteProcessMemory(hProcess,
                            pRemoteCode,
                            @InjectInfo,
                            SizeOf(TLoadInjectInfo),
                            dwCount) then
    RaiseLastWin32Error;

  hThread := 0;
  hThread := CreateRemoteThread( hProcess,
                                nil,
                                0,
                                Addr(pRemoteCode^.InjectCode[0]),
                                pRemoteCode,
                                0,
                                dwThreadId);
  if hThread=0 then
    RaiseLastWin32Error;

  WaitForSingleObject(hThread, INFINITE);

  GetExitCodeThread(hThread, dwExitCode);

  dllHandle := dwExitCode;

  CloseHandle(hThread);
finally
  if Assigned(pRemoteCode) then
         VirtualFreeEx( hProcess,
                        pRemoteCode,
                        SizeOf(TLoadInjectInfo),
                        MEM_RELEASE);
end;

end;

function UnLoadDllFromProcess(hProcess:THandle;
                              hLibModule: HModule;
                              var bOK:BOOL):BOOL;
var
  pCode : ^Byte;
  i : Integer;
  InjectInfo : TFreeInjectInfo;
  pRemoteCode : PFreeInjectInfo;
  dwCount : DWORD;
  dwThreadID : DWORD;
  hThread : THandle;
  dwExitCode : DWORD;

begin
  result := TRUE;
  bOK := TRUE;
try
  pCode := Addr(RemoteFreeFunc);

  for i:=0 to SizeOf(InjectInfo.InjectCode) - 1 do begin
    InjectInfo.InjectCode[i] := pCode^;
    Inc(pCode);
  end;

  InjectInfo.fnFreeLibrary := GetProcAddress(GetModuleHandle('Kernel32.dll'),
                                    'FreeLibrary');
  InjectInfo.hLibModule := hLibModule;
  InjectInfo.fnMessageBeep := GetProcAddress(GetModuleHandle('User32.dll'),
                                    'MessageBeep');
  InjectInfo.uBeep := 0;

  pRemoteCode := nil;
  pRemoteCode := VirtualAllocEx( hProcess,
                            nil,
                            SizeOf(TFreeInjectInfo),
                            MEM_COMMIT,
                            PAGE_EXECUTE_READWRITE);
  if (pRemoteCode = nil) then
    RaiseLastWin32Error;

  if not WriteProcessMemory(hProcess,
                            pRemoteCode,
                            @InjectInfo,
                            SizeOf(TFreeInjectInfo),
                            dwCount) then
    RaiseLastWin32Error;

  hThread := 0;
  hThread := CreateRemoteThread( hProcess,
                                nil,
                                0,
                                Addr(pRemoteCode^.InjectCode[0]),
                                pRemoteCode,
                                0,
                                dwThreadId);
  if hThread=0 then
    RaiseLastWin32Error;

  WaitForSingleObject(hThread, INFINITE);

  GetExitCodeThread(hThread, dwExitCode);

  bOK := BOOL(dwExitCode);

  CloseHandle(hThread);
finally
  if Assigned(pRemoteCode) then
         VirtualFreeEx( hProcess,
                        pRemoteCode,
                        SizeOf(TLoadInjectInfo),
                        MEM_RELEASE);
end;

end;


end.
