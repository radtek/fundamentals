{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals TLS                                         }
{   File name:        cTLSClient.pas                                           }
{   File version:     0.04                                                     }
{   Description:      TLS client                                               }
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
{   2008/01/18  0.01  Initial development.                                     }
{   2010/11/26  0.02  Protocol messages.                                       }
{   2010/11/30  0.03  Encrypted messages.                                      }
{   2010/12/03  0.04  Connection base class.                                   }
{                                                                              }
{ Todo:                                                                        }
{ - OnClientStateChange event                                                  }
{ - Send connection close alert                                                }
{******************************************************************************}

{$INCLUDE cTLS.inc}

unit cTLSClient;

interface

uses
  { Cipher }
  cCipherRSA,
  { X509 }
  cX509Certificate,
  { TLS }
  cTLSUtils,
  cTLSCipherSuite,
  cTLSRecord,
  cTLSAlert,
  cTLSHandshake,
  cTLSConnection;



{                                                                              }
{ TLS Client                                                                   }
{                                                                              }
type
  TTLSClient = class;

  TTLSClientNotifyEvent = procedure (Sender: TTLSClient) of object;

  TTLSClientOptions = set of (
    tlscoDontUseSSL3,
    tlscoDontUseTLS10,
    tlscoDontUseTLS11,
    tlscoDontUseTLS12);

  TTLSClientState = (
    tlsclInit,
    tlsclHandshakeAwaitingServerHello,
    tlsclHandshakeAwaitingServerHelloDone,
    tlsclHandshakeClientKeyExchange,
    tlsclConnection);

  TTLSClient = class(TTLSConnection)
  protected
    FClientOptions         : TTLSClientOptions;
    FResumeSessionID       : AnsiString;

    FClientState           : TTLSClientState;
    FClientProtocolVersion : TTLSProtocolVersion;
    FServerProtocolVersion : TTLSProtocolVersion;
    FClientHello           : TTLSClientHello;
    FClientHelloRandomStr  : AnsiString;
    FServerHello           : TTLSServerHello;
    FServerHelloRandomStr  : AnsiString;
    FServerCertificateList : TTLSCertificateList;
    FServerX509Certs       : TX509CertificateArray;
    FServerKeyExchange     : TTLSServerKeyExchange;
    FCertificateRequest    : TTLSCertificateRequest;
    FCertificateRequested  : Boolean;
    FClientKeyExchange     : TTLSClientKeyExchange;
    FServerRSAPublicKey    : TRSAPublicKey;
    FPreMasterSecret       : TTLSPreMasterSecret;
    FPreMasterSecretStr    : AnsiString;
    FMasterSecret          : AnsiString;

    procedure Init; override;

    procedure SetClientState(const State: TTLSClientState);
    procedure CheckNotActive;

    procedure SetClientOptions(const ClientOptions: TTLSClientOptions);

    procedure InitInitialProtocolVersion;
    procedure InitSessionProtocolVersion;
    procedure InitHandshakeClientHello;
    procedure InitServerRSAPublicKey;
    procedure InitHandshakeClientKeyExchange;

    procedure SendHandshakeClientHello;
    procedure SendHandshakeCertificate;
    procedure SendHandshakeClientKeyExchange;
    procedure SendHandshakeCertificateVerify;
    procedure SendHandshakeFinished;

    procedure HandleHandshakeHelloRequest(const Buffer; const Size: Integer);
    procedure HandleHandshakeServerHello(const Buffer; const Size: Integer);
    procedure HandleHandshakeCertificate(const Buffer; const Size: Integer);
    procedure HandleHandshakeServerKeyExchange(const Buffer; const Size: Integer);
    procedure HandleHandshakeCertificateRequest(const Buffer; const Size: Integer);
    procedure HandleHandshakeServerHelloDone(const Buffer; const Size: Integer);
    procedure HandleHandshakeFinished(const Buffer; const Size: Integer);
    procedure HandleHandshakeMessage(const MsgType: TTLSHandshakeType; const Buffer; const Size: Integer); override;

    procedure InitCipherSpecNone;
    procedure InitCipherSpecNewFromServerHello;

    procedure DoStart;

  public
    constructor Create(const TransportLayerSendProc: TTLSConnectionTransportLayerSendProc);
    destructor Destroy; override;

    property  ClientOptions: TTLSClientOptions read FClientOptions write SetClientOptions;
    property  ResumeSessionID: AnsiString read FResumeSessionID write FResumeSessionID;

    property  ClientState: TTLSClientState read FClientState;
    procedure Start;
  end;



implementation

uses
  { Fundamentals }
  cASN1,
  { TLS }
  cTLSCompress,
  cTLSCipher;



{                                                                              }
{ TLS Client                                                                   }
{                                                                              }
const
  STLSClientState: array[TTLSClientState] of String = (
    'Init',
    'HandshakeAwaitingServerHello',
    'HandshakeAwaitingServerHelloDone',
    'HandshakeClientKeyExchange',
    'Connection');

constructor TTLSClient.Create(const TransportLayerSendProc: TTLSConnectionTransportLayerSendProc);
begin
  inherited Create(TransportLayerSendProc);
end;

destructor TTLSClient.Destroy;
begin
  RSAPublicKeyFinalise(FServerRSAPublicKey);
  inherited Destroy;
end;

procedure TTLSClient.Init;
begin
  inherited Init;
  RSAPublicKeyInit(FServerRSAPublicKey);
  FClientOptions := [tlscoDontUseSSL3];
  FClientState := tlsclInit;
end;

procedure TTLSClient.SetClientState(const State: TTLSClientState);
begin
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'State:%s', [STLSClientState[State]]);
  {$ENDIF}
  FClientState := State;
end;

procedure TTLSClient.CheckNotActive;
begin
  if FClientState <> tlsclInit then
    raise ETLSError.Create(TLSError_InvalidState, 'Operation not allowed while active');
end;

procedure TTLSClient.SetClientOptions(const ClientOptions: TTLSClientOptions);
begin
  if ClientOptions = FClientOptions then
    exit;
  CheckNotActive;
  FClientOptions := ClientOptions;
end;

procedure TTLSClient.InitInitialProtocolVersion;
begin
  // set highest allowable protocol version
  if not (tlscoDontUseTLS12 in FClientOptions) then
    InitTLSProtocolVersion12(FProtocolVersion) else
  if not (tlscoDontUseTLS11 in FClientOptions) then
    InitTLSProtocolVersion11(FProtocolVersion) else
  if not (tlscoDontUseTLS10 in FClientOptions) then
    InitTLSProtocolVersion10(FProtocolVersion) else
  if not (tlscoDontUseSSL3 in FClientOptions) then
    InitSSLProtocolVersion30(FProtocolVersion)
  else
    raise ETLSError.Create(TLSError_InvalidParameter, 'Invalid version options');
  FClientProtocolVersion := FProtocolVersion;
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'InitialProtocolVersion:%s', [TLSProtocolVersionName(FProtocolVersion)]);
  {$ENDIF}
end;

procedure TTLSClient.InitSessionProtocolVersion;
begin
  FProtocolVersion := FServerProtocolVersion;
  if IsTLS12(FProtocolVersion) and (tlscoDontUseTLS12 in FClientOptions)then
    InitTLSProtocolVersion11(FProtocolVersion);
  if IsTLS11(FProtocolVersion) and (tlscoDontUseTLS11 in FClientOptions) then
    InitTLSProtocolVersion10(FProtocolVersion);
  if IsTLS10(FProtocolVersion) and (tlscoDontUseTLS10 in FClientOptions) then
    InitSSLProtocolVersion30(FProtocolVersion);
  if IsSSL3(FProtocolVersion) and (tlscoDontUseSSL3 in FClientOptions) then
    raise ETLSAlertError.Create(tlsadProtocol_version); // no allowable protocol version
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'SessionProtocolVersion:%s', [TLSProtocolVersionName(FProtocolVersion)]);
  {$ENDIF}
end;

procedure TTLSClient.InitHandshakeClientHello;
begin
  InitTLSClientHello(FClientHello,
      FClientProtocolVersion,
      FResumeSessionID);
  FClientHello.CipherSuites :=
      [
//       tlscsNULL_WITH_NULL_NULL                                                 // UNTESTED
//       tlscsRSA_WITH_NULL_MD5,                                                  // UNTESTED
//       tlscsRSA_WITH_NULL_SHA                                                   // UNTESTED
       tlscsRSA_WITH_RC4_128_MD5,                                               // TESTED OK
       tlscsRSA_WITH_RC4_128_SHA,                                               // TESTED OK
//       tlscsRSA_WITH_IDEA_CBC_SHA                                                  // UNTESTED
       tlscsRSA_WITH_DES_CBC_SHA,                                               // TESTED OK
//  tlscsRSA_WITH_3DES_EDE_CBC_SHA                                              // ERROR: SERVER DECRYPTION FAILED
//  tlscsRSA_WITH_NULL_SHA256                                                   // ERROR
       tlscsRSA_WITH_AES_128_CBC_SHA,                                           // TESTED OK
       tlscsRSA_WITH_AES_256_CBC_SHA,                                           // TESTED OK
       tlscsRSA_WITH_AES_128_CBC_SHA256,                                        // TESTED OK, TLS 1.2 only
       tlscsRSA_WITH_AES_256_CBC_SHA256                                         // TESTED OK, TLS 1.2 only
       ];
  FClientHello.CompressionMethods :=
      [tlscmNull];
  FClientHelloRandomStr := TLSRandomToStr(FClientHello.Random);
end;

procedure TTLSClient.InitServerRSAPublicKey;
var I, L, N1, N2 : Integer;
    C : PX509Certificate;
    S : AnsiString;
    PKR : TX509RSAPublicKey;
    R : Boolean;
begin
  // find RSA public key from certificates
  R := False;
  L := Length(FServerX509Certs);
  for I := 0 to L - 1 do
    begin
      C := @FServerX509Certs[I];
      if ASN1OIDEqual(C^.TBSCertificate.SubjectPublicKeyInfo.Algorithm.Algorithm, OID_RSA) then
        begin
          S := C^.TBSCertificate.SubjectPublicKeyInfo.SubjectPublicKey;
          Assert(S <> '');
          ParseX509RSAPublicKey(S[1], Length(S), PKR);
          R := True;
          break;
        end;
    end;
  if not R then
    exit;
  N1 := NormaliseX509IntKeyBuf(PKR.Modulus);
  N2 := NormaliseX509IntKeyBuf(PKR.PublicExponent);
  if N2 > N1 then
    N1 := N2;
  // initialise RSA public key
  RSAPublicKeyAssignBuf(FServerRSAPublicKey, N1 * 8,
      PKR.Modulus[1], Length(PKR.Modulus),
      PKR.PublicExponent[1], Length(PKR.PublicExponent), True);
end;

procedure TTLSClient.InitHandshakeClientKeyExchange;
var S : AnsiString;
begin
  case FCipherSpecNew.KeyExchangeAlgorithm of
    tlskeaRSA :
      begin
        InitTLSPreMasterSecret(FPreMasterSecret, FClientHello.ProtocolVersion);
        FPreMasterSecretStr := TLSPreMasterSecretToStr(FPreMasterSecret);

        InitServerRSAPublicKey;

        InitTLSEncryptedPreMasterSecret(S, FPreMasterSecret, FServerRSAPublicKey);
        FClientKeyExchange.EncryptedPreMasterSecret := S;

        FMasterSecret := TLSMasterSecret(FProtocolVersion, FPreMasterSecretStr, FClientHelloRandomStr, FServerHelloRandomStr);

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
        SetEncodeKeys(FKeys.ClientMACKey, FKeys.ClientEncKey, FKeys.ClientIV);
        SetDecodeKeys(FKeys.ServerMACKey, FKeys.ServerEncKey, FKeys.ServerIV);
      end;
    tlskeaDHE_DSS,
    tlskeaDHE_RSA,
    tlskeaDH_Anon,
    tlskeaDH_DSS,
    tlskeaDH_RSA :
      begin
        // TODO
        FClientKeyExchange.ClientDiffieHellmanPublic.PublicValueEncodingExplicit := False;
        FClientKeyExchange.ClientDiffieHellmanPublic.dh_Yc := '';
      end;
  end;
end;

const
  MaxHandshakeClientHelloSize       = 16384;
  MaxHandshakeCertificateSize       = 65536;
  MaxHandshakeClientKeyExchangeSize = 2048;
  MaxHandshakeCertificateVerifySize = 16384;
  MaxHandshakeFinishedSize          = 2048;

procedure TTLSClient.SendHandshakeClientHello;
var B : array[0..MaxHandshakeClientHelloSize - 1] of Byte;
    L : Integer;
begin
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'S:Handshake:ClientHello');
  {$ENDIF}
  InitHandshakeClientHello;
  L := EncodeTLSHandshakeClientHello(B, SizeOf(B), FClientHello);
  SendHandshake(B, L);
end;

procedure TTLSClient.SendHandshakeCertificate;
var B : array[0..MaxHandshakeCertificateSize - 1] of Byte;
    L : Integer;
begin
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'S:Handshake:Certificate');
  {$ENDIF}
  L := EncodeTLSHandshakeCertificate(B, SizeOf(B), nil);
  SendHandshake(B, L);
end;

procedure TTLSClient.SendHandshakeClientKeyExchange;
var B : array[0..MaxHandshakeClientKeyExchangeSize - 1] of Byte;
    L : Integer;
begin
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'S:Handshake:ClientKeyExchange');
  {$ENDIF}
  InitHandshakeClientKeyExchange;
  L := EncodeTLSHandshakeClientKeyExchange(
      B, SizeOf(B),
      FCipherSpecNew.KeyExchangeAlgorithm,
      FClientKeyExchange);
  SendHandshake(B, L);
end;

procedure TTLSClient.SendHandshakeCertificateVerify;
var B : array[0..MaxHandshakeCertificateVerifySize - 1] of Byte;
    L : Integer;
begin
  L := EncodeTLSHandshakeCertificateVerify(B, SizeOf(B));
  SendHandshake(B, L);
end;

procedure TTLSClient.SendHandshakeFinished;
var B : array[0..MaxHandshakeFinishedSize - 1] of Byte;
    L : Integer;
begin
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'S:Handshake:Finished:%s', [TLSProtocolVersionName(FProtocolVersion)]);
  {$ENDIF}
  L := EncodeTLSHandshakeFinished(B, SizeOf(B), FMasterSecret, FProtocolVersion, FVerifyHandshakeData, True);
  SendHandshake(B, L);
end;

procedure TTLSClient.HandleHandshakeHelloRequest(const Buffer; const Size: Integer);
begin
  if IsNegotiatingState then
    exit; // ignore while negotiating
  if FConnectionState = tlscoApplicationData then
    SendAlert(tlsalWarning, tlsadNo_renegotiation); // client does not support renegotiation, notify server
end;

procedure TTLSClient.HandleHandshakeServerHello(const Buffer; const Size: Integer);
begin
  if not (FClientState in [tlsclHandshakeAwaitingServerHello]) or
     not (FConnectionState in [tlscoStart, tlscoHandshaking]) then
    raise ETLSAlertError.Create(tlsadUnexpected_message);
  DecodeTLSServerHello(Buffer, Size, FServerHello);
  FServerProtocolVersion := FServerHello.ProtocolVersion;
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'ServerProtocolVersion:%s', [TLSProtocolVersionName(FServerProtocolVersion)]);
  {$ENDIF}
  FServerHelloRandomStr := TLSRandomToStr(FServerHello.Random);
  if not IsTLSProtocolVersion(FServerProtocolVersion, FProtocolVersion) then // different protocol version
    begin
      if IsFutureTLSVersion(FServerProtocolVersion) then
        raise ETLSAlertError.Create(tlsadProtocol_version); // unsupported future version of TLS
      if not IsKnownTLSVersion(FServerProtocolVersion) then
        raise ETLSAlertError.Create(tlsadProtocol_version); // unknown past TLS version
    end;
  InitSessionProtocolVersion;
  InitCipherSpecNewFromServerHello;
  SetClientState(tlsclHandshakeAwaitingServerHelloDone);
end;

procedure TTLSClient.HandleHandshakeCertificate(const Buffer; const Size: Integer);
var I, L : Integer;
    C : AnsiString;
begin
  if FClientState <> tlsclHandshakeAwaitingServerHelloDone then
    raise ETLSAlertError.Create(tlsadUnexpected_message);
  DecodeTLSCertificate(Buffer, Size, FServerCertificateList);
  L := Length(FServerCertificateList);
  SetLength(FServerX509Certs, L);
  for I := 0 to L - 1 do
    begin
      C := FServerCertificateList[I];
      InitX509Certificate(FServerX509Certs[I]);
      Assert(C <> '');
      ParseX509Certificate(C[1], Length(C), FServerX509Certs[I]);
    end;
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'R:Handshake:Certificate:Count=%d', [L]);
  {$ENDIF}
end;

procedure TTLSClient.HandleHandshakeServerKeyExchange(const Buffer; const Size: Integer);
begin
  if FClientState <> tlsclHandshakeAwaitingServerHelloDone then
    raise ETLSAlertError.Create(tlsadUnexpected_message);
  DecodeTLSServerKeyExchange(Buffer, Size, FCipherSpecNew.KeyExchangeAlgorithm, FServerKeyExchange);
end;

procedure TTLSClient.HandleHandshakeCertificateRequest(const Buffer; const Size: Integer);
begin
  if FClientState <> tlsclHandshakeAwaitingServerHelloDone then
    raise ETLSAlertError.Create(tlsadUnexpected_message);
  DecodeTLSCertificateRequest(Buffer, Size, FCertificateRequest);
  FCertificateRequested := True;
end;

procedure TTLSClient.HandleHandshakeServerHelloDone(const Buffer; const Size: Integer);
begin
  if FClientState <> tlsclHandshakeAwaitingServerHelloDone then
    raise ETLSAlertError.Create(tlsadUnexpected_message);
  SetClientState(tlsclHandshakeClientKeyExchange);
  if FCertificateRequested then
    SendHandshakeCertificate;
  SendHandshakeClientKeyExchange;
  // TODO SendHandshakeCertificateVerify;
  SendChangeCipherSpec;
  ChangeEncryptCipherSpec;
  SendHandshakeFinished;
end;

procedure TTLSClient.HandleHandshakeFinished(const Buffer; const Size: Integer);
begin
  if FClientState <> tlsclHandshakeClientKeyExchange then
    raise ETLSAlertError.Create(tlsadUnexpected_message);
  SetClientState(tlsclConnection);
  SetConnectionState(tlscoApplicationData);
  TriggerHandshakeFinished;
end;

procedure TTLSClient.HandleHandshakeMessage(const MsgType: TTLSHandshakeType; const Buffer; const Size: Integer);
begin
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'R:Handshake:' + TLSHandshakeTypeToStr(MsgType));
  {$ENDIF}
  case MsgType of
    tlshtHello_request       : HandleHandshakeHelloRequest(Buffer, Size);
    tlshtClient_hello        : ShutdownBadProtocol(tlsadUnexpected_message);
    tlshtServer_hello        : HandleHandshakeServerHello(Buffer, Size);
    tlshtCertificate         : HandleHandshakeCertificate(Buffer, Size);
    tlshtServer_key_exchange : HandleHandshakeServerKeyExchange(Buffer, Size);
    tlshtCertificate_request : HandleHandshakeCertificateRequest(Buffer, Size);
    tlshtServer_hello_done   : HandleHandshakeServerHelloDone(Buffer, Size);
    tlshtCertificate_verify  : ShutdownBadProtocol(tlsadUnexpected_message);
    tlshtClient_key_exchange : ShutdownBadProtocol(tlsadUnexpected_message);
    tlshtFinished            : HandleHandshakeFinished(Buffer, Size);
  else
    ShutdownBadProtocol(tlsadUnexpected_message);
  end;
end;

procedure TTLSClient.InitCipherSpecNone;
begin
  InitTLSSecurityParametersNone(FCipherEncryptSpec);
  InitTLSSecurityParametersNone(FCipherDecryptSpec);
  TLSCipherInitNone(FCipherEncryptState, tlscoEncrypt);
  TLSCipherInitNone(FCipherDecryptState, tlscoDecrypt);
end;

procedure TTLSClient.InitCipherSpecNewFromServerHello;
begin
  InitTLSSecurityParameters(
      FCipherSpecNew,
      FServerHello.CompressionMethod,
      GetCipherSuiteByRec(FServerHello.CipherSuite.B1, FServerHello.CipherSuite.B2));
  {$IFDEF TLS_DEBUG}
  Log(tlsltDebug, 'CipherSpec:%s', [FCipherSpecNew.CipherSuiteDetails.CipherSuiteInfo^.Name]);
  {$ENDIF}
end;

procedure TTLSClient.DoStart;
begin
  SetConnectionState(tlscoStart);
  InitInitialProtocolVersion;
  InitCipherSpecNone;
  SetConnectionState(tlscoHandshaking);
  SetClientState(tlsclHandshakeAwaitingServerHello);
  SendHandshakeClientHello;
end;

procedure TTLSClient.Start;
begin
  Assert(FConnectionState = tlscoInit);
  Assert(FClientState = tlsclInit);
  DoStart;
end;



end.

