unit UThreadQueue;

interface

uses
  Windows, SysUtils, Classes, SyncObjs, Contnrs;

type
  TSemaphore = class(TSynchroObject)
  private
    FHandle: THandle;
  public
    constructor Create(AEventAttributes: PSecurityAttributes; AMaximumCount: Integer;
      AInitialCount: Integer = 0; const AName: string = '');
    destructor Destroy; override;
    property Handle: THandle read FHandle;
    procedure Acquire; override;
    function WaitFor(ATimeout: LongWord = INFINITE): TWaitResult;
    procedure Release; override;
  end;

  TThreadQueue = class
  private
    FMaxSize: Integer;
    FQueue: TObjectQueue;
    FPushSemaphore: TSemaphore;
    FPopSemaphore: TSemaphore;
    FPushCriticalSection: TCriticalSection;
    FPopCriticalSection: TCriticalSection;
    FTerminated: Integer;
    FName: string;
    FPushCount: Integer;
    FPopCount: Integer;
    FCritical: TCriticalSection;
    function GetTerminated: Boolean;
    function GetCount: Integer;
  protected
    property PushCriticalSection: TCriticalSection read FPushCriticalSection;
    property PopCriticalSection: TCriticalSection read FPopCriticalSection;
    property PushSemaphore: TSemaphore read FPushSemaphore;
    property PopSemaphore: TSemaphore read FPopSemaphore;
    property Critical: TCriticalSection read FCritical;
  public
    constructor Create(const AMaxSize: Integer);
    destructor Destroy; override;
    procedure Push(const AObject: TObject);
    function Pop: TObject;
    property PopCount: Integer read FPopCount;
    property PushCount: Integer read FPushCount;
    procedure Terminate;
    procedure Clear;
    property Terminated: Boolean read GetTerminated;
    property MaxSize: Integer read FMaxSize;
    property Name: string read FName write FName;
    property Count: Integer read GetCount;
  end;

implementation

{ TSemaphore }

procedure TSemaphore.Acquire;
begin
  case WaitFor of
    wrTimeout: raise Exception.Create('Semaphore has timed out');
    wrAbandoned: raise Exception.Create('Semaphore has been abandoned');
    wrError: RaiseLastOSError;
  end;
end;

constructor TSemaphore.Create(AEventAttributes: PSecurityAttributes;
  AMaximumCount, AInitialCount: Integer; const AName: string);
begin
  FHandle := CreateSemaphore(AEventAttributes, AInitialCount, AMaximumCount, PChar(AName));
end;

destructor TSemaphore.Destroy;
begin
  CloseHandle(FHandle);
  inherited;
end;

procedure TSemaphore.Release;
begin
  ReleaseSemaphore(Handle, 1, nil);
end;

function TSemaphore.WaitFor(ATimeout: LongWord): TWaitResult;
begin
  case WaitForSingleObject(Handle, ATimeout) of
    WAIT_ABANDONED: Result := wrAbandoned;
    WAIT_OBJECT_0: Result := wrSignaled;
    WAIT_TIMEOUT: Result := wrTimeout;
    WAIT_FAILED: Result := wrError;
  else
    Result := wrError;
  end;
end;

{ TThreadQueue }

constructor TThreadQueue.Create(const AMaxSize: Integer);
begin
  FPopCount := 0;
  FPushCount := 0;
  FMaxSize := AMaxSize;
  FCritical := TCriticalSection.Create;
  FPushSemaphore := TSemaphore.Create(nil, AMaxSize);
  FPopSemaphore := TSemaphore.Create(nil, AMaxSize, AMaxSize);
  FPushCriticalSection := TCriticalSection.Create;
  FPopCriticalSection := TCriticalSection.Create;
  FQueue := TObjectQueue.Create;
end;

destructor TThreadQueue.Destroy;
begin
  FreeAndNil(FQueue);
  FreeAndNil(FPushSemaphore);
  FreeAndNil(FPopSemaphore);
  FreeAndNil(FPushCriticalSection);
  FreeAndNil(FPopCriticalSection);
  FreeAndNil(FCritical);
  inherited;
end;

function TThreadQueue.GetCount: Integer;
begin
  Critical.Enter;
  //try
    Result := FQueue.Count;
  //finally
    Critical.Leave;
  //end;
end;

function TThreadQueue.GetTerminated: Boolean;
begin
  Result := FTerminated > 0;
end;

function TThreadQueue.Pop: TObject;
begin
  PopCriticalSection.Enter;
  try
    Result := nil;
    if not Terminated or (Count > 0) then
    begin
      PushSemaphore.Acquire;
      if not Terminated or (Count > 0) then
      begin
        InterlockedIncrement(FPopCount);
        Critical.Enter;
        //try
          Result := FQueue.Pop;
        //finally
          Critical.Leave;
        //end;
        PopSemaphore.Release;
      end;
    end;
  finally
    PopCriticalSection.Leave;
  end;
end;

procedure TThreadQueue.Push(const AObject: TObject);
begin
  PushCriticalSection.Enter;
  try
    if Terminated then
    begin
      AObject.Free;
      Exit;
      //raise Exception.Create('Queue is terminated (TThreadQueue.Push)');
    end;
    PopSemaphore.Acquire;
    InterlockedIncrement(FPushCount);
    Critical.Enter;
    //try
      FQueue.Push(AObject);
    //finally
      Critical.Leave;
    //end;
    PushSemaphore.Release;
  finally
    PushCriticalSection.Leave;
  end;
end;

procedure TThreadQueue.Clear;
var
  lObject: TObject;
begin
  lObject := Pop;
  while Assigned(lObject) do
  begin
    FreeAndNil(lObject);
    lObject := Pop;
  end;
end;

procedure TThreadQueue.Terminate;
begin
  PushCriticalSection.Enter;
  try
    if not Terminated then
    begin
      InterlockedIncrement(FTerminated);
      if Count = 0 then
        PushSemaphore.Release; // pulse popping threads
    end;
  finally
    PushCriticalSection.Leave;
  end;
end;

end.
