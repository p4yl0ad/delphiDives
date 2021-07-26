program BasedAmsi_E;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  Windows
  ;

begin
  try

  WriteLn('Hello');

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

