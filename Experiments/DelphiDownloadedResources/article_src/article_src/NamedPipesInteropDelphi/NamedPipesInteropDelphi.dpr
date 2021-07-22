program NamedPipesInteropDelphi;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  UThreadQueue in 'UThreadQueue.pas',
  UPipeServer in 'UPipeServer.pas',
  UCalcPipeServer in 'UCalcPipeServer.pas',
  UCalcRequestDispatcher in 'UCalcRequestDispatcher.pas',
  UCalcProcessor in 'UCalcProcessor.pas',
  UPipeMessage in 'UPipeMessage.pas';

const
  cPipeParamPrefix = 'pipe=';
var
  I: Integer;
  lParam, lPipeName: string;
  lServer: TCalcPipeServer;
begin
  for I := 1 to ParamCount do
  begin
    lParam := ParamStr(I);
    if Pos(cPipeParamPrefix, lParam) = 1 then
    begin
      lPipeName := Copy(lParam, Length(cPipeParamPrefix) + 1, MaxInt);
      if lPipeName <> '' then
      begin
        lServer := TCalcPipeServer.Create(lPipeName);
        Writeln(Format('Listening to the pipe channel: [%s]', [lPipeName]));
        Writeln('Press <ENTER> to shut down...');
        Readln;
        FreeAndNil(lServer);
      end;
    end;
  end;
end.
