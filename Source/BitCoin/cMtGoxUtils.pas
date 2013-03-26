{$INCLUDE cMtGox.inc}

unit cMtGoxUtils;

interface

uses
  { Fundamentals }
  cJSON;



{ Conversion }

function MtGoxURLEncode(const S: AnsiString): AnsiString;

function MtGoxPriceToFloatStr(const Price: Extended): AnsiString;
function MtGoxPriceToIntStr(const Price: Extended): AnsiString;
function MtGoxAmountToFloatStr(const Amount: Extended): AnsiString;
function MtGoxAmountToIntStr(const Amount: Extended): AnsiString;



{ TMtGoxOrderType }

type
  TMtGoxOrderType = (
    mgotNone,
    mgotUnknown,
    mgotBuy,
    mgotSell);

function StrToMtGoxOrderType(const A: AnsiString): TMtGoxOrderType;



{ TMtGoxValue }

type
  TMtGoxValue = record
  public
    HasValue     : Boolean;
    ValueFloat   : Double;
    ValueInt     : Int64;
    Display      : AnsiString;
    DisplayShort : AnsiString;
    Currency     : AnsiString;
  end;

procedure MtGoxValueClear(var A: TMtGoxValue);
procedure MtGoxValueFromJSON(var A: TMtGoxValue; const B: TJSONObject);



{ TMtGoxTicker }

type
  TMtGoxTicker = record
  public
    HasValue  : Boolean;
    UpdatedAt : TDateTime;

    High      : TMtGoxValue;
    Low       : TMtGoxValue;
    Avg       : TMtGoxValue;
    VWAP      : TMtGoxValue;
    Vol       : TMtGoxValue;
    LastLocal : TMtGoxValue;
    Last      : TMtGoxValue;
    LastOrig  : TMtGoxValue;
    LastAll   : TMtGoxValue;
    Buy       : TMtGoxValue;
    Sell      : TMtGoxValue;
  end;

procedure MtGoxTickerClear(var A: TMtGoxTicker);
procedure MtGoxTickerFromJSON(var A: TMtGoxTicker; const B: TJSONObject);



{ TMtGoxWallet }

type
  TMtGoxWallet = record
  public
    HasValue             : Boolean;
    Balance              : TMtGoxValue;
    Operations           : Int64;
    DailyWithdrawLimit   : TMtGoxValue;
    MonthlyWithdrawLimit : TMtGoxValue;
    MaxWithdraw          : TMtGoxValue;
    OpenOrders           : TMtGoxValue;
  end;

procedure MtGoxWalletClear(var A: TMtGoxWallet);
procedure MtGoxWalletFromJSON(var A: TMtGoxWallet; const B: TJSONObject);



{ TMtGoxPrivateInfo }

type
  TMtGoxPrivateInfo = record
  public
    HasValue      : Boolean;
    Login         : AnsiString;
    Index         : AnsiString;
    Id            : AnsiString;
    Rights        : AnsiString;
    Language      : AnsiString;
    Created       : AnsiString;
    LastLogin     : AnsiString;
    WalletBTC     : TMtGoxWallet;
    WalletUSD     : TMtGoxWallet;
    MonthlyVolume : TMtGoxValue;
    TradeFee      : Double;
  end;

procedure MtGoxPrivateInfoClear(var A: TMtGoxPrivateInfo);
procedure MtGoxPrivateInfoFromJSON(var A: TMtGoxPrivateInfo; const B: TJSONObject);



{ TMtGoxDepthItem }

type
  TMtGoxDepthItem = record
  public
    HasValue    : Boolean;
    PriceFloat  : Double;
    AmountFloat : Double;
    PriceInt    : Int64;
    AmountInt   : Int64;
    Stamp       : AnsiString;
  end;
  PMtGoxDepthItem = ^TMtGoxDepthItem;
  TMtGoxDepthItemArray = array of TMtGoxDepthItem;

procedure MtGoxDepthItemClear(var A: TMtGoxDepthItem);
procedure MtGoxDepthItemFromJSON(var A: TMtGoxDepthItem; const B: TJSONObject);
procedure MtGoxDepthItemArrayFromJSON(var A: TMtGoxDepthItemArray; const B: TJSONArray);



{ TMtGoxDepth }

type
  TMtGoxDepth = record
  public
    HasValue       : Boolean;
    Asks           : TMtGoxDepthItemArray;
    Bids           : TMtGoxDepthItemArray;
    FilterMinPrice : TMtGoxValue;
    FilterMaxPrice : TMtGoxValue;
  end;

procedure MtGoxDepthClear(var A: TMtGoxDepth);
procedure MtGoxDepthFromJSON(var A: TMtGoxDepth; const B: TJSONObject);



{ TMtGoxOpenOrder }

type
  TMtGoxOpenOrder = record
    HasValue        : Boolean;
    OrderId         : AnsiString;
    Currency        : AnsiString;
    Item            : AnsiString;
    OrderType       : AnsiString;
    Amount          : TMtGoxValue;
    EffectiveAmount : TMtGoxValue;
    Price           : TMtGoxValue;
    Status          : AnsiString;
    Date            : AnsiString;
    Priority        : AnsiString;
    Actions         : AnsiString;
  end;
  TMtGoxOpenOrderArray = array of TMtGoxOpenOrder;

procedure MtGoxOpenOrderClear(var A: TMtGoxOpenOrder);
procedure MtGoxOpenOrderFromJSON(var A: TMtGoxOpenOrder; const B: TJSONObject);
procedure MtGoxOpenOrderArrayFromJSON(var A: TMtGoxOpenOrderArray; const B: TJSONObject);



{ Authentication }

function  MtGoxNonceGenerate: Int64;
function  MtGoxRestSignatureGenerate(const APISecret: AnsiString; const Msg: AnsiString): AnsiString;



implementation

uses
  { System }
  SysUtils,

  { Fundamentals }
  cUtils,
  cStrings,
  cHash;



{ Conversion                                                                   }

function MtGoxURLEncode(const S: AnsiString): AnsiString;
var R : AnsiString;
begin
  R := StrReplaceA('%', '%25', S);
  R := StrReplaceA('+', '%2B', R);
  R := StrReplaceA('-', '%2D', R);
  R := StrReplaceA('=', '%3D', R);
  R := StrReplaceA('&', '%26', R);
  R := StrReplaceA('?', '%3F', R);
  R := StrReplaceA(' ', '+', R);
  Result := R;
end;

// e.g. "price":70.48235
function MtGoxPriceToFloatStr(const Price: Extended): AnsiString;
begin
  Result := ToAnsiString(FloatToStrF(Price, ffFixed, 15, 5));
end;

// e.g. "price_int":"7048235"
function MtGoxPriceToIntStr(const Price: Extended): AnsiString;
begin
  Result := IntToStringA(Trunc(Price * 100000)); // 10^5
end;

// e.g. "amount":0.02240126
function MtGoxAmountToFloatStr(const Amount: Extended): AnsiString;
begin
  Result := ToAnsiString(FloatToStrF(Amount, ffFixed, 15, 8));
end;

// e.g. "amount_int":"2240126"
function MtGoxAmountToIntStr(const Amount: Extended): AnsiString;
begin
  Result := IntToStringA(Trunc(Amount * 100000000)); // 10^8
end;



{ TMtGoxOrderType                                                              }

function StrToMtGoxOrderType(const A: AnsiString): TMtGoxOrderType;
begin
  if StrEqualNoAsciiCaseA(A, 'bid') then
    Result := mgotBuy
  else
  if StrEqualNoAsciiCaseA(A, 'ask') then
    Result := mgotSell
  else
    Result := mgotUnknown;
end;



{ TMtGoxValue                                                                  }

procedure MtGoxValueClear(var A: TMtGoxValue);
begin
  A.HasValue     := False;
  A.ValueFloat   := 0.0;
  A.ValueInt     := 0;
  A.Display      := '';
  A.DisplayShort := '';
  A.Currency     := '';
end;

(*
  Examples:
  {"value":"1.00000","value_int":"100000","display":"$1.00000","display_short":"$1.00","currency":"USD"}
  {"value":"0.01000000","value_int":"1000000","display":"0.01000000 BTC","display_short":"0.01 BTC","currency":"BTC"}
*)
procedure MtGoxValueFromJSON(var A: TMtGoxValue; const B: TJSONObject);
begin
  if not Assigned(B) then
    begin
      MtGoxValueClear(A);
      exit;
    end;
  A.HasValue     := True;
  A.ValueFloat   := B.GetItemAsFloat('value', 0.0);
  A.ValueInt     := B.GetItemAsInt('value_int', 0);
  A.Display      := B.GetItemAsStrUTF8('display', '');
  A.DisplayShort := B.GetItemAsStrUTF8('display_short', '');
  A.Currency     := B.GetItemAsStrUTF8('currency', '');
end;



{ TMtGoxTicker                                                                 }

procedure MtGoxTickerClear(var A: TMtGoxTicker);
begin
  A.HasValue := False;
  A.UpdatedAt := 0.0;
  MtGoxValueClear(A.High);
  MtGoxValueClear(A.Low);
  MtGoxValueClear(A.Avg);
  MtGoxValueClear(A.VWAP);
  MtGoxValueClear(A.Vol);
  MtGoxValueClear(A.LastLocal);
  MtGoxValueClear(A.Last);
  MtGoxValueClear(A.LastOrig);
  MtGoxValueClear(A.LastAll);
  MtGoxValueClear(A.Buy);
  MtGoxValueClear(A.Sell);
end;

(*
  Examples:
  {
   "result":"success",
   "return":
       {
        "high":{"value":"73.74999","value_int":"7374999","display":"$73.75","display_short":"$73.75","currency":"USD"},
        "low":{"value":"65.88000","value_int":"6588000","display":"$65.88","display_short":"$65.88","currency":"USD"},
        "avg":{"value":"71.52697","value_int":"7152697","display":"$71.53","display_short":"$71.53","currency":"USD"},
        "vwap":{"value":"71.29410","value_int":"7129410","display":"$71.29","display_short":"$71.29","currency":"USD"},
        "vol":{"value":"68088.46052488","value_int":"6808846052488","display":"68,088.46\u00a0BTC","display_short":"68,088.46\u00a0BTC","currency":"BTC"},
        "last_local":{"value":"65.88000","value_int":"6588000","display":"$65.88","display_short":"$65.88","currency":"USD"},
        "last":{"value":"65.88000","value_int":"6588000","display":"$65.88","display_short":"$65.88","currency":"USD"},
        "last_orig":{"value":"65.88000","value_int":"6588000","display":"$65.88","display_short":"$65.88","currency":"USD"},
        "last_all":{"value":"65.88000","value_int":"6588000","display":"$65.88","display_short":"$65.88","currency":"USD"},
        "buy":{"value":"65.88000","value_int":"6588000","display":"$65.88","display_short":"$65.88","currency":"USD"},
        "sell":{"value":"66.00000","value_int":"6600000","display":"$66.00","display_short":"$66.00","currency":"USD"},
        "now":"1363986571521539"
       }
  }
*)
procedure MtGoxTickerFromJSON(var A: TMtGoxTicker; const B: TJSONObject);
var T : TJSONObject;
begin
  Assert(Assigned(B));
  T := B.GetItemAsObject('return');
  if not Assigned(T) then
    begin
      MtGoxTickerClear(A);
      exit;
    end;
  A.HasValue := True;
  A.UpdatedAt := Now;
  MtGoxValueFromJSON(A.High, T.GetItemAsObject('high'));
  MtGoxValueFromJSON(A.Low, T.GetItemAsObject('low'));
  MtGoxValueFromJSON(A.Avg, T.GetItemAsObject('avg'));
  MtGoxValueFromJSON(A.VWAP, T.GetItemAsObject('vwap'));
  MtGoxValueFromJSON(A.Vol, T.GetItemAsObject('vol'));
  MtGoxValueFromJSON(A.LastLocal, T.GetItemAsObject('last_local'));
  MtGoxValueFromJSON(A.Last, T.GetItemAsObject('last'));
  MtGoxValueFromJSON(A.LastOrig, T.GetItemAsObject('last_orig'));
  MtGoxValueFromJSON(A.LastAll, T.GetItemAsObject('last_all'));
  MtGoxValueFromJSON(A.Buy, T.GetItemAsObject('buy'));
  MtGoxValueFromJSON(A.Sell, T.GetItemAsObject('sell'));
end;



{ TMtGoxWallet                                                                 }

procedure MtGoxWalletClear(var A: TMtGoxWallet);
begin
  A.HasValue := False;
  MtGoxValueClear(A.Balance);
  A.Operations := 0;
  MtGoxValueClear(A.DailyWithdrawLimit);
  MtGoxValueClear(A.MonthlyWithdrawLimit);
  MtGoxValueClear(A.MaxWithdraw);
  MtGoxValueClear(A.OpenOrders);
end;

(*
  Examples:
  {
   "Balance":{"value":"0.00000000","value_int":"0","display":"0.00000000 BTC","display_short":"0.00 BTC","currency":"BTC"},
   "Operations":0,
   "Daily_Withdraw_Limit":{"value":"100.00000000","value_int":"10000000000","display":"100.00000000 BTC","display_short":"100.00 BTC","currency":"BTC"},
   "Monthly_Withdraw_Limit":null,
   "Max_Withdraw":{"value":"100.00000000","value_int":"10000000000","display":"100.00000000 BTC","display_short":"100.00 BTC","currency":"BTC"},
   "Open_Orders":{"value":"0.00000000","value_int":"0","display":"0.00000000 BTC","display_short":"0.00 BTC","currency":"BTC"}
  }
*)
procedure MtGoxWalletFromJSON(var A: TMtGoxWallet; const B: TJSONObject);
begin
  if not Assigned(B) then
    begin
      MtGoxWalletClear(A);
      exit;
    end;
  A.HasValue := True;
  MtGoxValueFromJSON(A.Balance, B.GetItemAsObject('Balance'));
  A.Operations := B.GetItemAsInt('Operations', 0);
  MtGoxValueFromJSON(A.DailyWithdrawLimit, B.GetItemAsObject('Daily_Withdraw_Limit'));
  MtGoxValueFromJSON(A.MonthlyWithdrawLimit, B.GetItemAsObject('Monthly_Withdraw_Limit'));
  MtGoxValueFromJSON(A.MaxWithdraw, B.GetItemAsObject('Max_Withdraw'));
  MtGoxValueFromJSON(A.OpenOrders, B.GetItemAsObject('Open_Orders'));
end;



{ TMtGoxPrivateInfo                                                            }

procedure MtGoxPrivateInfoClear(var A: TMtGoxPrivateInfo);
begin
  A.HasValue      := False;
  A.Login         := '';
  A.Index         := '';
  A.Id            := '';
  A.Rights        := '';
  A.Language      := '';
  A.Created       := '';
  A.LastLogin     := '';
  MtGoxWalletClear(A.WalletBTC);
  MtGoxWalletClear(A.WalletUSD);
  MtGoxValueClear(A.MonthlyVolume);
  A.TradeFee      := 0.0;
end;

(*
  Examples:

  {
   "result":"success",
   "return":
       {
        "Login":"testacc731",
        "Index":"326313",
        "Id":"d736acba-290b-4ba7-a894-8d71aedf8105",
        "Rights":["deposit","get_info","merchant","trade","withdraw"],
        "Language":"en_US",
        "Created":"2013-03-23 00:44:26",
        "Last_Login":"2013-03-23 01:12:01",
        "Wallets":
            {
             "BTC":
                {"Balance":{"value":"0.00000000","value_int":"0","display":"0.00000000 BTC","display_short":"0.00 BTC","currency":"BTC"},
                 "Operations":0,
                 "Daily_Withdraw_Limit":{"value":"100.00000000","value_int":"10000000000","display":"100.00000000 BTC","display_short":"100.00 BTC","currency":"BTC"},
                 "Monthly_Withdraw_Limit":null,
                 "Max_Withdraw":{"value":"100.00000000","value_int":"10000000000","display":"100.00000000 BTC","display_short":"100.00 BTC","currency":"BTC"},
                 "Open_Orders":{"value":"0.00000000","value_int":"0","display":"0.00000000 BTC","display_short":"0.00 BTC","currency":"BTC"}
                },
             "USD":
                {"Balance":{"value":"0.00000","value_int":"0","display":"$0.00000","display_short":"$0.00","currency":"USD"},
                 "Operations":0,
                 "Daily_Withdraw_Limit":{"value":"1000.00000","value_int":"100000000","display":"$1,000.00000","display_short":"$1,000.00","currency":"USD"},
                 "Monthly_Withdraw_Limit":{"value":"10000.00000","value_int":"1000000000","display":"$10,000.00000","display_short":"$10,000.00","currency":"USD"},
                 "Max_Withdraw":{"value":"1000.00000","value_int":"100000000","display":"$1,000.00000","display_short":"$1,000.00","currency":"USD"},
                 "Open_Orders":{"value":"0.00000","value_int":"0","display":"$0.00000","display_short":"$0.00","currency":"USD"}
                }
            },
        "Monthly_Volume":
            {"value":"0.00000000","value_int":"0","display":"0.00000000 BTC","display_short":"0.00 BTC","currency":"BTC"},
        "Trade_Fee":0.6
       }
  }
*)
procedure MtGoxPrivateInfoFromJSON(var A: TMtGoxPrivateInfo; const B: TJSONObject);
var R : TJSONObject;
    W : TJSONObject;
begin
  Assert(Assigned(B));
  R := B.GetItemAsObject('return');
  if not Assigned(R) then
    begin
      MtGoxPrivateInfoClear(A);
      exit;
    end;
  A.HasValue := True;
  A.Login := R.GetItemAsStrUTF8('Login');
  A.Index := R.GetItemAsStrUTF8('Index');
  A.Id := R.GetItemAsStrUTF8('Id');
  A.Rights := R.Item['Id'].GetJSONStringUTF8;
  A.Language := R.GetItemAsStrUTF8('Language');
  A.Created := R.GetItemAsStrUTF8('Created');
  A.LastLogin := R.GetItemAsStrUTF8('Last_Login');
  MtGoxValueFromJSON(A.MonthlyVolume, R.GetItemAsObject('Monthly_Volume'));
  A.TradeFee := R.GetItemAsFloat('Trade_Fee');
  W := R.GetItemAsObject('Wallets');
  if Assigned(W) then
    begin
      MtGoxWalletFromJSON(A.WalletBTC, W.GetItemAsObject('BTC'));
      MtGoxWalletFromJSON(A.WalletUSD, W.GetItemAsObject('USD'));
    end
  else
    begin
      MtGoxWalletClear(A.WalletBTC);
      MtGoxWalletClear(A.WalletUSD);
    end;
end;



{ TMtGoxDepthItem                                                              }

(*
  Examples:
  {"price":70.48235,"amount":0.02240126,"price_int":"7048235","amount_int":"2240126","stamp":"1363998978875084"}
*)

procedure MtGoxDepthItemClear(var A: TMtGoxDepthItem);
begin
  A.HasValue    := False;
  A.PriceFloat  := 0.0;
  A.AmountFloat := 0.0;
  A.PriceInt    := 0;
  A.AmountInt   := 0;
  A.Stamp       := '';
end;

procedure MtGoxDepthItemFromJSON(var A: TMtGoxDepthItem; const B: TJSONObject);
begin
  if not Assigned(B) then
    begin
      MtGoxDepthItemClear(A);
      exit;
    end;
  A.HasValue    := True;
  A.PriceFloat  := B.GetItemAsFloat('price', 0.0);
  A.AmountFloat := B.GetItemAsFloat('amount', 0.0);
  A.PriceInt    := B.GetItemAsInt('price_int', 0);
  A.AmountInt   := B.GetItemAsInt('amount_int', 0);
  A.Stamp       := B.GetItemAsStrUTF8('stamp', '');
end;

procedure MtGoxDepthItemArrayFromJSON(var A: TMtGoxDepthItemArray; const B: TJSONArray);
var I, L : Integer;
begin
  if not Assigned(B) then
    begin
      SetLength(A, 0);
      exit;
    end;
  L := B.Count;
  SetLength(A, L);
  for I := 0 to L - 1 do
     MtGoxDepthItemFromJSON(A[I], B.ItemAsObject[I]);
end;



{ TMtGoxDepth                                                                  }

procedure MtGoxDepthClear(var A: TMtGoxDepth);
begin
  A.HasValue := False;
  SetLength(A.Asks, 0);
  SetLength(A.Bids, 0);
  MtGoxValueClear(A.FilterMinPrice);
  MtGoxValueClear(A.FilterMaxPrice);
end;

(*
  Example:
  {"result":"success",
   "return":
       {"asks":[{"price":70.48235,"amount":0.02240126,"price_int":"7048235","amount_int":"2240126","stamp":"1363998978875084"},
                {"price":70.48236,"amount":2.87991,"price_int":"7048236","amount_int":"287991000","stamp":"1363998978171700"},
                .....
        "bids":[{"price":63.021,"amount":5,"price_int":"6302100","amount_int":"500000000","stamp":"1363844096112944"},
                {"price":63.02474,"amount":0.257,"price_int":"6302474","amount_int":"25700000","stamp":"1363823957419739"},
   "filter_min_price":{"value":"63.01139","value_int":"6301139","display":"$63.01","display_short":"$63.01","currency":"USD"},
   "filter_max_price":{"value":"77.01393","value_int":"7701393","display":"$77.01","display_short":"$77.01","currency":"USD"}
  }}
*)

procedure MtGoxDepthFromJSON(var A: TMtGoxDepth; const B: TJSONObject);
var R : TJSONObject;
begin
  if not Assigned(B) then
    begin
      MtGoxDepthClear(A);
      exit;
    end;
  R := B.GetItemAsObject('return');
  if not Assigned(R) then
    begin
      MtGoxDepthClear(A);
      exit;
    end;
  A.HasValue := True;
  MtGoxDepthItemArrayFromJSON(A.Asks, B.GetItemAsArray('asks'));
  MtGoxDepthItemArrayFromJSON(A.Bids, B.GetItemAsArray('bids'));
  MtGoxValueFromJSON(A.FilterMinPrice, B.GetItemAsObject('filter_min_price'));
  MtGoxValueFromJSON(A.FilterMaxPrice, B.GetItemAsObject('filter_max_price'));
end;



{ TMtGoxOpenOrder }

procedure MtGoxOpenOrderClear(var A: TMtGoxOpenOrder);
begin
  A.HasValue        := False;
  A.OrderId         := '';
  A.Currency        := '';
  A.Item            := '';
  A.OrderType       := '';
  MtGoxValueClear(A.Amount);
  MtGoxValueClear(A.EffectiveAmount);
  MtGoxValueClear(A.Price);
  A.Status          := '';
  A.Date            := '';
  A.Priority        := '';
  A.Actions         := '';
end;

(*
  Examples:
  {"result":"success","return":[]}

  {"result":"success",
   "return":[
       {"oid":"df208e2d-fa82-4ca3-a200-677050901ef5",
        "currency":"USD",
        "item":"BTC",
        "type":"bid",
        "amount":
            {"value":"0.01000000","value_int":"1000000","display":"0.01000000 BTC","display_short":"0.01 BTC","currency":"BTC"},
        "effective_amount":
            {"value":"0.01000000","value_int":"1000000","display":"0.01000000 BTC","display_short":"0.01 BTC","currency":"BTC"},
        "price":
            {"value":"1.00000","value_int":"100000","display":"$1.00000","display_short":"$1.00","currency":"USD"},
        "status":"invalid",
        "date":1364012167,
        "priority":"1364012167507134",
        "actions":[]
       }]
  }
*)

procedure MtGoxOpenOrderFromJSON(var A: TMtGoxOpenOrder; const B: TJSONObject);
begin
  if not Assigned(B) then
    begin
      MtGoxOpenOrderClear(A);
      exit;
    end;
  A.HasValue := True;
  A.OrderId := B.GetItemAsStrUTF8('oid', '');
  A.Currency := B.GetItemAsStrUTF8('currency', '');
  A.Item := B.GetItemAsStrUTF8('item', '');
  A.OrderType := B.GetItemAsStrUTF8('type', '');
  MtGoxValueFromJSON(A.Amount, B.GetItemAsObject('amount'));
  MtGoxValueFromJSON(A.EffectiveAmount, B.GetItemAsObject('effective_amount'));
  MtGoxValueFromJSON(A.Price, B.GetItemAsObject('price'));
  A.Status := B.GetItemAsStrUTF8('status', '');
  A.Date := B.GetItemAsStrUTF8('date', '');
  A.Priority := B.GetItemAsStrUTF8('priority', '');
  A.Actions := B.Item['actions'].GetJSONStringUTF8;
end;

procedure MtGoxOpenOrderArrayFromJSONArray(var A: TMtGoxOpenOrderArray; const B: TJSONArray);
var I, L : Integer;
begin
  if not Assigned(B) then
    begin
      SetLength(A, 0);
      exit;
    end;
  L := B.Count;
  SetLength(A, L);
  for I := 0 to L - 1 do
     MtGoxOpenOrderFromJSON(A[I], B.ItemAsObject[I]);
end;

procedure MtGoxOpenOrderArrayFromJSON(var A: TMtGoxOpenOrderArray; const B: TJSONObject);
var R : TJSONArray;
begin
  R := B.GetItemAsArray('return');
  if not Assigned(R) then
    begin
      SetLength(A, 0);
      exit;
    end;
  MtGoxOpenOrderArrayFromJSONArray(A, R);
end;

{ Nonce                                                                        }

function MtGoxNonceGenerate: Int64;
var TS : TTimeStamp;
    N : Int64;
begin
  TS := DateTimeToTimeStamp(Now);
  // ensure positive
  N :=
      (Int64(TS.Date) shl 33) or
      (Int64(TS.Time) shl 1);
  N := N shr 1;
  Result := N;
end;

// base64encode( HMAC hash( base64decoded(API-secret), the nonce, with SHA512 digest))
function MtGoxRestSignatureGenerate(const APISecret: AnsiString; const Msg: AnsiString): AnsiString;
var Secret : AnsiString;
begin
  Secret := MIMEBase64Decode(APISecret);
  Result :=
      MIMEBase64Encode(
          SHA512DigestToStrA(
              CalcHMAC_SHA512(Secret, Msg)));
  SecureClearStrA(Secret);
end;



end.

