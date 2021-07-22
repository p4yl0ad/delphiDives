(******************************************************************************
*   CopyRight (c) By GanHuaXin 2002
*   All Right Reserved
*   Email : huiyugan@263.net
*   Date    :
*       New Develop   : 2002-x-x
*       Modified      : 2001-05-26
******************************************************************************)
unit OpenThread;

interface

uses
  Windows,
  TlHelp32,
  SysUtils;

function OpenThread2(dwThreadID : DWORD; bInherit : BOOL):THandle;stdcall;
function GetProcessID(strProcessName : string):DWORD;
function GetThreadID(dwOwnerProcessID : DWORD):DWORD;

implementation

const
  THREAD_TERMINATE            = $0001;
  THREAD_SUSPEND_RESUME       = $0002;
  THREAD_GET_CONTEXT          = $0008;
  THREAD_SET_CONTEXT          = $0010;
  THREAD_SET_INFORMATION      = $0020;
  THREAD_QUERY_INFORMATION    = $0040;
  THREAD_SET_THREAD_TOKEN     = $0080;
  THREAD_IMPERSONATE          = $0100;
  THREAD_DIRECT_IMPERSONATION = $0200;
  THREAD_ALL_ACCESS           = STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $3FF;

type
  PPDB = ^T_PDB;
  T_PDB = record
    mType           : WORD;
    Refcount        : WORD;
    Unk0            : DWORD;
    Unk1            : DWORD;
    Unk2            : DWORD;
    TermStatus      : DWORD;
    Unk3            : DWORD;
    DefaultHeap     : DWORD;
    MemContext      : DWORD;
    Flags           : DWORD;
    pPsp            : DWORD;
    psSelector      : WORD;
    METIndex        : WORD;
    nThreads        : WORD;
    nThreadsNotTerm : WORD;
    Unk5            : WORD;
    nR0Threads      : WORD;
    HeapHandle      : DWORD;
    K16TDBSel       : WORD;
    Unk6            : WORD;
    Unk7            : DWORD;
    pEDB            : DWORD;
    pHandleTable    : DWORD;
    ParentPDB       : PPDB;
    ModRefList      : DWORD;
    ThreadList      : DWORD;
    DebugeeCB       : DWORD;
    LHFreeHead      : DWORD;
    InitialR0ID     : DWORD;
  end;
  PDB = T_PDB;


  T_TCB = record
    mType         : WORD;
    RefCount      : WORD;
    Unk1          : DWORD;
    pvExcept      : DWORD;
    TopOfStack    : DWORD;
    BaseOfStace   : DWORD;
    K16TDB        : WORD;
    StackSel16    : WORD;
    Unk2          : DWORD;
    UserPointer   : DWORD;
    pTIB          : DWORD;
    TIBFlags      : WORD;
    Win16MutxCnt  : WORD;
    DebugContext  : DWORD;
    PtrToCurPri   : DWORD;
    MsgQueue      : DWORD;
    pTLSarray     : DWORD;
    pParentPDB    : PPDB;
    SelmanList    : DWORD;
    Unk3          : DWORD;
    Flags         : DWORD;
    status        : DWORD;
    TibSel        : WORD;
    EmulatorSel   : WORD;
    HandleCount   : DWORD;
    WaitNodeList  : DWORD;
    R0hThread     : DWORD;
    ptdbx         : DWORD;
  end;
  TCB = T_TCB;
  PTCB = ^T_TCB;

  OBFUNC = function(dwPTID : DWORD):pointer;stdcall;
  OTFUNC = function(pH : PHandle; dwVal : DWORD; var var1; var var2):DWORD;stdcall;

function GetTrueProcAddress(lpMod : PChar; lpFunc : PChar):pointer;stdcall;forward;
function OpenThreadNT(dwThreadID : DWORD; bInherit : BOOL):THandle;stdcall;forward;


function XORProcessThreadID(dwPTID : DWORD):pointer;stdcall;
var
  obfuscate : OBFUNC;
  dwMain : DWORD;
  lpdw : PDWORD;
  dw1 : DWORD;
begin
  dwMain := DWORD(GetTrueProcAddress('Kernel32.dll', 'GetCurrentThreadId'));
  // if dwMain = nil then begin result := nil; exit; end;
  lpdw := PDWORD(dwMain+8);
  dw1 := dwMain + 12;
  obfuscate := OBFUNC(dw1 + lpdw^);
  result := obfuscate(dwPTID);
end;

function OpenThread2(dwThreadID : DWORD; bInherit : BOOL):THandle;stdcall;
var
  hThread, hPrc : THandle;
  lp1 : PDWORD;
  dwProcessID , dwWhere, dwTable : DWORD;
  b1 : BOOL;
  lpThreadObj : PTCB;
  procpPdb : PPDB;
  osvi : OSVERSIONINFO;
begin
  osvi.dwOSVersionInfoSize := sizeof(osvi);
  GetVersionEX(osvi);

  SetLastError(50);

  if osvi.dwPlatformId = VER_PLATFORM_WIN32_NT then
    result := OpenThreadNT(dwThreadID, bInherit)
  else begin
    procpPdb := PPDB(XORProcessThreadID(GetCurrentProcessID()));
    lpThreadObj := PTCB (XORProcessThreadID(dwThreadID));

    if IsBadReadPtr(lpThreadObj, sizeof(TCB)) then begin
      result := 0;
      exit;
    end;

    if PBYTE(lpThreadObj)^ <> 7 then begin
      result := 0;
      exit;
    end;

    dwProcessID := DWORD(XORProcessThreadID(DWORD(lpThreadObj^.pParentPDB)));

    if (dwProcessID = GetCurrentProcessID()) then
      hPrc := GetCurrentProcess()
    else begin
      hPrc := OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwProcessID);
      if (hPrc = 0) then begin
        result := 0;
        exit;
      end;
    end;

    // 4 is the lowest handle in the table
    // all proceses have this handle
    b1 := DuplicateHandle(hPrc,
                          THandle(4),
                          GetCurrentProcess(),
                          @hThread,
                          THREAD_ALL_ACCESS,
                          bInherit, 0);

    if (hPrc <> GetCurrentProcess()) then CloseHandle(hPrc);

    if (b1=FALSE) then begin
      result := 0;
      exit;
    end;

    dwWhere := DWORD(hThread) shr 2;
    dwTable := procpPdb^.pHandleTable;
    lp1 := PDWORD (dwTable + dwWhere*8 + 8);

    lp1^ := DWORD(lpThreadObj);

    result := hThread;

  end;

end;

{$J+}
function OpenThreadNT(dwThreadID : DWORD; bInherit : BOOL):THandle;stdcall;
const
  hThread : THandle = 0;
  struct1 : array [0..5] of DWORD = ($18, 0, 0, 0, 0, 0);
  struct2 : array [0..1] of DWORD = (0, 0);
  hLib : HModule = 0;
  OpenThatNTThread : OTFUNC = nil;

begin

  hLib := LoadLibrary('ntdll.dll');
  OpenThatNTThread := OTFUNC(GetProcAddress(hLib, 'NtOpenThread'));

  struct2[1] := dwThreadID;
  struct1[3] := DWORD(bInherit);

  OpenThatNtThread(@hThread, THREAD_ALL_ACCESS, struct1, struct2);

  FreeLibrary(hLib);

  result := hThread;
end;
{$J-}

function GetTrueProcAddress(lpMod : PChar; lpFunc : PChar):pointer;stdcall;
var
  bla : pointer;
  hMod : HModule;
begin
  hMod := GetModuleHandle(lpMod);

  if hMod=0 then begin
    result := nil;
    exit;
  end;

  bla := Pointer(GetProcAddress(hMod, lpFunc));
  if (DWORD(bla) = 0) then begin
    result := nil;
    exit;
  end;

  if PByte(bla)^ = $68 then
    bla := Pointer(PDWORD(DWORD(bla) + 1)^);

  result := bla;
end;

function GetProcessID(strProcessName : string):DWORD;
var
  dwRet : DWORD;
  hSnapShot : THandle;
  ProcessEntry : PROCESSENTRY32;
  bFlag : BOOL;
begin
	dwRet := 0;
	hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
	if(hSnapshot <> INVALID_HANDLE_VALUE) then
	begin
		FillChar(ProcessEntry,sizeof(PROCESSENTRY32),0);
		ProcessEntry.dwSize := sizeof(PROCESSENTRY32);
		bFlag := Process32First(hSnapshot,ProcessEntry);
		while (bFlag) do
		begin
      if Pos(UpperCase(strProcessName), UpperCase(ProcessEntry.szExeFile)) <> 0 then
			begin
				dwRet := ProcessEntry.th32ProcessID;
				break;
			end;
			ProcessEntry.dwSize := sizeof(PROCESSENTRY32);
			bFlag := Process32Next(hSnapshot,ProcessEntry);
		end;
		CloseHandle(hSnapshot);
	end;
	result := dwRet;
end;

function GetThreadID(dwOwnerProcessID : DWORD):DWORD;
var
  dwRet : DWORD;
  hThreadSnap : THandle;
  te32 : THREADENTRY32;
begin
	dwRet := 0;
	FillChar(te32, SizeOf(te32), 0);
	hThreadSnap := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if (hThreadSnap <> INVALID_HANDLE_VALUE) then	begin
		te32.dwSize := sizeof(THREADENTRY32);
		if (Thread32First(hThreadSnap, te32)) then
    repeat
      if (te32.th32OwnerProcessID = dwOwnerProcessID) then begin
			  dwRet := te32.th32ThreadID;
				break;
      end;
    until not (Thread32Next(hThreadSnap, te32));
		CloseHandle (hThreadSnap);
  end;
	result := dwRet;
end;

end.
