// Most of this taken from https://stackoverflow.com/a/19780129 with some edits.

#ifndef _WIN32_WINNT
// Windows XP
#define _WIN32_WINNT 0x0501
#endif
#define MAX_PATH 0xFF
#include <Windows.h>
#include <Psapi.h>  
#include <iostream>
#include <cstdio>
#include <errno.h>

ULONG PipeSerialNumber;

void EnumeratePipes()
{
    WIN32_FIND_DATA FindFileData;
    HANDLE hFind;

#define TARGET_PREFIX "//./pipe/"
    const char *target = TARGET_PREFIX "*";

    memset(&FindFileData, 0, sizeof(FindFileData));
    hFind = FindFirstFileA(target, &FindFileData);
    if (hFind == INVALID_HANDLE_VALUE) 
    {
        std::cerr << "FindFirstFileA() failed: " << GetLastError() << std::endl;
        return;
    }
    else 
    {
        do
        {
            std::cout << "Pipe: " << TARGET_PREFIX << FindFileData.cFileName << std::endl;
        }
        while (FindNextFile(hFind, &FindFileData));

        FindClose(hFind);
    }
#undef TARGET_PREFIX

    return;
}

// taken from: https://web.archive.org/web/20150125081922/http://www.davehart.net:80/remote/PipeEx.c
BOOL
APIENTRY
MyCreatePipeEx(
    OUT LPHANDLE lpReadPipe,
    OUT LPHANDLE lpWritePipe,
    IN LPSECURITY_ATTRIBUTES lpPipeAttributes,
    IN DWORD nSize,
    DWORD dwReadMode,
    DWORD dwWriteMode,
	unsigned char PipeNameBuffer[MAX_PATH]
    )
{
    HANDLE ReadPipeHandle, WritePipeHandle;
    DWORD dwError;

    if ((dwReadMode | dwWriteMode) & (~FILE_FLAG_OVERLAPPED)) {
        SetLastError(ERROR_INVALID_PARAMETER);
        return FALSE;
    }

    if (nSize == 0) {
        nSize = 4096;
        }

    ReadPipeHandle = CreateNamedPipeA(
                         (LPCSTR)PipeNameBuffer,
                         PIPE_ACCESS_INBOUND | dwReadMode,
                         PIPE_TYPE_BYTE | PIPE_WAIT,
                         1,             // Number of pipes
                         nSize,         // Out buffer size
                         nSize,         // In buffer size
                         120 * 1000,    // Timeout in ms
                         lpPipeAttributes
                         );

    if (! ReadPipeHandle) {
        return FALSE;
    }

    WritePipeHandle = CreateFileA(
                        (LPCSTR)PipeNameBuffer,
                        GENERIC_WRITE,
                        0,                         // No sharing
                        lpPipeAttributes,
                        OPEN_EXISTING,
                        FILE_ATTRIBUTE_NORMAL | dwWriteMode,
                        NULL                       // Template file
                      );

    if (INVALID_HANDLE_VALUE == WritePipeHandle) {
        dwError = GetLastError();
        CloseHandle( ReadPipeHandle );
        SetLastError(dwError);
        return FALSE;
    }

    *lpReadPipe = ReadPipeHandle;
    *lpWritePipe = WritePipeHandle;
    return( TRUE );
}

int main(int argc, char**argv)
{
    HANDLE read = INVALID_HANDLE_VALUE;
    HANDLE write = INVALID_HANDLE_VALUE;
    unsigned char pipe_name[MAX_PATH+1];

    BOOL success = MyCreatePipeEx(&read, &write, NULL, 0, 0, 0, pipe_name);

    EnumeratePipes();

    if ( success == FALSE )
    {
        std::cerr << "MyCreatePipeEx() failed: " << GetLastError() << std::endl;
        return 1;
    }

    FILE *f = fopen((const char*)pipe_name, "rwb");
    if ( f == NULL )
    {
        std::cerr << "fopen(\"" << pipe_name << "\") failed: " << (int)errno << std::endl;
    }

    CloseHandle(read);
    CloseHandle(write);

    return 0;
}