{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals TLS                                         }
{   File name:        cTLSAlert.pas                                            }
{   File version:     0.02                                                     }
{   Description:      TLS alert protocol                                       }
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
{   2010/11/30  0.02  Additional alerts from RFC 4366.                         }
{                                                                              }
{******************************************************************************}

{$INCLUDE cTLS.inc}

unit cTLSAlert;

interface



{                                                                              }
{ Alert Protocol                                                               }
{                                                                              }
type
  TTLSAlertLevel = (
    tlsalWarning        = 1,
    tlsalFatal          = 2,
    tlsalAlertLevelMax  = 255
  );

  TTLSAlertDescription = (
    tlsadClose_notify                    = 0,     // SSL 3
    tlsadUnexpected_message              = 10,    // SSL 3
    tlsadBad_record_mac                  = 20,    // SLL 3
    tlsadDecryption_failed               = 21,    // TLS 1.0
    tlsadRecord_overflow                 = 22,    // TLS 1.0
    tlsadDecompression_failure           = 30,    // SLL 3
    tlsadHandshake_failure               = 40,    // SLL 3
    tlsadNo_certificate                  = 41,    // SLL 3 / TLS 1.1 reserved
    tlsadBad_certificate                 = 42,    // SLL 3
    tlsadUnsupported_certificate         = 43,    // SLL 3
    tlsadCertificate_revoked             = 44,    // SLL 3
    tlsadCertificate_expired             = 45,    // SLL 3
    tlsadCertificate_unknown             = 46,    // SLL 3
    tlsadIllegal_parameter               = 47,    // SLL 3
    tlsadUnknown_ca                      = 48,    // TLS 1.0
    tlsadAccess_denied                   = 49,    // TLS 1.0
    tlsadDecode_error                    = 50,    // TLS 1.0
    tlsadDecrypt_error                   = 51,    // TLS 1.0
    tlsadExport_restriction              = 60,    // TLS 1.0 / TLS 1.1 reserved
    tlsadProtocol_version                = 70,    // TLS 1.0
    tlsadInsufficient_security           = 71,    // TLS 1.0
    tlsadInternal_error                  = 80,    // TLS 1.0
    tlsadUser_canceled                   = 90,    // TLS 1.0
    tlsadNo_renegotiation                = 100,   // TLS 1.0
    tlsadUnsupported_extention           = 110,   // TLS 1.2
    tlsadCertificate_unobtainable        = 111,   // RFC 4366
    tlsadUnrecognized_name               = 112,   // RFC 4366
    tlsadBad_certificate_status_response = 113,   // RFC 4366
    tlsadBad_certificate_hash_value      = 114,   // RFC 4366
    tlsadMax                             = 255
  );

function  TLSAlertLevelToStr(const Level: TTLSAlertLevel): String;
function  TLSAlertDescriptionToStr(const Description: TTLSAlertDescription): String;

type
  TTLSAlert = packed record
    level       : TTLSAlertLevel;
    description : TTLSAlertDescription;
  end;
  PTLSAlert = ^TTLSAlert;

const
  TLSAlertSize = Sizeof(TTLSAlert);

procedure InitTLSAlert(var Alert: TTLSAlert;
          const Level: TTLSAlertLevel; const Description: TTLSAlertDescription);



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF TLS_SELFTEST}
procedure SelfTest;
{$ENDIF}



implementation

uses
  { System }
  SysUtils;



{                                                                              }
{ Alert Protocol                                                               }
{                                                                              }
function TLSAlertLevelToStr(const Level: TTLSAlertLevel): String;
begin
  case Level of
    tlsalWarning : Result := 'Warning';
    tlsalFatal   : Result := 'Fatal';
  else
    Result := '[Level#' + IntToStr(Ord(Level)) + ']';
  end;
end;

function TLSAlertDescriptionToStr(const Description: TTLSAlertDescription): String;
begin
  case Description of
    tlsadClose_notify                    : Result := 'Close notify';
    tlsadUnexpected_message              : Result := 'Unexpected message';
    tlsadBad_record_mac                  : Result := 'Bad record MAC';
    tlsadDecryption_failed               : Result := 'Decryption failed';
    tlsadRecord_overflow                 : Result := 'Record overflow';
    tlsadDecompression_failure           : Result := 'Decompression failure';
    tlsadHandshake_failure               : Result := 'Handshake failure';
    tlsadNo_certificate                  : Result := 'No certificate';
    tlsadBad_certificate                 : Result := 'Bad certificate';
    tlsadUnsupported_certificate         : Result := 'Unsupported certificate';
    tlsadCertificate_revoked             : Result := 'Certificate revoked';
    tlsadCertificate_expired             : Result := 'Certificate expired';
    tlsadCertificate_unknown             : Result := 'Certficiate unknown';
    tlsadIllegal_parameter               : Result := 'Illegal parameter';
    tlsadUnknown_ca                      : Result := 'Unknown CA';
    tlsadAccess_denied                   : Result := 'Access denied';
    tlsadDecode_error                    : Result := 'Decode error';
    tlsadDecrypt_error                   : Result := 'Decrypt error';
    tlsadExport_restriction              : Result := 'Export restriction';
    tlsadProtocol_version                : Result := 'Protocol version';
    tlsadInsufficient_security           : Result := 'Insufficient security';
    tlsadInternal_error                  : Result := 'Internal error';
    tlsadUser_canceled                   : Result := 'User cancelled';
    tlsadNo_renegotiation                : Result := 'No renegotiation';
    tlsadUnsupported_extention           : Result := 'Unsuported extention';
    tlsadCertificate_unobtainable        : Result := 'Certificate unobtainable';
    tlsadUnrecognized_name               : Result := 'Unrecognised name';
    tlsadBad_certificate_status_response : Result := 'Bad certificate status response';
    tlsadBad_certificate_hash_value      : Result := 'Bad certificate hash value';
  else
    Result := '[Alert#' + IntToStr(Ord(Description)) + ']';
  end;
end;

procedure InitTLSAlert(
          var Alert: TTLSAlert;
          const Level: TTLSAlertLevel;
          const Description: TTLSAlertDescription);
begin
  Alert.level := Level;
  Alert.description := Description;
end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF TLS_SELFTEST}
{$ASSERTIONS ON}
procedure SelfTest;
begin
  Assert(TLSAlertSize = 2);
end;
{$ENDIF}



end.

