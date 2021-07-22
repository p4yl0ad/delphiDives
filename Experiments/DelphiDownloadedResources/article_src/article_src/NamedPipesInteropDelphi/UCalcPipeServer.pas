unit UCalcPipeServer;

interface

uses
  SysUtils, Classes, UPipeServer, UCalcRequestDispatcher;

type
  TCalcPipeServer = class(TNamedPipeServer)
  private
    FRequestDispatcher: TCalcRequestDispatcher;
    function GetRequestDispatcher: TCalcRequestDispatcher;
  protected
    procedure DispatchMessage(ARequestStream: TStream; AResponseStream: TStream); override;
    property RequestDispatcher: TCalcRequestDispatcher read GetRequestDispatcher;
  public
    destructor Destroy; override;
  end;

implementation

{ TCalcPipeServer }

destructor TCalcPipeServer.Destroy;
begin
  FreeAndNil(FRequestDispatcher);
  inherited;
end;

procedure TCalcPipeServer.DispatchMessage(ARequestStream, AResponseStream: TStream);
var
  lData: string;
begin
  SetLength(lData, ARequestStream.Size);
  ARequestStream.Read(lData[1], Length(lData));
  lData := RequestDispatcher.ProcessRequest(lData);
  AResponseStream.Write(lData[1], Length(lData));
end;

function TCalcPipeServer.GetRequestDispatcher: TCalcRequestDispatcher;
begin
  if not Assigned(FRequestDispatcher) then
    FRequestDispatcher := TCalcRequestDispatcher.Create;
  Result := FRequestDispatcher;
end;

end.
 