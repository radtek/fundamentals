{******************************************************************************}
{                                                                              }
{                              SOCKS client 4.01                               }
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cSocksUtils.pas                                          }
{   File version:     4.01                                                     }
{   Description:      SOCKS client                                             }
{                                                                              }
{   A SOCKS client implementation that is transport agnostic.                  }
{                                                                              }
{   Copyright:        Copyright (c) 2008-2011, David J Butler                  }
{                     All rights reserved.                                     }
{                     This file is licensed under the BSD License.             }
{                     See http://www.opensource.org/licenses/bsd-license.php   }
{                     Redistribution and use in source and binary forms, with  }
{                     or without modification, are permitted provided that     }
{                     the following conditions are met:                        }
{                     Redistributions of source code must retain the above     }
{                     copyright notice, this list of conditions and the        }
{                     following disclaimer.                                    }
{                     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND   }
{                     CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED          }
{                     WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED   }
{                     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          }
{                     PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL     }
{                     THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,    }
{                     INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR             }
{                     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,    }
{                     PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF     }
{                     USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)         }
{                     HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER   }
{                     IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING        }
{                     NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE   }
{                     USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE             }
{                     POSSIBILITY OF SUCH DAMAGE.                              }
{                                                                              }
{   Home page:        http://fundementals.sourceforge.net                      }
{   Forum:            http://sourceforge.net/forum/forum.php?forum_id=2117     }
{   E-mail:           fundamentalslib@gmail.com                                }
{                                                                              }
{ Revision history:                                                            }
{                                                                              }
{   2008/08/17  4.01  Initial version.                                         }
{                                                                              }
{ Supported compilers:                                                         }
{                                                                              }
{   Borland Delphi 5/6/7/2005/2006 Win32 i386                                  }
{   FreePascal 2 Win32 i386                                                    }
{   FreePascal 2.0.1 Linux i386                                                }
{                                                                              }
{******************************************************************************}

unit cSocksClient;

interface

uses
  { System }
  SysUtils,
  
  { Fundamentals }
  cSocketLib,
  cSocksUtils;



{                                                                              }
{ TSocksClient                                                                 }
{                                                                              }
{ To use:                                                                      }
{   1) Set Addr and other request properties                                   }
{   2) Set OnClientWrite handler                                               }
{   3) Call Connect/Bind                                                       }
{   4) While not IsComplete call ClientData and handle OnClientWrite           }
{   5) Check ReqState/FailureReason                                            }
{                                                                              }
type
  TSocksClientSocksVersion = (
      scvSocks4,
      scvSocks4a,
      scvSocks5);
  TSocksClientAddrType = (
      scaIP4,
      scaIP6,
      scaDomain);
  TSocksClientAuthMethod = (
      scamNone,
      scamSocks4UserId,
      scamSocks5UserPass);
  TSocksClientRequestType = (
      scrtConnect,
      scrtBind);
  TSocksClientRequestState = (
      scrsInit,
      scrsSocks5Greeting,
      scrsSocks5Authenticate,
      scrsSocks4Request,
      scrsSocks5Request,
      scrsSuccess,
      scrsFailed);

  TSocksClient = class;

  TSocksClientWriteEvent = procedure (
      const Client: TSocksClient;
      const Buf; const BufSize: Integer) of object;

  TSocksClient = class
  protected
    FSocksVersion  : TSocksClientSocksVersion;
    FAddrType      : TSocksClientAddrType;
    FAddrIP4       : TIP4Addr;
    FAddrIP6       : TIP6Addr;
    FAddrDomain    : AnsiString;
    FAddrPort      : Word;
    FAuthMethod    : TSocksClientAuthMethod;
    FUserID        : AnsiString;
    FPassword      : AnsiString;

    FOnClientWrite : TSocksClientWriteEvent;

    FReqType       : TSocksClientRequestType;
    FReqVer        : TSocksClientSocksVersion;
    FReqState      : TSocksClientRequestState;
    FReqAuth       : TSocksClientAuthMethod;
    FFailureReason : String;

    procedure ClientWrite(const Buf; const BufSize: Integer);
    procedure ClientWriteStr(const Buf: AnsiString);

    procedure InitRequestVersion;
    procedure ValidateConnectAddress;
    procedure ValidateBindAddress;

    procedure WriteSocks4ConnectRequest;
    procedure WriteSocks4BindRequest;

    procedure WriteSocks5Greeting;
    procedure WriteSocks5RequestMessage(const Code: Byte);
    procedure WriteSocks5ConnectRequest;
    procedure WriteSocks5BindRequest;
    procedure WriteSocks5Request;
    procedure WriteSocks5Authenticate;

    procedure SetReqState(const ReqState: TSocksClientRequestState);
    procedure SetReqStateInit;
    procedure SetReqStateFailed(const Reason: String);
    procedure SetReqStateSuccess;

    procedure ProcessSocks4InitialRequestConnect;
    procedure ProcessSocks4InitialRequestBind;
    procedure ProcessSocks4Request(const Response: TSocks4Message);

    procedure ProcessSocks5InitialRequest;
    procedure ProcessSocks5Greeting(const GreetingResponse: TSocks5GreetingResponse);
    procedure ProcessSocks5UserPass(const UserPassResponse: TSocks5UserPassResponse);
    procedure ProcessSocks5Request(const Response: TSocks5ResponseHeader);

    procedure ProcessInitialRequestConnect;
    procedure ProcessInitialRequestBind;

    function  ProcessClientDataSocks4Request(const Buf; const BufSize: Integer): Integer;
    function  ProcessClientDataSocks5Greeting(const Buf; const BufSize: Integer): Integer;
    function  ProcessClientDataSocks5Authenticate(const Buf; const BufSize: Integer): Integer;
    function  ProcessClientDataSocks5Request(const Buf; const BufSize: Integer): Integer;
    function  ProcessClientData(const Buf; const BufSize: Integer): Integer;

  public
    constructor Create;

    property  SocksVersion: TSocksClientSocksVersion read FSocksVersion write FSocksVersion;
    property  AddrType: TSocksClientAddrType read FAddrType write FAddrType;
    property  AddrIP4: TIP4Addr read FAddrIP4 write FAddrIP4;
    property  AddrIP6: TIP6Addr read FAddrIP6 write FAddrIP6;
    property  AddrDomain: AnsiString read FAddrDomain write FAddrDomain;
    property  AddrPort: Word read FAddrPort write FAddrPort;
    property  AuthMethod: TSocksClientAuthMethod read FAuthMethod write FAuthMethod;
    property  UserID: AnsiString read FUserID write FUserID;
    property  Password: AnsiString read FPassword write FPassword;

    property  OnClientWrite: TSocksClientWriteEvent read FOnClientWrite write FOnClientWrite;

    procedure Connect;
    procedure Bind;

    function  ClientData(const Buf; const BufSize: Integer): Integer;

    function  IsComplete: Boolean;
    property  ReqState: TSocksClientRequestState read FReqState;
    property  FailureReason: String read FFailureReason;
  end;

  ESocksClient = class(Exception);



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DEBUG}{$IFDEF SELFTEST}
procedure SelfTest;
{$ENDIF}{$ENDIF}



implementation



{                                                                              }
{ TSocksClient                                                                 }
{                                                                              }
constructor TSocksClient.Create;
begin
  inherited Create;
  FSocksVersion := scvSocks5;
  FAddrType := scaDomain;
  FReqType := scrtConnect;
  FReqState := scrsInit;
end;

procedure TSocksClient.ClientWrite(const Buf; const BufSize: Integer);
begin
  if not Assigned(FOnClientWrite) then
    raise ESocksClient.Create('Client write handler not defined');
  FOnClientWrite(self, Buf, BufSize);
end;

procedure TSocksClient.ClientWriteStr(const Buf: AnsiString);
begin
  ClientWrite(Pointer(Buf)^, Length(Buf));
end;

procedure TSocksClient.InitRequestVersion;
begin
  FReqVer := FSocksVersion;
  case FAddrType of
    scaIP4 :
      if FReqVer = scvSocks4a then
        FReqVer := scvSocks4;
    scaIP6 :
      FReqVer := scvSocks5;
    scaDomain :
      if FReqVer = scvSocks4 then
        FReqVer := scvSocks4a;
  else
    raise ESocksClient.Create('Invalid address type');
  end;
  case FAuthMethod of
    scamNone           : ;
    scamSocks4UserId   : ;
    scamSocks5UserPass : FReqVer := scvSocks5;
  else
    raise ESocksClient.Create('Invalid authentication method');
  end;
end;

procedure TSocksClient.ValidateConnectAddress;
begin
  case FAddrType of
    scaIP4 :
      if FAddrIP4.Addr32 = 0 then
        raise ESocksClient.Create('Invalid address');
    scaIP6 :
      if IP6AddrIsZero(FAddrIP6) then
        raise ESocksClient.Create('Invalid address');
    scaDomain :
      if FAddrDomain = '' then
        raise ESocksClient.Create('Invalid address');
  else
    raise ESocksClient.Create('Invalid address type');
  end;
  if FAddrPort = 0 then
    raise ESocksClient.Create('Invalid port');
end;

procedure TSocksClient.ValidateBindAddress;
begin
  if FAddrPort = 0 then
    raise ESocksClient.Create('Invalid port');
end;

procedure TSocksClient.WriteSocks4ConnectRequest;
var
  Req4 : AnsiString;
begin
  Assert(FReqVer in [scvSocks4, scvSocks4a]);
  Assert(FReqType = scrtConnect);

  case FReqVer of
    scvSocks4 :
      begin
        Assert(FAddrType = scaIP4);

        Req4 := Socks4ConnectRequest(FAddrIP4, FAddrPort, FUserID);
        ClientWrite(Pointer(Req4)^, Length(Req4));
      end;
    scvSocks4a :
      begin
        Assert(FAddrType = scaDomain);

        Req4 := Socks4aConnectRequest(FAddrDomain, FAddrPort, FUserID);
        ClientWrite(Pointer(Req4)^, Length(Req4));
      end;
  end;
end;

procedure TSocksClient.WriteSocks4BindRequest;
var
  Req4 : AnsiString;
begin
  Assert(FReqVer in [scvSocks4, scvSocks4a]);
  Assert(FReqType = scrtBind);

  case FReqVer of
    scvSocks4 :
      begin
        Assert(FAddrType = scaIP4);

        Req4 := Socks4BindRequest(FAddrIP4, FAddrPort, FUserID);
        ClientWrite(Pointer(Req4)^, Length(Req4));
      end;
    scvSocks4a :
      begin
        Assert(FAddrType = scaDomain);

        raise ESocksClient.Create('Invalid socks version');
      end;
  end;
end;

procedure TSocksClient.WriteSocks5Greeting;
var
  Greet5 : TSocks5Greeting;
begin
  case FAuthMethod of
    scamNone           : PopulateSocks5GreetingNoAuth(Greet5);
    scamSocks5UserPass : PopulateSocks5GreetingUserPass(Greet5);
  else
    raise ESocksClient.Create('Invalid authentication method');
  end;
  ClientWrite(Greet5, Sizeof(Greet5));
  FReqAuth := FAuthMethod;
end;

procedure TSocksClient.WriteSocks5RequestMessage(const Code: Byte);
var
  Port   : Word;
  MsgIP4 : TSocks5IP4Message;
  MsgIP6 : TSocks5IP6Message;
  MsgDom : AnsiString;
begin
  Port := PortToNetPort(FAddrPort);
  case FAddrType of
    scaIP4 :
      begin
        PopulateSocks5IP4Message(MsgIP4, Code, FAddrIP4, Port);
        ClientWrite(MsgIP4, Sizeof(MsgIP4));
      end;
    scaIP6 :
      begin
        PopulateSocks5IP6Message(MsgIP6, Code, FAddrIP6, Port);
        ClientWrite(MsgIP6, Sizeof(MsgIP6));
      end;
    scaDomain :
      begin
        MsgDom := Socks5DomainRequest(Code, FAddrDomain, Port);
        ClientWrite(PAnsiChar(MsgDom)^, Length(MsgDom));
      end;
  else
    raise ESocksClient.Create('Invalid address type');
  end;
end;

procedure TSocksClient.WriteSocks5ConnectRequest;
begin
  WriteSocks5RequestMessage(SOCKS5_REQ_CODE_CONNECT);
end;

procedure TSocksClient.WriteSocks5BindRequest;
begin
  WriteSocks5RequestMessage(SOCKS5_REQ_CODE_BIND);
end;

procedure TSocksClient.WriteSocks5Request;
begin
  Assert(FReqVer = scvSocks5);

  case FReqType of
    scrtConnect : WriteSocks5ConnectRequest;
    scrtBind    : WriteSocks5BindRequest;
  else
    raise ESocksClient.Create('Invalid request type');
  end;
end;

procedure TSocksClient.WriteSocks5Authenticate;
begin
  Assert(FReqAuth = scamSocks5UserPass);

  ClientWriteStr(Socks5UserPassMessage(FUserID, FPassword));
end;

procedure TSocksClient.SetReqState(const ReqState: TSocksClientRequestState);
begin
  FReqState := ReqState;
end;

procedure TSocksClient.SetReqStateInit;
begin
  FFailureReason := '';
  SetReqState(scrsInit);
end;

procedure TSocksClient.SetReqStateFailed(const Reason: String);
begin
  FFailureReason := Reason;
  SetReqState(scrsFailed);
end;

procedure TSocksClient.SetReqStateSuccess;
begin
  SetReqState(scrsSuccess);
end;

procedure TSocksClient.ProcessSocks4InitialRequestConnect;
begin
  Assert(FReqState = scrsInit);

  WriteSocks4ConnectRequest;
  SetReqState(scrsSocks4Request);
end;

procedure TSocksClient.ProcessSocks4InitialRequestBind;
begin
  Assert(FReqState = scrsInit);

  WriteSocks4BindRequest;
  SetReqState(scrsSocks4Request);
end;

procedure TSocksClient.ProcessSocks4Request(const Response: TSocks4Message);
begin
  Assert(FReqState = scrsSocks4Request);

  if Response.Code = SOCKS4_RESP_CODE_GRANTED then
    SetReqStateSuccess
  else
    SetReqStateFailed(Socks4ErrorDescription(Response.Code));
end;

procedure TSocksClient.ProcessSocks5InitialRequest;
begin
  Assert(FReqState = scrsInit);

  WriteSocks5Greeting;
  SetReqState(scrsSocks5Greeting);
end;

procedure TSocksClient.ProcessSocks5Greeting(const GreetingResponse: TSocks5GreetingResponse);
begin
  Assert(FReqState = scrsSocks5Greeting);

  if GreetingResponse.Version <> 5 then
  begin
    SetReqStateFailed('Invalid server response');
    exit;
  end;
  if GreetingResponse.Method = SOCKS5_METHOD_INVALID then
  begin
    SetReqStateFailed('Authentication method not acceptable');
    exit;
  end;
  case GreetingResponse.Method of
    SOCKS5_METHOD_NOAUTH :
      begin
        if FReqAuth <> scamNone then
          begin
            SetReqStateFailed('No authentication required');
            exit;
          end;
        WriteSocks5Request;
        SetReqState(scrsSocks5Request);
      end;
    SOCKS5_METHOD_USERPASS :
      begin
        if FReqAuth = scamNone then
          begin
            SetReqStateFailed('Authentication required');
            exit;
          end;
        WriteSocks5Authenticate;
        SetReqState(scrsSocks5Authenticate);
      end;
  else
    SetReqStateFailed('Unrecognised server authentication method');
  end;
end;

procedure TSocksClient.ProcessSocks5UserPass(const UserPassResponse: TSocks5UserPassResponse);
begin
  Assert(FReqState = scrsSocks5Authenticate);
  Assert(FReqAuth = scamSocks5UserPass);

  if UserPassResponse.Status = SOCKS5_USERPASS_STATUS_OK then
    begin
      WriteSocks5Request;
      SetReqState(scrsSocks5Request);
    end
  else
    SetReqStateFailed('Authentication failed');
end;

procedure TSocksClient.ProcessSocks5Request(const Response: TSocks5ResponseHeader);
begin
  if Response.Code <> SOCKS5_RESP_CODE_Success then
    SetReqStateFailed(Socks5ErrorDescription(Response.Code))
  else
    SetReqStateSuccess;
end;

procedure TSocksClient.ProcessInitialRequestConnect;
begin
  Assert(FReqState = scrsInit);

  FReqType := scrtConnect;
  case FReqVer of
    scvSocks4,
    scvSocks4a : ProcessSocks4InitialRequestConnect;
    scvSocks5  : ProcessSocks5InitialRequest;
  else
    raise ESocksClient.Create('Invalid socks version');
  end;
end;

procedure TSocksClient.ProcessInitialRequestBind;
begin
  Assert(FReqState = scrsInit);

  FReqType := scrtBind;
  case FReqVer of
    scvSocks4,
    scvSocks4a : ProcessSocks4InitialRequestBind;
    scvSocks5  : ProcessSocks5InitialRequest;
  else
    raise ESocksClient.Create('Invalid socks version');
  end;
end;

function TSocksClient.ProcessClientDataSocks4Request(const Buf; const BufSize: Integer): Integer;
begin
  Assert(FReqState = scrsSocks4Request);

  if BufSize < Sizeof(TSocks4Message) then
    Result := 0
  else
    begin
      ProcessSocks4Request(PSocks4Message(@Buf)^);
      Result := Sizeof(TSocks4Message);
    end;
end;

function TSocksClient.ProcessClientDataSocks5Greeting(const Buf; const BufSize: Integer): Integer;
begin
  Assert(FReqState = scrsSocks5Greeting);

  if BufSize < Sizeof(TSocks5GreetingResponse) then
    Result := 0
  else
    begin
      ProcessSocks5Greeting(PSocks5Greetingresponse(@Buf)^);
      Result := Sizeof(TSocks5GreetingResponse);
    end;
end;

function TSocksClient.ProcessClientDataSocks5Authenticate(const Buf; const BufSize: Integer): Integer;
begin
  Assert(FReqState = scrsSocks5Authenticate);
  Assert(FReqAuth = scamSocks5UserPass);

  if BufSize < Sizeof(TSocks5UserPassResponse) then
    Result := 0
  else
    begin
      ProcessSocks5UserPass(PSocks5UserPassResponse(@Buf)^);
      Result := Sizeof(TSocks5UserPassResponse);
    end;
end;

function TSocksClient.ProcessClientDataSocks5Request(const Buf; const BufSize: Integer): Integer;
var
  Hdr : PSocks5ResponseHeader;
  RespSize : Integer;
begin
  Assert(FReqState = scrsSocks5Request);

  if BufSize < Sizeof(TSocks5ResponseHeader) then
    Result := 0
  else
    begin
      Hdr := @Buf;
      if Hdr^.Version <> SOCKS5_MSG_VERSION then
        begin
          SetReqStateFailed('Invalid server response');
          Result := 0;
          exit;
        end;
      RespSize := Socks5ResponseSize(Hdr);
      if BufSize < RespSize then
        Result := 0
      else
        begin
          ProcessSocks5Request(Hdr^);
          Result := RespSize;
        end;
    end;
end;

function TSocksClient.ProcessClientData(const Buf; const BufSize: Integer): Integer;
begin
  case FReqState of
    scrsSocks4Request      : Result := ProcessClientDataSocks4Request(Buf, BufSize);
    scrsSocks5Greeting     : Result := ProcessClientDataSocks5Greeting(Buf, BufSize);
    scrsSocks5Authenticate : Result := ProcessClientDataSocks5Authenticate(Buf, BufSize);
    scrsSocks5Request      : Result := ProcessClientDataSocks5Request(Buf, BufSize)
  else
    raise ESocksClient.Create('Invalid state');
  end;
end;

procedure TSocksClient.Connect;
begin
  SetReqStateInit;
  InitRequestVersion;
  ValidateConnectAddress;
  ProcessInitialRequestConnect;
end;

procedure TSocksClient.Bind;
begin
  SetReqStateInit;
  InitRequestVersion;
  ValidateBindAddress;
  ProcessInitialRequestBind;
end;

function TSocksClient.ClientData(const Buf; const BufSize: Integer): Integer;
var P : PAnsiChar;
    L, R : Integer;
begin
  P := @Buf;
  L := BufSize;
  while L > 0 do
    begin
      R := ProcessClientData(P^, L);
      Assert(R <= L);
      if R = 0 then
        begin
          Result := BufSize - L;
          exit;
        end;
      Inc(P, R);
      Dec(L, R);
    end;
  Assert(L = 0);
  Result := BufSize;
end;

function TSocksClient.IsComplete: Boolean;
begin
  Result := FReqState in [scrsSuccess, scrsFailed];
end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DEBUG}{$IFDEF SELFTEST}
{$ASSERTIONS ON}
procedure SelfTest;
begin
end;
{$ENDIF}{$ENDIF}



end.

