library FirstLibrary_T;

uses
  SysUtils,
  Classes,
  Vcl.Dialogs;

procedure DllMessage; export;
begin
  ShowMessage('Successful delphi Dll Load')
end;
exports DllMessage;
begin
end.
