program PipeHunt_R;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  {$IFDEF UNIX}
  {$IFDEF UseCThreads}
  cthreads,
  {$ENDIF }
  {$ENDIF }
  Classes,
  sysutils;

// START
var
  Info : TSearchRec;
  ListDir : string;

begin
  ListDir:='\\.\pipe\';
  If FindFirst (ListDir+'*',faAnyFile and faDirectory,Info)=0 then
  begin
    repeat
      with Info do
      begin
        If (Attr and faDirectory) = faDirectory then
          Write('Dir : ');
        Writeln(ListDir+Name:40);
      end;
    until FindNext(info)<>0;
  end;
  FindClose(Info);
  Writeln ('Finished pipe hunt');
end.
