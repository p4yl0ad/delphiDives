program TestOt;

uses
  Forms,
  untMain in 'untMain.pas' {Form1},
  privilege in 'privilege.pas',
  untInjectCode in 'untInjectCode.pas',
  OpenThread in 'OpenThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
