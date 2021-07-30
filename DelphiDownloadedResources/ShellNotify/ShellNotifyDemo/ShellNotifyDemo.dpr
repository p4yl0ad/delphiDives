
{********************************************************}
{                                                        }
{    Firesoft ShellNotify Demo                           }
{                                                        }
{    Copyright (c) Federico Firenze                      }
{    Buenos Aires, Argentina                             }
{                                                        }
{********************************************************}

program ShellNotifyDemo;

uses
  Forms,
  unMain in 'unMain.pas' {frmMain};

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
