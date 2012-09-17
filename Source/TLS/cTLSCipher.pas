{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals TLS                                         }
{   File name:        cTLSCipher.pas                                           }
{   File version:     0.03                                                     }
{   Description:      TLS cipher                                               }
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
{   2008/01/18  0.01  Initial version.                                         }
{   2010/11/30  0.02  Revision.                                                }
{   2010/12/16  0.03  AES support.                                             }
{                                                                              }
{******************************************************************************}

{$INCLUDE cTLS.inc}

unit cTLSCipher;

interface

uses
  { Cipher }
  cCipher,
  { TLS }
  cTLSCipherSuite;



{                                                                              }
{ Cipher info                                                                  }
{                                                                              }
type
  TTLSCipherSuiteCipherCipherInfo = record
    CipherType : TCipherType;
    CipherMode : TCipherMode;
    Padding    : TCipherPadding;
  end;
  PTLSCipherSuiteCipherCipherInfo = ^TTLSCipherSuiteCipherCipherInfo;

const
  TLSCipherSuiteCipherCipherInfo : array[TTLSCipherSuiteCipher] of TTLSCipherSuiteCipherCipherInfo = (
    ( // None
     CipherType : ctNone;
     CipherMode : cmECB;
     Padding    : cpNone),
    ( // NULL
     CipherType : ctNone;
     CipherMode : cmECB;
     Padding    : cpNone),
    ( // RC4_40
     CipherType : ctRC4;
     CipherMode : cmECB;
     Padding    : cpNone),
    ( // RC4_56
     CipherType : ctRC4;
     CipherMode : cmECB;
     Padding    : cpNone),
    ( // RC4_128
     CipherType : ctRC4;
     CipherMode : cmECB;
     Padding    : cpNone),
    ( // RC2_CBC_40
     CipherType : ctRC2;
     CipherMode : cmCBC;
     Padding    : cpNone),
    ( // IDEA_CBC
     CipherType : ctNone;
     CipherMode : cmCBC;
     Padding    : cpNone),
    ( // DES40_CBC
     CipherType : ctDES;
     CipherMode : cmCBC;
     Padding    : cpNone),
    ( // DES_CBC
     CipherType : ctDES;
     CipherMode : cmCBC;
     Padding    : cpNone),
    ( // 3DES_EDE_CBC
     CipherType : ctTripleDESEDE;
     CipherMode : cmCBC;
     Padding    : cpNone),
    ( // AES_128_CBC
     CipherType : ctAES;
     CipherMode : cmCBC;
     Padding    : cpNone),
    ( // AES_256_CBC
     CipherType : ctAES;
     CipherMode : cmCBC;
     Padding    : cpNone)
  );



{                                                                              }
{ Cipher state                                                                 }
{                                                                              }
type
  TTLSCipherOperation = (
    tlscoNone,
    tlscoEncrypt,
    tlscoDecrypt);

  TTLSCipherState = record
    Operation     : TTLSCipherOperation;
    TLSCipher     : TTLSCipherSuiteCipher;
    TLSCipherInfo : TTLSCipherSuiteCipherInfo;
    CipherInfo    : TTLSCipherSuiteCipherCipherInfo;
    CipherState   : TCipherState;
  end;



{                                                                              }
{ Cipher                                                                       }
{                                                                              }
procedure TLSCipherInitNone(
          var CipherState: TTLSCipherState;
          const Operation: TTLSCipherOperation);
procedure TLSCipherInitNULL(
          var CipherState: TTLSCipherState;
          const Operation: TTLSCipherOperation);
procedure TLSCipherInit(
          var CipherState: TTLSCipherState;
          const Operation: TTLSCipherOperation;
          const TLSCipher: TTLSCipherSuiteCipher;
          const KeyBuf;
          const KeySize: Integer);

procedure TLSCipherBuf(
          var CipherState: TTLSCipherState;
          const MessageBuf;
          const MessageSize: Integer;
          var   CipherBuf;
          const CipherBufSize: Integer;
          out   CipherSize: Integer;
          const IVBufPtr: Pointer;
          const IVBufSize: Integer);

procedure TLSCipherFinalise(var CipherState: TTLSCipherState);



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF TLS_SELFTEST}
procedure SelfTest;
{$ENDIF}



implementation

uses
  { TLS }
  cTLSUtils;



{                                                                              }
{ Cipher                                                                       }
{                                                                              }
procedure TLSCipherInitNone(
          var CipherState: TTLSCipherState;
          const Operation: TTLSCipherOperation);
begin
  FillChar(CipherState, SizeOf(CipherState), 0);
  CipherState.Operation     := Operation;
  CipherState.TLSCipher     := tlscscNone;
  CipherState.TLSCipherInfo := TLSCipherSuiteCipherInfo[tlscscNone];
  CipherState.CipherInfo    := TLSCipherSuiteCipherCipherInfo[tlscscNone];
end;

procedure TLSCipherInitNULL(
          var CipherState: TTLSCipherState;
          const Operation: TTLSCipherOperation);
begin
  FillChar(CipherState, SizeOf(CipherState), 0);
  CipherState.Operation     := Operation;
  CipherState.TLSCipher     := tlscscNULL;
  CipherState.TLSCipherInfo := TLSCipherSuiteCipherInfo[tlscscNULL];
  CipherState.CipherInfo    := TLSCipherSuiteCipherCipherInfo[tlscscNULL];
end;

procedure TLSCipherInit(
          var CipherState: TTLSCipherState;
          const Operation: TTLSCipherOperation;
          const TLSCipher: TTLSCipherSuiteCipher;
          const KeyBuf;
          const KeySize: Integer);
begin
  FillChar(CipherState, SizeOf(CipherState), 0);
  CipherState.Operation     := Operation;
  CipherState.TLSCipher     := TLSCipher;
  CipherState.TLSCipherInfo := TLSCipherSuiteCipherInfo[TLSCipher];
  CipherState.CipherInfo    := TLSCipherSuiteCipherCipherInfo[TLSCipher];
  case Operation of
    tlscoEncrypt :
      EncryptInit(
          CipherState.CipherState,
          CipherState.CipherInfo.CipherType,
          CipherState.CipherInfo.CipherMode,
          CipherState.CipherInfo.Padding,
          CipherState.TLSCipherInfo.KeyBits, @KeyBuf, KeySize);
    tlscoDecrypt :
      DecryptInit(
          CipherState.CipherState,
          CipherState.CipherInfo.CipherType,
          CipherState.CipherInfo.CipherMode,
          CipherState.CipherInfo.Padding,
          CipherState.TLSCipherInfo.KeyBits, @KeyBuf, KeySize);
  end;
end;

procedure TLSCipherBuf(
          var CipherState: TTLSCipherState;
          const MessageBuf;
          const MessageSize: Integer;
          var CipherBuf;
          const CipherBufSize: Integer;
          out CipherSize: Integer;
          const IVBufPtr: Pointer;
          const IVBufSize: Integer);
begin
  if CipherState.Operation = tlscoNone then
    raise ETLSError.Create(TLSError_InvalidParameter); // cipher not initialised
  if MessageSize < 0 then
    raise ETLSError.Create(TLSError_InvalidBuffer);
  if CipherBufSize < MessageSize then
    raise ETLSError.Create(TLSError_InvalidBuffer);
  if CipherState.TLSCipher in [tlscscNone, tlscscNULL] then
    begin
      Move(MessageBuf, CipherBuf, MessageSize);
      CipherSize := MessageSize;
    end
  else
  case CipherState.Operation of
    tlscoEncrypt :
      CipherSize := EncryptBuf(CipherState.CipherState,
          @MessageBuf, MessageSize,
          @CipherBuf, CipherBufSize,
          IVBufPtr, IVBufSize);
    tlscoDecrypt :
      begin
        Move(MessageBuf, CipherBuf, MessageSize);
        CipherSize := DecryptBuf(CipherState.CipherState,
            @CipherBuf, MessageSize,
            IVBufPtr, IVBufSize);
      end;
  end;
end;

procedure TLSCipherFinalise(var CipherState: TTLSCipherState);
begin
  case CipherState.Operation of
    tlscoEncrypt : EncryptFinalise(CipherState.CipherState);
    tlscoDecrypt : DecryptFinalise(CipherState.CipherState);
  end;
end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF TLS_SELFTEST}
procedure SelfTest;
const
  ClientWriteKey = #$10#$D0#$D6#$C2#$D9#$B7#$62#$CB#$2C#$74#$BF#$5F#$85#$3C#$6F#$E7;
var
  S, T : AnsiString;
  C : TTLSCipherState;
  B : AnsiString;
  L : Integer;
begin
  //                                                                                              //
  // Example from http://download.oracle.com/javase/1.5.0/docs/guide/security/jsse/ReadDebug.html //
  //                                                                                              //
  S := ClientWriteKey;
  TLSCipherInit(C, tlscoEncrypt, tlscscRC4_128, S[1], Length(S));
  T :=
      #$14#$00#$00#$0C#$F2#$62#$42#$AA#$7C#$7C#$CC#$E7#$49#$0F#$ED#$AC +
      #$FA#$06#$3C#$9F#$8C#$41#$1D#$ED#$2B#$06#$D0#$5A#$ED#$31#$F2#$80;
  SetLength(B, 1024);
  L := 1024;
  TLSCipherBuf(C, T[1], Length(T), B[1], L, L, nil, 0);
  SetLength(B, L);
  Assert(B =
      #$15#$8C#$25#$BA#$4E#$73#$F5#$27#$79#$49#$B1 +
      #$E9#$F5#$7E#$C8#$48#$A7#$D3#$A6#$9B#$BD#$6F#$8E#$A5#$8E#$2B#$B7 +
      #$EE#$DC#$BD#$F4#$D7);
end;
{$ENDIF}



end.

