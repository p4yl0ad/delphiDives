program QuickPortscan_R;
{$APPTYPE CONSOLE}
{$R *.res}
//https://www.programmersought.com/article/63515174909/
//https://www.example-code.com/delphidll/socket_connect.asp


uses
  System.SysUtils,
  Vcl.Forms,
  IdTCPClient;

var
  Result : boolean;
  AHost : string;
  APort, i : Integer;
  IdTCPClient : TIdTCPClient;
  //53,88,135,137,139,161,389,445,636,1433,3269,5985,5986

const Ports : array [1..13] of integer =
 (53,88,135,137,139,161,389,445,636,1433,3269,5985,5986);

begin
  Result := False;
  AHost := '127.0.0.1';

  for i := 1 to 13 do
    WriteLn(Ports[i]);
    IdTCPClient := TIdTCPClient.Create(nil);
      try
        IdTCPClient.Host := AHost;
        IdTCPClient.Port := Ports[i];
        IdTCPClient.Connect;
        Result := True;
        if (Result <> True) then
          WriteLn('Port ', Ports[i] , ' Open');        
          //IdTCPClient.Free;
      except
        WriteLn('Port ', Ports[i], ' Closed');
        //IdTCPClient.Free;
  
      end;
        IdTCPClient.Free;

  //except
  //  on E: Exception do
  //    Writeln(E.ClassName, ': ', E.Message);
  //end;
end.
      
