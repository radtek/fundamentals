{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cMultiStrSysUtils.pas                                    }
{   File version:     4.02                                                     }
{   Description:      Multi-string SysUtils functions.                         }
{                     Provides common functions from SysUtils in AnsiString    }
{                     and WideString for compatibility between Unicode and     }
{                     non-Unicode versions of Delphi.                          }
{                                                                              }
{   Copyright:        Copyright © 2011, David J Butler                         }
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
{   E-mail:           fundamentalslib@gmail.com                                }
{                                                                              }
{ Revision history:                                                            }
{                                                                              }
{   2011/09/27  4.01  Initial version.                                         }
{   2011/03/20  4.02  WideString functions.                                    }
{                                                                              }
{ Supported compilers:                                                         }
{                                                                              }
{   Delphi 5 Win32 i386                4.01  2011/09/27                        }
{   Delphi 6 Win32 i386                4.01  2011/09/27                        }
{   Delphi 7 Win32 i386                4.01  2011/09/27                        }
{   Delphi 2006 Win32 i386             4.01  2011/09/27                        }
{   Delphi 2007 Win32 i386             4.01  2011/09/27                        }
{   Delphi 2009 Win32 i386             4.01  2011/09/27                        }
{                                                                              }
{******************************************************************************}

{$INCLUDE cDefines.inc}

{$IFDEF DEBUG}
{$IFDEF SELFTEST}
  {$DEFINE ANSISTRSYSUTILS_SELFTEST}
{$ENDIF}
{$ENDIF}

unit cMultiStrSysUtils;

interface



function TryStrToIntA(const A: AnsiString; out B: Integer): Boolean;
function StrToIntA(const A: AnsiString): Integer;
function StrToIntDefA(const A: AnsiString; const Default: Integer = 0): Integer;

function TryStrToIntW(const A: WideString; out B: Integer): Boolean;
function StrToIntW(const A: WideString): Integer;
function StrToIntDefW(const A: WideString; const Default: Integer = 0): Integer;

function TryStrToInt64A(const A: AnsiString; out B: Int64): Boolean;
function StrToInt64A(const A: AnsiString): Int64;
function StrToInt64DefA(const A: AnsiString; const Default: Int64 = 0): Int64;

function TryStrToInt64W(const A: WideString; out B: Int64): Boolean;
function StrToInt64W(const A: WideString): Int64;
function StrToInt64DefW(const A: WideString; const Default: Int64 = 0): Int64;

function IntToStrA(const A: Integer): AnsiString; overload;
function IntToStrA(const A: Int64): AnsiString; overload;

function IntToStrW(const A: Integer): WideString; overload;
function IntToStrW(const A: Int64): WideString; overload;

function LongWordToHexA(const A: LongWord; const Digits: Integer; const LowerCase: Boolean): AnsiString;
function LongWordToHexW(const A: LongWord; const Digits: Integer; const LowerCase: Boolean): WideString;

function SameTextA(const A, B: AnsiString): Boolean;

function LowerCaseA(const A: AnsiString): AnsiString;
function UpperCaseA(const A: AnsiString): AnsiString;

function StrLenA(const A: PAnsiChar): Integer;
function StrLenW(const A: PWideChar): Integer;

function StrPasA(const A: PAnsiChar): AnsiString;
function StrPasW(const A: PWideChar): WideString;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF ANSISTRSYSUTILS_SELFTEST}
procedure SelfTest;
{$ENDIF}



implementation

uses
  SysUtils;



const
  MaxInteger = High(Integer);
  MinInteger = Low(Integer);
  MaxAbsInteger = Abs(Int64(Low(Integer)));

function AsciiCharToInt(const A: AnsiChar): Integer;
begin
  if A in ['0'..'9'] then
    Result := Ord(A) - Ord('0')
  else
    Result := -1;
end;

function TryStrToIntA(const A: AnsiString; out B: Integer): Boolean;
var
  S, L, I, J : Integer;
  C : AnsiChar;
  R : Int64;
begin
  L := Length(A);
  if L = 0 then
    begin
      B := 0;
      Result := False;
      exit;
    end;
  I := 1;
  // check sign
  case A[I] of
    '-' : S := -1;
    '+' : S := 1;
  else
    S := 0;
  end;
  if S <> 0 then
    Inc(I);
  // skip leading zeros
  while (I <= L) and (A[I] = '0') do
    Inc(I);
  if I > L then
    begin
      // all zero
      B := 0;
      Result := True;
      exit;
    end;
  // validate digits and convert
  J := I;
  R := 0;
  while J <= L do
    begin
      C := A[J];
      case C of
        '0'..'9' :
          begin
            R := R * 10 + AsciiCharToInt(C);
            Inc(J);
            if R > MaxAbsInteger then
              break;
          end
      else
        begin
          // invalid character
          B := 0;
          Result := False;
          exit;
        end;
      end;
    end;
  // apply sign and check range
  if S < 0 then
    begin
      R := -R;
      if R < MinInteger then
        begin
          B := MinInteger;
          Result := False;
          exit;
        end;
    end else
    begin
      if R > MaxInteger then
        begin
          B := MaxInteger;
          Result := False;
          exit;
        end;
    end;
  // return integer result
  B := Integer(R);
  Result := True;
end;

function StrToIntA(const A: AnsiString): Integer;
begin
  if not TryStrToIntA(A, Result) then
    raise EConvertError.Create('Invalid integer value');
end;

function StrToIntDefA(const A: AnsiString; const Default: Integer = 0): Integer;
begin
  if not TryStrToIntA(A, Result) then
    Result := Default;
end;

function TryStrToIntW(const A: WideString; out B: Integer): Boolean;
var
  S, L, I, J : Integer;
  C : WideChar;
  R : Int64;
begin
  L := Length(A);
  if L = 0 then
    begin
      B := 0;
      Result := False;
      exit;
    end;
  I := 1;
  // check sign
  case A[I] of
    '-' : S := -1;
    '+' : S := 1;
  else
    S := 0;
  end;
  if S <> 0 then
    Inc(I);
  // skip leading zeros
  while (I <= L) and (A[I] = '0') do
    Inc(I);
  if I > L then
    begin
      // all zero
      B := 0;
      Result := True;
      exit;
    end;
  // validate digits and convert
  J := I;
  R := 0;
  while J <= L do
    begin
      C := A[J];
      case C of
        '0'..'9' :
          begin
            R := R * 10 + AsciiCharToInt(AnsiChar(C));
            Inc(J);
            if R > MaxAbsInteger then
              break;
          end
      else
        begin
          // invalid character
          B := 0;
          Result := False;
          exit;
        end;
      end;
    end;
  // apply sign and check range
  if S < 0 then
    begin
      R := -R;
      if R < MinInteger then
        begin
          B := MinInteger;
          Result := False;
          exit;
        end;
    end else
    begin
      if R > MaxInteger then
        begin
          B := MaxInteger;
          Result := False;
          exit;
        end;
    end;
  // return integer result
  B := Integer(R);
  Result := True;
end;

function StrToIntW(const A: WideString): Integer;
begin
  if not TryStrToIntW(A, Result) then
    raise EConvertError.Create('Invalid integer value');
end;

function StrToIntDefW(const A: WideString; const Default: Integer): Integer;
begin
  if not TryStrToIntW(A, Result) then
    Result := Default;
end;

function TryStrToInt64A(const A: AnsiString; out B: Int64): Boolean;
var
  E : Integer;
begin
  {$IFDEF StringIsUnicode}
  Val(String(A), B, E);
  {$ELSE}
  Val(A, B, E);
  {$ENDIF}
  Result := E = 0;
end;

function StrToInt64A(const A: AnsiString): Int64;
begin
  if not TryStrToInt64A(A, Result) then
    raise EConvertError.Create('Invalid integer value');
end;

function StrToInt64DefA(const A: AnsiString; const Default: Int64 = 0): Int64;
begin
  if not TryStrToInt64A(A, Result) then
    Result := Default;
end;

function TryStrToInt64W(const A: WideString; out B: Int64): Boolean;
var
  E : Integer;
begin
  Val(A, B, E);
  Result := E = 0;
end;

function StrToInt64W(const A: WideString): Int64;
begin
  if not TryStrToInt64W(A, Result) then
    raise EConvertError.Create('Invalid integer value');
end;

function StrToInt64DefW(const A: WideString; const Default: Int64 = 0): Int64;
begin
  if not TryStrToInt64W(A, Result) then
    Result := Default;
end;

function IntToAnsiChar(const A: Integer): AnsiChar;
begin
  if (A < 0) or (A > 9) then
    Result := #$00
  else
    Result := AnsiChar(48 + A);
end;

function IntToStrA(const A: Integer): AnsiString;
begin
  Result := IntToStrA(Int64(A));
end;

function IntToStrA(const A: Int64): AnsiString;
var
  L, I : Integer;
  T : Int64;
begin
  if A = 0 then
    begin
      Result := '0';
      exit;
    end;
  // calculate length
  if A < 0 then
    L := 1
  else
    L := 0;
  T := A;
  while T <> 0 do
    begin
      T := T div 10;
      Inc(L);
    end;
  // convert
  SetLength(Result, L);
  I := 0;
  T := A;
  if T < 0 then
    begin
      Result[1] := '-';
      T := -T;
    end;
  while T > 0 do
    begin
      Result[L - I] := IntToAnsiChar(T mod 10);
      T := T div 10;
      Inc(I);
    end;
end;

function IntToStrW(const A: Integer): WideString;
begin
  Result := IntToStrW(Int64(A));
end;

function IntToStrW(const A: Int64): WideString;
var
  L, I : Integer;
  T : Int64;
begin
  if A = 0 then
    begin
      Result := '0';
      exit;
    end;
  // calculate length
  if A < 0 then
    L := 1
  else
    L := 0;
  T := A;
  while T <> 0 do
    begin
      T := T div 10;
      Inc(L);
    end;
  // convert
  SetLength(Result, L);
  I := 0;
  T := A;
  if T < 0 then
    begin
      Result[1] := '-';
      T := -T;
    end;
  while T > 0 do
    begin
      Result[L - I] := WideChar(IntToAnsiChar(T mod 10));
      T := T div 10;
      Inc(I);
    end;
end;

function IntToLowerHexAnsiChar(const A: Integer): AnsiChar;
begin
  if (A < 0) or (A > 15) then
    Result := #$00
  else
  if A <= 9 then
    Result := AnsiChar(48 + A)
  else
    Result := AnsiChar(87 + A);
end;

function IntToUpperHexAnsiChar(const A: Integer): AnsiChar;
begin
  if (A < 0) or (A > 15) then
    Result := #$00
  else
  if A <= 9 then
    Result := AnsiChar(48 + A)
  else
    Result := AnsiChar(55 + A);
end;

function LongWordToHexA(const A: LongWord; const Digits: Integer; const LowerCase: Boolean): AnsiString;
var
  L, I, D : Integer;
  T : LongWord;
  C : AnsiChar;
begin
  // calculate length
  L := 0;
  T := A;
  while T <> 0 do
    begin
      T := T div 16;
      Inc(L);
    end;
  if L = 0 then
    L := 1;
  if Digits > L then
    L := Digits;
  // convert
  SetLength(Result, L);
  I := 0;
  T := A;
  while T > 0 do
    begin
      D := T mod 16;
      if LowerCase then
        C := IntToLowerHexAnsiChar(D)
      else
        C := IntToUpperHexAnsiChar(D);
      Result[L - I] := C;
      T := T div 16;
      Inc(I);
    end;
  while I < L do
    begin
      Result[L - I] := '0';
      Inc(I);
    end;
end;

function LongWordToHexW(const A: LongWord; const Digits: Integer; const LowerCase: Boolean): WideString;
var
  L, I, D : Integer;
  T : LongWord;
  C : WideChar;
begin
  // calculate length
  L := 0;
  T := A;
  while T <> 0 do
    begin
      T := T div 16;
      Inc(L);
    end;
  if L = 0 then
    L := 1;
  if Digits > L then
    L := Digits;
  // convert
  SetLength(Result, L);
  I := 0;
  T := A;
  while T > 0 do
    begin
      D := T mod 16;
      if LowerCase then
        C := WideChar(IntToLowerHexAnsiChar(D))
      else
        C := WideChar(IntToUpperHexAnsiChar(D));
      Result[L - I] := C;
      T := T div 16;
      Inc(I);
    end;
  while I < L do
    begin
      Result[L - I] := '0';
      Inc(I);
    end;
end;

function AsciiLowCase(const C: AnsiChar): AnsiChar; {$IFDEF UseInline}inline;{$ENDIF}
begin
  if C in ['A'..'Z'] then
    Result := AnsiChar(Byte(C) + 32)
  else
    Result := C;
end;

function AsciiUpperCase(const C: AnsiChar): AnsiChar; {$IFDEF UseInline}inline;{$ENDIF}
begin
  if C in ['a'..'z'] then
    Result := AnsiChar(Byte(C) - 32)
  else
    Result := C;
end;

function AsciiCharEqualNoCase(const A, B: AnsiChar): Boolean; {$IFDEF UseInline}inline;{$ENDIF}
var
  C, D : AnsiChar;
begin
  Result := A = B;
  if Result then
    exit;
  C := AsciiLowCase(A);
  D := AsciiLowCase(B);
  Result := C = D;
end;

function SameTextA(const A, B: AnsiString): Boolean;
var
  L, I : Integer;
begin
  L := Length(A);
  if L <> Length(B) then
    begin
      Result := False;
      exit;
    end;
  for I := 1 to L do
    if not AsciiCharEqualNoCase(A[I], B[I]) then
      begin
        Result := False;
        exit;
      end;
  Result := True;
end;

function LowerCaseA(const A: AnsiString): AnsiString;
var
  I : Integer;
  C, D : AnsiChar;
begin
  Result := A;
  for I := 1 to Length(Result) do
    begin
      C := Result[I];
      D := AsciiLowCase(C);
      if D <> C then
        Result[I] := D;
    end;
end;

function UpperCaseA(const A: AnsiString): AnsiString;
var
  I : Integer;
  C, D : AnsiChar;
begin
  Result := A;
  for I := 1 to Length(Result) do
    begin
      C := Result[I];
      D := AsciiUpperCase(C);
      if D <> C then
        Result[I] := D;
    end;
end;

function StrLenA(const A: PAnsiChar): Integer;
var
  L : Integer;
begin
  if not Assigned(A) then
    begin
      Result := 0;
      exit;
    end;
  L := 0;
  while A[L] <> #0 do
    Inc(L);
  Result := L;
end;

function StrLenW(const A: PWideChar): Integer;
var
  L : Integer;
begin
  if not Assigned(A) then
    begin
      Result := 0;
      exit;
    end;
  L := 0;
  while A[L] <> #0 do
    Inc(L);
  Result := L;
end;

function StrPasA(const A: PAnsiChar): AnsiString;
var
  I, L : Integer;
begin
  L := StrLenA(A);
  SetLength(Result, L);
  if L = 0 then
    exit;
  I := 0;
  while I < L do
    begin
      Result[I + 1] := A[I];
      Inc(I);
    end;
end;

function StrPasW(const A: PWideChar): WideString;
var
  I, L : Integer;
begin
  L := StrLenW(A);
  SetLength(Result, L);
  if L = 0 then
    exit;
  I := 0;
  while I < L do
    begin
      Result[I + 1] := A[I];
      Inc(I);
    end;
end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF ANSISTRSYSUTILS_SELFTEST}
{$ASSERTIONS ON}
procedure SelfTest;
var A : Integer;
begin
  Assert(not TryStrToIntA('', A));
  Assert(not TryStrToIntA('X', A));
  Assert(TryStrToIntA('0', A));
  Assert(A = 0);
  Assert(TryStrToIntA('-123', A));
  Assert(A = -123);

  Assert(TryStrToIntW('-123', A));
  Assert(A = -123);

  Assert(StrToIntA('1234567890') = 1234567890);
  Assert(StrToIntDefA('0123', 0) = 123);
  Assert(StrToIntDefA('', -1) = -1);
  Assert(StrToIntDefA('X', -1) = -1);

  Assert(StrToInt64A('1234567890') = 1234567890);
  Assert(StrToInt64DefA('0123', 0) = 123);

  Assert(StrToInt64W('123456789012345') = 123456789012345);

  Assert(IntToStrA(0) = '0');
  Assert(IntToStrA(-123) = '-123');
  Assert(IntToStrA(123) = '123');

  Assert(IntToStrW(0) = '0');
  Assert(IntToStrW(-1234567890) = '-1234567890');
  Assert(IntToStrW(1234567890) = '1234567890');

  Assert(LongWordToHexA(0, 0, True) = '0');
  Assert(LongWordToHexA(0, 4, True) = '0000');
  Assert(LongWordToHexA($1234ABCD, 0, False) = '1234ABCD');
  Assert(LongWordToHexA($1234ABCD, 0, True) = '1234abcd');
  Assert(LongWordToHexA($A5, 4, True) = '00a5');
  Assert(LongWordToHexA($1234, 2, True) = '1234');

  Assert(LongWordToHexW($1234ABCD, 0, True) = '1234abcd');

  Assert(SameTextA('', ''));
  Assert(SameTextA('ABC123', 'ABC123'));
  Assert(SameTextA('ABC123', 'aBc123'));
  Assert(not SameTextA('A', 'AA'));

  Assert(LowerCaseA('') = '');
  Assert(LowerCaseA('ABC123') = 'abc123');
  Assert(LowerCaseA('AbC123') = 'abc123');
  Assert(LowerCaseA('x') = 'x');

  Assert(UpperCaseA('') = '');
  Assert(UpperCaseA('ABC123') = 'ABC123');
  Assert(UpperCaseA('aBc123') = 'ABC123');
  Assert(UpperCaseA('X') = 'X');

  Assert(StrLenA(nil) = 0);
  Assert(StrLenA('') = 0);
  Assert(StrLenA('abc') = 3);

  Assert(StrLenW(nil) = 0);
  Assert(StrLenW('') = 0);
  Assert(StrLenW('abc') = 3);

  Assert(StrPasA(nil) = '');
  Assert(StrPasA('abc') = 'abc');

  Assert(StrPasW(nil) = '');
  Assert(StrPasW('abc') = 'abc');
end;
{$ENDIF}



end.

