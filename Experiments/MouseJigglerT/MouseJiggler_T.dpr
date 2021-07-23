program MouseJiggler_T;

{$APPTYPE CONSOLE}

//Mouse position code:
{https://rosettacode.org/wiki/Mouse_position}

//Adding extra components
{Project menu-->options-->delphi compiler->>add in "unit scope names" value "Vcl"}
{https://stackoverflow.com/questions/8797138/design-time-package-fails-to-build-file-not-found-graphics-dcu}

//Misc reading about components
{https://www.delphipower.xyz/guide_6/installing_component_packages.html}
{http://docwiki.embarcadero.com/RADStudio/Sydney/en/VCL_Overview}
{http://docwiki.embarcadero.com/CodeExamples/Sydney/en/OnMouseMove_(Delphi)}

uses
  SysUtils,
  Vcl.Controls,
  Windows,
  Math,
  Vcl.Forms
  ;

var
  MyMouse : TMouse;

  JA, SW, SH, RX, RY, FL : Integer;
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
      WriteLn(
       'Screen Width ',
       SW,
       #13#10,
       'Screen Height ',
       SH,
       #13#10,
       'Jitter Ammount ',
       JA , ' Seconds'
      );
      SetCursorPos(RX, RY);
      WriteLn(JA * 100)
      sleep(JA * 100);
    end

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
