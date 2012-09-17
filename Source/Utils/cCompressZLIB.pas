{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cCompressZLIB.pas                                        }
{   File version:     0.01                                                     }
{   Description:      ZLIB compression                                         }
{                                                                              }
{   Copyright:        Copyright © 2008-2010, David J Butler                    }
{                     All rights reserved.                                     }
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
{   E-mail:           fundamentalslib at gmail.com                             }
{                                                                              }
{                                                                              }
{   ZLIB copyright information:                                                }
{                                                                              }
{   Copyright (C) 1995-1998 Jean-loup Gailly and Mark Adler                    }
{                                                                              }
{   Permission is granted to anyone to use this software for any purpose,      }
{   including commercial applications, and to alter it and redistribute it     }
{   freely, subject to the following restrictions:                             }
{                                                                              }
{   1. The origin of this software must not be misrepresented; you must not    }
{      claim that you wrote the original software. If you use this software    }
{      in a product, an acknowledgment in the product documentation would be   }
{      appreciated but is not required.                                        }
{   2. Altered source versions must be plainly marked as such, and must not be }
{      misrepresented as being the original software.                          }
{   3. This notice may not be removed or altered from any source distribution. }
{                                                                              }
{   ZLIB web page: http://www.zlib.net/                                        }
{                                                                              }
{                                                                              }
{ Revision history:                                                            }
{                                                                              }
{   2008/12/12  0.01  Initial version using zlib 1.2.3 object files            }
{                                                                              }
{ Todo:                                                                        }
{ - Complete stream classes                                                    }
{ - Portable PurePascal version                                                }
{******************************************************************************}

{$INCLUDE cDefines.inc}

unit cCompressZLIB;

interface

uses
  SysUtils,
  Classes;



{ ZLIB declarations }

type
  TZAlloc = function (const opaque: Pointer; const items, size: Integer): Pointer;
  TZFree  = procedure (const opaque, block: Pointer);

  { TZStreamRec }

  TZStreamRec = packed record
    next_in   : PAnsiChar; // next input byte
    avail_in  : LongInt;   // number of bytes available at next_in
    total_in  : LongInt;   // total nb of input bytes read so far

    next_out  : PAnsiChar; // next output byte should be put here
    avail_out : LongInt;   // remaining free space at next_out
    total_out : LongInt;   // total nb of bytes output so far

    msg       : PAnsiChar; // last error message, NULL if no error
    state     : Pointer;   // not visible by applications

    zalloc    : TZAlloc;   // used to allocate the internal state
    zfree     : TZFree;    // used to free the internal state
    opaque    : Pointer;   // private data object passed to zalloc and zfree

    data_type : Integer;   // best guess about the data type: ascii or binary
    adler     : LongInt;   // adler32 value of the uncompressed data
    reserved  : LongInt;   // reserved for future use
  end;



{ ZLIB constants }

const
  ZLIB_VERSION : PAnsiChar = '1.2.3';
  ZLIB_VERNUM  = $1230;

  // flush constants
  Z_NO_FLUSH      = 0;
  Z_PARTIAL_FLUSH = 1;
  Z_SYNC_FLUSH    = 2;
  Z_FULL_FLUSH    = 3;
  Z_FINISH        = 4;

  // return codes
  Z_OK            =  0;
  Z_STREAM_END    =  1;
  Z_NEED_DICT     =  2;
  Z_ERRNO         = -1;
  Z_STREAM_ERROR  = -2;
  Z_DATA_ERROR    = -3;
  Z_MEM_ERROR     = -4;
  Z_BUF_ERROR     = -5;
  Z_VERSION_ERROR = -6;

  // compression levels
  Z_NO_COMPRESSION       =  0;
  Z_BEST_SPEED           =  1;
  Z_BEST_COMPRESSION     =  9;
  Z_DEFAULT_COMPRESSION  = -1;

  // compression strategies
  Z_FILTERED         = 1;
  Z_HUFFMAN_ONLY     = 2;
  Z_DEFAULT_STRATEGY = 0;

  // data types
  Z_BINARY   = 0;
  Z_TEXT     = 1;
  Z_ASCII    = Z_TEXT;
  Z_UNKNOWN  = 2;

  // compression methods
  Z_DEFLATED = 8;



{ ZLIB export routines }

function  adler32(const Adler: LongInt; const Buf: PAnsiChar; const Len: LongInt): LongInt;
function  deflateInit_(var Strm: TZStreamRec; const Level: LongInt; const Version: PAnsiChar; const RecSize: LongInt): LongInt;
function  deflate(var Strm: TZStreamRec; Flush: LongInt): LongInt;
function  deflateEnd(var Strm: TZStreamRec): LongInt;
function  inflateInit_(var Strm: TZStreamRec; const Version: PAnsiChar; const RecSize: LongInt): LongInt;
function  inflate(var Strm: TZStreamRec; const Flush: LongInt): LongInt;
function  inflateEnd(var Strm: TZStreamRec): LongInt;
function  inflateReset(var Strm: TZStreamRec): LongInt;



{ Custom ZLIB routines }

type
  TZLibCompressionLevel = (
    zclNone,
    zclBestSpeed,
    zclBestCompression,
    zclDefault
  );

type
  EZLibError = class(Exception);
  EZCompressionError = class(EZLibError);
  EZDecompressionError = class(EZLibError);

procedure ZLibCompressBuf(
          const InBuffer: Pointer; const InSize: Integer;
          out OutBuffer: Pointer; out OutSize: Integer;
          const Level: TZLibCompressionLevel = zclDefault);
function  ZLibCompressStr(
          const S: AnsiString;
          const Level: TZLibCompressionLevel = zclDefault): AnsiString;

procedure ZLibDecompressBuf(
          const InBuffer: Pointer; const InSize: Integer;
          out OutBuffer: Pointer; out OutSize: Integer);
function  ZLibDecompressStr(const S: AnsiString): AnsiString;



{ Custom ZLIB stream class }

type
  TZLibStreamBase = class(TStream)
  private
    FStream    : TStream;
    // FBuffer    : array[0..16383] of Byte;
    FStreamRec : TZStreamRec;
  public
    constructor Create(const Stream: TStream);
  end;

  TZLibCompressionStream = class(TZLibStreamBase)
  private
    FLevel : TZLibCompressionLevel;
  protected
    // function GetSize: Int64; override;
  public
    constructor Create(const Stream: TStream; const Level: TZLibCompressionLevel = zclDefault);
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

  TZLibDecompressionStream = class(TZLibStreamBase)
  protected
    // function GetSize: Int64; override;
  public
    constructor Create(const Stream: TStream);
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DEBUG}{$IFDEF SELFTEST}
procedure SelfTest;
{$ENDIF}{$IFDEF PROFILE}
procedure Profile;
{$ENDIF}{$ENDIF}



implementation



{                                                                              }
{ zlib link libaries                                                           }
{                                                                              }
{ note: do not reorder these -- doing so will result in external functions     }
{ being undefined                                                              }
{                                                                              }
{ obj files taken as built by zlibex 1.2.3                                     }
{ bcc32 -c -6 -O2 -Ve -X -pr -a8 -b -d -k- -vi -tWM -r -RT- -ff *.c            }
{                                                                              }
{$IFDEF OS_MSWIN}

{$IFDEF COMMAND_LINE}
{$L adler32.obj}
{$L deflate.obj}
{$L infback.obj}
{$L inffast.obj}
{$L inflate.obj}
{$L inftrees.obj}
{$L trees.obj}
{$L compress.obj}
{$L crc32.obj}
{$ELSE}
{$L zlib/zlib123/adler32.obj}
{$L zlib/zlib123/deflate.obj}
{$L zlib/zlib123/infback.obj}
{$L zlib/zlib123/inffast.obj}
{$L zlib/zlib123/inflate.obj}
{$L zlib/zlib123/inftrees.obj}
{$L zlib/zlib123/trees.obj}
{$L zlib/zlib123/compress.obj}
{$L zlib/zlib123/crc32.obj}
{$ENDIF}

{ zlib external utility routines }

function adler32(const Adler: LongInt; const Buf: PAnsiChar; const Len: LongInt): LongInt; external;

{ zlib external deflate routines }

function deflateInit_(var Strm: TZStreamRec; const Level: LongInt; const Version: PAnsiChar;
         const RecSize: LongInt): LongInt; external;
function deflate(var Strm: TZStreamRec; Flush: LongInt): LongInt; external;
function deflateEnd(var Strm: TZStreamRec): LongInt; external;

{ zlib external inflate routines }

function inflateInit_(var Strm: TZStreamRec; const Version: PAnsiChar;
         const RecSize: LongInt): LongInt; external;
function inflate(var Strm: TZStreamRec; const Flush: LongInt): LongInt; external;
function inflateEnd(var Strm: TZStreamRec): LongInt; external;
function inflateReset(var Strm: TZStreamRec): LongInt; external;

{ zlib external function implementations }

function zcalloc(const Opaque: Pointer; const Items, Size: LongInt): Pointer;
begin
  GetMem(Result, Items * Size);
end;

procedure zcfree(const Opaque, Block: Pointer);
begin
  FreeMem(Block);
end;

{ zlib external symbol implementations }

const
  _z_errmsg: array[0..9] of PAnsiChar = (
    'need dictionary',      // Z_NEED_DICT      (2)
    'stream end',           // Z_STREAM_END     (1)
    '',                     // Z_OK             (0)
    'file error',           // Z_ERRNO          (-1)
    'stream error',         // Z_STREAM_ERROR   (-2)
    'data error',           // Z_DATA_ERROR     (-3)
    'insufficient memory',  // Z_MEM_ERROR      (-4)
    'buffer error',         // Z_BUF_ERROR      (-5)
    'incompatible version', // Z_VERSION_ERROR  (-6)
    ''
    );

{ c external function implementations }

procedure _memset(const P: Pointer; const B: Byte; const Count: LongInt); cdecl;
begin
  Assert(Assigned(P));

  FillChar(P^, Count, B);
end;

procedure _memcpy(const Dest, Source: Pointer; const Count: LongInt); cdecl;
begin
  Assert(Assigned(Source));
  Assert(Assigned(Dest));

  Move(Source^, Dest^, Count);
end;
{$ENDIF}



{ Custom ZLIB routines }

function ZLIBErrorMessage(const Code: LongInt): AnsiString;
begin
  case Code of
    -6..2 : Result := _z_errmsg[2 - Code];
  else
    Result := 'error ' + IntToStr(Code);
  end;
end;

function CheckZLIBError(const Code: LongInt): LongInt; {$IFDEF UseInline}inline;{$ENDIF}
begin
  if Code < 0 then
    raise EZLibError.Create(ZLIBErrorMessage(Code));
  Result := Code;
end;

const
  ZCompressionLevelMapIn: array[TZLibCompressionLevel] of LongInt = (
    Z_NO_COMPRESSION,
    Z_BEST_SPEED,
    Z_BEST_COMPRESSION,
    Z_DEFAULT_COMPRESSION
  );

procedure StreamRecInit(var StreamRec: TZStreamRec;
          const InBuffer: Pointer; const InSize: Integer;
          const OutBuffer: Pointer; const OutSize: Integer);
begin
  FillChar(StreamRec, SizeOf(TZStreamRec), 0);
  StreamRec.next_in := InBuffer;
  StreamRec.avail_in := InSize;
  StreamRec.next_out := OutBuffer;
  StreamRec.avail_out := OutSize;
end;

function DeflateInit(var StreamRec: TZStreamRec; const Level: TZLibCompressionLevel): Integer;
begin
  Result := DeflateInit_(StreamRec, ZCompressionLevelMapIn[Level], ZLIB_VERSION,
      SizeOf(TZStreamRec));
end;

function InflateInit(var StreamRec: TZStreamRec): Integer;
begin
  Result := InflateInit_(StreamRec, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function ZLibCompressBufSizeEstimate(const InSize: Integer): Integer;
begin
  if InSize <= $F8 then
    Result := $100
  else
    Result := (InSize + $108) and not $FF;
end;

function ZLibCompressBufSizeReEstimate(const OutSize: Integer): Integer;
begin
  Assert(OutSize >= $100);
  
  Result := OutSize + (OutSize div 2);
end;

procedure ZLibOutBufResize(
          var StreamRec: TZStreamRec;
          var OutBuffer: Pointer; const OutSize: Integer);
var I : Integer;
begin
  Assert(Assigned(OutBuffer));
  Assert(OutSize > 0);

  ReallocMem(OutBuffer, OutSize);
  I := StreamRec.total_out;
  StreamRec.next_out := PAnsiChar(Integer(OutBuffer) + I);
  StreamRec.avail_out := OutSize - I;
end;

procedure ZLibCompressBuf(
          const InBuffer: Pointer; const InSize: Integer;
          out OutBuffer: Pointer; out OutSize: Integer;
          const Level: TZLibCompressionLevel);
var StreamRec : TZStreamRec;
begin
  OutSize := ZLibCompressBufSizeEstimate(InSize);
  GetMem(OutBuffer, OutSize);
  try
    StreamRecInit(StreamRec, InBuffer, InSize, OutBuffer, OutSize);
    CheckZLIBError(DeflateInit(StreamRec, Level));
    try
      while CheckZLIBError(deflate(StreamRec, Z_FINISH)) <> Z_STREAM_END do
      begin
        OutSize := ZLibCompressBufSizeReEstimate(OutSize);
        ZLibOutBufResize(StreamRec, OutBuffer, OutSize);
      end;
    finally
      CheckZLIBError(deflateEnd(StreamRec));
    end;
    if OutSize <> StreamRec.total_out then
    begin
      OutSize := StreamRec.total_out;
      ReallocMem(OutBuffer, OutSize);
    end;
  except
    on E: Exception do
    begin
      FreeMem(OutBuffer);
      raise EZCompressionError.Create('ZLIB compression error: ' + E.Message);
    end;
  end;
end;

function ZLibCompressStr(const S: AnsiString; const Level: TZLibCompressionLevel): AnsiString;
var OutBuffer : Pointer;
    OutSize   : Integer;
begin
  ZLibCompressBuf(PAnsiChar(S), Length(S), OutBuffer, OutSize, Level);
  try
    SetLength(Result, OutSize);
    Move(OutBuffer^, PAnsiChar(Result)^, OutSize);
  finally
    FreeMem(OutBuffer);
  end;
end;

function ZLibDecompressBufSizeEstimate(const InSize: Integer): Integer;
begin
  if InSize <= $80 then
    Result := $100
  else
    Result := (InSize * 2 + $108) and not $FF;
end;

function ZLibDecompressBufSizeReEstimate(const OutSize: Integer): Integer;
begin
  Assert(OutSize >= $100);
  Result := OutSize + (OutSize div 2);
end;

procedure ZLibDecompressBuf(
          const InBuffer: Pointer; const InSize: Integer;
          out OutBuffer: Pointer; out OutSize: Integer);
var StreamRec : TZStreamRec;
begin
  OutSize := ZLibDecompressBufSizeEstimate(InSize);
  GetMem(OutBuffer, OutSize);
  try
    StreamRecInit(StreamRec, InBuffer, InSize, OutBuffer, OutSize);
    CheckZLIBError(InflateInit(StreamRec));
    try
      while CheckZLIBError(inflate(StreamRec, Z_NO_FLUSH)) <> Z_STREAM_END do
        begin
          OutSize := ZLibDecompressBufSizeReEstimate(OutSize);
          ZLibOutBufResize(StreamRec, OutBuffer, OutSize);
        end;
    finally
      CheckZLIBError(inflateEnd(StreamRec));
    end;
    if OutSize <> StreamRec.total_out then
      begin
        OutSize := StreamRec.total_out;
        ReallocMem(OutBuffer, OutSize);
      end;
  except
    on E: Exception do
    begin
      FreeMem(OutBuffer);
      raise EZDecompressionError.Create('ZLIB decompression error: ' + E.Message);
    end;
  end;
end;

function ZLibDecompressStr(const S: AnsiString): AnsiString;
var
  Buffer : Pointer;
  Size   : Integer;
begin
  ZLibDecompressBuf(PAnsiChar(S), Length(S), Buffer, Size);
  try
    SetLength(Result, Size);
    if Size > 0 then
      Move(Buffer^, PAnsiChar(Result)^, Size);
  finally
    FreeMem(Buffer);
  end;
end;



{                                                                              }
{ TZLibStreamBase                                                              }
{                                                                              }
constructor TZLibStreamBase.Create(const Stream: TStream);
begin
  inherited Create;
  FStream := Stream;
end;



{                                                                              }
{ TZLibCompressionStream                                                       }
{                                                                              }
constructor TZLibCompressionStream.Create(const Stream: TStream; const Level: TZLibCompressionLevel);
begin
  inherited Create(Stream);
  FLevel := Level;
  CheckZLIBError(DeflateInit(FStreamRec, Level));
//  GetMem(OutBuffer, OutSize);
//  StreamRecInit(StreamRec, InBuffer, InSize, OutBuffer, OutSize);
end;

{
function TZLibCompressionStream.GetSize: Int64;
begin
end;
}

function TZLibCompressionStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
end;

function TZLibCompressionStream.Read(var Buffer; Count: Longint): Longint;
begin
  raise EZCompressionError.Create('Invalid method');
end;

function TZLibCompressionStream.Write(const Buffer; Count: Longint): Longint;
begin
{  OutSize := ZLibCompressBufSizeEstimate(Count);
  try
    StreamRecInit(StreamRec, InBuffer, InSize, OutBuffer, OutSize);
    CheckZLIBError(DeflateInit(StreamRec, Level));
    try
      while CheckZLIBError(deflate(StreamRec, Z_FINISH)) <> Z_STREAM_END do
      begin
        OutSize := ZLibCompressBufSizeReEstimate(OutSize);
        ZLibOutBufResize(StreamRec, OutBuffer, OutSize);
      end;
    finally
      CheckZLIBError(deflateEnd(StreamRec));
    end;
    if OutSize <> StreamRec.total_out then
    begin
      OutSize := StreamRec.total_out;
      ReallocMem(OutBuffer, OutSize);
    end;
  except
    on E: Exception do
    begin
      FreeMem(OutBuffer);
      raise EZCompressionError.Create('ZLIB compression error: ' + E.Message);
    end;
  end; }
end;



{                                                                              }
{ TZLibDecompressionStream                                                     }
{                                                                              }
constructor TZLibDecompressionStream.Create(const Stream: TStream);
begin
  inherited Create(Stream);
  CheckZLIBError(InflateInit(FStreamRec));
end;

{
function TZLibDecompressionStream.GetSize: Int64;
begin
end;
}

function TZLibDecompressionStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
end;

function TZLibDecompressionStream.Read(var Buffer; Count: Longint): Longint;
begin
{  while CheckZLIBError(deflate(StreamRec, Z_FINISH)) <> Z_STREAM_END do
    begin
    end;
    OutSize := StreamRec.total_out;
    ReallocMem(OutBuffer, OutSize); }
end;

function TZLibDecompressionStream.Write(const Buffer; Count: Longint): Longint;
begin
  raise EZCompressionError.Create('Invalid method');
end;



{                                                                              }
{ Self testing code                                                            }
{                                                                              }
{$IFDEF DEBUG}
{$IFDEF SELFTEST}
{$ASSERTIONS ON}
const
  TestStrCount = 8;
  TestStr : array[1..TestStrCount] of AnsiString = (
      '',
      #0,
      'Fundamentals',
      'ZLIB 1.2.3',
      'Test string with string repetition and string repetition',
      '...........................................................',
      #$FF#$00#$01#$02#$FE#$F0#$80#$7F,
      #$78#$9C#$03#$00#$00#$00#$00#$01);

procedure SelfTest_TestStrs;
var I : Integer;
begin
  for I := 1 to TestStrCount do
    Assert(ZLibDecompressStr(ZLibCompressStr(TestStr[I])) = TestStr[I]);
end;

procedure SelfTest_LongStr;
var
  I : Integer;
  S : AnsiString;
  T : AnsiString;
begin
  S := 'Long string';
  for I := 1 to 1000 do
    S := S + ' testing ' + IntToStr(I);
  T := ZLibCompressStr(S);
  Assert((S <> T) and (Length(T) < Length(S)));
  Assert(ZLibDecompressStr(T) = S);
end;

procedure SelfTest_SpecialStr;
const
  EmptyTestStrCompressed = #$78#$9C#$03#$00#$00#$00#$00#$01;
begin
  Assert(ZLibCompressStr('') = EmptyTestStrCompressed);
  Assert(ZLibDecompressStr(EmptyTestStrCompressed) = '');
end;

procedure SelfTest;
begin
  SelfTest_TestStrs;
  SelfTest_LongStr;
  SelfTest_SpecialStr;
end;
{$ENDIF}

{$IFDEF PROFILE}
procedure Profile;
var
  I : Integer;
begin
  for I := 1 to 10000 do
  begin
    SelfTest_LongStr;
    SelfTest_TestStrs;
  end;
end;
{$ENDIF}
{$ENDIF}



end.

