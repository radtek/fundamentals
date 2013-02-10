program ProtoTest1;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  pbTest1Messages in 'pbTest1Messages.pas',
  cUtils in '..\..\Utils\cUtils.pas',
  cProtoBufUtils in '..\cProtoBufUtils.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
