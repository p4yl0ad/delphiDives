program HelloDelphi;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;


begin
  try
    WriteLn('Hello Delphi');
    Sleep(10000);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
