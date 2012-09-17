{******************************************************************************}
(*                                                                            *)
(*    Library:       Fundamentals SQL                                         *)
(*    Description:   SQL nodes: Conditions                                    *)
(*    Version:       0.07                                                     *)
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
(*    2003/07/12  0.01  Initial version.                                      *)
(*    2003/07/29  0.02  Created cSQLNodesConditions unit.                     *)
(*    2003/07/31  0.03  Implementations.                                      *)
(*    2005/03/28  0.04  Revision.                                             *)
(*    2005/04/02  0.05  Development.                                          *)
(*    2005/04/09  0.06  Development.                                          *)
(*    2009/11/14  0.07  TSqlExistsStructureCondition.                         *)
(*                                                                            *)
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLNodesConditions;

interface

uses
  { SQL }
  cSQLUtils,
  cSQLStructs,
  cSQLDatabase,
  cSQLNodes;



{                                                                              }
{ ASqlBinaryOperatorCondition                                                  }
{   Base class for Binary Operator Search Conditions.                          }
{                                                                              }
type
  ASqlBinaryOperatorCondition = class(ASqlSearchCondition)
  protected
    FLeft  : ASqlValueExpression;
    FRight : ASqlValueExpression;

  public
    constructor CreateEx(const Left, Right: ASqlValueExpression);
    destructor Destroy; override;

    property  Left: ASqlValueExpression read FLeft write FLeft;
    property  Right: ASqlValueExpression read FRight write FRight;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlSearchCondition; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor;
              const Scope: ASqlScope); override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ ASqlBinaryCondition                                                          }
{   Base class for SQL Binary Search Conditions.                               }
{                                                                              }
type
  ASqlBinaryCondition = class(ASqlSearchCondition)
  protected
    FLeft  : ASqlSearchCondition;
    FRight : ASqlSearchCondition;

  public
    constructor CreateEx(const Left, Right: ASqlSearchCondition);
    destructor Destroy; override;

    property  Left: ASqlSearchCondition read FLeft write FLeft;
    property  Right: ASqlSearchCondition read FRight write FRight;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlSearchCondition; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ ASqlQueryCondition                                                           }
{   Base class for Search Condition based on a Query Expression.               }
{                                                                              }
type
  ASqlQueryCondition = class(ASqlSearchCondition)
  protected
    FSubQuery : ASqlQueryExpression;

  public
    constructor CreateEx(const SubQuery: ASqlQueryExpression);
    destructor Destroy; override;

    property  SubQuery: ASqlQueryExpression read FSubQuery write FSubQuery;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlSearchCondition; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
  end;



{                                                                              }
{ TSqlLiteralCondition                                                         }
{   Literal (True or False) Search Condition.                                  }
{                                                                              }
type
  TSqlLiteralCondition = class(ASqlSearchCondition)
  protected
    FValue : Boolean;

  public
    constructor CreateEx(const Value: Boolean);

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlComparisonCondition                                                      }
{   SQL Comparison Search Condition.                                           }
{                                                                              }
type
  TSqlComparisonCondition = class(ASqlBinaryOperatorCondition)
  protected
    FComparisonOperator : TSqlComparisonOperator;

  public
    constructor CreateEx(const ComparisonOperator: TSqlComparisonOperator;
                const Left, Right: ASqlValueExpression);

    property  ComparisonOperator: TSqlComparisonOperator read FComparisonOperator write FComparisonOperator;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Simplify: ASqlSearchCondition; override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlQuantifiedComparisonPredicate                                            }
{                                                                              }
type
  TSqlQuantifiedComparisonPredicate = class(ASqlSearchCondition)
  protected
    FCompOperator   : TSqlComparisonOperator;
    FCompQuantifier : TSqlComparisonQuantifier;
    FLeft           : ASqlValueExpression;
    FRight          : ASqlValueExpression;
    FQuery          : ASqlQueryExpression;

  public
    property  CompOperator: TSqlComparisonOperator read FCompOperator write FCompOperator;
    property  CompQuantifier: TSqlComparisonQuantifier read FCompQuantifier write FCompQuantifier;
    property  Left: ASqlValueExpression read FLeft write FLeft;
    property  Right: ASqlValueExpression read FRight write FRight;
    property  Query: ASqlQueryExpression read FQuery write FQuery;
  end;



{                                                                              }
{ TSqlLogicalOrCondition                                                       }
{   SQL Logical OR Search Condition.                                           }
{                                                                              }
type
  TSqlLogicalOrCondition = class(ASqlBinaryCondition)
  public
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
  end;



{                                                                              }
{ TSqlLogicalAndCondition                                                      }
{   SQL Logical AND Search Condition.                                          }
{                                                                              }
type
  TSqlLogicalAndCondition = class(ASqlBinaryCondition)
  public
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlLogicalNotCondition                                                      }
{   SQL Logical NOT Search Condition.                                          }
{                                                                              }
type
  TSqlLogicalNotCondition = class(ASqlSearchCondition)
  protected
    FOperand : ASqlSearchCondition;

  public
    constructor CreateEx(const Operand: ASqlSearchCondition);
    destructor Destroy; override;

    property  Operand: ASqlSearchCondition read FOperand write FOperand;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlSearchCondition; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlExistsCondition                                                          }
{   SQL EXISTS Search Condition.                                               }
{                                                                              }
type
  TSqlExistsCondition = class(ASqlQueryCondition)
  public
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlExistsStructureCondition                                                 }
{                                                                              }
type
  TSqlExistsStructureType = (
    sesUndefined,
    sesTable,
    sesIndex,
    sesProcedure,
    sesDatabase,
    sesView);

  TSqlExistsStructureCondition = class(ASqlSearchCondition)
  protected
    FStructureType : TSqlExistsStructureType;
    FIdentifier    : AnsiString;

    function  StructureTypeKeyword: AnsiString;

  public
    constructor CreateEx(const StructureType: TSqlExistsStructureType;
                const Identifier: AnsiString);

    property  StructureType: TSqlExistsStructureType read FStructureType write FStructureType;
    property  Identifier: AnsiString read FIdentifier write FIdentifier;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlUniqueCondition                                                          }
{   SQL UNIQUE Search Condition.                                               }
{                                                                              }
type
  TSqlUniqueCondition = class(ASqlQueryCondition)
  public
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlNullCondition                                                            }
{   SQL NULL Search Condition.                                                 }
{                                                                              }
type
  TSqlNullCondition = class(ASqlSearchCondition)
  protected
    FValueExpr : ASqlValueExpression;
    FNotNull   : Boolean;

  public
    constructor CreateEx(const ValueExpr: ASqlValueExpression;
                const NotNull: Boolean);
    destructor Destroy; override;

    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;
    property  NotNull: Boolean read FNotNull write FNotNull;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlSearchCondition; override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlInCondition                                                              }
{   SQL IN Search Condition.                                                   }
{                                                                              }
type
  TSqlInCondition = class(ASqlSearchCondition)
  protected
    FValueExpr : ASqlValueExpression;
    FQueryExpr : ASqlQueryExpression;
    FValueList : ASqlValueExpressionArray;
    FNotIn     : Boolean;

  public
    constructor CreateEx(const ValueExpr: ASqlValueExpression;
                const QueryExpr: ASqlQueryExpression;
                const ValueList: ASqlValueExpressionArray;
                const NotIn: Boolean);
    destructor Destroy; override;

    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;
    property  QueryExpr: ASqlQueryExpression read FQueryExpr write FQueryExpr;
    property  ValueList: ASqlValueExpressionArray read FValueList write FValueList;
    property  NotIn: Boolean read FNotIn write FNotIn;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlSearchCondition; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlLikeCondition                                                            }
{   SQL LIKE Search Condition.                                                 }
{                                                                              }
type
  TSqlLikeCondition = class(ASqlSearchCondition)
  protected
    FMatchValue : ASqlValueExpression;
    FPattern    : ASqlValueExpression;
    FEscapeChar : ASqlValueExpression;
    FNotLike    : Boolean;

  public
    constructor CreateEx(const MatchValue, Pattern, EscapeChar: ASqlValueExpression;
                const NotLike: Boolean);
    destructor Destroy; override;

    property  MatchValue: ASqlValueExpression read FMatchValue write FMatchValue;
    property  Pattern: ASqlValueExpression read FPattern write FPattern;
    property  EscapeChar: ASqlValueExpression read FEscapeChar write FEscapeChar;
    property  NotLike: Boolean read FNotLike write FNotLike;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlSearchCondition; override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
    function  FilterCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlBetweenPredicate                                                         }
{   SQL BETWEEN Predicate.                                                     }
{                                                                              }
type
  TSqlBetweenPredicate = class(ASqlSearchCondition)
  protected
    FNotBetween : Boolean;
    FExpr       : ASqlValueExpression;
    FLowValue   : ASqlValueExpression;
    FHighValue  : ASqlValueExpression;

  public
    destructor Destroy; override;

    property  NotBetween: Boolean read FNotBetween write FNotBetween;
    property  Expr: ASqlValueExpression read FExpr write FExpr;
    property  LowValue: ASqlValueExpression read FLowValue write FLowValue;
    property  HighValue: ASqlValueExpression read FHighValue write FHighValue;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
  end;



{                                                                              }
{ TSqlDistinctPredicate                                                        }
{                                                                              }
type
  TSqlDistinctPredicate = class(ASqlSearchCondition)
  protected
    FExpr1, FExpr2 : ASqlValueExpression;

  public
    constructor CreateEx(const Expr1, Expr2: ASqlValueExpression);
    destructor Destroy; override;
  end;



{                                                                              }
{ TSqlMatchPredicate                                                           }
{                                                                              }
type
  TSqlMatchPredicateType = (smpUndefined, smpPartial, smpFull);
  TSqlMatchPredicate = class(ASqlSearchCondition)
  protected
    FExpr          : ASqlValueExpression;
    FTableSubQuery : ASqlQueryExpression;
    FUnique        : Boolean;
    FMatchType     : TSqlMatchPredicateType;

  public
    destructor Destroy; override;

    property  Expr: ASqlValueExpression read FExpr write FExpr;
    property  TableSubQuery: ASqlQueryExpression read FTableSubQuery write FTableSubQuery;
    property  Unique: Boolean read FUnique write FUnique;
    property  MatchType: TSqlMatchPredicateType read FMatchType write FMatchType;
  end;



{                                                                              }
{ TSqlOverlapsPredicate                                                        }
{                                                                              }
type
  TSqlOverlapsPredicate = class(ASqlSearchCondition)
  protected
    FExpr1 : ASqlValueExpression;
    FExpr2 : ASqlValueExpression;

  public
    constructor CreateEx(const Expr1, Expr2: ASqlValueExpression);
    destructor Destroy; override;

    property  Expr1: ASqlValueExpression read FExpr1 write FExpr1;
    property  Expr2: ASqlValueExpression read FExpr2 write FExpr2;
  end;



{                                                                              }
{ TSqlBooleanTest                                                              }
{                                                                              }
type
  TSqlBooleanTest = class(ASqlSearchCondition)
  protected
    FCondition  : ASqlSearchCondition;
    FNotValue   : Boolean;
    FTruthValue : TSqlTruthValue;

  public
    destructor Destroy; override;

    property  Condition: ASqlSearchCondition read FCondition write FCondition;
    property  NotValue: Boolean read FNotValue write FNotValue;
    property  TruthValue: TSqlTruthValue read FTruthValue write FTruthValue;

    function  Match(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean; override;
  end;



implementation

uses
  { System }
  SysUtils,

  { Fundamentals }
  cUtils,

  { SQL }
  cSQLLexer,
  cSQLNodesValues;



{                                                                              }
{ TSqlConditionFilterCursor                                                    }
{                                                                              }
type
  TSqlConditionFilterCursor = class(ASqlProxyCursor)
  protected
    FEngine           : ASqlDatabaseEngine;
    FCondition        : ASqlSearchCondition;
    FEof              : Boolean;
    FInverseSelection : Boolean;

    procedure SetNextRecord;

  public
    constructor Create(const Engine: ASqlDatabaseEngine; const Cursor: ASqlCursor;
                const Condition: ASqlSearchCondition);

    function  Eof: Boolean; override;
    procedure Next; override;
    function  FilterInverseSelection: ASqlCursor; override;
  end;

constructor TSqlConditionFilterCursor.Create(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Condition: ASqlSearchCondition);
begin
  inherited Create(Cursor);
  FEngine := Engine;
  FCondition := Condition;
  SetNextRecord;
end;

procedure TSqlConditionFilterCursor.SetNextRecord;
var R : Boolean;
begin
  while not FCursor.Eof do
    begin
      R := FCondition.Match(FEngine, FCursor, nil);
      R := (R and not FInverseSelection) or
           (not R and FInverseSelection);
      if R then
        exit;
      FCursor.Next;
    end;
  FEof := True;
end;

function TSqlConditionFilterCursor.Eof: Boolean;
begin
  Result := FEof;
end;

procedure TSqlConditionFilterCursor.Next;
begin
  if FEof then
    raise ESqlError.Create('Next past Eof');
  FCursor.Next;
  SetNextRecord;
end;

function TSqlConditionFilterCursor.FilterInverseSelection: ASqlCursor;
begin
  FInverseSelection := not FInverseSelection;
  Result := self;
end;



{                                                                              }
{ ASqlBinaryOperatorCondition                                                  }
{                                                                              }
constructor ASqlBinaryOperatorCondition.CreateEx(const Left, Right: ASqlValueExpression);
begin
  inherited Create;
  Assert(Assigned(Left));
  Assert(Assigned(Right));
  FLeft := Left;
  FRight := Right;
end;

destructor ASqlBinaryOperatorCondition.Destroy;
begin
  FreeAndNil(FRight);
  FreeAndNil(FLeft);
  inherited Destroy;
end;

procedure ASqlBinaryOperatorCondition.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FLeft.TextOutputStructure(Output);
  FRight.TextOutputStructure(Output);
end;

procedure ASqlBinaryOperatorCondition.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FLeft);
  FLeft.Iterate(Proc);
  Proc(self, FRight);
  FRight.Iterate(Proc);
end;

function ASqlBinaryOperatorCondition.IsLiteral: Boolean;
begin
  Result := FLeft.IsLiteral and FRight.IsLiteral;
end;

function ASqlBinaryOperatorCondition.Simplify: ASqlSearchCondition;
begin
  FLeft := FLeft.Simplify;
  FRight := FRight.Simplify;
  if IsLiteral then
    begin
      Result := TSqlLiteralCondition.CreateEx(Match(ASqlDatabaseEngine(nil), nil, nil));
      Free;
    end
  else
    Result := self;
end;

procedure ASqlBinaryOperatorCondition.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FLeft.Prepare(Database, Cursor, Scope);
  FRight.Prepare(Database, Cursor, Scope);
end;

function ASqlBinaryOperatorCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  Result := TSqlConditionFilterCursor.Create(Engine, Cursor, self);
end;



{                                                                              }
{ ASqlBinaryCondition                                                          }
{                                                                              }
constructor ASqlBinaryCondition.CreateEx(const Left, Right: ASqlSearchCondition);
begin
  inherited Create;
  Assert(Assigned(Left));
  Assert(Assigned(Right));
  FLeft := Left;
  FRight := Right;
end;

destructor ASqlBinaryCondition.Destroy;
begin
  FreeAndNil(FRight);
  FreeAndNil(FLeft);
  inherited Destroy;
end;

procedure ASqlBinaryCondition.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FLeft.TextOutputStructure(Output);
  FRight.TextOutputStructure(Output);
end;

procedure ASqlBinaryCondition.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FLeft);
  FLeft.Iterate(Proc);
  Proc(self, FRight);
  FRight.Iterate(Proc);
end;

function ASqlBinaryCondition.IsLiteral: Boolean;
begin
  Result := FLeft.IsLiteral and FRight.IsLiteral;
end;

function ASqlBinaryCondition.Simplify: ASqlSearchCondition;
begin
  FLeft := FLeft.Simplify;
  FRight := FRight.Simplify;
  if IsLiteral then
    begin
      Result := TSqlLiteralCondition.CreateEx(Match(ASqlDatabaseEngine(nil), nil, nil));
      Free;
    end
  else
    Result := self;
end;

procedure ASqlBinaryCondition.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FLeft.Prepare(Database, Cursor, Scope);
  FRight.Prepare(Database, Cursor, Scope);
end;

function ASqlBinaryCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  Result := TSqlConditionFilterCursor.Create(Engine, Cursor, self);
end;



{                                                                              }
{ TSqlLiteralCondition                                                         }
{                                                                              }
constructor TSqlLiteralCondition.CreateEx(const Value: Boolean);
begin
  inherited Create;
  FValue := Value;
end;

procedure TSqlLiteralCondition.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  TextOutputSql(Output);
end;

procedure TSqlLiteralCondition.TextOutputSql(const Output: TSqlTextOutput);
begin
  if FValue then
    Output.Keyword(SQL_KEYWORD_TRUE)
  else
    Output.Keyword(SQL_KEYWORD_FALSE);
end;

function TSqlLiteralCondition.IsLiteral: Boolean;
begin
  Result := True;
end;

function TSqlLiteralCondition.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
begin
  Result := FValue;
end;

function TSqlLiteralCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  if FValue then
    Result := Cursor
  else
    Result := TSqlFilterAllCursor.Create(Cursor);
end;



{                                                                              }
{ TSqlComparisonCondition                                                      }
{                                                                              }
constructor TSqlComparisonCondition.CreateEx(const ComparisonOperator: TSqlComparisonOperator;
    const Left, Right: ASqlValueExpression);
begin
  inherited CreateEx(Left, Right);
  FComparisonOperator := ComparisonOperator;
end;

procedure TSqlComparisonCondition.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  Output.Symbol(SqlComparisonOperatorToString(FComparisonOperator));
  Output.Space;
  inherited TextOutputStructureParameters(Output);
end;

procedure TSqlComparisonCondition.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Symbol('(');
      FLeft.TextOutputSql(Output);
      Space;
      Symbol(SqlComparisonOperatorToString(FComparisonOperator));
      Space;
      FRight.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function TSqlComparisonCondition.Simplify: ASqlSearchCondition;
begin
  Result := inherited Simplify;
end;

function TSqlComparisonCondition.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
var L, R : ASqlLiteral;
    C : TCompareResult;
begin
  L := FLeft.Evaluate(Engine, Cursor, Scope);
  R := FRight.Evaluate(Engine, Cursor, Scope);
  C := L.Compare(R);
  R.ReleaseReference;
  L.ReleaseReference;
  case FComparisonOperator of
    scoEqual          : Result := C = crEqual;
    scoNotEqual       : Result := C in [crLess, crGreater];
    scoLess           : Result := C = crLess;
    scoGreater        : Result := C = crGreater;
    scoLessOrEqual    : Result := C in [crLess, crEqual];
    scoGreaterOrEqual : Result := C in [crGreater, crEqual];
  else
    Result := False;
  end;
end;

function TSqlComparisonCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  if (FLeft is TSqlColumnReference) and (FRight is TSqlLiteralValue) then
    Result := Cursor.FilterOnColumnLiteralComparison(
        TSqlColumnReference(FLeft).ColumnName, FComparisonOperator,
        TSqlLiteralValue(FRight).Value)
  else
    Result := TSqlConditionFilterCursor.Create(Engine, Cursor, self);
end;



{                                                                              }
{ TSqlLogicalOrCondition                                                       }
{                                                                              }
procedure TSqlLogicalOrCondition.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Symbol('(');
      FLeft.TextOutputSql(Output);
      Space;
      Keyword(SQL_KEYWORD_OR);
      Space;
      FRight.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function TSqlLogicalOrCondition.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
begin
  Result := FLeft.Match(Engine, Cursor, Scope) or
            FRight.Match(Engine, Cursor, Scope);
end;



{                                                                              }
{ TSqlLogicalAndCondition                                                      }
{                                                                              }
procedure TSqlLogicalAndCondition.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Symbol('(');
      FLeft.TextOutputSql(Output);
      Space;
      Keyword(SQL_KEYWORD_AND);
      Space;
      FRight.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function TSqlLogicalAndCondition.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
begin
  Result := FLeft.Match(Engine, Cursor, Scope) and
            FRight.Match(Engine, Cursor, Scope);
end;

function TSqlLogicalAndCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  Result := FRight.FilterCursor(Engine, FLeft.FilterCursor(Engine, Cursor));
end;



{                                                                              }
{ TSqlLogicalNotCondition                                                      }
{                                                                              }
constructor TSqlLogicalNotCondition.CreateEx(const Operand: ASqlSearchCondition);
begin
  inherited Create;
  Assert(Assigned(Operand));
  FOperand := Operand;
end;

destructor TSqlLogicalNotCondition.Destroy;
begin
  FreeAndNil(FOperand);
  inherited Destroy;
end;

procedure TSqlLogicalNotCondition.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FOperand.TextOutputStructure(Output);
end;

procedure TSqlLogicalNotCondition.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_NOT);
      Space;
      Symbol('(');
      FOperand.TextOutputSql(Output);
      Symbol(')');
    end;
end;

procedure TSqlLogicalNotCondition.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FOperand);
  FOperand.Iterate(Proc);
end;

function TSqlLogicalNotCondition.IsLiteral: Boolean;
begin
  Result := FOperand.IsLiteral;
end;

function TSqlLogicalNotCondition.Simplify: ASqlSearchCondition;
begin
  FOperand := FOperand.Simplify;
  if IsLiteral then
    begin
      Result := TSqlLiteralCondition.CreateEx(Match(nil, nil, nil));
      Free;
    end
  else
    Result := self;
end;

procedure TSqlLogicalNotCondition.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FOperand.Prepare(Database, Cursor, Scope);
end;

function TSqlLogicalNotCondition.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
begin
  Result := not FOperand.Match(Engine, Cursor, Scope);
end;

function TSqlLogicalNotCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  Result := FOperand.FilterCursor(Engine, Cursor).FilterInverseSelection;
end;



{                                                                              }
{ ASqlQueryCondition                                                           }
{                                                                              }
constructor ASqlQueryCondition.CreateEx(const SubQuery: ASqlQueryExpression);
begin
  inherited Create;
  FSubQuery := SubQuery;
end;

destructor ASqlQueryCondition.Destroy;
begin
  FreeAndNil(FSubQuery);
  inherited Destroy;
end;

procedure ASqlQueryCondition.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FSubQuery.TextOutputStructure(Output);
end;

procedure ASqlQueryCondition.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FSubQuery);
  FSubQuery.Iterate(Proc);
end;

function ASqlQueryCondition.Simplify: ASqlSearchCondition;
begin
  FSubQuery := FSubQuery.Simplify;
  Result := self;
end;

procedure ASqlQueryCondition.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FSubQuery.Prepare(Database, Cursor, Scope);
end;



{                                                                              }
{ TSqlExistsCondition                                                          }
{                                                                              }
procedure TSqlExistsCondition.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Keyword(SQL_KEYWORD_EXISTS);
  Output.Space;
  Output.Symbol('(');
  FSubQuery.TextOutputSql(Output);
  Output.Symbol(')');
end;

function TSqlExistsCondition.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
var C : ASqlCursor;
begin
  C := FSubQuery.GetCursor(Engine, Cursor, Scope);
  try
    Result := not C.Eof;
  finally
    C.Free;
  end;
end;

function TSqlExistsCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  Result := TSqlConditionFilterCursor.Create(Engine, Cursor, self);
end;



{                                                                              }
{ TSqlExistsStructureCondition                                                 }
{                                                                              }
constructor TSqlExistsStructureCondition.CreateEx(const StructureType: TSqlExistsStructureType;
    const Identifier: AnsiString);
begin
  inherited Create;
  FStructureType := StructureType;
  FIdentifier := Identifier;
end;

function TSqlExistsStructureCondition.StructureTypeKeyword: AnsiString;
begin
  case FStructureType of
    sesTable     : Result := SQL_KEYWORD_TABLE;
    sesIndex     : Result := SQL_KEYWORD_INDEX;
    sesProcedure : Result := SQL_KEYWORD_PROCEDURE;
  else
    Result := '';
  end;
end;

procedure TSqlExistsStructureCondition.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  with Output do
    begin
      Keyword(StructureTypeKeyword);
      Space;
      Identifier(FIdentifier);
    end;
end;

procedure TSqlExistsStructureCondition.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_EXISTS);
      Space;
      Keyword(StructureTypeKeyword);
      Space;
      Identifier(FIdentifier);
    end;
end;

function TSqlExistsStructureCondition.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
begin
  case FStructureType of
    sesTable     : Result := Engine.CurrentDatabase.HasTable(FIdentifier);
    sesProcedure : Result := Engine.CurrentDatabase.HasProcedure(FIdentifier);
    sesDatabase  : Result := Engine.HasDatabase(FIdentifier);
  else
    raise ESqlError.Create('Not implemented');
  end;
end;

function TSqlExistsStructureCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  Result := TSqlConditionFilterCursor.Create(Engine, Cursor, self);
end;



{                                                                              }
{ TSqlUniqueCondition                                                          }
{                                                                              }
procedure TSqlUniqueCondition.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Keyword(SQL_KEYWORD_UNIQUE);
  Output.Space;
  Output.Symbol('(');
  FSubQuery.TextOutputSql(Output);
  Output.Symbol(')');
end;

function TSqlUniqueCondition.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
begin
  Result := False;
end;

function TSqlUniqueCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  Result := TSqlConditionFilterCursor.Create(Engine, Cursor, self);
end;



{                                                                              }
{ TSqlNullCondition                                                            }
{                                                                              }
constructor TSqlNullCondition.CreateEx(const ValueExpr: ASqlValueExpression;
    const NotNull: Boolean);
begin
  inherited Create;
  FValueExpr := ValueExpr;
  FNotNull := NotNull;
end;

destructor TSqlNullCondition.Destroy;
begin
  FreeAndNil(FValueExpr);
  inherited;
end;

procedure TSqlNullCondition.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  if FNotNull then
    begin
      Output.Keyword(SQL_KEYWORD_NOT);
      Output.Space;
    end;
  FValueExpr.TextOutputStructure(Output);
end;

procedure TSqlNullCondition.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Symbol('(');
      FValueExpr.TextOutputSql(Output);
      Symbol(')');
      Space;
      Keyword(SQL_KEYWORD_IS);
      Space;
      if FNotNull then
        begin
          Keyword(SQL_KEYWORD_NOT);
          Space;
        end;
      Keyword(SQL_KEYWORD_NULL);
    end;
end;

procedure TSqlNullCondition.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FValueExpr);
  FValueExpr.Iterate(Proc);
end;

function TSqlNullCondition.Simplify: ASqlSearchCondition;
begin
  FValueExpr := FValueExpr.Simplify;
  Result := self;
end;

function TSqlNullCondition.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
var V : ASqlLiteral;
    N : Boolean;
begin
  V := FValueExpr.Evaluate(Engine, Cursor, nil);
  N := V.IsNullValue;
  V.ReleaseReference;
  Result := (FNotNull xor N);
end;

function TSqlNullCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  Result := TSqlConditionFilterCursor.Create(Engine, Cursor, self);
end;



{                                                                              }
{ TSqlInCondition                                                              }
{   SQL IN Search Condition.                                                   }
{                                                                              }
constructor TSqlInCondition.CreateEx(const ValueExpr: ASqlValueExpression;
    const QueryExpr: ASqlQueryExpression;
    const ValueList: ASqlValueExpressionArray; const NotIn: Boolean);
begin
  inherited Create;
  FValueExpr := ValueExpr;
  FQueryExpr := QueryExpr;
  FValueList := ValueList;
  FNotIn := NotIn;
end;

destructor TSqlInCondition.Destroy;
begin
  FreeAndNilObjectArray(ObjectArray(FValueList));
  FreeAndNil(FQueryExpr);
  FreeAndNil(FValueExpr);
  inherited;
end;

procedure TSqlInCondition.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  if FNotIn then
    begin
      Output.Keyword(SQL_KEYWORD_NOT);
      Output.Space;
    end;
  FValueExpr.TextOutputStructure(Output);
  if Assigned(FQueryExpr) then
    FQueryExpr.TextOutputStructure(Output);
end;

procedure TSqlInCondition.TextOutputSql(const Output: TSqlTextOutput);
var I : Integer;
begin
  with Output do
    begin
      FValueExpr.TextOutputSql(Output);
      Space;
      if FNotIn then
        begin
          Keyword(SQL_KEYWORD_NOT);
          Space;
        end;
      Keyword(SQL_KEYWORD_IN);
      Space;
      Symbol('(');
      if Assigned(FQueryExpr) then
        FQueryExpr.TextOutputSql(Output)
      else
        for I := 0 to Length(FValueList) - 1 do
          begin
            if I > 0 then
              begin
                Symbol(',');
                Space;
              end;
            FValueList[I].TextOutputSql(Output);
          end;
      Symbol(')');
    end;
end;

procedure TSqlInCondition.Iterate(const Proc: TSqlNodeIterateProc);
var I : Integer;
begin
  Proc(self, FValueExpr);
  FValueExpr.Iterate(Proc);
  if Assigned(FQueryExpr) then
    begin
      Proc(self, FQueryExpr);
      FQueryExpr.Iterate(Proc);
    end;
  for I := 0 to Length(FValueList) - 1 do
    begin
      Proc(self, FValueList[I]);
      FValueList[I].Iterate(Proc);
    end;
end;

function TSqlInCondition.Simplify: ASqlSearchCondition;
var I : Integer;
begin
  FValueExpr := FValueExpr.Simplify;
  if Assigned(FQueryExpr) then
    FQueryExpr := FQueryExpr.Simplify;
  for I := 0 to Length(FValueList) - 1 do
    FValueList[I] := FValueList[I].Simplify;
  Result := self;
end;

procedure TSqlInCondition.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
var I : Integer;
begin
  FValueExpr.Prepare(Database, Cursor, Scope);
  if Assigned(FQueryExpr) then
    FQueryExpr.Prepare(Database, Cursor, Scope);
  for I := 0 to Length(FValueList) - 1 do
    FValueList[I].Prepare(Database, Cursor, Scope);
end;

function TSqlInCondition.Match(const Engine: ASqlDatabaseEngine;
  const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
var V : ASqlLiteral;
    C : ASqlCursor;
    I : Integer;
    L : ASqlLiteral;
begin
  V := FValueExpr.Evaluate(Engine, Cursor, nil);
  if Assigned(FQueryExpr) then
    begin
      C := FQueryExpr.GetCursor(Engine, Cursor, Scope);
      while not C.Eof do
        begin
          if C.FieldByIndex[0].Value.Compare(V) = crEqual then
            begin
              Result := not FNotIn;
              C.Free;
              exit;
            end;
          C.Next;
        end;
      C.Free;
      Result := FNotIn;
      exit;
    end;
  for I := 0 to Length(FValueList) - 1 do
    begin
      L := FValueList[I].Evaluate(Engine, Cursor, nil);
      if L.Compare(V) = crEqual then
        begin
          Result := not FNotIn;
          exit;
        end;
    end;
  Result := FNotIn;
end;

function TSqlInCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
  const Cursor: ASqlCursor): ASqlCursor;
begin
  Result := TSqlConditionFilterCursor.Create(Engine, Cursor, self);
end;



{                                                                              }
{ TSqlLikeCondition                                                            }
{                                                                              }
constructor TSqlLikeCondition.CreateEx(const MatchValue, Pattern,
    EscapeChar: ASqlValueExpression; const NotLike: Boolean);
begin
  inherited Create;
  FMatchValue := MatchValue;
  FPattern := Pattern;
  FEscapeChar := EscapeChar;
  FNotLike := NotLike;
end;

destructor TSqlLikeCondition.Destroy;
begin
  FreeAndNil(FEscapeChar);
  FreeAndNil(FPattern);
  FreeAndNil(FMatchValue);
  inherited;
end;

procedure TSqlLikeCondition.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  if FNotLike then
    begin
      Output.Keyword(SQL_KEYWORD_NOT);
      Output.Space;
    end;
  FMatchValue.TextOutputStructure(Output);
  FPattern.TextOutputStructure(Output);
  if Assigned(FEscapeChar) then
    FEscapeChar.TextOutputStructure(Output);
end;

procedure TSqlLikeCondition.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      FMatchValue.TextOutputSql(Output);
      Space;
      if FNotLike then
        begin
          Keyword(SQL_KEYWORD_NOT);
          Space;
        end;
      Keyword(SQL_KEYWORD_LIKE);
      Space;
      FPattern.TextOutputSql(Output);
      if Assigned(FEscapeChar) then
        begin
          Space;
          Keyword(SQL_KEYWORD_ESCAPE);
          Space;
          FEscapeChar.TextOutputSql(Output);
        end;
    end;
end;

procedure TSqlLikeCondition.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FMatchValue);
  FMatchValue.Iterate(Proc);
  Proc(self, FPattern);
  FPattern.Iterate(Proc);
end;

function TSqlLikeCondition.Simplify: ASqlSearchCondition;
begin
  FMatchValue := FMatchValue.Simplify;
  FPattern := FPattern.Simplify;
  if Assigned(FEscapeChar) then
    FEscapeChar := FEscapeChar.Simplify;
  Result := self;
end;

function TSqlLikeCondition.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
var M, P : ASqlLiteral;
begin
  M := FMatchValue.Evaluate(Engine, Cursor, nil);
  P := FPattern.Evaluate(Engine, Cursor, nil);
  Result := SqlMatchPattern(P.AsString, M.AsString);
  P.ReleaseReference;
  M.ReleaseReference;
end;

function TSqlLikeCondition.FilterCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor): ASqlCursor;
begin
  Result := TSqlConditionFilterCursor.Create(Engine, Cursor, self);
end;



{                                                                              }
{ TSqlBetweenPredicate                                                         }
{                                                                              }
destructor TSqlBetweenPredicate.Destroy;
begin
  FreeAndNil(FHighValue);
  FreeAndNil(FLowValue);
  FreeAndNil(FExpr);
  inherited Destroy;
end;

procedure TSqlBetweenPredicate.TextOutputSql(const Output: TSqlTextOutput);
begin
  FExpr.TextOutputSql(Output);
  Output.Space;
  Output.Keyword(SQL_KEYWORD_BETWEEN);
  Output.Space;
  FLowValue.TextOutputSql(Output);
  Output.Space;
  Output.Keyword(SQL_KEYWORD_AND);
  Output.Space;
  FHighValue.TextOutputSql(Output);
end;

procedure TSqlBetweenPredicate.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FExpr);
  FExpr.Iterate(Proc);
  Proc(self, FLowValue);
  FLowValue.Iterate(Proc);
  Proc(self, FHighValue);
  FHighValue.Iterate(Proc);
end;

function TSqlBetweenPredicate.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
var V, L, H : ASqlLiteral;
begin
  V := FExpr.Evaluate(Engine, Cursor, Scope);
  L := FLowValue.Evaluate(Engine, Cursor, Scope);
  H := FHighValue.Evaluate(Engine, Cursor, Scope);
  try
    Result := (V.Compare(L) in [crGreater, crEqual]) and
              (V.Compare(H) in [crLess, crEqual]);
    if NotBetween then
      Result := not Result;
  finally
    H.ReleaseReference;
    L.ReleaseReference;
    V.ReleaseReference;
  end;
end;



{                                                                              }
{ TSqlDistinctPredicate                                                        }
{                                                                              }
constructor TSqlDistinctPredicate.CreateEx(const Expr1, Expr2: ASqlValueExpression);
begin
  inherited Create;
  FExpr1 := Expr1;
  FExpr2 := Expr2;
end;

destructor TSqlDistinctPredicate.Destroy;
begin
  FreeAndNil(FExpr2);
  FreeAndNil(FExpr1);
  inherited Destroy;
end;



{                                                                              }
{ TSqlMatchPredicate                                                           }
{                                                                              }
destructor TSqlMatchPredicate.Destroy;
begin
  FreeAndNil(FTableSubQuery);
  FreeAndNil(FExpr);
  inherited Destroy;
end;



{                                                                              }
{ TSqlOverlapsPredicate                                                        }
{                                                                              }
constructor TSqlOverlapsPredicate.CreateEx(const Expr1, Expr2: ASqlValueExpression);
begin
  inherited Create;
  FExpr1 := Expr1;
  FExpr2 := Expr2;
end;

destructor TSqlOverlapsPredicate.Destroy;
begin
  FreeAndNil(FExpr2);
  FreeAndNil(FExpr1);
  inherited Destroy;
end;



{                                                                              }
{ TSqlBooleanTest                                                              }
{                                                                              }
destructor TSqlBooleanTest.Destroy;
begin
  FreeAndNil(FTruthValue);
  FreeAndNil(FCondition);
  inherited Destroy;
end;

function TSqlBooleanTest.Match(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): Boolean;
begin
  Result := FCondition.Match(Engine, Cursor, Scope);
  if FTruthValue = stvFalse then
    Result := not Result;
  if FNotValue then
    Result := not Result;
end;



end.

