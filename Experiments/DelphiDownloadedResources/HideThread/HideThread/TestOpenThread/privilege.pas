(******************************************************************************
*   CopyRight (c) By GanHuaXin 2002
*   All Right Reserved
*   Email : huiyugan@263.net
*   Date    :
*       New Develop   : 2002-x-x
*       Modified      : 2001-05-26
******************************************************************************)

unit privilege;

interface
uses
  Windows, Dialogs;

////////////////////////////////////////////////////////////////////////
//                                                                    //
//               NT Defined Privileges                                //
//                                                                    //
////////////////////////////////////////////////////////////////////////
const
  SE_CREATE_TOKEN_NAME        : PChar = 'SeCreateTokenPrivilege';
  SE_ASSIGNPRIMARYTOKEN_NAME  : PChar = 'SeAssignPrimaryTokenPrivilege';
  SE_LOCK_MEMORY_NAME         : PChar = 'SeLockMemoryPrivilege';
  SE_INCREASE_QUOTA_NAME      : PChar = 'SeIncreaseQuotaPrivilege';
  SE_UNSOLICITED_INPUT_NAME   : PChar = 'SeUnsolicitedInputPrivilege';
  SE_MACHINE_ACCOUNT_NAME     : PChar = 'SeMachineAccountPrivilege';
  SE_TCB_NAME                 : PChar = 'SeTcbPrivilege';
  SE_SECURITY_NAME            : PChar = 'SeSecurityPrivilege';
  SE_TAKE_OWNERSHIP_NAME      : PChar = 'SeTakeOwnershipPrivilege';
  SE_LOAD_DRIVER_NAME         : PChar = 'SeLoadDriverPrivilege';
  SE_SYSTEM_PROFILE_NAME      : PChar = 'SeSystemProfilePrivilege';
  SE_SYSTEMTIME_NAME          : PChar = 'SeSystemtimePrivilege';
  SE_PROF_SINGLE_PROCESS_NAME : PChar = 'SeProfileSingleProcessPrivilege';
  SE_INC_BASE_PRIORITY_NAME   : PChar = 'SeIncreaseBasePriorityPrivilege';
  SE_CREATE_PAGEFILE_NAME     : PChar = 'SeCreatePagefilePrivilege';
  SE_CREATE_PERMANENT_NAME    : PChar = 'SeCreatePermanentPrivilege';
  SE_BACKUP_NAME              : PChar = 'SeBackupPrivilege';
  SE_RESTORE_NAME             : PChar = 'SeRestorePrivilege';
  SE_SHUTDOWN_NAME            : PChar = 'SeShutdownPrivilege';
  SE_DEBUG_NAME               : PChar = 'SeDebugPrivilege';
  SE_AUDIT_NAME               : PChar = 'SeAuditPrivilege';
  SE_SYSTEM_ENVIRONMENT_NAME  : PChar = 'SeSystemEnvironmentPrivilege';
  SE_CHANGE_NOTIFY_NAME       : PChar = 'SeChangeNotifyPrivilege';
  SE_REMOTE_SHUTDOWN_NAME     : PChar = 'SeRemoteShutdownPrivilege';

function SetPrivilege(hToken : THandle; strPrivilege : PChar; bEnable:BOOL):BOOL;
function SetCurProcessDbgPrivilege:BOOL;
function UnSetCurProcessDbgPrivilege:BOOL;

implementation

function SetPrivilege(hToken : THandle; strPrivilege : PChar; bEnable:BOOL):BOOL;
var
	tp : TOKEN_PRIVILEGES;
	luid : TLargeInteger;
	tpPrevious : TOKEN_PRIVILEGES;
	cbPrevious : DWORD;
  cbRtn : DWORD;
begin
	cbPrevious := sizeof(TOKEN_PRIVILEGES);

	if not LookupPrivilegeValue(nil, strPrivilege, luid) then begin
		result := FALSE;
		exit;
	end;

	tp.PrivilegeCount := 1;
	tp.Privileges[0].Luid := luid;
	tp.Privileges[0].Attributes := 0;

	AdjustTokenPrivileges(hToken, FALSE, tp,
			sizeof(TOKEN_PRIVILEGES),
			tpPrevious,
			cbPrevious);
	if (GetLastError() <> ERROR_SUCCESS) then begin
		result := FALSE;
		exit;
	end;

	tpPrevious.PrivilegeCount := 1;
	tpPrevious.Privileges[0].Luid := luid;

	if (bEnable) then begin
		tpPrevious.Privileges[0].Attributes :=
			tpPrevious.Privileges[0].Attributes or SE_PRIVILEGE_ENABLED;
	end
	else begin
		tpPrevious.Privileges[0].Attributes :=
			tpPrevious.Privileges[0].Attributes and (not SE_PRIVILEGE_ENABLED)
	end;

	AdjustTokenPrivileges(
		hToken,
		FALSE,
		tpPrevious,
		cbPrevious,
		nil,
		cbRtn);
	if (GetLastError() <> ERROR_SUCCESS) then
		result := FALSE;
	result := TRUE;
end;

function SetCurProcessDbgPrivilege:BOOL;
var
  hToken : THandle;
begin
  result := TRUE;
  if (not OpenProcessToken(GetCurrentProcess(),
				TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
				hToken ))
  then begin
    ShowMessage('Can not get the Process Token!');
    result := FALSE;
    exit;
  end;

  if (not SetPrivilege(hToken, SE_DEBUG_NAME, TRUE)) then begin
    result := FALSE;
    CloseHandle(hToken);
    exit;
  end;

  CloseHandle(hToken);
end;

function UnSetCurProcessDbgPrivilege:BOOL;
var
  hToken : THandle;
begin
  result := TRUE;
  if (not OpenProcessToken(GetCurrentProcess(),
				TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
				hToken ))
  then begin
    ShowMessage('Can not get the Process Token!');
    result := FALSE;
    exit;
  end;

  if (not SetPrivilege(hToken, SE_DEBUG_NAME, FALSE)) then begin
    result := FALSE;
    CloseHandle(hToken);
    exit;
  end;

  CloseHandle(hToken);
end;

end.
