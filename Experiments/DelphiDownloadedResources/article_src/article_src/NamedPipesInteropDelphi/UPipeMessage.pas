unit UPipeMessage;

interface

uses
  SysUtils, Classes;

type
  TPipeMessage = class
  private
    FName: string;
    FDataList: TStringList;
    FIsError: Boolean;
    FErrorCode: string;
    FErrorText: string;
    function GetData(const AKey: string): string;
    procedure SetData(const AKey, Value: string);
    function GetAsString: string;
    procedure SetAsString(const Value: string);
  public
    constructor Create; overload;
    constructor Create(AException: Exception); overload;
    constructor Create(const ARequest: string); overload;
    constructor Create(const AName: string; AKeys, AValues: array of string); overload;
    destructor Destroy; override;
    procedure RaiseIfError;
    class function MakeMessage(const AName: string; AKeys, AValues: array of string): string; overload;
    class function MakeMessage(AException: Exception): string; overload;
    property Name: string read FName write FName;
    property IsError: Boolean read FIsError write FIsError;
    property ErrorCode: string read FErrorCode write FErrorCode;
    property ErrorText: string read FErrorText write FErrorText;
    property Data[const AKey: string]: string read GetData write SetData;
    property AsString: string read GetAsString write SetAsString;
  end;

implementation

uses
  XMLIntf, XMLDoc, Variants;

{ TPPipeMessage }

constructor TPipeMessage.Create;
begin
  FDataList := TStringList.Create;
end;

constructor TPipeMessage.Create(AException: Exception);
begin
  Create;
  IsError := True;
  ErrorCode := AException.ClassName;
  ErrorText := AException.Message;
end;

constructor TPipeMessage.Create(const ARequest: string);
begin
  Create;
  if ARequest <> '' then
    AsString := ARequest;
end;

constructor TPipeMessage.Create(const AName: string; AKeys, AValues: array of string);
var
  I: Integer;
begin
  Create;
  FName := AName;
  for I := Low(AKeys) to High(AKeys) do
    Data[AKeys[I]] := AValues[I];
end;

destructor TPipeMessage.Destroy;
begin
  FreeAndNil(FDataList);
  inherited;
end;

function TPipeMessage.GetData(const AKey: string): string;
begin
  Result := FDataList.Values[AKey];
end;

procedure TPipeMessage.SetData(const AKey, Value: string);
begin
  FDataList.Values[AKey] := Value;
end;

function TPipeMessage.GetAsString: string;
var
  lDoc: IXMLDocument;
  lRoot: IXMLNode;
  I: Integer;
begin
  Result := '';
  lDoc := NewXMLDocument;
  lRoot := lDoc.AddChild('Message');
  if Name <> '' then
    lRoot.Attributes['Name'] := Name;
  if IsError then
  begin
    lRoot.Attributes['IsError'] := IntToStr(Ord(IsError));
    lRoot.Attributes['ErrorCode'] := ErrorCode;
    lRoot.Attributes['ErrorText'] := ErrorText;
  end;
  for I := 0 to FDataList.Count - 1 do
  begin
    with lRoot.AddChild('Data') do
    begin
      Attributes['Key'] := FDataList.Names[I];
      Text := FDataList.ValueFromIndex[I];
    end;
  end;
  Result := lRoot.XML;
end;

procedure TPipeMessage.SetAsString(const Value: string);
var
  lXml: string;
  lDoc: IXMLDocument;
  lRoot: IXMLNode;
  I: Integer;
  lKey: string;
begin
  FName := '';
  FIsError := False;
  FErrorCode := '';
  FErrorText := '';
  FDataList.Clear;

  lXml := Value;
  if Pos('<?xml ', lXml) <> 1 then
    lXml := '<?xml version="1.0" standalone="yes"?>'#13#10 + lXml;

  lDoc := LoadXMLData(lXml);
  lRoot := lDoc.DocumentElement;
  if Assigned(lRoot) and (lRoot.NodeName = 'Message') then
  begin
    FName := VarToStr(lRoot.Attributes['Name']);
    FIsError := StrToIntDef(VarToStr(lRoot.Attributes['IsError']), 0) > 0;
    FErrorCode := VarToStr(lRoot.Attributes['ErrorCode']);
    FErrorText := VarToStr(lRoot.Attributes['ErrorText']);
    for I := 0 to lRoot.ChildNodes.Count - 1 do
    begin
      if lRoot.ChildNodes[I].NodeName = 'Data' then
      begin
        lKey := VarToStr(lRoot.ChildNodes[I].Attributes['Key']);
        if lKey <> '' then
          Data[lKey] := VarToStr(lRoot.ChildNodes[I].Text);
      end;
    end;
  end;
end;

class function TPipeMessage.MakeMessage(const AName: string; AKeys, AValues: array of string): string;
var
  lMessage: TPipeMessage;
begin
  lMessage := TPipeMessage.Create(AName, AKeys, AValues);
  try
    Result := lMessage.AsString;
  finally
    lMessage.Free;
  end;
end;

class function TPipeMessage.MakeMessage(AException: Exception): string;
var
  lMessage: TPipeMessage;
begin
  lMessage := TPipeMessage.Create(AException);
  try
    Result := lMessage.AsString;
  finally
    lMessage.Free;
  end;
end;

procedure TPipeMessage.RaiseIfError;
var
  lErrorCode, lErrorText: string;
begin
  if IsError then
  begin
    lErrorCode := ErrorCode;
    lErrorText := ErrorText;
    if lErrorCode = '' then
      lErrorCode := 'Exception';
    if lErrorText = '' then
      lErrorText := 'Unknown Internal Error (TPipeMessage)';
    raise Exception.Create(Format('%s: %s', [lErrorCode, lErrorText]));
  end;
end;

end.
