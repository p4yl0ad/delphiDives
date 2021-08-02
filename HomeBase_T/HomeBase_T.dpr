program HomeBase_T;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Hash;


function genmd5(plaintext : string) : string;
begin
  Result := THashMD5.GetHashString(plaintext);
end;


function generate(cantidad: integer): string;
const
  letras_mi = 'abcdefghijklmnopqrstuvwxyz';
  numeros = '0123456789';
begin
  SetLength(Result, 3); // only alloc memory once

  Result[1] := letras_mi[Random(Length(letras_mi)) + 1];
  Result[2] := UpCase(letras_mi[Random(Length(letras_mi)) + 1]);
  Result[3] := numeros[Random(Length(numeros)) + 1];
end;

function GenerateRandomWord(CONST Len: Integer=16; StartWithVowel: Boolean= FALSE): string;
CONST
   sVowels: string= 'AEIOUY';
   sConson: string= 'BCDFGHJKLMNPQRSTVWXZ';
VAR
   i: Integer;
   B: Boolean;
begin
  B:= StartWithVowel;
  SetLength(Result, Len);
  for i:= 1 to len DO
   begin
    if B
    then Result[i]:= sVowels[Random(Length(sVowels)) + 1]
    else Result[i]:= sConson[Random(Length(sConson)) + 1];
    B:= NOT B;
   end;
end;


begin
try
  WriteLn('[+] SeaShell1 :');
  WriteLn(GenerateRandomWord(10));
  WriteLn(genmd5(GenerateRandomWord(10)));

  WriteLn('[+] SeaShell2 :');
  WriteLn(GenerateRandomWord(10));
  WriteLn(genmd5(GenerateRandomWord(10)));
except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
