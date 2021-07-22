unit UCalcRequestDispatcher;

interface

uses
  Windows, SysUtils, SyncObjs, UPipeMessage, UCalcProcessor;

type
  TCalcRequestDispatcher = class
  protected
    function InternalProcessRequest(const ARequest: string): string;
  public
    function ProcessRequest(const ARequest: string): string;
  end;

implementation

var
  ct: TCriticalSection;
  
{ TCalcRequestDispatcher }

function TCalcRequestDispatcher.InternalProcessRequest(const ARequest: string): string;
var
  lRequest: TPipeMessage;
  X, Y, lResult: Double;
begin
  Result := '';
  lRequest := TPipeMessage.Create(ARequest);
  try
    if lRequest.Name = 'Add' then
    begin
      X := StrToFloat(lRequest.Data['X']);
      Y := StrToFloat(lRequest.Data['Y']);
      lResult := TCalcProcessor.Add(X, Y);
      Result := TPipeMessage.MakeMessage('Result', ['Result'], [FloatToStr(lResult)]);
    end
    else if lRequest.Name = 'Subtract' then
    begin
      X := StrToFloat(lRequest.Data['X']);
      Y := StrToFloat(lRequest.Data['Y']);
      lResult := TCalcProcessor.Subtract(X, Y);
      Result := TPipeMessage.MakeMessage('Result', ['Result'], [FloatToStr(lResult)]);
    end
    else if lRequest.Name = 'Mult' then
    begin
      X := StrToFloat(lRequest.Data['X']);
      Y := StrToFloat(lRequest.Data['Y']);
      lResult := TCalcProcessor.Mult(X, Y);
      Result := TPipeMessage.MakeMessage('Result', ['Result'], [FloatToStr(lResult)]);
    end
    else if lRequest.Name = 'Div' then
    begin
      X := StrToFloat(lRequest.Data['X']);
      Y := StrToFloat(lRequest.Data['Y']);
      lResult := TCalcProcessor.Divide(X, Y);
      Result := TPipeMessage.MakeMessage('Result', ['Result'], [FloatToStr(lResult)]);
    end
    else if lRequest.Name = 'ExitProcess' then
    begin
      ExitProcess(0);
    end
    else if lRequest.Name = 'Ping' then
    begin
      // do nothing;
    end
    else
      raise Exception.CreateFmt('Unknown request: %s', [lRequest.Name]);
  finally
    lRequest.Free;
  end;
end;

function TCalcRequestDispatcher.ProcessRequest(const ARequest: string): string;
begin
  try
    ct.Enter;
    try
      Result := InternalProcessRequest(ARequest);
    finally
      ct.Leave;
    end;
  except
    on E: Exception do
      Result := TPipeMessage.MakeMessage(E);
  end;
end;

initialization
begin
  ct := TCriticalSection.Create;
end;

finalization
begin
  FreeAndNil(ct);
end;

end.
