program PipeHuntR;

{$APPTYPE CONSOLE}
{$R *.res}

// credits go to https://delphi.xcjc.net/viewthread.php?tid=49656&extra=page%3D2
// and credits go https://gist.github.com/nstarke/02c57823f473702186e1db94dca8edae
// Russell: pipes (use threads to read and write data via named pipes)
// Solid code base to draw insp from

uses
  Windows, SysUtils, Classes, Messages;



// localized constant string declarations (Resource Strings)
resourcestring
  resPipeBaseName   =  '\\.\pipe\';
  resPipeBaseFmtName=  '\\%s\pipe\';



begin
  try
    //test comment here
    //goal , enumerate local named pipes
    WriteLn('PipeHuntR start');
    //BAD http://www.delphibasics.co.uk/RTL.asp?Name=fileexists&ExpandCode1=Yes
    //pipes as files



    // START
    var
        Info : TSearchRec;

    begin

            if FindFirst(WorkingDir + '*.note', faAnyFile and faDirectory, Info)=0 then begin
                    repeat
                            DoSomething(WorkingDir, Info.Name);
                    until FindNext(Info) <> 0;
            end;
            FindClose(Info);
    end;
    // END






  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
