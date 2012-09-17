{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals TLS                                         }
{   File name:        cTLSCompress.pas                                         }
{   File version:     0.02                                                     }
{   Description:      TLS compression                                          }
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
{                                                                              }
{******************************************************************************}

{$INCLUDE cTLS.inc}

{$IFDEF DELPHI}
{$DEFINE TLS_COMPRESS_ZLIB}
{$ELSE}
{$UNDEF TLS_COMPRESS_ZLIB}
{$ENDIF}

unit cTLSCompress;

interface

uses
  { TLS }
  cTLSUtils;



{                                                                              }
{ Fragment compression                                                         }
{                                                                              }
procedure TLSCompressFragment(
          const CompressionMethod: TTLSCompressionMethod;
          const PlainTextBuf; const PlainTextSize: Integer;
          var CompressedBuf; const CompressedBufSize: Integer;
          var CompressedSize: Integer);

procedure TLSDecompressFragment(
          const CompressionMethod: TTLSCompressionMethod;
          const CompressedBuf; const CompressedSize: Integer;
          var PlainTextBuf; const PlainTextBufSize: Integer;
          var PlainTextSize: Integer);



implementation

{$IFDEF TLS_COMPRESS_ZLIB}
uses
  { Fundamentals }
  cCompressZLIB;
{$ENDIF}



{                                                                              }
{ Fragment compression                                                         }
{                                                                              }
procedure TLSCompressFragment(
          const CompressionMethod: TTLSCompressionMethod;
          const PlainTextBuf; const PlainTextSize: Integer;
          var CompressedBuf; const CompressedBufSize: Integer;
          var CompressedSize: Integer);
{$IFDEF TLS_COMPRESS_ZLIB}
var OutBuf : Pointer;
    OutSize : Integer;
{$ENDIF}
begin
  if (PlainTextSize <= 0) or
     (PlainTextSize > TLS_PLAINTEXT_FRAGMENT_MAXSIZE) then
    raise ETLSError.Create(TLSError_InvalidBuffer);
  case CompressionMethod of
    tlscmNull :
      begin
        if CompressedBufSize < PlainTextSize then
          raise ETLSError.Create(TLSError_InvalidBuffer);
        Move(PlainTextBuf, CompressedBuf, PlainTextSize);
        CompressedSize := PlainTextSize;
      end;
    {$IFDEF TLS_COMPRESS_ZLIB}
    tlscmDeflate :
      begin
        ZLibCompressBuf(@PlainTextBuf, PlainTextSize, OutBuf, OutSize, zclDefault);
        if CompressedBufSize < OutSize then
          raise ETLSError.Create(TLSError_InvalidBuffer);
        if OutSize > TLS_COMPRESSED_FRAGMENT_MAXSIZE then
          raise ETLSError.Create(TLSError_InvalidBuffer); // compressed fragment larger than maximum allowed size
        Move(OutBuf^, CompressedBuf, OutSize);
        FreeMem(OutBuf);
        CompressedSize := OutSize;
      end;
    {$ENDIF}
  else
    raise ETLSError.Create(TLSError_InvalidParameter, 'Invalid compression method');
  end;
end;

procedure TLSDecompressFragment(
          const CompressionMethod: TTLSCompressionMethod;
          const CompressedBuf; const CompressedSize: Integer;
          var PlainTextBuf; const PlainTextBufSize: Integer;
          var PlainTextSize: Integer);
{$IFDEF TLS_COMPRESS_ZLIB}
var OutBuf : Pointer;
    OutSize : Integer;
{$ENDIF}
begin
  if (CompressedSize < 0) or
     (CompressedSize > TLS_COMPRESSED_FRAGMENT_MAXSIZE) then
    raise ETLSError.Create(TLSError_InvalidBuffer);
  case CompressionMethod of
    tlscmNull :
      begin
        if PlainTextBufSize < CompressedSize then
          raise ETLSError.Create(TLSError_InvalidBuffer);
        Move(CompressedBuf, PlainTextBuf, CompressedSize);
        PlainTextSize := CompressedSize;
      end;
    {$IFDEF TLS_COMPRESS_ZLIB}
    tlscmDeflate :
      begin
        ZLibDecompressBuf(@CompressedBuf, CompressedSize, OutBuf, OutSize);
        if PlainTextBufSize < OutSize then
          raise ETLSError.Create(TLSError_InvalidBuffer);
        if OutSize > TLS_PLAINTEXT_FRAGMENT_MAXSIZE then
          raise ETLSError.Create(TLSError_InvalidBuffer); // uncompressed fragment larger than maximum allowed size
        Move(OutBuf^, PlainTextBuf, OutSize);
        FreeMem(OutBuf);
        PlainTextSize := OutSize;
      end;
    {$ENDIF}
  else
    raise ETLSError.Create(TLSError_InvalidParameter, 'Invalid compression method');
  end;
end;



end.

