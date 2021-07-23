program MouseJiggler_T;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Vcl.Controls,
  Windows,
  Math,
  Vcl.Forms;

var
  MyMouse : TMouse;

  JA, SW, SH, RX, RY, FL, TS, TMS : Integer;
  mx, my, nx, ny, len : double;

begin
  try
    MyMouse := TMouse.Create;
    SW := Screen.Width;
    SH := Screen.Height;
    FL := 60;

    While True do
    begin
      JA := RandomRange(1, 300);
      RX := RandomRange(0, SW);
      RY :=  RandomRange(0, SH);
      WriteLn(
       '(X, y) = ('+
        inttostr(
          TPoint(
            MyMouse.CursorPos
          ).x)+
       ','+
       inttostr(
        TPoint(
          MyMouse.CursorPos
        ).y)+
       ')'
      );
      TS := FL + JA;
      TMS := TS * 1000;
      WriteLn(
       'Screen Width ',
       SW,
       #13#10,
       'Screen Height ',
       SH,
       #13#10,
       #13#10,
       'Jitter Ammount ',
       JA,
       '/300 Seconds',
       #13#10,
       'Fixed Delay ',
       FL,
       #13#10,
       'Total Seconds Sleep ',
       TS,
       #13#10,
       'Total Milliseconds Sleep ',
       TMS
      );
      SetCursorPos(RX, RY);
      sleep(TMS);
    end

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
