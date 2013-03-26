{$INCLUDE cMtGox.inc}

unit cMtGoxClientTests;

interface



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DEBUG}{$IFDEF SELFTEST}
procedure SelfTest;
{$ENDIF}{$ENDIF}



implementation

uses
  SysUtils,
  SyncObjs,
  cMtGoxClient;

{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DEBUG}{$IFDEF SELFTEST}
{$ASSERTIONS ON}
type
  TMtGoxClient_TestObj = class
    FLock : TCriticalSection;
    constructor Create;
    destructor Destroy; override;
    procedure ClientLog(const Sender: TMtGoxClient; const LogType: TMtGoxClientLogType; const LogMsg: AnsiString; const LogLevel: Integer);
  end;

constructor TMtGoxClient_TestObj.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
end;

destructor TMtGoxClient_TestObj.Destroy;
begin
  FreeAndNil(FLock);
  inherited Destroy;
end;

procedure TMtGoxClient_TestObj.ClientLog(const Sender: TMtGoxClient;
  const LogType: TMtGoxClientLogType; const LogMsg: AnsiString; const LogLevel: Integer);
begin
  FLock.Acquire;
  try
    Writeln(FormatDateTime('hh:nn:ss', Now), ' ', LogLevel, ':', LogMsg);
  finally
    FLock.Release;
  end;
end;

procedure SelfTest_Client;
var T : TMtGoxClient_TestObj;
    C : TMtGoxClient;
begin
  T := TMtGoxClient_TestObj.Create;
  C := TMtGoxClient.Create;
  try
    C.OnLog := T.ClientLog;

    C.Username := 'testacc731';
    C.Password := 'g723x@a82512';
    C.APIKey := '283b77e6-5eb3-4e1e-8116-565d1d67943b';
    C.APISecret := '4ijkI+QbPM5SU2vLA00cuyzU0IGmyjLXd3cODhmJZqD4DYGkKl/t/Iycmoq1y/xBqtVAtOUSBKLpakka7VE06Q==';

    // C.RequestDepth;
    //C.RequestPrivateInfo;
    C.RequestOpenOrders;
    // C.RequestTicker;
    //C.RequestBuyOrder(0.01, 0.02);

    Sleep(60 * 1000);

  finally
    C.Free;
    T.Free;
  end;
end;

procedure SelfTest;
begin
  SelfTest_Client;
end;
{$ENDIF}{$ENDIF}

end.

