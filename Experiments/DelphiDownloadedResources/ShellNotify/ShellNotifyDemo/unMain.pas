
{********************************************************}
{                                                        }
{    Firesoft ShellNotify Demo - Form Main               }
{                                                        }
{    Copyright (c) Federico Firenze                      }
{    Buenos Aires, Argentina                             }
{                                                        }
{********************************************************}

unit unMain;

{$IFNDEF VER110}
  {$IFNDEF VER120}
    {$IFNDEF VER130}
      {$WARN UNIT_PLATFORM OFF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ShellNotify, StdCtrls, FileCtrl;

type
  TfrmMain = class(TForm)
    ShellNotify: TShellNotify;
    bgNotifyPaths: TGroupBox;
    lbPaths: TListBox;
    btnAdd: TButton;
    btnRemove: TButton;
    btnClear: TButton;
    GroupBox1: TGroupBox;
    lbEvents: TListBox;
    btnStart: TButton;
    btnStop: TButton;
    btnClearLog: TButton;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure ShellNotifyNotify(Sender: TObject; Event: TShellNotifyEvent;
      Path1, Path2: String);
    procedure btnClearLogClick(Sender: TObject);
  private
    procedure CheckButtons; 
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  ShellNotify.PathList.Assign(lbPaths.Items);
  ShellNotify.Active := True;
  CheckButtons;
end;

procedure TfrmMain.btnStopClick(Sender: TObject);
begin
  ShellNotify.Active := False;
  CheckButtons;
end;

procedure TfrmMain.CheckButtons;
var
  AActive: Boolean;
begin
  AActive := ShellNotify.Active;

  btnStart.Enabled := not AActive;
  btnStop.Enabled := AActive;
end;

procedure TfrmMain.btnRemoveClick(Sender: TObject);
begin
  if lbPaths.ItemIndex <> -1 Then
    lbPaths.Items.Delete(lbPaths.ItemIndex);
end;

procedure TfrmMain.btnClearClick(Sender: TObject);
begin
  lbPaths.Items.Clear;
end;

procedure TfrmMain.btnAddClick(Sender: TObject);
var
  ADirectory: string;
begin
  if SelectDirectory(ADirectory, [sdAllowCreate, sdPerformCreate, sdPrompt], 0) Then
    lbPaths.Items.Add(ADirectory);
end;


procedure TfrmMain.ShellNotifyNotify(Sender: TObject; Event: TShellNotifyEvent; Path1, Path2: String);
begin
  { http://msdn.microsoft.com/library/default.asp?url=/library/en-us/shellcc/platform/shell/reference/functions/shchangenotify.asp }

  case Event of
    neAssocChanged:
      lbEvents.Items.Add('A file type association has changed ' + Path1);
    neAttributes:
      lbEvents.Items.Add('The attributes of an item or folder have changed ' + Path1);
    neCreate:
      lbEvents.Items.Add('A nonfolder item has been created ' + Path1);
    neDelete:
      lbEvents.Items.Add('A nonfolder item has been deleted ' + Path1);
    neDriveAdd:
      lbEvents.Items.Add('A drive has been added ' + Path1);
    neDriveAddGUI:
      lbEvents.Items.Add('A drive has been added and the Shell should create a new window for the drive ' + Path1);
    neDriveRemoved:
      lbEvents.Items.Add('A drive has been removed ' + Path1);
    neMediaInserted:
      lbEvents.Items.Add('Storage media has been inserted into a drive ' + Path1);
    neMediaRemoved:
      lbEvents.Items.Add('Storage media has been removed from a drive ' + Path1);
    neMkDir:
      lbEvents.Items.Add('A folder has been created ' + Path1);
    neNetShare:
      lbEvents.Items.Add('A folder on the local computer is being shared via the network ' + Path1);
    neNetUnshare:
      lbEvents.Items.Add('A folder on the local computer is no longer being shared via the network ' + Path1);
    neRenameFolder:
      lbEvents.Items.Add('The name of a folder "' + Path1 + '" has changed to "' + Path2 + '"');
    neRenameItem:
      lbEvents.Items.Add('The name of a nonfolder item "' + Path1 + '" has changed to "' + Path2 + '"');
    neRmDir:
      lbEvents.Items.Add('A folder has been removed ' + Path1);
    neServerDisconnect:
      lbEvents.Items.Add('The computer has disconnected from a server ' + Path1);
    neUpdateDir:
      lbEvents.Items.Add('The contents of an existing folder have changed, but the folder still exists and has not been renamed ' + Path1);
    neUpdateImage:
      lbEvents.Items.Add('An image in the system image list has changed ' + Path1 + Path2);
    neUpdateItem:
      lbEvents.Items.Add('An existing nonfolder item has changed, but the item still exists and has not been renamed ' + Path1);
    neOther:
      lbEvents.Items.Add('Other "' + Path1 + '", "' + Path2 + '"');
  end;
end;

procedure TfrmMain.btnClearLogClick(Sender: TObject);
begin
  lbEvents.Items.Clear;
end;

end.
