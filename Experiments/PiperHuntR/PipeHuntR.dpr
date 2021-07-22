program PipeHuntR;

{$APPTYPE CONSOLE}
{$R *.res}

// credits go to https://delphi.xcjc.net/viewthread.php?tid=49656&extra=page%3D2
// Russell: pipes (use threads to read and write data via named pipes)
// Solid code base to draw insp from

uses
  Windows, SysUtils, Classes, Messages;

////////////////////////////////////////////////////////////////////////////////
//   Resource strings
////////////////////////////////////////////////////////////////////////////////
resourcestring
  resThreadCtx      =  'The notify window and the component window do not exist in the same thread!';
  resPipeActive     =  'Cannot change property while server is active!';
  resPipeConnected  =  'Cannot change property when client is connected!';
  resBadPipeName    =  'Invalid pipe name specified!';
  resPipeBaseName   =  '\\.\pipe\';
  resPipeBaseFmtName=  '\\%s\pipe\';
  resPipeName       =  'PipeServer';
  resConClass       =  'ConsoleWindowClass';
  resComSpec        =  'ComSpec';


begin
  try
    //test comment here
    //goal , enumerate local named pipes
    WriteLn('PipeHuntR');


  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
