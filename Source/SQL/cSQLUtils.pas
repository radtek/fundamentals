{******************************************************************************}
(*                                                                            *)
(*    Library:       Fundamentals SQL                                         *)
(*    Description:   SQL utilities.                                           *)
(*    Version:       1.01                                                     *)
(*                                                                            *)
(*  Copyright (c) 2003-2011 by David J Butler.                                *)
(*  All rights reserved.                                                      *)
(*  E-mail: fundamentals.library@gmail.com                                    *)
(*                                                                            *)
(*  DUAL LICENSE                                                              *)
(*                                                                            *)
(*  This source code is released under a dual license:                        *)
(*                                                                            *)
(*      1.  The GNU General Public License (GPL)                              *)
(*      2.  Commercial license                                                *)
(*                                                                            *)
(*  By using this source code in your application (directly or indirectly,    *)
(*  statically or dynamically linked) your application is subject to this     *)
(*  dual license.                                                             *)
(*                                                                            *)
(*  If you choose the GPL, your application is also subject to the GPL.       *)
(*  You are required to release the source code of your application           *)
(*  publicly when you distribute it. Distribution includes giving it away     *)
(*  or using it in a commercial environment. To distribute an application     *)
(*  under the GPL it must not use any non open-source components.             *)
(*                                                                            *)
(*  If you do not wish your application to be bound by the GPL, you can       *)
(*  acquire a commercial license from the author.                             *)
(*                                                                            *)
(*  GPL LICENSE                                                               *)
(*                                                                            *)
(*  This program is free software: you can redistribute it and/or modify      *)
(*  it under the terms of the GNU General Public License as published by      *)
(*  the Free Software Foundation, either version 3 of the License, or         *)
(*  (at your option) any later version.                                       *)
(*                                                                            *)
(*  This program is distributed in the hope that it will be useful,           *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of            *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *)
(*  GNU General Public License for more details.                              *)
(*                                                                            *)
(*  For the full terms of the GPL, see:                                       *)
(*                                                                            *)
(*        http://www.gnu.org/licenses/                                        *)
(*    or  http://opensource.org/licenses/GPL-3.0                              *)
(*                                                                            *)
(*  Revision history:                                                         *)
(*    2003/07/12  1.00  Initial version.                                      *)
(*    2009/10/17  1.01  Development.                                          *)
(*                                                                            *)
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLUtils;

interface

uses
  { System }
  SysUtils;



{                                                                              }
{ SQL types                                                                    }
{                                                                              }
type
  TSqlSetQuantifier = (
      ssqUndefined,
      ssqNone,
      ssqDistinct,
      ssqAll);

  TSqlComputationalOperation = (
      scmUndefined,
      scmAVG,
      scmMAX,
      scmMIN,
      scmSUM,
      scmEVERY,
      scmANY,
      scmSOME,
      scmCOUNT,
      scmSTDDEV_POP,
      scmSTDDEV_SAMP,
      scmVAR_SAMP,
      scmVAR_POP,
      scmCOLLECT,
      scmFUSION,
      scmINTERSECTION);

  TSqlSetFunctionType = TSqlComputationalOperation;

  TSqlComparisonOperator = (
      scoUndefined,
      scoEqual,
      scoNotEqual,
      scoLess,
      scoGreater,
      scoLessOrEqual,
      scoGreaterOrEqual);

  TSqlComparisonQuantifier = (
      scqUndefined,
      scqAll,
      scqSome,
      scqAny);

  TSqlNumericOperator = (
      snoUndefined,
      snoAdd,
      snoSubtract,
      snoMultiply,
      snoDivide,
      snoPower);

  TSqlIsolationLevel = (
      silUndefined,
      silReadUncommitted,
      silReadCommitted,
      silRepeatableRead,
      silSerializable);

  TSqlTransactionAccessMode = (
      staUndefined,
      staReadOnly,
      staReadWrite);

  TSqlOrderSpecification = (
      sosUndefined,
      sosAscending,
      sosDescending);

  TSqlGroupLevel = (
      sglInvalid,
      sglAny,
      sglGrouped,
      sglCursor,
      sglUngrouped);

  TSqlDropBehavior = (
      sdbUndefined,
      sdbCascade,
      sdbRestrict);

  TSqlTableScope = (
      stsUndefined,
      stsGlobal,
      stsLocal);

  TSqlTableCommitAction = (
      stcUndefined,
      stcDeleteRows,
      stcPreserveRows);

  TSqlConstraintCheckTime = (
      sccUndefined,
      sccInitiallyDeferred,
      sccInitiallyImmediate);

  TSqlScopeOption = (
      ssoUndefined,
      ssoGlobal,
      ssoLocal);

  TSqlLevelOfIsolation = (
      sliUndefined,
      sliReadUncommitted,
      sliReadCommitted,
      sliRepeatableRead,
      sliSerializable);

  TSqlTruthValue = (
      stvUndefined,
      stvTrue,
      stvFalse,
      stvUnknown);

  TSqlTimeZoneField = (
      stzUndefined,
      stzHour,
      stzMinute);

  TSqlDateTimeField = (
      sdfUndefined,
      sdfYear,
      sdfMonth,
      sdfDay,
      sdfHour,
      sdfMinute,
      sdfSecond);

  TSqlParameterMode = (
      spmUndefined,
      spmIn,
      spmOut,
      spmInOut);


    
{                                                                              }
{ SQL types helper functions                                                   }
{                                                                              }
function  SqlComparisonOperatorToString(const Operator: TSqlComparisonOperator): String;
function  SqlNumericOperatorToString(const Operator: TSqlNumericOperator): String;



{                                                                              }
{ SQL error                                                                    }
{                                                                              }
type
  ESqlError = class(Exception);



{                                                                              }
{ SQL pattern matching                                                         }
{   Matches SQL LIKE patterns.                                                 } 
{                                                                              }
function SqlMatchPattern(const M, S: AnsiString): Boolean;



{                                                                              }
{ SQL structure helper functions                                               }
{                                                                              }
function ClassToSqlStructureName(const AClass: TClass): AnsiString;



implementation

uses
  { Fundamentals }
  cStrings;



{                                                                              }
{ SqlComparisonOperatorToString                                                }
{                                                                              }
function SqlComparisonOperatorToString(const Operator: TSqlComparisonOperator): String;
begin
  case Operator of
    scoUndefined      : Result := '';
    scoEqual          : Result := '=';
    scoNotEqual       : Result := '<>';
    scoLess           : Result := '<';
    scoGreater        : Result := '>';
    scoLessOrEqual    : Result := '<=';
    scoGreaterOrEqual : Result := '>=';
  else
    Result := '';
  end;
end;

function SqlNumericOperatorToString(const Operator: TSqlNumericOperator): String;
begin
  case Operator of
    snoUndefined : Result := '';
    snoAdd       : Result := '+';
    snoSubtract  : Result := '-';
    snoMultiply  : Result := '*';
    snoDivide    : Result := '/';
    snoPower     : Result := '**';
  else
    Result := '';
  end;
end;



{                                                                              }
{ MatchPattern                                                                 }
{   Taken and adapted from Delphi Fundamentals by David J Butler.              }
{   Based on MatchPattern from a Delphi 3000 article by Paramjeet Reen         }
{   http://www.delphi3000.com/articles/article_1561.asp.                       }
{                                                                              }
function SqlMatchPatternZ(M, S: PAnsiChar): Boolean;

  function EscapedChar(const C: AnsiChar): AnsiChar;
  begin
    case C of
      'b' : Result := asciiBS;
      'e' : Result := asciiESC;
      'f' : Result := asciiFF;
      'n' : Result := asciiLF;
      'r' : Result := asciiCR;
      't' : Result := asciiHT;
      'v' : Result := asciiVT;
      else Result := C;
    end;
  end;

var A, C, D : AnsiChar;
    N       : Boolean;
begin
  repeat
    case M^ of
      #0 : // end of pattern
        begin
          Result := S^ = #0;
          exit;
        end;
      '_' : // match one
        if S^ = #0 then
          begin
            Result := False;
            exit;
          end else
          begin
            Inc(M);
            Inc(S);
          end;
      '%' :
        begin
          Inc(M);
          if M^ = #0 then // always match at end of mask
            begin
              Result := True;
              exit;
            end else
            while S^ <> #0 do
              if SqlMatchPatternZ(M, S) then
                begin
                  Result := True;
                  Exit;
                end else
                Inc(S);
          end;
      '[' : // character class
        begin
          A := S^;
          Inc(M);
          C := M^;
          N := C = '^';
          Result := N;
          while C <> ']' do
            begin
              if C = #0 then
                begin
                  Result := False;
                  exit;
                end;
              Inc(M);
              if C = '\' then // escaped character
                begin
                  C := M^;
                  if C = #0 then
                    begin
                      Result := False;
                      exit;
                    end;
                  C := EscapedChar(C);
                  Inc(M);
                end;
              D := M^;
              if D = '-' then // match range
                begin
                  Inc(M);
                  D := M^;
                  if D = #0 then
                    begin
                      Result := False;
                      exit;
                    end;
                  if D = '\' then // escaped character
                    begin
                      Inc(M);
                      D := M^;
                      if D = #0 then
                        begin
                          Result := False;
                          exit;
                        end;
                      D := EscapedChar(D);
                      Inc(M);
                    end;
                  if (A >= C) and (A <= D) then
                    begin
                      Result := not N;
                      break;
                    end;
                  Inc(M);
                  C := M^;
                end else
                begin // match single character
                  if A = C then
                    begin
                      Result := not N;
                      break;
                    end;
                  C := D;
                end;
            end;
          if not Result then
            exit;
          Inc(S);
          // Locate closing bracket
          while M^ <> ']' do
            if M^ = #0 then
              begin
                Result := False;
                exit;
              end else
              Inc(M);
          Inc(M);
        end;
    else // single character match
      if M^ <> S^ then
        begin
          Result := False;
          exit;
        end else
        begin
          Inc(M);
          Inc(S);
        end;
    end;
  until False;
end;

function SqlMatchPattern(const M, S: AnsiString): Boolean;
begin
  Result := SqlMatchPatternZ(PAnsiChar(M), PAnsiChar(S));
end;



{                                                                              }
{ SQL structure helper functions                                               }
{                                                                              }
function ClassToSqlStructureName(const AClass: TClass): AnsiString;
var S : String;
    I : Integer;
begin
  S := AClass.ClassName;
  Assert(S <> '');
  if Copy(S, 1, 1) = 'T' then
    Delete(S, 1, 1);
  if Copy(S, 1, 3) = 'Sql' then
    Delete(S, 1, 3);
  I := 2;
  while I <= Length(S) do
    if S[I] in ['A'..'Z'] then
      begin
        Insert(' ', S, I);
        Inc(I, 2);
      end
    else
      Inc(I);
  Result := S;
end;



end.

