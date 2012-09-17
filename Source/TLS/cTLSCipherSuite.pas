{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals TLS                                         }
{   File name:        cTLSCipherSuite.pas                                      }
{   File version:     0.01                                                     }
{   Description:      TLS cipher suite                                         }
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
{   2008/01/18  0.01  Initial version                                          }
{                                                                              }
{******************************************************************************}

{$INCLUDE cTLS.inc}

unit cTLSCipherSuite;

interface

uses
  { TLS }
  cTLSUtils;



{                                                                              }
{ Cipher Suite                                                                 }
{                                                                              }
type
  TTLSCipherSuite = (
    tlscsNone,
    tlscsNULL_WITH_NULL_NULL,
    tlscsRSA_WITH_NULL_MD5,
    tlscsRSA_WITH_NULL_SHA,
    tlscsRSA_EXPORT_WITH_RC4_40_MD5,
    tlscsRSA_WITH_RC4_128_MD5,
    tlscsRSA_WITH_RC4_128_SHA,
    tlscsRSA_EXPORT_WITH_RC2_CBC_40_MD5,
    tlscsRSA_WITH_IDEA_CBC_SHA,
    tlscsRSA_EXPORT_WITH_DES40_CBC_SHA,
    tlscsRSA_WITH_DES_CBC_SHA,
    tlscsRSA_WITH_3DES_EDE_CBC_SHA,
    tlscsRSA_EXPORT1024_WITH_DES_CBC_SHA,            // draft-ietf-tls-56-bit-ciphersuites-01
    tlscsRSA_EXPORT1024_WITH_RC4_56_SHA,             // draft-ietf-tls-56-bit-ciphersuites-01
    tlscsRSA_WITH_NULL_SHA256,
    tlscsRSA_WITH_AES_128_CBC_SHA,
    tlscsRSA_WITH_AES_256_CBC_SHA,
    tlscsRSA_WITH_AES_128_CBC_SHA256,
    tlscsRSA_WITH_AES_256_CBC_SHA256,
    tlscsDH_DSS_EXPORT_WITH_DES40_CBC_SHA,
    tlscsDH_DSS_WITH_DES_CBC_SHA,
    tlscsDH_DSS_WITH_3DES_EDE_CBC_SHA,
    tlscsDH_RSA_EXPORT_WITH_DES40_CBC_SHA,
    tlscsDH_RSA_WITH_DES_CBC_SHA,
    tlscsDH_RSA_WITH_3DES_EDE_CBC_SHA,
    tlscsDHE_DSS_EXPORT_WITH_DES40_CBC_SHA,
    tlscsDHE_DSS_WITH_DES_CBC_SHA,
    tlscsDHE_DSS_WITH_3DES_EDE_CBC_SHA,              // required
    tlscsDHE_DSS_WITH_RC4_128_SHA,                   // draft-ietf-tls-56-bit-ciphersuites-01
    tlscsDHE_RSA_EXPORT_WITH_DES40_CBC_SHA,
    tlscsDHE_RSA_WITH_DES_CBC_SHA,
    tlscsDHE_RSA_WITH_3DES_EDE_CBC_SHA,
    tlscsDH_Anon_EXPORT_WITH_RC4_40_MD5,
    tlscsDH_Anon_WITH_RC4_128_MD5,
    tlscsDH_Anon_EXPORT_WITH_DES40_CBC_SHA,
    tlscsDH_Anon_WITH_DES_CBC_SHA,
    tlscsDH_Anon_WITH_3DES_EDE_CBC_SHA,
    tlscsDH_DSS_WITH_AES_128_CBC_SHA,
    tlscsDH_DSS_WITH_AES_256_CBC_SHA,
    tlscsDH_DSS_WITH_AES_128_CBC_SHA256,
    tlscsDH_DSS_WITH_AES_256_CBC_SHA256,
    tlscsDH_RSA_WITH_AES_128_CBC_SHA,
    tlscsDH_RSA_WITH_AES_256_CBC_SHA,
    tlscsDH_RSA_WITH_AES_128_CBC_SHA256,
    tlscsDH_RSA_WITH_AES_256_CBC_SHA256,
    tlscsDHE_DSS_WITH_AES_128_CBC_SHA,
    tlscsDHE_DSS_WITH_AES_256_CBC_SHA,
    tlscsDHE_DSS_WITH_AES_128_CBC_SHA256,
    tlscsDHE_DSS_WITH_AES_256_CBC_SHA256,
    tlscsDHE_RSA_WITH_AES_128_CBC_SHA,
    tlscsDHE_RSA_WITH_AES_256_CBC_SHA,
    tlscsDHE_RSA_WITH_AES_128_CBC_SHA256,
    tlscsDHE_RSA_WITH_AES_256_CBC_SHA256
  );
  TTLSCipherSuites = set of TTLSCipherSuite;

  TTLSCipherSuiteKeyExchange = (
    tlscskeNone,
    tlscskeNULL,
    tlscskeRSA,
    tlscskeRSA_EXPORT,
    tlscskeRSA_EXPORT1024,
    tlscskeDH_DSS_EXPORT,
    tlscskeDH_DSS,
    tlscskeDH_RSA_EXPORT,
    tlscskeDH_RSA,
    tlscskeDHE_DSS_EXPORT,
    tlscskeDHE_DSS,
    tlscskeDHE_RSA_EXPORT,
    tlscskeDHE_RSA,
    tlscskeDH_anon_EXPORT,
    tlscskeDH_anon
  );

  TTLSCipherSuiteCipher = (
    tlscscNone,
    tlscscNULL,
    tlscscRC4_40,
    tlscscRC4_56,
    tlscscRC4_128,
    tlscscRC2_CBC_40,
    tlscscIDEA_CBC,
    tlscscDES40_CBC,
    tlscscDES_CBC,
    tlscsc3DES_EDE_CBC,
    tlscscAES_128_CBC,
    tlscscAES_256_CBC
  );

  TTLSCipherSuiteHash = (
    tlscshNone,
    tlscshNULL,
    tlscshSHA,
    tlscshSHA256,
    tlscshMD5
  );

type
  TTLSCipherSuiteRec = packed record
    B1, B2 : Byte;
  end;
  PTLSCipherSuiteRec = ^TTLSCipherSuiteRec;

const
  TLSCipherSuiteRecSize = Sizeof(TTLSCipherSuiteRec);

type
  TTLSCipherSuiteInfo = record
    Name          : AnsiString;
    KeyExchange   : TTLSCipherSuiteKeyExchange;
    Cipher        : TTLSCipherSuiteCipher;
    Hash          : TTLSCipherSuiteHash;
    Rec           : TTLSCipherSuiteRec;
    ServerSupport : Boolean;
    MinVersion    : TTLSProtocolVersion;
  end;
  PTLSCipherSuiteInfo = ^TTLSCipherSuiteInfo;

const
  TLSCipherSuiteInfo : array[TTLSCipherSuite] of TTLSCipherSuiteInfo = (
    ( // None
    Name          : '';
    KeyExchange   : tlscskeNone;
    Cipher        : tlscscNone;
    Hash          : tlscshNone;
    Rec           : (B1: $FF; B2: $FF);
    ServerSupport : False;
    MinVersion    : (major: 0; minor: 0);
    ),
    ( // NULL_WITH_NULL_NULL
    Name          : 'NULL_WITH_NULL_NULL';
    KeyExchange   : tlscskeNULL;
    Cipher        : tlscscNULL;
    Hash          : tlscshNULL;
    Rec           : (B1: $00; B2: $00);
    ServerSupport : False;
    MinVersion    : (major: 0; minor: 0);
    ),
    ( // RSA_WITH_NULL_MD5
    Name          : 'RSA_WITH_NULL_MD5';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscscNULL;
    Hash          : tlscshMD5;
    Rec           : (B1: $00; B2: $01);
    ServerSupport : False;
    ),
    ( // RSA_WITH_NULL_SHA
    Name          : 'RSA_WITH_NULL_SHA';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscscNULL;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $02);
    ServerSupport : False;
    ),
    ( // RSA_EXPORT_WITH_RC4_40_MD5
    Name          : 'RSA_EXPORT_WITH_RC4_40_MD5';
    KeyExchange   : tlscskeRSA_EXPORT;
    Cipher        : tlscscRC4_40;
    Hash          : tlscshMD5;
    Rec           : (B1: $00; B2: $03);
    ServerSupport : False;
    MinVersion    : (major: 3; minor: 0); // SSL 3
    ),
    ( // RSA_WITH_RC4_128_MD5
    Name          : 'RSA_WITH_RC4_128_MD5';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscscRC4_128;
    Hash          : tlscshMD5;
    Rec           : (B1: $00; B2: $04);
    ServerSupport : True;
    MinVersion    : (major: 3; minor: 0); // SSL 3
    ),
    ( // RSA_WITH_RC4_128_SHA
    Name          : 'RSA_WITH_RC4_128_SHA';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscscRC4_128;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $05);
    ServerSupport : True;
    MinVersion    : (major: 3; minor: 0); // SSL 3
    ),
    ( // RSA_EXPORT_WITH_RC2_CBC_40_MD5
    Name          : 'RSA_EXPORT_WITH_RC2_CBC_40_MD5';
    KeyExchange   : tlscskeRSA_EXPORT;
    Cipher        : tlscscRC2_CBC_40;
    Hash          : tlscshMD5;
    Rec           : (B1: $00; B2: $06);
    ServerSupport : False;
    MinVersion    : (major: 3; minor: 0); // SSL 3
    ),
    ( // RSA_WITH_IDEA_CBC_SHA
    Name          : 'RSA_WITH_IDEA_CBC_SHA';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscscIDEA_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $07);
    ServerSupport : False;
    ),
    ( // RSA_EXPORT_WITH_DES40_CBC_SHA
    Name          : 'RSA_EXPORT_WITH_DES40_CBC_SHA';
    KeyExchange   : tlscskeRSA_EXPORT;
    Cipher        : tlscscDES40_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $08);
    ServerSupport : False;
    ),
    ( // RSA_WITH_DES_CBC_SHA
    Name          : 'RSA_WITH_DES_CBC_SHA';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscscDES_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $09);
    ServerSupport : True;
    MinVersion    : (major: 3; minor: 0); // SSL 3
    ),
    ( // RSA_WITH_3DES_EDE_CBC_SHA
    Name          : 'RSA_WITH_3DES_EDE_CBC_SHA';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscsc3DES_EDE_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $0A);
    ServerSupport : False;
    MinVersion    : (major: 3; minor: 0); // SSL 3
    ),
    ( // RSA_EXPORT1024_WITH_DES_CBC_SHA
    Name          : 'RSA_EXPORT1024_WITH_DES_CBC_SHA';
    KeyExchange   : tlscskeRSA_EXPORT1024;
    Cipher        : tlscscDES_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $62);
    ServerSupport : False;
    MinVersion    : (major: 3; minor: 0); // SSL 3
    ),
    ( // RSA_EXPORT1024_WITH_RC4_56_SHA
    Name          : 'RSA_EXPORT1024_WITH_RC4_56_SHA';
    KeyExchange   : tlscskeRSA_EXPORT1024;
    Cipher        : tlscscRC4_56;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $64);
    ServerSupport : False;
    MinVersion    : (major: 3; minor: 0); // SSL 3
    ),
    ( // RSA_WITH_NULL_SHA256
    Name          : 'RSA_WITH_NULL_SHA256';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscscNULL;
    Hash          : tlscshSHA256;
    Rec           : (B1: $00; B2: $3B);
    ServerSupport : False;
    ),
    ( // RSA_WITH_AES_128_CBC_SHA
    Name          : 'RSA_WITH_AES_128_CBC_SHA';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscscAES_128_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $2F);
    ServerSupport : True;
    ),
    ( // RSA_WITH_AES_256_CBC_SHA
    Name          : 'RSA_WITH_AES_256_CBC_SHA';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscscAES_256_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $35);
    ServerSupport : True;
    ),
    ( // RSA_WITH_AES_128_CBC_SHA256
    Name          : 'RSA_WITH_AES_128_CBC_SHA256';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscscAES_128_CBC;
    Hash          : tlscshSHA256;
    Rec           : (B1: $00; B2: $3C);
    ServerSupport : True;
    MinVersion    : (major: 3; minor: 3); // TLS 1.2
    ),
    ( // RSA_WITH_AES_256_CBC_SHA256
    Name          : 'RSA_WITH_AES_256_CBC_SHA256';
    KeyExchange   : tlscskeRSA;
    Cipher        : tlscscAES_256_CBC;
    Hash          : tlscshSHA256;
    Rec           : (B1: $00; B2: $3D);
    ServerSupport : True;
    MinVersion    : (major: 3; minor: 3); // TLS 1.2
    ),
    ( // DH_DSS_EXPORT_WITH_DES40_CBC_SHA
    Name          : 'DH_DSS_EXPORT_WITH_DES40_CBC_SHA';
    KeyExchange   : tlscskeDH_DSS_EXPORT;
    Cipher        : tlscscDES40_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $0B);
    ServerSupport : False;
    ),
    ( // DH_DSS_WITH_DES_CBC_SHA
    Name          : 'DH_DSS_WITH_DES_CBC_SHA';
    KeyExchange   : tlscskeDH_DSS;
    Cipher        : tlscscDES_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $0C);
    ServerSupport : False;
    ),
    ( // DH_DSS_WITH_3DES_EDE_CBC_SHA
    Name          : 'DH_DSS_WITH_3DES_EDE_CBC_SHA';
    KeyExchange   : tlscskeDH_DSS;
    Cipher        : tlscsc3DES_EDE_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $0D);
    ServerSupport : False;
    ),
    ( // DH_RSA_EXPORT_WITH_DES40_CBC_SHA
    Name          : 'DH_RSA_EXPORT_WITH_DES40_CBC_SHA';
    KeyExchange   : tlscskeDH_RSA_EXPORT;
    Cipher        : tlscscDES40_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $0E);
    ServerSupport : False;
    ),
    ( // DH_RSA_WITH_DES_CBC_SHA
    Name          : 'DH_RSA_WITH_DES_CBC_SHA';
    KeyExchange   : tlscskeDH_RSA;
    Cipher        : tlscscDES_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $0F);
    ServerSupport : False;
    ),
    ( // DH_RSA_WITH_3DES_EDE_CBC_SHA
    Name          : 'DH_RSA_WITH_3DES_EDE_CBC_SHA';
    KeyExchange   : tlscskeDH_RSA;
    Cipher        : tlscsc3DES_EDE_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $10);
    ServerSupport : False;
    ),
    ( // DHE_DSS_EXPORT_WITH_DES40_CBC_SHA
    Name          : 'DHE_DSS_EXPORT_WITH_DES40_CBC_SHA';
    KeyExchange   : tlscskeDHE_DSS_EXPORT;
    Cipher        : tlscscDES40_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $11);
    ServerSupport : False;
    ),
    ( // DHE_DSS_WITH_DES_CBC_SHA
    Name          : 'DHE_DSS_WITH_DES_CBC_SHA';
    KeyExchange   : tlscskeDHE_DSS;
    Cipher        : tlscscDES_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $12);
    ServerSupport : False;
    ),
    ( // DHE_DSS_WITH_3DES_EDE_CBC_SHA
    Name          : 'DHE_DSS_WITH_3DES_EDE_CBC_SHA';
    KeyExchange   : tlscskeDHE_DSS;
    Cipher        : tlscsc3DES_EDE_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $13);
    ServerSupport : False;
    ),
    ( // DHE_DSS_WITH_RC4_128_SHA
    Name          : 'DHE_DSS_WITH_RC4_128_SHA';
    KeyExchange   : tlscskeDHE_DSS;
    Cipher        : tlscscRC4_128;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $66);
    ServerSupport : False;
    ),
    ( // DHE_RSA_EXPORT_WITH_DES40_CBC_SHA
    Name          : 'DHE_RSA_EXPORT_WITH_DES40_CBC_SHA';
    KeyExchange   : tlscskeDHE_RSA_EXPORT;
    Cipher        : tlscscDES40_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $14);
    ServerSupport : False;
    ),
    ( // DHE_RSA_WITH_DES_CBC_SHA
    Name          : 'DHE_RSA_WITH_DES_CBC_SHA';
    KeyExchange   : tlscskeDHE_RSA;
    Cipher        : tlscscDES_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $15);
    ServerSupport : False;
    ),
    ( // DHE_RSA_WITH_3DES_EDE_CBC_SHA
    Name          : 'DHE_RSA_WITH_3DES_EDE_CBC_SHA';
    KeyExchange   : tlscskeDHE_RSA;
    Cipher        : tlscsc3DES_EDE_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $16);
    ServerSupport : False;
    ),
    ( // DH_anon_EXPORT_WITH_RC4_40_MD5
    Name          : 'DH_anon_EXPORT_WITH_RC4_40_MD5';
    KeyExchange   : tlscskeDH_anon_EXPORT;
    Cipher        : tlscscRC4_40;
    Hash          : tlscshMD5;
    Rec           : (B1: $00; B2: $17);
    ServerSupport : False;
    ),
    ( // DH_anon_WITH_RC4_128_MD5
    Name          : 'DH_anon_WITH_RC4_128_MD5';
    KeyExchange   : tlscskeDH_anon;
    Cipher        : tlscscRC4_128;
    Hash          : tlscshMD5;
    Rec           : (B1: $00; B2: $18);
    ServerSupport : False;
    ),
    ( // DH_anon_EXPORT_WITH_DES40_CBC_SHA
    Name          : 'DH_anon_EXPORT_WITH_DES40_CBC_SHA';
    KeyExchange   : tlscskeDH_anon_EXPORT;
    Cipher        : tlscscDES40_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $19);
    ServerSupport : False;
    ),
    ( // DH_anon_WITH_DES_CBC_SHA
    Name          : 'DH_anon_WITH_DES_CBC_SHA';
    KeyExchange   : tlscskeDH_anon;
    Cipher        : tlscscDES_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $1A);
    ServerSupport : False;
    ),
    ( // DH_anon_WITH_3DES_EDE_CBC_SHA
    Name          : 'DH_anon_WITH_3DES_EDE_CBC_SHA';
    KeyExchange   : tlscskeDH_anon;
    Cipher        : tlscsc3DES_EDE_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $1B);
    ServerSupport : False;
    ),
    ( // DH_DSS_WITH_AES_128_CBC_SHA
    Name          : 'DH_DSS_WITH_AES_128_CBC_SHA';
    KeyExchange   : tlscskeDH_DSS;
    Cipher        : tlscscAES_128_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $30);
    ServerSupport : False;
    ),
    ( // DH_DSS_WITH_AES_256_CBC_SHA
    Name          : 'DH_DSS_WITH_AES_256_CBC_SHA';
    KeyExchange   : tlscskeDH_DSS;
    Cipher        : tlscscAES_256_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $36);
    ServerSupport : False;
    ),
    ( // DH_DSS_WITH_AES_128_CBC_SHA256
    Name          : 'DH_DSS_WITH_AES_128_CBC_SHA256';
    KeyExchange   : tlscskeDH_DSS;
    Cipher        : tlscscAES_128_CBC;
    Hash          : tlscshSHA256;
    Rec           : (B1: $00; B2: $3E);
    ServerSupport : False;
    ),
    ( // DH_DSS_WITH_AES_256_CBC_SHA256
    Name          : 'DH_DSS_WITH_AES_256_CBC_SHA256';
    KeyExchange   : tlscskeDH_DSS;
    Cipher        : tlscscAES_256_CBC;
    Hash          : tlscshSHA256;
    Rec           : (B1: $00; B2: $68);
    ServerSupport : False;
    ),
    ( // DH_RSA_WITH_AES_128_CBC_SHA
    Name          : 'DH_RSA_WITH_AES_128_CBC_SHA';
    KeyExchange   : tlscskeDH_RSA;
    Cipher        : tlscscAES_128_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $31);
    ServerSupport : False;
    ),
    ( // DH_RSA_WITH_AES_256_CBC_SHA
    Name          : 'DH_RSA_WITH_AES_256_CBC_SHA';
    KeyExchange   : tlscskeDH_RSA;
    Cipher        : tlscscAES_256_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $37);
    ServerSupport : False;
    ),
    ( // DH_RSA_WITH_AES_128_CBC_SHA256
    Name          : 'DH_RSA_WITH_AES_128_CBC_SHA256';
    KeyExchange   : tlscskeDH_RSA;
    Cipher        : tlscscAES_128_CBC;
    Hash          : tlscshSHA256;
    Rec           : (B1: $00; B2: $3F);
    ServerSupport : False;
    ),
    ( // DH_RSA_WITH_AES_256_CBC_SHA256
    Name          : 'DH_RSA_WITH_AES_256_CBC_SHA256';
    KeyExchange   : tlscskeDH_RSA;
    Cipher        : tlscscAES_256_CBC;
    Hash          : tlscshSHA256;
    Rec           : (B1: $00; B2: $69);
    ServerSupport : False;
    ),
    ( // DHE_DSS_WITH_AES_128_CBC_SHA
    Name          : 'DHE_DSS_WITH_AES_128_CBC_SHA  ';
    KeyExchange   : tlscskeDHE_DSS;
    Cipher        : tlscscAES_128_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $32);
    ServerSupport : False;
    ),
    ( // DHE_DSS_WITH_AES_256_CBC_SHA
    Name          : 'DHE_DSS_WITH_AES_256_CBC_SHA';
    KeyExchange   : tlscskeDHE_DSS;
    Cipher        : tlscscAES_256_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $38);
    ServerSupport : False;
    ),
    ( // DHE_DSS_WITH_AES_128_CBC_SHA256
    Name          : 'DHE_DSS_WITH_AES_128_CBC_SHA256';
    KeyExchange   : tlscskeDHE_DSS;
    Cipher        : tlscscAES_128_CBC;
    Hash          : tlscshSHA256;
    Rec           : (B1: $00; B2: $40);
    ServerSupport : False;
    ),
    ( // DHE_DSS_WITH_AES_256_CBC_SHA256
    Name          : 'DHE_DSS_WITH_AES_256_CBC_SHA256';
    KeyExchange   : tlscskeDHE_DSS;
    Cipher        : tlscscAES_256_CBC;
    Hash          : tlscshSHA256;
    Rec           : (B1: $00; B2: $6A);
    ServerSupport : False;
    ),
    ( // DHE_RSA_WITH_AES_128_CBC_SHA
    Name          : 'DHE_RSA_WITH_AES_128_CBC_SHA';
    KeyExchange   : tlscskeDHE_RSA;
    Cipher        : tlscscAES_128_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $33);
    ServerSupport : False;
    ),
    ( // DHE_RSA_WITH_AES_256_CBC_SHA
    Name          : 'DHE_RSA_WITH_AES_256_CBC_SHA';
    KeyExchange   : tlscskeDHE_RSA;
    Cipher        : tlscscAES_256_CBC;
    Hash          : tlscshSHA;
    Rec           : (B1: $00; B2: $39);
    ServerSupport : False;
    ),
    ( // DHE_RSA_WITH_AES_128_CBC_SHA256
    Name          : 'DHE_RSA_WITH_AES_128_CBC_SHA256';
    KeyExchange   : tlscskeDHE_RSA;
    Cipher        : tlscscAES_128_CBC;
    Hash          : tlscshSHA256;
    Rec           : (B1: $00; B2: $67);
    ServerSupport : False;
    ),
    ( // DHE_RSA_WITH_AES_256_CBC_SHA256
    Name          : 'DHE_RSA_WITH_AES_256_CBC_SHA256';
    KeyExchange   : tlscskeDHE_RSA;
    Cipher        : tlscscAES_256_CBC;
    Hash          : tlscshSHA256;
    Rec           : (B1: $00; B2: $6B);
    ServerSupport : False;
    )
    );

function GetCipherSuiteByRec(const B1, B2: Byte): TTLSCipherSuite;
function GetCipherSuiteByName(const Name: AnsiString): TTLSCipherSuite;

type
  TTLSCipherSuiteKeyExchangeInfo = record
    Name        : AnsiString;
    KeyExchange : TTLSKeyExchangeAlgorithm;
    Exportable  : Boolean;
    Supported   : Boolean; // Not used
  end;
  PTLSCipherSuiteKeyExchangeInfo = ^TTLSCipherSuiteKeyExchangeInfo;

const
  TLSCipherSuiteKeyExchangeInfo : array[TTLSCipherSuiteKeyExchange] of TTLSCipherSuiteKeyExchangeInfo = (
    ( // None
      Name        : '';
      KeyExchange : tlskeaNone;
      Exportable  : True;
      Supported   : False;
    ),
    ( // NULL
      Name        : 'NULL';
      KeyExchange : tlskeaNULL;
      Exportable  : True;
      Supported   : False;
    ),
    ( // RSA
      Name        : 'RSA';
      KeyExchange : tlskeaRSA;
      Exportable  : False;
      Supported   : True;
    ),
    ( // RSA_EXPORT
      Name        : 'RSA_EXPORT';
      KeyExchange : tlskeaRSA;
      Exportable  : True;
      Supported   : False;
    ),
    ( // RSA_EXPORT1024
      Name        : 'RSA_EXPORT1024';
      KeyExchange : tlskeaRSA;
      Exportable  : True;
      Supported   : False;
    ),
    ( // DH_DSS_EXPORT
      Name        : 'DH_DSS_EXPORT';
      KeyExchange : tlskeaDH_DSS;
      Exportable  : True;
      Supported   : False;
    ),
    ( // DH_DSS
      Name        : 'DH_DSS';
      KeyExchange : tlskeaDH_DSS;
      Exportable  : False;
      Supported   : False;
    ),
    ( // DH_RSA_EXPORT
      Name        : 'DH_RSA_EXPORT';
      KeyExchange : tlskeaDH_RSA;
      Exportable  : True;
      Supported   : False;
    ),
    ( // DH_RSA
      Name        : 'DH_RSA';
      KeyExchange : tlskeaDH_RSA;
      Exportable  : False;
      Supported   : False;
    ),
    ( // DHE_DSS_EXPORT
      Name        : 'DHE_DSS_EXPORT';
      KeyExchange : tlskeaDHE_DSS;
      Exportable  : True;
      Supported   : False;
    ),
    (  // DHE_DSS
      Name        : 'DHE_DSS';
      KeyExchange : tlskeaDHE_DSS;
      Exportable  : False;
      Supported   : False;
    ),
    ( // DHE_RSA_EXPORT
      Name        : 'DHE_RSA_EXPORT';
      KeyExchange : tlskeaDHE_RSA;
      Exportable  : True;
      Supported   : False;
    ),
    ( // DHE_RSA
      Name        : 'DHE_RSA';
      KeyExchange : tlskeaDHE_RSA;
      Exportable  : False;
      Supported   : False;
    ),
    ( // DH_anon_EXPORT
      Name        : 'DH_anon_EXPORT';
      KeyExchange : tlskeaDH_Anon;
      Exportable  : True;
      Supported   : False;
    ),
    ( // DH_anon
      Name        : 'DH_anon';
      KeyExchange : tlskeaDH_Anon;
      Exportable  : False;
      Supported   : False;
    ));



{                                                                              }
{ Cipher Suite Cipher                                                          }
{                                                                              }
type
  TTLSCipherSuiteCipherType = (
    tlscsctNone,
    tlscsctNULL,
    tlscsctStream,
    tlscsctBlock);

  TTLSCipherSuiteBulkCipher = (
    tlscsbcNone,
    tlscsbcNULL,
    tlscsbcRC4,
    tlscsbcRC2,
    tlscsbcDES,
    tlscsbc3DES,
    tlscsbcIDEA,
    tlscsbcDES40,
    tlscsbcAES
  );

  TTLSCipherSuiteCipherInfo = record
    Name        : AnsiString;
    CipherType  : TTLSCipherSuiteCipherType;
    BulkCipher  : TTLSCipherSuiteBulkCipher;
    KeyBits     : Integer;
    KeyMaterial : Integer;
    ExpKeyMat   : Integer; // expanded key material
    IVSize      : Integer;
    BlockSize   : Integer;
    Exportable  : Boolean;
    Supported   : Boolean; // Not used
  end;
  PTLSCipherSuiteCipherInfo = ^TTLSCipherSuiteCipherInfo;

const
  TLSCipherSuiteCipherInfo : array[TTLSCipherSuiteCipher] of TTLSCipherSuiteCipherInfo = (
    ( // None
    Name        : '';
    CipherType  : tlscsctNone;
    BulkCipher  : tlscsbcNone;
    KeyBits     : 0;
    KeyMaterial : 0;
    ExpKeyMat   : 0;
    IVSize      : 0;
    BlockSize   : 0;
    Exportable  : True;
    Supported   : False;
    ),
    ( // NULL
    Name        : 'NULL';
    CipherType  : tlscsctNULL;
    BulkCipher  : tlscsbcNULL;
    KeyBits     : 0;
    KeyMaterial : 0;
    ExpKeyMat   : 0;
    IVSize      : 0;
    BlockSize   : 0;
    Exportable  : True;
    Supported   : True;
    ),
    ( // RC4_40
    Name        : 'RC4_40';
    CipherType  : tlscsctStream;
    BulkCipher  : tlscsbcRC4;
    KeyBits     : 40;
    KeyMaterial : 5;
    ExpKeyMat   : 16;
    IVSize      : 0;
    BlockSize   : 0;
    Exportable  : True;
    Supported   : True;
    ),
    ( // RC4_56
    Name        : 'RC4_56';
    CipherType  : tlscsctStream;
    BulkCipher  : tlscsbcRC4;
    KeyBits     : 56;
    KeyMaterial : 7;
    ExpKeyMat   : 16;
    IVSize      : 0;
    BlockSize   : 0;
    Exportable  : True;
    Supported   : False;
    ),
    ( // RC4_128
    Name        : 'RC4_128';
    CipherType  : tlscsctStream;
    BulkCipher  : tlscsbcRC4;
    KeyBits     : 128;
    KeyMaterial : 16;
    ExpKeyMat   : 16;
    IVSize      : 0;
    BlockSize   : 0;
    Exportable  : False;
    Supported   : False;
    ),
    ( // RC2_CBC_40
    Name        : 'RC2_CBC_40';
    CipherType  : tlscsctBlock;
    BulkCipher  : tlscsbcRC2;
    KeyBits     : 40;
    KeyMaterial : 5;
    ExpKeyMat   : 16;
    IVSize      : 8;
    BlockSize   : 8;
    Exportable  : True;
    Supported   : False;
    ),
    ( // IDEA_CBC
    Name        : 'IDEA_CBC';
    CipherType  : tlscsctBlock;
    BulkCipher  : tlscsbcIDEA;
    KeyBits     : 128;
    KeyMaterial : 16;
    ExpKeyMat   : 16;
    IVSize      : 8;
    BlockSize   : 8;
    Exportable  : False;
    Supported   : False;
    ),
    ( // DES40_CBC
    Name        : 'DES40_CBC';
    CipherType  : tlscsctBlock;
    BulkCipher  : tlscsbcDES40;
    KeyBits     : 40;
    KeyMaterial : 5;
    ExpKeyMat   : 8;
    IVSize      : 8;
    BlockSize   : 8;
    Exportable  : True;
    Supported   : False;
    ),
    ( // DES_CBC
    Name        : 'DES_CBC';
    CipherType  : tlscsctBlock;
    BulkCipher  : tlscsbcDES;
    KeyBits     : 64;
    KeyMaterial : 8;
    ExpKeyMat   : 8;
    IVSize      : 8;
    BlockSize   : 8;
    Exportable  : False;
    Supported   : False;
    ),
    ( // 3DES_EDE_CBC
    Name        : '3DES_EDE_CBC';
    CipherType  : tlscsctBlock;
    BulkCipher  : tlscsbc3DES;
    KeyBits     : 128;
    KeyMaterial : 24;
    ExpKeyMat   : 24;
    IVSize      : 8;
    BlockSize   : 8;
    Exportable  : False;
    Supported   : False;
    ),
    ( // AES_128_CBC
    Name        : 'AES_128_CBC';
    CipherType  : tlscsctBlock;
    BulkCipher  : tlscsbcAES;
    KeyBits     : 128;
    KeyMaterial : 16;
    ExpKeyMat   : 16;
    IVSize      : 16;
    BlockSize   : 16;
    Exportable  : False;
    Supported   : False;
    ),
    ( // AES_256_CBC
    Name        : 'AES_256_CBC';
    CipherType  : tlscsctBlock;
    BulkCipher  : tlscsbcAES;
    KeyBits     : 256;
    KeyMaterial : 32;
    ExpKeyMat   : 32;
    IVSize      : 16;
    BlockSize   : 16;
    Exportable  : False;
    Supported   : False;
    )
    );

  TLS_CIPHERSUITE_MaxBlockSize = 16;
  TLS_CIPHERSUITE_MaxIVSize    = 16;



{                                                                              }
{ Cipher Suite Hash                                                            }
{                                                                              }
type
  TTLSCipherSuiteHashInfo = record
    Name         : AnsiString;
    HashSize     : Integer;
    KeyLength    : Integer;
    MACAlgorithm : TTLSMACAlgorithm;
    Supported    : Boolean; // Not used
  end;
  PTLSCipherSuiteHashInfo = ^TTLSCipherSuiteHashInfo;

const
  TLSCipherSuiteHashInfo : array[TTLSCipherSuiteHash] of TTLSCipherSuiteHashInfo = (
    ( // None
    Name         : '';
    HashSize     : 0;
    KeyLength    : 0;
    MACAlgorithm : tlsmaNone;
    Supported    : False;
    ),
    ( // NULL
    Name         : 'NULL';
    HashSize     : 0;
    KeyLength    : 0;
    MACAlgorithm : tlsmaNULL;
    Supported    : True;
    ),
    ( // SHA
    Name         : 'SHA';
    HashSize     : 160;
    KeyLength    : 160;
    MACAlgorithm : tlsmaHMAC_SHA1;
    Supported    : True;
    ),
    ( // SHA256
    Name         : 'SHA256';
    HashSize     : 256;
    KeyLength    : 256;
    MACAlgorithm : tlsmaHMAC_SHA256;
    Supported    : True;
    ),
    ( // MD5
    Name         : 'MD5';
    HashSize     : 128;
    KeyLength    : 128;
    MACAlgorithm : tlsmaHMAC_MD5;
    Supported    : True;
    )
    );



{                                                                              }
{ Cipher Suite Details                                                         }
{                                                                              }
type
  TTLSCipherSuiteDetails = record
    CipherSuite     : TTLSCipherSuite;
    CipherSuiteInfo : PTLSCipherSuiteInfo;
    CipherInfo      : PTLSCipherSuiteCipherInfo;
    HashInfo        : PTLSCipherSuiteHashInfo;
    KeyExchangeInfo : PTLSCipherSuiteKeyExchangeInfo;
  end;

procedure InitTLSCipherSuiteDetails(var A: TTLSCipherSuiteDetails; const CipherSuite: TTLSCipherSuite);
procedure InitTLSCipherSuiteDetailsNULL(var A: TTLSCipherSuiteDetails);



implementation



{                                                                              }
{ Cipher Suite                                                                 }
{                                                                              }
function GetCipherSuiteByRec(const B1, B2: Byte): TTLSCipherSuite;
var C : TTLSCipherSuite;
    D : PTLSCipherSuiteInfo;
begin
  for C := Low(TTLSCipherSuite) to High(TTLSCipherSuite) do
    begin
      D := @TLSCipherSuiteInfo[C];
      if (D^.Rec.B1 = B1) and (D^.Rec.B2 = B2) then
        begin
          Result := C;
          exit;
        end;
    end;
  Result := tlscsNone;
end;

function GetCipherSuiteByName(const Name: AnsiString): TTLSCipherSuite;
var C : TTLSCipherSuite;
    D : PTLSCipherSuiteInfo;
begin
  for C := Low(TTLSCipherSuite) to High(TTLSCipherSuite) do
    begin
      D := @TLSCipherSuiteInfo[C];
      if D^.Name = Name then
        begin
          Result := C;
          exit;
        end;
    end;
  Result := tlscsNone;
end;



{                                                                              }
{ Cipher Suite Details                                                         }
{                                                                              }
procedure InitTLSCipherSuiteDetails(var A: TTLSCipherSuiteDetails; const CipherSuite: TTLSCipherSuite);
var C : PTLSCipherSuiteInfo;
begin
  C := @TLSCipherSuiteInfo[CipherSuite];
  A.CipherSuite     := CipherSuite;
  A.CipherSuiteInfo := C;
  A.CipherInfo      := @TLSCipherSuiteCipherInfo[C^.Cipher];
  A.HashInfo        := @TLSCipherSuiteHashInfo[C^.Hash];
  A.KeyExchangeInfo := @TLSCipherSuiteKeyExchangeInfo[C^.KeyExchange];
end;

procedure InitTLSCipherSuiteDetailsNULL(var A: TTLSCipherSuiteDetails);
begin
  InitTLSCipherSuiteDetails(A, tlscsNULL_WITH_NULL_NULL);
end;



end.

