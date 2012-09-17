{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals TLS                                         }
{   File name:        cTLS.pas                                                 }
{   File version:     0.03                                                     }
{   Description:      TLS library                                              }
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
{   2010/12/15  0.02  Client/Server test case.                                 ]
{   2010/12/17  0.03  Client/Server test cases for TLS 1.0, 1.1 and 1.2.       }
{                                                                              }
{ References:                                                                  }
{                                                                              }
{   SSL 3 - www.mozilla.org/projects/security/pki/nss/ssl/draft302.txt         }
{   RFC 2246 - The TLS Protocol Version 1.0                                    }
{   RFC 4346 - The TLS Protocol Version 1.1                                    }
{   RFC 5246 - The TLS Protocol Version 1.2                                    }
{   RFC 4366 - Transport Layer Security (TLS) Extensions                       }
{   www.mozilla.org/projects/security/pki/nss/ssl/traces/trc-clnt-ex.html      }
{                                                                              }
{ Todo:                                                                        }
{ - Test compression.                                                          }
{******************************************************************************}

{$INCLUDE cTLS.inc}

unit cTLS;

interface



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF TLS_SELFTEST}
procedure SelfTest;
{$ENDIF}



implementation

uses
  SysUtils,
  cUtils,
  cX509Certificate,
  { TLS }
  cTLSUtils,
  cTLSRecord,
  cTLSAlert,
  cTLSHandshake,
  cTLSCipher,
  cTLSConnection,
  cTLSClient,
  cTLSServer;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF TLS_SELFTEST}
type
  TTLSClientServerTester = class
    Sr : TTLSServer;
    Cl : TTLSClient;
    SCl : TTLSServerClient;
    constructor Create;
    destructor Destroy; override;
    procedure ServerTLSendProc(Server: TTLSServer; Client: TTLSServerClient; const Buffer; const Size: Integer);
    procedure ClientTLSendProc(const Sender: TTLSConnection; const Buffer; const Size: Integer);
  end;

constructor TTLSClientServerTester.Create;
begin
  inherited Create;
  Sr := TTLSServer.Create(ServerTLSendProc);
  Cl := TTLSClient.Create(ClientTLSendProc);
end;

destructor TTLSClientServerTester.Destroy;
begin
  FreeAndNil(Cl);
  FreeAndNil(Sr);
  inherited Destroy;
end;

procedure TTLSClientServerTester.ServerTLSendProc(Server: TTLSServer; Client: TTLSServerClient; const Buffer; const Size: Integer);
begin
  Assert(Assigned(Cl));
  Cl.ProcessTransportLayerReceivedData(Buffer, Size);
end;

procedure TTLSClientServerTester.ClientTLSendProc(const Sender: TTLSConnection; const Buffer; const Size: Integer);
begin
  Assert(Assigned(SCl));
  SCl.ProcessTransportLayerReceivedData(Buffer, Size);
end;

procedure SelfTestClientServer(const ClientOptions: TTLSClientOptions);
const
  LargeBlockSize = TLS_PLAINTEXT_FRAGMENT_MAXSIZE * 8;
var CS : TTLSClientServerTester;
    CtL : TTLSCertificateList;
    S : AnsiString;
    I, L : Integer;
begin
  CS := TTLSClientServerTester.Create;
  try
    // initialise client
    CS.Cl.ClientOptions := ClientOptions;
    // initialise server
    CS.Sr.PrivateKeyRSAPEM := // from stunnel pem file
      'MIICXAIBAAKBgQCxUFMuqJJbI9KnB8VtwSbcvwNOltWBtWyaSmp7yEnqwWel5TFf' +
      'cOObCuLZ69sFi1ELi5C91qRaDMow7k5Gj05DZtLDFfICD0W1S+n2Kql2o8f2RSvZ' +
      'qD2W9l8i59XbCz1oS4l9S09L+3RTZV9oer/Unby/QmicFLNM0WgrVNiKywIDAQAB' +
      'AoGAKX4KeRipZvpzCPMgmBZi6bUpKPLS849o4pIXaO/tnCm1/3QqoZLhMB7UBvrS' +
      'PfHj/Tejn0jjHM9xYRHi71AJmAgzI+gcN1XQpHiW6kATNDz1r3yftpjwvLhuOcp9' +
      'tAOblojtImV8KrAlVH/21rTYQI+Q0m9qnWKKCoUsX9Yu8UECQQDlbHL38rqBvIMk' +
      'zK2wWJAbRvVf4Fs47qUSef9pOo+p7jrrtaTqd99irNbVRe8EWKbSnAod/B04d+cQ' +
      'ci8W+nVtAkEAxdqPOnCISW4MeS+qHSVtaGv2kwvfxqfsQw+zkwwHYqa+ueg4wHtG' +
      '/9+UgxcXyCXrj0ciYCqURkYhQoPbWP82FwJAWWkjgTgqsYcLQRs3kaNiPg8wb7Yb' +
      'NxviX0oGXTdCaAJ9GgGHjQ08lNMxQprnpLT8BtZjJv5rUOeBuKoXagggHQJAaUAF' +
      '91GLvnwzWHg5p32UgPsF1V14siX8MgR1Q6EfgKQxS5Y0Mnih4VXfnAi51vgNIk/2' +
      'AnBEJkoCQW8BTYueCwJBALvz2JkaUfCJc18E7jCP7qLY4+6qqsq+wr0t18+ogOM9' +
      'JIY9r6e1qwNxQ/j1Mud6gn6cRrObpRtEad5z2FtcnwY=';
    TLSCertificateListAppend(CtL,
      MIMEBase64Decode( // from stunnel pem file
        'MIICDzCCAXigAwIBAgIBADANBgkqhkiG9w0BAQQFADBCMQswCQYDVQQGEwJQTDEf' +
        'MB0GA1UEChMWU3R1bm5lbCBEZXZlbG9wZXJzIEx0ZDESMBAGA1UEAxMJbG9jYWxo' +
        'b3N0MB4XDTk5MDQwODE1MDkwOFoXDTAwMDQwNzE1MDkwOFowQjELMAkGA1UEBhMC' +
        'UEwxHzAdBgNVBAoTFlN0dW5uZWwgRGV2ZWxvcGVycyBMdGQxEjAQBgNVBAMTCWxv' +
        'Y2FsaG9zdDCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAsVBTLqiSWyPSpwfF' +
        'bcEm3L8DTpbVgbVsmkpqe8hJ6sFnpeUxX3Djmwri2evbBYtRC4uQvdakWgzKMO5O' +
        'Ro9OQ2bSwxXyAg9FtUvp9iqpdqPH9kUr2ag9lvZfIufV2ws9aEuJfUtPS/t0U2Vf' +
        'aHq/1J28v0JonBSzTNFoK1TYissCAwEAAaMVMBMwEQYJYIZIAYb4QgEBBAQDAgZA' +
        'MA0GCSqGSIb3DQEBBAUAA4GBAAhYFTngWc3tuMjVFhS4HbfFF/vlOgTu44/rv2F+' +
        'ya1mEB93htfNxx3ofRxcjCdorqONZFwEba6xZ8/UujYfVmIGCBy4X8+aXd83TJ9A' +
        'eSjTzV9UayOoGtmg8Dv2aj/5iabNeK1Qf35ouvlcTezVZt2ZeJRhqUHcGaE+apCN' +
        'TC9Y'));
    CS.Sr.CertificateList := CtL;
    // start server
    CS.Sr.Start;
    Assert(CS.Sr.State = tlssActive);
    // start connection
    CS.SCl := CS.Sr.AddClient(nil);
    CS.SCl.Start;
    CS.Cl.Start;
    // negotiated
    Assert(CS.Cl.IsReadyState);
    Assert(CS.SCl.IsReadyState);
    // application data (small block)
    S := 'Fundamentals';
    CS.Cl.Write(S[1], Length(S));
    Assert(CS.SCl.AvailableToRead = 12);
    S := '1234567890';
    Assert(CS.SCl.Read(S[1], 3) = 3);
    Assert(CS.SCl.AvailableToRead = 9);
    Assert(S = 'Fun4567890');
    Assert(CS.SCl.Read(S[1], 9) = 9);
    Assert(CS.SCl.AvailableToRead = 0);
    Assert(S = 'damentals0');
    S := 'Fundamentals';
    CS.SCl.Write(S[1], Length(S));
    Assert(CS.Cl.AvailableToRead = 12);
    S := '123456789012';
    Assert(CS.Cl.Read(S[1], 12) = 12);
    Assert(CS.Cl.AvailableToRead = 0);
    Assert(S = 'Fundamentals');
    // application data (large blocks)
    for L := LargeBlockSize - 1 to LargeBlockSize + 1 do
      begin
        SetLength(S, L);
        FillChar(S[1], L, #1);
        CS.Cl.Write(S[1], L);
        Assert(CS.SCl.AvailableToRead = L);
        FillChar(S[1], L, #0);
        CS.SCl.Read(S[1], L);
        for I := 1 to L do
          Assert(S[I] = #1);
        Assert(CS.SCl.AvailableToRead = 0);
        CS.SCl.Write(S[1], L);
        Assert(CS.Cl.AvailableToRead = L);
        FillChar(S[1], L, #0);
        Assert(CS.Cl.Read(S[1], L) = L);
        for I := 1 to L do
          Assert(S[I] = #1);
        Assert(CS.Cl.AvailableToRead = 0);
      end;
    // close
    CS.Cl.Close;
    Assert(CS.Cl.IsFinishedState);
    Assert(CS.SCl.IsFinishedState);
    // stop
    CS.Sr.RemoveClient(CS.SCl);
    CS.Sr.Stop;
  finally
    FreeAndNil(CS);
  end;
end;

procedure SelfTest;
begin
  cTLSUtils.SelfTest;
  cTLSRecord.SelfTest;
  cTLSHandshake.SelfTest;
  cTLSCipher.SelfTest;
  SelfTestClientServer([tlscoDontUseSSL3, tlscoDontUseTLS10, tlscoDontUseTLS11]); // TLS 1.2
  SelfTestClientServer([tlscoDontUseSSL3, tlscoDontUseTLS10, tlscoDontUseTLS12]); // TLS 1.1
  SelfTestClientServer([tlscoDontUseSSL3, tlscoDontUseTLS11, tlscoDontUseTLS12]); // TLS 1.0
  // SelfTestClientServer([tlscoDontUseTLS10, tlscoDontUseTLS11, tlscoDontUseTLS12]); SSL3
end;
{$ENDIF}



end.

