program EncBoi_T;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;


//https://delphi.cjcsoft.net/viewthread.php?tid=45395
function XorStr(Stri, Strk: String): String;
var
    Longkey: string;
    I: Integer;
    Next: char;
begin
    for I := 0 to (Length(Stri) div Length(Strk)) do
    Longkey := Longkey + Strk;
    for I := 1 to length(Stri) do
    begin
        Next := chr((ord(Stri[i]) xor ord(Longkey[i])));
        Result := Result + Next;
    end;
end;


begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    WriteLn(XorStr('The String', '1234567890'));
    WriteLn(XorStr(XorStr('The String', '1234567890'), '0987654321'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
