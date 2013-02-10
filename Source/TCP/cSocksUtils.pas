{******************************************************************************}
{                                                                              }
{                            SOCKS utilities 4.05                              }
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cSocksUtils.pas                                          }
{   File version:     4.05                                                     }
{   Description:      SOCKS utilities                                          }
{                                                                              }
{   SOCKS was originally developed by David Koblas and subsequently modified   }
{   as SOCKS4 by Ying-Da Lee from NEC.                                         }
{   SOCKS5 is an internet standard as defined in RFC1928.                      }
{                                                                              }
{   Copyright:        Copyright (c) 2001-2011, David J Butler                  }
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
{   2001/12/13  0.01  Added Socks5 support for TCP clients.                    }
{   2002/09/21  2.02  Created cSocks unit.                                     }
{                     Added Socks4 functions.                                  }
{   2003/09/10  3.03  Small revisions.                                         }
{   2008/08/15  4.04  Revision for Fundamentals 4.                             }
{                     IP6 support.                                             }
{   2008/12/29  4.05  Revision.                                                }
{                                                                              }
{ Supported compilers:                                                         }
{                                                                              }
{   Borland Delphi 5/6/7/2005/2006 Win32 i386                                  }
{   FreePascal 2 Win32 i386                                                    }
{   FreePascal 2.0.1 Linux i386                                                }
{                                                                              }
{******************************************************************************}

{$INCLUDE cDefines.inc}
unit cSocksUtils;

interface

uses
  { System }
  SysUtils,
  cSocketLib;



{                                                                              }
{ SOCKS                                                                        }
{                                                                              }
const
  SOCKS_DEFAULTPORT     = 1080;
  SOCKS_DEFAULTPORT_STR = '1080';

type
  ESocks = class(Exception);



{                                                                              }
{ SOCKS4                                                                       }
{                                                                              }

{ Socks 4 constants                                                            }
const
  SOCKS4_MSG_VERSION = 4;

  SOCKS4_REQ_CODE_CONNECT = 1;
  SOCKS4_REQ_CODE_BIND    = 2;

  SOCKS4_RESP_CODE_GRANTED         = 90;
  SOCKS4_RESP_CODE_FAILED          = 91;
  SOCKS4_RESP_CODE_NO_IDENTD       = 92;
  SOCKS4_RESP_CODE_IDENTD_MISMATCH = 93;

function Socks4ErrorDescription(const Code: Integer): String;



{ Socks 4 Message                                                              }
type
  TSocks4Message = packed record // 8 bytes
    Version  : Byte;       // 4
    Code     : Byte;
    DestPort : Word;
    DestIP   : LongWord;
  end;
  PSocks4Message = ^TSocks4Message;

const
  SOCKS4_MAX_MSG_SIZE = Sizeof(TSocks4Message);

procedure PopulateSocks4Message(var Msg: TSocks4Message;
          const Code: Byte; const IP: TIP4Addr; const Port: Word);



{ Socks 4 Request                                                              }
function  Socks4Request(const Code: Byte; const IP: TIP4Addr; const Port: Word;
          const UserID: AnsiString): AnsiString;
function  Socks4ConnectRequest(const IP: TIP4Addr; const Port: Word;
          const UserID: AnsiString = ''): AnsiString;
function  Socks4BindRequest(const IP: TIP4Addr; const Port: Word;
          const UserID: AnsiString = ''): AnsiString;



{ Socks 4a Request                                                             }
function  Socks4aRequest(const Code: Byte; const Domain: AnsiString; const Port: Word;
          const UserID: AnsiString): AnsiString;
function  Socks4aConnectRequest(const Domain: AnsiString; const Port: Word;
          const UserID: AnsiString = ''): AnsiString;



{ Socks 4 Response                                                             }
procedure PopulateSocks4ErrorResponse(var Msg : TSocks4Message; const Code: Byte);
function  IsGrantedSocks4ResponseCode(const Code: Byte): Boolean;



{                                                                              }
{ SOCKS5                                                                       }
{   From RFC 1928 (Socks5) and RFC 1929 (Socks5 User/Pass Authentication).     }
{                                                                              }
const
  SOCKS5_MSG_VERSION = 5;



{ Socks 5 Greeting                                                             }
type
  TSocks5Greeting = packed record
    Version : Byte;
    Methods : Byte;
    Method1 : Byte;
  end;
  PSocks5Greeting = ^TSocks5Greeting;

const
  SOCKS5_METHOD_NOAUTH    = 0;
  SOCKS5_METHOD_GSSAPI    = 1;
  SOCKS5_METHOD_USERPASS  = 2;
  SOCKS5_METHOD_RESERVED0 = 3;   // ..$7F IANA ASSIGNED
  SOCKS5_METHOD_PRIVATE0  = $80; // ..$FE PRIVATE METHODS
  SOCKS5_METHOD_INVALID   = $FF; // NO ACCEPTABLE METHODS

procedure PopulateSocks5Greeting(var Greeting: TSocks5Greeting;
          const Method: Byte);
procedure PopulateSocks5GreetingNoAuth(var Greeting: TSocks5Greeting);
procedure PopulateSocks5GreetingUserPass(var Greeting: TSocks5Greeting);



{ Socks 5 Greeting Response                                                    }
type
  TSocks5GreetingResponse = packed record
    Version : Byte;
    Method  : Byte;
  end;
  PSocks5GreetingResponse = ^TSocks5GreetingResponse;

procedure PopulateSocks5GreetingResponse(var Response: TSocks5GreetingResponse;
          const Method: Byte);
function  Socks5GreetingResponse(const Method: Byte): AnsiString;

const
  SOCKS5_GREETING_RESPONSE_NOAUTH   = AnsiChar(SOCKS5_MSG_VERSION) +
                                      AnsiChar(SOCKS5_METHOD_NOAUTH);
  SOCKS5_GREETING_RESPONSE_USERPASS = AnsiChar(SOCKS5_MSG_VERSION) +
                                      AnsiChar(SOCKS5_METHOD_USERPASS);
  SOCKS5_GREETING_RESPONSE_INVALID  = AnsiChar(SOCKS5_MSG_VERSION) +
                                      AnsiChar(SOCKS5_METHOD_INVALID);



{ Socks 5 UserPass                                                             }
const
  SOCKS5_USERPASS_VERSION = 1;

  SOCKS5_USERPASS_MAX_MSG_SIZE = 513;

  SOCKS5_USERPASS_STATUS_OK   = 0;
  SOCKS5_USERPASS_STATUS_FAIL = 1;

  SOCKS5_USERPASS_RESPONSE_OK   = AnsiChar(SOCKS5_USERPASS_VERSION) +
                                  AnsiChar(SOCKS5_USERPASS_STATUS_OK);
  SOCKS5_USERPASS_RESPONSE_FAIL = AnsiChar(SOCKS5_USERPASS_VERSION) +
                                  AnsiChar(SOCKS5_USERPASS_STATUS_FAIL);

function Socks5UserPassMessage(const Username, Password: AnsiString): AnsiString;

type
  TSocks5UserPassResponse = packed record
    Version : Byte;
    Status  : Byte;
  end;
  PSocks5UserPassResponse = ^TSocks5UserPassResponse;

procedure PopulateSocks5UserPassResponse(var Response: TSocks5UserPassResponse;
          const Status: Byte);



{ Socks 5 Messages                                                             }
const
  SOCKS5_REQ_CODE_CONNECT       = 1;
  SOCKS5_REQ_CODE_BIND          = 2;
  SOCKS5_REQ_CODE_UDP_ASSOCIATE = 3;

  SOCKS5_RESP_CODE_Success                 = 0;
  SOCKS5_RESP_CODE_GeneralServerFailure    = 1;
  SOCKS5_RESP_CODE_ConnectionNotAllowed    = 2;
  SOCKS5_RESP_CODE_NetworkUnreachable      = 3;
  SOCKS5_RESP_CODE_HostUnreachable         = 4;
  SOCKS5_RESP_CODE_ConnectionRefused       = 5;
  SOCKS5_RESP_CODE_TTLExpired              = 6;
  SOCKS5_RESP_CODE_CommandNotSupported     = 7;
  SOCKS5_RESP_CODE_AddressTypeNotSupported = 8;

  SOCKS5_ADDR_TYPE_IP4    = 1;
  SOCKS5_ADDR_TYPE_DOMAIN = 3;
  SOCKS5_ADDR_TYPE_IP6    = 4;

  SOCKS5_ADDRMSG_MAX_MSG_SIZE = 296;

function Socks5ErrorDescription(const Code: Integer): String;



{ Socks 5 IP4 Message                                                          }
type
  TSocks5IP4Message = packed record
    Version  : Byte;
    Code     : Byte;
    Reserved : Byte;
    AddrType : Byte;
    IP4Addr  : TIP4Addr;
    Port     : Word;
  end;
  PSocks5IP4Message = ^TSocks5IP4Message;

procedure PopulateSocks5IP4Message(var Msg: TSocks5IP4Message;
          const Command: Byte; const Addr: TIP4Addr; const NetPort: Word);
procedure PopulateSocks5IP4ErrorReply(var Msg: TSocks5IP4Message;
          const ResponseCode: Byte);



{ Socks 5 IP6 Message                                                          }
type
  TSocks5IP6Message = packed record
    Version  : Byte;
    Code     : Byte;
    Reserved : Byte;
    AddrType : Byte;
    IP6Addr  : TIP6Addr;
    Port     : Word;
  end;
  PSocks5IP6Message = ^TSocks5IP6Message;

procedure PopulateSocks5IP6Message(var Msg: TSocks5IP6Message;
          const Command: Byte; const Addr: TIP6Addr; const NetPort: Word);
procedure PopulateSocks5IP6ErrorReply(var Msg: TSocks5IP6Message;
          const ResponseCode: Byte);



{ Socks 5 Domain Message                                                       }
type
  TSocks5DomainMessageHeader = packed record
    Version  : Byte;
    Code     : Byte;
    Reserved : Byte;
    AddrType : Byte;
    NameLen  : Byte;
  end;
  PSocks5DomainMessageHeader = ^TSocks5DomainMessageHeader;

procedure PopulateSocks5DomainMessageHeader(var MsgHdr: TSocks5DomainMessageHeader;
          const Command: Byte; const Domain: AnsiString);
function  Socks5DomainRequest(const Command: Byte; const Domain: AnsiString;
          const NetPort: Word): AnsiString;



{ Socks 5 Response                                                             }
type
  TSocks5ResponseHeader = packed record
    Version   : Byte;
    Code      : Byte;
    Reserved  : Byte;
    AddrType  : Byte;
    Addr1     : Byte;  // First byte of address (Length for saDomainName)
  end;
  PSocks5ResponseHeader = ^TSocks5ResponseHeader;

function  Socks5ResponseSize(const Header: PSocks5ResponseHeader): Integer;



{ Socks 5 constants                                                            }
const
  SOCKS5_MAX_MSG_SIZE = SOCKS5_USERPASS_MAX_MSG_SIZE;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DEBUG}
procedure SelfTest;
{$ENDIF}



implementation



{                                                                              }
{ SOCKS4                                                                       }
{                                                                              }

{ Socks 4 constants                                                            }
function Socks4ErrorDescription(const Code: Integer): String;
begin
  case Code of
    SOCKS4_RESP_CODE_GRANTED         : Result := '';
    SOCKS4_RESP_CODE_FAILED          : Result := 'Failed';
    SOCKS4_RESP_CODE_NO_IDENTD       : Result := 'No identd';
    SOCKS4_RESP_CODE_IDENTD_MISMATCH : Result := 'Identd mismatch';
  else
    Result := 'Error ' + IntToStr(Code);
  end;
end;



{ Socks 4 Message                                                              }
procedure PopulateSocks4Message(var Msg : TSocks4Message;
          const Code: Byte; const IP: TIP4Addr; const Port: Word);
begin
  FillChar(Msg, Sizeof(Msg), 0);
  Msg.Version := SOCKS4_MSG_VERSION;
  Msg.Code := Code;
  Msg.DestPort := PortToNetPort(Port);
  Msg.DestIP := IP.Addr32;
end;



{ Socks 4 Request                                                              }
function Socks4Request(const Code: Byte; const IP: TIP4Addr; const Port: Word;
    const UserID: AnsiString): AnsiString;
var P : PAnsiChar;
    L : Integer;
begin
  L := Length(UserID);
  SetLength(Result, Sizeof(TSocks4Message) + L + 1);
  P := Pointer(Result);
  PopulateSocks4Message(PSocks4Message(P)^, Code, IP, Port);
  Inc(P, Sizeof(TSocks4Message));
  if L > 0 then
    begin
      Move(Pointer(UserID)^, P^, L);
      Inc(P, L);
    end;
  P^ := #0;
end;

function Socks4ConnectRequest(const IP: TIP4Addr; const Port: Word;
    const UserID: AnsiString): AnsiString;
begin
  Result := Socks4Request(SOCKS4_REQ_CODE_CONNECT, IP, Port, UserID);
end;

function Socks4BindRequest(const IP: TIP4Addr; const Port: Word;
    const UserID: AnsiString): AnsiString;
begin
  Result := Socks4Request(SOCKS4_REQ_CODE_BIND, IP, Port, UserID);
end;



{ Socks 4a Request                                                             }
function Socks4aRequest(const Code: Byte; const Domain: AnsiString; const Port: Word;
    const UserID: AnsiString): AnsiString;
var IP   : TIP4Addr;
    L, M : Integer;
    P    : PAnsiChar;
begin
  IP.Addr32 := 0;
  IP.Addr8[3] := $FF;
  Result := Socks4Request(Code, IP, Port, UserID);
  M := Length(Result);
  L := Length(Domain);
  SetLength(Result, M + L + 1);
  P := Pointer(Result);
  Inc(P, M);
  if L > 0 then
    begin
      Move(Pointer(Domain)^, P^, L);
      Inc(P, L);
    end;
  P^ := #0;
end;

function Socks4aConnectRequest(const Domain: AnsiString; const Port: Word;
    const UserID: AnsiString): AnsiString;
begin
  Result := Socks4aRequest(SOCKS4_REQ_CODE_CONNECT, Domain, Port, UserID);
end;



{ Socks 4 Response                                                             }
procedure PopulateSocks4ErrorResponse(var Msg : TSocks4Message; const Code: Byte);
var A : TIP4Addr;
begin
  A.Addr32 := 0;
  PopulateSocks4Message(Msg, Code, A, 0);
end;

function IsGrantedSocks4ResponseCode(const Code: Byte): Boolean;
begin
  Result := Code = SOCKS4_RESP_CODE_GRANTED;
end;



{                                                                              }
{ SOCKS5                                                                       }
{                                                                              }

{ Socks 5 Greeting                                                             }
procedure PopulateSocks5Greeting(var Greeting : TSocks5Greeting;
    const Method: Byte);
begin
  FillChar(Greeting, Sizeof(TSocks5Greeting), 0);
  Greeting.Version := SOCKS5_MSG_VERSION;
  Greeting.Methods := 1;
  Greeting.Method1 := Method;
end;

procedure PopulateSocks5GreetingNoAuth(var Greeting: TSocks5Greeting);
begin
  PopulateSocks5Greeting(Greeting, SOCKS5_METHOD_NOAUTH);
end;

procedure PopulateSocks5GreetingUserPass(var Greeting : TSocks5Greeting);
begin
  PopulateSocks5Greeting(Greeting, SOCKS5_METHOD_USERPASS)
end;



{ Socks 5 Greeting Response                                                    }
procedure PopulateSocks5GreetingResponse(var Response : TSocks5GreetingResponse;
    const Method: Byte);
begin
  FillChar(Response, Sizeof(TSocks5GreetingResponse), 0);
  Response.Version := SOCKS5_MSG_VERSION;
  Response.Method := Method;
end;

function Socks5GreetingResponse(const Method: Byte): AnsiString;
var P : PSocks5GreetingResponse;
begin
  SetLength(Result, Sizeof(TSocks5GreetingResponse));
  P := Pointer(Result);
  PopulateSocks5GreetingResponse(P^, Method);
end;



{ Socks 5 UserPass                                                             }
function Socks5UserPassMessage(const Username, Password: AnsiString): AnsiString;
var L, M : Integer;
    P    : PAnsiChar;
begin
  L := Length(UserName);
  if L > 255 then
    raise ESocks.Create('Username too long for use with SOCKS');
  M := Length(Password);
  if M > 255 then
    raise ESocks.Create('Password too long for use with SOCKS');
  SetLength(Result, 3 + L + M);
  P := Pointer(Result);
  P[0] := AnsiChar(SOCKS5_USERPASS_VERSION);
  P[1] := AnsiChar(L);
  if L > 0 then
    Move(Pointer(UserName)^, P[2], L);
  P[2 + L] := AnsiChar(M);
  if M > 0 then
    Move(Pointer(Password)^, P[3 + L], M);
end;

procedure PopulateSocks5UserPassResponse(var Response : TSocks5UserPassResponse;
    const Status: Byte);
begin
  FillChar(Response, Sizeof(TSocks5UserPassResponse), 0);
  Response.Version := SOCKS5_USERPASS_VERSION;
  Response.Status := Status;
end;



{ Socks 5 Messages                                                             }
function Socks5ErrorDescription(const Code: Integer): String;
begin
  case Code of
    SOCKS5_RESP_CODE_Success                 : Result := '';
    SOCKS5_RESP_CODE_GeneralServerFailure    : Result := 'General server failure';
    SOCKS5_RESP_CODE_ConnectionNotAllowed    : Result := 'Connection not allowed';
    SOCKS5_RESP_CODE_NetworkUnreachable      : Result := 'Network unreachable';
    SOCKS5_RESP_CODE_HostUnreachable         : Result := 'Host unreachable';
    SOCKS5_RESP_CODE_ConnectionRefused       : Result := 'Connection refused';
    SOCKS5_RESP_CODE_TTLExpired              : Result := 'TTL expired';
    SOCKS5_RESP_CODE_CommandNotSupported     : Result := 'Command not supported';
    SOCKS5_RESP_CODE_AddressTypeNotSupported : Result := 'Address type not supported';
  else
    Result := 'Server error ' + IntToStr(Code);
  end;
end;



{ Socks 5 IP4 Message                                                          }
procedure PopulateSocks5IP4Message(var Msg : TSocks5IP4Message; const Command: Byte;
    const Addr: TIP4Addr; const NetPort: Word);
begin
  FillChar(Msg, Sizeof(TSocks5IP4Message), 0);
  Msg.Version  := SOCKS5_MSG_VERSION;
  Msg.Code     := Command;
  Msg.Reserved := $00;
  Msg.AddrType := SOCKS5_ADDR_TYPE_IP4;
  Msg.IP4Addr  := Addr;
  Msg.Port     := NetPort;
end;

procedure PopulateSocks5IP4ErrorReply(var Msg : TSocks5IP4Message; const ResponseCode: Byte);
var A : TIP4Addr;
begin
  A.Addr32 := 0;
  PopulateSocks5IP4Message(Msg, ResponseCode, A, 0);
end;



{ Socks 5 IP6 Message                                                          }
procedure PopulateSocks5IP6Message(var Msg: TSocks5IP6Message;
    const Command: Byte; const Addr: TIP6Addr; const NetPort: Word);
begin
  FillChar(Msg, Sizeof(TSocks5IP6Message), 0);
  Msg.Version  := SOCKS5_MSG_VERSION;
  Msg.Code     := Command;
  Msg.Reserved := $00;
  Msg.AddrType := SOCKS5_ADDR_TYPE_IP6;
  Msg.IP6Addr  := Addr;
  Msg.Port     := NetPort;
end;

procedure PopulateSocks5IP6ErrorReply(var Msg: TSocks5IP6Message;
          const ResponseCode: Byte);
var A : TIP6Addr;
begin
  FillChar(A, Sizeof(TIP6Addr), 0);
  PopulateSocks5IP6Message(Msg, ResponseCode, A, 0);
end;



{ Socks 5 Domain Message                                                       }
procedure PopulateSocks5DomainMessageHeader(var MsgHdr: TSocks5DomainMessageHeader;
    const Command: Byte; const Domain: AnsiString);
var L : Integer;
begin
  L := Length(Domain);
  if L > 255 then
    raise ESocks.Create('Domain name too long for use with SOCKS5');
  FillChar(MsgHdr, Sizeof(TSocks5DomainMessageHeader), 0);
  MsgHdr.Version  := SOCKS5_MSG_VERSION;
  MsgHdr.Code     := Command;
  MsgHdr.Reserved := $00;
  MsgHdr.AddrType := SOCKS5_ADDR_TYPE_DOMAIN;
  MsgHdr.NameLen  := Byte(L);
end;

function Socks5DomainRequest(const Command: Byte; const Domain: AnsiString;
    const NetPort: Word): AnsiString;
var L : Integer;
    P : PAnsiChar;
begin
  L := Length(Domain);
  if L > 255 then
    raise ESocks.Create('Domain name too long for use with SOCKS');
  SetLength(Result, 7 + L);
  P := Pointer(Result);
  PopulateSocks5DomainMessageHeader(PSocks5DomainMessageHeader(P)^, Command, Domain);
  Inc(P, Sizeof(TSocks5DomainMessageHeader));
  if L > 0 then
    begin
      Move(Pointer(Domain)^, P^, L);
      Inc(P, L);
    end;
  Move(NetPort, P^, 2);
end;



{ Socks 5 Response                                                             }
function Socks5ResponseSize(const Header: PSocks5ResponseHeader): Integer;
begin
  case Header^.AddrType of
    SOCKS5_ADDR_TYPE_IP4    : Result := 10;
    SOCKS5_ADDR_TYPE_IP6    : Result := 22;
    SOCKS5_ADDR_TYPE_DOMAIN : Result := 7 + Header^.Addr1;
  else
    raise ESocks.Create('Socks5 Address type #' + IntToStr(Header^.AddrType) +
        ' not supported');
  end;
end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DEBUG}{$ASSERTIONS ON}
procedure SelfTest;
begin
end;
{$ENDIF}



end.

