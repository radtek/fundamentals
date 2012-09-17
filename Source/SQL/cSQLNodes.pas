{******************************************************************************}
(*                                                                            *)
(*    Library:       Fundamentals SQL                                         *)
(*    Description:   SQL nodes.                                               *)
(*    Version:       1.05                                                     *)
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
(*    2003/07/29  1.01  Split into seperate units.                            *)
(*    2005/03/28  1.02  Revision.                                             *)
(*    2005/04/08  1.03  Improvements.                                         *)
(*    2009/11/14  1.04  TextOutputStructure and Iterate.                      *)
(*    2009/11/27  1.05  Change SearchCondition's parent to ValueExpression    *)
(*                      to match Sql99 changes.                               *)
(*                                                                            *)
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLNodes;

interface

uses
  { System }
  SysUtils,

  { SQL }
  cSQLUtils,
  cSQLStructs,
  cSQLDatabase;



{                                                                              }
{ ASqlNode                                                                     }
{   Base class for SQL nodes.                                                  }
{                                                                              }
type
  TSqlNodeIterateProc = procedure (const Parent, Item: TObject) of object;
  ASqlNode = class
  public
    // Text Output
    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); virtual;
    procedure TextOutputStructure(const Output: TSqlTextOutput); virtual;
    procedure TextOutputSql(const Output: TSqlTextOutput); virtual;

    // Iterate
    procedure Iterate(const Proc: TSqlNodeIterateProc); virtual;
  end;



{                                                                              }
{ ASqlValueExpression                                                          }
{   Base class for SQL Value Expressions.                                      }
{   IsLiteral returns True if this value expression resolves to a literal      }
{   value.                                                                     }
{   Evaluate returns an SQL Literal for this value expression applied to the   }
{   given cursor. The SQL Literal is reference counted and a reference is      }
{   added for the caller (caller must release reference).                      }
{                                                                              }
type
  ASqlValueExpression = class(ASqlNode)
  public
    // Syntactic
    function  IsLiteral: Boolean; virtual;
    function  Simplify: ASqlValueExpression; virtual;

    // Evaluate
    function  GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel; virtual;

    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); virtual;

    function  Evaluate(const Database: ASqlDatabase;
              const Cursor: ASqlCursor;
              const Scope: ASqlScope): ASqlLiteral; overload; virtual;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor;
              const Scope: ASqlScope): ASqlLiteral; overload; virtual;

    function  EvaluateAsString(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor;
              const Scope: ASqlScope; const Default: AnsiString = ''): AnsiString; virtual;
    function  EvaluateAsInteger(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor;
              const Scope: ASqlScope; const Default: Int64 = 0): Int64; virtual;
    function  EvaluateAsBoolean(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor;
              const Scope: ASqlScope; const Default: Boolean = False): Boolean; virtual;
  end;
  ESqlValueExpression = class(Exception);
  ASqlValueExpressionArray = Array of ASqlValueExpression;

function SqlEvaluateAsString(const ValueExpr: ASqlValueExpression;
         const Engine: ASqlDatabaseEngine; const Cursor: ASqlCursor;
         const Scope: ASqlScope; const Default: AnsiString = ''): AnsiString;



{                                                                              }
{ ASqlSearchCondition                                                          }
{   Base class for SQL Search Conditions.                                      }
{   Match returns True if the condition matches the values from the given      }
{   cursor.                                                                    }
{   FilterCursor returns a SQL Cursor that filters the given cursor on this    }
{   search condition.                                                          }
{                                                                              }
type
  ASqlSearchCondition = class(ASqlValueExpression)
  public
    // Syntactic
    function  Simplify: ASqlSearchCondition; reintroduce; overload; virtual;

    // Evaluate
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor;
              const Scope: ASqlScope): ASqlLiteral; override;

    // Match
    function  Match(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; overload; virtual;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; overload; virtual;

    function  FilterCursor(const Database: ASqlDatabase;
              const Cursor: ASqlCursor): ASqlCursor; overload; virtual;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; overload; virtual;
  end;



{                                                                              }
{ ASqlQueryExpression                                                          }
{   Base class for SQL Query Expressions.                                      }
{   GetCursor returns an SQL Cursor (caller frees).                            }
{                                                                              }
type
  ASqlQueryExpression = class(ASqlNode)
  public
    // Syntactic
    function  Simplify: ASqlQueryExpression; virtual;

    // Execution
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); virtual;

    function  GetCursor(const Database: ASqlDatabase;
              const Cursor: ASqlCursor;
              const Scope: ASqlScope): ASqlCursor; overload; virtual;
    function  GetCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor;
              const Scope: ASqlScope): ASqlCursor; overload; virtual;
  end;
  ASqlQueryExpressionArray = Array of ASqlQueryExpression;



{                                                                              }
{ ASqlStatement                                                                }
{   Base class for SQL Statements.                                             }
{   Execute returns an SQL Cursor (caller frees).                              }
{   Prepare must be called before every Execute.                               }
{                                                                              }
type
  ASqlStatement = class(ASqlNode)
  public
    function  GetAsStructure: AnsiString;
    function  GetAsSql: AnsiString;

    // Syntactic
    function  Simplify: ASqlStatement; virtual;

    // Execute
    procedure Prepare(const Database: ASqlDatabase;
              const Scope: ASqlScope); overload; virtual;
    procedure Prepare(const Engine: ASqlDatabaseEngine;
              const Scope: ASqlScope); overload; virtual;

    function  Execute(const Database: ASqlDatabase;
              const Scope: ASqlScope): ASqlCursor; overload; virtual;
    function  Execute(const Engine: ASqlDatabaseEngine;
              const Scope: ASqlScope): ASqlCursor; overload; virtual;

    procedure ExecuteNoResult(const Database: ASqlDatabase;
              const Scope: ASqlScope); overload;
    procedure ExecuteNoResult(const Engine: ASqlDatabaseEngine;
              const Scope: ASqlScope); overload;
  end;
  ASqlStatementArray = Array of ASqlStatement;
  ESqlStatement = class(Exception);



implementation

uses
  { Fundamentals }
  cUtils,

  { SQL }
  cSQLDataTypes;



{                                                                              }
{ ASqlNode                                                                     }
{                                                                              }
procedure ASqlNode.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
end;

procedure ASqlNode.TextOutputStructure(const Output: TSqlTextOutput);
begin
  Output.StructureName(ClassToSqlStructureName(self.ClassType));
  Output.StructureParamBegin;
  TextOutputStructureParameters(Output);
  Output.StructureParamEnd;
end;

procedure ASqlNode.TextOutputSql(const Output: TSqlTextOutput);
begin
  TextOutputStructure(Output);
end;

procedure ASqlNode.Iterate(const Proc: TSqlNodeIterateProc);
begin
end;



{                                                                              }
{ ASqlValueExpression                                                          }
{                                                                              }
function ASqlValueExpression.IsLiteral: Boolean;
begin
  Result := False;
end;

function ASqlValueExpression.Simplify: ASqlValueExpression;
begin
  Result := self;
end;

function ASqlValueExpression.GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel;
begin
  Result := sglAny;
end;

procedure ASqlValueExpression.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
end;

function ASqlValueExpression.Evaluate(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  raise ESqlError.CreateFmt('%s: Evaluate not implemented', [ClassToSqlStructureName(self.ClassType)]);
end;

function ASqlValueExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var Database : ASqlDatabase;
begin
  if Assigned(Engine) then
    Database := Engine.CurrentDatabase
  else
    Database := nil;
  Result := Evaluate(Database, Cursor, Scope);
end;

function ASqlValueExpression.EvaluateAsString(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope; const Default: AnsiString): AnsiString;
var R : ASqlLiteral;
begin
  R := Evaluate(Engine, Cursor, Scope);
  if not Assigned(R) then
    Result := Default
  else
    try
      Result := R.AsString;
    finally
      R.ReleaseReference;
    end;
end;

function ASqlValueExpression.EvaluateAsInteger(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope; const Default: Int64): Int64;
var R : ASqlLiteral;
begin
  R := Evaluate(Engine, Cursor, Scope);
  if not Assigned(R) then
    Result := Default
  else
    try
      Result := R.AsInteger;
    finally
      R.ReleaseReference;
    end;
end;

function ASqlValueExpression.EvaluateAsBoolean(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope; const Default: Boolean): Boolean;
var R : ASqlLiteral;
begin
  R := Evaluate(Engine, Cursor, Scope);
  if not Assigned(R) then
    Result := Default
  else
    try
      Result := R.AsBoolean = sbvTrue;
    finally
      R.ReleaseReference;
    end;
end;

function SqlEvaluateAsString(const ValueExpr: ASqlValueExpression;
    const Engine: ASqlDatabaseEngine; const Cursor: ASqlCursor;
    const Scope: ASqlScope; const Default: AnsiString): AnsiString;
begin
  if not Assigned(ValueExpr) then
    Result := Default
  else
    Result := ValueExpr.EvaluateAsString(Engine, Cursor, Scope, Default);
end;



{                                                                              }
{ ASqlSearchCondition                                                          }
{                                                                              }
function ASqlSearchCondition.Simplify: ASqlSearchCondition;
begin
  Result := self;
end;

function ASqlSearchCondition.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor;
    const Scope: ASqlScope): ASqlLiteral;
var M : Boolean;
    B : TSqlBooleanValue;
begin
  M := Match(Engine, Cursor, Scope);
  Result := TSqlBoolean.Create();
end;

function ASqlSearchCondition.Match(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
begin
  raise ESqlError.CreateFmt('%s: Match not implemented', [ClassToSqlStructureName(self.ClassType)]);
end;

function ASqlSearchCondition.Match(const Engine: ASqlDatabaseEngine;
  const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
var Database : ASqlDatabase;
begin
  if Assigned(Engine) then
    Database := Engine.CurrentDatabase
  else
    Database := nil;
  Result := Match(Database, Cursor, Scope);
end;

function ASqlSearchCondition.FilterCursor(const Database: ASqlDatabase;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  Result := nil;
end;

function ASqlSearchCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
var Database : ASqlDatabase;
begin
  if Assigned(Engine) then
    Database := Engine.CurrentDatabase
  else
    Database := nil;
  Result := FilterCursor(Database, Cursor);
end;



{                                                                              }
{ ASqlQueryExpression                                                          }
{                                                                              }
function ASqlQueryExpression.Simplify: ASqlQueryExpression;
begin
  Result := self;
end;

procedure ASqlQueryExpression.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
end;

function ASqlQueryExpression.GetCursor(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
begin
  Result := nil;
end;

function ASqlQueryExpression.GetCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
var Database : ASqlDatabase;
begin
  if Assigned(Engine) then
    Database := Engine.CurrentDatabase
  else
    Database := nil;
  Result := GetCursor(Database, Cursor, Scope);
end;



{                                                                              }
{ ASqlStatement                                                                }
{                                                                              }
function ASqlStatement.GetAsStructure: AnsiString;
var O : TSqlTextOutput;
begin
  O := TSqlTextOutput.Create;
  try
    TextOutputStructure(O);
    Result := O.GetAsString;
  finally
    O.Free;
  end;
end;

function ASqlStatement.GetAsSql: AnsiString;
var O : TSqlTextOutput;
begin
  O := TSqlTextOutput.Create;
  try
    TextOutputSql(O);
    Result := O.GetAsString;
  finally
    O.Free;
  end;
end;

function ASqlStatement.Simplify: ASqlStatement;
begin
  Result := self;
end;

procedure ASqlStatement.Prepare(const Database: ASqlDatabase; const Scope: ASqlScope);
begin
end;

procedure ASqlStatement.Prepare(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope);
var Database : ASqlDatabase;
begin
  if Assigned(Engine) then
    Database := Engine.CurrentDatabase
  else
    Database := nil;
  Prepare(Database, Scope);
end;

function ASqlStatement.Execute(const Database: ASqlDatabase; const Scope: ASqlScope): ASqlCursor;
begin
  raise ESqlStatement.CreateFmt('%s: Execute not implemented', [ClassToSqlStructureName(self.ClassType)]);
end;

function ASqlStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var Database : ASqlDatabase;
begin
  if Assigned(Engine) then
    Database := Engine.CurrentDatabase
  else
    Database := nil;
  Result := Execute(Database, Scope);
end;

procedure ASqlStatement.ExecuteNoResult(const Database: ASqlDatabase; const Scope: ASqlScope);
begin
  Execute(Database, Scope).Free;
end;

procedure ASqlStatement.ExecuteNoResult(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope);
begin
  Execute(Engine, Scope).Free;
end;



end.

