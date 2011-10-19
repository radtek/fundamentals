{******************************************************************************}
(*                                                                            *)
(*    Library:       Fundamentals SQL                                         *)
(*    Description:   SQL database engine abstractions.                        *)
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
(*    2003/07/14  0.01  Initial version.                                      *)
(*    2005/03/28  0.02  Improvements.                                         *)
(*    2011/07/12  0.03  SQLDatabaseEngine class.                              *)
(*                                                                            *)
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLDatabase;

interface

uses
  { Fundamentals }
  cUtils,

  { SQL }
  cSQLUtils,
  cSQLStructs;



{                                                                              }
{ ASqlCursor                                                                   }
{   Base class for SQL Cursors.                                                }
{   Cursors are used to iterate through and operate on data sets.              }
{                                                                              }
type
  ASqlCursor = class
  protected
    procedure RaiseNextPastEofError;

    // Fields
    function  GetField(const Name: AnsiString): TSqlField; virtual; abstract;
    function  GetFieldCount: Integer; virtual; abstract;
    function  GetFieldByIndex(const Idx: Integer): TSqlField; virtual; abstract;
    function  RequireField(const Name: AnsiString): TSqlField;
    function  RequireFields(const Names: AnsiStringArray): TSqlFieldArray;

  public
    // Iterate
    procedure Reset; virtual; abstract;
    function  Eof: Boolean; virtual; abstract;
    procedure Next; virtual; abstract;

    // Fields
    property  Field[const Name: AnsiString]: TSqlField read GetField; default;
    property  FieldCount: Integer read GetFieldCount;
    property  FieldByIndex[const Idx: Integer]: TSqlField read GetFieldByIndex;
    function  FindField(const Name: AnsiString): TSqlField; virtual;
    function  FindRequiredField(const Name: AnsiString): TSqlField;

    // Grouping
    function  GetUngroupedCursor: ASqlCursor; virtual;
    function  GetFieldGroup(const Name: AnsiString): TSqlGroupLevel; virtual;

    // Filter
    function  FilterOnColumnLiteralComparison(const Column: AnsiString;
              const Operator: TSqlComparisonOperator;
              const Value: ASqlLiteral): ASqlCursor; virtual;
    function  FilterInverseSelection: ASqlCursor; virtual;

    // Order
    function  OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor; virtual;

    // Update
    procedure UpdateRecord; virtual;

    // Delete
    procedure DeleteRecord; virtual;
    procedure Delete; virtual;
  end;
  ESqlCursor = class(ESqlError);
  ASqlCursorArray = Array of ASqlCursor;



{                                                                              }
{ ASqlTable                                                                    }
{   Abstract base class for SQL Tables.                                        }
{                                                                              }
type
  ASqlTable = class
  protected
    // Columns
    function  GetColumns: TSqlColumnDefinitionList; virtual; abstract;

  public
    // Columns
    property  Columns: TSqlColumnDefinitionList read GetColumns;
    procedure AddColumn(const Column: TSqlColumnDefinition); virtual; abstract;

    // Records
    function  RecordCount: Integer; virtual; abstract;

    // Iterate
    function  GetCursor: ASqlCursor; virtual;

    // Insert
    procedure InsertRecord(const Fields: TSqlFieldArray); virtual; abstract;

    // Record Access By Index (??)
    procedure ReadRecord(const RecordIdx: Integer;
              const Values: ASqlLiteralArray); virtual; abstract;
    procedure WriteRecord(const RecordIdx: Integer;
              const Values: ASqlLiteralArray); virtual; abstract;
    procedure DeleteRecord(const RecordIdx: Integer); virtual; abstract;
  end;
  ESqlTable = class(ESqlError);



{                                                                              }
{ ASqlDatabase                                                                 }
{   Abstract base class for SQL Databases.                                     }
{                                                                              }
type
  ASqlDatabaseEngine = class;

  ASqlStoredProcedure = class
  public
    function  GetAsString: AnsiString; virtual; abstract;
    function  Execute(const System: ASqlDatabaseEngine; const Scope: ASqlScope;
              const Parameters: ASqlLiteralArray): ASqlCursor; virtual; abstract;
  end;

  ASqlDatabase = class
  public
    // Connection
    procedure ConnectDefault; virtual; abstract;
    procedure Connect(const ServerName, ConnectionName, UserName: AnsiString); virtual; abstract;
    procedure Disconnect; virtual; abstract;

    // Tables
    procedure CreateTable(const Name: AnsiString;
              const Columns: TSqlColumnDefinitionList); virtual; abstract;
    procedure DropTable(const Name: AnsiString); virtual; abstract;
    function  GetTable(const Name: AnsiString): ASqlTable; virtual; abstract;
    function  HasTable(const Name: AnsiString): Boolean; virtual; abstract;

    // Transactions
    procedure StartTransaction; virtual; abstract;
    procedure CancelTransaction; virtual; abstract;
    procedure CommitTransaction; virtual; abstract;

    // Stored Procedures
    procedure CreateProcedure(const Name: AnsiString;
              const StoredProc: ASqlStoredProcedure); virtual; abstract;
    procedure DropProcedure(const Name: AnsiString); virtual; abstract;
    function  GetProcedure(const Name: AnsiString): ASqlStoredProcedure; virtual; abstract;
    function  HasProcedure(const Name: AnsiString): Boolean; virtual; abstract;
    function  GetProcedureNames: AnsiStringArray; virtual; abstract;
  end;
  ESqlDatabase = class(ESqlError);



  {                                                                            }
  { ASqlDatabaseEngine                                                         }
  {   Abstract base class for SQL database engine.                             }
  {                                                                            }
  ASqlDatabaseEngine = class
  protected
    function  GetCurrentDatabase: ASqlDatabase; virtual; abstract;

  public
    // Databases
    procedure CreateDatabase(const Name: AnsiString;
              const FileName: AnsiString;
              const SizeKB: Integer); virtual; abstract;
    procedure DropDatabase(const Name: AnsiString); virtual; abstract;
    function  HasDatabase(const Name: AnsiString): Boolean; virtual; abstract;
    function  GetDatabase(const Name: AnsiString): ASqlDatabase; virtual; abstract;
    function  GetDatabaseNames: AnsiStringArray; virtual; abstract;

    // Current database
    procedure UseDatabase(const Name: AnsiString); virtual; abstract;
    property  CurrentDatabase: ASqlDatabase read GetCurrentDatabase;

    // Logins
    procedure CreateLogin(const Name, Password: AnsiString); virtual; abstract;
    procedure DropLogin(const Name: AnsiString); virtual; abstract;

    // Login
    procedure Login(const Name, Password: AnsiString); virtual; abstract;
  end;
  ESqlDatabaseEngine = class(ESqlError);



{                                                                              }
{ TSqlTableCursor                                                              }
{   Default SQL Cursor for SQL Tables.                                         }
{                                                                              }
type
  TSqlTableCursor = class(ASqlCursor)
  protected
    FTable            : ASqlTable;
    FRecIdx           : Integer;
    FInverseSelection : Boolean;
    FFields           : TSqlFieldArray;
    FValues           : ASqlLiteralArray;

    procedure SetCurrentRecord;

    function  GetField(const Name: AnsiString): TSqlField; override;
    function  GetFieldCount: Integer; override;
    function  GetFieldByIndex(const Idx: Integer): TSqlField; override;

  public
    constructor Create(const Table: ASqlTable);
    destructor Destroy; override;

    procedure Reset; override;
    function  Eof: Boolean; override;
    procedure Next; override;
    function  FilterInverseSelection: ASqlCursor; override;
    function  OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor; override;
    procedure UpdateRecord; override;
    procedure DeleteRecord; override;
  end;



{                                                                              }
{ TSqlValueCursor                                                              }
{   SQL Cursor for one row of literal values.                                  }
{                                                                              }
type
  TSqlValueCursor = class(ASqlCursor)
  protected
    FFields : TSqlFieldArray;
    FEof    : Boolean;

    function  GetField(const Name: AnsiString): TSqlField; override;
    function  GetFieldCount: Integer; override;
    function  GetFieldByIndex(const Idx: Integer): TSqlField; override;

  public
    constructor Create(const Fields: TSqlFieldArray);

    procedure Reset; override;
    function  Eof: Boolean; override;
    procedure Next; override;
    function  FilterInverseSelection: ASqlCursor; override;
    function  OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor; override;
    procedure UpdateRecord; override;
    procedure DeleteRecord; override;
  end;



{                                                                              }
{ ASqlProxyCursor                                                              }
{   SQL Cursor proxy.                                                          }
{                                                                              }
type
  ASqlProxyCursor = class(ASqlCursor)
  protected
    FCursor : ASqlCursor;

    function  GetField(const Name: AnsiString): TSqlField; override;
    function  GetFieldCount: Integer; override;
    function  GetFieldByIndex(const Idx: Integer): TSqlField; override;

  public
    constructor Create(const Cursor: ASqlCursor);
    destructor Destroy; override;

    procedure Reset; override;
    function  Eof: Boolean; override;
    procedure Next; override;

    function  FindField(const Name: AnsiString): TSqlField; override;

    function  GetUngroupedCursor: ASqlCursor; override;
    function  GetFieldGroup(const Name: AnsiString): TSqlGroupLevel; override;

    function  FilterOnColumnLiteralComparison(const Column: AnsiString;
              const Operator: TSqlComparisonOperator;
              const Value: ASqlLiteral): ASqlCursor; override;
    function  FilterInverseSelection: ASqlCursor; override;

    function  OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor; override;

    procedure UpdateRecord; override;
    procedure DeleteRecord; override;
  end;



{                                                                              }
{ TSqlColumnLiteralComparisonFilterCursor                                      }
{   SQL Column Literal Comparison Filter Cursor.                               }
{                                                                              }
type
  TSqlColumnLiteralComparisonFilterCursor = class(ASqlProxyCursor)
  protected
    FColumn           : AnsiString;
    FOperator         : TSqlComparisonOperator;
    FValue            : ASqlLiteral;
    FEof              : Boolean;
    FInverseSelection : Boolean;

    procedure SetNextRecord;

  public
    constructor Create(const Cursor: ASqlCursor; const Column: AnsiString;
                const Operator: TSqlComparisonOperator;
                const Value: ASqlLiteral);

    function  Eof: Boolean; override;
    procedure Next; override;
    function  FilterInverseSelection: ASqlCursor; override;
  end;



{                                                                              }
{ TSqlFilterAllCursor                                                          }
{   SQL Cursor that filters out all records from another cursor.               }
{                                                                              }
type
  TSqlFilterAllCursor = class(ASqlProxyCursor)
  protected
    FInverseSelection : Boolean;

  public
    function  Eof: Boolean; override;
    procedure Next; override;
    function  FilterInverseSelection: ASqlCursor; override;
  end;



{                                                                              }
{ ASqlProxyCursorWithFields                                                    }
{   SQL Cursor proxy with field storage.                                       }
{                                                                              }
type
  ASqlProxyCursorWithFields = class(ASqlProxyCursor)
  protected
    FFields      : TSqlFieldArray;
    FFieldsOwner : Boolean;

    function  GetField(const Name: AnsiString): TSqlField; override;
    function  GetFieldCount: Integer; override;
    function  GetFieldByIndex(const Idx: Integer): TSqlField; override;

  public
    constructor Create(const Cursor: ASqlCursor; const Fields: TSqlFieldArray;
                const FieldsOwner: Boolean);
    destructor Destroy; override;

    function  FindField(const Name: AnsiString): TSqlField; override;
  end;



{                                                                              }
{ TSqlSelectedColumnCursor                                                     }
{   Cursor with columns selected from another cursor.                          }
{                                                                              }
type
  TSqlSelectedColumnCursor = class(ASqlProxyCursorWithFields)
  protected
    FColumnList : AnsiStringArray;

  public
    constructor Create(const Cursor: ASqlCursor; const ColumnList: AnsiStringArray);
  end;



{                                                                              }
{ TSqlDistinctCursor                                                           }
{   Cursor returning only distinct records from another cursor.                }
{                                                                              }
type
  TSqlDistinctCursor = class(ASqlProxyCursor)
  protected
    FValues : ASqlLiteralArray;

    function  GetSortOrderItemArray: TSqlSortSpecificationArray;
    procedure InitialiseValues;
    function  IsSameValues: Boolean;
    procedure AssignValues;

  public
    constructor Create(const Cursor: ASqlCursor);
    destructor Destroy; override;

    procedure Next; override;
  end;



{                                                                              }
{ TSqlGroupedCursor                                                            }
{   Cursor for GROUP BY groupings.                                             }
{                                                                              }
type
  TSqlGroupedCursor = class(ASqlProxyCursor)
  protected
    FGroupByColumns  : AnsiStringArray;
    FUngroupedCursor : ASqlCursor;

  public
    constructor Create(const Cursor: ASqlCursor; const GroupByColumns: AnsiStringArray);

    function  GetUngroupedCursor: ASqlCursor; override;
  end;



{                                                                              }
{ TSqlFromMultipleCursor                                                       }
{   Cursor to iterate through all record combinations for multiple cursors.    }
{                                                                              }
type
  TSqlFromMultipleCursor = class(ASqlCursor)
  protected
    FCursors : ASqlCursorArray;

    function  GetField(const Name: AnsiString): TSqlField; override;
    function  GetFieldCount: Integer; override;
    function  GetFieldByIndex(const Idx: Integer): TSqlField; override;

  public
    constructor Create(const Cursors: ASqlCursorArray);
    destructor Destroy; override;

    procedure Reset; override;
    function  Eof: Boolean; override;
    procedure Next; override;
  end;



implementation

uses
  { System }
  SysUtils;



{                                                                              }
{ ASqlCursor                                                                   }
{                                                                              }
procedure ASqlCursor.RaiseNextPastEofError;
begin
  raise ESqlCursor.Create('Next past Eof');
end;

function ASqlCursor.RequireField(const Name: AnsiString): TSqlField;
begin
  Result := GetField(Name);
  if not Assigned(Result) then
    raise ESqlCursor.CreateFmt('Field not defined: %s', [Name]);
end;

function ASqlCursor.RequireFields(const Names: AnsiStringArray): TSqlFieldArray;
var I, L : Integer;
begin
  L := Length(Names);
  SetLength(Result, L);
  for I := 0 to L - 1 do
    Result[I] := RequireField(Names[I]);
end;

function ASqlCursor.FindField(const Name: AnsiString): TSqlField;
var C : ASqlCursor;
begin
  Result := GetField(Name);
  if Assigned(Result) then
    exit;
  C := GetUngroupedCursor;
  if Assigned(C) then
    Result := C.FindField(Name);
end;

function ASqlCursor.FindRequiredField(const Name: AnsiString): TSqlField;
begin
  Result := FindField(Name);
  if not Assigned(Result) then
    raise ESqlCursor.CreateFmt('Field not defined: %s', [Name]);
end;

function ASqlCursor.GetUngroupedCursor: ASqlCursor;
begin
  Result := nil;
end;

function ASqlCursor.GetFieldGroup(const Name: AnsiString): TSqlGroupLevel;
var C : ASqlCursor;
begin
  if Assigned(GetField(Name)) then
    Result := sglCursor
  else
    begin
      C := GetUngroupedCursor;
      if Assigned(C) and Assigned(C.GetField(Name)) then
        Result := sglUngrouped
      else
        Result := sglInvalid;
    end;
end;

function ASqlCursor.FilterOnColumnLiteralComparison(const Column: AnsiString;
    const Operator: TSqlComparisonOperator;
    const Value: ASqlLiteral): ASqlCursor;
begin
  Result := TSqlColumnLiteralComparisonFilterCursor.Create(self, Column, Operator, Value);
end;

function ASqlCursor.FilterInverseSelection: ASqlCursor;
begin
  raise ESqlCursor.CreateFmt('%s: FilterInverseSelection not implemented', [ClassToSqlStructureName(self.ClassType)]);
end;

function ASqlCursor.OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor;
begin
  raise ESqlCursor.CreateFmt('%s: OrderBy not implemented', [ClassToSqlStructureName(self.ClassType)]);
end;

procedure ASqlCursor.UpdateRecord;
begin
  raise ESqlCursor.CreateFmt('%s: UpdateRecord not implemented', [ClassToSqlStructureName(self.ClassType)]);
end;

procedure ASqlCursor.DeleteRecord;
begin
  raise ESqlCursor.CreateFmt('%s: DeleteRecord not implemented', [ClassToSqlStructureName(self.ClassType)]);
end;

procedure ASqlCursor.Delete;
begin
  while not Eof do
    begin
      DeleteRecord;
      Next;
    end;
end;



{                                                                              }
{ ASqlTable                                                                    }
{                                                                              }
function ASqlTable.GetCursor: ASqlCursor;
begin
  Result := TSqlTableCursor.Create(self);
end;



{                                                                              }
{ TSqlTableCursor                                                              }
{                                                                              }
constructor TSqlTableCursor.Create(const Table: ASqlTable);
var I, L : Integer;
begin
  inherited Create;
  Assert(Assigned(Table));
  FTable := Table;
  FRecIdx := 0;
  L := FTable.Columns.Count;
  SetLength(FFields, L);
  SetLength(FValues, L);
  for I := 0 to L - 1 do
    begin
      FValues[I] := SqlLiteralClassFromDataType(FTable.Columns.Item[I].TypeDefinition.DataType).Create;
      FFields[I] := TSqlField.Create(FTable.Columns.Item[I], FValues[I], True);
    end;
  SetCurrentRecord;
end;

destructor TSqlTableCursor.Destroy;
begin
  FValues := nil;
  FreeAndNilObjectArray(ObjectArray(FFields));
  inherited Destroy;
end;

procedure TSqlTableCursor.Reset;
begin
  FRecIdx := 0;
end;

function TSqlTableCursor.Eof: Boolean;
begin
  if FInverseSelection then
    Result := True
  else
    Result := (FRecIdx >= FTable.RecordCount);
end;

procedure TSqlTableCursor.Next;
begin
  if Eof then
    RaiseNextPastEofError;
  Inc(FRecIdx);
  SetCurrentRecord;
end;

procedure TSqlTableCursor.SetCurrentRecord;
var I : Integer;
begin
  for I := 0 to Length(FValues) - 1 do
    FValues[I].AssignDefaultValue;
  if Eof then
    exit;
  FTable.ReadRecord(FRecIdx, FValues);
end;

function TSqlTableCursor.GetField(const Name: AnsiString): TSqlField;
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

function TSqlTableCursor.GetFieldCount: Integer;
begin
  Result := FTable.Columns.Count;
end;

function TSqlTableCursor.GetFieldByIndex(const Idx: Integer): TSqlField;
begin
  Result := FFields[Idx];
end;

function TSqlTableCursor.FilterInverseSelection: ASqlCursor;
begin
  FInverseSelection := not FInverseSelection;
  Result := self;
end;

function TSqlTableCursor.OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor;
begin
  Result := inherited OrderBy(Order);
end;

procedure TSqlTableCursor.UpdateRecord;
begin
  if Eof then
    raise ESqlCursor.Create('No current record');
  FTable.WriteRecord(FRecIdx, FValues);
end;

procedure TSqlTableCursor.DeleteRecord;
begin
  inherited DeleteRecord;
end;



{                                                                              }
{ TSqlValueCursor                                                              }
{                                                                              }
constructor TSqlValueCursor.Create(const Fields: TSqlFieldArray);
begin
  inherited Create;
  FFields := Fields;
  FEof := False;
end;

function TSqlValueCursor.GetField(const Name: AnsiString): TSqlField;
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

function TSqlValueCursor.GetFieldCount: Integer;
begin
  Result := Length(FFields);
end;

function TSqlValueCursor.GetFieldByIndex(const Idx: Integer): TSqlField;
begin
  Result := FFields[Idx];
end;

procedure TSqlValueCursor.Reset;
begin
  FEof := False;
end;

function TSqlValueCursor.Eof: Boolean;
begin
  Result := FEof;
end;

procedure TSqlValueCursor.Next;
begin
  if FEof then
    raise ESqlError.Create('Next past EOF');
  FEof := True;
end;

function TSqlValueCursor.FilterInverseSelection: ASqlCursor;
begin
  Result := inherited FilterInverseSelection;
end;

function TSqlValueCursor.OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor;
begin
  Result := inherited OrderBy(Order);
end;

procedure TSqlValueCursor.UpdateRecord;
begin
  inherited UpdateRecord;
end;

procedure TSqlValueCursor.DeleteRecord;
begin
  inherited DeleteRecord;
end;



{                                                                              }
{ ASqlProxyCursor                                                              }
{                                                                              }
constructor ASqlProxyCursor.Create(const Cursor: ASqlCursor);
begin
  inherited Create;
  Assert(Assigned(Cursor));
  FCursor := Cursor;
end;

destructor ASqlProxyCursor.Destroy;
begin
  FreeAndNil(FCursor);
  inherited Destroy;
end;

function ASqlProxyCursor.GetField(const Name: AnsiString): TSqlField;
begin
  Result := FCursor.GetField(Name);
end;

function ASqlProxyCursor.GetFieldCount: Integer;
begin
  Result := FCursor.GetFieldCount;
end;

function ASqlProxyCursor.GetFieldByIndex(const Idx: Integer): TSqlField;
begin
  Result := FCursor.GetFieldByIndex(Idx);
end;

procedure ASqlProxyCursor.Reset;
begin
  FCursor.Reset;
end;

function ASqlProxyCursor.Eof: Boolean;
begin
  Result := FCursor.Eof;
end;

procedure ASqlProxyCursor.Next;
begin
  FCursor.Next;
end;

function ASqlProxyCursor.FindField(const Name: AnsiString): TSqlField;
begin
  Result := FCursor.FindField(Name);
end;

function ASqlProxyCursor.GetUngroupedCursor: ASqlCursor;
begin
  Result := FCursor.GetUngroupedCursor;
end;

function ASqlProxyCursor.GetFieldGroup(const Name: AnsiString): TSqlGroupLevel;
var C : ASqlCursor;
begin
  Result := FCursor.GetFieldGroup(Name);
  if (Result in [sglGrouped, sglCursor, sglUngrouped]) then
    exit;
  C := GetUngroupedCursor;
  if not Assigned(C) then
    Result := sglInvalid
  else
    Case C.GetFieldGroup(Name) of
      sglCursor  : Result := sglUngrouped;
      sglGrouped : Result := sglCursor;
    else
      Result := sglInvalid;
    end;
end;

function ASqlProxyCursor.FilterOnColumnLiteralComparison(const Column: AnsiString;
    const Operator: TSqlComparisonOperator; const Value: ASqlLiteral): ASqlCursor;
begin
  Result := FCursor.FilterOnColumnLiteralComparison(Column, Operator, Value);
end;

function ASqlProxyCursor.FilterInverseSelection: ASqlCursor;
begin
  Result := FCursor.FilterInverseSelection;
end;

function ASqlProxyCursor.OrderBy(const Order: TSqlSortSpecificationArray): ASqlCursor;
begin
  Result := FCursor.OrderBy(Order);
end;

procedure ASqlProxyCursor.UpdateRecord;
begin
  FCursor.UpdateRecord;
end;

procedure ASqlProxyCursor.DeleteRecord;
begin
  FCursor.DeleteRecord;
end;



{                                                                              }
{ TSqlColumnLiteralComparisonFilterCursor                                      }
{                                                                              }
constructor TSqlColumnLiteralComparisonFilterCursor.Create(const Cursor: ASqlCursor;
    const Column: AnsiString; const Operator: TSqlComparisonOperator;
    const Value: ASqlLiteral);
begin
  inherited Create(Cursor);
  FColumn := Column;
  FOperator := Operator;
  FValue := Value;
  FEof := False;
  SetNextRecord;
end;

procedure TSqlColumnLiteralComparisonFilterCursor.SetNextRecord;
var F : TSqlField;
    C : TCompareResult;
    R : Boolean;
begin
  while not FCursor.Eof do
    begin
      F := FCursor.FindField(FColumn);
      C := F.Value.Compare(FValue);
      Case FOperator of
        scoEqual          : R := (C = crEqual);
        scoNotEqual       : R := (C <> crEqual);
        scoLess           : R := (C = crLess);
        scoGreater        : R := (C = crGreater);
        scoLessOrEqual    : R := (C in [crLess, crEqual]);
        scoGreaterOrEqual : R := (C in [crGreater, crEqual]);
      else
        R := True;
      end;
      R := (R and not FInverseSelection) or
           (not R and FInverseSelection);
      if R then
        exit;
      FCursor.Next;
    end;
  FEof := True;
end;

function TSqlColumnLiteralComparisonFilterCursor.Eof: Boolean;
begin
  Result := FEof;
end;

procedure TSqlColumnLiteralComparisonFilterCursor.Next;
begin
  if FEof then
    raise ESqlError.Create('Next past EOF');
  FCursor.Next;
  SetNextRecord;
end;

function TSqlColumnLiteralComparisonFilterCursor.FilterInverseSelection: ASqlCursor;
begin
  FInverseSelection := not FInverseSelection;
  Result := self;
end;



{                                                                              }
{ TSqlFilterAllCursor                                                          }
{                                                                              }
function TSqlFilterAllCursor.Eof: Boolean;
begin
  if FInverseSelection then
    Result := FCursor.Eof
  else
    Result := True;
end;

procedure TSqlFilterAllCursor.Next;
begin
  if FInverseSelection then
    FCursor.Next
  else
    RaiseNextPastEofError;
end;

function TSqlFilterAllCursor.FilterInverseSelection: ASqlCursor;
begin
  FInverseSelection := not FInverseSelection;
  Result := self;
end;



{                                                                              }
{ ASqlProxyCursorWithFields                                                    }
{                                                                              }
constructor ASqlProxyCursorWithFields.Create(const Cursor: ASqlCursor;
    const Fields: TSqlFieldArray; const FieldsOwner: Boolean);
begin
  inherited Create(Cursor);
  FFields := Fields;
  FFieldsOwner := FieldsOwner;
end;

destructor ASqlProxyCursorWithFields.Destroy;
begin
  if FFieldsOwner then
    FreeObjectArray(FFields);
  inherited Destroy;
end;

function ASqlProxyCursorWithFields.GetField(const Name: AnsiString): TSqlField;
var I : Integer;
    F : TSqlField;
begin
  for I := 0 to Length(FFields) - 1 do
    begin
      F := FFields[I];
      if F.Column.IsName(Name) then
        begin
          Result := F;
          exit;
        end;
    end;
  Result := nil;
end;

function ASqlProxyCursorWithFields.GetFieldCount: Integer;
begin
  Result := Length(FFields);
end;

function ASqlProxyCursorWithFields.GetFieldByIndex(const Idx: Integer): TSqlField;
begin
  Result := FFields[Idx];
end;

function ASqlProxyCursorWithFields.FindField(const Name: AnsiString): TSqlField;
var C : ASqlCursor;
begin
  Result := GetField(Name);
  if Assigned(Result) then
    exit;
  Result := FCursor.FindField(Name);
  if Assigned(Result) then
    exit;
  C := GetUngroupedCursor;
  if Assigned(C) then
    Result := C.FindField(Name);
end;



{                                                                              }
{ TSqlSelectedColumnCursor                                                     }
{                                                                              }
constructor TSqlSelectedColumnCursor.Create(const Cursor: ASqlCursor;
    const ColumnList: AnsiStringArray);
begin
  Assert(Assigned(Cursor));
  inherited Create(Cursor, Cursor.RequireFields(ColumnList), False);
  FColumnList := ColumnList;
end;



{                                                                              }
{ TSqlDistinctCursor                                                           }
{                                                                              }
constructor TSqlDistinctCursor.Create(const Cursor: ASqlCursor);
begin
  Assert(Assigned(Cursor));
  inherited Create(Cursor.OrderBy(GetSortOrderItemArray));
  if Cursor.Eof then
    exit;
  InitialiseValues;
end;

destructor TSqlDistinctCursor.Destroy;
begin
  FreeObjectArray(FValues);
  inherited Destroy;
end;

function TSqlDistinctCursor.GetSortOrderItemArray: TSqlSortSpecificationArray;
var I, L : Integer;
    R    : TSqlSortSpecificationArray;
begin
  L := FCursor.FieldCount;
  SetLength(R, L);
  for I := 0 to L - 1 do
    R[I] := TSqlSortSpecification.CreateEx(FCursor.FieldByIndex[I].Column.Name,
        sosUndefined);
  Result := R;
end;

procedure TSqlDistinctCursor.InitialiseValues;
var I, L : Integer;
begin
  L := FCursor.FieldCount;
  SetLength(FValues, L);
  for I := 0 to L - 1 do
    FValues[I] := FCursor.FieldByIndex[I].Value.Duplicate;
end;

function TSqlDistinctCursor.IsSameValues: Boolean;
var I : Integer;
begin
  for I := 0 to Length(FValues) - 1 do
    if FValues[I].Compare(FCursor.FieldByIndex[I].Value) <> crEqual then
      begin
        Result := False;
        exit;
      end;
  Result := True;
end;

procedure TSqlDistinctCursor.AssignValues;
var I : Integer;
begin
  for I := 0 to Length(FValues) - 1 do
    FValues[I].AssignLiteral(FCursor.FieldByIndex[I].Value);
end;

procedure TSqlDistinctCursor.Next;
begin
  repeat
    FCursor.Next;
    if FCursor.Eof then
      exit;
  until not IsSameValues;
  AssignValues;
end;



{                                                                              }
{ TSqlGroupedCursor                                                            }
{                                                                              }
constructor TSqlGroupedCursor.Create(const Cursor: ASqlCursor; const GroupByColumns: AnsiStringArray);
begin
  Assert(Assigned(Cursor));
  inherited Create(TSqlDistinctCursor.Create(
      TSqlSelectedColumnCursor.Create(Cursor, GroupByColumns)));
  FGroupByColumns := GroupByColumns;
  FUngroupedCursor := Cursor;
end;

function TSqlGroupedCursor.GetUngroupedCursor: ASqlCursor;
begin
  Result := FUngroupedCursor;
end;



{                                                                              }
{ TSqlFromMultipleCursor                                                       }
{                                                                              }
constructor TSqlFromMultipleCursor.Create(const Cursors: ASqlCursorArray);
begin
  inherited Create;
  FCursors := Cursors;
end;

destructor TSqlFromMultipleCursor.Destroy;
begin
  FreeObjectArray(FCursors);
  inherited Destroy;
end;

function TSqlFromMultipleCursor.GetField(const Name: AnsiString): TSqlField;
var I : Integer;
begin
  for I := 0 to Length(FCursors) - 1 do
    begin
      Result := FCursors[I].Field[Name];
      if Assigned(Result) then
        exit;
    end;
  Result := nil;
end;

function TSqlFromMultipleCursor.GetFieldByIndex(const Idx: Integer): TSqlField;
var I, J, L : Integer;
begin
  J := Idx;
  for I := 0 to Length(FCursors) - 1 do
    begin
      L := FCursors[I].FieldCount;
      if J >= L then
        Dec(J, L)
      else
        begin
          Result := FCursors[I].FieldByIndex[J];
          exit;
        end;
    end;
  Result := nil;
end;

function TSqlFromMultipleCursor.GetFieldCount: Integer;
var I : Integer;
begin
  Result := 0;
  for I := 0 to Length(FCursors) - 1 do
    Inc(Result, FCursors[I].FieldCount);
end;

procedure TSqlFromMultipleCursor.Reset;
var I : Integer;
begin
  for I := 0 to Length(FCursors) - 1 do
    FCursors[I].Reset;
end;

function TSqlFromMultipleCursor.Eof: Boolean;
begin
  Result := FCursors[0].Eof;
end;

procedure TSqlFromMultipleCursor.Next;
var I : Integer;
    C : ASqlCursor;
begin
  if FCursors[0].Eof then
    RaiseNextPastEofError;
  for I := Length(FCursors) - 1 downto 0 do
    begin
      C := FCursors[I];
      C.Next;
      if not C.Eof then
        exit;
      if I > 0 then
        C.Reset;
    end;
end;



end.

