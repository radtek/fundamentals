{******************************************************************************}
(*                                                                            *)
(*    Library:       Fundamentals SQL                                         *)
(*    Description:   SQL data type utilities.                                 *)
(*    Version:       1.00                                                     *)
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
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLDataTypes;

interface



{                                                                              }
{ SQL data types                                                               }
{                                                                              }
type
  TSqlDataType = (
      stUndefined,
      { Integer }
      stTinyInt,
      stSmallInt,
      stInt,
      stBigInt,
      { Decimal }
      stNumeric,
      stDecimal,
      { Float }
      stFloat,
      stDoublePrecision,
      stReal,
      { Money }
      stSmallMoney,
      stMoney,
      { Date/Time }
      stDate,
      stTime,
      stSmallDateTime,
      stDateTime,
      stTimeStamp,
      stInterval,
      { Character }
      stChar,
      stVarChar,
      stText,
      stNChar,
      stNVarChar,
      stNText,
      { Binary }
      stBinary,
      stVarBinary,
      stImage,
      { Boolean }
      stBit);
  TSqlDataTypes = Set of TSqlDataType;

const
  SqlIntegerDataTypes    = [stTinyInt, stSmallInt, stInt, stBigInt];
  SqlDecimalDataTypes    = [stNumeric, stDecimal];
  SqlFloatDataTypes      = [stFloat, stDoublePrecision, stReal];
  SqlMoneyDataTypes      = [stSmallMoney, stMoney];
  SqlDateTimeDataTypes   = [stDate, stTime, stSmallDateTime, stDateTime,
                            stTimeStamp];
  SqlCharacterDataTypes  = [stChar, stVarChar, stText];
  SqlNCharacterDataTypes = [stNChar, stNVarChar, stNText];
  SqlBinaryDataTypes     = [stBinary, stVarBinary, stImage];
  SqlBooleanDataTypes    = [stBit];
  SqlNumericDataTypes    = SqlIntegerDataTypes +
                           SqlDecimalDataTypes +
                           SqlFloatDataTypes +
                           SqlMoneyDataTypes;

  SqlDataTypesWithLength            = SqlCharacterDataTypes +
                                      SqlBinaryDataTypes;
  SqlDataTypesWithPrecisionAndScale = [stNumeric, stDecimal];
  SqlDataTypesWithPrecision         = [stFloat, stTime, stTimeStamp];

function  SqlDataTypeIsInteger(const DataType: TSqlDataType): Boolean;
function  SqlDataTypeIsFloat(const DataType: TSqlDataType): Boolean;
function  SqlDataTypeIsDateTime(const DataType: TSqlDataType): Boolean;
function  SqlDataTypeIsString(const DataType: TSqlDataType): Boolean;
function  SqlDataTypeIsNString(const DataType: TSqlDataType): Boolean;
function  SqlDataTypeIsBoolean(const DataType: TSqlDataType): Boolean;
function  SqlDataTypeHasLength(const DataType: TSqlDataType): Boolean;
function  SqlDataTypeHasPrecisionAndScale(const DataType: TSqlDataType): Boolean;
function  SqlDataTypeHasPrecision(const DataType: TSqlDataType): Boolean;

function  SqlDataTypeToSqlStr(const DataType: TSqlDataType;
          const Length: Integer): String;



{                                                                              }
{ Conversion functions                                                         }
{                                                                              }
function  DateToSqlStr(const D: TDateTime): String;
function  TimeToSqlStr(const D: TDateTime;
          const IncludeMilliseconds: Boolean = True): String;



{                                                                              }
{ SQL variant                                                                  }
{                                                                              }
type
  TSqlVariantType = (
      svUnassigned = $00,
      svNull       = $01,
      svInteger    = $02,
      svFloat      = $03,
      svBoolean    = $04,
      svChar       = $05,
      svWideChar   = $06,
      svTimeStamp  = $07);
  TSqlVariant = packed record // 12 bytes
    case VariantType : TSqlVariantType of
      svUnassigned : (Buffer    : Array[0..10] of Byte);
      svInteger    : (Int       : Int64);
      svFloat      : (Float     : Extended);
      svBoolean    : (Bool      : Boolean);
      svChar       : (Ch        : Char);
      svWideChar   : (WideCh    : WideChar);
      svTimeStamp  : (TimeStamp : TDateTime);
  end;
  TSqlVariantArray = Array of TSqlVariant;

const
  SqlVariantSize = Sizeof(TSqlVariant); // 12

procedure SqlInitVariantNull(var Value: TSqlVariant);
procedure SqlInitVariantInt(var Value: TSqlVariant; const Int: Int64);
procedure SqlInitVariantFloat(var Value: TSqlVariant; const Float: Extended);



implementation

uses
  { System }
  SysUtils,

  { Fundamentals }
  cUtils,
  cStrings;



{                                                                              }
{ SQL data types                                                               }
{                                                                              }
function SqlDataTypeIsInteger(const DataType: TSqlDataType): Boolean;
begin
  Result := DataType in SqlIntegerDataTypes;
end;

function SqlDataTypeIsFloat(const DataType: TSqlDataType): Boolean;
begin
  Result := DataType in SqlFloatDataTypes;
end;

function SqlDataTypeIsDateTime(const DataType: TSqlDataType): Boolean;
begin
  Result := DataType in SqlDateTimeDataTypes;
end;

function SqlDataTypeIsString(const DataType: TSqlDataType): Boolean;
begin
  Result := DataType in SqlCharacterDataTypes;
end;

function SqlDataTypeIsNString(const DataType: TSqlDataType): Boolean;
begin
  Result := DataType in SqlNCharacterDataTypes;
end;

function SqlDataTypeIsBoolean(const DataType: TSqlDataType): Boolean;
begin
  Result := DataType in SqlBooleanDataTypes;
end;

function SqlDataTypeHasLength(const DataType: TSqlDataType): Boolean;
begin
  Result := DataType in SqlDataTypesWithLength;
end;

function SqlDataTypeHasPrecisionAndScale(const DataType: TSqlDataType): Boolean;
begin
  Result := DataType in SqlDataTypesWithPrecisionAndScale;
end;

function SqlDataTypeHasPrecision(const DataType: TSqlDataType): Boolean;
begin
  Result := DataType in SqlDataTypesWithPrecision;
end;

const
  SqlDataTypeStrings : Array[TSqlDataType] of String = (
      '',
      'tinyint', 'smallint', 'int', 'bigint',
      'numeric', 'decimal',
      'float', 'double', 'real',
      'smallmoney', 'money',
      'date', 'time', 'smalldatetime', 'datetime', 'timestamp', 'interval',
      'char', 'varchar', 'text', 'nchar', 'nvarchar', 'ntext',
      'binary', 'varbinary', 'image',
      'bit');

function SqlDataTypeToSqlStr(const DataType: TSqlDataType;
    const Length: Integer): String;
begin
  Result := SqlDataTypeStrings[DataType];
  if SqlDataTypeHasLength(DataType) then
    Result := Result + '(' + IntToStr(Length) + ')';
end;



{                                                                              }
{ Conversion functions                                                         }
{                                                                              }
function DateToSqlStr(const D: TDateTime): String;
var Ye, Mo, Da : Word;
begin
  DecodeDate(D, Ye, Mo, Da);
  Result := IntToStr(Ye) + '-' + IntToStr(Mo) + '-' + IntToStr(Da);
end;

function TimeToSqlStr(const D: TDateTime;
    const IncludeMilliseconds: Boolean): String;
var Ho, Mi, Se, Ms : Word;
begin
  DecodeTime(D, Ho, Mi, Se, Ms);
  Result := IntToStr(Ho) + '-' + IntToStr(Mi) + '-' + IntToStr(Se);
  if IncludeMilliseconds then
    Result := Result + '.' + StrPadLeftA(IntToStr(Ms), '0', 3);
end;

function DateTimeToSqlStr(const D: TDateTime): String;
begin
  Result := DateToSqlStr(D) + ' ' + TimeToSqlStr(D);
end;



{                                                                              }
{ SQL variant                                                                  }
{                                                                              }
procedure SqlInitVariantNull(var Value: TSqlVariant);
begin
  ZeroMem(Value, SqlVariantSize);
  Value.VariantType := svNull;
end;

procedure SqlInitVariantInt(var Value: TSqlVariant; const Int: Int64);
begin
  ZeroMem(Value, SqlVariantSize);
  Value.VariantType := svInteger;
  Value.Int := Int;
end;

procedure SqlInitVariantFloat(var Value: TSqlVariant; const Float: Extended);
begin
  ZeroMem(Value, SqlVariantSize);
  Value.VariantType := svFloat;
  Value.Float := Float;
end;



end.

