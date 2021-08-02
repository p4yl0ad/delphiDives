program SeaShell_T;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  IdComponent,
  IdTCPConnection,
  IdTCPClient;



{
https://github.com/vladon/IdTcpClientAndServerExample
}


begin
var
  IdTCPClient1: TIdTCPClient;

  IdTCPClient1.Host := '127.0.0.1';
  IdTCPClient1.Port := StrToInt('6666');
  IdTCPClient1.Connect;


  IdTCPClient1.IOHandler.WriteLn('[C1c] Hello Server');
  IdTCPClient1.Disconnect;

  try
    WriteLn('kek');

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
