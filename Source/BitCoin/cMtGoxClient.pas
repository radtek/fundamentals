{******************************************************************************}
{                                                                              }
{  2011/06/16  0.01  Initial development.                                      }
{  2011/06/17  0.02  Further development.                                      }
{  2011/06/18  0.03  Test cases.                                               }
{  2011/07/16  0.04  Updated for API changes.                                  }
{  2013/03/22  0.05  Overhaul for new HTTP API v1.                             }
{                                                                              }
{ References:                                                                  }
{ * https://en.bitcoin.it/wiki/MtGox/API/HTTP/v1                               }
{                                                                              }
{******************************************************************************}

{$INCLUDE cMtGox.inc}

unit cMtGoxClient;

interface

uses
  { System }
  SyncObjs,
  { Fundamentals }
  cHTTPUtils,
  cHTTPClient,
  cJSON,
  { BitCoin }
  cMtGoxUtils;



{ TMtGoxClient }

type
  TMtGoxHTTPClientType = (
    mghTicker,
    mghDepth,
    mghPrivateInfo,
    mghOpenOrders,
    mghBuyOrder,
    mghSellOrder,
    mghWithdraw);

  TMtGoxClientLogType = (
    mgltDebug,
    mgltInfo,
    mgltError);

  TMtGoxHTTPClient = class
  private
    FJSONParser : TJSONParser;
    FHTTPClient : TF4HTTPClient;

  public
    constructor Create;
    destructor Destroy; override;

    property JSONParser: TJSONParser read FJSONParser;
    property HTTPClient: TF4HTTPClient read FHTTPClient;
  end;

  TMtGoxClient = class;

  TMtGoxClientEvent = procedure (const Sender: TMtGoxClient) of object;
  TMtGoxClientLogEvent = procedure (const Sender: TMtGoxClient; const LogType: TMtGoxClientLogType; const LogMsg: AnsiString; const LogLevel: Integer) of object;
  TMtGoxClientErrorEvent = procedure (const Sender: TMtGoxClient; const ClientType: TMtGoxHTTPClientType; const ErrorMsg: AnsiString) of object;

  TMtGoxClient = class
  protected
    FOnLog         : TMtGoxClientLogEvent;
    FOnError       : TMtGoxClientErrorEvent;
    FOnTicker      : TMtGoxClientEvent;
    FOnDepth       : TMtGoxClientEvent;
    FOnPrivateInfo : TMtGoxClientEvent;
    FOnOpenOrders  : TMtGoxClientEvent;

    FAPIKey    : AnsiString;
    FAPISecret : AnsiString;

    FLock         : TCriticalSection;
    FHTTPClients  : array[TMtGoxHTTPClientType] of TMtGoxHTTPClient;
    FLoc          : AnsiString;
    FCookies      : THTTPSetCookieFieldArray;
    FCookie       : AnsiString;
    FTicker       : TMtGoxTicker;
    FDepth        : TMtGoxDepth;
    FPrivateInfo  : TMtGoxPrivateInfo;
    FOpenOrders   : TMtGoxOpenOrderArray;

    procedure Init; virtual;
    procedure InitHTTPClient(const ClientType: TMtGoxHTTPClientType); virtual;
    procedure InitHTTPClients;

    procedure Log(const LogType: TMtGoxClientLogType; const LogMsg: AnsiString; const LogLevel: Integer = 0);

    procedure Lock;
    procedure Unlock;

    function  GetHTTPClient(const ClientType: TMtGoxHTTPClientType; const PostFields: array of AnsiString): TF4HTTPClient;

    procedure HTTPClientContentBuffer(Client: TF4HTTPClient; const Buf; const Size: Integer);
    procedure HTTPClientContentComplete(Client: TF4HTTPClient);
    procedure HTTPClientLog(Client: TF4HTTPClient; LogType: THTTPClientLogType; Msg: String; Level: Integer);

    procedure TriggerError(const ClientType: TMtGoxHTTPClientType; const ErrorMsg: AnsiString);
    procedure TriggerTicker;
    procedure TriggerDepth;
    procedure TriggerPrivateInfo;
    procedure TriggerOpenOrders;

    procedure ProcessErrorResponse(const I: TMtGoxHTTPClientType; const ErrorMsg: AnsiString);

    procedure ProcessContent_Ticker(const C: TJSONObject);
    procedure ProcessContent_Depth(const C: TJSONObject);
    procedure ProcessContent_PrivateInfo(const C: TJSONObject);
    procedure ProcessContent_OpenOrders(const C: TJSONObject);
    procedure ProcessContent_BuyOrder(const C: TJSONObject);
    procedure ProcessContent_SellOrder(const C: TJSONObject);
    procedure ProcessContent_Withdraw(const C: TJSONObject);
    procedure ProcessContent(const Client: TF4HTTPClient; const I: TMtGoxHTTPClientType; const C: TJSONObject);

  public
    constructor Create;
    destructor Destroy; override;

    property  OnLog: TMtGoxClientLogEvent read FOnLog write FOnLog;
    property  OnError: TMtGoxClientErrorEvent read FOnError write FOnError;
    property  OnTicker: TMtGoxClientEvent read FOnTicker write FOnTicker;
    property  OnDepth: TMtGoxClientEvent read FOnDepth write FOnDepth;
    property  OnPrivateInfo: TMtGoxClientEvent read FOnPrivateInfo write FOnPrivateInfo;
    property  OnOpenOrders: TMtGoxClientEvent read FOnOpenOrders write FOnOpenOrders;

    property  APIKey: AnsiString read FAPIKey write FAPIKey;
    property  APISecret: AnsiString read FAPISecret write FAPISecret;

    procedure RequestTicker;
    procedure RequestDepth;
    procedure RequestPrivateInfo;
    procedure RequestOpenOrders;
    procedure RequestBuyOrder(const Amount, Price: Extended);
    procedure RequestSellOrder(const Amount, Price: Extended);
    procedure RequestWithdrawal(const BitCoinAddress: AnsiString; const Amount: Extended);

    property  Ticker: TMtGoxTicker read FTicker;
    property  Depth: TMtGoxDepth read FDepth;
    property  PrivateInfo: TMtGoxPrivateInfo read FPrivateInfo;
    property  OpenOrders: TMtGoxOpenOrderArray read FOpenOrders;
  end;



implementation

uses
  { System }
  SysUtils,
  Variants,
  { Fundamentals }
  cUtils,
  cStrings,
  cHash,
  { BitCoin }
  cBitCoinUtils;



{ Utilities }

const
  SMtGoxHTTPClientType : array[TMtGoxHTTPClientType] of AnsiString = (
    'Ticker',
    'Depth',
    'PrivateInfo',
    'OpenOrders',
    'BuyOrder',
    'SellOrder',
    'Withdraw');



{ TMtGoxHTTPClient }

constructor TMtGoxHTTPClient.Create;
begin
  inherited Create;
  FJSONParser := TJSONParser.Create;
  FHTTPClient := TF4HTTPClient.Create(nil);
end;

destructor TMtGoxHTTPClient.Destroy;
begin
  FreeAndNil(FHTTPClient);
  FreeAndNil(FJSONParser);
  inherited Destroy;
end;



{ TMtGoxClient }

constructor TMtGoxClient.Create;
begin
  inherited Create;
  Init;
end;

destructor TMtGoxClient.Destroy;
var I : TMtGoxHTTPClientType;
begin
  for I := High(TMtGoxHTTPClientType) downto Low(TMtGoxHTTPClientType) do
    FreeAndNil(FHTTPClients[I]);
  FreeAndNil(FLock);
  inherited Destroy;
end;

procedure TMtGoxClient.Init;
begin
  MtGoxTickerClear(FTicker);
  MtGoxPrivateInfoClear(FPrivateInfo);
  FLock := TCriticalSection.Create;
  InitHTTPClients;
end;

const
  HTTPClientMethod : array[TMtGoxHTTPClientType] of THTTPClientMethod =
    (
      cmGET,
      cmGET,
      cmPOST,
      cmPOST,
      cmPOST,
      cmPOST,
      cmPOST
    );

  HTTPClientURI : array[TMtGoxHTTPClientType] of AnsiString =
    (
      '/api/1/BTCUSD/ticker',
      '/api/1/BTCUSD/depth/fetch',
      '/api/1/generic/private/info',
      '/api/1/generic/private/orders',
      '/api/1/BTCUSD/private/order/add',
      '/api/1/BTCUSD/private/order/add',
      '/api/1/generic/bitcoin/send_simple'
    );

  HTTPClientAuthRequired : array[TMtGoxHTTPClientType] of Boolean =
    (
      False,
      False,
      True,
      True,
      True,
      True,
      True
    );

procedure TMtGoxClient.InitHTTPClient(const ClientType: TMtGoxHTTPClientType);
var G : TMtGoxHTTPClient;
    H : TF4HTTPClient;
begin
  G := TMtGoxHTTPClient.Create;
  FHTTPClients[ClientType] := G;
  H := G.FHTTPClient;
  H.UserTag := Ord(ClientType);
  H.OnResponseContentBuffer := HTTPClientContentBuffer;
  H.OnResponseContentComplete := HTTPClientContentComplete;
  H.OnLog := HTTPClientLog;
  H.Host := 'data.mtgox.com';
  H.UserAgent := 'Mozilla/5.0 (compatible; Fundamentals/4.0; MtGoxClient/0.1; Experimental)';
  H.KeepAlive := kaDefault;
  H.UseHTTPS := True;
  H.Port := '443';
  H.ResponseContentMechanism := hcrmString;
  H.Method := HTTPClientMethod[ClientType];
end;

procedure TMtGoxClient.InitHTTPClients;
var I : TMtGoxHTTPClientType;
begin
  for I := Low(TMtGoxHTTPClientType) to High(TMtGoxHTTPClientType) do
    InitHTTPClient(I);
end;

procedure TMtGoxClient.Log(const LogType: TMtGoxClientLogType; const LogMsg: AnsiString; const LogLevel: Integer);
begin
  if Assigned(FOnLog) then
    FOnLog(self, LogType, LogMsg, LogLevel);
end;

procedure TMtGoxClient.Lock;
begin
  if Assigned(FLock) then
    FLock.Acquire;
end;

procedure TMtGoxClient.Unlock;
begin
  if Assigned(FLock) then
    FLock.Release;
end;

function TMtGoxClient.GetHTTPClient(
         const ClientType: TMtGoxHTTPClientType;
         const PostFields: array of AnsiString): TF4HTTPClient;
var Clnt    : TF4HTTPClient;
    Nonce   : Int64;
    NonceS  : AnsiString;
    RestSgn : AnsiString;
    URI     : AnsiString;
    I, L    : Integer;
    FlNam   : AnsiString;
    FlVal   : AnsiString;
    ParmStr : AnsiString;
begin
  Lock;
  try
    Clnt := FHTTPClients[ClientType].FHTTPClient;
    URI := HTTPClientURI[ClientType];

    if HTTPClientAuthRequired[ClientType] then
      begin
        Nonce := mtGoxNonceGenerate;
        NonceS := IntToStringA(Nonce);

        // parameters
        Clnt.SetRequestContentWwwFormUrlEncodedField('nonce', MtGoxURLEncode(NonceS));
        L := Length(PostFields);
        Assert(L mod 2 = 0);
        I := 0;
        while I < L - 1 do
          begin
            FlNam := PostFields[I];
            FlVal := MtGoxURLEncode(PostFields[I + 1]);
            Inc(I, 2);
            Clnt.SetRequestContentWwwFormUrlEncodedField(FlNam, FlVal);
          end;
        ParmStr := Clnt.RequestContentStr;

        // signature
        RestSgn := MtGoxRestSignatureGenerate(FAPISecret, ParmStr);

        // headers
        Clnt.CustomHeader['Rest-Key'] := FAPIKey;
        Clnt.CustomHeader['Rest-Sign'] := RestSgn;
      end;

    Clnt.URI := URI;
    Clnt.Cookie := FCookie;
  finally
    Unlock;
  end;
  Result := Clnt;

  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[ClientType] + ':HTTP:URI:' + Clnt.URI);
  Log(mgltDebug, SMtGoxHTTPClientType[ClientType] + ':HTTP:Content:' + Clnt.RequestContentStr);
  Log(mgltDebug, SMtGoxHTTPClientType[ClientType] + ':HTTP:Cookie:' + Clnt.Cookie);
  {$ENDIF}
end;

procedure TMtGoxClient.HTTPClientContentBuffer(Client: TF4HTTPClient; const Buf; const Size: Integer);
begin
end;

(*
  Error response examples:
  {"error":"Not logged in."}
  {"error":"Invalid."}
  {"error":"Invalid oid/type, received values are 0/0."}
  Success response examples:
  {"result":"success","return":  ...... }
*)
procedure TMtGoxClient.HTTPClientContentComplete(Client: TF4HTTPClient);
var I : TMtGoxHTTPClientType;
    S : AnsiString;
    P : TJSONParser;
    C : TJSONValue;
    D : TJSONObject;
    E : AnsiString;
begin
  I := TMtGoxHTTPClientType(Client.UserTag);
  S := FHTTPClients[I].HTTPClient.ResponseContentStr;
  P := FHTTPClients[I].FJSONParser;
  C := P.ParseText(ToWideString(ToStringA(S)));
  try
    if not (C is TJSONObject) then
      begin
        E := 'Invalid JSON response: object expected';
        ProcessErrorResponse(I, E);
      end
    else
      begin
        D := TJSONObject(C);
        if D.Exists('error') then
          begin
            E := D.GetItemAsStrUTF8('error', '');
            ProcessErrorResponse(I, E);
          end
        else
          begin
            E := D.GetItemAsStrUTF8('result', '');
            if not StrEqualNoAsciiCaseA(E, 'success') then
              ProcessErrorResponse(I, E)
            else
              ProcessContent(Client, I, D);
          end;
      end;
  finally
    C.Free;
  end;
end;

procedure TMtGoxClient.HTTPClientLog(Client: TF4HTTPClient; LogType: THTTPClientLogType; Msg: String; Level: Integer);
var I : TMtGoxHTTPClientType;
begin
  I := TMtGoxHTTPClientType(Client.UserTag);
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[I] + ':HTTP:' + ToAnsiString(Msg), Level + 1);
  {$ENDIF}
end;

procedure TMtGoxClient.TriggerError(const ClientType: TMtGoxHTTPClientType; const ErrorMsg: AnsiString);
begin
  if Assigned(FOnError) then
    FOnError(self, ClientType, ErrorMsg);
end;

procedure TMtGoxClient.TriggerPrivateInfo;
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghPrivateInfo] + ':Notify');
  {$ENDIF}
  if Assigned(FOnPrivateInfo) then
    FOnPrivateInfo(self);
end;

procedure TMtGoxClient.TriggerTicker;
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghTicker] + ':Notify');
  {$ENDIF}
  if Assigned(FOnTicker) then
    FOnTicker(self);
end;

procedure TMtGoxClient.TriggerDepth;
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghDepth] + ':Notify');
  {$ENDIF}
  if Assigned(FOnDepth) then
    FOnDepth(self);
end;

procedure TMtGoxClient.TriggerOpenOrders;
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghOpenOrders] + ':Notify');
  {$ENDIF}
  if Assigned(FOnOpenOrders) then
    FOnOpenOrders(self);
end;

procedure TMtGoxClient.ProcessErrorResponse(const I: TMtGoxHTTPClientType; const ErrorMsg: AnsiString);
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[I] + ':Error:' + ErrorMsg);
  {$ENDIF}
  Lock;
  try
    //
  finally
    Unlock;
  end;
  TriggerError(I, ErrorMsg);
end;

procedure TMtGoxClient.ProcessContent_Ticker(const C: TJSONObject);
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghTicker] + ':Process');
  {$ENDIF}
  Lock;
  try
    MtGoxTickerFromJSON(FTicker, C);
  finally
    Unlock;
  end;
  TriggerTicker;
end;

procedure TMtGoxClient.ProcessContent_Depth(const C: TJSONObject);
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghDepth] + ':Process');
  {$ENDIF}
  Lock;
  try
    MtGoxDepthFromJSON(FDepth, C);
  finally
    Unlock;
  end;
  TriggerDepth;
end;

procedure TMtGoxClient.ProcessContent_PrivateInfo(const C: TJSONObject);
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghPrivateInfo] + ':Process');
  {$ENDIF}
  Lock;
  try
    MtGoxPrivateInfoFromJSON(FPrivateInfo, C);
  finally
    Unlock;
  end;
  TriggerPrivateInfo;
end;

procedure TMtGoxClient.ProcessContent_OpenOrders(const C: TJSONObject);
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghOpenOrders] + ':Process');
  {$ENDIF}
  Lock;
  try
    MtGoxOpenOrderArrayFromJSON(FOpenOrders, C);
  finally
    Unlock;
  end;
  TriggerOpenOrders;
end;

procedure TMtGoxClient.ProcessContent_BuyOrder(const C: TJSONObject);
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghBuyOrder] + ':Process');
  {$ENDIF}
  Lock;
  try
    ////
  finally
    Unlock;
  end;
  ////
end;

procedure TMtGoxClient.ProcessContent_SellOrder(const C: TJSONObject);
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghSellOrder] + ':Process');
  {$ENDIF}
  Lock;
  try
    ////
  finally
    Unlock;
  end;
  ////
end;

procedure TMtGoxClient.ProcessContent_Withdraw(const C: TJSONObject);
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghWithdraw] + ':Process');
  {$ENDIF}
end;

procedure TMtGoxClient.ProcessContent(const Client: TF4HTTPClient; const I: TMtGoxHTTPClientType; const C: TJSONObject);
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[I] + ':JSON:');
  Log(mgltDebug, Copy(C.GetJSONStringUTF8, 1, 1024));
  {$ENDIF}
  case I of
    mghTicker      : ProcessContent_Ticker(C);
    mghDepth       : ProcessContent_Depth(C);
    mghPrivateInfo : ProcessContent_PrivateInfo(C);
    mghOpenOrders  : ProcessContent_OpenOrders(C);
    mghBuyOrder    : ProcessContent_BuyOrder(C);
    mghSellOrder   : ProcessContent_SellOrder(C);
    mghWithdraw    : ProcessContent_Withdraw(C);
  end;
end;

procedure TMtGoxClient.RequestTicker;
var H : TF4HTTPClient;
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghTicker] + ':Request');
  {$ENDIF}
  H := GetHTTPClient(mghTicker, []);
  H.Request;
end;

procedure TMtGoxClient.RequestDepth;
var H : TF4HTTPClient;
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghDepth] + ':Request');
  {$ENDIF}
  H := GetHTTPClient(mghDepth, []);
  H.Request;
end;

procedure TMtGoxClient.RequestPrivateInfo;
var H : TF4HTTPClient;
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghPrivateInfo] + ':Request');
  {$ENDIF}
  H := GetHTTPClient(mghPrivateInfo, []);
  H.Request;
end;

procedure TMtGoxClient.RequestOpenOrders;
var H : TF4HTTPClient;
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghOpenOrders] + ':Request');
  {$ENDIF}
  H := GetHTTPClient(mghOpenOrders, []);
  H.Request;
end;

procedure TMtGoxClient.RequestBuyOrder(const Amount, Price: Extended);
var H : TF4HTTPClient;
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghBuyOrder] + ':Request');
  {$ENDIF}
  H := GetHTTPClient(mghBuyOrder, [
      'type', 'bid',
      'amount_int', MtGoxAmountToIntStr(Amount),
      'price_int', MtGoxPriceToIntStr(Price)
      ]);
  H.Request;
end;

procedure TMtGoxClient.RequestSellOrder(const Amount, Price: Extended);
var H : TF4HTTPClient;
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghSellOrder] + ':Request');
  {$ENDIF}
  H := GetHTTPClient(mghSellOrder, [
      'type', 'ask',
      'amount_int', MtGoxAmountToIntStr(Amount),
      'price_int', MtGoxPriceToIntStr(Price)
      ]);
  H.Request;
end;

procedure TMtGoxClient.RequestWithdrawal(const BitCoinAddress: AnsiString; const Amount: Extended);
var H : TF4HTTPClient;
begin
  {$IFDEF MTGOX_DEBUG}
  Log(mgltDebug, SMtGoxHTTPClientType[mghWithdraw] + ':Request');
  {$ENDIF}
  H := GetHTTPClient(mghWithdraw, [
      'btca', BitCoinAddress,
      'amount', BTCAmountToStr(Amount)
      ]);
  H.Request;
end;



end.

