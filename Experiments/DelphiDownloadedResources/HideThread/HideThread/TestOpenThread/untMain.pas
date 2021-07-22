(******************************************************************************
*   CopyRight (c) By GanHuaXin 2002
*   All Right Reserved
*   Email : huiyugan@263.net
*   Date    :
*       New Develop   : 2002-x-x
*       Modified      : 2001-05-26
******************************************************************************)
unit untMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OpenThread, Privilege, untInjectCode;

const
  STR_INJECT_EXE = 'Explorer.exe';
type
  TForm1 = class(TForm)
    btnClose: TButton;
    btnUnInject: TButton;
    btnInject: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);

    procedure CreateParams(var Params: TCreateParams);override;
    procedure btnUnInjectClick(Sender: TObject);
    procedure btnInjectClick(Sender: TObject);
  private
    { Private declarations }
    hInjectProcess : THandle;
    hInjectThread : THandle;

    hMod : HModule; // The Injected module handle

  public
    { Public declarations }
    procedure WndProc(var Mess: TMessage); override;
  end;

var
  Form1: TForm1;
  hThread : THandle;

implementation

{$R *.dfm}

procedure TForm1.WndProc(var Mess: TMessage);
begin
  Inherited WndProc(Mess);
end;

procedure TForm1.CreateParams(var Params: TCreateParams);
begin
  Inherited CreateParams(Params);
  Params.WindowClass.style := CS_NOCLOSE or CS_DBLCLKS;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  hThread := 0;
  hInjectProcess := 0;
  hInjectThread := 0;
  hMod := 0;

  if not SetCurProcessDbgPrivilege() then
    ShowMessage('Can not Set DEBUG Privilege!');
  // InitCodeToLoad;
  {
  SetWindowPos(handle, HWND_TOPMOST, 0, 0, 0, 0,
               SWP_NOSIZE or SWP_NOMOVE);}
end;

procedure TForm1.btnCloseClick(Sender: TObject);
begin
  Close;
end;


procedure TForm1.btnUnInjectClick(Sender: TObject);
var
  dwProcessID : DWORD;
  hProcess : THandle;
  bOK : BOOL;

begin
  if hMod=0 then begin
    ShowMessage('The Module not Loaded!');
    exit;
  end;

  dwProcessID := 0;
  dwProcessID := GetProcessID(STR_INJECT_EXE);
  if dwProcessID=0 then begin
    ShowMessage('Can not get the process ID');
    exit;
  end;

  hProcess := 0;
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwProcessID);

  if hProcess=0 then begin
    ShowMessage('Can not Open the process!');
    exit;
  end;

  try
    UnLoadDllFromProcess(hProcess, hMod, bOK);
    ShowMessage(Format('UnLoad, Module Handle : %X, BOK: %X', [hMod, DWORD(bOK)]));
  finally
    CloseHandle(hProcess);
    hMod := 0;
  end;

end;

procedure TForm1.btnInjectClick(Sender: TObject);
var
  dwProcessID : DWORD;
  szFileName : PChar;
  strDllFile : String;
  hProcess : THandle;

begin
  if hMod<>0 then begin
    ShowMessage('The module has installed!');
    exit;
  end;

  dwProcessID := 0;
  dwProcessID := GetProcessID(STR_INJECT_EXE);
  if dwProcessID=0 then begin
    ShowMessage('Can not get the process ID');
    exit;
  end;

  hProcess := 0;
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwProcessID);

  if hProcess=0 then begin
    ShowMessage('Can not Open the process!');
    exit;
  end;

  szFileName := StrAlloc(256);
  GetModuleFileName(HInstance, szFileName, 255);
  strDllFile := StrPas(szFileName);
  strDllFile := ExtractFileDir(strDllFile);
  strDllFile := StrDllFile + '\clock.dll';
  StrPCopy(szFileName, strDllFile);
  try
    LoadDllToProcess(hProcess, szFileName, hMod);
    ShowMessage(Format('Load OK--Module %X', [hMod]));
  finally
    CloseHandle(hProcess);
  end;

  StrDispose(szFileName);

end;

end.
