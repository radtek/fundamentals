{******************************************************************************}
(*                                                                            *)
(*    Library:       Fundamentals SQL                                         *)
(*    Description:   SQL nodes: Query                                         *)
(*    Version:       0.03                                                     *)
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
(*    2003/07/29  0.02  Created cSQLNodesQuery unit.                          *)
(*    2005/04/09  0.03  Development.                                          *)
(*                                                                            *)
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLNodesQuery;

interface

uses
  { Fundamentals }
  cUtils,

  { SQL }
  cSQLUtils,
  cSQLStructs,
  cSQLDatabase,
  cSQLNodes;



{                                                                              }
{ TSqlSimpleTableReference                                                     }
{   SQL Simple Table Reference Query Expression.                               }
{                                                                              }
type
  TSqlSimpleTableReference = class(ASqlQueryExpression)
  protected
    FName       : AnsiString;
    FIdentifier : AnsiString;
    FColumnList : AnsiStringArray;

  public
    constructor CreateEx(const Name, Identifier: AnsiString;
                const ColumnList: AnsiStringArray);

    property  Name: AnsiString read FName write FName;
    property  Identifier: AnsiString read FIdentifier write FIdentifier;
    property  ColumnList: AnsiStringArray read FColumnList write FColumnList;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;

    function  GetCursor(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlExplicitTable                                                            }
{   SQL Explicit Table Query Expression.                                       }
{                                                                              }
type
  TSqlExplicitTable = class(ASqlQueryExpression)
  protected
    FName : AnsiString;

  public
    constructor CreateEx(const Name: AnsiString);

    property  Name: AnsiString read FName write FName;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  GetCursor(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlDerivedTableReference                                                    }
{   Table Reference from a Query Expression.                                   }
{                                                                              }
type
  TSqlDerivedTableReference = class(ASqlQueryExpression)
  protected
    FQueryExpr       : ASqlQueryExpression;
    FCorrelationName : AnsiString;
    FDerivedColumns  : AnsiStringArray;

  public
    destructor Destroy; override;

    property  QueryExpr: ASqlQueryExpression read FQueryExpr write FQueryExpr;
    property  CorrelationName: AnsiString read FCorrelationName write FCorrelationName;
    property  DerivedColumns: AnsiStringArray read FDerivedColumns write FDerivedColumns;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlQueryExpression; override;
    procedure Prepare(const Database: ASqlDatabase; const Cursor: ASqlCursor;
              const Scope: ASqlScope); override;
    function  GetCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlTableValueConstructor                                                    }
{                                                                              }
type
  TSqlTableValueConstructor = class(ASqlQueryExpression)
  protected
    FRowValues : ASqlValueExpressionArray;

  public
    constructor CreateEx(const RowValues: ASqlValueExpressionArray);
    destructor Destroy; override;

    property  RowValues: ASqlValueExpressionArray read FRowValues write FRowValues;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlQueryExpression; override;
    function  GetCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlSelectList                                                               }
{   Helper structure to store a SQL SELECT list.                               }
{                                                                              }
type
  TSqlSelectItem = class
  protected
    FValueExpr  : ASqlValueExpression;
    FAsName     : AnsiString;

    function  GetColumnName: AnsiString;

  public
    constructor CreateEx(const ValueExpr: ASqlValueExpression;
                const AsName: AnsiString);
    destructor Destroy; override;

    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;
    property  AsName: AnsiString read FAsName write FAsName;
    property  ColumnName: AnsiString read GetColumnName;

    procedure TextOutputStructure(const Output: TSqlTextOutput);
    procedure TextOutputSql(const Output: TSqlTextOutput);
    procedure Simplify;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope);
  end;
  TSqlSelectItemArray = Array of TSqlSelectItem;

  TSqlSelectList = class
  protected
    FWild : Boolean;
    FList : TSqlSelectItemArray;

  public
    constructor CreateEx(const List: TSqlSelectItemArray);
    constructor CreateWild;
    destructor Destroy; override;

    property  Wild: Boolean read FWild write FWild;
    property  List: TSqlSelectItemArray read FList write FList;
    procedure AddItem(const Item: TSqlSelectItem);
    function  Count: Integer;
    function  GetItem(const Idx: Integer): TSqlSelectItem;

    procedure TextOutputStructure(const Output: TSqlTextOutput);
    procedure TextOutputSql(const Output: TSqlTextOutput);
    procedure Simplify;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope);
  end;



{                                                                              }
{ TSqlTableExpression                                                          }
{   Helper structure to store SQL Table Expression.                            }
{                                                                              }
type
  TSqlGroupingColumnReference = class
    ColumnRef : ASqlValueExpression;
    Collate   : AnsiString;
  end;
  TSqlGroupingColumnReferenceArray = Array of TSqlGroupingColumnReference;
  TSqlGroupByClause = class
    ColumnRefs : TSqlGroupingColumnReferenceArray;
  end;
  TSqlTableExpression = class
  protected
    FFromTable : ASqlQueryExpression;
    FWhere     : ASqlSearchCondition;
    FGroupBy   : TSqlGroupByClause;
    FHaving    : ASqlSearchCondition;

  public
    constructor CreateEx(const FromTable: ASqlQueryExpression;
                const Where: ASqlSearchCondition;
                const GroupBy: TSqlGroupByClause;
                const Having: ASqlSearchCondition);
    destructor Destroy; override;

    property  FromTable: ASqlQueryExpression read FFromTable write FFromTable;
    property  Where: ASqlSearchCondition read FWhere write FWhere;
    property  GroupBy: TSqlGroupByClause read FGroupBy write FGroupBy;
    property  Having: ASqlSearchCondition read FHaving write FHaving;

    procedure TextOutputStructure(const Output: TSqlTextOutput);
    procedure TextOutputSql(const Output: TSqlTextOutput);
    procedure Iterate(const Proc: TSqlNodeIterateProc);
    function  Simplify: TSqlTableExpression;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope);
    function  GetCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
  end;



{                                                                              }
{ TSqlQueryExpression                                                          }
{   SQL Query Expression.                                                      }
{                                                                              }
type
  TSqlQueryExpression = class(ASqlQueryExpression)
  protected
    FQuantifier : TSqlSetQuantifier;
    FSelectList : TSqlSelectList;
    FInto       : ASqlValueExpressionArray;
    FTableExpr  : TSqlTableExpression;

  public
    constructor CreateEx(const Quantifier: TSqlSetQuantifier;
                const SelectList: TSqlSelectList;
                const TableExpr: TSqlTableExpression);
    destructor Destroy; override;

    property  Quantifier: TSqlSetQuantifier read FQuantifier write FQuantifier;
    property  SelectList: TSqlSelectList read FSelectList write FSelectList;
    property  Into: ASqlValueExpressionArray read FInto write FInto;
    property  TableExpr: TSqlTableExpression read FTableExpr write FTableExpr;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlQueryExpression; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
    function  GetCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlFromMultipleQuery                                                        }
{   SQL query from multiple tables.                                            }
{                                                                              }
type
  TSqlFromMultipleQuery = class(ASqlQueryExpression)
  protected
    FQueries : ASqlQueryExpressionArray;

  public
    constructor CreateEx(const Queries: ASqlQueryExpressionArray);
    destructor Destroy; override;

    property  Queries: ASqlQueryExpressionArray read FQueries write FQueries;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlQueryExpression; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
    function  GetCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlJoinedQuery                                                              }
{                                                                              }
type
  TSqlJoinType = (sjtUndefined, sjtCross, sjtInner, sjtLeftOuter,
      sjtRightOuter, sjtFullOuter, sjtUnion);
  TSqlJoinedQuery = class(ASqlQueryExpression)
  protected
    FJoinType       : TSqlJoinType;
    FTableRef1      : ASqlQueryExpression;
    FTableRef2      : ASqlQueryExpression;
    FNatural        : Boolean;
    FJoinCondition  : ASqlSearchCondition;
    FJoinColumnList : AnsiStringArray;

    procedure TextOutputJoinType(const Output: TSqlTextOutput);

  public
    constructor CreateEx(const JoinType: TSqlJoinType;
                const TableRef1, TableRef2: ASqlQueryExpression;
                const Natural: Boolean;
                const JoinCondition: ASqlSearchCondition;
                const JoinColumnList: AnsiStringArray);
    destructor Destroy; override;

    property  JoinType: TSqlJoinType read FJoinType write FJoinType;
    property  TableRef1: ASqlQueryExpression read FTableRef1 write FTableRef1;
    property  TableRef2: ASqlQueryExpression read FTableRef2 write FTableRef2;
    property  Natural: Boolean read FNatural write FNatural;
    property  JoinCondition: ASqlSearchCondition read FJoinCondition write FJoinCondition;
    property  JoinColumnList: AnsiStringArray read FJoinColumnList write FJoinColumnList;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlQueryExpression; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
    function  GetCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlOrderByQuery                                                             }
{                                                                              }
type
  TSqlOrderByQuery = class(ASqlQueryExpression)
  protected
    FQuery : ASqlQueryExpression;
    FItems : TSqlSortSpecificationArray;

  public
    constructor CreateEx(const Query: ASqlQueryExpression;
                const Items: TSqlSortSpecificationArray);
    destructor Destroy; override;

    property  Query: ASqlQueryExpression read FQuery write FQuery;
    property  Items: TSqlSortSpecificationArray read FItems write FItems;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlQueryExpression; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
    function  GetCursor(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlUnionQueryExpression                                                     }
{                                                                              }
type
  TSqlCorrespondingSpec = class
    ColumnNames : AnsiStringArray;
  end;
  TSqlUnionType = (sutUndefined, sutUnion, sutExcept);
  TSqlUnionQueryExpression = class(ASqlQueryExpression)
  protected
    FUnionType     : TSqlUnionType;
    FQuery1        : ASqlQueryExpression;
    FQuery2        : ASqlQueryExpression;
    FAll           : Boolean;
    FCorresponding : TSqlCorrespondingSpec;

  public
    property  UnionType: TSqlUnionType read FUnionType write FUnionType;
    property  Query1: ASqlQueryExpression read FQuery1 write FQuery1;
    property  Query2: ASqlQueryExpression read FQuery2 write FQuery2;
    property  All: Boolean read FAll write FAll;
    property  Corresponding: TSqlCorrespondingSpec read FCorresponding write FCorresponding;
  end;



{                                                                              }
{ TSqlIntersectQueryExpression                                                 }
{                                                                              }
type
  TSqlIntersectQueryExpression = class(ASqlQueryExpression)
  protected
    FQuery1        : ASqlQueryExpression;
    FQuery2        : ASqlQueryExpression;
    FAll           : Boolean;
    FCorresponding : TSqlCorrespondingSpec;

  public
    property  Query1: ASqlQueryExpression read FQuery1 write FQuery1;
    property  Query2: ASqlQueryExpression read FQuery2 write FQuery2;
    property  All: Boolean read FAll write FAll;
    property  Corresponding: TSqlCorrespondingSpec read FCorresponding write FCorresponding;
  end;



implementation

uses
  { System }
  SysUtils,

  { Fundamentals }
  cDynArrays,

  { SQL }
  cSQLLexer,
  cSQLDataTypes,
  cSQLNodesValues;



{                                                                              }
{ TSqlSelectedCursor                                                           }
{   Cursor with value expressions as field values.                             }
{                                                                              }
type
  TSqlSelectedCursor = class(ASqlProxyCursor)
  protected
    FEngine     : ASqlDatabaseEngine;
    FSelectList : TSqlSelectList;
    FFields     : TSqlFieldArray;

    function  GetField(const Name: AnsiString): TSqlField; override;
    function  GetFieldCount: Integer; override;
    function  GetFieldByIndex(const Idx: Integer): TSqlField; override;

  public
    constructor Create(const Engine: ASqlDatabaseEngine; const Cursor: ASqlCursor;
                const SelectList: TSqlSelectList);

    procedure Next; override;
  end;

constructor TSqlSelectedCursor.Create(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const SelectList: TSqlSelectList);
var I, L : Integer;
    V    : ASqlLiteral;
    C    : TSqlColumnDefinition;
    J    : TSqlSelectItem;
    R    : Boolean;
begin
  inherited Create(Cursor);
  FEngine := Engine;
  FSelectList := SelectList;
  L := FSelectList.Count;
  SetLength(FFields, L);
  R := Cursor.Eof;
  for I := 0 to L - 1 do
    begin
      J := FSelectList.GetItem(I);
      if R then
        V := nil
      else
        V := J.ValueExpr.Evaluate(Engine, Cursor, nil);
      C := TSqlColumnDefinition.Create;
      C.Name := J.ColumnName;
      FFields[I] := TSqlField.Create(C, V, False);
    end;
end;

function TSqlSelectedCursor.GetField(const Name: AnsiString): TSqlField;
var I : Integer;
begin
  for I := 0 to Length(FFields) - 1 do
    if FFields[I].Column.IsName(Name) then
      begin
        Result := FFields[I];
        exit;
      end;
  Result := nil;
end;

function TSqlSelectedCursor.GetFieldCount: Integer;
begin
  Result := Length(FFields);
end;

function TSqlSelectedCursor.GetFieldByIndex(const Idx: Integer): TSqlField;
begin
  Result := FFields[Idx];
end;

procedure TSqlSelectedCursor.Next;
var V : ASqlLiteral;
    I : Integer;
begin
  FCursor.Next;
  if FCursor.Eof then
    exit;
  for I := 0 to Length(FFields) - 1 do
    begin
      V := FSelectList.GetItem(I).ValueExpr.Evaluate(FEngine, FCursor, nil);
      FFields[I].Value.AssignLiteral(V);
    end;
end;



{                                                                              }
{ TSqlGroupedSummaryCursor                                                     }
{   Single line cursor consisting of grouped summary values.                   }
{                                                                              }
type
  TSqlGroupedSummaryCursor = class(ASqlCursor)
  protected
    FCursor     : ASqlCursor;
    FSelectList : TSqlSelectList;
    FFields     : TSqlFieldArray;
    FEOF        : Boolean;

    function  GetField(const Name: AnsiString): TSqlField; override;
    function  GetFieldCount: Integer; override;
    function  GetFieldByIndex(const Idx: Integer): TSqlField; override;

  public
    constructor Create(const Cursor: ASqlCursor; const SelectList: TSqlSelectList);
    destructor Destroy; override;

    procedure Reset; override;
    function  Eof: Boolean; override;
    procedure Next; override;

    function  GetUngroupedCursor: ASqlCursor; override;

    function  FilterInverseSelection: ASqlCursor; override;
    function  OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor; override;
    procedure UpdateRecord; override;
    procedure DeleteRecord; override;
  end;

constructor TSqlGroupedSummaryCursor.Create(const Cursor: ASqlCursor;
            const SelectList: TSqlSelectList);
var I, L : Integer;
    C    : TSqlColumnDefinition;
begin
  inherited Create;
  FCursor := Cursor;
  FSelectList := SelectList;
  L := FSelectList.Count;
  SetLength(FFields, L);
  for I := 0 to L - 1 do
    begin
      C := TSqlColumnDefinition.Create;
      C.Name := FSelectList.GetItem(I).AsName;
      FFields[I] := TSqlField.Create(C, nil, False);
    end;
  for I := 0 to L - 1 do
    FFields[I].Value := FSelectList.GetItem(I).ValueExpr.Evaluate(ASqlDatabaseEngine(nil), self, nil);
end;

destructor TSqlGroupedSummaryCursor.Destroy;
begin
  FreeAndNil(FCursor);
  inherited Destroy;
end;

function TSqlGroupedSummaryCursor.GetField(const Name: AnsiString): TSqlField;
var I : Integer;
begin
  for I := 0 to Length(FFields) - 1 do
    if FFields[I].Column.IsName(Name) then
      begin
        Result := FFields[I];
        exit;
      end;
  Result := nil;
end;

function TSqlGroupedSummaryCursor.GetFieldCount: Integer;
begin
  Result := Length(FFields);
end;

function TSqlGroupedSummaryCursor.GetFieldByIndex(const Idx: Integer): TSqlField;
begin
  Result := FFields[Idx];
end;

function TSqlGroupedSummaryCursor.GetUngroupedCursor: ASqlCursor;
begin
  Result := FCursor;
end;

procedure TSqlGroupedSummaryCursor.Reset;
begin
  FEof := False;
end;

function TSqlGroupedSummaryCursor.Eof: Boolean;
begin
  Result := FEof;
end;

procedure TSqlGroupedSummaryCursor.Next;
begin
  if FEof then
    RaiseNextPastEofError;
  FEof := True;
end;

function TSqlGroupedSummaryCursor.FilterInverseSelection: ASqlCursor;
begin
  raise ESqlError.Create('Not implemented');
end;

function TSqlGroupedSummaryCursor.OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor;
begin
  raise ESqlError.Create('Not implemented');
end;

procedure TSqlGroupedSummaryCursor.UpdateRecord;
begin
  raise ESqlError.Create('Not implemented');
end;

procedure TSqlGroupedSummaryCursor.DeleteRecord;
begin
  raise ESqlError.Create('Not implemented');
end;



{                                                                              }
{ TSqlSimpleTableReference                                                     }
{                                                                              }
constructor TSqlSimpleTableReference.CreateEx(const Name, Identifier: AnsiString;
    const ColumnList: AnsiStringArray);
begin
  inherited Create;
  Assert(Name <> '');
  FName := Name;
  FIdentifier := Identifier;
  FColumnList := ColumnList;
end;

procedure TSqlSimpleTableReference.TextOutputStructureParameters(const Output: TSqlTextOutput);
var I : Integer;
begin
  inherited TextOutputStructureParameters(Output);
  Output.Identifier(FName);
  if FIdentifier <> '' then
    begin
      Output.Symbol('=');
      Output.Identifier(FIdentifier);
    end;
  for I := 0 to Length(FColumnList) - 1 do
    begin
      Output.Symbol(',');
      Output.Identifier(FColumnList[I]);
    end;
end;

procedure TSqlSimpleTableReference.TextOutputSql(const Output: TSqlTextOutput);
var I, L : Integer;
begin
  with Output do
    begin
      Identifier(FName);
      if FIdentifier <> '' then
        begin
          Space;
          Keyword(SQL_KEYWORD_AS);
          Space;
          Identifier(FIdentifier);
        end;
      L := Length(FColumnList);
      if L > 0 then
        begin
          Symbol('(');
          for I := 0 to L - 1 do
            begin
              if I > 0 then
                begin
                  Symbol(',');
                  Space;
                end;
              Identifier(FColumnList[I]);
            end;
          Symbol(')');
        end;
    end;
end;

function TSqlSimpleTableReference.GetCursor(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
begin
  if not Assigned(Database) then
    raise ESqlDatabase.Create('Database required');
  Result := Database.GetTable(FName).GetCursor;
  if Length(FColumnList) > 0 then
    Result := TSqlSelectedColumnCursor.Create(Result, FColumnList);
end;



{                                                                              }
{ TSqlExplicitTable                                                            }
{                                                                              }
constructor TSqlExplicitTable.CreateEx(const Name: AnsiString);
begin
  inherited Create;
  FName := Name;
end;

procedure TSqlExplicitTable.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  Output.Identifier(FName);
  Output.Space;
  inherited TextOutputStructureParameters(Output);
end;

procedure TSqlExplicitTable.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_TABLE);
      Space;
      Identifier(FName);
    end;
end;

function TSqlExplicitTable.GetCursor(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
begin
  raise ESqlError.Create('Not implemented');
end;



{                                                                              }
{ TSqlDerivedTableReference                                                    }
{                                                                              }
destructor TSqlDerivedTableReference.Destroy;
begin
  FreeAndNil(FQueryExpr);
  inherited Destroy;
end;

procedure TSqlDerivedTableReference.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FQueryExpr.TextOutputStructure(Output);
end;

procedure TSqlDerivedTableReference.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Symbol('(');
      FQueryExpr.TextOutputSql(Output);
      Symbol(')');
    end;
end;

procedure TSqlDerivedTableReference.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FQueryExpr);
  FQueryExpr.Iterate(Proc);
end;

function TSqlDerivedTableReference.Simplify: ASqlQueryExpression;
begin
  FQueryExpr := FQueryExpr.Simplify;
  Result := self;
end;

procedure TSqlDerivedTableReference.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FQueryExpr.Prepare(Database, Cursor, Scope); 
end;

function TSqlDerivedTableReference.GetCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
begin
  Result := FQueryExpr.GetCursor(Engine, Cursor, Scope);
end;



{                                                                              }
{ TSqlTableValueCursor                                                         }
{                                                                              }
type
  TSqlTableValueCursor = class(ASqlCursor)
  protected
    FEngine     : ASqlDatabaseEngine;
    FCursor     : ASqlCursor;
    FScope      : ASqlScope;
    FRowValues  : ASqlValueExpressionArray;
    FRowCount   : Integer;
    FRowIndex   : Integer;
    FEof        : Boolean;
    FFields     : TSqlFieldArray;
    FFieldCount : Integer;

    function  GetField(const Name: AnsiString): TSqlField; override;
    function  GetFieldCount: Integer; override;
    function  GetFieldByIndex(const Idx: Integer): TSqlField; override;

    procedure SetFields;

  public
    constructor Create(const Engine: ASqlDatabaseEngine; const Cursor: ASqlCursor;
                const Scope: ASqlScope;
                const RowValues: ASqlValueExpressionArray);
    destructor Destroy; override;

    procedure Reset; override;
    function  Eof: Boolean; override;
    procedure Next; override;
  end;

constructor TSqlTableValueCursor.Create(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope;
    const RowValues: ASqlValueExpressionArray);
var A : ASqlLiteral;
    B : TSqlLiteralArray;
    I : Integer;
begin
  inherited Create;
  FEngine := Engine;
  FCursor := Cursor;
  FScope := Scope;
  FRowValues := RowValues;
  FRowCount := Length(FRowValues);
  FRowIndex := 0;
  FEof := (FRowIndex >= FRowCount);
  if FEof then
    exit;
  A := FRowValues[0].Evaluate(Engine, Cursor, Scope);
  if A is TSqlLiteralArray then
    begin
      B := TSqlLiteralArray(A);
      FFieldCount := Length(B.Value);
      SetLength(FFields, FFieldCount);
      for I := 0 to FFieldCount - 1 do
        FFields[I] := TSqlField.Create(TSqlColumnDefinition.Create,
            B.Value[I].Duplicate, True);
    end
  else
    begin
      FFieldCount := 1;
      SetLength(FFields, 1);
      FFields[0] := TSqlField.Create(TSqlColumnDefinition.Create,
          A.Duplicate, True);
    end;
end;

destructor TSqlTableValueCursor.Destroy;
begin
  FreeObjectArray(FFields);
  inherited Destroy;
end;

function TSqlTableValueCursor.GetField(const Name: AnsiString): TSqlField;
begin
  Result := nil;
end;

function TSqlTableValueCursor.GetFieldCount: Integer;
begin
  Result := FFieldCount;
end;

function TSqlTableValueCursor.GetFieldByIndex(const Idx: Integer): TSqlField;
begin
  Result := FFields[Idx];
end;

procedure TSqlTableValueCursor.SetFields;
var A : ASqlLiteral;
    B : TSqlLiteralArray;
    I : Integer;
begin
  A := FRowValues[FRowIndex].Evaluate(FEngine, FCursor, FScope);
  if A is TSqlLiteralArray then
    begin
      B := TSqlLiteralArray(A);
      for I := 0 to MinI(FFieldCount, Length(B.Value)) - 1 do
        FFields[I].Value.AssignLiteral(B.Value[I]);
    end
  else
    FFields[0].Value.AssignLiteral(A);
end;

procedure TSqlTableValueCursor.Reset;
begin
  FRowIndex := 0;
  FEof := (FRowIndex >= FRowCount);
  SetFields;
end;

function TSqlTableValueCursor.Eof: Boolean;
begin
  Result := FEof;
end;

procedure TSqlTableValueCursor.Next;
begin
  if FEof then
    RaiseNextPastEofError;
  Inc(FRowIndex);
  FEof := (FRowIndex >= FRowCount);
  if not FEof then
    SetFields;
end;



{                                                                              }
{ TSqlTableValueConstructor                                                    }
{                                                                              }
constructor TSqlTableValueConstructor.CreateEx(const RowValues: ASqlValueExpressionArray);
begin
  inherited Create;
  FRowValues := RowValues;
end;

destructor TSqlTableValueConstructor.Destroy;
begin
  FreeObjectArray(FRowValues);
  inherited Destroy;
end;

procedure TSqlTableValueConstructor.TextOutputStructureParameters(const Output: TSqlTextOutput);
var I : Integer;
begin
  inherited TextOutputStructureParameters(Output);
  for I := 0 to Length(FRowValues) - 1 do
    FRowValues[I].TextOutputStructure(Output);
end;

procedure TSqlTableValueConstructor.TextOutputSql(const Output: TSqlTextOutput);
var I : Integer;
begin
  for I := 0 to Length(FRowValues) - 1 do
    begin
      if I > 0 then
        Output.Symbol(',');
      FRowValues[I].TextOutputSql(Output);
    end;
end;

procedure TSqlTableValueConstructor.Iterate(const Proc: TSqlNodeIterateProc);
var I : Integer;
begin
  for I := 0 to Length(FRowValues) - 1 do
    begin
      Proc(self, FRowValues[I]);
      FRowValues[I].Iterate(Proc);
    end;
end;

function TSqlTableValueConstructor.Simplify: ASqlQueryExpression;
var I : Integer;
begin
  for I := 0 to Length(FRowValues) - 1 do
    FRowValues[I] := FRowValues[I].Simplify;
  Result := self;
end;

function TSqlTableValueConstructor.GetCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
begin
  Result := TSqlTableValueCursor.Create(Engine, Cursor, Scope, FRowValues);
end;



{                                                                              }
{ TSqlSelectItem                                                               }
{                                                                              }
constructor TSqlSelectItem.CreateEx(const ValueExpr: ASqlValueExpression;
    const AsName: AnsiString);
begin
  inherited Create;
  Assert(Assigned(ValueExpr));
  FValueExpr := ValueExpr;
  FAsName := AsName;
end;

destructor TSqlSelectItem.Destroy;
begin
  FreeAndNil(FValueExpr);
  inherited Destroy;
end;

function TSqlSelectItem.GetColumnName: AnsiString;
begin
  if FAsName <> '' then
    Result := FAsName
  else
    if FValueExpr is TSqlColumnReference then
      Result := TSqlColumnReference(ValueExpr).ColumnName
    else
      Result := '';
end;

procedure TSqlSelectItem.TextOutputStructure(const Output: TSqlTextOutput);
begin
  if FAsName <> '' then
    begin
      Output.Identifier(FAsName);
      Output.Space;
    end;
  FValueExpr.TextOutputStructure(Output);
end;

procedure TSqlSelectItem.TextOutputSql(const Output: TSqlTextOutput);
begin
  FValueExpr.TextOutputSql(Output);
  if FAsName <> '' then
    with Output do
      begin
        Space;
        Keyword(SQL_KEYWORD_AS);
        Space;
        Identifier(FAsName);
      end;
end;

procedure TSqlSelectItem.Simplify;
begin
  FValueExpr := FValueExpr.Simplify;
end;

procedure TSqlSelectItem.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FValueExpr.Prepare(Database, Cursor, Scope);
end;



{                                                                              }
{ TSqlSelectList                                                               }
{                                                                              }
constructor TSqlSelectList.CreateEx(const List: TSqlSelectItemArray);
begin
  inherited Create;
  FList := List;
  FWild := False;
end;

constructor TSqlSelectList.CreateWild;
begin
  inherited Create;
  FWild := True;
end;

destructor TSqlSelectList.Destroy;
begin
  FreeAndNilObjectArray(ObjectArray(FList));
  inherited Destroy;
end;

procedure TSqlSelectList.AddItem(const Item: TSqlSelectItem);
begin
  DynArrayAppend(ObjectArray(FList), Item);
end;

function TSqlSelectList.Count: Integer;
begin
  Result := Length(FList);
end;

function TSqlSelectList.GetItem(const Idx: Integer): TSqlSelectItem;
begin
  Result := FList[Idx];
end;

procedure TSqlSelectList.TextOutputStructure(const Output: TSqlTextOutput);
var I : Integer;
begin
  if FWild then
    Output.StructureName('Wild')
  else
    for I := 0 to Length(FList) - 1 do
      FList[I].TextOutputStructure(Output);
end;

procedure TSqlSelectList.TextOutputSql(const Output: TSqlTextOutput);
var I : Integer;
begin
  if FWild then
    Output.Symbol('*')
  else
    for I := 0 to Length(FList) - 1 do
      begin
        if I > 0 then
          begin
            Output.Symbol(',');
            Output.Space;
          end;
        FList[I].TextOutputSql(Output);
      end;
end;

procedure TSqlSelectList.Simplify;
var I : Integer;
begin
  for I := 0 to Length(FList) - 1 do
    FList[I].Simplify;
end;

procedure TSqlSelectList.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
var I : Integer;
begin
  for I := 0 to Length(FList) - 1 do
    FList[I].Prepare(Database, Cursor, Scope);
end;



{                                                                              }
{ TSqlTableExpression                                                          }
{                                                                              }
constructor TSqlTableExpression.CreateEx(const FromTable: ASqlQueryExpression;
    const Where: ASqlSearchCondition; const GroupBy: TSqlGroupByClause;
    const Having: ASqlSearchCondition);
begin
  inherited Create;
  Assert(Assigned(FromTable));
  FFromTable := FromTable;
  FWhere := Where;
  FGroupBy := GroupBy;
  FHaving := Having;
end;

destructor TSqlTableExpression.Destroy;
begin
  FreeAndNil(FHaving);
  FreeAndNil(FWhere);
  FreeAndNil(FFromTable);
  inherited Destroy;
end;

procedure TSqlTableExpression.TextOutputStructure(const Output: TSqlTextOutput);
begin
  FFromTable.TextOutputStructure(Output);
  if Assigned(FWhere) then
    FWhere.TextOutputStructure(Output);
end;

procedure TSqlTableExpression.TextOutputSql(const Output: TSqlTextOutput);
var I, L : Integer;
begin
  with Output do
    begin
      FFromTable.TextOutputSql(Output);
      if Assigned(FWhere) then
        begin
          Space;
          Keyword(SQL_KEYWORD_WHERE);
          Space;
          FWhere.TextOutputSql(Output);
        end;
      if Assigned(FGroupBy) then
        L := Length(FGroupBy.ColumnRefs) else
        L := 0;
      if L > 0 then
        begin
          Space;
          Keyword(SQL_KEYWORD_GROUP);
          Space;
          Keyword(SQL_KEYWORD_BY);
          Space;
          for I := 0 to L - 1 do
            begin
              if I > 0 then
                begin
                  Symbol(',');
                  Space;
                end;
              FGroupBy.ColumnRefs[I].ColumnRef.TextOutputSql(Output);
            end;
        end;
      if Assigned(FHaving) then
        begin
          Space;
          Keyword(SQL_KEYWORD_HAVING);
          Space;
          FHaving.TextOutputSql(Output);
        end;
    end;
end;

procedure TSqlTableExpression.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FFromTable);
  FFromTable.Iterate(Proc);
  if Assigned(FWhere) then
    begin
      Proc(self, FWhere);
      FWhere.Iterate(Proc);
    end;
  if Assigned(FHaving) then
    begin
      Proc(self, FHaving);
      FHaving.Iterate(Proc);
    end;
end;

function TSqlTableExpression.Simplify: TSqlTableExpression;
begin
  FFromTable := FFromTable.Simplify;
  if Assigned(FWhere) then
    FWhere := FWhere.Simplify;
  if Assigned(FHaving) then
    FHaving := FHaving.Simplify;
  Result := self;
end;

procedure TSqlTableExpression.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FFromTable.Prepare(Database, Cursor, Scope);
  if Assigned(FWhere) then
    FWhere.Prepare(Database, Cursor, Scope);
end;

function TSqlTableExpression.GetCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
begin
  Result := FFromTable.GetCursor(Engine, Cursor, Scope);
//  Moved down below:
//  if Assigned(FWhere) then
//    Result := FWhere.FilterCursor(Engine, Result);
//  if Length(FGroupBy.ColumnRefs) > 0 then
//    Result := TSqlGroupedCursor.Create(Result, FGroup);
end;



{                                                                              }
{ TSqlQueryExpression                                                          }
{                                                                              }
constructor TSqlQueryExpression.CreateEx(const Quantifier: TSqlSetQuantifier;
    const SelectList: TSqlSelectList; const TableExpr: TSqlTableExpression);
begin
  inherited Create;
  Assert(Assigned(SelectList));
  FQuantifier := Quantifier;
  FSelectList := SelectList;
  FTableExpr := TableExpr;
end;

destructor TSqlQueryExpression.Destroy;
begin
  FreeAndNil(FTableExpr);
  FreeAndNil(FSelectList);
  inherited Destroy;
end;

procedure TSqlQueryExpression.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FSelectList.TextOutputStructure(Output);
  if Assigned(FTableExpr) then
    begin
      Output.NewLine;
      FTableExpr.TextOutputStructure(Output);
    end;
end;

procedure TSqlQueryExpression.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      case FQuantifier of
        ssqDistinct  : begin
                         Keyword(SQL_KEYWORD_DISTINCT);
                         Space;
                       end;
        ssqAll       : begin
                         Keyword(SQL_KEYWORD_ALL);
                         Space;
                       end;
      end;
      FSelectList.TextOutputSql(Output);
      if Assigned(FTableExpr) then
        begin
          Space;
          Keyword(SQL_KEYWORD_FROM);
          Space;
          FTableExpr.TextOutputSql(Output);
        end;
    end;
end;

procedure TSqlQueryExpression.Iterate(const Proc: TSqlNodeIterateProc);
begin
  if Assigned(FTableExpr) then
    begin
      Proc(self, FTableExpr);
      FTableExpr.Iterate(Proc);
    end;
end;

function TSqlQueryExpression.Simplify: ASqlQueryExpression;
begin
  FSelectList.Simplify;
  if Assigned(FTableExpr) then
    FTableExpr := FTableExpr.Simplify;
  Result := self;
end;

procedure TSqlQueryExpression.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FSelectList.Prepare(Database, Cursor, Scope);
end;

function TSqlQueryExpression.GetCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
var I : Integer;
    L : Integer;
    T : TSqlSelectItem;
    F : TSqlFieldArray;
    G : TSqlField;
    V : ASqlLiteral;
    C : TSqlColumnDefinition;
    D : TSqlGroupLevel;
    U : Boolean;
begin
  if Assigned(FTableExpr) then
    begin
      Result := FTableExpr.GetCursor(Engine, Cursor, Scope);
      if not FSelectList.Wild then
        begin
          U := False;
          L := FSelectList.Count;
          for I := 0 to L - 1 do
            begin
              D := FSelectList.GetItem(I).ValueExpr.GetGroupLevel(Result);
              case D of
                sglInvalid,
                sglUngrouped : raise ESqlError.Create('Item in select list is not on grouping level');
                sglGrouped   : U := True;
              end;
            end;
          if U then
            Result := TSqlGroupedSummaryCursor.Create(Result, FSelectList)
          else
            Result := TSqlSelectedCursor.Create(Engine, Result, FSelectList);
        end;
      if Assigned(FTableExpr.Where) then
        Result := FTableExpr.Where.FilterCursor(Engine, Result);
      if FQuantifier = ssqDistinct then
        Result := TSqlDistinctCursor.Create(Result);
    end
  else
    begin
      L := FSelectList.Count;
      SetLength(F, L);
      for I := 0 to L - 1 do
        begin
          T := FSelectList.GetItem(I);
          V := T.ValueExpr.Evaluate(Engine, nil, Scope);
          C := TSqlColumnDefinition.CreateEx(T.AsName, TSqlDataTypeDefinition.Create);
          G := TSqlField.Create(C, V, True);
          F[I] := G;
        end;
      Result := TSqlValueCursor.Create(F);
    end;
end;



{                                                                              }
{ TSqlFromMultipleQuery                                                        }
{                                                                              }
constructor TSqlFromMultipleQuery.CreateEx(const Queries: ASqlQueryExpressionArray);
begin
  inherited Create;
  FQueries := Queries;
end;

destructor TSqlFromMultipleQuery.Destroy;
begin
  FreeAndNilObjectArray(ObjectArray(FQueries));
  inherited Destroy;
end;

procedure TSqlFromMultipleQuery.TextOutputStructureParameters(const Output: TSqlTextOutput);
var I : Integer;
begin
  inherited TextOutputStructureParameters(Output);
  for I := 0 to Length(FQueries) - 1 do
    FQueries[I].TextOutputStructure(Output);
end;

procedure TSqlFromMultipleQuery.TextOutputSql(const Output: TSqlTextOutput);
var I : Integer;
begin
  with Output do
    for I := 0 to Length(FQueries) - 1 do
      begin
        if I > 0 then
          begin
            Symbol(',');
            Space;
          end;
        FQueries[I].TextOutputSql(Output);
      end;
end;

procedure TSqlFromMultipleQuery.Iterate(const Proc: TSqlNodeIterateProc);
var I : Integer;
begin
  for I := 0 to Length(FQueries) - 1 do
    begin
      Proc(self, FQueries[I]);
      FQueries[I].Iterate(Proc);
    end;
end;

function TSqlFromMultipleQuery.Simplify: ASqlQueryExpression;
var I : Integer;
begin
  for I := 0 to Length(FQueries) - 1 do
    FQueries[I] := FQueries[I].Simplify;
  Result := self;
end;

procedure TSqlFromMultipleQuery.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
var I : Integer;
begin
  for I := 0 to Length(FQueries) - 1 do
    FQueries[I].Prepare(Database, Cursor, Scope);
end;

function TSqlFromMultipleQuery.GetCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
var C : ASqlCursorArray;
    I, L : Integer;
begin
  L := Length(FQueries);
  SetLength(C, L);
  for I := 0 to L - 1 do
    C[I] := FQueries[I].GetCursor(Engine, Cursor, Scope);
  Result := TSqlFromMultipleCursor.Create(C);
end;



{                                                                              }
{ TSqlJoinedCursor                                                             }
{                                                                              }
type
  TSqlJoinedCursor = class(ASqlCursor)
  protected
    FJoinType      : TSqlJoinType;
    FCursor1       : ASqlCursor;
    FCursor2       : ASqlCursor;
    FNatural       : Boolean;
    FJoinCondition : ASqlSearchCondition;

    function  GetField(const Name: AnsiString): TSqlField; override;
    function  GetFieldCount: Integer; override;
    function  GetFieldByIndex(const Idx: Integer): TSqlField; override;

  public
    constructor Create(const JoinType: TSqlJoinType;
                const Cursor1, Cursor2: ASqlCursor; const Natural: Boolean;
                const JoinCondition: ASqlSearchCondition);
    destructor Destroy; override;

    procedure Reset; override;
    function  Eof: Boolean; override;
    procedure Next; override;
    function  FilterInverseSelection: ASqlCursor; override;
    function  OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor; override;
    procedure UpdateRecord; override;
    procedure DeleteRecord; override;
  end;

constructor TSqlJoinedCursor.Create(const JoinType: TSqlJoinType;
    const Cursor1, Cursor2: ASqlCursor; const Natural: Boolean;
    const JoinCondition: ASqlSearchCondition);
begin
  inherited Create;
  FJoinType := JoinType;
  FCursor1 := Cursor1;
  FCursor2 := Cursor2;
  FNatural := Natural;
  FJoinCondition := JoinCondition;
end;

destructor TSqlJoinedCursor.Destroy;
begin
  FreeAndNil(FJoinCondition);
  FreeAndNil(FCursor2);
  FreeAndNil(FCursor1);
  inherited Destroy;
end;

function TSqlJoinedCursor.GetField(const Name: AnsiString): TSqlField;
begin
  Result := FCursor1.Field[Name];
  if Assigned(Result) then
    exit;
  Result := FCursor2.Field[Name];
end;

function TSqlJoinedCursor.GetFieldCount: Integer;
begin
  Result := FCursor1.FieldCount + FCursor2.FieldCount;
end;

function TSqlJoinedCursor.GetFieldByIndex(const Idx: Integer): TSqlField;
var L : Integer;
begin
  L := FCursor1.FieldCount;
  if Idx < L then
    Result := FCursor1.FieldByIndex[Idx]
  else
    Result := FCursor2.FieldByIndex[Idx - L];
end;

procedure TSqlJoinedCursor.Reset;
begin
  FCursor1.Reset;
  FCursor2.Reset;
end;

function TSqlJoinedCursor.Eof: Boolean;
begin
  Result := True;
end;

procedure TSqlJoinedCursor.Next;
begin
end;

function TSqlJoinedCursor.FilterInverseSelection: ASqlCursor;
begin
  raise ESqlCursor.Create('Filter not implemented');
end;

function TSqlJoinedCursor.OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor;
begin
  Result := self;
end;

procedure TSqlJoinedCursor.UpdateRecord;
begin
  raise ESqlCursor.Create('Update not implemented');
end;

procedure TSqlJoinedCursor.DeleteRecord;
begin
  raise ESqlCursor.Create('Delete not implemented');
end;



{                                                                              }
{ TSqlJoinedQuery                                                              }
{                                                                              }
constructor TSqlJoinedQuery.CreateEx(const JoinType: TSqlJoinType;
    const TableRef1, TableRef2: ASqlQueryExpression; const Natural: Boolean;
    const JoinCondition: ASqlSearchCondition;
    const JoinColumnList: AnsiStringArray);
begin
  inherited Create;
  FJoinType := JoinType;
  FTableRef1 := TableRef1;
  FTableRef2 := TableRef2;
  FNatural := Natural;
  FJoinCondition := JoinCondition;
  FJoinColumnList := JoinColumnList;
end;

destructor TSqlJoinedQuery.Destroy;
begin
  FreeAndNil(FJoinCondition);
  FreeAndNil(FTableRef2);
  FreeAndNil(FTableRef1);
  inherited Destroy;
end;

procedure TSqlJoinedQuery.TextOutputJoinType(const Output: TSqlTextOutput);
begin
  with Output do
    case FJoinType of
      sjtCross : Keyword(SQL_KEYWORD_CROSS);
      sjtInner : Keyword(SQL_KEYWORD_INNER);
      sjtLeftOuter,
      sjtRightOuter,
      sjtFullOuter :
        begin
          case FJoinType of
            sjtLeftOuter  : Keyword(SQL_KEYWORD_LEFT);
            sjtRightOuter : Keyword(SQL_KEYWORD_RIGHT);
            sjtFullOuter  : Keyword(SQL_KEYWORD_FULL);
          end;
          Space;
          Keyword(SQL_KEYWORD_OUTER);
        end;
      sjtUnion : Keyword(SQL_KEYWORD_UNION);
    end;
end;

procedure TSqlJoinedQuery.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  TextOutputJoinType(Output);
  Output.Space;
  FTableRef1.TextOutputStructure(Output);
  FTableRef2.TextOutputStructure(Output);
  if Assigned(FJoinCondition) then
    FJoinCondition.TextOutputStructure(Output);
end;

procedure TSqlJoinedQuery.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      FTableRef1.TextOutputSql(Output);
      Space;
      if FNatural then
        begin
          Keyword(SQL_KEYWORD_NATURAL);
          Space;
        end;
      TextOutputJoinType(Output);
      Space;
      Keyword(SQL_KEYWORD_JOIN);
      Space;
      FTableRef2.TextOutputSql(Output);
      if Assigned(FJoinCondition) then
        begin
          Space;
          Keyword(SQL_KEYWORD_ON);
          Space;
          FJoinCondition.TextOutputSql(Output);
        end;
    end;
end;

procedure TSqlJoinedQuery.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FTableRef1);
  FTableRef1.Iterate(Proc);
  Proc(self, FTableRef2);
  FTableRef2.Iterate(Proc);
  if Assigned(FJoinCondition) then
    begin
      Proc(self, FJoinCondition);
      FJoinCondition.Iterate(Proc);
    end;
end;

function TSqlJoinedQuery.Simplify: ASqlQueryExpression;
begin
  FTableRef1 := FTableRef1.Simplify;
  FTableRef2 := FTableRef2.Simplify;
  if Assigned(FJoinCondition) then
    FJoinCondition := FJoinCondition.Simplify;
  Result := self;
end;

procedure TSqlJoinedQuery.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FTableRef1.Prepare(Database, Cursor, Scope);
  FTableRef2.Prepare(Database, Cursor, Scope);
  if Assigned(FJoinCondition) then
    FJoinCondition.Prepare(Database, Cursor, Scope);
end;

function TSqlJoinedQuery.GetCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
var C, D : ASqlCursor;
begin
  C := FTableRef1.GetCursor(Engine, Cursor, Scope);
  D := FTableRef1.GetCursor(Engine, Cursor, Scope);
  Result := TSqlJoinedCursor.Create(FJoinType, C, D, FNatural, FJoinCondition);
end;



{                                                                              }
{ TSqlOrderByQuery                                                             }
{                                                                              }
constructor TSqlOrderByQuery.CreateEx(const Query: ASqlQueryExpression;
    const Items: TSqlSortSpecificationArray);
begin
  inherited Create;
  FQuery := Query;
  FItems := Items;
end;

destructor TSqlOrderByQuery.Destroy;
begin
  FreeAndNilObjectArray(ObjectArray(FItems));
  FreeAndNil(FQuery);
  inherited Destroy;
end;

procedure TSqlOrderByQuery.TextOutputStructureParameters(const Output: TSqlTextOutput);
var I : Integer;
    T : TSqlSortSpecification;
begin
  inherited TextOutputStructureParameters(Output);
  FQuery.TextOutputStructure(Output);
  for I := 0 to Length(FItems) do
    begin
      if I > 0 then
        Output.Space;
      T := FItems[I];
      Output.Identifier(T.ColumnName);
    end;
end;

procedure TSqlOrderByQuery.TextOutputSql(const Output: TSqlTextOutput);
var I : Integer;
    T : TSqlSortSpecification;
begin
  with Output do
    begin
      FQuery.TextOutputSql(Output);
      Space;
      Keyword(SQL_KEYWORD_ORDER);
      Space;
      Keyword(SQL_KEYWORD_BY);
      Space;
      for I := 0 to Length(FItems) do
        begin
          if I > 0 then
            begin
              Symbol(',');
              Space;
            end;
          T := FItems[I];
          Identifier(T.ColumnName);
          if T.OrderSpec = sosDescending then
            begin
              Space;
              Keyword(SQL_KEYWORD_DESC);
            end;
        end;
    end;
end;

procedure TSqlOrderByQuery.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FQuery);
  FQuery.Iterate(Proc);
end;

function TSqlOrderByQuery.Simplify: ASqlQueryExpression;
begin
  FQuery := FQuery.Simplify;
  Result := self;
end;

procedure TSqlOrderByQuery.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FQuery.Prepare(Database, Cursor, Scope);
end;

function TSqlOrderByQuery.GetCursor(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlCursor;
begin
  Result := FQuery.GetCursor(Engine, Cursor, Scope).OrderBy(FItems);
end;



end.

