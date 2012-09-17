{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals TLS                                         }
{   File name:        cTLSBuffer.pas                                           }
{   File version:     0.01                                                     }
{   Description:      TLS buffer                                               }
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
{   2010/11/26  0.01  Initial development.                                     }
{                                                                              }
{******************************************************************************}

{$INCLUDE cTLS.inc}

unit cTLSBuffer;

interface



{                                                                              }
{ TLS Buffer                                                                   }
{                                                                              }
type
  TTLSBuffer = record
    Ptr  : Pointer;
    Size : Integer;
    Head : Integer;
    Used : Integer;
  end;

procedure TLSBufferInitialise(
          var TLSBuf: TTLSBuffer;
          const TLSBufSize: Integer = -1);
procedure TLSBufferFinalise(var TLSBuf: TTLSBuffer);
procedure TLSBufferPack(var TLSBuf: TTLSBuffer);
procedure TLSBufferResize(
          var TLSBuf: TTLSBuffer;
          const TLSBufSize: Integer);
procedure TLSBufferExpand(
          var TLSBuf: TTLSBuffer;
          const Size: Integer);
function  TLSBufferAddPtr(
          var TLSBuf: TTLSBuffer;
          const Size: Integer): Pointer;
procedure TLSBufferAddBuf(
          var TLSBuf: TTLSBuffer;
          const Buf; const Size: Integer);
procedure TLSBufferShrink(var TLSBuf: TTLSBuffer);
function  TLSBufferPeekPtr(
          const TLSBuf: TTLSBuffer;
          var BufPtr: Pointer; const Size: Integer): Integer;
function  TLSBufferPeek(
          var TLSBuf: TTLSBuffer;
          var Buf; const Size: Integer): Integer;
function  TLSBufferRemove(
          var TLSBuf: TTLSBuffer;
          var Buf; const Size: Integer): Integer;
function  TLSBufferUsed(const TLSBuf: TTLSBuffer): Integer;
function  TLSBufferPtr(const TLSBuf: TTLSBuffer): Pointer;
procedure TLSBufferClear(var TLSBuf: TTLSBuffer);
function  TLSBufferDiscard(
          var TLSBuf: TTLSBuffer;
          const Size: Integer): Integer; 



implementation

uses
  { TLS }
  cTLSUtils;



{                                                                              }
{ TLS Buffer                                                                   }
{                                                                              }
const
  TLS_CLIENT_DEFAULTBUFFERSIZE = 16384;

// Initialise a TLS buffer
procedure TLSBufferInitialise(
          var TLSBuf: TTLSBuffer;
          const TLSBufSize: Integer = -1);
var L : Integer;
begin
  TLSBuf.Ptr := nil;
  TLSBuf.Size := 0;
  TLSBuf.Head := 0;
  TLSBuf.Used := 0;
  L := TLSBufSize;
  if L < 0 then
    L := TLS_CLIENT_DEFAULTBUFFERSIZE;
  if L > 0 then
    GetMem(TLSBuf.Ptr, L);
  TLSBuf.Size := L;
end;

// Finalise a TLS buffer
procedure TLSBufferFinalise(var TLSBuf: TTLSBuffer);
var P : Pointer;
begin
  P := TLSBuf.Ptr;
  if Assigned(P) then
    begin
      TLSBuf.Ptr := nil;
      FreeMem(P);
    end;
  TLSBuf.Size := 0;
end;

// Pack a TLS buffer
// Moves data to front of buffer
// Post: TLSBuf.Head = 0
procedure TLSBufferPack(var TLSBuf: TTLSBuffer);
var P, Q : PByte;
    U, H : Integer;
begin
  H := TLSBuf.Head;
  if H <= 0 then
    exit;
  U := TLSBuf.Used;
  if U <= 0 then
    begin
      TLSBuf.Head := 0;
      exit;
    end;
  Assert(Assigned(TLSBuf.Ptr));
  P := TLSBuf.Ptr;
  Q := P;
  Inc(P, H);
  Move(P^, Q^, U);
  TLSBuf.Head := 0;
end;

// Resize a TLS buffer
// New buffer size must be large enough to hold existing data
// Post: TLSBuf.Size = TLSBufSize
procedure TLSBufferResize(
          var TLSBuf: TTLSBuffer;
          const TLSBufSize: Integer);
var U, L : Integer;
begin
  L := TLSBufSize;
  U := TLSBuf.Used;
  // treat negative TLSBufSize parameter as zero
  if L < 0 then
    L := 0;
  // check if shrinking buffer to less than used size
  if U > L then
    raise ETLSError.Create(TLSError_InvalidParameter);
  // check if packing required to fit buffer
  if U + TLSBuf.Head > L then
    TLSBufferPack(TLSBuf);
  Assert(U + TLSBuf.Head <= L);
  // resize
  ReallocMem(TLSBuf.Ptr, L);
  TLSBuf.Size := L;
end;

// Expand a TLS buffer
// Expands the size of the buffer to at least Size
procedure TLSBufferExpand(
          var TLSBuf: TTLSBuffer;
          const Size: Integer);
var S, N, I : Integer;
begin
  S := TLSBuf.Size;
  N := Size;
  // check if expansion not required
  if N <= S then
    exit;
  // scale up new size proportional to current size
  // increase by at least quarter of current size
  // this reduces the number of resizes in growing buffers
  I := S + (S div 4);
  if N < I then
    N := I;
  // resize buffer
  Assert(N >= Size);
  TLSBufferResize(TLSBuf, N);
end;

// Returns a pointer to position in buffer to add new data of Size
// Handles resizing and packing of buffer to fit new data
function TLSBufferAddPtr(
         var TLSBuf: TTLSBuffer;
         const Size: Integer): Pointer; {$IFDEF UseInline}inline;{$ENDIF}
var P : PByte;
    U, L : Integer;
begin
  // return nil if nothing to add
  if Size <= 0 then
    begin
      Result := nil;
      exit;
    end;
  U := TLSBuf.Used;
  L := U + Size;
  // resize if necessary
  if L > TLSBuf.Size then
    TLSBufferExpand(TLSBuf, L);
  // pack if necessary
  if TLSBuf.Head + L > TLSBuf.Size then
    TLSBufferPack(TLSBuf);
  // buffer should now be large enough for new data
  Assert(TLSBuf.Size > 0);
  Assert(TLSBuf.Head + TLSBuf.Used + Size <= TLSBuf.Size);
  // get buffer pointer
  Assert(Assigned(TLSBuf.Ptr));
  P := TLSBuf.Ptr;
  Inc(P, TLSBuf.Head + U);
  Result := P;
end;

// Adds new data from a buffer to a TLS buffer
procedure TLSBufferAddBuf(
          var TLSBuf: TTLSBuffer;
          const Buf; const Size: Integer); {$IFDEF UseInline}inline;{$ENDIF}
var P : PByte;
begin
  if Size <= 0 then
    exit;
  // get buffer pointer
  P := TLSBufferAddPtr(TLSBuf, Size);
  // move user buffer to buffer
  Assert(Assigned(P));
  Move(Buf, P^, Size);
  Inc(TLSBuf.Used, Size);
  Assert(TLSBuf.Head + TLSBuf.Used <= TLSBuf.Size);
end;

// Shrink the size of a TLS buffer to release all unused memory
// Post: TLSBuf.Used = TLSBuf.Size and TLSBuf.Head = 0
procedure TLSBufferShrink(var TLSBuf: TTLSBuffer);
var S, U : Integer;
begin
  S := TLSBuf.Size;
  if S <= 0 then
    exit;
  U := TLSBuf.Used;
  if U = 0 then
    begin
      TLSBufferResize(TLSBuf, 0);
      TLSBuf.Head := 0;
      exit;
    end;
  if U = S then
    exit;
  TLSBufferPack(TLSBuf);        // move data to front of buffer
  TLSBufferResize(TLSBuf, U);   // set size equal to used bytes
  Assert(TLSBuf.Used = TLSBuf.Size);
end;

// Peek TLS buffer
// Returns the number of bytes actually available to peek (up to requested size)
function TLSBufferPeekPtr(
         const TLSBuf: TTLSBuffer;
         var BufPtr: Pointer; const Size: Integer): Integer; {$IFDEF UseInline}inline;{$ENDIF}
var P : PByte;
    L : Integer;
begin
  // handle peeking zero bytes
  if Size <= 0 then
    begin
      BufPtr := nil;
      Result := 0;
      exit;
    end;
  // handle empty buffer
  L := TLSBuf.Used;
  if L <= 0 then
    begin
      BufPtr := nil;
      Result := 0;
      exit;
    end;
  // peek from buffer
  if L > Size then
    L := Size;
  Assert(TLSBuf.Head + L <= TLSBuf.Size);
  Assert(Assigned(TLSBuf.Ptr));
  P := TLSBuf.Ptr;
  Inc(P, TLSBuf.Head);
  BufPtr := P;
  Result := L;
end;

// Peek data from a TLS buffer
// Returns the number of bytes actually available and copied into the buffer
function TLSBufferPeek(
         var TLSBuf: TTLSBuffer;
         var Buf; const Size: Integer): Integer; {$IFDEF UseInline}inline;{$ENDIF}
var P : Pointer;
    L : Integer;
begin
  L := TLSBufferPeekPtr(TLSBuf, P, Size);
  Move(P^, Buf, L);
  Result := L;
end;

// Remove data from a TLS buffer
// Returns the number of bytes actually available and copied into the user buffer
function TLSBufferRemove(
         var TLSBuf: TTLSBuffer;
         var Buf; const Size: Integer): Integer; {$IFDEF UseInline}inline;{$ENDIF}
var L, H, U : Integer;
begin
  // peek data from buffer
  L := TLSBufferPeek(TLSBuf, Buf, Size);
  if L = 0 then
    begin
      Result := 0;
      exit;
    end;
  // remove from buffer
  H := TLSBuf.Head;
  U := TLSBuf.Used;
  Inc(H, L);
  Dec(U, L);
  if U = 0 then
    H := 0;
  TLSBuf.Head := H;
  TLSBuf.Used := U;
  Result := L;
end;

// Returns number of bytes used in TLS buffer
function TLSBufferUsed(const TLSBuf: TTLSBuffer): Integer; {$IFDEF UseInline}inline;{$ENDIF}
begin
  Result := TLSBuf.Used;
end;

// Returns pointer to TLS buffer head
function TLSBufferPtr(const TLSBuf: TTLSBuffer): Pointer; {$IFDEF UseInline}inline;{$ENDIF}
var P : PAnsiChar;
begin
  P := PAnsiChar(TLSBuf.Ptr);
  Inc(P, TLSBuf.Head);
  Result := P;
end;

// Clear the data from a TLS buffer
procedure TLSBufferClear(var TLSBuf: TTLSBuffer);
begin
  TLSBuf.Used := 0;
  TLSBuf.Head := 0;
end;

// Discard a number of bytes from the TLS buffer
// Returns the number of bytes actually discarded from buffer
function TLSBufferDiscard(
         var TLSBuf: TTLSBuffer;
         const Size: Integer): Integer; {$IFDEF UseInline}inline;{$ENDIF}
var L, U : Integer;
begin
  // handle discarding zero bytes from buffer
  L := Size;
  if L <= 0 then
    begin
      Result := 0;
      exit;
    end;
  // handle discarding the complete buffer
  U := TLSBuf.Used;
  if L >= U then
    begin
      TLSBuf.Used := 0;
      TLSBuf.Head := 0;
      Result := U;
      exit;
    end;
  // discard partial buffer
  Inc(TLSBuf.Head, L);
  Dec(U, L);
  TLSBuf.Used := U;
  Result := L;
end;



end.

