{******************************************************************************}
(*                                                                            *)
(*    Library:       Fundamentals SQL                                         *)
(*    Description:   SQL data structures.                                     *)
(*    Version:       1.03                                                     *)
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
(*    2005/04/01  1.01  Development.                                          *)
(*    2005/04/08  1.02  Development.                                          *)
(*    2009/10/17  1.03  Development.                                          *)
(*                                                                            *)
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLStructs;

interface

uses
  { System }
  SysUtils,

  { Fundamentals }
  cUtils,
  cStreams,
  cDataStructs,

  { SQL }
  cSQLUtils,
  cSQLDataTypes;



{                                                                              }
{ TSqlTextOutput                                                               }
{   Base implementation for SQL Text Output.                                   }
{                                                                              }
type
  TSqlTextOutput = class
  protected
    FText        : TLongStringWriter;
    FIndentCount : Integer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Keyword(const Keyword: AnsiString); virtual;
    procedure Space; virtual;
    procedure NewLine(const Count: Integer = 1); virtual;
    procedure Symbol(const Symbol: AnsiString); virtual;
    procedure Identifier(const Identifier: AnsiString); virtual;
    procedure Literal(const Literal: AnsiString); virtual;
    procedure Indent; virtual;
    procedure Unindent; virtual;

    procedure StructureNameBegin; virtual;
    procedure StructureNameEnd; virtual;
    procedure StructureName(const Name: AnsiString); virtual;
    procedure StructureParamBegin(const DoIndent: Boolean = True); virtual;
    procedure StructureParamEnd(const DoUnindent: Boolean = True); virtual;

    function  GetAsString: AnsiString;
  end;



{                                                                              }
{ ASqlLiteral                                                                  }
{   Base class for SQL Literals.                                               }
{                                                                              }
type
  ASqlLiteral = class
  protected
    FReferenceCount : Integer;
    FNullValue      : Boolean;

    procedure Init; virtual;
    function  GetAsInteger: Int64; virtual;
    procedure SetAsInteger(const Value: Int64); virtual;
    function  GetAsFloat: Extended; virtual;
    procedure SetAsFloat(const Value: Extended); virtual;
    function  GetAsString: AnsiString; virtual;
    procedure SetAsString(const Value: AnsiString); virtual;
    function  GetAsNString: WideString; virtual;
    procedure SetAsNString(const Value: WideString); virtual;
    function  GetAsBoolean: TSqlBooleanValue; virtual;
    procedure SetAsBoolean(const Value: TSqlBooleanValue); virtual;
    function  GetAsDateTime: TDateTime; virtual;
    procedure SetAsDateTime(const Value: TDateTime); virtual;
    function  GetAsSql: AnsiString; virtual;
    procedure SetAsSql(const Value: AnsiString); virtual;

  public
    constructor Create;
    constructor CreateEx(const Value: ASqlLiteral);

    procedure AddReference;
    procedure ReleaseReference;

    procedure AssignLiteral(const Source: ASqlLiteral); virtual;
    procedure AssignNullValue;
    procedure AssignDefaultValue; virtual;
    procedure AssignVariant(const Value: TSqlVariant); virtual;
    function  IsNullValue: Boolean;
    function  IsDataType(const DataType: TSqlDataType): Boolean; virtual;
    function  IsIntegerType: Boolean; virtual;
    function  IsRealType: Boolean; virtual;
    function  IsStringType: Boolean; virtual;
    function  IsBooleanType: Boolean; virtual;
    function  IsDateTimeType: Boolean; virtual;
    function  Duplicate: ASqlLiteral;
    function  DuplicateAsType(const DataType: TSqlDataType): ASqlLiteral;

    property  AsInteger: Int64 read GetAsInteger write SetAsInteger;
    property  AsFloat: Extended read GetAsFloat write SetAsFloat;
    property  AsString: AnsiString read GetAsString write SetAsString;
    property  AsNString: WideString read GetAsNString write SetAsNString;
    property  AsBoolean: TSqlBooleanValue read GetAsBoolean write SetAsBoolean;
    property  AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;

    property  AsSql: AnsiString read GetAsSql write SetAsSql;

    procedure Negate; virtual;
    procedure Abs; virtual;
    function  Add(const Value: ASqlLiteral): ASqlLiteral; virtual;
    function  Subtract(const Value: ASqlLiteral): ASqlLiteral; virtual;
    function  Multiply(const Value: ASqlLiteral): ASqlLiteral; virtual;
    function  Divide(const Value: ASqlLiteral): ASqlLiteral; virtual;
    function  Compare(const Value: ASqlLiteral): TCompareResult; virtual;
  end;
  ASqlLiteralClass = Class of ASqlLiteral;
  ASqlLiteralArray = Array of ASqlLiteral;
  ESqlLiteral = class(Exception);

procedure UniqueLiteral(var Literal: ASqlLiteral);



{                                                                              }
{ ASqlScope                                                                    }
{   Base class for SQL Scope.                                                  }
{                                                                              }
type
  ASqlScope = class
  public
    procedure AddObject(const Name: AnsiString; const Obj: TObject); virtual; abstract;
    function  GetObject(const Name: AnsiString): TObject; virtual; abstract;
    function  RequireObject(const Name: AnsiString): TObject;
    function  RequireLiteral(const Name: AnsiString): ASqlLiteral;
  end;
  ESqlScope = class(ESqlError);



{                                                                              }
{ TSqlMemoryScope                                                              }
{   SQL Scope implemented in memory.                                           }
{                                                                              }
type
  TSqlMemoryScope = class(ASqlScope)
  protected
    FScope : TObjectDictionaryA;

  public
    constructor Create;
    destructor Destroy; override;

    procedure AddObject(const Name: AnsiString; const Obj: TObject); override;
    function  GetObject(const Name: AnsiString): TObject; override;
  end;



{                                                                              }
{ TSqlDataTypeDefinition                                                       }
{   SQL Data Type Definition.                                                  }
{                                                                              }
type
  TSqlSingleDateTimeField = class
    Field         : TSqlDateTimeField;
    Precision     : Integer;
    FracPrecision : Integer;
  end;
  TSqlIntervalQualifier = class
    StartField : TSqlDateTimeField;
    EndField   : TSqlSingleDateTimeField;
  end;
  TSqlDataTypeDefinition = class
  protected
    FDataType     : TSqlDataType;
    FLength       : Integer;
    FPrecision    : Integer;
    FScale        : Integer;
    FWithTimeZone : Boolean;

  public
    Qualifier : TSqlIntervalQualifier;

    constructor Create;
    constructor CreateEx(const DataType: TSqlDataType;
                const Length: Integer = 0; const Precision: Integer = 0;
                const Scale: Integer = 0; const WithTimeZone: Boolean = False);

    property  DataType: TSqlDataType read FDataType write FDataType;
    property  Length: Integer read FLength write FLength;
    property  Precision: Integer read FPrecision write FPrecision;
    property  Scale: Integer read FScale write FScale;
    property  WithTimeZone: Boolean read FWithTimeZone write FWithTimeZone;

    procedure TextOutputStructure(const Output: TSqlTextOutput);
    procedure TextOutputSql(const Output: TSqlTextOutput);

    function  CreateLiteralInstance: ASqlLiteral;
  end;



{                                                                              }
{ TSqlColumnDefinition                                                         }
{   SQL Column Definition.                                                     }
{                                                                              }
type
  TSqlColumnDefinition = class
  protected
    FName           : AnsiString;
    FTypeDefinition : TSqlDataTypeDefinition;
    FAllowNull      : Boolean;
    FUnique         : Boolean;
    FPrimaryKey     : Boolean;
    FDefaultValue   : ASqlLiteral;

  public
    constructor Create;
    constructor CreateEx(const Name: AnsiString;
                const TypeDefinition: TSqlDataTypeDefinition;
                const AllowNull: Boolean = True;
                const Unique: Boolean = False;
                const PrimaryKey: Boolean = False;
                const DefaultValue: ASqlLiteral = nil);
    destructor Destroy; override;

    property  Name: AnsiString read FName write FName;
    property  TypeDefinition: TSqlDataTypeDefinition read FTypeDefinition write FTypeDefinition;
    property  AllowNull: Boolean read FAllowNull write FAllowNull;
    property  Unique: Boolean read FUnique write FUnique;
    property  PrimaryKey: Boolean read FPrimaryKey write FPrimaryKey;

    procedure TextOutputSql(const Output: TSqlTextOutput);
    function  IsName(const Name: AnsiString): Boolean;

    procedure SetDefaultValue(const Value: ASqlLiteral);
  end;
  TSqlColumnDefinitionArray = Array of TSqlColumnDefinition;



{                                                                              }
{ TSqlColumnDefinitionList                                                     }
{   List of SQL Column Definitions.                                            }
{                                                                              }
type
  TSqlColumnDefinitionList = class
  protected
    FList : TSqlColumnDefinitionArray;

    function  GetCount: Integer;
    function  GetItem(const Idx: Integer): TSqlColumnDefinition;

  public
    ColumnOwner : Boolean;

    constructor Create;
    destructor Destroy; override;

    property  Count: Integer read GetCount;
    procedure Add(const Column: TSqlColumnDefinition);
    property  Item[const Idx: Integer]: TSqlColumnDefinition read GetItem; default;
    function  GetColumnByName(const Name: AnsiString): TSqlColumnDefinition;

    procedure TextOutputSql(const Output: TSqlTextOutput);
  end;



{                                                                              }
{ TSqlSortSpecification                                                        }
{                                                                              }
type
  TSqlSortSpecification = class
  protected
    FColumnName : AnsiString;
    FOrderSpec  : TSqlOrderSpecification;

  public
    ColumnKey     : Int64;
    CollateClause : AnsiString;

    constructor CreateEx(const ColumnName: AnsiString; const OrderSpec: TSqlOrderSpecification);

    property  ColumnName: AnsiString read FColumnName write FColumnName;
    property  OrderSpec: TSqlOrderSpecification read FOrderSpec write FOrderSpec;
  end;
  TSqlSortSpecificationArray = Array of TSqlSortSpecification;



{                                                                              }
{ TSqlField                                                                    }
{   General Purpose SQL Field Structure (Column, Value)                        }
{                                                                              }
type
  TSqlField = class
  protected
    FColumn     : TSqlColumnDefinition;
    FValue      : ASqlLiteral;
    FValueOwner : Boolean;

    function  GetColumn: TSqlColumnDefinition; virtual;
    function  GetValue: ASqlLiteral; virtual;

  public
    constructor Create(const Column: TSqlColumnDefinition;
                const Value: ASqlLiteral; const ValueOwner: Boolean);
    destructor Destroy; override;

    property  Column: TSqlColumnDefinition read GetColumn;
    property  Value: ASqlLiteral read GetValue write FValue;
  end;
  TSqlFieldArray = Array of TSqlField;



{                                                                              }
{ TSqlNull                                                                     }
{   SQL NULL Literal                                                           }
{                                                                              }
type
  TSqlNull = class(ASqlLiteral)
  protected
    function  GetAsSql: AnsiString; override;

  public
    constructor Create;

    function  Compare(const Value: ASqlLiteral): TCompareResult; override;
  end;



{                                                                              }
{ TSqlInteger                                                                  }
{   SQL Integer Literal                                                        }
{                                                                              }
type
  TSqlInteger = class(ASqlLiteral)
  protected
    FValue : Int64;

    function  GetAsInteger: Int64; override;
    procedure SetAsInteger(const Value: Int64); override;
    function  GetAsFloat: Extended; override;
    procedure SetAsFloat(const Value: Extended); override;
    function  GetAsString: AnsiString; override;
    procedure SetAsString(const Value: AnsiString); override;
    function  GetAsBoolean: TSqlBooleanValue; override;
    procedure SetAsBoolean(const Value: TSqlBooleanValue); override;

  public
    constructor Create(const Value: Int64);

    property  Value: Int64 read FValue write FValue;

    procedure AssignLiteral(const Source: ASqlLiteral); override;
    function  IsDataType(const DataType: TSqlDataType): Boolean; override;
    function  IsIntegerType: Boolean; override;

    procedure Negate; override;
    procedure Abs; override;
    function  Add(const Value: ASqlLiteral): ASqlLiteral; override;
    function  Subtract(const Value: ASqlLiteral): ASqlLiteral; override;
    function  Multiply(const Value: ASqlLiteral): ASqlLiteral; override;
    function  Divide(const Value: ASqlLiteral): ASqlLiteral; override;
    function  Compare(const Value: ASqlLiteral): TCompareResult; override;
  end;



{                                                                              }
{ TSqlFloat                                                                    }
{   SQL Float Literal                                                          }
{                                                                              }
type
  TSqlFloat = class(ASqlLiteral)
  protected
    FValue : Extended;

    function  GetAsInteger: Int64; override;
    procedure SetAsInteger(const Value: Int64); override;
    function  GetAsFloat: Extended; override;
    procedure SetAsFloat(const Value: Extended); override;
    function  GetAsString: AnsiString; override;
    procedure SetAsString(const Value: AnsiString); override;

  public
    constructor Create(const Value: Extended);

    property  Value: Extended read FValue write FValue;

    procedure AssignLiteral(const Source: ASqlLiteral); override;
    function  IsDataType(const DataType: TSqlDataType): Boolean; override;
    function  IsRealType: Boolean; override;

    procedure Negate; override;
    procedure Abs; override;
    function  Add(const Value: ASqlLiteral): ASqlLiteral; override;
    function  Subtract(const Value: ASqlLiteral): ASqlLiteral; override;
    function  Multiply(const Value: ASqlLiteral): ASqlLiteral; override;
    function  Divide(const Value: ASqlLiteral): ASqlLiteral; override;
    function  Compare(const Value: ASqlLiteral): TCompareResult; override;
  end;



{                                                                              }
{ TSqlString                                                                   }
{   SQL AnsiString Literal                                                     }
{                                                                              }
type
  TSqlString = class(ASqlLiteral)
  protected
    FValue   : AnsiString;
    FCharSet : AnsiString;

    function  GetAsString: AnsiString; override;
    procedure SetAsString(const Value: AnsiString); override;
    function  GetAsSql: AnsiString; override;

  public
    constructor Create(const Value: AnsiString; const CharSet: AnsiString = '');

    property  Value: AnsiString read FValue write FValue;

    procedure AssignLiteral(const Source: ASqlLiteral); override;
    function  IsDataType(const DataType: TSqlDataType): Boolean; override;
    function  IsStringType: Boolean; override;

    function  Compare(const Value: ASqlLiteral): TCompareResult; override;
  end;



{                                                                              }
{ TSqlNString                                                                  }
{   SQL National AnsiString (Unicode AnsiString)                               }
{                                                                              }
type
  TSqlNString = class(ASqlLiteral)
  protected
    FValue : WideString;

    function  GetAsString: AnsiString; override;
    procedure SetAsString(const Value: AnsiString); override;
    function  GetAsNString: WideString; override;
    procedure SetAsNString(const Value: WideString); override;
    function  GetAsSql: AnsiString; override;

  public
    constructor Create(const Value: WideString);

    property  Value: WideString read FValue write FValue;

    procedure AssignLiteral(const Source: ASqlLiteral); override;
    function  IsDataType(const DataType: TSqlDataType): Boolean; override;
    function  IsStringType: Boolean; override;

    function  Compare(const Value: ASqlLiteral): TCompareResult; override;
  end;



{                                                                              }
{ TSqlBoolean                                                                  }
{   SQL Boolean Literal                                                        }
{                                                                              }
type
  TSqlBoolean = class(ASqlLiteral)
  protected
    FValue : TSqlBooleanValue;

    function  GetAsBoolean: TSqlBooleanValue; override;
    procedure SetAsBoolean(const Value: TSqlBooleanValue); override;

  public
    constructor Create(const Value: TSqlBooleanValue); overload;
    constructor Create(const Value: Boolean); overload;

    property  Value: TSqlBooleanValue read FValue write FValue;

    procedure AssignLiteral(const Source: ASqlLiteral); override;
    function  IsDataType(const DataType: TSqlDataType): Boolean; override;
    function  IsBooleanType: Boolean; override;

    function  Compare(const Value: ASqlLiteral): TCompareResult; override;
  end;



{                                                                              }
{ TSqlDateTime                                                                 }
{   SQL DateTime Literal                                                       }
{                                                                              }
type
  TSqlDateTime = class(ASqlLiteral)
  protected
    FValue : TDateTime;

    function  GetAsDateTime: TDateTime; override;
    procedure SetAsDateTime(const Value: TDateTime); override;

  public
    constructor Create(const Value: TDateTime);

    property  Value: TDateTime read FValue write FValue;

    procedure AssignLiteral(const Source: ASqlLiteral); override;
    function  IsDataType(const DataType: TSqlDataType): Boolean; override;
    function  IsDateTimeType: Boolean; override;

    function  Compare(const Value: ASqlLiteral): TCompareResult; override;
  end;



{                                                                              }
{ TSqlLiteralArray                                                             }
{   SQL Literal Array.                                                         }
{                                                                              }
type
  TSqlLiteralArray = class(ASqlLiteral)
  protected
    FValue : ASqlLiteralArray;

    function  GetAsString: AnsiString; override;

  public
    constructor Create(const Value: ASqlLiteralArray);
    destructor Destroy; override;

    property  Value: ASqlLiteralArray read FValue write FValue;
  end;



{                                                                              }
{ Helper functions                                                             }
{                                                                              }
function  SqlLiteralClassFromDataType(
          const DataType: TSqlDataType): ASqlLiteralClass;



implementation

uses
  { Fundamentals }
  cDynArrays,
  cStrings,
  cUnicodeCodecs;



{                                                                              }
{ TSqlTextOutput                                                               }
{                                                                              }
constructor TSqlTextOutput.Create;
begin
  inherited Create;
  FText := TLongStringWriter.Create;
end;

destructor TSqlTextOutput.Destroy;
begin
  FreeAndNil(FText);
  inherited Destroy;
end;

procedure TSqlTextOutput.Keyword(const Keyword: AnsiString);
begin
  FText.WriteStrA(Keyword);
end;

procedure TSqlTextOutput.Space;
begin
  FText.WriteByte(Byte(AsciiSP));
end;

procedure TSqlTextOutput.NewLine(const Count: Integer);
begin
  FText.WriteStrA(DupStrA(CRLF, Count));
  if FIndentCount > 0 then
    FText.WriteStrA(DupCharA(AsciiSP, FIndentCount * 4));
end;

procedure TSqlTextOutput.Symbol(const Symbol: AnsiString);
begin
  FText.WriteStrA(Symbol);
end;

procedure TSqlTextOutput.Identifier(const Identifier: AnsiString);
begin
  FText.WriteStrA(Identifier);
end;

procedure TSqlTextOutput.Literal(const Literal: AnsiString);
begin
  FText.WriteStrA(Literal);
end;

procedure TSqlTextOutput.Indent;
begin
  Inc(FIndentCount);
end;

procedure TSqlTextOutput.Unindent;
begin
  Dec(FIndentCount);
end;

procedure TSqlTextOutput.StructureNameBegin;
begin
  Symbol('{');
end;

procedure TSqlTextOutput.StructureNameEnd;
begin
  Symbol('}');
end;

procedure TSqlTextOutput.StructureName(const Name: AnsiString);
begin
  StructureNameBegin;
  Identifier(Name);
  StructureNameEnd;
end;

procedure TSqlTextOutput.StructureParamBegin(const DoIndent: Boolean = True);
begin
  Symbol('(');
  if DoIndent then
    begin
      Indent;
      NewLine;
    end;
end;

procedure TSqlTextOutput.StructureParamEnd(const DoUnindent: Boolean = True);
begin
  Symbol(')');
  if DoUnindent then
    begin
      Unindent;
      NewLine;
    end;
end;

function TSqlTextOutput.GetAsString: AnsiString;
begin
  Result := FText.AsStringA;
end;



{                                                                              }
{ TSqlDataTypeDefinition                                                       }
{                                                                              }
constructor TSqlDataTypeDefinition.Create;
begin
  inherited Create;
  FDataType := stUndefined;
end;

constructor TSqlDataTypeDefinition.CreateEx(const DataType: TSqlDataType;
    const Length: Integer; const Precision: Integer; const Scale: Integer;
    const WithTimeZone: Boolean);
begin
  inherited Create;
  FDataType := DataType;
  FLength := Length;
  FPrecision := Precision;
  FScale := Scale;
  FWithTimeZone := WithTimeZone;
end;

procedure TSqlDataTypeDefinition.TextOutputStructure(const Output: TSqlTextOutput);
begin
  Output.Identifier(SqlDataTypeToSqlStr(FDataType, FLength));
end;

procedure TSqlDataTypeDefinition.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Identifier(SqlDataTypeToSqlStr(FDataType, FLength));
      if SqlDataTypeHasLength(FDataType) then
        begin
          Symbol('(');
          Literal(IntToStringA(FLength));
          Symbol(')');
        end else
      if SqlDataTypeHasPrecisionAndScale(FDataType) then
        begin
          Symbol('(');
          Literal(IntToStringA(FPrecision));
          Symbol(',');
          Literal(IntToStringA(FScale));
          Symbol(')');
        end else
      if SqlDataTypeHasPrecision(FDataType) then
        begin
          Symbol('(');
          Literal(IntToStringA(FPrecision));
          Symbol(')');
        end;
      if (FDataType in [stTime, stTimeStamp]) and FWithTimeZone then
        begin
          Space;
          Keyword('WITH');
          Space;
          Keyword('TIME');
          Space;
          Keyword('ZONE');
        end;
    end;
end;

function TSqlDataTypeDefinition.CreateLiteralInstance: ASqlLiteral;
var C : ASqlLiteralClass;
begin
  C := SqlLiteralClassFromDataType(FDataType);
  if not Assigned(C) then
    raise ESqlError.Create('Literal not supported');
  Result := C.Create;
end;



{                                                                              }
{ TSqlColumnDefinition                                                         }
{                                                                              }
constructor TSqlColumnDefinition.Create;
begin
  inherited Create;
  FAllowNull := True;
  FUnique := False;
  FPrimaryKey := False;
  FTypeDefinition := TSqlDataTypeDefinition.Create;
end;

constructor TSqlColumnDefinition.CreateEx(const Name: AnsiString;
    const TypeDefinition: TSqlDataTypeDefinition; 
    const AllowNull: Boolean; const Unique: Boolean; const PrimaryKey: Boolean;
    const DefaultValue: ASqlLiteral);
begin
  inherited Create;
  FName := Name;
  FTypeDefinition := TypeDefinition;
  FAllowNull := AllowNull;
  FUnique := Unique;
  FPrimaryKey := PrimaryKey;
  FDefaultValue := DefaultValue;
end;

destructor TSqlColumnDefinition.Destroy;
begin
  FreeAndNil(FTypeDefinition);
  inherited Destroy;
end;

procedure TSqlColumnDefinition.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Identifier(FName);
  Output.Space;
  FTypeDefinition.TextOutputSql(Output);
end;

function TSqlColumnDefinition.IsName(const Name: AnsiString): Boolean;
begin
  Result := StrEqualNoAsciiCaseA(Name, FName);
end;

procedure TSqlColumnDefinition.SetDefaultValue(const Value: ASqlLiteral);
begin
  if Assigned(FDefaultValue) then
    Value.AssignLiteral(FDefaultValue)
  else
    Value.AssignDefaultValue;
end;



{                                                                              }
{ TSqlColumnDefinitionList                                                     }
{                                                                              }
constructor TSqlColumnDefinitionList.Create;
begin
  inherited Create;
  ColumnOwner := True;
end;

destructor TSqlColumnDefinitionList.Destroy;
begin
  if ColumnOwner then
    FreeObjectArray(FList);
  inherited Destroy;
end;

function TSqlColumnDefinitionList.GetCount: Integer;
begin
  Result := Length(FList);
end;

procedure TSqlColumnDefinitionList.Add(const Column: TSqlColumnDefinition);
begin
  Assert(Assigned(Column));
  DynArrayAppend(ObjectArray(FList), Column);
end;

function TSqlColumnDefinitionList.GetItem(const Idx: Integer): TSqlColumnDefinition;
begin
  Result := FList[Idx];
end;

function TSqlColumnDefinitionList.GetColumnByName(const Name: AnsiString): TSqlColumnDefinition;
var I : Integer;
begin
  for I := 0 to Length(FList) - 1 do
    if FList[I].Name = Name then
      begin
        Result := FList[I];
        exit;
      end;
  Result := nil;
end;

procedure TSqlColumnDefinitionList.TextOutputSql(const Output: TSqlTextOutput);
var I : Integer;
begin
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



{                                                                              }
{ ASqlLiteral                                                                  }
{                                                                              }
constructor ASqlLiteral.Create;
begin
  inherited Create;
  Init;
end;

constructor ASqlLiteral.CreateEx(const Value: ASqlLiteral);
begin
  inherited Create;
  Init;
  AssignLiteral(Value);
end;

procedure ASqlLiteral.Init;
begin
  FReferenceCount := 1;
  FNullValue := False;
end;

procedure ASqlLiteral.AddReference;
begin
  Inc(FReferenceCount);
end;

procedure ASqlLiteral.ReleaseReference;
begin
  if Assigned(self) then
    begin
      Assert(FReferenceCount > 0);
      Dec(FReferenceCount);
      if FReferenceCount = 0 then
        Destroy;
    end;
end;

procedure ASqlLiteral.AssignLiteral(const Source: ASqlLiteral);
begin
  raise ESqlLiteral.CreateFmt('Cannot assign from %s', [ClassToSqlStructureName(Source.ClassType)]);
end;

procedure ASqlLiteral.AssignNullValue;
begin
  FNullValue := True;
end;

procedure ASqlLiteral.AssignDefaultValue;
begin
  AssignNullValue;
end;

procedure ASqlLiteral.AssignVariant(const Value: TSqlVariant);
begin
  Case Value.VariantType of
    svNull    : AssignNullValue;
    svInteger : SetAsInteger(Value.Int);
    svFloat   : SetAsFloat(Value.Float);
  else
    AssignNullValue;
  end;
end;

function ASqlLiteral.IsNullValue: Boolean;
begin
  Result := FNullValue;
end;

function ASqlLiteral.IsDataType(const DataType: TSqlDataType): Boolean;
begin
  Result := False;
end;

function ASqlLiteral.IsIntegerType: Boolean;
begin
  Result := False;
end;

function ASqlLiteral.IsRealType: Boolean;
begin
  Result := False;
end;

function ASqlLiteral.IsStringType: Boolean;
begin
  Result := False;
end;

function ASqlLiteral.IsBooleanType: Boolean;
begin
  Result := False;
end;

function ASqlLiteral.IsDateTimeType: Boolean;
begin
  Result := False;
end;

function ASqlLiteral.Duplicate: ASqlLiteral;
begin
  Result := ASqlLiteralClass(ClassType).CreateEx(self);
end;

function ASqlLiteral.DuplicateAsType(const DataType: TSqlDataType): ASqlLiteral;
begin
  Result := SqlLiteralClassFromDataType(DataType).CreateEx(self);
end;

function ASqlLiteral.GetAsInteger: Int64;
begin
  raise ESqlLiteral.Create('Cannot convert to integer');
end;

procedure ASqlLiteral.SetAsInteger(const Value: Int64);
begin
  raise ESqlLiteral.Create('Cannot convert from integer');
end;

function ASqlLiteral.GetAsFloat: Extended;
begin
  raise ESqlLiteral.Create('Cannot convert to float');
end;

procedure ASqlLiteral.SetAsFloat(const Value: Extended);
begin
  raise ESqlLiteral.Create('Cannot convert from float');
end;

function ASqlLiteral.GetAsString: AnsiString;
begin
  raise ESqlLiteral.Create('Cannot convert to string');
end;

procedure ASqlLiteral.SetAsString(const Value: AnsiString);
begin
  raise ESqlLiteral.Create('Cannot convert from string');
end;

function ASqlLiteral.GetAsNString: WideString;
begin
  Result := LongStringToWideString(GetAsString);
end;

procedure ASqlLiteral.SetAsNString(const Value: WideString);
begin
  SetAsString(WideStringToLongString(Value));
end;

function ASqlLiteral.GetAsBoolean: TSqlBooleanValue;
begin
  raise ESqlLiteral.Create('Cannot convert to boolean');
end;

procedure ASqlLiteral.SetAsBoolean(const Value: TSqlBooleanValue);
begin
  raise ESqlLiteral.Create('Cannot convert from boolean');
end;

function ASqlLiteral.GetAsDateTime: TDateTime;
begin
  raise ESqlLiteral.Create('Cannot convert to date/time');
end;

procedure ASqlLiteral.SetAsDateTime(const Value: TDateTime);
begin
  raise ESqlLiteral.Create('Cannot convert from date/time');
end;

function ASqlLiteral.GetAsSql: AnsiString;
begin
  if FNullValue then
    Result := 'NULL'
  else
    Result := GetAsString;
end;

procedure ASqlLiteral.SetAsSql(const Value: AnsiString);
begin
  SetAsString(Value);
end;

procedure ASqlLiteral.Negate;
begin
  raise ESqlLiteral.Create('Negate operation not supported');
end;

procedure ASqlLiteral.Abs;
begin
  raise ESqlLiteral.Create('Abs operation not supported');
end;

function ASqlLiteral.Add(const Value: ASqlLiteral): ASqlLiteral;
begin
  raise ESqlLiteral.Create('Add operation not supported');
end;

function ASqlLiteral.Subtract(const Value: ASqlLiteral): ASqlLiteral;
begin
  raise ESqlLiteral.Create('Subtract operation not supported');
end;

function ASqlLiteral.Multiply(const Value: ASqlLiteral): ASqlLiteral;
begin
  raise ESqlLiteral.Create('Multiply operation not supported');
end;

function ASqlLiteral.Divide(const Value: ASqlLiteral): ASqlLiteral;
begin
  raise ESqlLiteral.Create('Divide operation not supported');
end;

function ASqlLiteral.Compare(const Value: ASqlLiteral): TCompareResult;
begin
  Result := crUndefined;
end;

procedure UniqueLiteral(var Literal: ASqlLiteral);
begin
  if Assigned(Literal) then
    begin
      if Literal.FReferenceCount <= 1 then
        exit;
      Dec(Literal.FReferenceCount);
      Literal := Literal.Duplicate;
    end;
end;



{                                                                              }
{ ASqlScope                                                                    }
{                                                                              }
function ASqlScope.RequireObject(const Name: AnsiString): TObject;
begin
  Result := GetObject(Name);
  if not Assigned(Result) then
    raise ESqlScope.CreateFmt('Identifier not defined: %s', [Name]);
end;

function ASqlScope.RequireLiteral(const Name: AnsiString): ASqlLiteral;
var R : TObject;
begin
  R := RequireObject(Name);
  if not (R is ASqlLiteral) then
    raise ESqlScope.CreateFmt('Identifier value not a literal: %s', [Name]);
  Result := ASqlLiteral(R);
end;



{                                                                              }
{ TSqlMemoryScope                                                              }
{                                                                              }
constructor TSqlMemoryScope.Create;
begin
  inherited Create;
  FScope := TObjectDictionaryA.CreateEx(nil, nil, False, False, True, ddAccept);
end;

destructor TSqlMemoryScope.Destroy;
begin
  FreeAndNil(FScope);
  inherited Destroy;
end;

procedure TSqlMemoryScope.AddObject(const Name: AnsiString; const Obj: TObject);
begin
  FScope.Add(Name, Obj);
end;

function TSqlMemoryScope.GetObject(const Name: AnsiString): TObject;
begin
  Result := FScope.Item[Name];
end;



{                                                                              }
{ TSqlSortSpecification                                                        }
{                                                                              }
constructor TSqlSortSpecification.CreateEx(const ColumnName: AnsiString; const OrderSpec: TSqlOrderSpecification);
begin
  inherited Create;
  FColumnName := ColumnName;
  FOrderSpec := OrderSpec;
end;



{                                                                              }
{ TSqlField                                                                    }
{                                                                              }
constructor TSqlField.Create(const Column: TSqlColumnDefinition;
    const Value: ASqlLiteral; const ValueOwner: Boolean);
begin
  inherited Create;
  FColumn := Column;
  FValue := Value;
  FValueOwner := ValueOwner;
end;

destructor TSqlField.Destroy;
begin
  if FValueOwner then
    FreeAndNil(FValue);
  inherited Destroy;
end;

function TSqlField.GetColumn: TSqlColumnDefinition;
begin
  Result := FColumn;
end;

function TSqlField.GetValue: ASqlLiteral;
begin
  Result := FValue;
end;



{                                                                              }
{ TSqlNull                                                                     }
{                                                                              }
constructor TSqlNull.Create;
begin
  inherited Create;
  FNullValue := True;
end;

function TSqlNull.GetAsSql: AnsiString;
begin
  Result := 'NULL';
end;

function TSqlNull.Compare(const Value: ASqlLiteral): TCompareResult;
begin
  Result := crUndefined;
end;



{                                                                              }
{ TSqlInteger                                                                  }
{                                                                              }
constructor TSqlInteger.Create(const Value: Int64);
begin
  inherited Create;
  FValue := Value;
end;

procedure TSqlInteger.AssignLiteral(const Source: ASqlLiteral);
begin
  FValue := Source.GetAsInteger;
  FNullValue := Source.IsNullValue;
end;

function TSqlInteger.IsDataType(const DataType: TSqlDataType): Boolean;
begin
  Result := SqlDataTypeIsInteger(DataType);
end;

function TSqlInteger.IsIntegerType: Boolean;
begin
  Result := True;
end;

function TSqlInteger.GetAsInteger: Int64;
begin
  Result := FValue;
end;

procedure TSqlInteger.SetAsInteger(const Value: Int64);
begin
  FValue := Value;
  FNullValue := False;
end;

function TSqlInteger.GetAsFloat: Extended;
begin
  Result := FValue;
end;

procedure TSqlInteger.SetAsFloat(const Value: Extended);
begin
  FValue := Trunc(Value);
  FNullValue := False;
end;

function TSqlInteger.GetAsString: AnsiString;
begin
  Result := IntToStringA(FValue);
end;

function TSqlInteger.GetAsBoolean: TSqlBooleanValue;
begin
  if FValue <> 0 then
    Result := sbvTrue
  else
    Result := sbvFalse;
end;

procedure TSqlInteger.SetAsBoolean(const Value: TSqlBooleanValue);
begin
  case Value of
    sbvTrue  : FValue := 1;
    sbvFalse : FValue := 0;
  else
    raise ESqlLiteral.Create('Cannot convert unknown boolean value to integer');
  end;
end;

procedure TSqlInteger.SetAsString(const Value: AnsiString);
begin
  FValue := StringToInt64A(Value);
  FNullValue := False;
end;

procedure TSqlInteger.Negate;
begin
  FValue := -FValue;
end;

procedure TSqlInteger.Abs;
begin
  FValue := System.Abs(FValue);
end;

function TSqlInteger.Add(const Value: ASqlLiteral): ASqlLiteral;
var V : Integer;
begin
  if Value is TSqlFloat then
    Result := Value.Add(self)
  else
    begin
      V := Value.AsInteger;
      Result := Duplicate;
      Inc(TSqlInteger(Result).FValue, V);
    end;
end;

function TSqlInteger.Subtract(const Value: ASqlLiteral): ASqlLiteral;
var V : Integer;
begin
  if Value is TSqlFloat then
    begin
      Result := Value.Subtract(self);
      Result.Negate;
    end
  else
    begin
      V := Value.AsInteger;
      Result := Duplicate;
      Dec(TSqlInteger(Result).FValue, V);
    end;
end;

function TSqlInteger.Multiply(const Value: ASqlLiteral): ASqlLiteral;
var V : Integer;
begin
  if Value is TSqlFloat then
    Result := Value.Multiply(self)
  else
    begin
      V := Value.AsInteger;
      Result := Duplicate;
      TSqlInteger(Result).FValue := TSqlInteger(Result).FValue * V;
    end;
end;

function TSqlInteger.Divide(const Value: ASqlLiteral): ASqlLiteral;
var V : Extended;
begin
  V := Value.AsFloat;
  Result := DuplicateAsType(stFloat);
  Result.AsFloat := FValue / V;
end;

function TSqlInteger.Compare(const Value: ASqlLiteral): TCompareResult;
begin
  if Value is TSqlFloat then
    Result := cUtils.Compare(FValue, Value.AsFloat)
  else
    Result := cUtils.Compare(FValue, Value.AsInteger);
end;



{                                                                              }
{ TSqlFloat                                                                    }
{                                                                              }
constructor TSqlFloat.Create(const Value: Extended);
begin
  inherited Create;
  FValue := Value;
end;

procedure TSqlFloat.AssignLiteral(const Source: ASqlLiteral);
begin
  FValue := Source.GetAsFloat;
  FNullValue := Source.IsNullValue;
end;

function TSqlFloat.IsDataType(const DataType: TSqlDataType): Boolean;
begin
  Result := SqlDataTypeIsFloat(DataType);
end;

function TSqlFloat.IsRealType: Boolean;
begin
  Result := True;
end;

function TSqlFloat.GetAsInteger: Int64;
begin
  Result := Trunc(FValue);
end;

procedure TSqlFloat.SetAsInteger(const Value: Int64);
begin
  FValue := Value;
  FNullValue := False;
end;

function TSqlFloat.GetAsFloat: Extended;
begin
  Result := FValue;
end;

procedure TSqlFloat.SetAsFloat(const Value: Extended);
begin
  FValue := Value;
  FNullValue := False;
end;

function TSqlFloat.GetAsString: AnsiString;
begin
  Result := FloatToStringA(FValue);
end;

procedure TSqlFloat.SetAsString(const Value: AnsiString);
begin
  FValue := StringToFloatA(Value);
  FNullValue := False;
end;

procedure TSqlFloat.Negate;
begin
  FValue := -FValue;
end;

procedure TSqlFloat.Abs;
begin
  FValue := System.Abs(FValue);
end;

function TSqlFloat.Add(const Value: ASqlLiteral): ASqlLiteral;
var V : Extended;
begin
  V := Value.AsFloat;
  Result := Duplicate;
  TSqlFloat(Result).FValue := TSqlFloat(Result).FValue + V;
end;

function TSqlFloat.Subtract(const Value: ASqlLiteral): ASqlLiteral;
var V : Extended;
begin
  V := Value.AsFloat;
  Result := Duplicate;
  TSqlFloat(Result).FValue := TSqlFloat(Result).FValue - V;
end;

function TSqlFloat.Multiply(const Value: ASqlLiteral): ASqlLiteral;
var V : Extended;
begin
  V := Value.AsFloat;
  Result := Duplicate;
  TSqlFloat(Result).FValue := TSqlFloat(Result).FValue * V;
end;

function TSqlFloat.Divide(const Value: ASqlLiteral): ASqlLiteral;
var V : Extended;
begin
  V := Value.AsFloat;
  Result := Duplicate;
  TSqlFloat(Result).FValue := TSqlFloat(Result).FValue / V;
end;

function TSqlFloat.Compare(const Value: ASqlLiteral): TCompareResult;
begin
  Result := cUtils.Compare(FValue, Value.AsFloat);
end;



{                                                                              }
{ TSqlString                                                                   }
{                                                                              }
constructor TSqlString.Create(const Value: AnsiString; const CharSet: AnsiString);
begin
  inherited Create;
  FValue := Value;
  FCharSet := CharSet;
end;

procedure TSqlString.AssignLiteral(const Source: ASqlLiteral);
begin
  FValue := Source.GetAsString;
  FNullValue := Source.IsNullValue;
end;

function TSqlString.IsDataType(const DataType: TSqlDataType): Boolean;
begin
  Result := SqlDataTypeIsString(DataType);
end;

function TSqlString.IsStringType: Boolean;
begin
  Result := True;
end;

function TSqlString.GetAsString: AnsiString;
begin
  Result := FValue;
end;

procedure TSqlString.SetAsString(const Value: AnsiString);
begin
  FValue := Value;
  FNullValue := False;
end;

function TSqlString.GetAsSql: AnsiString;
begin
  if FNullValue then
    Result := 'NULL'
  else
    Result := '''' + StrReplaceA('''', '''''', FValue) + '''';
end;

function TSqlString.Compare(const Value: ASqlLiteral): TCompareResult;
begin
  Result := cUtils.CompareA(FValue, Value.AsString);
end;



{                                                                              }
{ TSqlNString                                                                  }
{                                                                              }
constructor TSqlNString.Create(const Value: WideString);
begin
  inherited Create;
  FValue := Value;
end;

procedure TSqlNString.AssignLiteral(const Source: ASqlLiteral);
begin
  FValue := Source.GetAsString;
end;

function TSqlNString.IsDataType(const DataType: TSqlDataType): Boolean;
begin
  Result := SqlDataTypeIsNString(DataType);
end;

function TSqlNString.IsStringType: Boolean;
begin
  Result := True;
end;

function TSqlNString.GetAsString: AnsiString;
begin
  Result := WideStringToLongString(FValue);
end;

procedure TSqlNString.SetAsString(const Value: AnsiString);
begin
  FValue := LongStringToWideString(Value);
end;

function TSqlNString.GetAsNString: WideString;
begin
  Result := FValue;
end;

procedure TSqlNString.SetAsNString(const Value: WideString);
begin
  FValue := Value;
  FNullValue := False;
end;

function TSqlNString.GetAsSql: AnsiString;
begin
  if FNullValue then
    Result := 'NULL'
  else
    Result := '''' + FValue + '''';
end;

function TSqlNString.Compare(const Value: ASqlLiteral): TCompareResult;
begin
  Result := CompareW(FValue, Value.AsNString);
end;



{                                                                              }
{ TSqlBoolean                                                                  }
{                                                                              }
constructor TSqlBoolean.Create(const Value: TSqlBooleanValue);
begin
  inherited Create;
  FValue := Value;
end;

constructor TSqlBoolean.Create(const Value: Boolean);
begin
  inherited Create;
  if Value then
    FValue := sbvTrue
  else
    FValue := sbvFalse;
end;

procedure TSqlBoolean.AssignLiteral(const Source: ASqlLiteral);
begin
  FValue := Source.GetAsBoolean;
  FNullValue := Source.IsNullValue;
end;

function TSqlBoolean.IsDataType(const DataType: TSqlDataType): Boolean;
begin
  Result := SqlDataTypeIsBoolean(DataType);
end;

function TSqlBoolean.IsBooleanType: Boolean;
begin
  Result := True;
end;

function TSqlBoolean.GetAsBoolean: TSqlBooleanValue;
begin
  Result := FValue;
end;

procedure TSqlBoolean.SetAsBoolean(const Value: TSqlBooleanValue);
begin
  FValue := Value;
  FNullValue := False;
end;

function TSqlBoolean.Compare(const Value: ASqlLiteral): TCompareResult;
begin
  Result := SqlBooleanValueCompare(FValue, Value.AsBoolean);
end;



{                                                                              }
{ TSqlDateTime                                                                 }
{                                                                              }
constructor TSqlDateTime.Create(const Value: TDateTime);
begin
  inherited Create;
  FValue := Value;
end;

procedure TSqlDateTime.AssignLiteral(const Source: ASqlLiteral);
begin
  FValue := Source.GetAsDateTime;
  FNullValue := Source.IsNullValue;
end;

function TSqlDateTime.IsDataType(const DataType: TSqlDataType): Boolean;
begin
  Result := SqlDataTypeIsDateTime(DataType);
end;

function TSqlDateTime.IsDateTimeType: Boolean; 
begin
  Result := True;
end;

function TSqlDateTime.GetAsDateTime: TDateTime;
begin
  Result := FValue;
end;

procedure TSqlDateTime.SetAsDateTime(const Value: TDateTime);
begin
  FValue := Value;
  FNullValue := False;
end;

function TSqlDateTime.Compare(const Value: ASqlLiteral): TCompareResult;
begin
  Result := cUtils.Compare(FValue, Value.AsDateTime);
end;



{                                                                              }
{ TSqlLiteralArray                                                             }
{                                                                              }
constructor TSqlLiteralArray.Create(const Value: ASqlLiteralArray);
begin
  inherited Create;
  FValue := Value;
end;

destructor TSqlLiteralArray.Destroy;
begin
  FreeObjectArray(FValue);
  inherited Destroy;
end;

function TSqlLiteralArray.GetAsString: AnsiString;
var I : Integer;
begin
  Result := '(';
  for I := 0 to Length(FValue) - 1 do
    Result := Result + iifA(I > 0, ', ', '') + FValue[I].AsString;
  Result := Result + ')';
end;



{                                                                              }
{ Helper Functions                                                             }
{                                                                              }
function SqlLiteralClassFromDataType(
    const DataType: TSqlDataType): ASqlLiteralClass;
begin
  Case DataType of
    stChar,
    stVarChar,
    stText             : Result := TSqlString;
    stNChar,
    stNVarChar,
    stNText            : Result := TSqlNString;
    stNumeric,
    stDecimal          : Result := TSqlFloat;
    stInt,
    stSmallInt         : Result := TSqlInteger;
    stFloat,
    stDoublePrecision,
    stReal             : Result := TSqlFloat;
    stDate,
    stTime,
    stSmallDateTime,
    stDateTime         : Result := TSqlDateTime;
  else
    Result := nil;
  end;
end;



end.

