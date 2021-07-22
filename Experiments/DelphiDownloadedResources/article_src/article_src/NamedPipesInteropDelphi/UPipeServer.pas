unit UPipeServer;

interface

uses
  SysUtils, Classes, Windows, ActiveX, Messages, UThreadQueue;

const
  PIPE_TIMEOUT = 1000;
  BUFFER_SIZE = 4096;

type
  TNamedPipeServer = class;

  TInitializedThread = class(TThread)
  private
    FFatalError: TObject;
  protected
    procedure RaiseException;
    procedure Execute; override;
    procedure IntExecute; virtual; abstract;
    property FatalError: TObject read FFatalError write FFatalError;
  end;

  TPipeListenerThread = class(TInitializedThread)
  private
    FPipeName: string;
    FServer: TNamedPipeServer;
    hPipe: THandle;
    procedure EmulateConnect;
  protected
    procedure IntExecute; override;
    property PipeName: string read FPipeName write FPipeName;
    property Server: TNamedPipeServer read FServer write FServer;
  end;

  TPipeWorkerThread = class(TInitializedThread)
  private
    FServer: TNamedPipeServer;
  protected
    procedure IntExecute; override;
    property Server: TNamedPipeServer read FServer write FServer;
  end;

  TPipeMessageHandler = class
  private
    FPipeHandle: THandle;
    FServer: TNamedPipeServer;
  public
    constructor Create(AServer: TNamedPipeServer; APipeHandle: THandle);
    procedure Execute;
  end;

  TNamedPipeServer = class
  private
    FBufferSize: Integer;
    FServerID: string;
    FListener: TPipeListenerThread;
    FWorker: TPipeWorkerThread;
    FQueue: TThreadQueue;
    procedure SetBufferSize(const Value: Integer);
    function GetServerID: string;
    function GetBufferSize: Integer;
  protected
    procedure DispatchMessage(ARequestStream, AResponseStream: TStream); virtual; abstract;
    property Listener: TPipeListenerThread read FListener;
    property Worker: TPipeWorkerThread read FWorker;
    property Queue: TThreadQueue read FQueue;
  public
    constructor Create(const AServerID: string);
    destructor Destroy; override;
  published
    property ServerID: string read GetServerID;
    property BufferSize: Integer read GetBufferSize write SetBufferSize default BUFFER_SIZE;
  end;

implementation

{ TInitializedThread }

procedure TInitializedThread.Execute;
begin
  CoInitialize(nil);
  try
    try
      IntExecute;
    except
      on E: TObject do
      begin
        FatalError := E;
        Synchronize(RaiseException);
        //RaiseException;
      end;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TInitializedThread.RaiseException;
begin
  raise FatalError;
end;

{ TPipeListenerThread }

procedure TPipeListenerThread.EmulateConnect;
var
  I: Cardinal;
begin
  if hPipe <> INVALID_HANDLE_VALUE then
    CallNamedPipe(PChar(FPipeName), nil, 0, nil, 0, i, 10);
end;

procedure TPipeListenerThread.IntExecute;
var
  lConnected: Boolean;
  lSecurityDescriptor: _SECURITY_DESCRIPTOR;
  lSecurityAttribute: SECURITY_ATTRIBUTES;
begin
  hPipe := INVALID_HANDLE_VALUE;
  FillChar(lSecurityAttribute, SizeOf(lSecurityAttribute), 0);
  InitializeSecurityDescriptor(@lSecurityDescriptor, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@lSecurityDescriptor, true, nil, False);
  lSecurityAttribute.nLength := SizeOf(lSecurityAttribute);
  lSecurityAttribute.bInheritHandle := True;
  lSecurityAttribute.lpSecurityDescriptor := @lSecurityDescriptor;

  while not Terminated do
  begin
    hPipe := CreateNamedPipe(
        PChar(FPipeName),         // pipe name
        PIPE_ACCESS_DUPLEX,       // read/write access
        PIPE_TYPE_MESSAGE or      // message type pipe
        PIPE_READMODE_BYTE or     // byte-read mode
        PIPE_WAIT,                // blocking mode
        PIPE_UNLIMITED_INSTANCES, // max. instances
        Server.BufferSize,        // output buffer size
        Server.BufferSize,        // input buffer size
        PIPE_TIMEOUT,             // client time-out
        @lSecurityAttribute);

    if (hPipe = INVALID_HANDLE_VALUE) then
      RaiseLastOSError;

    lConnected := ConnectNamedPipe(hPipe, nil);

    if not lConnected then
      lConnected := GetLastError = ERROR_PIPE_CONNECTED;

    if lConnected and not Terminated then
    begin
      Server.Queue.Push(TPipeMessageHandler.Create(Server, hPipe));
    end
    else
    begin
      CloseHandle(hPipe);
      hPipe := INVALID_HANDLE_VALUE;
    end;
  end;
end;

{ TPipeWorkerThread }

procedure TPipeWorkerThread.IntExecute;
var
  lMessage: TPipeMessageHandler;
begin
  while not Terminated do
  begin
    lMessage := TPipeMessageHandler(Server.Queue.Pop);
    if Assigned(lMessage) then
    begin
      lMessage.Execute;
      lMessage.Free;
    end;
  end;
end;

{ TNamedPipeServer }

constructor TNamedPipeServer.Create(const AServerID: string);
begin
  FServerID := AServerID;

  FQueue := TThreadQueue.Create(64);
  FQueue.Name := ServerID;

  FWorker := TPipeWorkerThread.Create(True);
  FWorker.Server := Self;
  FWorker.Resume;

  FListener := TPipeListenerThread.Create(True);
  FListener.Server := Self;
  FListener.PipeName := '\\.\pipe\'+ ServerID;
  FListener.Resume;
end;

destructor TNamedPipeServer.Destroy;
begin
  FListener.Terminate;
  FListener.EmulateConnect;
  FListener.WaitFor;
  FQueue.Terminate;
  FWorker.Terminate;
  FWorker.WaitFor;

  FreeAndNil(FListener);
  FreeAndNil(FQueue);
  FreeAndNil(FWorker);

  inherited;
end;

function TNamedPipeServer.GetBufferSize: Integer;
begin
  if FBufferSize = 0 then
    FBufferSize := BUFFER_SIZE;
  Result := FBufferSize;
end;

function TNamedPipeServer.GetServerID: string;
begin
  Result := FServerID;
  if Result = '' then
    Result := IntToStr(GetCurrentProcessId);
end;

procedure TNamedPipeServer.SetBufferSize(const Value: Integer);
begin
  if Value < 1024 then
    FBufferSize := 1024
  else
    FBufferSize := Value;
end;

{ TPipeMessageHandler }

constructor TPipeMessageHandler.Create(AServer: TNamedPipeServer; APipeHandle: THandle);
begin
  FServer := AServer;
  FPipeHandle := APipeHandle;
end;

procedure TPipeMessageHandler.Execute;
var
  lReadStream, lWriteStream: TMemoryStream;
  lBytesRead, lBytesWritten: DWORD;
  lSuccess: BOOL;
  lDataSize, lBufferSize: Integer;
  lBuffer: PChar;
begin
  lBufferSize := FServer.BufferSize;
  GetMem(lBuffer, lBufferSize);
  lReadStream := TMemoryStream.Create;
  try
    try
      lSuccess := ReadFile(fPipeHandle, lDataSize, SizeOf(lDataSize), lBytesRead, nil);

      if not lSuccess then
      begin
        if GetLastError = ERROR_BROKEN_PIPE then
          Exit
        else
          RaiseLastOSError;
      end;

      while lDataSize > 0 do
      begin
        lSuccess := ReadFile(fPipeHandle, lBuffer^, lBufferSize, lBytesRead, nil);

        if not lSuccess and (GetLastError <> ERROR_MORE_DATA) then
          RaiseLastOSError;

        if lBytesRead > 0 then
          lReadStream.Write(lBuffer^, lBytesRead);

        Dec(lDataSize, lBytesRead);
      end;

      if not lSuccess then
        RaiseLastOSError;

      if lReadStream.Size > 0 then
      begin
        lReadStream.Position := 0;
        lWriteStream := TMemoryStream.Create;
        try
          FServer.DispatchMessage(lReadStream, lWriteStream);
          lReadStream.Position := 0;
          lReadStream.SetSize(0);
          lWriteStream.Position := 0;

          lDataSize := lWriteStream.Size;
          lSuccess := WriteFile(fPipeHandle, lDataSize, SizeOf(lDataSize), lBytesWritten, nil);

          if not lSuccess then
            RaiseLastOSError;

          while lDataSize > 0 do
          begin
            lBytesRead := lWriteStream.Read(lBuffer^, lBufferSize);
            Dec(lDataSize, lBytesRead);
            lSuccess := WriteFile(fPipeHandle, lBuffer^, lBytesRead, lBytesWritten, nil);

            if not lSuccess then
              RaiseLastOSError;
          end;
        finally
          lWriteStream.Free;
        end;
      end;
    except
      on E: EOSError do
      begin
        if not (E.ErrorCode in [ERROR_NO_DATA, ERROR_BROKEN_PIPE]) then
          raise;
      end;
    end;
  finally
    FreeMem(lBuffer);
    lReadStream.Free;
    FlushFileBuffers(FPipeHandle);
    DisconnectNamedPipe(FPipeHandle);
    CloseHandle(FPipeHandle);
  end;
end;

end.

