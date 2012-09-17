{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals TLS                                         }
{   File name:        cTLSServer.pas                                           }
{   File version:     0.02                                                     }
{   Description:      TLS server                                               }
{                                                                              }
{   Copyright:        Copyright (c) 2008-2012, David J Butler                  }
{                     All rights reserved.                                     }
{   E-mail:           fundamentals.tls@gmail.com                               }
{                                                                              }
{   DUAL LICENSE                                                               }
{                                                                              }
{   This source code is released under a dual license:                         }
{                                                                              }
{       1.  The GNU General Public License (GPL)                               }
{       2.  Commercial license                                                 }
{                                                                              }
{   By using this source code in your application (directly or indirectly,     }
{   statically or dynamically linked) your application is subject to this      }
{   dual license.                                                              }
{                                                                              }
{   If you choose the GPL, your application is also subject to the GPL.        }
{   You are required to release the source code of your application            }
{   publicly when you distribute it. Distribution includes giving it away      }
{   or using it in a commercial environment. To distribute an application      }
{   under the GPL it must not use any non open-source components.              }
{                                                                              }
{   If you do not wish your application to be bound by the GPL, you can        }
{   acquire a commercial license from the author.                              }
{                                                                              }
{   GPL LICENSE                                                                }
{                                                                              }
{   This program is free software: you can redistribute it and/or modify       }
{   it under the terms of the GNU General Public License as published by       }
{   the Free Software Foundation, either version 3 of the License, or          }
{   (at your option) any later version.                                        }
{                                                                              }
{   This program is distributed in the hope that it will be useful,            }
{   but WITHOUT ANY WARRANTY; without even the implied warranty of             }
{   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              }
{   GNU General Public License for more details.                               }
{                                                                              }
{   For the full terms of the GPL, see:                                        }
{                                                                              }
{         http://www.gnu.org/licenses/                                         }
{     or  http://opensource.org/licenses/GPL-3.0                               }
{                                                                              }
{   COMMERCIAL LICENSE                                                         }
{                                                                              }
{   To use this component for commercial purposes, please visit:               }
{                                                                              }
{         http://www.eternallines.com/fndtls/                                  }
{                                                                              }
{ Revision history:                                                            }
{                                                                              }
{   2010/12/02  0.01  Initial development.                                     }
{   2010/12/15  0.02  Development. Simple client server test case.             }
{                                                                              }
{ Todo:                                                                        }
{ - Server options for cipher and compression selection.                       }
{ - SSL3 can only select SHA1 and MD5 hash.                                    }
{******************************************************************************}

{$INCLUDE cTLS.inc}

unit cTLSServer;

interface

uses
  { System }
  SyncObjs,
  { Cipher }
  cCipherRSA,
  { X509 }
  cX509Certificate,
  { PEM }
  cPEM,
  { TLS }
  cTLSUtils,
  cTLSCipherSuite,
  cTLSAlert,
  cTLSHandshake,
  cTLSConnection;



{                                                                              }
{ TLS Server                                                                   }
{                                                                              }
type
  TTLSServer = class;

  TTLSServerClientState = (
    tlsscInit,
    tlsscHandshakeAwaitingClientHello,
    tlsscHandshakeAwaitingClientKeyExchange,
    tlsscHandshakeAwaitingFinish,
    tlsscConnection);

  TTLSServerClient = class(TTLSConnection)
  protected
    FServer  : TTLSServer;
    FUserObj : TObject;

    FClientState          : TTLSServerClientState;
    FSessionID            : AnsiString;
    FCipherSuite          : TTLSCipherSuite;
    FCompression          : TTLSCompressionMethod;
    FClientHello          : TTLSClientHello;
    FClientHelloRandomStr : AnsiString;
    FServerHello          : TTLSServerHello;
    FServerHelloRandomStr : AnsiString;
    FClientKeyExchange    : TTLSClientKeyExchange;
    FPreMasterSecret      : AnsiString;
    FMasterSecret         : AnsiString;

    procedure TriggerLog(const LogType: TTLSLogType; const LogMsg: String; const LogLevel: Integer); override;
    procedure TriggerConnectionStateChange; override;
    procedure TriggerAlert(const Level: TTLSAlertLevel; const Description: TTLSAlertDescription); override;
    procedure TriggerHandshakeFinished; override;

    procedure SetClientState(const State: TTLSServerClientState);

    procedure TransportLayerSendProc(const Sender: TTLSConnection; const Buffer; const Size: Integer);

    procedure SelectCompression(var Compression: TTLSCompressionMethod);
    procedure SelectCipherSuite(var CipherSuite: TTLSCipherSuite);

    procedure InitProtocolVersion;
    procedure InitHandshakeServerHello;

    procedure SendHandshakeHelloRequest;
    procedure SendHandshakeServerHello;
    procedure SendHandshakeCertificate;
    procedure SendHandshakeServerKeyExchange;
    procedure SendHandshakeCertificateRequest;
    procedure SendHandshakeServerHelloDone;
    procedure SendHandshakeFinished;

    procedure HandleHandshakeClientHello(const Buffer; const Size: Integer);
    procedure HandleHandshakeCertificateVerify(const Buffer; const Size: Integer);
    procedure HandleHandshakeClientKeyExchange(const Buffer; const Size: Integer);
    procedure HandleHandshakeFinished(const Buffer; const Size: Integer);
    procedure HandleHandshakeMessage(const MsgType: TTLSHandshakeType; const Buffer; const Size: Integer); override;

    procedure InitCipherSpecNone;
    procedure DoStart;

  public
    constructor Create(const Server: TTLSServer; const UserObj: TObject);

    property  UserObj: TObject read FUserObj;
    procedure Start;
  end;

  TTLSServerOptions = set of (
    tlssoDontUseSSL3,
    tlssoDontUseTLS10,
    tlssoDontUseTLS11,
    tlssoDontUseTLS12);

  TTLSServerState = (
    tlssInit,
    tlssActive,
    tlssStopped);

  TTLServerTransportLayerSendProc = procedure (Server: TTLSServer; Client: TTLSServerClient; const Buffer; const Size: Integer) of object;
  TTLSServerNotifyEvent = procedure (Sender: TTLSServer) of object;
  TTLSServerLogEvent = procedure (Sender: TTLSServer; LogType: TTLSLogType; LogMsg: String) of object;
  TTLSServerClientEvent = procedure (Sender: TTLSServer; Client: TTLSServerClient) of object;
  TTLSServerClientAlertEvent = procedure (Sender: TTLSServer; Client: TTLSServerClient; Level: TTLSAlertLevel; Description: TTLSAlertDescription) of object;

  TTLSServer = class
  protected
    FOnLog                     : TTLSServerLogEvent;
    FOnClientStateChange       : TTLSServerClientEvent;
    FOnClientAlert             : TTLSServerClientAlertEvent;
    FOnClientHandshakeFinished : TTLSServerClientEvent;
    FTransportLayerSendProc    : TTLServerTransportLayerSendProc;
    FOptions                   : TTLSServerOptions;
    FCertificateList           : TTLSCertificateList;
    FPrivateKeyRSA             : AnsiString;
    FPEMFileName               : String;
    FPEMText                   : AnsiString;

    FLock              : TCriticalSection;
    FState             : TTLSServerState;
    FClients           : array of TTLSServerClient;
    FX509RSAPrivateKey : TX509RSAPrivateKey;
    FRSAPrivateKey     : TRSAPrivateKey;

    procedure Init; virtual;

    procedure Lock;
    procedure Unlock;

    procedure Log(const LogType: TTLSLogType; const LogMsg: String; const LogLevel: Integer = 0); virtual;

    procedure CheckNotActive;
    procedure CheckActive;

    procedure SetOptions(const Options: TTLSServerOptions);
    procedure SetCertificateList(const List: TTLSCertificateList);
    procedure SetPrivateKeyRSA(const PrivateKeyRSA: AnsiString);
    function  GetPrivateKeyRSAPEM: AnsiString;
    procedure SetPrivateKeyRSAPEM(const PrivateKeyRSAPEM: AnsiString);
    procedure SetPEMFileName(const PEMFileName: String);
    procedure SetPEMText(const PEMText: AnsiString);

    procedure ClientLog(const Client: TTLSServerClient; const LogType: TTLSLogType; const LogMsg: String; const LogLevel: Integer);
    procedure ClientStateChange(const Client: TTLSServerClient);
    procedure ClientAlert(const Client: TTLSServerClient; const Level: TTLSAlertLevel; const Description: TTLSAlertDescription);
    procedure ClientHandshakeFinished(const Client: TTLSServerClient);

    function  CreateClient(const UserObj: TObject): TTLSServerClient; virtual;
    function  GetClientCount: Integer;
    function  GetClient(const Idx: Integer): TTLSServerClient;
    function  GetClientIndex(const Client: TTLSServerClient): Integer;

    procedure ClientTransportLayerSend(const Sender: TTLSServerClient; const Buffer; const Size: Integer);

    procedure InitFromPEM;
    procedure InitPrivateKey;
    procedure AllocateSessionID(var SessionID: AnsiString);

    procedure DoStart;
    procedure DoStop;

  public
    constructor Create(const TransportLayerSendProc: TTLServerTransportLayerSendProc);
    destructor Destroy; override;

    property  OnLog: TTLSServerLogEvent read FOnLog write FOnLog;
    property  OnClientAlert: TTLSServerClientAlertEvent read FOnClientAlert write FOnClientAlert;
    property  OnClientStateChange: TTLSServerClientEvent read FOnClientStateChange write FOnClientStateChange;
    property  OnClientHandshakeFinished: TTLSServerClientEvent read FOnClientHandshakeFinished write FOnClientHandshakeFinished;

    property  Options: TTLSServerOptions read FOptions write SetOptions;
    property  CertificateList: TTLSCertificateList read FCertificateList write SetCertificateList;
    property  PrivateKeyRSA: AnsiString read FPrivateKeyRSA write SetPrivateKeyRSA;
    property  PrivateKeyRSAPEM: AnsiString read GetPrivateKeyRSAPEM write SetPrivateKeyRSAPEM;
    property  PEMFileName: String read FPEMFileName write SetPEMFileName;
    property  PEMText: AnsiString read FPEMText write SetPEMText;

    property  State: TTLSServerState read FState;
    procedure Start;
    procedure Stop;

    property  ClientCount: Integer read GetClientCount;
    property  Client[const Idx: Integer]: TTLSServerClient read GetClient;
    function  AddClient(const UserObj: TObject): TTLSServerClient;
    procedure RemoveClient(const Client: TTLSServerClient);
    
    procedure ProcessTransportLayerReceivedData(const Client: TTLSServerClient; const Buffer; const Size: Integer);
  end;



implementation

uses
  { System }
  SysUtils,
  { Fundamentals }
  cUtils,
  { Cipher }
  cCipherRandom,
  { TLS }
  cTLSCipher;



{                                                                              }
{ TLS Server Client                                                            }
{                                                                              }
constructor TTLSServerClient.Create(const Server: TTLSServer; const UserObj: TObject);
begin
  Assert(Assigned(Server));
  inherited Create(TransportLayerSendProc);
  FServer := Server;
  FUserObj := UserObj;
end;

procedure TTLSServerClient.TriggerLog(const LogType: TTLSLogType; const LogMsg: String; const LogLevel: Integer);
begin
  inherited;
  FServer.ClientLog(self, LogType, LogMsg, LogLevel);
end;

procedure TTLSServerClient.TriggerConnectionStateChange;
begin
  inherited;
  FServer.ClientStateChange(self);
end;

procedure TTLSServerClient.TriggerAlert(const Level: TTLSAlertLevel; const Description: TTLSAlertDescription);
begin
  inherited;
  FServer.ClientAlert(self, Level, Description);
end;

procedure TTLSServerClient.TriggerHandshakeFinished;
begin
  inherited;
  FServer.ClientHandshakeFinished(self);
end;

procedure TTLSServerClient.SetClientState(const State: TTLSServerClientState);
begin
  FClientState := State;
end;

procedure TTLSServerClient.TransportLayerSendProc(const Sender: TTLSConnection; const Buffer; const Size: Integer);
begin
  FServer.ClientTransportLayerSend(self, Buffer, Size);
end;

procedure TTLSServerClient.SelectCompression(var Compression: TTLSCompressionMethod);
begin
  Compression := tlscmNull;
end;

procedure TTLSServerClient.SelectCipherSuite(var CipherSuite: TTLSCipherSuite);
var I : TTLSCipherSuite;
    C : PTLSCipherSuiteInfo;
begin
  for I := High(TTLSCipherSuite) downto Low(TTLSCipherSuite) do
    if (I <> tlscsNone) and (I in FClientHello.CipherSuites) then
      begin
        C := @TLSCipherSuiteInfo[I];
        if C^.ServerSupport then
          begin
            CipherSuite := I;
            exit;
          end;
      end;
  CipherSuite := tlscsNone;
end;

procedure TTLSServerClient.InitProtocolVersion;
begin
  FProtocolVersion := FClientHello.ProtocolVersion;
  if IsSSL2(FProtocolVersion) then
    raise ETLSAlertError.Create(tlsadProtocol_version); // SSL2 not supported
  if IsFutureTLSVersion(FProtocolVersion) then
    FProtocolVersion := TLSProtocolVersion12;
  if not IsKnownTLSVersion(FProtocolVersion) then
    raise ETLSAlertError.Create(tlsadProtocol_version); // unknown SSL version
end;

procedure TTLSServerClient.InitHandshakeServerHello;
begin
  InitTLSServerHello(FServerHello,
      FProtocolVersion,
      FSessionID,
      FCipherSpecNew.CipherSuiteDetails.CipherSuiteInfo^.Rec,
      FCompression);
  FServerHelloRandomStr := TLSRandomToStr(FServerHello.Random);
end;

const
  MaxHandshakeHelloRequestSize       = 2048;
  MaxHandshakeServerHelloSize        = 2048;
  MaxHandshakeCertificateSize        = 65536;
  MaxHandshakeServerKeyExchangeSize  = 16384;
  MaxHandshakeCertificateRequestSize = 16384;
  MaxHandshakeServerHelloDoneSize    = 16384;
  MaxHandshakeFinishedSize           = 2048;

procedure TTLSServerClient.SendHandshakeHelloRequest;
var B : array[0..MaxHandshakeHelloRequestSize - 1] of Byte;
    L : Integer;
begin
  L := EncodeTLSHandshakeHelloRequest(B, SizeOf(B));
  SendHandshake(B, L);
end;

procedure TTLSServerClient.SendHandshakeServerHello;
var B : array[0..MaxHandshakeServerHelloSize - 1] of Byte;
    L : Integer;
begin
  InitHandshakeServerHello;
  L := EncodeTLSHandshakeServerHello(B, SizeOf(B), FServerHello);
  SendHandshake(B, L);
end;

procedure TTLSServerClient.SendHandshakeCertificate;
var B : array[0..MaxHandshakeCertificateSize - 1] of Byte;
    L : Integer;
begin
  L := EncodeTLSHandshakeCertificate(B, SizeOf(B), FServer.FCertificateList);
  SendHandshake(B, L);
end;

procedure TTLSServerClient.SendHandshakeServerKeyExchange;
var B : array[0..MaxHandshakeServerKeyExchangeSize - 1] of Byte;
    L : Integer;
    K : TTLSServerKeyExchange;
begin
  L := EncodeTLSHandshakeServerKeyExchange(B, SizeOf(B),
      FCipherSpecNew.KeyExchangeAlgorithm, K);
  SendHandshake(B, L);
end;

procedure TTLSServerClient.SendHandshakeCertificateRequest;
var B : array[0..MaxHandshakeCertificateRequestSize - 1] of Byte;
    L : Integer;
    R : TTLSCertificateRequest;
begin
  L := EncodeTLSHandshakeCertificateRequest(B, SizeOf(B), R);
  SendHandshake(B, L);
end;

procedure TTLSServerClient.SendHandshakeServerHelloDone;
var B : array[0..MaxHandshakeServerHelloDoneSize - 1] of Byte;
    L : Integer;
begin
  L := EncodeTLSHandshakeServerHelloDone(B, SizeOf(B));
  SendHandshake(B, L);
end;

procedure TTLSServerClient.SendHandshakeFinished;
var B : array[0..MaxHandshakeFinishedSize - 1] of Byte;
    L : Integer;
begin
  L := EncodeTLSHandshakeFinished(B, SizeOf(B), FMasterSecret, FProtocolVersion, FVerifyHandshakeData, False);
  SendHandshake(B, L);
end;

procedure TTLSServerClient.HandleHandshakeClientHello(const Buffer; const Size: Integer);
begin
  if FClientState <> tlsscHandshakeAwaitingClientHello then
    raise ETLSAlertError.Create(tlsadUnexpected_message);
  DecodeTLSClientHello(Buffer, Size, FClientHello);
  FClientHelloRandomStr := TLSRandomToStr(FClientHello.Random);
  InitProtocolVersion;
  SelectCompression(FCompression);
  SelectCipherSuite(FCipherSuite);
  if FCipherSuite = tlscsNone then
    raise ETLSAlertError.Create(tlsadHandshake_failure);
  InitTLSSecurityParameters(FCipherSpecNew, FCompression, FCipherSuite);
  SetClientState(tlsscHandshakeAwaitingClientKeyExchange);
  SendHandshakeServerHello;
  SendHandshakeCertificate;
  SendHandshakeServerKeyExchange;
  SendHandshakeServerHelloDone;
end;

procedure TTLSServerClient.HandleHandshakeCertificateVerify(const Buffer; const Size: Integer);
begin
  if FClientState <> tlsscHandshakeAwaitingClientKeyExchange then
    raise ETLSAlertError.Create(tlsadUnexpected_message);
end;

procedure TTLSServerClient.HandleHandshakeClientKeyExchange(const Buffer; const Size: Integer);
begin
  if FClientState <> tlsscHandshakeAwaitingClientKeyExchange then
    raise ETLSAlertError.Create(tlsadUnexpected_message);
  DecodeTLSClientKeyExchange(Buffer, Size,
      FCipherSpecNew.KeyExchangeAlgorithm,
      False, FClientKeyExchange);
  case FCipherSpecNew.KeyExchangeAlgorithm of
    tlskeaRSA :
      begin
        FPreMasterSecret := RSADecryptStr(rsaetPKCS1, FServer.FRSAPrivateKey,
            FClientKeyExchange.EncryptedPreMasterSecret);
        FMasterSecret := TLSMasterSecret(FProtocolVersion, FPreMasterSecret,
            FClientHelloRandomStr, FServerHelloRandomStr);
        GenerateTLSKeys(FProtocolVersion,
            FCipherSpecNew.CipherSuiteDetails.HashInfo^.KeyLength,
            FCipherSpecNew.CipherSuiteDetails.CipherInfo^.KeyBits,
            FCipherSpecNew.CipherSuiteDetails.CipherInfo^.IVSize * 8,
            FMasterSecret,
            FServerHelloRandomStr,
            FClientHelloRandomStr,
            FKeys);
        GenerateFinalTLSKeys(FProtocolVersion,
            FCipherSpecNew.CipherSuiteDetails.CipherInfo^.Exportable,
            FCipherSpecNew.CipherSuiteDetails.CipherInfo^.ExpKeyMat * 8,
            FServerHelloRandomStr,
            FClientHelloRandomStr,
            FKeys);
        SetEncodeKeys(FKeys.ServerMACKey, FKeys.ServerEncKey, FKeys.ServerIV);
        SetDecodeKeys(FKeys.ClientMACKey, FKeys.ClientEncKey, FKeys.ClientIV);
      end;
  end;
  SetClientState(tlsscHandshakeAwaitingFinish);
end;

procedure TTLSServerClient.HandleHandshakeFinished(const Buffer; const Size: Integer);
begin
  if FClientState <> tlsscHandshakeAwaitingFinish then
    raise ETLSAlertError.Create(tlsadUnexpected_message);
  SendChangeCipherSpec;
  ChangeEncryptCipherSpec;
  SetClientState(tlsscConnection);
  SetConnectionState(tlscoApplicationData);
  SendHandshakeFinished;
  TriggerHandshakeFinished;
end;

procedure TTLSServerClient.HandleHandshakeMessage(const MsgType: TTLSHandshakeType; const Buffer; const Size: Integer);
begin
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'R:Handshake:' + TLSHandshakeTypeToStr(MsgType));
  {$ENDIF}
  case MsgType of
    tlshtHello_request       : ShutdownBadProtocol(tlsadUnexpected_message);
    tlshtClient_hello        : HandleHandshakeClientHello(Buffer, Size);
    tlshtServer_hello        : ShutdownBadProtocol(tlsadUnexpected_message);
    tlshtCertificate         : ShutdownBadProtocol(tlsadUnexpected_message);
    tlshtServer_key_exchange : ShutdownBadProtocol(tlsadUnexpected_message);
    tlshtCertificate_request : ShutdownBadProtocol(tlsadUnexpected_message);
    tlshtServer_hello_done   : ShutdownBadProtocol(tlsadUnexpected_message);
    tlshtCertificate_verify  : HandleHandshakeCertificateVerify(Buffer, Size);
    tlshtClient_key_exchange : HandleHandshakeClientKeyExchange(Buffer, Size);
    tlshtFinished            : HandleHandshakeFinished(Buffer, Size);
  else
    ShutdownBadProtocol(tlsadUnexpected_message);
  end;
end;

procedure TTLSServerClient.InitCipherSpecNone;
begin
  InitTLSSecurityParametersNone(FCipherEncryptSpec);
  InitTLSSecurityParametersNone(FCipherDecryptSpec);
  TLSCipherInitNone(FCipherEncryptState, tlscoEncrypt);
  TLSCipherInitNone(FCipherDecryptState, tlscoDecrypt);
end;

procedure TTLSServerClient.DoStart;
begin
  SetConnectionState(tlscoStart);
  InitCipherSpecNone;
  SetConnectionState(tlscoHandshaking);
  SetClientState(tlsscHandshakeAwaitingClientHello);
  FServer.AllocateSessionID(FSessionID);
end;

procedure TTLSServerClient.Start;
begin
  Assert(FConnectionState = tlscoInit);
  Assert(FClientState = tlsscInit);
  DoStart;
end;



{                                                                              }
{ TLS Server                                                                   }
{                                                                              }
constructor TTLSServer.Create(const TransportLayerSendProc: TTLServerTransportLayerSendProc);
begin
  inherited Create;
  Init;
  if not Assigned(TransportLayerSendProc) then
    raise ETLSError.Create(TLSError_InvalidParameter);
  FTransportLayerSendProc := TransportLayerSendProc;
end;

procedure TTLSServer.Init;
begin
  FOptions := [];
  FState := tlssInit;
  FLock := TCriticalSection.Create;
  RSAPrivateKeyInit(FRSAPrivateKey);
end;

destructor TTLSServer.Destroy;
var I : Integer;
begin
  for I := Length(FClients) - 1 downto 0 do
    FreeAndNil(FClients[I]);
  RSAPrivateKeyFinalise(FRSAPrivateKey);
  FreeAndNil(FLock);
  inherited Destroy;
end;

procedure TTLSServer.Lock;
begin
  Assert(Assigned(FLock));
  FLock.Acquire;
end;

procedure TTLSServer.Unlock;
begin
  FLock.Release;
end;

procedure TTLSServer.Log(const LogType: TTLSLogType; const LogMsg: String; const LogLevel: Integer);
begin
  if Assigned(FOnLog) then
    FOnLog(self, LogType, LogMsg);
end;

procedure TTLSServer.CheckNotActive;
begin
  if FState = tlssActive then
    raise ETLSError.Create(TLSError_InvalidState, 'Operation not allowed while active');
end;

procedure TTLSServer.CheckActive;
begin
  if FState <> tlssActive then
    raise ETLSError.Create(TLSError_InvalidState, 'Operation not allowed while not active');
end;

procedure TTLSServer.SetOptions(const Options: TTLSServerOptions);
begin
  if Options = FOptions then
    exit;
  CheckNotActive;
  FOptions := Options;
end;

procedure TTLSServer.SetCertificateList(const List: TTLSCertificateList);
begin
  CheckNotActive;
  FCertificateList := Copy(List);
end;

procedure TTLSServer.SetPrivateKeyRSA(const PrivateKeyRSA: AnsiString);
begin
  if PrivateKeyRSA = FPrivateKeyRSA then
    exit;
  CheckNotActive;
  FPrivateKeyRSA := PrivateKeyRSA;
end;

function TTLSServer.GetPrivateKeyRSAPEM: AnsiString;
begin
  Result := MIMEBase64Encode(PrivateKeyRSA);
end;

procedure TTLSServer.SetPrivateKeyRSAPEM(const PrivateKeyRSAPEM: AnsiString);
begin
  SetPrivateKeyRSA(MIMEBase64Decode(PrivateKeyRSAPEM));
end;

procedure TTLSServer.SetPEMFileName(const PEMFileName: String);
begin
  if PEMFileName = FPEMFileName then
    exit;
  CheckNotActive;
  FPEMFileName := PEMFileName;
end;

procedure TTLSServer.SetPEMText(const PEMText: AnsiString);
begin
  if PEMText = FPEMText then
    exit;
  CheckNotActive;
  FPEMText := PEMText;
end;

procedure TTLSServer.ClientLog(const Client: TTLSServerClient; const LogType: TTLSLogType; const LogMsg: String; const LogLevel: Integer);
begin
  Log(LogType, 'C:' + LogMsg, LogLevel + 1);
end;

procedure TTLSServer.ClientStateChange(const Client: TTLSServerClient);
begin
  if Assigned(FOnClientStateChange) then
    FOnClientStateChange(self, Client);
end;

procedure TTLSServer.ClientAlert(const Client: TTLSServerClient; const Level: TTLSAlertLevel; const Description: TTLSAlertDescription);
begin
  if Assigned(FOnClientAlert) then
    FOnClientAlert(self, Client, Level, Description);
end;

procedure TTLSServer.ClientHandshakeFinished(const Client: TTLSServerClient);
begin
  if Assigned(FOnClientHandshakeFinished) then
    FOnClientHandshakeFinished(self, Client);
end;

function TTLSServer.CreateClient(const UserObj: TObject): TTLSServerClient;
begin
  Result := TTLSServerClient.Create(self, UserObj);
end;

function TTLSServer.GetClientCount: Integer;
begin
  Result := Length(FClients);
end;

function TTLSServer.GetClient(const Idx: Integer): TTLSServerClient;
begin
  Assert(Idx >= 0);
  Assert(Idx < Length(FClients));
  Result := FClients[Idx];
end;

function TTLSServer.GetClientIndex(const Client: TTLSServerClient): Integer;
var I : Integer;
begin
  for I := 0 to Length(FClients) - 1 do
    if FClients[I] = Client then
      begin
        Result := I;
        exit;
      end;
  Result := -1;
end;

function TTLSServer.AddClient(const UserObj: TObject): TTLSServerClient;
var L : Integer;
    C : TTLSServerClient;
begin
  CheckActive;
  C := CreateClient(UserObj);
  Lock;
  try
    L := Length(FClients);
    SetLength(FClients, L + 1);
    FClients[L] := C;
  finally
    Unlock;
  end;
  Result := C;
end;

procedure TTLSServer.RemoveClient(const Client: TTLSServerClient);
var I, J, L : Integer;
begin
  Lock;
  try
    I := GetClientIndex(Client);
    if I < 0 then
      raise ETLSError.Create(TLSError_InvalidParameter);
    L := Length(FClients);
    for J := I to L - 2 do
      FClients[J] := FClients[J + 1];
    SetLength(FClients, L - 1);
  finally
    Unlock;
  end;
  Client.Free;
end;

procedure TTLSServer.ClientTransportLayerSend(const Sender: TTLSServerClient; const Buffer; const Size: Integer);
begin
  Assert(Assigned(FTransportLayerSendProc));
  Assert(Size > 0);
  FTransportLayerSendProc(self, Sender, Buffer, Size);
end;

procedure TTLSServer.ProcessTransportLayerReceivedData(const Client: TTLSServerClient; const Buffer; const Size: Integer);
begin
  if not Assigned(Client) then
    raise ETLSError.Create(TLSError_InvalidParameter);
  Client.ProcessTransportLayerReceivedData(Buffer, Size);
end;

procedure TTLSServer.InitFromPEM;
var P : TPEMFile;
    L, I : Integer;
begin
  if (FPEMFileName = '') and (FPEMText = '') then
    exit;
  P := TPEMFile.Create;
  try
    if FPEMFileName <> '' then
      P.LoadFromFile(FPEMFileName)
    else
      P.LoadFromText(FPEMText);
    FPrivateKeyRSA := P.RSAPrivateKey;
    L := P.CertificateCount;
    SetLength(FCertificateList, L);
    for I := 0 to L - 1 do
      FCertificateList[I] := P.Certificate[I];
  finally
    P.Free;
  end;
end;

procedure TTLSServer.InitPrivateKey;
var L1, L2 : Integer;
begin
  if FPrivateKeyRSA = '' then
    raise ETLSError.Create(TLSError_InvalidCertificate, 'No private key');
  ParseX509RSAPrivateKeyStr(FPrivateKeyRSA, FX509RSAPrivateKey);
  L1 := NormaliseX509IntKeyBuf(FX509RSAPrivateKey.Modulus);
  L2 := NormaliseX509IntKeyBuf(FX509RSAPrivateKey.PrivateExponent);
  if L2 > L1 then
    L1 := L2;
  RSAPrivateKeyAssignBufStr(FRSAPrivateKey, L1 * 8,
      FX509RSAPrivateKey.Modulus,
      FX509RSAPrivateKey.PrivateExponent);
end;

procedure TTLSServer.AllocateSessionID(var SessionID: AnsiString);
begin
  SessionID := SecureRandomStr(TLSSessionIDMaxLen);
end;

procedure TTLSServer.DoStart;
begin
  Assert(FState <> tlssActive);
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'Start');
  {$ENDIF}
  InitFromPEM;
  InitPrivateKey;
  FState := tlssActive;
end;

procedure TTLSServer.DoStop;
begin
  Assert(FState = tlssActive);
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'Stop');
  {$ENDIF}
  FState := tlssStopped;
end;

procedure TTLSServer.Start;
begin
  if FState = tlssActive then
    exit;
  DoStart;
end;

procedure TTLSServer.Stop;
begin
  if FState <> tlssActive then
    exit;
  DoStop;
end;



end.

