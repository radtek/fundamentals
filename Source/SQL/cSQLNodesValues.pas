{******************************************************************************}
(*                                                                            *)
(*    Library:       Fundamentals SQL                                         *)
(*    Description:   SQL nodes: Value expressions                             *)
(*    Version:       0.05                                                     *)
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
(*    2003/07/29  0.02  Created cSQLNodesValues unit.                         *)
(*    2003/07/31  0.03  Implementations.                                      *)
(*    2005/04/02  0.04  Development.                                          *)
(*    2005/04/09  0.05  Development.                                          *)
(*                                                                            *)
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLNodesValues;

interface

uses
  { SQL }
  cSQLUtils,
  cSQLDataTypes,
  cSQLStructs,
  cSQLDatabase,
  cSQLNodes;



{                                                                              }
{ ASqlLiteralValueExpression                                                   }
{   Base class for Literal Value Expressions.                                  }
{                                                                              }
type
  ASqlLiteralValueExpression = class(ASqlValueExpression)
  public
    function  IsLiteral: Boolean; override;
  end;



{                                                                              }
{ TSqlLiteralValue                                                             }
{   SQL Literal Value Expression.                                              }
{                                                                              }
type
  TSqlLiteralValue = class(ASqlLiteralValueExpression)
  protected
    FValue : ASqlLiteral;

  public
    constructor CreateEx(const Value: ASqlLiteral);
    constructor CreateInteger(const Value: Int64);
    constructor CreateFloat(const Value: Extended);
    constructor CreateString(const Value: AnsiString; const CharSetSpec: AnsiString = '');
    constructor CreateBitString(const Value: AnsiString);
    constructor CreateHexString(const Value: AnsiString);
    constructor CreateNString(const Value: WideString);
    constructor CreateBoolean(const Value: TSqlBooleanValue);
    destructor  Destroy; override;

    property  Value: ASqlLiteral read FValue write FValue;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;

    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor;
              const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlNullValue                                                                }
{   SQL NULL Value Expression.                                                 }
{                                                                              }
type
  TSqlNullValue = class(ASqlLiteralValueExpression)
  public
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlDefaultValue                                                             }
{   SQL DEFAULT Value Expression.                                              }
{                                                                              }
type
  TSqlDefaultValue = class(ASqlLiteralValueExpression)
  public
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlSpecialValue                                                             }
{   SQL Special Value Expression.                                              }
{                                                                              }
type
  TSqlSpecialValueType = (
      ssvUndefined,
      ssvUSER, ssvCURRENT_USER, ssvSESSION_USER, ssvSYSTEM_USER,                // User
      ssvPI, ssvRAND,                                                           // Mathematical
      ssvGETDATE, ssvCURRENT_DATE, ssvCURRENT_TIME, ssvCURRENT_TIMESTAMP,       // Date/Time
      ssvVALUE);                                                                // Value
  TSqlSpecialValue = class(ASqlValueExpression)
  protected
    FValueType : TSqlSpecialValueType;
    FPrecision : Integer;

  public

    constructor CreateEx(const ValueType: TSqlSpecialValueType);

    property  ValueType: TSqlSpecialValueType read FValueType write FValueType;
    property  Precision: Integer read FPrecision write FPrecision;

    function  IsLiteral: Boolean; override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlColumnReference                                                          }
{   SQL Column Reference Value Expression.                                     }
{                                                                              }
type
  TSqlColumnReference = class(ASqlValueExpression)
  protected
    FColumnName : AnsiString;

  public
    constructor CreateEx(const ColumnName: AnsiString);

    property  ColumnName: AnsiString read FColumnName write FColumnName;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel; override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlIdentifier                                                               }
{   SQL Identifier Value Expression.                                           }
{                                                                              }
type
  TSqlIdentifier = class(ASqlValueExpression)
  protected
    FName : AnsiString;

  public
    constructor CreateEx(const Name: AnsiString);

    property  Name: AnsiString read FName write FName;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlParameterReference                                                       }
{   SQL Parameter Reference Value Expression.                                  }
{                                                                              }
type
  TSqlParameterReference = class(ASqlValueExpression)
  protected
    FName : AnsiString;

  public
    constructor CreateEx(const Name: AnsiString);

    property  Name: AnsiString read FName write FName;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlDynamicCursorName                                                        }
{   SQL Dynamic Cursor Name Expression.                                        }
{                                                                              }
type
  TSqlDynamicCursorName = class(ASqlValueExpression)
  protected
    FCursorName         : AnsiString;
    FScopeOption        : TSqlScopeOption;
    FExtendedCursorName : ASqlValueExpression;
  public
    property  CursorName: AnsiString read FCursorName write FCursorName;
    property  ScopeOption: TSqlScopeOption read FScopeOption write FScopeOption;
    property  ExtendedCursorName: ASqlValueExpression read FExtendedCursorName write FExtendedCursorName;
  end;



{                                                                              }
{ TSqlDynamicParameterSpecification                                            }
{                                                                              }
type
  TSqlDynamicParameterSpecification = class(ASqlValueExpression);



{                                                                              }
{ TSqlParameterSpecification                                                   }
{                                                                              }
type
  TSqlParameterSpecification = class(ASqlValueExpression)
  protected
    FName      : AnsiString;
    FIndicator : AnsiString;

  public
    property  Name: AnsiString read FName write FName;
    property  Indicator: AnsiString read FIndicator write FIndicator;
  end;



{                                                                              }
{ TSqlVariableSpecification                                                    }
{                                                                              }
type
  TSqlVariableSpecification = class(ASqlValueExpression)
  protected
    FName      : ASqlValueExpression;
    FIndicator : ASqlValueExpression;

  public
    property  Name: ASqlValueExpression read FName write FName;
    property  Indicator: ASqlValueExpression read FIndicator write FIndicator;
  end;



{                                                                              }
{ TSqlNullIfExpression                                                         }
{   SQL NULLIF Value Expression.                                               }
{                                                                              }
type
  TSqlNullIfExpression = class(ASqlValueExpression)
  protected
    FValue1 : ASqlValueExpression;
    FValue2 : ASqlValueExpression;

  public
    constructor CreateEx(const Value1, Value2: ASqlValueExpression);
    destructor Destroy; override;

    property  Value1: ASqlValueExpression read FValue1 write FValue1;
    property  Value2: ASqlValueExpression read FValue2 write FValue2;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlCastExpression                                                           }
{   SQL CAST Value Expresison.                                                 }
{                                                                              }
type
  TSqlCastExpression = class(ASqlValueExpression)
  protected
    FOperand        : ASqlValueExpression;
    FTypeDefinition : TSqlDataTypeDefinition;

  public
    constructor CreateEx(const Operand: ASqlValueExpression;
                const TypeDefinition: TSqlDataTypeDefinition);
    destructor Destroy; override;

    property  Operand: ASqlValueExpression read FOperand write FOperand;
    property  TypeDefinition: TSqlDataTypeDefinition read FTypeDefinition write FTypeDefinition;

    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ ASqlValueExpressionProxy                                                     }
{   Base class for Value Expression proxies.                                   }
{                                                                              }
type
  ASqlValueExpressionProxy = class(ASqlValueExpression)
  protected
    FValueExpr : ASqlValueExpression;

  public
    constructor CreateEx(const ValueExpr: ASqlValueExpression);
    destructor Destroy; override;

    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
    function  Evaluate(const Engine: ASqlDatabaseEngine; const Cursor: ASqlCursor;
              const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlValueExpressionWithCollate                                               }
{   Value Expression with a Collate clause.                                    }
{                                                                              }
type
  TSqlValueExpressionWithCollate = class(ASqlValueExpressionProxy)
  protected
    FCollate : AnsiString;

  public
    constructor CreateEx(const ValueExpr: ASqlValueExpression;
                const Collate: AnsiString);

    property  Collate: AnsiString read FCollate write FCollate;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
  end;



{                                                                              }
{ TSqlCharacterTranslation                                                     }
{                                                                              }
type
  TSqlCharacterTranslation = class(ASqlValueExpressionProxy)
  protected
    FTranslationName : AnsiString;

  public
    property  TranslationName: AnsiString read FTranslationName write FTranslationName;
  end;



{                                                                              }
{ TSqlFormOfUseConversion                                                      }
{                                                                              }
type
  TSqlFormOfUseConversion = class(ASqlValueExpressionProxy)
  protected
    FConversionName : AnsiString;

  public
    property  ConversionName: AnsiString read FConversionName write FConversionName;
  end;



{                                                                              }
{ TSqlIsNullExpression                                                         }
{   SQL ISNULL Expression.                                                     }
{                                                                              }
type
  TSqlIsNullExpression = class(ASqlValueExpression)
  protected
    FValueExpr   : ASqlValueExpression;
    FReplacement : ASqlValueExpression;

  public
    destructor Destroy; override;

    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;
    property  Replacement: ASqlValueExpression read FReplacement write FReplacement;

    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlCoalesceExpression                                                       }
{   SQL COALESCE Expression.                                                   }
{                                                                              }
type
  TSqlCoalesceExpression = class(ASqlValueExpression)
  protected
    FExprList : ASqlValueExpressionArray;

  public
    constructor CreateEx(const ExprList: ASqlValueExpressionArray);
    destructor Destroy; override;

    property  ExprList: ASqlValueExpressionArray read FExprList write FExprList;

    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlCaseExpression                                                           }
{   SQL CASE Value Expression.                                                 }
{                                                                              }
type
  TSqlSimpleWhen = class
    WhenOperand : ASqlValueExpression;
    ResultExpr  : ASqlValueExpression;
  end;
  TSqlSimpleWhenArray = Array of TSqlSimpleWhen;

  TSqlSearchedWhen = class
    Condition   : ASqlSearchCondition;
    ResultExpr  : ASqlValueExpression;
  end;
  TSqlSearchedWhenArray = Array of TSqlSearchedWhen;

  TSqlCaseExpression = class(ASqlValueExpression)
  protected
    FCaseOperand  : ASqlValueExpression;
    FElseValue    : ASqlValueExpression;
    FSimpleWhen   : TSqlSimpleWhenArray;
    FSearchedWhen : TSqlSearchedWhenArray;

  public
    destructor Destroy; override;

    property  CaseOperand: ASqlValueExpression read FCaseOperand write FCaseOperand;
    property  ElseValue: ASqlValueExpression read FElseValue write FElseValue;
    property  SimpleWhen: TSqlSimpleWhenArray read FSimpleWhen write FSimpleWhen;
    property  SearchedWhen: TSqlSearchedWhenArray read FSearchedWhen write FSearchedWhen;

    function  Evaluate(const Engine: ASqlDatabaseEngine; const Cursor: ASqlCursor;
              const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ ASqlUnaryOperatorExpression                                                  }
{   Base class for unary operator value expressions.                           }
{                                                                              }
type
  ASqlUnaryOperatorExpression = class(ASqlValueExpression)
  protected
    FOperand : ASqlValueExpression;

  public
    constructor CreateEx(const Operand: ASqlValueExpression);
    destructor Destroy; override;

    property  Operand: ASqlValueExpression read FOperand write FOperand;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
              
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel; override;
  end;



{                                                                              }
{ TSqlNegateExpression                                                         }
{   Negate Operator Value Expression.                                          }
{                                                                              }
type
  TSqlNegateExpression = class(ASqlUnaryOperatorExpression)
  public
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Simplify: ASqlValueExpression; override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlUnaryMathematicalFunction                                                }
{                                                                              }
type
  TSqlUnaryMathematicalFunctionType = (
      sumUndefined,
      sumABS,
      sumROUND,
      sumSIGN,
      sumLOG,
      sumLOG10,
      sumSIN,
      sumCOS,
      sumFLOOR,
      sumCEILING,
      sumSQRT);
  TSqlUnaryMathematicalFunction = class(ASqlUnaryOperatorExpression)
  protected
    FFunctionType : TSqlUnaryMathematicalFunctionType;

  public
    constructor CreateEx(const FunctionType: TSqlUnaryMathematicalFunctionType;
                const Operand: ASqlValueExpression);
    property  FunctionType: TSqlUnaryMathematicalFunctionType read FFunctionType write FFunctionType;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ ASqlBinaryOperatorExpression                                                 }
{   Base class for binary operator value expressions.                          }
{                                                                              }
type
  ASqlBinaryOperatorExpression = class(ASqlValueExpression)
  protected
    FLeft  : ASqlValueExpression;
    FRight : ASqlValueExpression;

    procedure TextOutOperator(const Output: TSqlTextOutput); virtual; abstract;

  public
    constructor CreateEx(const Left, Right: ASqlValueExpression);
    destructor Destroy; override;

    property  Left: ASqlValueExpression read FLeft write FLeft;
    property  Right: ASqlValueExpression read FRight write FRight;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
  end;



{                                                                              }
{ TSqlAddExpression                                                            }
{   Add Operator Value Expression.                                             }
{                                                                              }
type
  TSqlAddExpression = class(ASqlBinaryOperatorExpression)
  protected
    procedure TextOutOperator(const Output: TSqlTextOutput); override;
  public
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlSubtractExpression                                                       }
{   Subtract Operator Value Expression.                                        }
{                                                                              }
type
  TSqlSubtractExpression = class(ASqlBinaryOperatorExpression)
  protected
    procedure TextOutOperator(const Output: TSqlTextOutput); override;
  public
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlMultiplyExpression                                                       }
{   Multiply Operator Value Expression.                                        }
{                                                                              }
type
  TSqlMultiplyExpression = class(ASqlBinaryOperatorExpression)
  protected
    procedure TextOutOperator(const Output: TSqlTextOutput); override;
  public
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlDivideExpression                                                         }
{   Divide Operator Value Expression.                                          }
{                                                                              }
type
  TSqlDivideExpression = class(ASqlBinaryOperatorExpression)
  protected
    procedure TextOutOperator(const Output: TSqlTextOutput); override;
  public
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlSetFunctionExpression                                                    }
{   Set Function Value Expression.                                             }
{                                                                              }
type
  TSqlSetFunctionExpression = class(ASqlValueExpression)
  protected
    FFunctionType : TSqlSetFunctionType;
    FQuantifier   : TSqlSetQuantifier;
    FValueExpr    : ASqlValueExpression;

  public
    Wild : Boolean;

    constructor CreateEx(const FunctionType: TSqlSetFunctionType;
                const Quantifier: TSqlSetQuantifier;
                const ValueExpr: ASqlValueExpression);
    destructor Destroy; override;

    property  FunctionType: TSqlSetFunctionType read FFunctionType write FFunctionType;
    property  Quantifier: TSqlSetQuantifier read FQuantifier write FQuantifier;
    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel; override;
    procedure Prepare(const Database: ASqlDatabase;
              const Cursor: ASqlCursor; const Scope: ASqlScope); override;
    function  CalculateStatistic(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlCharacterSubStringFunction                                               }
{   Character SUBSTRING Function Value Expression.                             }
{                                                                              }
type
  TSqlCharacterSubStringFunction = class(ASqlValueExpression)
  protected
    FValueExpr     : ASqlValueExpression;
    FStartPosition : ASqlValueExpression;
    FStringLength  : ASqlValueExpression;

  public
    constructor CreateEx(const ValueExpr, StartPosition, StringLength: ASqlValueExpression);
    destructor Destroy; override;

    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;
    property  StartPosition: ASqlValueExpression read FStartPosition write FStartPosition;
    property  StringLength: ASqlValueExpression read FStringLength write FStringLength;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ ASqlUnaryCharacterFunction                                                   }
{   Base class for character functions with a value expression parameter.      }
{                                                                              }
type
  ASqlUnaryCharacterFunction = class(ASqlValueExpression)
  protected
    FValueExpr : ASqlValueExpression;

  public
    constructor CreateEx(const ValueExpr: ASqlValueExpression);
    destructor Destroy; override;

    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
  end;



{                                                                              }
{ TSqlCharacterFoldFunction                                                    }
{   Character Fold Function (UPPER or LOWER) Value Expression.                 }
{                                                                              }
type
  TSqlCharacterFoldOperation = (
      scfUndefined,
      scfUpper,
      scfLower);
  TSqlCharacterFoldFunction = class(ASqlUnaryCharacterFunction)
  protected
    FOperation : TSqlCharacterFoldOperation;

  public
    constructor CreateEx(const Operation: TSqlCharacterFoldOperation;
                const ValueExpr: ASqlValueExpression);

    property  Operation: TSqlCharacterFoldOperation read FOperation write FOperation;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlCharacterConcatenationOperation                                          }
{   Character Concatenation Operation (||) Value Expression.                   }
{                                                                              }
type
  TSqlCharacterConcatenationOperation = class(ASqlValueExpression)
  protected
    FLeft  : ASqlValueExpression;
    FRight : ASqlValueExpression;

  public
    constructor CreateEx(const Left, Right: ASqlValueExpression);
    destructor Destroy; override;

    property  Left: ASqlValueExpression read FLeft write FLeft;
    property  Right: ASqlValueExpression read FRight write FRight;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlCharacterPositionExpression                                              }
{   Character POSITION Value Expression.                                       }
{                                                                              }
type
  TSqlCharacterPositionExpression = class(ASqlValueExpression)
  protected
    FSubValueExpr : ASqlValueExpression;
    FValueExpr    : ASqlValueExpression;

  public
    constructor CreateEx(const SubValueExpr, ValueExpr: ASqlValueExpression);
    destructor Destroy; override;

    property  SubValueExpr: ASqlValueExpression read FSubValueExpr write FSubValueExpr;
    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlCharacterTrimFunction                                                    }
{   Character TRIM Function Value Expression.                                  }
{                                                                              }
type
  TSqlTrimOperation = (stoUndefined, stoLeading, stoTrailing, stoBoth);
  TSqlCharacterTrimFunction = class(ASqlValueExpression)
  protected
    FTrimOperation  : TSqlTrimOperation;
    FValueExpr      : ASqlValueExpression;
    FTrimCharacters : ASqlValueExpression;

  public
    constructor CreateEx(const TrimOperation: TSqlTrimOperation;
                const ValueExpr, TrimCharacters: ASqlValueExpression);
    destructor Destroy; override;

    property  TrimOperation: TSqlTrimOperation read FTrimOperation write FTrimOperation;
    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;
    property  TrimCharacters: ASqlValueExpression read FTrimCharacters write FTrimCharacters;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlLengthExpression                                                         }
{                                                                              }
type
  TSqlLengthExpressionType = (
      sleUndefined,
      sleChar,
      sleOctet,
      sleBit);
  TSqlLengthExpression = class(ASqlValueExpression)
  protected
    FLengthType : TSqlLengthExpressionType;
    FStrValue   : ASqlValueExpression;
  public
    property  LengthType: TSqlLengthExpressionType read FLengthType write FLengthType;
    property  StrValue: ASqlValueExpression read FStrValue write FStrValue;
  end;



{                                                                              }
{ TSqlBitConcatenationOperation                                                }
{   Bit Concatenation Operation (||) Value Expression.                         }
{                                                                              }
type
  TSqlBitConcatenationOperation = class(ASqlValueExpression)
  protected
    FLeft  : ASqlValueExpression;
    FRight : ASqlValueExpression;

  public
    constructor CreateEx(const Left, Right: ASqlValueExpression);
    destructor Destroy; override;

    property  Left: ASqlValueExpression read FLeft write FLeft;
    property  Right: ASqlValueExpression read FRight write FRight;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  IsLiteral: Boolean; override;
    function  Simplify: ASqlValueExpression; override;
    function  Evaluate(const Engine: ASqlDatabaseEngine;
              const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral; override;
  end;



{                                                                              }
{ TSqlBitSubStringFunction                                                     }
{                                                                              }
type
  TSqlBitSubStringFunction = class(ASqlValueExpression)
  protected
    FValueExpr    : ASqlValueExpression;
    FStartPos     : ASqlValueExpression;
    FStringLength : ASqlValueExpression;
  public
    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;
    property  StartPos: ASqlValueExpression read FStartPos write FStartPos;
    property  StringLength: ASqlValueExpression read FStringLength write FStringLength;
  end;



{                                                                              }
{ TSqlRowValueConstructor                                                      }
{   SQL Row Value Constructor.                                                 }
{                                                                              }
type
  TSqlRowValueConstructor = class(ASqlValueExpression)
  protected
    FRowElement  : ASqlValueExpression;
    FRowElements : ASqlValueExpressionArray;
    FRowSubQuery : ASqlQueryExpression;

  public
    destructor Destroy; override;

    property  RowElement: ASqlValueExpression read FRowElement write FRowElement;
    property  RowElements: ASqlValueExpressionArray read FRowElements write FRowElements;
    property  RowSubQuery: ASqlQueryExpression read FRowSubQuery write FRowSubQuery;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Simplify: ASqlValueExpression; override;
    function  Evaluate(const Engine: ASqlDatabaseEngine; const Cursor: ASqlCursor;
              const Scope: ASqlScope): ASqlLiteral; override;
  end;
  TSqlRowValueConstructorArray = Array of TSqlRowValueConstructor;



{                                                                              }
{ TSqlDateTimeExprAtTimeZone                                                   }
{                                                                              }
type
  TSqlTimeZone = class
    Local    : Boolean;
    TimeZone : ASqlValueExpression;
  end;
  TSqlDateTimeExprAtTimeZone = class(ASqlValueExpression)
  protected
    FValueExpr : ASqlValueExpression;
    FTimeZone  : TSqlTimeZone;

  public
    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;
    property  TimeZone: TSqlTimeZone read FTimeZone write FTimeZone;
  end;



{                                                                              }
{ TSqlIntervalLiteralValue                                                     }
{                                                                              }
type
  TSqlIntervalLiteralValue = class(ASqlValueExpression)
  protected
    FNegate         : Boolean;
    FIntervalString : AnsiString;
    FQualifier      : TSqlIntervalQualifier;

  public
    property  Negate: Boolean read FNegate write FNegate;
    property  IntervalString: AnsiString read FIntervalString write FIntervalString;
    property  Qualifier: TSqlIntervalQualifier read FQualifier write FQualifier;
  end;



{                                                                              }
{ TSqlExtractExpression                                                        }
{                                                                              }
type
  TSqlExtractExpression = class(ASqlValueExpression)
  protected
    FExtractZone     : TSqlTimeZoneField;
    FExtractDateTime : TSqlDateTimeField;
    FValueExpr       : ASqlValueExpression;

  public
    property  ExtractZone: TSqlTimeZoneField read FExtractZone write FExtractZone;
    property  ExtractDateTime: TSqlDateTimeField read FExtractDateTime write FExtractDateTime;
    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;
  end;



{                                                                              }
{ TSqlDefaultOption                                                            }
{                                                                              }
type
  TSqlSpecialDefaultOption = (
      ssdUndefined,
      ssdUser,
      ssdCurrentUser,
      ssdSessionUser,
      ssdSystemUser,
      ssdNull);
  TSqlDefaultOption = class(ASqlValueExpression)
  protected
    FLiteral     : ASqlValueExpression;
    FSpecial     : TSqlSpecialDefaultOption;
    FDateTimeVal : ASqlValueExpression;

  public
    property  Literal: ASqlValueExpression read FLiteral write FLiteral;
    property  Special: TSqlSpecialDefaultOption read FSpecial write FSpecial;
    property  DateTimeVal: ASqlValueExpression read FDateTimeVal write FDateTimeVal;
  end;



implementation

uses
  { System }
  SysUtils,

  { Fundamentals }
  cUtils,
  cStrings,
  cDateTime,
  cRandom,

  { SQL }
  cSQLLexer;



{                                                                              }
{ ASqlLiteralValueExpression                                                   }
{                                                                              }
function ASqlLiteralValueExpression.IsLiteral: Boolean;
begin
  Result := True;
end;



{                                                                              }
{ TSqlLiteralValue                                                             }
{                                                                              }
constructor TSqlLiteralValue.CreateEx(const Value: ASqlLiteral);
begin
  inherited Create;
  Assert(Assigned(Value));
  FValue := Value;
end;

constructor TSqlLiteralValue.CreateInteger(const Value: Int64);
begin
  inherited Create;
  FValue := TSqlInteger.Create(Value);
end;

constructor TSqlLiteralValue.CreateFloat(const Value: Extended);
begin
  inherited Create;
  FValue := TSqlFloat.Create(Value);
end;

constructor TSqlLiteralValue.CreateString(const Value: AnsiString; const CharSetSpec: AnsiString);
begin
  inherited Create;
  FValue := TSqlString.Create(Value, CharSetSpec);
end;

constructor TSqlLiteralValue.CreateBitString(const Value: AnsiString);
begin
  inherited Create;
  FValue := TSqlString.Create(Value);
end;

constructor TSqlLiteralValue.CreateHexString(const Value: AnsiString);
begin
  inherited Create;
  FValue := TSqlString.Create(Value);
end;

constructor TSqlLiteralValue.CreateNString(const Value: WideString);
begin
  inherited Create;
  FValue := TSqlNString.Create(Value);
end;

constructor TSqlLiteralValue.CreateBoolean(const Value: TSqlBooleanValue);
begin
  inherited Create;
  FValue := TSqlBoolean.Create(Value);
end;

destructor TSqlLiteralValue.Destroy;
begin
  FValue.ReleaseReference;
  inherited Destroy;
end;

procedure TSqlLiteralValue.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  Output.StructureName(ClassToSqlStructureName(FValue.ClassType));
  Output.StructureParamBegin(False);
  Output.Literal(FValue.AsString);
end;

procedure TSqlLiteralValue.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Literal(FValue.AsSql);
end;

function TSqlLiteralValue.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  Result := FValue;
  Result.AddReference;
end;



{                                                                              }
{ TSqlNullValue                                                                }
{                                                                              }
procedure TSqlNullValue.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Keyword(SQL_KEYWORD_NULL);
end;

function TSqlNullValue.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  Result := TSqlNull.Create;
end;



{                                                                              }
{ TSqlDefaultValue                                                             }
{                                                                              }
procedure TSqlDefaultValue.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Keyword(SQL_KEYWORD_DEFAULT);
end;

function TSqlDefaultValue.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  raise ESqlValueExpression.Create('Not implemented');
end;



{                                                                              }
{ TSqlSpecialValue                                                             }
{                                                                              }
constructor TSqlSpecialValue.CreateEx(const ValueType: TSqlSpecialValueType);
begin
  inherited Create;
  FValueType := ValueType;
end;

procedure TSqlSpecialValue.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    case FValueType of
      ssvUSER         : Keyword(SQL_KEYWORD_USER);
      ssvCURRENT_USER : Keyword(SQL_KEYWORD_CURRENT_USER);
      ssvSESSION_USER : Keyword(SQL_KEYWORD_SESSION_USER);
      ssvSYSTEM_USER  : Keyword(SQL_KEYWORD_SYSTEM_USER);
    end;
end;

function TSqlSpecialValue.IsLiteral: Boolean;
begin
  case FValueType of
    ssvPI : Result := True;
  else
    Result := False;
  end;
end;

function TSqlSpecialValue.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  Assert(Assigned(Scope));
  case FValueType of
    ssvUSER              : Result := Scope.RequireLiteral('USER');
    ssvCURRENT_USER      : Result := Scope.RequireLiteral('CURRENT_USER');
    ssvSESSION_USER      : Result := Scope.RequireLiteral('SESSION_USER');
    ssvSYSTEM_USER       : Result := Scope.RequireLiteral('SYSTEM_USER');
    ssvPI                : Result := TSqlFloat.Create(Pi);
    ssvRAND              : Result := TSqlFloat.Create(RandomFloat);
    ssvGETDATE           : Result := TSqlDateTime.Create(Now);
    ssvCURRENT_DATE      : Result := TSqlDateTime.Create(DatePart(Now));
    ssvCURRENT_TIME      : Result := TSqlDateTime.Create(TimePart(Now));
    ssvCURRENT_TIMESTAMP : Result := TSqlDateTime.Create(Now);
  else
    raise ESqlValueExpression.Create('Value not implemented');
  end;
end;



{                                                                              }
{ TSqlColumnReference                                                          }
{                                                                              }
constructor TSqlColumnReference.CreateEx(const ColumnName: AnsiString);
begin
  inherited Create;
  FColumnName := ColumnName;
end;

procedure TSqlColumnReference.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  Output.Identifier(FColumnName);
end;

procedure TSqlColumnReference.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Identifier(FColumnName);
end;

function TSqlColumnReference.IsLiteral: Boolean;
begin
  Result := False;
end;

function TSqlColumnReference.GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel;
begin
  Result := Cursor.GetFieldGroup(FColumnName);
end;

function TSqlColumnReference.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  Result := Cursor[FColumnName].Value;
  Result.AddReference;
end;



{                                                                              }
{ TSqlParameterReference                                                       }
{                                                                              }
constructor TSqlParameterReference.CreateEx(const Name: AnsiString);
begin
  inherited Create;
  FName := Name;
end;

procedure TSqlParameterReference.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  Output.Identifier(FName);
end;

procedure TSqlParameterReference.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Identifier(FName);
end;

function TSqlParameterReference.IsLiteral: Boolean;
begin
  Result := False;
end;

procedure TSqlParameterReference.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
end;

function TSqlParameterReference.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  if not Assigned(Scope) then
    raise ESqlScope.Create('Scope required');
  Result := Scope.RequireLiteral(FName);
  Result.AddReference;
end;



{                                                                              }
{ TSqlIdentifier                                                               }
{                                                                              }
constructor TSqlIdentifier.CreateEx(const Name: AnsiString);
begin
  inherited Create;
  FName := Name;
end;

procedure TSqlIdentifier.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  Output.Identifier(FName);
end;

procedure TSqlIdentifier.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Symbol(':');
  Output.Identifier(FName);
end;

function TSqlIdentifier.IsLiteral: Boolean;
begin
  Result := False;
end;

procedure TSqlIdentifier.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
end;

function TSqlIdentifier.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  if not Assigned(Scope) then
    raise ESqlScope.Create('Scope required');
  Result := Scope.RequireLiteral(FName);
  Result.AddReference;
end;



{                                                                              }
{ ASqlValueExpressionProxy                                                     }
{   Base class for Value Expression proxies.                                   }
{                                                                              }
constructor ASqlValueExpressionProxy.CreateEx(const ValueExpr: ASqlValueExpression);
begin
  inherited Create;
  Assert(Assigned(ValueExpr));
  FValueExpr := ValueExpr;
end;

destructor ASqlValueExpressionProxy.Destroy;
begin
  FreeAndNil(FValueExpr);
  inherited Destroy;
end;

procedure ASqlValueExpressionProxy.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  FValueExpr.TextOutputStructure(Output);
end;

procedure ASqlValueExpressionProxy.TextOutputSql(const Output: TSqlTextOutput);
begin
  FValueExpr.TextOutputSql(Output);
end;

function ASqlValueExpressionProxy.IsLiteral: Boolean;
begin
  Result := FValueExpr.IsLiteral;
end;

function ASqlValueExpressionProxy.Simplify: ASqlValueExpression;
begin
  FValueExpr := FValueExpr.Simplify;
  Result := self;
end;

function ASqlValueExpressionProxy.GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel;
begin
  Result := FValueExpr.GetGroupLevel(Cursor);
end;

procedure ASqlValueExpressionProxy.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FValueExpr.Prepare(Database, Cursor, Scope);
end;

function ASqlValueExpressionProxy.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  Result := FValueExpr.Evaluate(Engine, Cursor, Scope);
end;



{                                                                              }
{ TSqlValueExpressionWithCollate                                               }
{                                                                              }
constructor TSqlValueExpressionWithCollate.CreateEx(const ValueExpr: ASqlValueExpression;
    const Collate: AnsiString);
begin
  inherited CreateEx(ValueExpr);
  FCollate := Collate;
end;

procedure TSqlValueExpressionWithCollate.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      FValueExpr.TextOutputSql(Output);
      Space;
      Keyword(SQL_KEYWORD_COLLATE);
      Space;
      Literal(FCollate);
    end;
end;



{                                                                              }
{ TSqlIsNullExpression                                                         }
{                                                                              }
destructor TSqlIsNullExpression.Destroy;
begin
  FreeAndNil(FReplacement);
  FreeAndNil(FValueExpr);
  inherited Destroy;
end;

function TSqlIsNullExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  Result := FValueExpr.Evaluate(Engine, Cursor, Scope);
  if Result.IsNullValue then
    begin
      Result.ReleaseReference;
      Result := FReplacement.Evaluate(Engine, Cursor, Scope)
    end;
end;



{                                                                              }
{ TSqlCoalesceExpression                                                       }
{                                                                              }
constructor TSqlCoalesceExpression.CreateEx(const ExprList: ASqlValueExpressionArray);
begin
  inherited Create;
  FExprList := ExprList;
end;

destructor TSqlCoalesceExpression.Destroy;
begin
  FreeObjectArray(FExprList);
  inherited Destroy;
end;


function TSqlCoalesceExpression.IsLiteral: Boolean;
var I : Integer;
begin
  for I := 0 to Length(FExprList) - 1 do
    if not FExprList[I].IsLiteral then
      begin
        Result := False;
        exit;
      end;
  Result := True;
end;

function TSqlCoalesceExpression.Simplify: ASqlValueExpression;
var I : Integer;
begin
  for I := 0 to Length(FExprList) - 1 do
    FExprList[I] := FExprList[I].Simplify;
  Result := self;
end;

function TSqlCoalesceExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var I : Integer;
    V : ASqlLiteral;
begin
  for I := 0 to Length(FExprList) - 1 do
    begin
      V := FExprList[I].Evaluate(Engine, Cursor, Scope);
      if not V.IsNullValue then
        begin
          Result := V;
          exit;
        end;
      V.ReleaseReference;
    end;
  Result := TSqlNull.Create;
end;



{                                                                              }
{ TSqlNullIfExpression                                                         }
{                                                                              }
constructor TSqlNullIfExpression.CreateEx(const Value1, Value2: ASqlValueExpression);
begin
  inherited Create;
  Assert(Assigned(Value1));
  Assert(Assigned(Value2));
  FValue1 := Value1;
  FValue2 := Value2;
end;

destructor TSqlNullIfExpression.Destroy;
begin
  FreeAndNil(FValue2);
  FreeAndNil(FValue1);
  inherited Destroy;
end;

procedure TSqlNullIfExpression.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FValue1.TextOutputStructure(Output);
  FValue2.TextOutputStructure(Output);
end;

procedure TSqlNullIfExpression.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_NULLIF);
      Symbol('(');
      FValue1.TextOutputSql(Output);
      Symbol(',');
      FValue2.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function TSqlNullIfExpression.IsLiteral: Boolean;
begin
  Result := FValue1.IsLiteral and FValue2.IsLiteral;
end;

function TSqlNullIfExpression.Simplify: ASqlValueExpression;
begin
  FValue1 := FValue1.Simplify;
  FValue2 := FValue2.Simplify;
  Result := self;
end;

function TSqlNullIfExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var V1, V2 : ASqlLiteral;
begin
  V1 := FValue1.Evaluate(Engine, Cursor, Scope);
  try
    V2 := FValue2.Evaluate(Engine, Cursor, Scope);
    try
      if V1.Compare(V2) = crEqual then
        Result := TSqlNull.Create
      else
        begin
          V1.AddReference;
          Result := V1;
        end;
    finally
      V2.ReleaseReference;
    end;
  finally
    V1.ReleaseReference;
  end;
end;



{                                                                              }
{ TSqlCastExpression                                                           }
{                                                                              }
constructor TSqlCastExpression.CreateEx(const Operand: ASqlValueExpression;
    const TypeDefinition: TSqlDataTypeDefinition);
begin
  inherited Create;
  FOperand := Operand;
  FTypeDefinition := TypeDefinition;
end;

destructor TSqlCastExpression.Destroy;
begin
  FreeAndNil(FTypeDefinition);
  FreeAndNil(FOperand);
  inherited Destroy;
end;

function TSqlCastExpression.IsLiteral: Boolean;
begin
  Result := FOperand.IsLiteral;
end;

function TSqlCastExpression.Simplify: ASqlValueExpression;
begin
  FOperand := FOperand.Simplify;
  Result := self;
end;

function TSqlCastExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  Result := FOperand.Evaluate(Engine, Cursor, Scope);
  if Result.IsDataType(FTypeDefinition.DataType) then
    exit;
  Result := Result.DuplicateAsType(FTypeDefinition.DataType);
end;



{                                                                              }
{ TSqlCaseExpression                                                           }
{                                                                              }
destructor TSqlCaseExpression.Destroy;
begin
  FreeObjectArray(FSearchedWhen);
  FreeObjectArray(FSimpleWhen);
  FreeAndNil(FElseValue);
  FreeAndNil(FCaseOperand);
  inherited Destroy;
end;

function TSqlCaseExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var C, D : ASqlLiteral;
    I    : Integer;
    K    : TSqlSimpleWhen;
    L    : TSqlSearchedWhen;
    T    : TCompareResult;
begin
  if Assigned(FCaseOperand) then
    begin
      C := FCaseOperand.Evaluate(Engine, Cursor, Scope);
      try
        for I := 0 to Length(FSimpleWhen) - 1 do
          begin
            K := FSimpleWhen[I];
            D := K.WhenOperand.Evaluate(Engine, Cursor, Scope);
            T := C.Compare(D);
            D.ReleaseReference;
            if T = crEqual then
              begin
                Result := K.ResultExpr.Evaluate(Engine, Cursor, Scope);
                exit;
              end;
          end;
      finally
        C.ReleaseReference;
      end;
    end
  else
    for I := 0 to Length(FSearchedWhen) - 1 do
      begin
        L := FSearchedWhen[I];
        if L.Condition.Match(Engine, Cursor, Scope) then
          begin
            Result := L.ResultExpr.Evaluate(Engine, Cursor, Scope);
            exit;
          end;
      end;
  if Assigned(FElseValue) then
    Result := FElseValue.Evaluate(Engine, Cursor, Scope)
  else
    Result := TSqlNull.Create;
end;



{                                                                              }
{ ASqlUnaryOperatorExpression                                                  }
{                                                                              }
constructor ASqlUnaryOperatorExpression.CreateEx(const Operand: ASqlValueExpression);
begin
  inherited Create;
  FOperand := Operand;
end;

destructor ASqlUnaryOperatorExpression.Destroy;
begin
  FreeAndNil(FOperand);
  inherited Destroy;
end;

procedure ASqlUnaryOperatorExpression.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FOperand.TextOutputStructure(Output);
end;

function ASqlUnaryOperatorExpression.IsLiteral: Boolean;
begin
  Result := FOperand.IsLiteral;
end;

function ASqlUnaryOperatorExpression.Simplify: ASqlValueExpression;
begin
  FOperand := FOperand.Simplify;
  if FOperand.IsLiteral then
    begin
      Result := TSqlLiteralValue.CreateEx(Evaluate(ASqlDatabaseEngine(nil), nil, nil));
      Free;
    end
  else
    Result := self;
end;

function ASqlUnaryOperatorExpression.GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel;
begin
  Result := FOperand.GetGroupLevel(Cursor);
end;



{                                                                              }
{ TSqlNegateExpression                                                         }
{                                                                              }
procedure TSqlNegateExpression.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Symbol('-');
  FOperand.TextOutputSql(Output);
end;

function TSqlNegateExpression.Simplify: ASqlValueExpression;
begin
  FOperand := FOperand.Simplify;
  if FOperand.IsLiteral then
    begin
      Result := TSqlLiteralValue.CreateEx(Evaluate(nil, nil, nil));
      Free;
    end else
  if FOperand is TSqlNegateExpression then
    begin
      Result := TSqlNegateExpression(FOperand).Operand;
      TSqlNegateExpression(FOperand).Operand := nil;
      Free;
    end
  else
    Result := nil;
end;

function TSqlNegateExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
begin
  Result := FOperand.Evaluate(Engine, Cursor, Scope);
  UniqueLiteral(Result);
  Result.Negate;
end;



{                                                                              }
{ TSqlUnaryMathematicalFunction                                                }
{                                                                              }
constructor TSqlUnaryMathematicalFunction.CreateEx(
            const FunctionType: TSqlUnaryMathematicalFunctionType;
            const Operand: ASqlValueExpression);
begin
  inherited CreateEx(Operand);
  FFunctionType := FunctionType;
end;

procedure TSqlUnaryMathematicalFunction.TextOutputSql(const Output: TSqlTextOutput);
begin
  case FFunctionType of
    sumABS   : Output.Keyword('ABS');
    sumROUND : Output.Keyword('ROUND');
  end;
  Output.Symbol('(');
  FOperand.TextOutputSql(Output);
  Output.Symbol(')');
end;

function TSqlUnaryMathematicalFunction.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var V : ASqlLiteral;
    R : ASqlLiteral;
begin
  V := FOperand.Evaluate(Engine, Cursor, Scope);
  R := nil;
  try
    case FFunctionType of
      sumABS     : begin
                     R := V.Duplicate;
                     try
                       R.Abs;
                     except
                       R.ReleaseReference;
                       raise;
                     end;
                   end;
      sumROUND   : R := TSqlInteger.Create(Round(V.AsFloat));
      sumSIGN    : R := TSqlInteger.Create(Sgn(V.AsFloat));
      sumLOG     : R := TSqlFloat.Create(Ln(V.AsFloat));
      sumLOG10   : ;
      sumSIN     : R := TSqlFloat.Create(Sin(V.AsFloat));
      sumCOS     : R := TSqlFloat.Create(Cos(V.AsFloat));
      sumFLOOR   : R := TSqlInteger.Create(Trunc(V.AsFloat));
      sumCEILING : ;
      sumSQRT    : R := TSqlFloat.Create(Sqrt(V.AsFloat));
    else
      raise ESqlValueExpression.Create('Unary function not implemented');
    end;
  finally
    V.ReleaseReference;
  end;
  Result := R;
end;



{                                                                              }
{ ASqlBinaryOperatorExpression                                                 }
{                                                                              }
constructor ASqlBinaryOperatorExpression.CreateEx(const Left, Right: ASqlValueExpression);
begin
  inherited Create;
  FLeft := Left;
  FRight := Right;
end;

destructor ASqlBinaryOperatorExpression.Destroy;
begin
  FreeAndNil(FRight);
  FreeAndNil(FLeft);
  inherited Destroy;
end;

procedure ASqlBinaryOperatorExpression.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FLeft.TextOutputStructure(Output);
  FRight.TextOutputStructure(Output);
end;

procedure ASqlBinaryOperatorExpression.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Symbol('(');
      FLeft.TextOutputSql(Output);
      Space;
      TextOutOperator(Output);
      Space;
      FRight.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function ASqlBinaryOperatorExpression.IsLiteral: Boolean;
begin
  Result := FLeft.IsLiteral and FRight.IsLiteral;
end;

function ASqlBinaryOperatorExpression.Simplify: ASqlValueExpression;
begin
  FLeft := FLeft.Simplify;
  FRight := FRight.Simplify;
  if IsLiteral then
    begin
      Result := TSqlLiteralValue.CreateEx(Evaluate(ASqlDatabaseEngine(nil), nil, nil));
      Free;
    end
  else
    Result := self;
end;

function ASqlBinaryOperatorExpression.GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel;
var A, B : TSqlGroupLevel;
begin
  A := FLeft.GetGroupLevel(Cursor);
  B := FRight.GetGroupLevel(Cursor);
  if (A = sglInvalid) or (B = sglInvalid) then
    Result := sglInvalid else
  if A = sglAny then
    Result := B else
  if B = sglAny then
    Result := A else
  if A = B then
    Result := A
  else
    Result := sglInvalid;
end;

procedure ASqlBinaryOperatorExpression.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
  FLeft.Prepare(Database, Cursor, Scope);
  FRight.Prepare(Database, Cursor, Scope);
end;



{                                                                              }
{ TSqlAddExpression                                                            }
{                                                                              }
procedure TSqlAddExpression.TextOutOperator(const Output: TSqlTextOutput);
begin
  Output.Symbol('+');
end;

function TSqlAddExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var L, R : ASqlLiteral;
begin
  L := FLeft.Evaluate(Engine, Cursor, Scope);
  R := FRight.Evaluate(Engine, Cursor, Scope);
  Result := L.Add(R);
  L.ReleaseReference;
  R.ReleaseReference;
end;



{                                                                              }
{ TSqlSubtractExpression                                                       }
{                                                                              }
procedure TSqlSubtractExpression.TextOutOperator(const Output: TSqlTextOutput);
begin
  Output.Symbol('-');
end;

function TSqlSubtractExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var L, R : ASqlLiteral;
begin
  L := FLeft.Evaluate(Engine, Cursor, Scope);
  R := FRight.Evaluate(Engine, Cursor, Scope);
  Result := L.Subtract(R);
  L.ReleaseReference;
  R.ReleaseReference;
end;



{                                                                              }
{ TSqlMultiplyExpression                                                       }
{                                                                              }
procedure TSqlMultiplyExpression.TextOutOperator(const Output: TSqlTextOutput);
begin
  Output.Symbol('*');
end;

function TSqlMultiplyExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var L, R : ASqlLiteral;
begin
  L := FLeft.Evaluate(Engine, Cursor, Scope);
  R := FRight.Evaluate(Engine, Cursor, Scope);
  Result := L.Multiply(R);
  L.ReleaseReference;
  R.ReleaseReference;
end;



{                                                                              }
{ TSqlDivideExpression                                                         }
{                                                                              }
procedure TSqlDivideExpression.TextOutOperator(const Output: TSqlTextOutput);
begin
  Output.Symbol('/');
end;

function TSqlDivideExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var L, R : ASqlLiteral;
begin
  L := FLeft.Evaluate(Engine, Cursor, Scope);
  R := FRight.Evaluate(Engine, Cursor, Scope);
  Result := L.Divide(R);
  L.ReleaseReference;
  R.ReleaseReference;
end;



{                                                                              }
{ TSqlSetFunctionExpression                                                    }
{                                                                              }
constructor TSqlSetFunctionExpression.CreateEx(const FunctionType: TSqlSetFunctionType;
    const Quantifier: TSqlSetQuantifier; const ValueExpr: ASqlValueExpression);
begin
  inherited Create;
  FFunctionType := FunctionType;
  FQuantifier := Quantifier;
  FValueExpr := ValueExpr;
end;

destructor TSqlSetFunctionExpression.Destroy;
begin
  FreeAndNil(FValueExpr);
  inherited Destroy;
end;

procedure TSqlSetFunctionExpression.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      case FFunctionType of
        scmAVG   : Keyword(SQL_KEYWORD_AVG);
        scmMAX   : Keyword(SQL_KEYWORD_MIN);
        scmMIN   : Keyword(SQL_KEYWORD_MAX);
        scmSUM   : Keyword(SQL_KEYWORD_SUM);
        scmCOUNT : Keyword(SQL_KEYWORD_COUNT);
      end;
      Symbol('(');
      FValueExpr.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function TSqlSetFunctionExpression.IsLiteral: Boolean;
begin
  Result := FValueExpr.IsLiteral;
end;

function TSqlSetFunctionExpression.Simplify: ASqlValueExpression;
begin
  FValueExpr := FValueExpr.Simplify;
  if IsLiteral then
    begin
      Result := TSqlLiteralValue.CreateEx(FValueExpr.Evaluate(ASqlDatabaseEngine(nil), nil, nil));
      Free;
    end
  else
    Result := self;
end;

function TSqlSetFunctionExpression.GetGroupLevel(const Cursor: ASqlCursor): TSqlGroupLevel;
begin
  Result := FValueExpr.GetGroupLevel(Cursor);
  case Result of
    sglUngrouped : Result := sglCursor;
    sglCursor    : Result := sglGrouped;
    sglGrouped   : Result := sglInvalid;
  end;
end;

procedure TSqlSetFunctionExpression.Prepare(const Database: ASqlDatabase;
    const Cursor: ASqlCursor; const Scope: ASqlScope);
begin
end;

function TSqlSetFunctionExpression.CalculateStatistic(
    const Engine: ASqlDatabaseEngine; const Cursor: ASqlCursor;
    const Scope: ASqlScope): ASqlLiteral;
var R, V : ASqlLiteral;
    C    : Int64;
begin
  C := 0;
  R := nil;
  while not Cursor.Eof do
    begin
      Inc(C);
      V := FValueExpr.Evaluate(Engine, Cursor, Scope);
      if (FunctionType <> scmCOUNT) and not Assigned(R) then
        R := V.Duplicate
      else
        case FunctionType of
          scmMIN  : if R.Compare(V) = crGreater then
                      R.AssignLiteral(V);
          scmMAX  : if R.Compare(V) = crLess then
                      R.AssignLiteral(V);
          scmAVG,
          scmSUM  : R.Add(V);
        end;
      Cursor.Next;
    end;
  Cursor.Reset;
  case FunctionType of
    scmCOUNT : Result := TSqlInteger.Create(C);
    scmAVG   :
      begin
        Result := TSqlFloat.Create(R.AsFloat / C);
        R.Free;
      end;
  else
    Result := R;
  end;
end;

function TSqlSetFunctionExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var C : ASqlCursor;
begin
  C := Cursor.GetUngroupedCursor;
  if not Assigned(C) then
    raise ESqlValueExpression.Create('No grouping for set function');
  Result := CalculateStatistic(Engine, C, Scope);
  Result.AddReference;
end;



{                                                                              }
{ TSqlCharacterSubStringFunction                                               }
{                                                                              }
constructor TSqlCharacterSubStringFunction.CreateEx(const ValueExpr,
    StartPosition, StringLength: ASqlValueExpression);
begin
  inherited Create;
  FValueExpr := ValueExpr;
  FStartPosition := StartPosition;
  FStringLength := StringLength;
end;

destructor TSqlCharacterSubStringFunction.Destroy;
begin
  FreeAndNil(FStringLength);
  FreeAndNil(FStartPosition);
  FreeAndNil(FValueExpr);
  inherited Destroy;
end;

procedure TSqlCharacterSubStringFunction.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_SUBSTRING);
      Symbol('(');
      FValueExpr.TextOutputSql(Output);
      Space;
      Keyword(SQL_KEYWORD_FROM);
      Space;
      FStartPosition.TextOutputSql(Output);
      if Assigned(FStringLength) then
        begin
          Space;
          Keyword(SQL_KEYWORD_FOR);
          Space;
          FStringLength.TextOutputSql(Output);
        end;
    end;
end;

function TSqlCharacterSubStringFunction.IsLiteral: Boolean;
begin
  Result := FValueExpr.IsLiteral and FStartPosition.IsLiteral;
  if Result and Assigned(FStringLength) then
    Result := FStringLength.IsLiteral;
end;

function TSqlCharacterSubStringFunction.Simplify: ASqlValueExpression;
begin
  FValueExpr := FValueExpr.Simplify;
  FStartPosition := FStartPosition.Simplify;
  if Assigned(FStringLength) then
    FStringLength := FStringLength.Simplify;
  if IsLiteral then
    begin
      Result := TSqlLiteralValue.CreateEx(Evaluate(nil, nil, nil));
      Free;
    end
  else
    Result := self;
end;

function TSqlCharacterSubStringFunction.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var V, S, L : ASqlLiteral;
    T : AnsiString;
    I, J : Integer;
begin
  V := FValueExpr.Evaluate(Engine, Cursor, Scope);
  S := FStartPosition.Evaluate(Engine, Cursor, Scope);
  if Assigned(FStringLength) then
    L := FStringLength.Evaluate(Engine, Cursor, Scope)
  else
    L := nil;
  T := V.AsString;
  I := S.AsInteger;
  if Assigned(L) then
    begin
      J := L.AsInteger;
      T := Copy(T, I, J);
    end
  else
    T := CopyFromA(T, I);
  Result := TSqlString.Create(T);
  if Assigned(L) then
    L.ReleaseReference;
  S.ReleaseReference;
  V.ReleaseReference;
end;



{                                                                              }
{ ASqlUnaryCharacterFunction                                                   }
{                                                                              }
constructor ASqlUnaryCharacterFunction.CreateEx(const ValueExpr: ASqlValueExpression);
begin
  inherited Create;
  FValueExpr := ValueExpr;
end;

destructor ASqlUnaryCharacterFunction.Destroy;
begin
  FreeAndNil(FValueExpr);
  inherited Destroy;
end;

procedure ASqlUnaryCharacterFunction.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FValueExpr.TextOutputStructure(Output);
end;

function ASqlUnaryCharacterFunction.IsLiteral: Boolean;
begin
  Result := FValueExpr.IsLiteral;
end;

function ASqlUnaryCharacterFunction.Simplify: ASqlValueExpression;
begin
  FValueExpr := FValueExpr.Simplify;
  if IsLiteral then
    begin
      Result := TSqlLiteralValue.CreateEx(Evaluate(ASqlDatabaseEngine(nil), nil, nil));
      Free;
    end
  else
    Result := self;
end;



{                                                                              }
{ TSqlCharacterFoldFunction                                                    }
{                                                                              }
constructor TSqlCharacterFoldFunction.CreateEx(const Operation: TSqlCharacterFoldOperation;
    const ValueExpr: ASqlValueExpression);
begin
  inherited CreateEx(ValueExpr);
  FOperation := Operation;
end;

procedure TSqlCharacterFoldFunction.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      case FOperation of
        scfUpper : Keyword(SQL_KEYWORD_UPPER);
        scfLower : Keyword(SQL_KEYWORD_LOWER);
      end;
      Symbol('(');
      FValueExpr.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function TSqlCharacterFoldFunction.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var V : ASqlLiteral;
begin
  V := FValueExpr.Evaluate(Engine, Cursor, Scope);
  case FOperation of
    scfUpper : Result := TSqlString.Create(UpperCase(V.AsString));
    scfLower : Result := TSqlString.Create(LowerCase(V.AsString));
  else
    Result := nil;
  end;
  V.ReleaseReference;
end;



{                                                                              }
{ TSqlCharacterConcatenationOperation                                          }
{                                                                              }
constructor TSqlCharacterConcatenationOperation.CreateEx(const Left, Right: ASqlValueExpression);
begin
  inherited Create;
  FLeft := Left;
  FRight := Right;
end;

destructor TSqlCharacterConcatenationOperation.Destroy;
begin
  FreeAndNil(FRight);
  FreeAndNil(FLeft);
  inherited Destroy;
end;

procedure TSqlCharacterConcatenationOperation.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Symbol('(');
      FLeft.TextOutputSql(Output);
      Space;
      Symbol('||');
      Space;
      FRight.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function TSqlCharacterConcatenationOperation.IsLiteral: Boolean;
begin
  Result := FLeft.IsLiteral and FRight.IsLiteral;
end;

function TSqlCharacterConcatenationOperation.Simplify: ASqlValueExpression;
begin
  FLeft := FLeft.Simplify;
  FRight := FRight.Simplify;
  if IsLiteral then
    begin
      Result := TSqlLiteralValue.CreateEx(Evaluate(nil, nil, nil));
      Free;
    end
  else
    Result := self;
end;

function TSqlCharacterConcatenationOperation.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var L, R : ASqlLiteral;
begin
  L := FLeft.Evaluate(Engine, Cursor, Scope);
  R := FRight.Evaluate(Engine, Cursor, Scope);
  Result := TSqlString.Create(L.AsString + R.AsString);
  R.ReleaseReference;
  L.ReleaseReference;
end;



{                                                                              }
{ TSqlCharacterPositionExpression                                              }
{                                                                              }
constructor TSqlCharacterPositionExpression.CreateEx(const SubValueExpr, ValueExpr: ASqlValueExpression);
begin
  inherited Create;
  FSubValueExpr := SubValueExpr;
  FValueExpr := ValueExpr;
end;

destructor TSqlCharacterPositionExpression.Destroy;
begin
  FreeAndNil(FValueExpr);
  FreeAndNil(FSubValueExpr);
  inherited Destroy;
end;

procedure TSqlCharacterPositionExpression.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_POSITION);
      Symbol('(');
      FSubValueExpr.TextOutputSql(Output);
      Space;
      Keyword(SQL_KEYWORD_IN);
      Space;
      FValueExpr.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function TSqlCharacterPositionExpression.IsLiteral: Boolean;
begin
  Result := FSubValueExpr.IsLiteral and FValueExpr.IsLiteral;
end;

function TSqlCharacterPositionExpression.Simplify: ASqlValueExpression;
begin
  FSubValueExpr := FSubValueExpr.Simplify;
  FValueExpr := FValueExpr.Simplify;
  if IsLiteral then
    begin
      Result := TSqlLiteralValue.CreateEx(Evaluate(nil, nil, nil));
      Free;
    end
  else
    Result := self;
end;

function TSqlCharacterPositionExpression.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var S, T : ASqlLiteral;
begin
  S := FSubValueExpr.Evaluate(Engine, Cursor, Scope);
  T := FValueExpr.Evaluate(Engine, Cursor, Scope);
  Result := TSqlInteger.Create(Pos(S.AsString, T.AsString));
  T.ReleaseReference;
  S.ReleaseReference;
end;



{                                                                              }
{ TSqlCharacterTrimFunction                                                    }
{                                                                              }
constructor TSqlCharacterTrimFunction.CreateEx(const TrimOperation: TSqlTrimOperation;
    const ValueExpr, TrimCharacters: ASqlValueExpression);
begin
  inherited Create;
  FTrimOperation := TrimOperation;
  FValueExpr := ValueExpr;
  FTrimCharacters := TrimCharacters;
end;

destructor TSqlCharacterTrimFunction.Destroy;
begin
  FreeAndNil(FTrimCharacters);
  FreeAndNil(FValueExpr);
  inherited Destroy;
end;

procedure TSqlCharacterTrimFunction.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_TRIM);
      Symbol('(');
      case FTrimOperation of
        stoLeading : begin
                       Keyword(SQL_KEYWORD_LEADING);
                       Space;
                     end;
        stoTrailing : begin
                       Keyword(SQL_KEYWORD_TRAILING);
                       Space;
                     end;
      end;
      if Assigned(FTrimCharacters) then
        begin
          FTrimCharacters.TextOutputSql(Output);
          Space;
          Keyword(SQL_KEYWORD_FROM);
          Space;
        end;
      FValueExpr.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function TSqlCharacterTrimFunction.IsLiteral: Boolean;
begin
  Result := FValueExpr.IsLiteral;
  if Result and Assigned(FTrimCharacters) then
    Result := FTrimCharacters.IsLiteral;
end;

function TSqlCharacterTrimFunction.Simplify: ASqlValueExpression;
begin
  FValueExpr := FValueExpr.Simplify;
  if Assigned(FTrimCharacters) then
    FTrimCharacters := FTrimCharacters.Simplify;
  if IsLiteral then
    begin
      Result := TSqlLiteralValue.CreateEx(Evaluate(nil, nil, nil));
      Free;
    end
  else
    Result := self;
end;

function TSqlCharacterTrimFunction.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var V, W : ASqlLiteral;
    S, T : AnsiString;
    C    : CharSet;
begin
  V := FValueExpr.Evaluate(Engine, Cursor, Scope);
  S := V.AsString;
  V.ReleaseReference;
  if Assigned(FTrimCharacters) then
    begin
      W := FTrimCharacters.Evaluate(Engine, Cursor, Scope);
      T := W.AsString;
      W.ReleaseReference;
      C := StrToCharSet(T);
    end
  else
    C := [' '];
  case FTrimOperation of
    stoLeading  : StrTrimLeftInPlaceA(S, C);
    stoTrailing : StrTrimRightInPlaceA(S, C);
    stoBoth     : StrTrimInPlaceA(S, C);
  end;
  Result := TSqlString.Create(S);
end;



{                                                                              }
{ TSqlBitConcatenationOperation                                                }
{                                                                              }
constructor TSqlBitConcatenationOperation.CreateEx(const Left, Right: ASqlValueExpression);
begin
  inherited Create;
  FLeft := Left;
  FRight := Right;
end;

destructor TSqlBitConcatenationOperation.Destroy;
begin
  FreeAndNil(FRight);
  FreeAndNil(FLeft);
  inherited Destroy;
end;

procedure TSqlBitConcatenationOperation.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Symbol('(');
      FLeft.TextOutputSql(Output);
      Space;
      Symbol('||');
      Space;
      FRight.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function TSqlBitConcatenationOperation.IsLiteral: Boolean;
begin
  Result := FLeft.IsLiteral and FRight.IsLiteral;
end;

function TSqlBitConcatenationOperation.Simplify: ASqlValueExpression;
begin
  FLeft := FLeft.Simplify;
  FRight := FRight.Simplify;
  if IsLiteral then
    begin
      Result := TSqlLiteralValue.CreateEx(Evaluate(nil, nil, nil));
      Free;
    end
  else
    Result := self;
end;

function TSqlBitConcatenationOperation.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var L, R : ASqlLiteral;
begin
  L := FLeft.Evaluate(Engine, Cursor, Scope);
  R := FRight.Evaluate(Engine, Cursor, Scope);
  Result := TSqlString.Create(L.AsString + R.AsString);
  R.ReleaseReference;
  L.ReleaseReference;
end;



{                                                                              }
{ TSqlRowValueConstructor                                                      }
{                                                                              }
destructor TSqlRowValueConstructor.Destroy;
begin
  FreeAndNil(FRowSubQuery);
  FreeObjectArray(FRowElements);
  FreeAndNil(FRowElement);
  inherited Destroy;
end;

procedure TSqlRowValueConstructor.TextOutputStructureParameters(const Output: TSqlTextOutput);
var I : Integer;
begin
  if Assigned(FRowElement) then
    begin
      FRowElement.TextOutputStructure(Output);
      exit;
    end;
  if Assigned(FRowSubQuery) then
    begin
      FRowSubQuery.TextOutputStructure(Output);
      exit;
    end;
  Output.StructureParamBegin;
  for I := 0 to Length(FRowElements) - 1 do
    FRowElements[I].TextOutputStructure(Output);
  Output.StructureParamEnd;
end;

procedure TSqlRowValueConstructor.TextOutputSql(const Output: TSqlTextOutput);
var I : Integer;
begin
  if Assigned(FRowElement) then
    begin
      FRowElement.TextOutputSql(Output);
      exit;
    end;
  if Assigned(FRowSubQuery) then
    begin
      FRowSubQuery.TextOutputSql(Output);
      exit;
    end;
  Output.Symbol('(');
  for I := 0 to Length(FRowElements) - 1 do
    begin
      if I > 0 then
        Output.Symbol(',');
      FRowElements[I].TextOutputSql(Output);
    end;
  Output.Symbol(')');
end;

function TSqlRowValueConstructor.Simplify: ASqlValueExpression;
var I : Integer;
begin
  if Assigned(FRowElement) then
    FRowElement := FRowElement.Simplify;
  for I := 0 to Length(FRowElements) - 1 do
    FRowElements[I] := FRowElements[I].Simplify;
  if Assigned(FRowSubQuery) then
    FRowSubQuery := FRowSubQuery.Simplify;
  Result := self;
end;

function TSqlRowValueConstructor.Evaluate(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor; const Scope: ASqlScope): ASqlLiteral;
var C    : ASqlCursor;
    I, L : Integer;
    A    : ASqlLiteral;
    R    : ASqlLiteralArray;
begin
  if Assigned(FRowElement) then
    begin
      Result := FRowElement.Evaluate(Engine, Cursor, Scope);
      exit;
    end;
  if Assigned(FRowSubQuery) then
    begin
      C := FRowSubQuery.GetCursor(Engine, Cursor, Scope);
      if C.Eof then
        Result := nil
      else
        begin
          L := C.FieldCount;
          SetLength(R, L);
          for I := 0 to L - 1 do
            begin
              A := C.FieldByIndex[I].Value;
              A.AddReference;
              R[I] := A;
            end;
          Result := TSqlLiteralArray.Create(R);
        end;
      C.Free;
      exit;
    end;
  L := Length(FRowElements);
  if L = 0 then
    begin
      Result := nil;
      exit;
    end;
  SetLength(R, L);
  for I := 0 to L - 1 do
    R[I] := FRowElements[I].Evaluate(Engine, Cursor, Scope);
  Result := TSqlLiteralArray.Create(R);
end;



end.

