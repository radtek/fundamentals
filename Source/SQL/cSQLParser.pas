{******************************************************************************}
(*                                                                            *)
(*   Library:       Fundamentals SQL                                          *)
(*    Description:   SQL parser.                                              *)
(*    Version:       0.17                                                     *)
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
(*    2005/02/05  0.02  GO statement.                                         *)
(*    2005/03/27  0.03  Development.                                          *)
(*    2005/03/30  0.04  SQL92 BNF specifications in source.                   *)
(*    2005/03/31  0.05  Development.                                          *)
(*    2005/04/01  0.06  Development.                                          *)
(*    2005/04/08  0.07  Development.                                          *)
(*    2005/04/19  0.08  Development.                                          *)
(*    2005/04/23  0.09  Full SQL92 parsing.                                   *)
(*    2009/10/17  0.10  Development.                                          *)
(*    2009/11/14  0.11  Development.                                          *)
(*    2009/11/26  0.12  SQL99 BNF specifications in source.                   *)
(*    2009/11/27  0.13  SQL99 development.                                    *)
(*    2010/01/09  0.14  SQL2003 BNF specifications in source.                 *)
(*    2010/01/10  0.15  SQL2003 development.                                  *)
{     2011/07/12  0.16  Extensions.                                           *)
(*    2011/07/31  0.17  Extensions.                                           *)
(*                                                                            *)
(*  Features:                                                                 *)
(*    * SQL92 compliance                                                      *)
(*    * Optional syntax extentions (mostly Transact-SQL)                      *)
(*    * Partial SQL99/SQL2003                                                 *)
(*                                                                            *)
(*  Todo:                                                                     *)
(*    * Complete SQL99/2003                                                   *)
(*    * Check ??                                                              *)
(*                                                                            *)
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLParser;

interface

uses
  { System }
  SysUtils,

  { Fundamentals }
  cUtils,
  cTimers,

  { SQL }
  cSQLUtils,
  cSQLDataTypes,
  cSQLLexer,
  cSQLStructs,
  cSQLNodes,
  cSQLNodesStructs,
  cSQLNodesValues,
  cSQLNodesConditions,
  cSQLNodesQuery,
  cSQLNodesStatements;



{                                                                              }
{ TSqlParser                                                                   }
{   SQL Parser.                                                                }
{                                                                              }
const
  SqlParserVersion = '0.17';

type
  TSqlParserOptions = set of (
      spoExtendedSyntax);
  TSqlParserCompatibility = (
      spcSql92,
      spcSql99,
      spcSql2003);
  TSqlParser = class
  protected
    FOptions       : TSqlParserOptions;
    FCompatibility : TSqlParserCompatibility;
    FLexer         : TSqlLexer;
    FTokenType     : Integer;
    FLineNr        : Integer;
    FParseTime     : Int64;

    // Parsing helper functions
    procedure ParseError(const Msg: String; const Args: array of const); overload;
    procedure ParseError(const Msg: String); overload;
    procedure UnexpectedToken;
    function  GetNextToken: Integer;
    function  SkipToken(const TokenType: Integer): Boolean;
    function  SkipAnyToken(const TokenSet: ByteSet): Integer;
    procedure CheckToken(const TokenType: Integer; const Error: String; const Args: array of const); overload;
    procedure CheckToken(const TokenType: Integer; const Error: String); overload;
    procedure ExpectToken(const TokenType: Integer; const Error: String; const Args: array of const); overload;
    procedure ExpectToken(const TokenType: Integer; const Error: String); overload;
    procedure ExpectKeyword(const TokenType: Integer; const Keyword: AnsiString);
    procedure ExpectLeftParen;
    procedure ExpectRightParen;
    procedure ExpectEqualSign;
    procedure ExpectComma;

    // Simple results
    function  ExpectUnsignedInt64: Int64;
    function  ExpectUnsignedInteger: Integer;
    function  TokenIsIdentifier(const AllowKeyword: Boolean): Boolean;
    function  ParseIdentifier(const AllowKeyword: Boolean = False): AnsiString;
    function  ExpectIdentifier(const AllowKeyword: Boolean = False): AnsiString;
    function  ParseIdentifierList(const AllowKeyword: Boolean = False): AnsiStringArray;
    function  ParseBasicIdentifierChain: AnsiString;
    function  ParseColumnName: AnsiString;
    function  ExpectColumnName: AnsiString;
    function  ParseColumnNameList: AnsiStringArray;
    function  ParseMethodName: AnsiString;
    function  ParseSchemaName: AnsiString;
    function  ParseQualifiedIdentifier: AnsiString;
    function  ExpectQualifiedIdentifier: AnsiString;
    function  ParseQualifiedName: AnsiString;
    function  ParseSchemaQualifiedName: AnsiString;
    function  ParseSchemaQualifiedTypeName: AnsiString;
    function  ParseUserDefinedTypeName: AnsiString;
    function  ParseSpecificName: AnsiString;
    function  ParseSchemaQualifiedRoutineName: AnsiString;
    function  ParseDomainName: AnsiString;
    function  ParseQualifiedLocalTableName: AnsiString;
    function  ParseTableName: AnsiString;
    function  ParseQueryName: AnsiString;
    function  ParseTableOrQueryName: AnsiString;
    function  ParseTargetTable: AnsiString;
    function  ParseQualifier: AnsiString;
    function  ParseParameterName: AnsiString;
    function  ParseHostParameterName: AnsiString;
    function  ParseSqlParameterReference: AnsiString;
    function  ParseSqlVariableReference: AnsiString;
    function  ParseConstraintName: AnsiString;
    function  ParseCollationName: AnsiString;
    function  ParseTranslationName: AnsiString;
    function  ParseLocalQualifiedName: AnsiString;
    function  ParseCursorName: AnsiString;

    // Literals
    function  ParseExactNumericLiteral: ASqlValueExpression;
    function  ParseUnsignedNumericLiteral: ASqlValueExpression;
    function  ParseCharacterSetName: AnsiString;
    function  ParseCharacterSetSpecification: AnsiString;
    function  ParseCharacterStringLiteral: ASqlValueExpression;
    function  ParseNationalCharacterStringLiteral: ASqlValueExpression;
    function  ParseHexStringLiteral: ASqlValueExpression;
    function  ParseBitStringLiteral: ASqlValueExpression;
    function  ParseBinaryStringLiteral: ASqlValueExpression;
    function  ParseDateTimeLiteral: ASqlValueExpression;
    function  ParseIntervalLiteral: TSqlIntervalLiteralValue;
    function  ParseBooleanLiteral: ASqlValueExpression;
    function  ParseGeneralLiteral: ASqlValueExpression;
    function  ParseSignedNumericLiteral: ASqlValueExpression;
    function  ParseLiteral: ASqlValueExpression;
    function  ParseUnsignedLiteral: ASqlValueExpression;
    function  ParseParameterNameExpr: ASqlValueExpression;

    // Unsigned Value Specification
    function  ParseEmbeddedVariableName: ASqlValueExpression;
    function  ParseVariableSpecification: TSqlVariableSpecification;
    function  ParseParameterSpecification: TSqlParameterSpecification;
    function  ParseGeneralValueSpecification: ASqlValueExpression;
    function  ParseUnsignedValueSpecification: ASqlValueExpression;

    // Interval Qualifier
    function  ParseNonSecondDateTimeField: TSqlDateTimeField;
    function  ParseSingleDateTimeField: TSqlSingleDateTimeField;
    function  ParseIntervalFractionalSecondsPrecision: Integer;
    function  ParseIntervalLeadingFieldPrecision: Integer;
    function  ParseNonSecondPrimaryDateTimeField: Integer;
    function  ParseStartField: TSqlDateTimeField;
    function  ParseEndField: TSqlSingleDateTimeField;
    function  ParseIntervalQualifier: TSqlIntervalQualifier;

    // Data Type
    function  ParseTypeLength(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
    function  ParseTypePrecisionAndScale(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
    function  ParseTypePrecision(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
    function  ParseCharacterStringType(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
    function  ParseApproximateNumericType(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
    function  ParsePrecision: Integer;
    function  ParseScale: Integer;
    function  ParseExactNumericType(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
    function  ParseNumericType(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
    function  ParseDateTimeType(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
    procedure ParseIntervalType(const TypeDefinition: TSqlDataTypeDefinition);
    procedure ParseBooleanType(const TypeDefinition: TSqlDataTypeDefinition);
    procedure ParsePredefinedType(const TypeDefinition: TSqlDataTypeDefinition);
    procedure ExpectDataType(const TypeDefinition: TSqlDataTypeDefinition);

    // DateTime Value Function
    function  ParseDateTimeValueFunction: ASqlValueExpression;

    // Column Definition
    function  ParseDefaultClause: TSqlDefaultOption;
    function  ParseColumnConstraint: TObject;
    function  ParseConstraintCharacteristics: TObject;
    function  ParseColumnConstraintDefinition: TSqlColumnConstraintDefinition;
    function  ParseCollateClause: AnsiString;
    function  ParseSequenceGeneratorStartWithOption: Integer;
    function  ParseSequenceGeneratorIncrementByOption: Integer;
    function  ParseSequenceGeneratorMinMaxCycleOption: Integer;
    function  ParseBasicSequenceGeneratorOption: TObject;
    function  ParseCommonSequenceGeneratorOptions: TObject;
    function  ParseGeneratedClause: TObject;
    function  ParseReferencialAction: Integer;
    function  ParseReferenceScopeCheckAction: TObject;
    function  ParseReferenceScopeCheck: TObject;
    function  ParseColumnDefinition: TSqlColumnDefinitionEx;

    // Value Expression Primaries
    function  ParseColumnReference: ASqlValueExpression;
    function  ParseNullSpecification: Boolean;
    function  ParseEmptySpecification: TObject;
    function  ParseImplicitlyTypedValueSpecification: TObject;
    function  ParseCastOperand: TObject;
    function  ParseCastTarget: TObject;
    function  ParseCastSpecification: TSqlCastExpression;
    function  ParseSetQuantifier: TSqlSetQuantifier;
    function  ParseComputationalOperation: TSqlComputationalOperation;
    function  ParseSetFunctionType: TSqlSetFunctionType;
    function  ParseGeneralSetFunction: TSqlSetFunctionExpression;
    function  ParseGroupingOperation: AnsiStringArray;
    function  ParseBinarySetFunctionType: Integer;
    function  ParseBinarySetFunction: TSqlSetFunctionExpression;
    function  ParseRankFunctionType: Integer;
    function  ParseWithinGroupSpecification: TObject;
    function  ParseHypotheticalSetFunctionValueExpressionList: TObject;
    function  ParseHypotheticalSetFunction: TSqlSetFunctionExpression;
    function  ParseInverseDistributionFunctionType: Integer;
    function  ParseInverseDistributionFunctionArgument: ASqlValueExpression;
    function  ParseInverseDistributionFunction: ASqlValueExpression;
    function  ParseOrderedSetFunction: TSqlSetFunctionExpression;
    function  ParseAggregateFunction: TSqlSetFunctionExpression;
    function  ParseSetFunctionSpecification: TSqlSetFunctionExpression;
    function  ParseParameterIdentifier: ASqlValueExpression;
    function  ParseSimpleValueSpecification: ASqlValueExpression;
    function  ExpectSimpleValueSpecification: ASqlValueExpression;
    function  ParseNullIfExpression: TSqlNullIfExpression;
    function  ParseCoalesceExpression: TSqlCoalesceExpression;
    function  ParseCaseAbbreviation: ASqlValueExpression;
    function  ParseResult: ASqlValueExpression;
    function  ParseSimpleWhenClause: TSqlSimpleWhen;
    function  ExpectCaseOperand: ASqlValueExpression;
    function  ParseSimpleCase: TSqlCaseExpression;
    function  ParseSearchedWhenClause: TSqlSearchedWhen;
    function  ParseSearchedCase: TSqlCaseExpression;
    function  ParseCaseSpecification: ASqlValueExpression;
    function  ParseCaseExpression: ASqlValueExpression;
    function  ParseParameterReference: ASqlValueExpression;
    function  ParseIsNullExpression: TSqlIsNullExpression;
    function  ParseArrayFactor: ASqlValueExpression;
    function  ParseArrayConcatenation: ASqlValueExpression;
    function  ParseArrayElement: ASqlValueExpression;
    function  ParseArrayElementList: ASqlValueExpressionArray;
    function  ParseArrayValueListConstructor: ASqlValueExpression;
    function  ParseArrayValueConstructor: ASqlValueExpression;
    function  ParseArrayValueExpression: ASqlValueExpression;
    function  ParseNonParenthesizedValueExpressionPrimary: ASqlValueExpression;
    function  ParseParenthesizedValueExpression: ASqlValueExpression;
    function  ParseValueExpressionPrimary: ASqlValueExpression;

    // Numeric Value Expressions
    function  ParsePositionExpression: TSqlCharacterPositionExpression;
    function  ParseLengthExpression: TSqlLengthExpression;
    function  ParseTimeZoneField: TSqlTimeZoneField;
    function  ParseDateTimeField: TSqlDateTimeField;
    function  ParsePrimaryDateTimeField: ASqlValueExpression;
    function  ParseExtractField: ASqlValueExpression;
    function  ParseExtractSource: ASqlValueExpression;
    function  ParseExtractExpression: TSqlExtractExpression;
    function  ParseMultiSetFunction: ASqlValueExpression;
    function  ParseMultiSetValueFunction: ASqlValueExpression;
    function  ParseMultiSetPrimary: ASqlValueExpression;
    function  ParseMultiSetTerm(var GotMultiSetToken: Boolean): ASqlValueExpression;
    function  ParseMultiSetValueExpression: ASqlValueExpression;
    function  ParseCollectionValueExpression: ASqlValueExpression;
    function  ParseCardinalityExpression: ASqlValueExpression;
    function  ParseAbsoluteValueExpression: ASqlValueExpression;
    function  ParseModulusExpression: ASqlValueExpression;
    function  ParseWidthBucketFunction: ASqlValueExpression;
    function  ParseNumericValueFunction: ASqlValueExpression;
    function  ParseNumericPrimary: ASqlValueExpression;
    function  ParseFactor: ASqlValueExpression;
    function  ParseTerm(const Factor: ASqlValueExpression = nil): ASqlValueExpression;
    function  ParseNumericValueExpression(const Factor: ASqlValueExpression = nil): ASqlValueExpression;

    // Character Value Functions
    function  ParseCharacterSubStringFunction: TSqlCharacterSubStringFunction;
    function  ParseCharacterTrimFunction: TSqlCharacterTrimFunction;
    function  ParseCharacterFoldFunction: TSqlCharacterFoldFunction;
    function  ParseFormOfUseConversion: TSqlFormOfUseConversion;
    function  ParseCharacterTranslation: TSqlCharacterTranslation;
    function  ParseRegularExpressionSubStringFunction: ASqlValueExpression;
    function  ParseCharacterOverlayFunction: ASqlValueExpression;
    function  ParseSpecificTypeMethod: ASqlValueExpression;
    function  ParseTranscoding: ASqlValueExpression;
    function  ParseCharacterTransliteration: ASqlValueExpression;
    function  ParseNormalizeFunction: ASqlValueExpression;
    function  ParseCharacterValueFunction: ASqlValueExpression;

    // Bit, Character and AnsiString Value Expressions
    function  ParseBitSubStringFunction: TSqlBitSubStringFunction;
    function  ParseBitValueFunction: ASqlValueExpression;
    function  ParseStringValueFunction: ASqlValueExpression;
    function  ParseCharacterPrimary: ASqlValueExpression;
    function  ParseCharacterFactor: ASqlValueExpression;
    function  ParseCharacterValueExpression: ASqlValueExpression;
    function  ExpectCharacterValueExpression: ASqlValueExpression;
    function  ParseBitPrimary: ASqlValueExpression;
    function  ParseBitFactor: ASqlValueExpression;
    function  ParseBitValueExpression: ASqlValueExpression;
    function  ParseStringValueExpression: ASqlValueExpression;

    // DateTime Value Expressions
    function  ParseTimeZoneSpecifier: TObject;
    function  ParseTimeZone: TSqlTimeZone;
    function  ParseDateTimePrimary: ASqlValueExpression;
    function  ParseDateTimeFactor: ASqlValueExpression;
    function  ParseDateTimeTerm: ASqlValueExpression;
    function  ParseDateTimeValueExpression: ASqlValueExpression;
    function  ParseIntervalValueFunction: ASqlValueExpression;
    function  ParseIntervalPrimary: ASqlValueExpression;
    function  ParseIntervalFactor: ASqlValueExpression;
    function  ParseIntervalTerm: ASqlValueExpression;
    function  ParseIntervalValueExpression: ASqlValueExpression;

    // Boolean Value Expression
    function  ParseBooleanValueExpression: ASqlValueExpression;

    // Value Expressions
    function  ParseCommonValueExpression(const Factor: ASqlValueExpression): ASqlValueExpression;
    function  ParseValueExpression(const Factor: ASqlValueExpression = nil): ASqlValueExpression;
    function  ExpectValueExpression(const Factor: ASqlValueExpression = nil): ASqlValueExpression;

    // Select List
    function  ParseAllFieldsColumnNameList: AnsiStringArray;
    function  ParseAllFieldsReference: ASqlValueExpression;
    function  ParseAsteriskedIdentifier: AnsiString;
    function  ParseAsteriskedIdentifierChain: AnsiString;
    function  ParseQualifiedAsterisk: ASqlValueExpression;
    function  ParseAsClause: AnsiString;
    function  ParseDerivedColumn: ASqlValueExpression;
    function  ParseSelectSubList: TSqlSelectItem;
    function  ParseSelectList: TSqlSelectList;

    // Row Value
    function  ParseRowValueConstructorElementList: TObject;
    function  ParseRowSubQuery: ASqlQueryExpression;
    function  ParseExplicitRowValueConstructor: ASqlValueExpression;
    function  ParseRowValueExpression: ASqlValueExpression;
    function  ExpectRowValueExpression: ASqlValueExpression;
    function  ParseRowValueConstructorElement: ASqlValueExpression;
    function  ExpectRowValueConstructorElement: ASqlValueExpression;
    function  ParseRowValueConstructorList: ASqlValueExpressionArray;
    function  ParseRowValueConstructor: TSqlRowValueConstructor;
    function  ExpectRowValueConstructor: TSqlRowValueConstructor;
    function  ParseRowValue: ASqlValueExpression;
    function  ExpectRowValue: ASqlValueExpression;

    // Search Predicates
    function  ParseQuantifier: TSqlComparisonQuantifier;
    function  ParseQuantifiedComparisonPredicate(const RowValue: ASqlValueExpression; const CompOp: TSqlComparisonOperator): TSqlQuantifiedComparisonPredicate;
    function  ParseRowValueSpecialCase: ASqlValueExpression;
    function  ParseParenthesizedBooleanValueExpression: ASqlValueExpression;
    function  ParseBooleanPredicand: ASqlValueExpression;
    function  ParseRowValueConstructorPredicand: ASqlValueExpression;
    function  ParseRowValuePredicand: ASqlValueExpression;
    function  ParseComparisonPredicate(const RowValue: ASqlValueExpression): ASqlSearchCondition;
    function  ParseBetweenPredicate(const RowValue: ASqlValueExpression; const NotPredicate: Boolean): TSqlBetweenPredicate;
    function  ParseInValueList: ASqlValueExpressionArray;
    function  ParseInPredicateValue: ASqlValueExpression;
    function  ParseInPredicate(const RowValue: ASqlValueExpression; const NotPredicate: Boolean): TSqlInCondition;
    function  ParseLikePredicate(const RowValue: ASqlValueExpression; const NotPredicate: Boolean): TSqlLikeCondition;
    function  ParseExistsPredicate: ASqlSearchCondition;
    function  ParseUniquePredicate: TSqlUniqueCondition;
    function  ParseNullPredicate(const RowValue: ASqlValueExpression; const NotNull: Boolean): TSqlNullCondition;
    function  ParseDistinctPredicate(const RowValue: ASqlValueExpression): TSqlDistinctPredicate;
    function  ParseUserDefinedTypeSpecification: TObject;
    function  ParseTypeList: TObject;
    function  ParseTypePredicate(const RowValue: ASqlValueExpression; const NotOf: Boolean): ASqlSearchCondition;
    function  ParseIsPredicate(const RowValue: ASqlValueExpression): ASqlSearchCondition;
    function  ParseMatchPredicate(const RowValue: ASqlValueExpression): TSqlMatchPredicate;
    function  ParseOverlapsPredicate(const RowValue: ASqlValueExpression): TSqlOverlapsPredicate;
    function  ParseSimilarPredicate(const RowValue: ASqlValueExpression): TObject;
    function  ParseNormalizedPredicate: ASqlSearchCondition;
    function  ParseMemberPredicate: ASqlSearchCondition;
    function  ParseSubMultisetPredicate: ASqlSearchCondition;
    function  ParseSetPredicate: ASqlSearchCondition;
    function  ParsePredicate: ASqlSearchCondition;

    // Search Condition
    function  ParseTruthValue: TSqlTruthValue;
    function  ParseWindowFunctionType: TObject;
    function  ParseWindowName: AnsiString;
    function  ParseExistingWindowName: AnsiString;
    function  ParseWindowPartitionColumnReference: ASqlValueExpression;
    function  ParseWindowPartitionColumnReferenceList: ASqlValueExpressionArray;
    function  ParseWindowPartitionClause: TObject;
    function  ParseWindowOrderClause: TObject;
    function  ParseWindowFrameUnits: Integer;
    function  ParseWindowFramePreceding: TObject;
    function  ParseWindowFrameStart: TObject;
    function  ParseWindowFrameFollowing: TObject;
    function  ParseWindowFrameBound: TObject;
    function  ParseWindowFrameExclusion: TObject;
    function  ParseWindowFrameBetween: TObject;
    function  ParseWindowFrameExtent: TObject;
    function  ParseWindowFrameClause: TObject;
    function  ParseWindowSpecification: TObject;
    function  ParseInlineWindowSpecification: TObject;
    function  ParseWindowSpecificationDetails: TObject;
    function  ParseWindowNameOrSpecification: TObject;
    function  ParseWindowFunction: ASqlSearchCondition;
    function  ParseBooleanPrimary: ASqlSearchCondition;
    function  ParseBooleanTest: ASqlSearchCondition;
    function  ParseBooleanFactor: ASqlSearchCondition;
    function  ParseBooleanTerm: ASqlSearchCondition;
    function  ParseSearchCondition: ASqlSearchCondition;
    function  ExpectSearchCondition: ASqlSearchCondition;

    // Non-Join Query
    function  ParseGroupingColumnReference: TSqlGroupingColumnReference;
    function  ParseEmptyGroupingSet: TObject;
    function  ParseGroupingSetsSpecification: TObject;
    function  ParseCubeList: TObject;
    function  ParseRollupList: TObject;
    function  ParseOrdinaryGroupingSet: TObject;
    function  ParseGroupingElement: TObject;
    function  ParseGroupingElementList: TObject;
    function  ParseGroupByClause: TSqlGroupByClause;
    function  ParseTableReferenceList: TObject;
    function  ParseFromClause: ASqlQueryExpression;
    function  ParseWhereClause: ASqlSearchCondition;
    function  ParseHavingClause: ASqlSearchCondition;
    function  ParseWindowDefinition: TObject;
    function  ParseWindowDefinitionList: TObject;
    function  ParseWindowClause: ASqlSearchCondition;
    function  ParseTableExpression: TSqlTableExpression;
    function  ParseQuerySpecification(const AllowIntoClause: Boolean = False): TSqlQueryExpression;
    function  ParseTableValueConstructorList: TSqlTableValueConstructor;
    function  ParseTableRowValueExpression: TObject;
    function  ParseRowValueExprssionList: TObject;
    function  ParseTableValueConstructor: ASqlQueryExpression;
    function  ParseExplicitTable: TObject;
    function  ParseSimpleTable(const IsStatement: Boolean = False): ASqlQueryExpression;
    function  ParseQueryTerm: ASqlQueryExpression;
    function  ParseQueryPrimary: ASqlQueryExpression;
    function  ParseNonJoinQueryTerm(const IsStatement: Boolean = False): ASqlQueryExpression;
    function  ParseCorrespondingSpec: TSqlCorrespondingSpec;
    function  ParseNonJoinQueryExpression(const IsStatement: Boolean = False): ASqlQueryExpression;
    function  ParseNonJoinQueryPrimary(const IsStatement: Boolean = False): ASqlQueryExpression;

    // Query Expression
    function  ParseCorrelationNameClause: AnsiString;
    function  ParseDerivedColumnListClause: AnsiStringArray;
    function  ParseSubQuery(const GotLeftParen: Boolean): ASqlQueryExpression;
    function  ParseTableSubQuery(const GotLeftParen: Boolean): ASqlQueryExpression;
    function  ExpectTableSubQuery(const GotLeftParen: Boolean): ASqlQueryExpression;
    function  ParseDerivedTableReference: TSqlDerivedTableReference;
    function  ParseSimpleTableReference: TSqlSimpleTableReference;
    function  ParseTablePrimary: ASqlQueryExpression;
    function  ParseTableReference: ASqlQueryExpression;
    function  ParseCrossJoin(const TableRef: ASqlQueryExpression): TSqlJoinedQuery;
    function  ParseJoinType: Integer;
    function  ParseQualifiedJoin: ASqlQueryExpression;
    function  ParseJoinCondition: ASqlSearchCondition;
    function  ParseJoinColumnList: TObject;
    function  ParseNamedColumnsJoin: TObject;
    function  ParseJoinSpecification: TObject;
    function  ParseNaturalJoin: ASqlQueryExpression;
    function  ParseUnionJoin: ASqlQueryExpression;
    function  ParseJoinedTable(const TableRef: ASqlQueryExpression): ASqlQueryExpression;
    function  ParseWithListElement: TObject;
    function  ParseWithList: TObject;
    function  ParseWithClause: TObject;
    function  ParseQueryExpressionBody: ASqlQueryExpression;
    function  ParseQueryExpression(const IsStatement: Boolean = False): ASqlQueryExpression;
    function  ExpectQueryExpression(const IsStatement: Boolean = False): ASqlQueryExpression;

    // Statements
    function  ParseUpdateSource: TObject;
    function  ParseAssignedRow: TObject;
    function  ParseMultipleColumnAssignment: TObject;
    function  ParseMutatedSetClause: TObject;
    function  ParseUpdateTarget: TObject;
    function  ParseObjectColumn: AnsiString;
    function  ParseUpdateSetClause: TSqlUpdateSetItem;
    function  ParseUpdateSetList: TSqlUpdateSetList;
    function  ParseDynamicUpdateStatementPositioned: ASqlStatement;
    function  ParseUpdateStatement(const UpdateType: TSqlUpdateStatementType): TSqlUpdateStatement;
    function  ParseUpdateStatementPositioned: ASqlStatement;
    function  ParseUpdateStatementSearched: TSqlUpdateStatement;
    function  ParseMergeWhenClause: TObject;
    function  ParseMergeOperationSpecification: TObject;
    function  ParseMergeStatement: ASqlStatement;
    function  ParseInsertColumnList: AnsiStringArray;
    function  ParseInsertionTarget: AnsiString;
    function  ParseFromSubQuery: TObject;
    function  ParseFromConstructor: TObject;
    function  ParseFromDefault: Boolean;
    function  ParseInsertColumnsAndSource: TObject;
    function  ParseInsertStatement: TSqlInsertStatement;
    function  ParseDeleteStatement(const DeleteType: TSqlDeleteStatementType): TSqlDeleteStatement;
    function  ParseDynamicDeleteStatementPositioned: ASqlStatement;
    function  ParseDeleteStatementPositioned: ASqlStatement;
    function  ParseDeleteStatementSearched: TSqlDeleteStatement;
    function  ParseConstraintCheckTime: TSqlConstraintCheckTime;
    function  ParseConstraintDeferrable: TSqlConstraintDeferrable;
    function  ParseConstraintAttributes: TSqlConstraintAttributes;
    function  ParseConstraintNameDefinition: AnsiString;
    function  ParseUniqueSpecification: TSqlUniqueSpecification;
    function  ParseUniqueConstraintDefinition: TSqlUniqueConstraint;
    function  ParseReferentialAction: TSqlReferentialAction;
    function  ParseReferentialTriggeredAction(
              var UpdateAction, DeleteAction: TSqlReferentialAction): Boolean;
    function  ExpectMatchType: TSqlReferencesMatchType;
    function  ParseReferencesSpecification: TSqlReferencesSpecification;
    function  ParseReferentialConstraintDefinition: TSqlReferentialConstraint;
    function  ParseCheckConstraintDefinition: TSqlCheckConstraint;
    function  ParseTableConstraint: ASqlConstraint;
    function  ParseTableConstraintDefinition: TSqlTableConstraint;
    function  ParseTableElement: TSqlTableElement;
    function  ParseTableElementList: TSqlTableElementArray;
    function  ParseTableScope: Integer;
    function  ParseWithOrWithoutData: Integer;
    function  ParseAsSubQueryClause: TObject;
    function  ParseTableContentsSource: TObject;
    function  ParseTableCommitAction: TSqlTableCommitAction;
    function  ParseTableDefinition: TSqlCreateTableStatement;
    function  ParseIndexDefinition: TSqlCreateIndexStatement;
    function  ParseDropBehavior: TSqlDropBehavior;
    function  ParseDropTableStatement: TSqlDropTableStatement;
    function  ParseDropProcedureStatement: TSqlDropProcedureStatement;
    function  ParseConnectStatement: TSqlConnectStatement;
    function  ParseDisconnectObject: TSqlDisconnectObject;
    function  ParseDisconnectStatement: TSqlDisconnectStatement;
    function  ParseSqlStatementName: TSqlStatementName;
    function  ParseTargetSpecification: ASqlValueExpression;
    function  ParseParameterValue: TSqlParameterValue;
    function  ParseExecuteImmediateStatement: TSqlExecuteImmediateStatement;
    function  ParseExecuteStatementExt: TSqlExecuteStatement;
    function  ParseIntoArgument: TObject;
    function  ParseIntoArguments: TObject;
    function  ParseIntoDescriptor: TObject;
    function  ParseOutputUsingClause: TObject;
    function  ParseUsingArgument: TObject;
    function  ParseUsingArguments: TObject;
    function  ParseUsingInputDescriptor: TObject;
    function  ParseInputUsingClause: TObject;
    function  ParseSql92ExecuteStatement: TSql92ExecuteStatement;
    function  ParseExecuteStatementSub: ASqlStatement;
    function  ParseExecuteStatement: ASqlStatement;

    // Statements
    function  ParseTemporaryTableDeclaration: TSqlTemporaryTableDeclaration;
    function  ParseOrderingSpecification: TSqlOrderSpecification;
    function  ParseNullOrdering: Integer;
    function  ParseSortKey: TObject;
    function  ParseSortSpecification: TSqlSortSpecification;
    function  ParseSortSpecificationList: TSqlSortSpecificationArray;
    function  ParseOrderByClause: TSqlSortSpecificationArray;
    function  ParseDirectSelectStatementMultipleRows: ASqlQueryExpression;
    function  ParseDirectSqlDataStatement: ASqlStatement;
    function  ParseSetConnectionStatement: TSqlSetConnectionStatement;
    function  ParseSqlConnectionStatement: ASqlConnectionStatement;
    function  ParseLevelOfIsolation: TSqlLevelOfIsolation;
    function  ParseIsolationLevel: TSqlLevelOfIsolation;
    function  ParseTransactionAccessMode: Integer;
    function  ParseDiagnosticsSize: TObject;
    function  ParseTransactionMode: TSqlTransactionMode;
    function  ParseSetTransactionStatement: TSqlSetTransactionStatement;
    function  ParseSetConstraintsModeStatement: TSqlSetConstraintsModeStatement;
    function  ParseCommitStatement: TSqlCommitStatement;
    function  ParseSavepointSpecifier: TObject;
    function  ParseSavepointClause: TObject;
    function  ParseRollbackStatement: TSqlRollbackStatement;
    function  ParseSqlTransactionStatement: ASqlStatement;
    procedure ParseAddColumnDefinition(const Alter: TSqlAlterTableStatement);
    procedure ParseAddTableConstraintDefinition(const Alter: TSqlAlterTableStatement);
    procedure ParseAlterAddDefinition(const Alter: TSqlAlterTableStatement);
    function  ParseAlterSequenceGeneratorRestartOption: TObject;
    function  ParseAlterIdentityColumnAction: TObject;
    function  ParseAlterIdentityColumnSpecification: TObject;
    function  ParseAlterColumnAction: TObject;
    procedure ParseAlterColumnDefinition(const Alter: TSqlAlterTableStatement);
    procedure ParseDropColumnDefinition(const Alter: TSqlAlterTableStatement);
    procedure ParseDropTableConstraintDefinition(const Alter: TSqlAlterTableStatement);
    procedure ParseAlterDropDefinition(const Alter: TSqlAlterTableStatement);
    function  ParseAlterTableAction: TObject;
    function  ParseAlterTableStatement: TSqlAlterTableStatement;
    function  ParseViewDefinition: TSqlViewDefinitionStatement;
    function  ParseAction: TSqlAction;
    function  ParseRoutineType: Integer;
    function  ParseObjectName: TSqlObjectName;
    function  ParseAuthorizationIdentifier: TObject;
    function  ParseGrantee: TSqlGrantee;
    function  ParsePrivileges: TSqlPrivileges;
    function  ParseGrantees: TSqlGranteeArray;
    function  ParseGrantor: Integer;
    function  ParseGrantRoleStatement: TSqlGrantStatement;
    function  ParseGrantPrivilegeStatement: TSqlGrantStatement;
    function  ParseGrantStatement: TSqlGrantStatement;
    function  ParseAssertionDefinition: TSqlAssertionDefinitionStatement;
    function  ParseDomainConstraint: TSqlDomainConstraint;
    function  ParseDomainDefinition: TSqlDomainDefinitionStatement;
    function  ParseCharacterSetDefinition: TSqlCharacterSetDefinition;
    function  ParseParameterMode: TSqlParameterMode;
    function  ParseSqlParameterName: AnsiString;
    function  ParseParameterType: TObject;
    function  ParseSqlParameterDeclaration: TObject;
    function  ParseSqlParameterDeclarationList: TObject;
    function  ParseLanguageClause: TObject;
    function  ParseParameterStyleClause: TObject;
    function  ParseDeterministicCharacteristic: Integer;
    function  ParseSQLDataAccessIndication: Integer;
    function  ParseNullCallClause: Integer;
    function  ParseDynamicResultSetsCharacteristic: TObject;
    function  ParseSavepointLevelIndication: Integer;
    function  ParseRoutineCharacteristic: TObject;
    function  ParseRoutineCharacteristics: TObject;
    function  ParseExternalBodyReference: TObject;
    function  ParseSQLRoutineBody: TObject;
    function  ParseRoutineBody: TObject;
    function  ParseSqlInvokedProcedure: ASqlStatement;
    function  ParseLocatorIndication: Boolean;
    function  ParseResultCast: TObject;
    function  ParseReturnsDataType: TObject;
    function  ParseReturnsType: TObject;
    function  ParseReturnsClause: TObject;
    function  ParseDispatchClause: Boolean;
    function  ParseFunctionSpecification: ASqlStatement;
    function  ParseMethodSpecificationDesignator: ASqlStatement;
    function  ParseSqlInvokedFunction: ASqlStatement;
    function  ParseSchemaRoutine: ASqlStatement;
    function  ParseTriggerActionTime: Integer;
    function  ParseTriggerColumnList: AnsiStringArray;
    function  ParseTriggerEvent: TObject;
    function  ParseTriggeredSqlStatement: TObject;
    function  ParseTriggeredAction: TObject;
    function  ParseTriggerDefinition: ASqlStatement;
    function  ParseTransformDefinition: ASqlStatement;
    function  ParseUserDefinedTypeDefinition: ASqlStatement;
    function  ParseRoleDefinition: ASqlStatement;
    function  ParseSchemaElement: ASqlStatement;
    function  ParseSchemaNameClause: TSqlSchemaNameClause;
    function  ParseSchemaDefinition: TSqlSchemaDefinitionStatement;
    function  ParseCollationSource: TSqlCollationSource;
    function  ParseCollationDefinition: TSqlCollationDefinitionStatement;
    function  ParseTranslationSpecification: TSqlTranslationSpecification;
    function  ParseTranslationDefinition: TSqlTranslationDefinitionStatement;
    function  ParseDatabaseDefinitionFileSpec: TSqlDatabaseDefinitionFileSpec;
    function  ParseDatabaseDefinition: TSqlDatabaseDefinitionStatement;
    function  ParseLoginDefinition: TSqlLoginDefinitionStatement;
    function  ParseUserDefinition: TSqlUserDefinitionStatement;
    function  ParseSqlSchemaDefinitionStatement: ASqlStatement;
    function  ParseRevokeStatement: TSqlRevokeStatement;
    procedure ParseSetDomainDefaultClause(const A: TSqlAlterDomainStatement);
    procedure ParseDropDomainDefaultClause(const A: TSqlAlterDomainStatement);
    procedure ParseAddDomainConstraintDefinition(const A: TSqlAlterDomainStatement);
    procedure ParseDropDomainConstraintDefinition(const A: TSqlAlterDomainStatement);
    function  ParseAlterDomainStatement: TSqlAlterDomainStatement;
    function  ParseDropViewStatement: TSqlDropStatement;
    function  ParseDropDomainStatement: TSqlDropStatement;
    function  ParseDropCharacterSetStatement: TSqlDropStatement;
    function  ParseDropCollationStatement: TSqlDropStatement;
    function  ParseDropTranslationStatement: TSqlDropStatement;
    function  ParseDropAssertionStatement: TSqlDropStatement;
    function  ParseDropDatabaseStatement: TSqlDropStatement; 
    function  ParseDropSchemaStatement: TSqlDropStatement;
    function  ParseSqlSchemaStatement: ASqlStatement;
    function  ParseValueSpecification: ASqlValueExpression;
    function  ParseSetCatalogStatement: TSqlSessionSetStatement;
    function  ParseSetSchemaStatement: TSqlSessionSetStatement;
    function  ParseSetNamesStatement: TSqlSessionSetStatement;
    function  ParseSetSessionAuthorizationIdentifierStatement: TSqlSessionSetStatement;
    function  ParseSetLocalTimeZoneStatement: TSqlSetLocalTimeZoneStatement;
    function  ParseSqlSessionStatement: ASqlStatement;
    function  ParseDirectlyExecutableStatement: ASqlStatement;
    function  ParseDirectSqlStatement: ASqlStatement;
    function  ParseSelectTargetList: ASqlValueExpressionArray;
    function  ParseSelectStatementSingleRow: TSqlSelectStatement;
    function  ParseSqlDataChangeStatement: ASqlStatement;
    function  ParseDynamicOpenStatement: TSqlDynamicOpenStatement;
    function  ParseOpenStatement: ASqlStatement;
    function  ParseFetchTargetList: ASqlValueExpressionArray;
    function  ParseFetchStatementExt(const FetchType: TSqlFetchType): TSqlFetchStatement;
    function  ParseFetchStatement: TSqlFetchStatement;
    function  ParseDynamicFetchStatement: TSqlFetchStatement;
    function  ParseDynamicCloseStatement: TSqlDynamicCloseStatement;
    function  ParseCloseStatement: ASqlStatement;
    function  ParseSqlDataStatement: ASqlStatement;
    function  ParseExtendedStatementName: TObject;
    function  ParseStatementCursor: TObject;
    function  ParseResultSetCursor: TObject;
    function  ParseCursorIntent: TObject;
    function  ParseAllocateCursorStatement: TSqlAllocateCursorStatement;
    function  ParseScopeOption: TSqlScopeOption;
    function  ParseExtendedCursorName: TSqlDynamicCursorName;
    function  ExpectExtendedCursorName: TSqlDynamicCursorName;
    function  ParseDynamicCursorName: TSqlDynamicCursorName;
    function  ExpectDynamicCursorName: TSqlDynamicCursorName;
    function  ParseUsingClause: TSqlUsingClause;
    function  ParseSqlDynamicDataStatement: ASqlStatement;
    function  ExpectSQLStatementVariable: ASqlValueExpression;
    function  ParseAttributesSpecification: ASqlValueExpression;
    function  ParsePrepareStatement: TSqlPrepareStatement;
    function  ParseDeallocatePrepareStatement: TSqlDeallocatePrepareStatement;
    function  ParseGetItemInformation: TSqlGetItemInformation;
    function  ParseGetDescriptorInformation: TSqlGetDescriptorInformation;
    function  ParseGetDescriptorStatement: TSqlGetDescriptorStatement;
    function  ParseSetItemInformation: TSqlSetItemInformation;
    function  ParseSetDescriptorInformation: TSqlSetDescriptorInformation;
    function  ParseSetDescriptorStatement: TSqlSetDescriptorStatement;
    function  ParseAllocateDescriptorStatement: TSqlAllocateDescriptorStatement;
    function  ParseDeallocateDescriptorStatement: TSqlDeallocateDescriptorStatement;
    function  ParseSystemDescriptorStatement: ASqlStatement;
    function  ParseDescriptorName: TSqlDescriptorName;
    function  ParseUsingDescriptor: TSqlDescriptorName;
    function  ParseDescribeStatement: TSqlDescribeStatement;
    function  ParseAllocateStatement: ASqlStatement;
    function  ParseDeallocateStatement: ASqlStatement;
    function  ParseSqlDynamicStatement: ASqlStatement;
    function  ParseSimpleTargetSpecification: ASqlValueExpression;
    function  ParseStatementInformationItem: TSqlStatementInformationItem;
    function  ParseStatementInformation: TSqlStatementInformation;
    function  ParseConditionInformationItem: TSqlConditionInformationItem;
    function  ParseConditionInformation: TSqlConditionInformation;
    function  ParseSqlDiagnosticsStatement: TSqlDiagnosticsStatement;
    function  ParseSqlStatementList: ASqlStatement;
    function  ParseSql99IfStatement: TSqlIfStatement;
    function  ParseMsSqlIfStatement: TSqlIfStatement;
    function  ParseRoutineName: AnsiString;
    function  ParseUserDefinedType: AnsiString;
    function  ParseSqlArgument: TObject;
    function  ParseSqlArgumentList: TObject;
    function  ParseCallStatement: ASqlStatement;
    function  ParseReturnValue: TObject;
    function  ParseReturnStatement: ASqlStatement;
    function  ParseModifiedFieldReference: TObject;
    function  ParseMutatorReference: TObject;
    function  ParseAssignmentTarget: TObject;
    function  ParseAssignmentSource: TObject;
    function  ParseAssignmentStatement: ASqlStatement;
    function  ParseStatementLabel: AnsiString;
    function  ParseSql99WhileStatement: TSqlWhileStatement;
    function  ParseRepeatStatement: ASqlStatement;
    function  ParseSqlVariableName: AnsiString;
    function  ParseSqlVariableNameList: TObject;
    function  ParseSqlVariableDeclaration: TObject;
    function  ParseConditionName: AnsiString;
    function  ParseSqlStateValue: TObject;
    function  ParseConditionDeclaration: TObject;
    function  ParseLocalDeclarationList: TObject;
    function  ParseLocalCursorDeclarationList: TObject;
    function  ParseHandlerType: Integer;
    function  ParseConditionValue: TObject;
    function  ParseConditionValueList: TObject;
    function  ParseLocalHandlerDeclarationList: TObject;
    function  ParseCompoundStatement: ASqlStatement;
    function  ParseSimpleCaseStatement: ASqlStatement;
    function  ParseSearchedCaseStatement: ASqlStatement;
    function  ParseCaseStatement: ASqlStatement;
    function  ParseCursorSensitivity: Integer;
    function  ParseForStatement: ASqlStatement;
    function  ParseLoopStatement: ASqlStatement;
    function  ParseIterateStatement: ASqlStatement;
    function  ParseLeaveStatement: ASqlStatement;
    function  ParseSqlControlStatement: ASqlStatement;
    function  ParseSqlProcedureStatement: ASqlStatement;
    function  ParseUpdatabilityClause: TSqlUpdatabilityClause;
    function  ParseCursorSpecification: TSqlCursorSpecification;
    function  ParseDeclareCursor: TSqlDeclareCursorStatement;
    function  ParseCondition: TSqlExceptionCondition;
    function  ParseConditionAction: TSqlExceptionConditionAction;
    function  ParseEmbeddedExceptionDeclaration: TSqlEmbeddedExceptionDeclaration;
    function  ParseStatementOrDeclaration: ASqlStatement;
    function  ParseEmbeddedSqlStatementForm1: TSqlEmbeddedSqlStatement;
    function  ParseEmbeddedSqlStatementForm2: TSqlEmbeddedSqlStatement;
    function  ParseEmbeddedSqlStatement: ASqlStatement;
    function  ParsePreparableSqlDataStatement: ASqlStatement;
    function  ParsePreparableStatement: ASqlStatement;

    // Ext: Statements
    function  ParseUseStatement: TSqlUseStatement;
    function  ParseParameterDefinition: TSqlParameterDefinition;
    function  ParseProcedureDefinition: TSqlProcedureDefinition;
    function  ParseCreateProcedureStatement: TSqlCreateProcedureStatement;
    function  ParseStatementBlock: TSqlStatementBlock;
    function  ParseWhileStatement: TSqlWhileStatement;
    function  ParseSelectStatement: TSqlSelectStatement;
    function  ParseCreateStatement: ASqlStatement;
    function  ParseDropStatement: ASqlStatement;
    function  ParseSetLocalVariable: TSqlSetLocalVariableStatement;
    function  ParseSetStatement: ASqlStatement;

    // Ext: Declare Statements
    function  ParseDeclareLocalVariable: TSqlDeclareLocalVariableStatement;
    function  ParseDeclareStatement: ASqlStatement;
    
    function  ParseAlterStatement: ASqlStatement;
    function  ParseExecStatement: ASqlStatement;

    // Statement
    function  ParseStatement: ASqlStatement;

  public
    constructor Create;
    destructor Destroy; override;

    property  Options: TSqlParserOptions read FOptions write FOptions;

    function  ParseSql(const Sql: AnsiString): ASqlStatement;
    function  ParseSqlProcedureDefinition(const Sql: AnsiString): TSqlProcedureDefinition;

    property  ParseTimeMicroSeconds: Int64 read FParseTime;
  end;

  ESqlParser = class(ESqlError)
  protected
    FParser : TSqlParser;
    FLineNr : Integer;
  public
    constructor Create(const Msg: string; const Parser: TSqlParser);
    constructor CreateFmt(const Msg: string; const Args: array of const; const Parser: TSqlParser);
    property LineNr: Integer read FLineNr;
  end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF SQL_SELFTEST}
procedure SelfTest;
{$ENDIF}



implementation

uses
  { SQL } 
  cSQLDatabase;



{                                                                              }
{ ESqlParser                                                                   }
{                                                                              }
constructor ESqlParser.Create(const Msg: string; const Parser: TSqlParser);
begin
  FParser := Parser;
  FLineNr := Parser.FLineNr;
  inherited Create(Msg);
end;

constructor ESqlParser.CreateFmt(const Msg: string; const Args: array of const; const Parser: TSqlParser);
begin
  FParser := Parser;
  FLineNr := Parser.FLineNr;
  inherited CreateFmt(Msg, Args);
end;



{                                                                              }
{ TSqlParser                                                                   }
{                                                                              }
constructor TSqlParser.Create;
begin
  inherited Create;
  FLexer := TSqlLexer.Create;
  FOptions := [spoExtendedSyntax];
  FCompatibility := spcSql92;
end;

destructor TSqlParser.Destroy;
begin
  FreeAndNil(FLexer);
  inherited Destroy;
end;

procedure TSqlParser.ParseError(const Msg: String; const Args: array of const);
begin
  raise ESqlParser.CreateFmt('Line %d: %s', [FLineNr, Format(Msg, Args)], self);
end;

procedure TSqlParser.ParseError(const Msg: String);
begin
  ParseError(Msg, []);
end;

procedure TSqlParser.UnexpectedToken;
begin
  ParseError('Unexpected token: %s', [FLexer.TokenID]);
end;

function TSqlParser.GetNextToken: Integer;
begin
  repeat
    Result := FLexer.GetNextToken;
    if Result = ttNewLine then
      Inc(FLineNr);
  until not (Result in [ttWhiteSpace, ttNewLine, ttLineComment, ttBlockComment]);
  FTokenType := Result;
end;

function TSqlParser.SkipToken(const TokenType: Integer): Boolean;
begin
  Result := (FTokenType = TokenType);
  if Result then
    GetNextToken;
end;

function TSqlParser.SkipAnyToken(const TokenSet: ByteSet): Integer;
begin
  if FTokenType in TokenSet then
    begin
      Result := FTokenType;
      GetNextToken;
    end
  else
    Result := ttNone;
end;

procedure TSqlParser.CheckToken(const TokenType: Integer; const Error: String; const Args: array of const);
begin
  if FTokenType <> TokenType then
    ParseError(Error, Args);
end;

procedure TSqlParser.CheckToken(const TokenType: Integer; const Error: String);
begin
  CheckToken(TokenType, Error, []);
end;

procedure TSqlParser.ExpectToken(const TokenType: Integer; const Error: String; const Args: array of const);
begin
  CheckToken(TokenType, Error, Args);
  GetNextToken;
end;

procedure TSqlParser.ExpectToken(const TokenType: Integer; const Error: String);
begin
  ExpectToken(TokenType, Error, []);
end;

procedure TSqlParser.ExpectKeyword(const TokenType: Integer; const Keyword: AnsiString);
begin
  ExpectToken(TokenType, '%s expected', [Keyword]);
end;

procedure TSqlParser.ExpectLeftParen;
begin
  ExpectToken(ttLeftParen, '( expected');
end;

procedure TSqlParser.ExpectRightParen;
begin
  ExpectToken(ttRightParen, ') expected');
end;

procedure TSqlParser.ExpectEqualSign;
begin
  ExpectToken(ttEqual, '= expected');
end;

procedure TSqlParser.ExpectComma;
begin
  ExpectToken(ttComma, ', expected');
end;

{ SQL92/SQL99:                                                                 }
{ <unsigned integer> ::= <digit>...                                            }
function TSqlParser.ExpectUnsignedInt64: Int64;
begin
  CheckToken(ttUnsignedInteger, 'Integer expected');
  try
    Result := StrToInt64(FLexer.TokenStr);
  except
    raise ESqlParser.Create('Integer out of range', self);
  end;
  GetNextToken;
end;

function TSqlParser.ExpectUnsignedInteger: Integer;
var I : Int64;
begin
  I := ExpectUnsignedInt64;
  if not InLongIntRange(I) then
    ParseError('Integer out of range');
  Result := Integer(I);
end;

{ SQL92:                                                                       }
{ <identifier> ::=                                                             }
{     [ <introducer><character set specification> ] <actual identifier>        }
{ <actual identifier> ::= <regular identifier> | <delimited identifier>        }
{ <regular identifier> ::= <identifier body>                                   }
{ <identifier body> ::=                                                        }
{     <identifier start> [ ( <underscore> | <identifier part> )... ]           }
{ <identifier part> ::= <identifier start> | <digit>                           }
{ <delimited identifier> ::=                                                   }
{     <double quote> <delimited identifier body> <double quote>                }
{ <delimited identifier body> ::= <delimited identifier part>...               }
{ <delimited identifier part> ::=                                              }
{       <nondoublequote character> | <doublequote symbol>                      }
{ <introducer> ::= <underscore>                                                }
{                                                                              }
{ SQL99:                                                                       }
{ <regular identifier> ::= <identifier body>                                   }
{ <identifier body> ::= <identifier start> [ <identifier part>... ]            }
{ <identifier start> ::=                                                       }
{     <initial alphabetic character> | <ideographic character>                 }
{ <identifier part> ::=                                                        }
{       <alphabetic character>                                                 }
{     | <ideographic character>                                                }
{     | <decimal digit character>                                              }
{     | <identifier combining character>                                       }
{     | <underscore>                                                           }
{     | <alternate underscore>                                                 }
{     | <extender character>                                                   }
{     | <identifier ignorable character>                                       }
{     | <connector character>                                                  }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <identifier> ::= <actual identifier>                                         }
{ <actual identifier> ::= <regular identifier> | <delimited identifier>        }
{ <identifier part> ::= <identifier start> | <identifier extend>               }
function TSqlParser.TokenIsIdentifier(const AllowKeyword: Boolean): Boolean;
begin
  Result :=
     (FTokenType in [ttIdentifier, ttQuotedIdentifier]) or
     (AllowKeyword and FLexer.TokenIsKeyword);
end;

function TSqlParser.ParseIdentifier(const AllowKeyword: Boolean): AnsiString;
begin
  if TokenIsIdentifier(AllowKeyword) then
    begin
      Result := FLexer.TokenStr;
      GetNextToken;
    end
  else
    Result := '';
end;

function TSqlParser.ExpectIdentifier(const AllowKeyword: Boolean): AnsiString;
begin
  if not TokenIsIdentifier(AllowKeyword) then
    ParseError('Identifier expected');
  Result := FLexer.TokenStr;
  GetNextToken;
end;

{ SQL92:                                                                       }
{ ::= <identifier> [ ( <comma> <identifier> )... ]                             }
function TSqlParser.ParseIdentifierList(const AllowKeyword: Boolean): AnsiStringArray;
begin
  Result := nil;
  if FTokenType = ttIdentifier then
    repeat
      Append(Result, ExpectIdentifier(AllowKeyword));
    until not SkipToken(ttComma);
end;

{ SQL99/SQL2003:                                                               }
{ <basic identifier chain> ::= <identifier chain>                              }
{ <identifier chain> ::= <identifier> [ ( <period> <identifier> )... ]         }
function TSqlParser.ParseBasicIdentifierChain: AnsiString;
begin
  Result := ParseIdentifier;
  while SkipToken(ttPeriod) do
    Result := Result + '.' + ExpectIdentifier;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <column name> ::= <identifier>                                               }
function TSqlParser.ParseColumnName: AnsiString;
begin
  Result := ParseIdentifier(True);
end;

function TSqlParser.ExpectColumnName: AnsiString;
begin
  Result := ExpectIdentifier(True);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <column name list> ::= <column name> [ ( <comma> <column name> )... ]        }
function TSqlParser.ParseColumnNameList: AnsiStringArray;
begin
  Result := ParseIdentifierList(True);
end;

{ SQL99/SQL2003:                                                               }
{ <method name> ::= <identifier>                                               }
function TSqlParser.ParseMethodName: AnsiString;
begin
  Result := ParseIdentifier;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <schema name> ::=                                                            }
{     [ <catalog name> <period> ] <unqualified schema name>                    }
{ <catalog name> ::= <identifier>                                              }
{ <unqualified schema name> ::= <identifier>                                   }
function TSqlParser.ParseSchemaName: AnsiString;
begin
  Result := ParseIdentifier;
  if Result = '' then
    exit;
  if SkipToken(ttPeriod) then
    Result := Result + '.' + ExpectIdentifier;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <qualified identifier> ::= <identifier>                                      }
function TSqlParser.ParseQualifiedIdentifier: AnsiString;
begin
  Result := ParseIdentifier;
end;

function TSqlParser.ExpectQualifiedIdentifier: AnsiString;
begin
  Result := ExpectIdentifier;
end;

{ SQL92:                                                                       }
{ <qualified name> ::=                                                         }
{     [ <schema name> <period> ] <qualified identifier>                        }
{                                                                              }
{ SQL99: Not used                                                              }
function TSqlParser.ParseQualifiedName: AnsiString;
begin
  Result := ParseSchemaName;
  if Result = '' then
    exit;
  if SkipToken(ttPeriod) then
    Result := Result + '.' + ExpectIdentifier;
end;

{ SQL92: Not used                                                              }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <schema qualified name> ::=                                                  }
{     [ <schema name> <period> ] <qualified identifier>                        }
function TSqlParser.ParseSchemaQualifiedName: AnsiString;
begin
  Result := ParseSchemaName;
  if Result = '' then
    exit;
  if SkipToken(ttPeriod) then
    Result := Result + '.' + ExpectQualifiedIdentifier;
end;

{ SQL99/SQL2003:                                                               }
{ <schema qualified type name> ::=                                             }
{     [ <schema name> <period> ] <qualified identifier>                        }
function TSqlParser.ParseSchemaQualifiedTypeName: AnsiString;
begin
  Result := ParseSchemaName;
  if Result = '' then
    exit;
  if SkipToken(ttPeriod) then
    Result := Result + '.' + ExpectQualifiedIdentifier;
end;

{ SQL99/SQL2003:                                                               }
{ <user-defined type name> ::= <schema qualified type name>                    }
function TSqlParser.ParseUserDefinedTypeName: AnsiString;
begin
  Result := ParseSchemaQualifiedTypeName;
end;

{ SQL92: Not used                                                              }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <schema qualified routine name> ::= <schema qualified name>                  }
function TSqlParser.ParseSchemaQualifiedRoutineName: AnsiString;
begin
  Result := ParseSchemaQualifiedName;
end;

{ SQL92: Not used                                                              }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <specific name> ::= <schema qualified name>                                  }
function TSqlParser.ParseSpecificName: AnsiString;
begin
  Result := ParseSchemaQualifiedName;
end;

{ SQL92:                                                                       }
{ <domain name> ::= <qualified name>                                           }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <domain name> ::= <schema qualified name>                                    }
function TSqlParser.ParseDomainName: AnsiString;
begin
  Result := ParseQualifiedName;
end;

{ SQL92:                                                                       }
{ <qualified local table name> ::= MODULE <period> <local table name>          }
{ <local table name> ::= <qualified identifier>                                }
{                                                                              }
{ SQL99: Not used                                                              }
function TSqlParser.ParseQualifiedLocalTableName: AnsiString;
begin
  if SkipToken(ttMODULE) then
    begin
      ExpectToken(ttPeriod, '. expected');
      Result := SQL_KEYWORD_MODULE + '.' + ExpectIdentifier;
    end
  else
    Result := '';
end;

{ SQL92:                                                                       }
{ <table name> ::=                                                             }
{       <qualified name>                                                       }
{     | <qualified local table name>                                           }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <table name> ::=                                                             }
{     <local or schema qualified name>                                         }
{ <local or schema qualified name> ::=                                         }
{     [ <local or schema qualifier> <period> ] <qualified identifier>          }
{ <local or schema qualifier> ::= <schema name> | MODULE                       }
function TSqlParser.ParseTableName: AnsiString;
begin
  case FTokenType of
    ttIdentifier : Result := ParseQualifiedName;
    ttMODULE     : Result := ParseQualifiedLocalTableName;
  else
    Result := '';
  end;
end;

{ SQL2003:                                                                     }
{ <query name> ::= <identifier>                                                }
function TSqlParser.ParseQueryName: AnsiString;
begin
  Result := ParseIdentifier;
end;

{ SQL2003:                                                                     }
{ <table or query name> ::= <table name> | <query name>                        }
function TSqlParser.ParseTableOrQueryName: AnsiString;
begin
  Result := ParseIdentifier;
end;

{ SQL99:                                                                       }
{ <target table> ::=                                                           }
{       <table name>                                                           }
{     | [ ONLY ] <left paren> <table name> <right paren>                       }
{                                                                              }
{ SQL2003:                                                                     }
{ <target table> ::=                                                           }
{       <table name>                                                           }
{     |	ONLY <left paren> <table name> <right paren>                           }
function TSqlParser.ParseTargetTable: AnsiString;
var Only : Boolean;
begin
  Only := SkipToken(ttONLY);
  if Only then
    ExpectLeftParen else
  if SkipToken(ttLeftParen) then
    Only := True;
  Result := ParseTableName;
  if Only then
    ExpectRightParen;
end;

{ SQL92:                                                                       }
{ <qualifier> ::= <table name> | <correlation name>                            }
{ <correlation name> ::= <identifier>                                          }
{                                                                              }
{ SQL99: Not used                                                              }
function TSqlParser.ParseQualifier: AnsiString;
begin
  Result := ParseTableName;
  if Result = '' then
    Result := ParseIdentifier;
end;

{ SQL92:                                                                       }
{ <parameter name> ::= <colon> <identifier>                                    }
{                                                                              }
{ SQL99: Not used                                                              }
function TSqlParser.ParseParameterName: AnsiString;
begin
  if SkipToken(ttColon) then
    Result := ':' + ExpectIdentifier
  else
    Result := '';
end;

{ SQL92: Not used                                                              }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <host parameter name> ::= <colon> <identifier>                               }
function TSqlParser.ParseHostParameterName: AnsiString;
begin
  if SkipToken(ttColon) then
    Result := ':' + ExpectIdentifier
  else
    Result := '';
end;

{ SQL99/SQL2003:                                                               }
{ <SQL parameter reference> ::= <basic identifier chain>                       }
function TSqlParser.ParseSqlParameterReference: AnsiString;
begin
  Result := ParseBasicIdentifierChain;
end;

{ SQL99:                                                                       }
{ <SQL variable reference> ::= <basic identifier chain>                        }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseSqlVariableReference: AnsiString;
begin
  Result := ParseBasicIdentifierChain;
end;

{ SQL92:                                                                       }
{ <constraint name> ::= <qualified name>                                       }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <constraint name> ::= <schema qualified name>                                }
function TSqlParser.ParseConstraintName: AnsiString;
begin
  if FCompatibility >= spcSql99 then
    Result := ParseSchemaQualifiedName
  else
    Result := ParseQualifiedName;
end;

{ SQL92:                                                                       }
{ <collation name> ::= <qualified name>                                        }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <collation name> ::= <schema qualified name>                                 }
function TSqlParser.ParseCollationName: AnsiString;
begin
  Result := ParseQualifiedName;
end;

{ SQL92:                                                                       }
{ <translation name> ::= <qualified name>                                      }
{                                                                              }
{ SQL99:                                                                       }
{ <translation name> ::= <schema qualified name>                               }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseTranslationName: AnsiString;
begin
  if FCompatibility >= spcSql99 then
    Result := ParseSchemaQualifiedName
  else
    Result := ParseQualifiedName;
end;

{ SQL99/SQL2003:                                                               }
{ <local qualified name> ::=                                                   }
{     [ <local qualifier> <period> ] <qualified identifier>                    }
{ <local qualifier> ::= MODULE                                                 }
function TSqlParser.ParseLocalQualifiedName: AnsiString;
begin
  if SkipToken(ttMODULE) then
    ExpectToken(ttPeriod, '. expected');
  Result := ParseQualifiedIdentifier;
end;

{ SQL92:                                                                       }
{ <cursor name> ::= <identifier>                                               }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <cursor name> ::= <local qualified name>                                     }
function TSqlParser.ParseCursorName: AnsiString;
begin
  if FCompatibility >= spcSql99 then
    Result := ParseLocalQualifiedName
  else
    Result := ParseIdentifier;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <exact numeric literal> ::=                                                  }
{       <unsigned integer> [ <period> [ <unsigned integer> ] ]                 }
{     | <period> <unsigned integer>                                            }
function TSqlParser.ParseExactNumericLiteral: ASqlValueExpression;
begin
  Result := nil;
  try
    case FTokenType of
      ttUnsignedInteger : Result := TSqlLiteralValue.CreateInteger(StrToInt64(FLexer.TokenStr));
      ttRealNumber      : Result := TSqlLiteralValue.CreateFloat(StrToFloat(FLexer.TokenStr));
      ttPeriod          :
        begin
          GetNextToken;
          CheckToken(ttUnsignedInteger, 'Invalid floating point value');
          Result := TSqlLiteralValue.CreateFloat(StrToFloat('0.' + FLexer.TokenStr));
        end;
    end;
    if Assigned(Result) then
      GetNextToken;
  except
    on EConvertError do ParseError('Invalid numeric value');
  else
    raise;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <unsigned numeric literal> ::=                                               }
{       <exact numeric literal>                                                }
{     | <approximate numeric literal>                                          }
{ <approximate numeric literal> ::= <mantissa> E <exponent>                    }
{ <mantissa> ::= <exact numeric literal>                                       }
{ <exponent> ::= <signed integer>                                              }
function TSqlParser.ParseUnsignedNumericLiteral: ASqlValueExpression;
begin
  case FTokenType of
    ttSciRealNumber    :
      try
        Result := TSqlLiteralValue.CreateEx(TSqlFloat.Create(
            StrToFloat(FLexer.TokenStr)));
        GetNextToken;
      except
        raise ESqlParser.Create('Invalid float value', self);
      end;
    ttUnsignedInteger,
    ttRealNumber,
    ttPeriod           : Result := ParseExactNumericLiteral;
  else
    Result := nil;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <character set name> ::= [ <schema name> <period> ]                          }
{     <SQL language identifier>                                                }
{ <SQL language identifier> ::=                                                }
{     <SQL language identifier start>                                          }
{        [ ( <underscore> | <SQL language identifier part> )... ]              }
{ <SQL language identifier start> ::= <simple Latin letter>                    }
{ <SQL language identifier part> ::= <simple Latin letter> | <digit>           }
function TSqlParser.ParseCharacterSetName: AnsiString;
begin
  Result := ParseSchemaName;
  if SkipToken(ttPeriod) then
    Result := Result + '.' + ExpectIdentifier
end;

{ SQL92:                                                                       }
{ <character set specification> ::=                                            }
{       <standard character repertoire name>                                   }
{     | <implementation-defined character repertoire name>                     }
{     | <user-defined character repertoire name>                               }
{     | <standard universal character form-of-use name>                        }
{     | <implementation-defined universal character form-of-use name>          }
{ <standard character repertoire name> ::= <character set name>                }
{ <implementation-defined character repertoire name> ::= <character set name>  }
{ <user-defined character repertoire name> ::= <character set name>            }
{ <standard universal character form-of-use name> ::= <character set name>     }
{ <implementation-defined universal character form-of-use name> ::=            }
{     <character set name>                                                     }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <character set specification> ::=                                            }
{       <standard character set name>                                          }
{     | <implementation-defined character set name>                            }
{     | <user-defined character set name>                                      }
{ <standard character set name> ::= <character set name>                       }
{ <character set name> ::=                                                     }
{     [ <schema name> <period> ] <SQL language identifier>                     }
{ <implementation-defined character set name> ::= <character set name>         }
{ <user-defined character set name> ::= <character set name>                   }
function TSqlParser.ParseCharacterSetSpecification: AnsiString;
begin
  Result := ParseCharacterSetName;
end;

{ SQL92:                                                                       }
{ <character string literal> ::=                                               }
{  [ <introducer><character set specification> ]                               }
{  <quote> [ <character representation>... ] <quote>                           }
{  [ ( <separator>... <quote> [ <character representation>... ] <quote> )... ] }
{ <introducer> ::= <underscore>                                                }
{ <quote> ::= '                                                                }
{ <character representation> ::= <nonquote character> | <quote symbol>         }
{ <quote symbol> ::= <quote><quote>                                            }
{ <separator> ::= ( <comment> | <space> | <newline> )...                       }
{                                                                              }
{ SQL99:                                                                       }
{ <separator> ::= ( <comment> | <white space> )...                             }
{ <comment> ::= <simple comment> | <bracketed comment>                         }
{ <simple comment> ::= <simple comment introducer> [ <comment character>... ] <newline> }
{ <simple comment introducer> ::= <minus sign><minus sign> [ <minus sign>... ] }
{ <comment character> ::= <nonquote character> | <quote> }
function TSqlParser.ParseCharacterStringLiteral: ASqlValueExpression;
var S, C : AnsiString;
begin
  if (FTokenType = ttIdentifier) and (FLexer.TokenStr <> '') and
     (FLexer.TokenStr[1] = '_') then
    begin
      C := ParseCharacterSetSpecification;
      if C <> '' then
        CheckToken(ttStringLiteral, 'String literal expected');
    end;
  if FTokenType = ttStringLiteral then
    begin
      S := FLexer.TokenStr;
      while GetNextToken = ttStringLiteral do
        S := S + FLexer.TokenStr;
      Result := TSqlLiteralValue.CreateString(S, C);
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <national character string literal> ::=                                      }
{   N <quote> [ <character representation>... ] <quote>                        }
{     [ { <separator>...                                                       }
{         ( <quote> [ <character representation>... ] <quote> )... ]           }
function TSqlParser.ParseNationalCharacterStringLiteral: ASqlValueExpression;
var S : WideString;
begin
  if FTokenType = ttNStringLiteral then
    begin
      S := FLexer.TokenStr;
      while GetNextToken = ttNStringLiteral do
        S := S + FLexer.TokenStr;
      Result := TSqlLiteralValue.CreateNString(S);
    end
  else
    Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <hex string literal> ::= X <quote> [ <hexit>... ] <quote>                    }
{       [ ( <separator>... <quote> [ <hexit>... ] <quote> )... ]               }
{ <hexit> ::= <digit> | A | B | C | D | E | F | a | b | c | d | e | f          }
function TSqlParser.ParseHexStringLiteral: ASqlValueExpression;
var S : AnsiString;
begin
  if FTokenType = ttHexStringLiteral then
    begin
      S := FLexer.TokenStr;
      while GetNextToken = ttHexStringLiteral do
        S := S + FLexer.TokenStr;
      Result := TSqlLiteralValue.CreateHexString(S);
    end
  else
    Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <bit string literal> ::=                                                     }
{     B <quote> [ <bit>... ] <quote>                                           }
{       [ ( <separator>... <quote> [ <bit>... ] <quote> )... ]                 }
{ <bit> ::= 0 | 1                                                              }
function TSqlParser.ParseBitStringLiteral: ASqlValueExpression;
var S : AnsiString;
begin
  if FTokenType = ttBitStringLiteral then
    begin
      S := FLexer.TokenStr;
      while GetNextToken = ttBitStringLiteral do
        S := S + FLexer.TokenStr;
      Result := TSqlLiteralValue.CreateBitString(S);
    end
  else
    Result := nil;
end;

{ SQL99:                                                                       }
{ <binary string literal> ::=                                                  }
{ 		X <quote> [ ( <hexit> <hexit> )... ] <quote>                             }
{ 		[ ( <separator> <quote> [ ( <hexit> <hexit> )... ] <quote> )... ]        }
{                                                                              }
{ SQL2003:                                                                     }
{ <binary string literal> ::=                                                  }
{     X <quote> [ ( <hexit><hexit> )... ] <quote>                              }
{     [ ( <separator> <quote> [ ( <hexit><hexit> )... ] <quote> )... ]         }
{     [ ESCAPE <escape character> ]                                            }
function TSqlParser.ParseBinaryStringLiteral: ASqlValueExpression;
begin
  Result := nil;
end;

{ SQL92:                                                                       }
{ <date literal> ::= DATE <date string>                                        }
{ <date string> ::= <quote> <date value> <quote>                               }
{ <date value> ::= <years value> <minus sign> <months value>                   }
{       <minus sign> <days value>                                              }
{ <years value> ::= <datetime value>                                           }
{ <months value> ::= <datetime value>                                          }
{ <days value> ::= <datetime value>                                            }
{ <datetime value> ::= <unsigned integer>                                      }

{ SQL92:                                                                       }
{ <time literal> ::= TIME <time string>                                        }
{ <time string> ::= <quote> <time value> [ <time zone interval> ] <quote>      }
{ <time value> ::= <hours value> <colon> <minutes value>                       }
{       <colon> <seconds value>                                                }
{ <hours value> ::= <datetime value>                                           }
{ <minutes value> ::= <datetime value>                                         }
{ <seconds value> ::=                                                          }
{       <seconds integer value> [ <period> [ <seconds fraction> ] ]            }
{ <seconds integer value> ::= <unsigned integer>                               }
{ <seconds fraction> ::= <unsigned integer>                                    }

{ SQL92:                                                                       }
{ <timestamp literal> ::= TIMESTAMP <timestamp string>                         }
{ <timestamp string> ::=                                                       }
{     <quote> <date value> <space> <time value>                                }
{         [ <time zone interval> ] <quote>                                     }

{ SQL92/SQL99/SQL2003:                                                         }
{ <datetime literal> ::= <date literal> | <time literal> | <timestamp literal> }
function TSqlParser.ParseDateTimeLiteral: ASqlValueExpression;
begin
  if FTokenType in [ttDATE, ttTIME, ttTIMESTAMP] then
    begin
      GetNextToken;
      CheckToken(ttStringLiteral, 'Date/Time string expected');
      Result := TSqlLiteralValue.CreateEx(TSqlDateTime.Create(
          StrToDateTime(FLexer.TokenStr)));
      GetNextToken;
    end
  else
    Result := nil;
end;

{ SQL92:                                                                       }
{ <interval string> ::=                                                        }
{     <quote> ( <year-month literal> | <day-time literal> ) <quote>            }
{ <year-month literal> ::=                                                     }
{       <years value>                                                          }
{     | [ <years value> <minus sign> ] <months value>                          }
{ <day-time literal> ::=                                                       }
{       <day-time interval>                                                    }
{     | <time interval>                                                        }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <interval string> ::= <quote> <unquoted interval string> <quote>             }
{ <unquoted interval string> ::=                                               }
{     [ <sign> ] ( <year-month literal> | <day-time literal> )                 }

{ SQL92/SQL99/SQL2003:                                                         }
{ <interval literal> ::=                                                       }
{     INTERVAL [ <sign> ] <interval string> <interval qualifier>               }
function TSqlParser.ParseIntervalLiteral: TSqlIntervalLiteralValue;
begin
  if SkipToken(ttINTERVAL) then
    begin
      Result := TSqlIntervalLiteralValue.Create;
      with Result do
        try
          Negate := (FTokenType = ttMinus);
          SkipAnyToken([ttPlus, ttMinus]);
          CheckToken(ttStringLiteral, 'Interval string expected');
          IntervalString := FLexer.TokenStr;
          GetNextToken;
          Qualifier := ParseIntervalQualifier;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <boolean literal> ::= TRUE | FALSE | UNKNOWN                                 }
function TSqlParser.ParseBooleanLiteral: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
  if SkipToken(ttTRUE) then
  else
  if SkipToken(ttFALSE) then
  else
  if SkipToken(ttUNKNOWN) then
  else
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <Unicode character string literal> ::=                                       }
{     [ <introducer><character set specification> ]                            }
{     U<ampersand><quote> [ <Unicode representation>... ] <quote>              }
{     [ ( <separator> <quote> [ <Unicode representation>... ] <quote> )... ]   }
{     [ ESCAPE <escape character> ]                                            }
{ <Unicode representation> ::=                                                 }
{       <character representation>                                             }
{     | <Unicode escape value>                                                 }

{ SQL92:                                                                       }
{ <general literal> ::=                                                        }
{       <character string literal>                                             }
{     | <national character string literal>                                    }
{     | <bit string literal>                                                   }
{     | <hex string literal>                                                   }
{     | <datetime literal>                                                     }
{     | <interval literal>                                                     }
{                                                                              }
{ SQL99:                                                                       }
{ <general literal> ::=                                                        }
{       <character string literal>                                             }
{     | <national character string literal>                                    }
{     | <bit string literal>                                                   }
{     | <hex string literal>                                                   }
{     | <binary string literal>                                                }
{     | <datetime literal>                                                     }
{     | <interval literal>                                                     }
{     | <boolean literal>                                                      }
{                                                                              }
{ SQL2003:                                                                     }
{ <general literal> ::=                                                        }
{       <character string literal>                                             }
{     | <national character string literal>                                    }
{     | <Unicode character string literal>                                     }
{     | <binary string literal>                                                }
{     | <datetime literal>                                                     }
{     | <interval literal>                                                     }
{     | <boolean literal>                                                      }
function TSqlParser.ParseGeneralLiteral: ASqlValueExpression;
begin
  case FTokenType of
    ttNStringLiteral   : Result := ParseNationalCharacterStringLiteral;
    ttBitStringLiteral : Result := ParseBitStringLiteral;
    ttHexStringLiteral : Result := ParseHexStringLiteral;
    ttINTERVAL         : Result := ParseIntervalLiteral;
    ttDATE,
    ttTIME,
    ttTIMESTAMP        : Result := ParseDateTimeLiteral;
  else
    Result := ParseCharacterStringLiteral;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <signed numeric literal> ::=                                                 }
{     [ <sign> ] <unsigned numeric literal>                                    }
{ <sign> ::= <plus sign> | <minus sign>                                        }
function TSqlParser.ParseSignedNumericLiteral: ASqlValueExpression;
var I : Integer;
begin
  case FTokenType of
    ttPlus  : I := 1;
    ttMinus : I := -1;
  else
    I := 0;
  end;
  if I <> 0 then
    GetNextToken;
  Result := ParseUnsignedNumericLiteral;
  if not Assigned(Result) and (I <> 0) then
    ParseError('Number expected');
  if Assigned(Result) and (I = -1) then
    Result := TSqlNegateExpression.CreateEx(Result);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <literal> ::=                                                                }
{       <signed numeric literal>                                               }
{     | <general literal>                                                      }
function TSqlParser.ParseLiteral: ASqlValueExpression;
begin
  Result := ParseSignedNumericLiteral;
  if not Assigned(Result) then
    Result := ParseGeneralLiteral;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <unsigned literal> ::= <unsigned numeric literal> | <general literal>        }
function TSqlParser.ParseUnsignedLiteral: ASqlValueExpression;
begin
  Result := ParseUnsignedNumericLiteral;
  if Assigned(Result) then
    exit;
  Result := ParseGeneralLiteral;
end;

{ SQL92:                                                                       }
{ <parameter name> ::= <colon> <identifier>                                    }
{                                                                              }
{ SQL99/SQL2003: Not used                                                      }
function TSqlParser.ParseParameterNameExpr: ASqlValueExpression;
var S : AnsiString;
begin
  S := ParseParameterName;
  if S <> '' then
    Result := TSqlIdentifier.CreateEx(S)
  else
    Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <host identifier> ::= !!HOST SPECIFIC                                        }
{                                                                              }
{ SQL2003:                                                                     }
{ <host identifier> ::=                                                        }
{       <Ada host identifier>                                                  }
{     |	<C host identifier>                                                    }
{     |	<COBOL host identifier>                                                }
{     |	<Fortran host identifier>                                              }
{     |	<MUMPS host identifier>                                                }
{     |	<Pascal host identifier>                                               }
{     |	<PL/I host identifier>                                                 }

{ SQL92/SQL99/SQL2003:                                                         }
{ <embedded variable name> ::= <colon> <host identifier>                       }
function TSqlParser.ParseEmbeddedVariableName: ASqlValueExpression;
begin
  if SkipToken(ttColon) then
    Result := TSqlIdentifier.CreateEx(ExpectIdentifier)
  else
    Result := nil;
end;

{ SQL92:                                                                       }
{ <variable specification> ::=                                                 }
{     <embedded variable name> [ <indicator variable> ]                        }
{ <indicator variable> ::= [ INDICATOR ] <embedded variable name>              }
{                                                                              }
{ SQL99/SQL2003: Not used                                                      }
function TSqlParser.ParseVariableSpecification: TSqlVariableSpecification;
var N : ASqlValueExpression;
begin
  N := ParseEmbeddedVariableName;
  if not Assigned(N) then
    begin
      Result := nil;
      exit;
    end;
  Result := TSqlVariableSpecification.Create;
  with Result do
    try
      Name := N;
      SkipToken(ttINDICATOR);
      Indicator := ParseEmbeddedVariableName;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <parameter specification> ::= <parameter name> [ <indicator parameter> ]     }
{ <parameter name> ::= <colon> <identifier>                                    }
{ <indicator parameter> ::= [ INDICATOR ] <parameter name>                     }
{                                                                              }
{ SQL99/SQL2003: Not used                                                      }
function TSqlParser.ParseParameterSpecification: TSqlParameterSpecification;
begin
  if FTokenType = ttColon then
    begin
      Result := TSqlParameterSpecification.Create;
      with Result do
        try
          Name := ParseParameterName;
          SkipToken(ttINDICATOR);
          Indicator := ParseParameterName;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL2003:                                                                     }
{ <path-resolved user-defined type name> ::= <user-defined type name>          }

{ SQL92:                                                                       }
{ <general value specification> ::=                                            }
{       <parameter specification>                                              }
{     | <dynamic parameter specification>                                      }
{     | <variable specification>                                               }
{     | USER                                                                   }
{     | CURRENT_USER                                                           }
{     | SESSION_USER                                                           }
{     | SYSTEM_USER                                                            }
{     | VALUE                                                                  }
{ <dynamic parameter specification> ::= <question mark>                        }
{                                                                              }
{ SQL99:                                                                       }
{ <general value specification> ::=                                            }
{	      <host parameter specification>                                         }
{     | <SQL parameter reference>                                              }
{     | <SQL variable reference>                                               }
{     | <dynamic parameter specification>                                      }
{     | <embedded variable specification>                                      }
{     | CURRENT_DEFAULT_TRANSFORM_GROUP                                        }
{     | CURRENT_PATH                                                           }
{     | CURRENT_ROLE                                                           }
{     | CURRENT_TRANSFORM_GROUP_FOR_TYPE <user-defined type>                   }
{     | CURRENT_USER                                                           }
{     | SESSION_USER                                                           }
{     | SYSTEM_USER                                                            }
{     | USER                                                                   }
{     | VALUE                                                                  }
{                                                                              }
{ SQL2003:                                                                     }
{ <general value specification> ::=                                            }
{       <host parameter specification>                                         }
{     | <SQL parameter reference>                                              }
{     | <dynamic parameter specification>                                      }
{     | <embedded variable specification>                                      }
{     | <current collation specification>                                      }
{     | CURRENT_DEFAULT_TRANSFORM_GROUP                                        }
{     | CURRENT_PATH                                                           }
{     | CURRENT_ROLE                                                           }
{     | CURRENT_TRANSFORM_GROUP_FOR_TYPE <path-resolved user-defined type name>}
{     | CURRENT_USER                                                           }
{     | SESSION_USER                                                           }
{     | SYSTEM_USER                                                            }
{     | USER                                                                   }
{     | VALUE                                                                  }
function TSqlParser.ParseGeneralValueSpecification: ASqlValueExpression;
begin
  case FTokenType of
    ttColon         : Result := ParseParameterSpecification;
    ttQuestionMark  :
      begin
        GetNextToken;
        Result := TSqlDynamicParameterSpecification.Create;
      end;
  else
    begin
      case FTokenType of
        ttUSER          : Result := TSqlSpecialValue.CreateEx(ssvUSER);
        ttCURRENT_USER  : Result := TSqlSpecialValue.CreateEx(ssvCURRENT_USER);
        ttSESSION_USER  : Result := TSqlSpecialValue.CreateEx(ssvSESSION_USER);
        ttSYSTEM_USER   : Result := TSqlSpecialValue.CreateEx(ssvSYSTEM_USER);
        ttVALUE         : Result := TSqlSpecialValue.CreateEx(ssvVALUE);
      else
        Result := nil;
      end;
      if Assigned(Result) then
        GetNextToken
      else
        Result := ParseVariableSpecification;
    end;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <unsigned value specification> ::=                                           }
{       <unsigned literal>                                                     }
{     | <general value specification>                                          }
function TSqlParser.ParseUnsignedValueSpecification: ASqlValueExpression;
begin
  Result := ParseUnsignedLiteral;
  if Assigned(Result) then
    exit;
  Result := ParseGeneralValueSpecification;
end;

{ SQL92:                                                                       }
{ <non-second datetime field> ::= YEAR | MONTH | DAY | HOUR | MINUTE           }
{                                                                              }
{ SQL99/SQL2003: Not used                                                      }
function TSqlParser.ParseNonSecondDateTimeField: TSqlDateTimeField;
begin
  case FTokenType of
    ttYEAR   : Result := sdfYear;
    ttMONTH  : Result := sdfMonth;
    ttDAY    : Result := sdfDay;
    ttHOUR   : Result := sdfHour;
    ttMINUTE : Result := sdfMinute;
  else
    Result := sdfUndefined;
  end;
  if Result <> sdfUndefined then
    GetNextToken;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <interval fractional seconds precision> ::= <unsigned integer>               }
function TSqlParser.ParseIntervalFractionalSecondsPrecision: Integer;
begin
  Result := ExpectUnsignedInteger;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <interval leading field precision> ::= <unsigned integer>                    }
function TSqlParser.ParseIntervalLeadingFieldPrecision: Integer;
begin
  Result := ExpectUnsignedInteger;
end;

{ SQL92:                                                                       }
{ <single datetime field> ::=                                                  }
{     <non-second datetime field>                                              }
{         [ <left paren> <interval leading field precision> <right paren> ]    }
{   | SECOND [ <left paren> <interval leading field precision>                 }
{         [ <comma> <interval fractional seconds precision> ] <right paren> ]  }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <single datetime field> ::=                                                  }
{ 		<non-second primary datetime field>                                      }
{         [ <left paren> <interval leading field precision> <right paren> ]    }
{ 	|	SECOND [ <left paren> <interval leading field precision>                 }
{         [ <comma> <interval fractional seconds precision> ] <right paren> ]  }
function TSqlParser.ParseSingleDateTimeField: TSqlSingleDateTimeField;
begin
  Result := TSqlSingleDateTimeField.Create;
  with Result do
    try
      Field := ParseDateTimeField;
      if Field = sdfUndefined then
        ParseError('DateTime field expected');
      if SkipToken(ttLeftParen) then
        begin
          Precision := ExpectUnsignedInteger;
          if (Field = sdfSecond) and SkipToken(ttComma) then
            FracPrecision := ExpectUnsignedInteger;
          ExpectRightParen;
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL99/SQL2003:                                                               }
{ <non-second primary datetime field> ::= YEAR | MONTH | DAY | HOUR | MINUTE   }
function TSqlParser.ParseNonSecondPrimaryDateTimeField: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL92:                                                                       }
{ <start field> ::=                                                            }
{     <non-second datetime field>                                              }
{         [ <left paren> <interval leading field precision> <right paren> ]    }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <start field> ::=                                                            }
{ 		<non-second primary datetime field>                                      }
{         [ <left paren> <interval leading field precision> <right paren> ]    }
function TSqlParser.ParseStartField: TSqlDateTimeField;
begin
  Result := ParseNonSecondDateTimeField;
  if SkipToken(ttLeftParen) then
    begin
      ParseIntervalLeadingFieldPrecision;
      ExpectRightParen;
    end;
end;

{ SQL92:                                                                       }
{ <end field> ::=                                                              }
{     <non-second datetime field>                                              }
{     | SECOND [ <left paren> <interval fractional seconds precision>          }
{                <right paren> ]                                               }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <end field> ::=                                                              }
{ 		<non-second primary datetime field>                                      }
{ 	  | SECOND [ <left paren> <interval fractional seconds precision>          }
{                <right paren> ]                                               }
function TSqlParser.ParseEndField: TSqlSingleDateTimeField;
begin
  Result := ParseSingleDateTimeField;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <interval qualifier> ::=                                                     }
{       <start field> TO <end field>                                           }
{     | <single datetime field>                                                }
function TSqlParser.ParseIntervalQualifier: TSqlIntervalQualifier;
begin
  Result := TSqlIntervalQualifier.Create;
  with Result do
    try
      StartField := ParseStartField;
      if SkipToken(ttTO) then
        EndField := ParseEndField;
    except
      Result.Free;
      raise;
    end;
end;

{ COMMON:                                                                      }
{ [ <left paren> <length> <right paren> ]                                      }
function TSqlParser.ParseTypeLength(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
begin
  if SkipToken(ttLeftParen) then
    begin
      TypeDefinition.Length := ExpectUnsignedInteger;
      ExpectRightParen;
      Result := True;
    end
  else
    Result := False;
end;

{ COMMON:                                                                      }
{ [ <left paren> <precision> [ <comma> <scale> ] <right paren> ]               }
function TSqlParser.ParseTypePrecisionAndScale(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
begin
  if SkipToken(ttLeftParen) then
    begin
      TypeDefinition.Precision := ExpectUnsignedInteger;
      if SkipToken(ttComma) then
        TypeDefinition.Scale := ExpectUnsignedInteger;
      ExpectRightParen;
      Result := True;
    end
  else
    Result := False;
end;

{ COMMON:                                                                      }
{ [ <left paren> <precision> <right paren> ]                                   }
function TSqlParser.ParseTypePrecision(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
begin
  if SkipToken(ttLeftParen) then
    begin
      TypeDefinition.Precision := ExpectUnsignedInteger;
      ExpectRightParen;
      Result := True;
    end
  else
    Result := False;
end;

{ SQL92:                                                                       }
{ <character string type> ::=                                                  }
{       CHARACTER [ <left paren> <length> <right paren> ]                      }
{     | CHAR [ <left paren> <length> <right paren> ]                           }
{     | CHARACTER VARYING <left paren> <length> <right paren>                  }
{     | CHAR VARYING <left paren> <length> <right paren>                       }
{     | VARCHAR <left paren> <length> <right paren>                            }
{ <national character string type> ::=                                         }
{       NATIONAL CHARACTER [ <left paren> <length> <right paren> ]             }
{     | NATIONAL CHAR [ <left paren> <length> <right paren> ]                  }
{     | NCHAR [ <left paren> <length> <right paren> ]                          }
{     | NATIONAL CHARACTER VARYING <left paren> <length> <right paren>         }
{     | NATIONAL CHAR VARYING <left paren> <length> <right paren>              }
{     | NCHAR VARYING <left paren> <length> <right paren>                      }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <character string type> ::=                                                  }
{ 		CHARACTER [ <left paren> <length> <right paren> ]                        }
{ 	|	CHAR [ <left paren> <length> <right paren> ]                             }
{ 	|	CHARACTER VARYING <left paren> <length> <right paren>                    }
{ 	|	CHAR VARYING <left paren> <length> <right paren>                         }
{ 	|	VARCHAR <left paren> <length> <right paren>                              }
{ 	|	CHARACTER LARGE OBJECT [ <left paren> <large object length> <right paren> ] }
{ 	|	CHAR LARGE OBJECT [ <left paren> <large object length> <right paren> ]   }
{ 	|	CLOB [ <left paren> <large object length> <right paren> ]                }
{ <national character string type> ::=                                         }
{ 		NATIONAL CHARACTER [ <left paren> <length> <right paren> ]               }
{ 	|	NATIONAL CHAR [ <left paren> <length> <right paren> ]                    }
{ 	|	NCHAR [ <left paren> <length> <right paren> ]                            }
{ 	|	NATIONAL CHARACTER VARYING <left paren> <length> <right paren>           }
{ 	|	NATIONAL CHAR VARYING <left paren> <length> <right paren>                }
{ 	|	NCHAR VARYING <left paren> <length> <right paren>                        }
{ 	|	NATIONAL CHARACTER LARGE OBJECT [ <left paren> <large object length> <right paren> ] }
{ 	|	NCHAR LARGE OBJECT [ <left paren> <large object length> <right paren> ]  }
{ 	|	NCLOB [ <left paren> <large object length> <right paren> ]               }
function TSqlParser.ParseCharacterStringType(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
var T : TSqlDataType;
begin
  if FTokenType in [ttNATIONAL, ttCHARACTER, ttCHAR, ttVARCHAR] then
    begin
      if SkipToken(ttNATIONAL) then
        begin
          if SkipAnyToken([ttCHARACTER, ttCHAR]) = ttNone then
            ParseError('CHAR expected');
          GetNextToken;
          if SkipToken(ttVARYING) then
            T := stNVarChar
          else
            T := stNChar;
        end
      else
        begin
          T := SqlTokenToDataType(FTokenType);
          if T = stUndefined then
            ParseError('Type expected');
          GetNextToken;
          if SkipToken(ttVARYING) then
            case T of
              stChar  : T := stVarChar;
              stNChar : T := stNVarChar;
            else
              ParseError('VARYING not expected');
            end;
        end;
      TypeDefinition.DataType := T;
      if SqlDataTypeHasLength(T) then
        ParseTypeLength(TypeDefinition);
      Result := True;
    end
  else
    Result := False;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <approximate numeric type> ::=                                               }
{       FLOAT [ <left paren> <precision> <right paren> ]                       }
{     | REAL                                                                   }
{     | DOUBLE PRECISION                                                       }
function TSqlParser.ParseApproximateNumericType(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
begin
  //// TODO
  Result := False;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <precision> ::= <unsigned integer>                                           }
function TSqlParser.ParsePrecision: Integer;
begin
  Result := ExpectUnsignedInteger;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <scale> ::= <unsigned integer>                                               }
function TSqlParser.ParseScale: Integer;
begin
  Result := ExpectUnsignedInteger;
end;

{ SQL92/SQL99:                                                                 }
{ <exact numeric type> ::=                                                     }
{       NUMERIC [ <left paren> <precision> [ <comma> <scale> ] <right paren> ] }
{     | DECIMAL [ <left paren> <precision> [ <comma> <scale> ] <right paren> ] }
{     | DEC [ <left paren> <precision> [ <comma> <scale> ] <right paren> ]     }
{     | INTEGER                                                                }
{     | INT                                                                    }
{     | SMALLINT                                                               }
{                                                                              }
{ SQL2003:                                                                     }
{ <exact numeric type> ::=                                                     }
{   		NUMERIC [ <left paren> <precision> [ <comma> <scale> ] <right paren> ] }
{   	|	DECIMAL [ <left paren> <precision> [ <comma> <scale> ] <right paren> ] }
{    	|	DEC [ <left paren> <precision> [ <comma> <scale> ] <right paren> ]     }
{    	|	SMALLINT                                                               }
{     |	INTEGER                                                                }
{ 	  |	INT                                                                    }
{ 	  |	BIGINT                                                                 }
function TSqlParser.ParseExactNumericType(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
begin
  //// TODO
  Result := False;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <numeric type> ::=                                                           }
{       <exact numeric type>                                                   }
{     | <approximate numeric type>                                             }
function TSqlParser.ParseNumericType(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
begin
  case FTokenType of
    ttDOUBLE :
      begin
        GetNextToken;
        ExpectKeyword(ttPRECISION, SQL_KEYWORD_PRECISION);
        TypeDefinition.DataType := stDoublePrecision;
        Result := True;
      end;
    ttINTEGER,
    ttINT,
    ttSMALLINT,
    ttBIGINT,
    ttREAL :
      begin
        TypeDefinition.DataType := SqlTokenToDataType(FTokenType);
        GetNextToken;
        Result := True;
      end;
    ttNUMERIC,
    ttDECIMAL,
    ttDEC :
      begin
        TypeDefinition.DataType := SqlTokenToDataType(FTokenType);
        GetNextToken;
        ParseTypePrecisionAndScale(TypeDefinition);
        Result := True;
      end;
    ttFLOAT :
      begin
        TypeDefinition.DataType := stFloat;
        GetNextToken;
        ParseTypeLength(TypeDefinition);
        Result := True;
      end;
  else
    Result := False;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <time precision> ::= <time fractional seconds precision>                     }
{ <time fractional seconds precision> ::= <unsigned integer>                   }
{ <timestamp precision> ::= <time fractional seconds precision>                }

{ SQL92:                                                                       }
{ <datetime type> ::=                                                          }
{       DATE                                                                   }
{     | TIME [ <left paren> <time precision> <right paren> ]                   }
{           [ WITH TIME ZONE ]                                                 }
{     | TIMESTAMP [ <left paren> <timestamp precision> <right paren> ]         }
{           [ WITH TIME ZONE ]                                                 }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <datetime type> ::=                                                          }
{   		DATE                                                                   }
{   	|	TIME [ <left paren> <time precision> <right paren> ]                   }
{           [ <with or without time zone> ]                                    }
{   	|	TIMESTAMP [ <left paren> <timestamp precision> <right paren> ]         }
{           [ <with or without time zone> ]                                    }
{ <with or without time zone> ::= WITH TIME ZONE | WITHOUT TIME ZONE           }
function TSqlParser.ParseDateTimeType(const TypeDefinition: TSqlDataTypeDefinition): Boolean;
begin
  case FTokenType of
    ttDATE :
      begin
        TypeDefinition.DataType := stDate;
        GetNextToken;
        Result := True;
      end;
    ttTIME ,
    ttTIMESTAMP :
      begin
        case FTokenType of
          ttTIME      : TypeDefinition.DataType := stTime;
          ttTIMESTAMP : TypeDefinition.DataType := stTimeStamp;
        end;
        GetNextToken;
        ParseTypePrecision(TypeDefinition);
        if SkipToken(ttWITH) then
          begin
            ExpectKeyword(ttTIME, SQL_KEYWORD_TIME);
            ExpectKeyword(ttZONE, SQL_KEYWORD_ZONE);
            TypeDefinition.WithTimeZone := True;
          end;
        Result := True;
      end;
  else
    Result := False;
  end;
end;

{ SQL92/SQL99:                                                                 }
{ <bit string type> ::=                                                        }
{       BIT [ <left paren> <length> <right paren> ]                            }
{     | BIT VARYING <left paren> <length> <right paren>                        }

{ SQL99/SQL2003:                                                               }
{ <binary large object string type> ::=                                        }
{ 		BINARY LARGE OBJECT [ <left paren> <large object length> <right paren> ] }
{ 	|	BLOB [ <left paren> <large object length> <right paren> ]                }

{ SQL92/SQL99/SQL2003:                                                         }
{ <interval type> ::= INTERVAL <interval qualifier>                            }
procedure TSqlParser.ParseIntervalType(const TypeDefinition: TSqlDataTypeDefinition);
begin
  SkipToken(ttINTERVAL);
  ParseIntervalQualifier;
end;

{ SQL99/SQL2003:                                                               }
{ <boolean type> ::= BOOLEAN                                                   }
procedure TSqlParser.ParseBooleanType(const TypeDefinition: TSqlDataTypeDefinition);
begin
  //// SkipToken(ttBOOLEAN);
end;

{ SQL99:                                                                       }
{ <predefined type> ::=                                                        }
{ 		<character string type> [ CHARACTER SET <character set specification> ]  }
{ 	|	<national character string type>                                         }
{ 	|	<binary large object string type>                                        }
{ 	|	<bit string type>                                                        }
{ 	|	<numeric type>                                                           }
{ 	|	<boolean type>                                                           }
{ 	|	<datetime type>                                                          }
{ 	|	<interval type>                                                          }
{                                                                              }
{ SQL2003:                                                                     }
{ <predefined type> ::=                                                        }
{ 		<character string type> [ CHARACTER SET <character set specification> ]  }
{                             [ <collate clause> ]                             }
{ 	|	<national character string type> [ <collate clause> ]                    }
{ 	|	<binary large object string type>                                        }
{ 	|	<numeric type>                                                           }
{ 	|	<boolean type>                                                           }
{ 	|	<datetime type>                                                          }
{ 	|	<interval type>                                                          }
procedure TSqlParser.ParsePredefinedType(const TypeDefinition: TSqlDataTypeDefinition);
begin
end;

{ SQL92:                                                                       }
{ <data type> ::=                                                              }
{       <character string type>                                                }
{            [ CHARACTER SET <character set specification> ]                   }
{     | <national character string type>                                       }
{     | <bit string type>                                                      }
{     | <numeric type>                                                         }
{     | <datetime type>                                                        }
{     | <interval type>                                                        }
{                                                                              }
{ SQL99:                                                                       }
{ <data type> ::=                                                              }
{ 		  <predefined type>                                                      }
{     | <row type>                                                             }
{     | <user-defined type>                                                    }
{     | <reference type>                                                       }
{     | <collection type>                                                      }
{                                                                              }
{ SQL2003:                                                                     }
{ <data type> ::=                                                              }
{       <predefined type>                                                      }
{     | <row type>                                                             }
{     | <path-resolved user-defined type name>                                 }
{     | <reference type>                                                       }
{     | <collection type>                                                      }
procedure TSqlParser.ExpectDataType(const TypeDefinition: TSqlDataTypeDefinition);
var T : TSqlDataType;
begin
  if ParseCharacterStringType(TypeDefinition) then
    exit;
  if ParseNumericType(TypeDefinition) then
    exit;
  if ParseDateTimeType(TypeDefinition) then
    exit;
  T := SqlTokenToDataType(FTokenType);
  if T = stUndefined then
    ParseError('Type expected');
  GetNextToken;
  with TypeDefinition do
    begin
      DataType := T;
      if SqlDataTypeHasLength(T) then
        begin
          ExpectLeftParen;
          Length := ExpectUnsignedInteger;
          ExpectRightParen;
        end;
      if SqlDataTypeHasPrecisionAndScale(T) then
        begin
          ExpectLeftParen;
          Precision := ExpectUnsignedInteger;
          if SkipToken(ttComma) then
            Scale := ExpectUnsignedInteger;
          ExpectRightParen;
        end
      else if SqlDataTypeHasPrecision(T) then
        begin
          ExpectLeftParen;
          Precision := ExpectUnsignedInteger;
          ExpectRightParen;
        end;
      if T = stInterval then
        Qualifier := ParseIntervalQualifier;
    end;
end;

{ SQL92:                                                                       }
{ <current date value function> ::= CURRENT_DATE                               }
{ <current time value function> ::=                                            }
{       CURRENT_TIME [ <left paren> <time precision> <right paren> ]           }
{ <current timestamp value function> ::=                                       }
{      CURRENT_TIMESTAMP [ <left paren> <timestamp precision> <right paren> ]  }
{ <timestamp precision> ::= <time fractional seconds precision>                }
{ <time fractional seconds precision> ::= <unsigned integer>                   }

{ SQL92:                                                                       }
{ <datetime value function> ::=                                                }
{       <current date value function>                                          }
{     | <current time value function>                                          }
{     | <current timestamp value function>                                     }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <datetime value function> ::=                                                }
{       <current date value function>                                          }
{     | <current time value function>                                          }
{     | <current timestamp value function>                                     }
{     | <current local time value function>                                    }
{     | <current local timestamp value function>                               }
function TSqlParser.ParseDateTimeValueFunction: ASqlValueExpression;
begin
  case FTokenType of
    ttCURRENT_DATE      : Result := TSqlSpecialValue.CreateEx(ssvCURRENT_DATE);
    ttCURRENT_TIME      : Result := TSqlSpecialValue.CreateEx(ssvCURRENT_TIME);
    ttCURRENT_TIMESTAMP : Result := TSqlSpecialValue.CreateEx(ssvCURRENT_TIMESTAMP);
  else
    Result := nil;
  end;
  case FTokenType of
    ttCURRENT_DATE      : GetNextToken;
    ttCURRENT_TIME,
    ttCURRENT_TIMESTAMP :
      begin
        GetNextToken;
        if SkipToken(ttLeftParen) then
          begin
            TSqlSpecialValue(Result).Precision := ExpectUnsignedInteger;
            ExpectRightParen;
          end;
      end;
  end;
end;

{ SQL92:                                                                       }
{ <default clause> ::= DEFAULT <default option>                                }
{ <default option> ::=                                                         }
{       <literal>                                                              }
{     | <datetime value function>                                              }
{     | USER                                                                   }
{     | CURRENT_USER                                                           }
{     | SESSION_USER                                                           }
{     | SYSTEM_USER                                                            }
{     | NULL                                                                   }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <default clause> ::= DEFAULT <default option>                                }
{ <default option> ::=                                                         }
{       <literal>                                                              }
{     | <datetime value function>                                              }
{     | USER                                                                   }
{     | CURRENT_USER                                                           }
{     | CURRENT_ROLE                                                           }
{     | SESSION_USER                                                           }
{     | SYSTEM_USER                                                            }
{     | CURRENT_PATH                                                           }
{     | <implicitly typed value specification>                                 }
function TSqlParser.ParseDefaultClause: TSqlDefaultOption;
begin
  if SkipToken(ttDEFAULT) then
    begin
      Result := TSqlDefaultOption.Create;
      with Result do
        try
          case FTokenType of
            ttUSER         : Special := ssdUser;
            ttCURRENT_USER : Special := ssdCurrentUser;
            ttSESSION_USER : Special := ssdSessionUser;
            ttSYSTEM_USER  : Special := ssdSystemUser;
            ttNULL         : Special := ssdNull;
          else
            Special := ssdUndefined;
          end;
          if Special <> ssdUndefined then
            GetNextToken
          else
            begin
              DateTimeVal := ParseDateTimeValueFunction;
              if not Assigned(DateTimeVal) then
                begin
                  Literal := ParseLiteral;
                  if not Assigned(Literal) then
                    ParseError('Default option expected');
                end;
            end;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL92:                                                                       }
{ <column constraint> ::=                                                      }
{       NOT NULL                                                               }
{     | <unique specification>                                                 }
{     | <references specification>                                             }
{     | <check constraint definition>                                          }
{                                                                              }
{ SQL99:                                                                       }
{ <column constraint> ::=                                                      }
{       NOT NULL                                                               }
{     | <unique specification>                                                 }
{     | <references specification>                                             }
{     | <check constraint definition>                                          }
function TSqlParser.ParseColumnConstraint: TObject;
begin
  SkipToken(ttNOT);
  SkipToken(ttNULL);
  ParseUniqueSpecification;
  ParseReferencesSpecification;
  ParseCheckConstraintDefinition;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <constraint characteristics> ::=                                             }
{       <constraint check time> [ [ NOT ] DEFERRABLE ]                         }
{     |	[ NOT ] DEFERRABLE [ <constraint check time> ]                         }
function TSqlParser.ParseConstraintCharacteristics: TObject;
begin
  ParseConstraintCheckTime;
  SkipToken(ttNOT);
  SkipToken(ttDEFERRABLE);
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <column constraint definition> ::= [ <constraint name definition> ]          }
{     <column constraint> [ <constraint attributes> ]                          }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <column constraint definition> ::=                                           }
{	    [ <constraint name definition> ] <column constraint>                     }
{     [ <constraint characteristics> ]                                         }
function TSqlParser.ParseColumnConstraintDefinition: TSqlColumnConstraintDefinition;
begin
  if FTokenType in [ttCONSTRAINT, ttNOT, ttUNIQUE, ttPRIMARY, ttREFERENCES,
      ttCHECK] then
    begin
      Result := TSqlColumnConstraintDefinition.Create;
      with Result do
        try
          //// Name := ParseConstraintNameDefinition;
          case FTokenType of
            ttUNIQUE,
            ttPRIMARY    : UniqueSpec := ParseUniqueSpecification;
            ttREFERENCES : ReferencesSpec := ParseReferencesSpecification;
            ttCHECK      : CheckConstraint := ParseCheckConstraintDefinition;
            ttNOT        :
              begin
                GetNextToken;
                ExpectKeyword(ttNULL, SQL_KEYWORD_NULL);
                NotNull := True;
              end;
          end;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <collate clause> ::= COLLATE <collation name>                                }
function TSqlParser.ParseCollateClause: AnsiString;
begin
  if SkipToken(ttCOLLATE) then
    Result := ParseCollationName
  else
    Result := '';
end;

{ SQL2003:                                                                     }
{ <sequence generator start with option> ::=                                   }
{     START WITH <sequence generator start value>                              }
{ <sequence generator start value> ::= <signed numeric literal>                }
function TSqlParser.ParseSequenceGeneratorStartWithOption: Integer;
begin
  //// TODO
  Result := -1;
  if SkipToken(ttSTART) then
    begin
      ExpectKeyword(ttWITH, SQL_KEYWORD_WITH);
      ParseSignedNumericLiteral;
    end
  else
    Result := MinLongInt;
end;

{ SQL2003:                                                                     }
{ <sequence generator increment by option> :: =                                }
{     INCREMENT BY <sequence generator increment>                              }
{ <sequence generator increment> ::= <signed numeric literal>                  }
function TSqlParser.ParseSequenceGeneratorIncrementByOption: Integer;
begin
  //// TODO
  Result := -1;
  if SkipToken(ttINCREMENT) then
    begin
      ExpectKeyword(ttBY, SQL_KEYWORD_BY);
      ParseSignedNumericLiteral;
    end
  else
    Result := MinLongInt;
end;

{ SQL2003:                                                                     }
{ <sequence generator maxvalue option> ::=                                     }
{       MAXVALUE <sequence generator max value>                                }
{     | NO MAXVALUE                                                            }
{ <sequence generator minvalue option> ::=                                     }
{       MINVALUE <sequence generator min value>                                }
{     | NO MINVALUE                                                            }
{ <sequence generator max value> ::= <signed numeric literal>                  }
{ <sequence generator min value> ::= <signed numeric literal>                  }
{ <sequence generator cycle option> ::= CYCLE | NO CYCLE                       }
function TSqlParser.ParseSequenceGeneratorMinMaxCycleOption: Integer;
begin
  //// TODO
  Result := -1;
  if SkipToken(ttMAXVALUE) then
    ParseSignedNumericLiteral else
  if SkipToken(ttMINVALUE) then
    ParseSignedNumericLiteral else
  if SkipToken(ttCYCLE) then
  else
  if SkipToken(ttNO) then
    begin
      if SkipToken(ttMAXVALUE) then
      else
      if SkipToken(ttMINVALUE) then
      else
      if SkipToken(ttCYCLE) then
      else
        ParseError('MINVALUE, MAXVALUE or CYCLE expected');
    end
  else
    Result := MinLongInt;
end;

{ SQL2003:                                                                     }
{ <basic sequence generator option> ::=                                        }
{       <sequence generator increment by option>                               }
{     |	<sequence generator maxvalue option>                                   }
{     |	<sequence generator minvalue option>                                   }
{     |	<sequence generator cycle option>                                      }
function TSqlParser.ParseBasicSequenceGeneratorOption: TObject;
begin
  ParseSequenceGeneratorIncrementByOption;
  ParseSequenceGeneratorMinMaxCycleOption;
  ParseSequenceGeneratorMinMaxCycleOption;
  ParseSequenceGeneratorMinMaxCycleOption;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <common sequence generator options> ::=                                      }
{     <common sequence generator option> ...                                   }
{ <common sequence generator option> ::=                                       }
{       <sequence generator start with option>                                 }
{     | <basic sequence generator option>                                      }
function TSqlParser.ParseCommonSequenceGeneratorOptions: TObject;
begin
  ParseSequenceGeneratorStartWithOption;
  ParseBasicSequenceGeneratorOption;
  //// TODO
  Result := nil;
end;

{ EXT:                                                                         }
{ <generated clause> ::= <generation clause> | <identity column specification> }
{                                                                              }
{ SQL2003:                                                                     }
{ <generation clause> ::= <generation rule> AS <generation expression>         }
{ <generation rule> ::= GENERATED ALWAYS                                       }
{ <generation expression> ::= <left paren> <value expression> <right paren>    }
{                                                                              }
{ <identity column specification> ::=                                          }
{     GENERATED ( ALWAYS | BY DEFAULT ) AS IDENTITY                            }
{     [ <left paren> <common sequence generator options> <right paren> ]       }
function TSqlParser.ParseGeneratedClause: TObject;
var Always, {ByDefault,} Identity : Boolean;
begin
  //// TODO
  Result := nil;
  if SkipToken(ttGENERATED) then
    begin
      Always := SkipToken(ttALWAYS);
      // ByDefault := False;
      if not Always then
        if SkipToken(ttBY) then
          begin
            ExpectKeyword(ttDEFAULT, SQL_KEYWORD_DEFAULT);
            // ByDefault := True;
          end;
      ExpectKeyword(ttAS, SQL_KEYWORD_AS);
      Identity := SkipToken(ttIDENTITY);
      if Identity then
        begin
          ExpectLeftParen;
          ParseCommonSequenceGeneratorOptions;
          ExpectRightParen;
        end
      else
        begin
          ExpectLeftParen;
          ParseValueExpression(nil);
          ExpectRightParen;
        end;
    end
  else
    Result := nil;
end;

{ SQL99:                                                                       }
{ <referential action> ::=                                                     }
{       CASCADE                                                                }
{     |	SET NULL                                                               }
{     |	SET DEFAULT                                                            }
{     |	RESTRICT                                                               }
{     |	NO ACTION                                                              }
function TSqlParser.ParseReferencialAction: Integer;
begin
  case FTokenType of
    ttCASCADE  : ;
    ttSET	     :
      begin
        GetNextToken;
        case FTokenType of
          ttNULL : ;
          ttDEFAULT : ;
        end;
      end;
    ttRESTRICT : ;
    ttNO       : ;
  end;
  //// TODO
  Result := -1;
end;

{ SQL99:                                                                       }
{ <reference scope check action> ::= <referential action>                      }
function TSqlParser.ParseReferenceScopeCheckAction: TObject;
begin
  ParseReferencialAction;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <reference scope check> ::=                                                  }
{     REFERENCES ARE [ NOT ] CHECKED                                           }
{     [ ON DELETE <reference scope check action> ]                             }
function TSqlParser.ParseReferenceScopeCheck: TObject;
begin
  SkipToken(ttREFERENCES);
  //// SkipToken(ttARE);
  SkipToken(ttNOT);
  //// SkipToken(ttCHECKED);
  SkipToken(ttON);
  SkipToken(ttDELETE);
  ParseReferenceScopeCheckAction;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <column definition> ::=                                                      }
{     <column name> ( <data type> | <domain name> )                            }
{     [ <default clause> ]                                                     }
{     [ <column constraint definition>... ]                                    }
{     [ <collate clause> ]                                                     }
{                                                                              }
{ SQL99:                                                                       }
{ <column definition> ::=                                                      }
{		  <column name> ( <data type> | <domain name> )                            }
{     [ <reference scope check> ]                                              }
{     [ <default clause> ]                                                     }
{     [ <column constraint definition>... ]                                    }
{     [ <collate clause> ]                                                     }
{                                                                              }
{ SQL2003:                                                                     }
{ <column definition> ::=                                                      }
{     <column name> [ <data type> | <domain name> ]                            }
{     [ <reference scope check> ]                                              }
{     [   <default clause>                                                     }
{       | <identity column specification>                                      }
{       | <generation clause> ]                                                }
{     [ <column constraint definition>... ]                                    }
{     [ <collate clause> ]                                                     }
function TSqlParser.ParseColumnDefinition: TSqlColumnDefinitionEx;
begin
  Result := TSqlColumnDefinitionEx.Create;
  with Result do
    try
      Name := ExpectColumnName;
      ExpectDataType(TypeDefinition);
      DefaultClause := ParseDefaultClause;
      ParseGeneratedClause; // TODO
      ColumnConstraint := ParseColumnConstraintDefinition;
      Collate := ParseCollateClause;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <column reference> ::= [ <qualifier> <period> ] <column name>                }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <column reference> ::=                                                       }
{       <basic identifier chain>                                               }
{	    |	MODULE <period> <qualified identifier> <period> <column name>          }
function TSqlParser.ParseColumnReference: ASqlValueExpression;
var S : AnsiString;
begin
  if FTokenType = ttIdentifier then
    begin
      S := ParseQualifier;
      if SkipToken(ttPeriod) then
        S := S + '.' + ExpectColumnName;
      Result := TSqlColumnReference.CreateEx(S);
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <default specification> ::= DEFAULT                                          }

{ SQL92/SQL99/SQL2003:                                                         }
{ <null specification> ::= NULL                                                }
function TSqlParser.ParseNullSpecification: Boolean;
begin
  Result := SkipToken(ttNULL);
end;

{ SQL2003:                                                                     }
{ <empty specification> ::=                                                    }
{       ARRAY <left bracket or trigraph> <right bracket or trigraph>           }
{     | MULTISET <left bracket or trigraph> <right bracket or trigraph>        }
function TSqlParser.ParseEmptySpecification: TObject;
begin
  SkipToken(ttARRAY);
  SkipToken(ttMULTISET);
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <implicitly typed value specification> ::=                                   }
{       <null specification>                                                   }
{     | <empty specification>                                                  }
function TSqlParser.ParseImplicitlyTypedValueSpecification: TObject;
begin
  ParseNullSpecification;
  ParseEmptySpecification;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <cast operand> ::=                                                           }
{       <value expression>                                                     }
{     | NULL                                                                   }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <cast operand> ::=                                                           }
{       <value expression>                                                     }
{     | <implicitly typed value specification>                                 }
function TSqlParser.ParseCastOperand: TObject;
begin
  ParseImplicitlyTypedValueSpecification;
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <cast target> ::=                                                            }
{       <domain name>                                                          }
{     | <data type>                                                            }
function TSqlParser.ParseCastTarget: TObject;
begin
  ParseDomainName;
  //// ExpectDataType;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <cast specification> ::=                                                     }
{     CAST <left paren> <cast operand> AS                                      }
{         <cast target> <right paren>                                          }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <cast specification> ::=                                                     }
{     CAST <left paren> <cast operand> AS                                      }
{         <cast target> <right paren>                                          }
function TSqlParser.ParseCastSpecification: TSqlCastExpression;
begin
  Assert(FTokenType = ttCAST);
  GetNextToken;
  ExpectLeftParen;
  Result := TSqlCastExpression.Create;
  with Result do
    try
      if SkipToken(ttNULL) then
        Operand := TSqlNullValue.Create
      else
        Operand := ExpectValueExpression;
      ExpectKeyword(ttAS, SQL_KEYWORD_AS);
      ExpectDataType(TypeDefinition);
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <set quantifier> ::= DISTINCT | ALL                                          }
function TSqlParser.ParseSetQuantifier: TSqlSetQuantifier;
begin
  Result := SqlTokenToSetQuantifier(FTokenType);
  if Result <> ssqNone then
    GetNextToken;
end;

{ SQL99:                                                                       }
{ <computational operation> ::=                                                }
{       AVG | MAX | MIN | SUM | EVERY | ANY | SOME | COUNT                     }
{                                                                              }
{ SQL2003:                                                                     }
{ <computational operation> ::=                                                }
{       AVG | MAX | MIN | SUM |	EVERY | ANY | SOME | COUNT                     }
{     | STDDEV_POP | STDDEV_SAMP | VAR_SAMP | VAR_POP                          }
{     | COLLECT | FUSION | INTERSECTION                                        }
function TSqlParser.ParseComputationalOperation: TSqlComputationalOperation;
begin
  Result := scmUndefined;
  if FCompatibility >= spcSql99 then
    case FTokenType of
      ttAVG   : Result := scmAVG;
      ttMAX   : Result := scmMAX;
      ttMIN   : Result := scmMIN;
      ttSUM   : Result := scmSUM;
      ttEVERY : Result := scmEVERY;
      ttANY   : Result := scmANY;
      ttSOME  : Result := scmSOME;
      ttCOUNT : Result := scmCOUNT;
    else
      Result := scmUndefined;
    end;
  if Result <> scmUndefined then
    exit;
  if FCompatibility >= spcSql2003 then
    case FTokenType of
      ttSTDDEV_POP   : Result := scmSTDDEV_POP;
      ttSTDDEV_SAMP  : Result := scmSTDDEV_SAMP;
      ttVAR_SAMP     : Result := scmVAR_SAMP;
      ttVAR_POP      : Result := scmVAR_POP;
      ttCOLLECT      : Result := scmCOLLECT;
      ttFUSION       : Result := scmFUSION;
      ttINTERSECTION : Result := scmINTERSECTION;
    end;
end;

{ SQL92:                                                                       }
{ <set function type> ::=                                                      }
{     AVG | MAX | MIN | SUM | COUNT                                            }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <set function type> ::= <computational operation>                            }
function TSqlParser.ParseSetFunctionType: TSqlSetFunctionType;
begin
  if FCompatibility >= spcSql99 then
    Result := ParseComputationalOperation
  else
    case FTokenType of
      ttAVG   : Result := scmAVG;
      ttMAX   : Result := scmMAX;
      ttMIN   : Result := scmMIN;
      ttSUM   : Result := scmSUM;
      ttCOUNT : Result := scmCOUNT;
    else
      Result := scmUndefined;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <general set function> ::=                                                   }
{     <set function type>                                                      }
{         <left paren> [ <set quantifier> ] <value expression> <right paren>   }
function TSqlParser.ParseGeneralSetFunction: TSqlSetFunctionExpression;
begin
  ParseSetFunctionType;
  ExpectLeftParen;
  ParseSetQuantifier;
  ParseValueExpression;
  ExpectRightParen;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <grouping operation> ::=                                                     }
{     GROUPING <left paren> <column reference>                                 }
{     <right paren>                                                            }
{                                                                              }
{ SQL2003:                                                                     }
{ <grouping operation> ::=                                                     }
{     GROUPING <left paren> <column reference>                                 }
{     [ ( <comma> <column reference> )... ] <right paren>                      }
function TSqlParser.ParseGroupingOperation: AnsiStringArray;
begin
  if SkipToken(ttGROUPING) then
    begin
      ExpectLeftParen;
      ParseColumnReference;
      ExpectRightParen;
    end
  else
    Result := nil;
end;

{ SQL2003:                                                                     }
{ <binary set function type> ::=                                               }
{       COVAR_POP | COVAR_SAMP | CORR | REGR_SLOPE                             }
{     | REGR_INTERCEPT | REGR_COUNT | REGR_R2 | REGR_AVGX | REGR_AVGY          }
{     | REGR_SXX | REGR_SYY | REGR_SXY                                         }
function TSqlParser.ParseBinarySetFunctionType: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL2003:                                                                     }
{ <binary set function> ::=                                                    }
{     <binary set function type>                                               }
{     <left paren> <dependent variable expression> <comma>                     }
{     <independent variable expression> <right paren>                          }
{ <dependent variable expression> ::= <numeric value expression>               }
{ <independent variable expression> ::= <numeric value expression>             }
function TSqlParser.ParseBinarySetFunction: TSqlSetFunctionExpression;
begin
  ParseBinarySetFunctionType;
  ExpectLeftParen;
  ParseNumericValueExpression;
  ExpectComma;
  ParseNumericValueExpression;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <rank function type> ::= RANK | DENSE_RANK | PERCENT_RANK | CUME_DIST        }
function TSqlParser.ParseRankFunctionType: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL2003:                                                                     }
{ <within group specification> ::=                                             }
{     WITHIN GROUP <left paren>                                                }
{     ORDER BY <sort specification list> <right paren>                         }
function TSqlParser.ParseWithinGroupSpecification: TObject;
begin
  //// TODO
  Result := nil;
  if SkipToken(ttWITHIN) then
    begin
      ExpectKeyword(ttGROUP, SQL_KEYWORD_GROUP);
      ExpectLeftParen;
      ExpectKeyword(ttORDER, SQL_KEYWORD_ORDER);
      ExpectKeyword(ttBY, SQL_KEYWORD_BY);
      ParseSortSpecificationList;
      ExpectRightParen;
    end
  else
    Result := nil;
end;

{ SQL2003:                                                                     }
{ <hypothetical set function value expression list> ::=                        }
{     <value expression> [ ( <comma> <value expression> )... ]                 }
function TSqlParser.ParseHypotheticalSetFunctionValueExpressionList: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <hypothetical set function> ::=                                              }
{     <rank function type>                                                     }
{     <left paren> <hypothetical set function value expression list>           }
{     <right paren> <within group specification>                               }
function TSqlParser.ParseHypotheticalSetFunction: TSqlSetFunctionExpression;
begin
  ParseRankFunctionType;
  ExpectLeftParen;
  ParseHypotheticalSetFunctionValueExpressionList;
  ExpectRightParen;
  ParseWithinGroupSpecification;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <inverse distribution function type> ::= PERCENTILE_CONT | PERCENTILE_DISC   }
function TSqlParser.ParseInverseDistributionFunctionType: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL2003:                                                                     }
{ <inverse distribution function argument> ::= <numeric value expression>      }
function TSqlParser.ParseInverseDistributionFunctionArgument: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <inverse distribution function> ::=                                          }
{     <inverse distribution function type>                                     }
{     <left paren> <inverse distribution function argument> <right paren>      }
{     <within group specification>                                             }
function TSqlParser.ParseInverseDistributionFunction: ASqlValueExpression;
begin
  ParseInverseDistributionFunctionType;
  ParseInverseDistributionFunctionArgument;
  ParseWithinGroupSpecification;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <ordered set function> ::=                                                   }
{       <hypothetical set function>                                            }
{     | <inverse distribution function>                                        }
function TSqlParser.ParseOrderedSetFunction: TSqlSetFunctionExpression;
begin
  ParseHypotheticalSetFunction;
  ParseInverseDistributionFunction;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <aggregate function> ::=                                                     }
{       COUNT <left paren> <asterisk> <right paren> [ <filter clause> ]        }
{     | <general set function> [ <filter clause> ]                             }
{     | <binary set function> [ <filter clause> ]                              }
{     | <ordered set function> [ <filter clause> ]                             }
function TSqlParser.ParseAggregateFunction: TSqlSetFunctionExpression;
begin
  ParseGeneralSetFunction;
  ParseBinarySetFunction;
  ParseOrderedSetFunction;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <set function specification> ::=                                             }
{       COUNT <left paren> <asterisk> <right paren>                            }
{     | <general set function>                                                 }
{                                                                              }
{ SQL99:                                                                       }
{ <set function specification> ::=                                             }
{       COUNT <left paren> <asterisk> <right paren>                            }
{     | <general set function>                                                 }
{     | <grouping operation>                                                   }
{                                                                              }
{ SQL2003:                                                                     }
{ <set function specification> ::=                                             }
{       <aggregate function>                                                   }
{     | <grouping operation>                                                   }
function TSqlParser.ParseSetFunctionSpecification: TSqlSetFunctionExpression;
var T : TSqlSetFunctionType;
begin
  Result := nil;
  T := SqlTokenToSetFunction(FTokenType);
  if T = scmUndefined then
    exit;
  GetNextToken;
  Result := TSqlSetFunctionExpression.Create;
  with Result do
    try
      FunctionType := T;
      Quantifier := ssqNone;
      ExpectLeftParen;
      if (T = scmCOUNT) and SkipToken(ttAsterisk) then
        Wild := True
      else
        begin
          Quantifier := ParseSetQuantifier;
          ValueExpr := ExpectValueExpression;
        end;
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ ::= <parameter name>                                                         }
function TSqlParser.ParseParameterIdentifier: ASqlValueExpression;
var S : AnsiString;
begin
  S := ParseParameterName;
  if S <> '' then
    Result := TSqlIdentifier.CreateEx(S)
  else
    Result := nil;
end;

{ SQL92:                                                                       }
{ <simple value specification> ::=                                             }
{       <parameter name>                                                       }
{     | <embedded variable name>                                               }
{     | <literal>                                                              }
{                                                                              }
{ SQL99:                                                                       }
{ <simple value specification> ::=                                             }
{       <literal>                                                              }
{     | <host parameter name>                                                  }
{     | <SQL parameter reference>                                              }
{     | <SQL variable reference>                                               }
{     | <embedded variable name>                                               }
{                                                                              }
{ SQL2003:                                                                     }
{ <simple value specification> ::=                                             }
{       <literal>                                                              }
{     | <host parameter name>                                                  }
{     | <SQL parameter reference>                                              }
{     | <embedded variable name>                                               }
function TSqlParser.ParseSimpleValueSpecification: ASqlValueExpression;
begin
  Result := ParseParameterIdentifier;
  if Assigned(Result) then
    exit;
  Result := ParseEmbeddedVariableName;
  if Assigned(Result) then
    exit;
  Result := ParseLiteral;
end;

function TSqlParser.ExpectSimpleValueSpecification: ASqlValueExpression;
begin
  Result := ParseSimpleValueSpecification;
  if not Assigned(Result) then
    ParseError('Simple value specification expected');
end;

{ SQL92:                                                                       }
{ ::=   NULLIF <left paren> <value expression> <comma>                         }
{             <value expression> <right paren>                                 }
function TSqlParser.ParseNullIfExpression: TSqlNullIfExpression;
begin
  Assert(FTokenType = ttNULLIF);
  GetNextToken;
  Result := TSqlNullIfExpression.Create;
  with Result do
    try
      ExpectLeftParen;
      Value1 := ExpectValueExpression;
      ExpectComma;
      Value2 := ExpectValueExpression;
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ ::=   COALESCE <left paren> <value expression>                               }
{             ( <comma> <value expression> )... <right paren>                  }
function TSqlParser.ParseCoalesceExpression: TSqlCoalesceExpression;
var E : ASqlValueExpressionArray;
begin
  Assert(FTokenType = ttCOALESCE);
  GetNextToken;
  ExpectLeftParen;
  try
    Append(ObjectArray(E), ExpectValueExpression);
    while SkipToken(ttComma) do
      Append(ObjectArray(E), ExpectValueExpression);
    ExpectRightParen;
  except
    FreeObjectArray(E);
    raise;
  end;
  Result := TSqlCoalesceExpression.Create;
  Result.ExprList := E;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <case abbreviation> ::=                                                      }
{       NULLIF <left paren> <value expression> <comma>                         }
{             <value expression> <right paren>                                 }
{     | COALESCE <left paren> <value expression>                               }
{             ( <comma> <value expression> )... <right paren>                  }
function TSqlParser.ParseCaseAbbreviation: ASqlValueExpression;
begin
  case FTokenType of
    ttNULLIF   : Result := ParseNullIfExpression;
    ttCOALESCE : Result := ParseCoalesceExpression;
  else
    Result := nil;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <result> ::= <result expression> | NULL                                      }
{ <result expression> ::= <value expression>                                   }
function TSqlParser.ParseResult: ASqlValueExpression;
begin
  if SkipToken(ttNULL) then
    Result := TSqlNullValue.Create
  else
    Result := ExpectValueExpression;
end;

{ SQL92/SQL99:                                                                 }
{ <simple when clause> ::= WHEN <when operand> THEN <result>                   }
{ <when operand> ::= <value expression>                                        }
{                                                                              }
{ SQL2003:                                                                     }
{ <when operand> ::=                                                           }
{       <row value predicand>                                                  }
{     | <comparison predicate part 2>                                          }
{     | <between predicate part 2>                                             }
{     | <in predicate part 2>                                                  }
{     | <character like predicate part 2>                                      }
{     | <octet like predicate part 2>                                          }
{     | <similar predicate part 2>                                             }
{     | <null predicate part 2>                                                }
{     | <quantified comparison predicate part 2>                               }
{     | <match predicate part 2>                                               }
{     | <overlaps predicate part 2>                                            }
{     | <distinct predicate part 2>                                            }
{     | <member predicate part 2>                                              }
{     | <submultiset predicate part 2>                                         }
{     | <set predicate part 2>                                                 }
{     | <type predicate part 2>                                                }
function TSqlParser.ParseSimpleWhenClause: TSqlSimpleWhen;
begin
  ExpectKeyword(ttWHEN, SQL_KEYWORD_WHEN);
  Result := TSqlSimpleWhen.Create;
  with Result do
    try
      WhenOperand := ExpectValueExpression;
      ExpectKeyword(ttTHEN, SQL_KEYWORD_THEN);
      ResultExpr := ParseResult;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99:                                                                 }
{ <case operand> ::= <value expression>                                        }
{                                                                              }
{ SQL2003:                                                                     }
{ <case operand> ::= <row value predicand> | <overlaps predicate part>         }
function TSqlParser.ExpectCaseOperand: ASqlValueExpression;
begin
  if FCompatibility <= spcSql99 then
    Result := ExpectValueExpression
  else
  begin
    Result := ParseRowValuePredicand;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <simple case> ::=                                                            }
{     CASE <case operand>                                                      }
{       <simple when clause>...                                                }
{       [ <else clause> ]                                                      }
{     END                                                                      }
{ <else clause> ::= ELSE <result>                                              }
function TSqlParser.ParseSimpleCase: TSqlCaseExpression;
var S : TSqlSimpleWhenArray;
begin
  Result := TSqlCaseExpression.Create;
  with Result do
    try
      CaseOperand := ExpectCaseOperand;
      while FTokenType = ttWHEN do
        Append(ObjectArray(S), ParseSimpleWhenClause);
      SimpleWhen := S;
      if SkipToken(ttELSE) then
        ElseValue := ParseResult;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <searched when clause> ::= WHEN <search condition> THEN <result>             }
function TSqlParser.ParseSearchedWhenClause: TSqlSearchedWhen;
begin
  ExpectKeyword(ttWHEN, SQL_KEYWORD_WHEN);
  Result := TSqlSearchedWhen.Create;
  with Result do
    try
      Condition := ParseSearchCondition;
      ExpectKeyword(ttTHEN, SQL_KEYWORD_THEN);
      ResultExpr := ParseResult;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <searched case> ::=                                                          }
{     CASE                                                                     }
{       <searched when clause>...                                              }
{       [ <else clause> ]                                                      }
{     END                                                                      }
function TSqlParser.ParseSearchedCase: TSqlCaseExpression;
var S : TSqlSearchedWhenArray;
begin
  Assert(FTokenType = ttWHEN);
  Result := TSqlCaseExpression.Create;
  with Result do
    try
      while FTokenType = ttWHEN do
        Append(ObjectArray(S), ParseSearchedWhenClause);
      SearchedWhen := S;
      if SkipToken(ttELSE) then
        ElseValue := ParseResult;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <case specification> ::= <simple case> | <searched case>                     }
function TSqlParser.ParseCaseSpecification: ASqlValueExpression;
begin
  Assert(FTokenType = ttCASE);
  GetNextToken;
  if FTokenType = ttWHEN then
    Result := ParseSearchedCase
  else
    Result := ParseSimpleCase;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <case expression> ::= <case abbreviation> | <case specification>             }
function TSqlParser.ParseCaseExpression: ASqlValueExpression;
begin
  case FTokenType of
    ttNULLIF,
    ttCOALESCE : Result := ParseCaseAbbreviation;
    ttCASE     : Result := ParseCaseSpecification;
  else
    Result := nil;
  end;
end;

{ EXT:                                                                         }
{ <parameter reference> ::= @ <identifier>                                     }
function TSqlParser.ParseParameterReference: ASqlValueExpression;
begin
  Assert(FTokenType = ttLocalIdentifier);
  Result := TSqlParameterReference.CreateEx(FLexer.TokenStr);
  GetNextToken;
end;

{ MSSQL:                                                                       }
{ <isnull expression> ::=                                                      }
{ ISNULL ( check_expression , replacement_value )                              }
function TSqlParser.ParseIsNullExpression: TSqlIsNullExpression;
begin
  Assert(FTokenType = ttISNULL);
  Result := TSqlIsNullExpression.Create;
  with Result do
    try
      ExpectLeftParen;
      ValueExpr := ExpectValueExpression;
      ExpectComma;
      Replacement := ExpectValueExpression;
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL2003:                                                                     }
{ <array factor> ::= <value expression primary>                                }
function TSqlParser.ParseArrayFactor: ASqlValueExpression;
begin
  Result := ParseValueExpressionPrimary;
end;

{ SQL99:                                                                       }
{ <array concatenation> ::=                                                    }
{     <array value expression 1> <concatenation operator>                      }
{         <array value expression 2>                                           }
{ <array value expression 1> ::= <array value expression>                      }
{ <array value expression 2> ::= <array value expression>                      }
{ <concatenation operator> ::= ||                                              }
{                                                                              }
{ SQL2003:                                                                     }
{ <array concatenation> ::=                                                    }
{     <array value expression 1> <concatenation operator>                      }
{         <array factor>                                                       }
{ <array value expression 1> ::= <array value expression>                      }
{ <concatenation operator> ::= <vertical bar> <vertical bar>                   }
function TSqlParser.ParseArrayConcatenation: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <array element> ::= <value expression>                                       }
function TSqlParser.ParseArrayElement: ASqlValueExpression;
begin
  Result := ParseValueExpression;
end;

{ SQL99:                                                                       }
{ <array element list> ::= <array element> [ ( <comma> <array element> )... ]  }
function TSqlParser.ParseArrayElementList: ASqlValueExpressionArray;
begin
  ParseArrayElement;
  while SkipToken(ttComma) do
    ParseArrayElement;
end;

{ SQL99:                                                                       }
{ <array value list constructor> ::=                                           }
{     ARRAY <left bracket or trigraph> <array element list> <right bracket or trigraph> }
function TSqlParser.ParseArrayValueListConstructor: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
  if SkipToken(ttARRAY) then
    begin
      ExpectLeftParen;
      ParseArrayElementList;
      ExpectRightParen;
    end
  else
    Result := nil;
end;

{ SQL99:                                                                       }
{ <array value constructor> ::= <array value list constructor>                 }
function TSqlParser.ParseArrayValueConstructor: ASqlValueExpression;
begin
  Result := ParseArrayValueListConstructor;
end;

{ SQL99:                                                                       }
{ <array value expression> ::=                                                 }
{       <array value constructor>                                              }
{     | <array concatenation>                                                  }
{     | <value expression primary>                                             }
{                                                                              }
{ SQL2003:                                                                     }
{ <array value expression> ::=                                                 }
{       <array concatenation>                                                  }
{     | <array factor>                                                         }
function TSqlParser.ParseArrayValueExpression: ASqlValueExpression;
begin
  Assert(FTokenType = ttARRAY);
  GetNextToken;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <nonparenthesized value expression primary> ::=                              }
{       <unsigned value specification>                                         }
{     |	<column reference>                                                     }
{     |	<set function specification>                                           }
{     |	<scalar subquery>                                                      }
{     |	<case expression>                                                      }
{     |	<cast specification>                                                   }
{     |	<subtype treatment>                                                    }
{     |	<attribute or method reference>                                        }
{     |	<reference resolution>                                                 }
{     |	<collection value constructor>                                         }
{     |	<routine invocation>                                                   }
{     |	<field reference>                                                      }
{     |	<element reference>                                                    }
{     |	<method invocation>                                                    }
{     |	<static method invocation>                                             }
{     |	<new specification>                                                    }
{ <collection value constructor> ::= <array value expression>                  }
{                                                                              }
{ SQL2003:                                                                     }
{ <nonparenthesized value expression primary> ::=                              }
{       <unsigned value specification>                                         }
{     | <column reference>                                                     }
{     | <set function specification>                                           }
{     | <window function>                                                      }
{     | <scalar subquery>                                                      }
{     | <case expression>                                                      }
{     | <cast specification>                                                   }
{     | <field reference>                                                      }
{     | <subtype treatment>                                                    }
{     | <method invocation>                                                    }
{     | <static method invocation>                                             }
{     | <new specification>                                                    }
{     | <attribute or method reference>                                        }
{     | <reference resolution>                                                 }
{     | <collection value constructor>                                         }
{     | <array element reference>                                              }
{     | <multiset element reference>                                           }
{     | <routine invocation>                                                   }
{     | <next value expression>                                                }
{ <reference resolution> ::=                                                   }
{     DEREF <left paren> <reference value expression> <right paren>            }
{ <array element reference> ::=                                                }
{     <array value expression> <left bracket or trigraph>                      }
{         <numeric value expression> <right bracket or trigraph>               }
{ <multiset element reference> ::=                                             }
{     ELEMENT <left paren> <multset value expression> <right paren>            }
{ <next value expression> ::= NEXT VALUE FOR <sequence generator name>         }
function TSqlParser.ParseNonParenthesizedValueExpressionPrimary: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <parenthesized value expression> ::=                                         }
{     <left paren> <value expression> <right paren>                            }
function TSqlParser.ParseParenthesizedValueExpression: ASqlValueExpression;
begin
  if SkipToken(ttLeftParen) then
    begin
      Result := ParseValueExpression;
      ExpectRightParen;
    end
  else
    Result := nil;
end;

{ SQL92:                                                                       }
{ <value expression primary> ::=                                               }
{       <unsigned value specification>                                         }
{     | <column reference>                                                     }
{     | <set function specification>                                           }
{     | <scalar subquery>                                                      }// Not implemented: Resolve conflict with <left paren> <value expression> <right paren>
{     | <case expression>                                                      }
{     | <left paren> <value expression> <right paren>                          }
{     | <cast specification>                                                   }
{     | EXT:<parameter reference>                                              }
{     | EXT:<isnull expression>                                                }
{ <scalar subquery> ::= <subquery>                                             }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <value expression primary> ::=                                               }
{       <parenthesized value expression>                                       }
{     | <nonparenthesized value expression primary>                            }
function TSqlParser.ParseValueExpressionPrimary: ASqlValueExpression;
begin
  case FTokenType of
    ttIdentifier      : Result := ParseColumnReference;
    ttCOUNT,
    ttAVG,
    ttMAX,
    ttMIN,
    ttSUM             : Result := ParseSetFunctionSpecification;
    ttNULLIF,
    ttCOALESCE,
    ttCASE            : Result := ParseCaseExpression;
    ttCAST            : Result := ParseCastSpecification;
    ttLocalIdentifier : Result := ParseParameterReference;
    ttISNULL          : Result := ParseIsNullExpression;
    ttLeftParen       :
      begin
        GetNextToken;
        Result := ExpectValueExpression;
        try
          ExpectRightParen;
        except
          Result.Free;
          raise;
        end;
      end;
  else
    if FCompatibility >= spcSql99 then
      case FTokenType of
        ttARRAY : Result := ParseArrayValueExpression;
      else
        Result := ParseUnsignedValueSpecification;
      end
    else
      Result := ParseUnsignedValueSpecification;
  end;
end;

{ SQL92:                                                                       }
{ <position expression> ::=                                                    }
{     POSITION <left paren> <character value expression>                       }
{         IN <character value expression> <right paren>                        }
{                                                                              }
{ SQL99:                                                                       }
{ <string position expression> ::=                                             }
{     POSITION <left paren> <string value expression>                          }
{     IN <string value expression> <right paren>                               }
{                                                                              }
{ SQL2003:                                                                     }
{ <string position expression> ::=                                             }
{     POSITION <left paren> <string value expression>                          }
{     IN <string value expression>                                             }
{     [ USING <char length units> ] <right paren>                              }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <position expression> ::=                                                    }
{       <string position expression>                                           }
{     | <blob position expression>                                             }
{ <blob position expression> ::=                                               }
{     POSITION <left paren> <blob value expression>                            }
{     IN <blob value expression> <right paren>                                 }
function TSqlParser.ParsePositionExpression: TSqlCharacterPositionExpression;
begin
  Assert(FTokenType = ttPOSITION);
  Result := TSqlCharacterPositionExpression.Create;
  with Result do
    try
      ExpectLeftParen;
      SubValueExpr := ExpectCharacterValueExpression;
      if (spoExtendedSyntax in FOptions) and (FTokenType = ttComma) then
        GetNextToken                 // Extended syntax: Use comma instead of IN
      else
        ExpectKeyword(ttIN, SQL_KEYWORD_IN); // SQL92: IN required
      ValueExpr := ExpectCharacterValueExpression;
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99:                                                                 }
{ <length expression> ::=                                                      }
{       <char length expression>                                               }
{     | <octet length expression>                                              }
{     | <bit length expression>                                                }
{ <char length expression> ::=                                                 }
{     ( CHAR_LENGTH | CHARACTER_LENGTH )                                       }
{         <left paren> <string value expression> <right paren>                 }
{ <octet length expression> ::=                                                }
{     OCTET_LENGTH <left paren> <string value expression> <right paren>        }
{ <bit length expression> ::=                                                  }
{     BIT_LENGTH <left paren> <string value expression> <right paren>          }
{                                                                              }
{ SQL2003:                                                                     }
{ <length expression> ::=                                                      }
{       <char length expression>                                               }
{     | <octet length expression>                                              }
function TSqlParser.ParseLengthExpression: TSqlLengthExpression;
begin
  Assert((FTokenType = ttCHAR_LENGTH) or (FTokenType = ttCHARACTER_LENGTH) or
         (FTokenType = ttOCTET_LENGTH) or (FTokenType = ttBIT_LENGTH));
  Result := TSqlLengthExpression.Create;
  with Result do
    try
      case FTokenType of
        ttCHAR_LENGTH,
        ttCHARACTER_LENGTH : LengthType := sleChar;
        ttOCTET_LENGTH     : LengthType := sleOctet;
        ttBIT_LENGTH       : LengthType := sleBit;
      end;
      GetNextToken;
      ExpectLeftParen;
      StrValue := ParseStringValueExpression;
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <time zone field> ::= TIMEZONE_HOUR | TIMEZONE_MINUTE                        }
function TSqlParser.ParseTimeZoneField: TSqlTimeZoneField;
begin
  case FTokenType of
    ttTIMEZONE_HOUR   : Result := stzHour;
    ttTIMEZONE_MINUTE : Result := stzMinute;
  else
    Result := stzUndefined;
  end;
  if Result <> stzUndefined then
    GetNextToken;
end;

{ SQL92:                                                                       }
{ <datetime field> ::=                                                         }
{       <non-second datetime field>                                            }
{     | SECOND                                                                 }
{                                                                              }
{ SQL99/SQL2003: Not used                                                      }
function TSqlParser.ParseDateTimeField: TSqlDateTimeField;
begin
  if SkipToken(ttSECOND) then
    Result := sdfSecond
  else
    Result := ParseNonSecondDateTimeField;
end;

{ SQL99/SQL2003:                                                               }
{ <primary datetime field> ::=                                                 }
{       <non-second primary datetime field>                                    }
{     | SECOND                                                                 }
function TSqlParser.ParsePrimaryDateTimeField: ASqlValueExpression;
begin
  ParseNonSecondPrimaryDateTimeField;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <extract field> ::=                                                          }
{       <datetime field>                                                       }
{     | <time zone field>                                                      }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <extract field> ::=                                                          }
{       <primary datetime field>                                               }
{     | <time zone field>                                                      }
function TSqlParser.ParseExtractField: ASqlValueExpression;
begin
  ParseTimeZoneField;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <extract source> ::=                                                         }
{       <datetime value expression>                                            }
{     | <interval value expression>                                            }
function TSqlParser.ParseExtractSource: ASqlValueExpression;
begin
  Result := ParseDateTimeValueExpression;
  if Assigned(Result) then
    exit;
  Result := ParseIntervalValueExpression;
end;

{ SQL92:                                                                       }
{ <extract expression> ::=                                                     }
{     EXTRACT <left paren> <extract field>                                     }
{         FROM <extract source> <right paren>                                  }
function TSqlParser.ParseExtractExpression: TSqlExtractExpression;
begin
  Assert(FTokenType = ttEXTRACT);
  GetNextToken;
  Result := TSqlExtractExpression.Create;
  with Result do
    try
      ExpectLeftParen;
      case FTokenType of
        ttTIMEZONE_HOUR,
        ttTIMEZONE_MINUTE : ExtractZone := ParseTimeZoneField;
      else
        ExtractDateTime := ParseDateTimeField;
      end;
      ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);
      ValueExpr := ParseExtractSource;
      if not Assigned(ValueExpr) then
        ParseError('Extract source expected');
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL2003:                                                                     }
{ <multiset set function> ::=                                                  }
{     SET <left paren> <multiset value expression> <right paren>               }
function TSqlParser.ParseMultiSetFunction: ASqlValueExpression;
begin
  if SkipToken(ttSET) then
    begin
      ExpectLeftParen;
      Result := ParseMultiSetValueExpression;
      ExpectRightParen;
    end
  else
    Result := nil;
end;

{ SQL2003:                                                                     }
{ <multiset value function> ::= <multiset set function>                        }
function TSqlParser.ParseMultiSetValueFunction: ASqlValueExpression;
begin
  Result := ParseMultiSetFunction;
end;

{ SQL2003:                                                                     }
{ <multiset primary> ::=                                                       }
{       <multiset value function>                                              }
{     | <value expression primary>                                             }
function TSqlParser.ParseMultiSetPrimary: ASqlValueExpression;
begin
  Result := ParseMultiSetValueFunction;
  if Assigned(Result) then
    exit;
  Result := ParseValueExpressionPrimary;
end;

{ SQL2003:                                                                     }
{ <multiset term> ::=                                                          }
{       <multiset primary>                                                     }
{     | <multiset term> MULTISET INTERSECT [ ALL | DISTINCT ]                  }
{       <multiset primary>                                                     }
function TSqlParser.ParseMultiSetTerm(var GotMultiSetToken: Boolean): ASqlValueExpression;
begin
  Result := ParseMultiSetPrimary;
  while SkipToken(ttMULTISET) do
    begin
      if not SkipToken(ttINTERSECT) then
        begin
          GotMultiSetToken := True;
          exit;
        end;
      if SkipToken(ttALL) then
      else
      if SkipToken(ttDISTINCT) then
      ;
      ParseMultiSetPrimary;
    end;
end;

{ SQL2003:                                                                     }
{ <multiset value expression> ::=                                              }
{       <multiset term>                                                        }
{     | <multiset value expression> MULTISET UNION [ ALL | DISTINCT ]          }
{       <multiset term>                                                        }
{     | <multiset value expression> MULTISET EXCEPT [ ALL | DISTINCT ]         }
{       <multiset term>                                                        }
function TSqlParser.ParseMultiSetValueExpression: ASqlValueExpression;
var GotMultiSetToken : Boolean;
begin
  Result := ParseMultiSetTerm(GotMultiSetToken);
  while GotMultiSetToken do
    begin
      case FTokenType of
        ttUNION  : GetNextToken;
        ttEXCEPT : GetNextToken;
      else
        ParseError('Invalid MULTISET operator');
      end;
      if SkipToken(ttALL) then
      else
      if SkipToken(ttDISTINCT) then
      ;
      ParseMultiSetTerm(GotMultiSetToken);
    end;
end;

{ SQL99:                                                                       }
{ <collection value expression> ::=                                            }
{     <value expression primary>                                               }
{                                                                              }
{ SQL2003:                                                                     }
{ <collection value expression> ::=                                            }
{       <array value expression>                                               }
{     | <multiset value expression>                                            }
function TSqlParser.ParseCollectionValueExpression: ASqlValueExpression;
begin
  Result := ParseValueExpressionPrimary;
end;

{ SQL99/SQL2003:                                                               }
{ <cardinality expression> ::=                                                 }
{     CARDINALITY <left paren> <collection value expression> <right paren>     }
function TSqlParser.ParseCardinalityExpression: ASqlValueExpression;
begin
  Assert(FTokenType = ttCARDINALITY);
  GetNextToken;
  ExpectLeftParen;
  ParseCollectionValueExpression;
  ExpectRightParen;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <absolute value expression> ::=                                              }
{     ABS <left paren> <numeric value expression> <right paren>                }
function TSqlParser.ParseAbsoluteValueExpression: ASqlValueExpression;
begin
  Assert(FTokenType = ttABS);
  GetNextToken;
  ExpectLeftParen;
  ParseNumericValueExpression(nil);
  ExpectRightParen;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <modulus expression> ::=                                                     }
{     MOD <left paren> <numeric value expression dividend> <comma>             }
{     <numeric value expression divisor><right paren>                          }
{ <numeric value expression dividend> ::= <numeric value expression>           }
function TSqlParser.ParseModulusExpression: ASqlValueExpression;
begin
  Assert(FTokenType = ttMOD);
  GetNextToken;
  ExpectLeftParen;
  ParseNumericValueExpression(nil);
  ExpectRightParen;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <natural logarithm> ::= LN <left paren> <numeric value expression> <right paren> }
{ <exponential function> ::= EXP <left paren> <numeric value expression> <right paren> }
{ <power function> ::= POWER <left paren> <numeric value expression base> <comma> <numeric value expression exponent> <right paren> }
{ <square root> ::= SQRT <left paren> <numeric value expression> <right paren> }
{ <floor function> ::= FLOOR <left paren> <numeric value expression> <right paren> }
{ <ceiling function> ::= ( CEIL | CEILING ) <left paren> <numeric value expression> <right paren> }

{ SQL2003:                                                                     }
{ <width bucket function> ::= WIDTH_BUCKET <left paren> <width bucket operand> <comma> <width bucket bound 1> <comma> <width bucket bound 2> <comma> <width bucket count> <right paren> }
{ <width bucket operand> ::= <numeric value expression>                        }
{ <width bucket bound 1> ::= <numeric value expression>                        }
{ <width bucket bound 2> ::= <numeric value expression>                        }
{ <width bucket count> ::= <numeric value expression>                          }
function TSqlParser.ParseWidthBucketFunction: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
  if SkipToken(ttWIDTH_BUCKET) then
    begin
      ExpectLeftParen;
      ParseNumericValueExpression(nil);
      ExpectComma;
      ParseNumericValueExpression(nil);
      ExpectComma;
      ParseNumericValueExpression(nil);
      ExpectComma;
      ParseNumericValueExpression(nil);
      ExpectRightParen;
    end
  else
    Result := nil;
end;

{ SQL92:                                                                       }
{ <numeric value function> ::=                                                 }
{       <position expression>                                                  }
{     | <extract expression>                                                   }
{     | <length expression>                                                    }
{                                                                              }
{ SQL99:                                                                       }
{ <numeric value function> ::=                                                 }
{       <position expression>                                                  }
{     | <extract expression>                                                   }
{     | <length expression>                                                    }
{     | <cardinality expression>                                               }
{     | <absolute value expression>                                            }
{     | <modulus expression>                                                   }
{                                                                              }
{ SQL2003:                                                                     }
{ <numeric value function> ::=                                                 }
{       <position expression>                                                  }
{     | <extract expression>                                                   }
{     | <length expression>                                                    }
{     | <cardinality expression>                                               }
{     | <absolute value expression>                                            }
{     | <modulus expression>                                                   }
{     | <natural logarithm>                                                    }
{     | <exponential function>                                                 }
{     | <power function>                                                       }
{     | <square root>                                                          }
{     | <floor function>                                                       }
{     | <ceiling function>                                                     }
{     | <width bucket function>                                                }
function TSqlParser.ParseNumericValueFunction: ASqlValueExpression;
begin
  case FTokenType of
    ttPOSITION          : Result := ParsePositionExpression;
    ttEXTRACT           : Result := ParseExtractExpression;
    ttCHAR_LENGTH,
    ttCHARACTER_LENGTH,
    ttOCTET_LENGTH,
    ttBIT_LENGTH        : Result := ParseLengthExpression;
  else
    Result := nil;
  end;
  if Assigned(Result) then
    exit;
  if FCompatibility >= spcSql99 then
    case FTokenType of
      ttCARDINALITY : Result := ParseCardinalityExpression;
      ttABS         : Result := ParseAbsoluteValueExpression;
      ttMOD         : Result := ParseModulusExpression;
    end;
  if Assigned(Result) then
    exit;
  if FCompatibility >= spcSql2003 then
    case FTokenType of
      ttLN           : ;
      ttEXP          : ;
      ttPOWER        : ;
      ttSQRT         : ;
      ttFLOOR        : ;
      ttCEIL,
      ttCEILING      : ;
      ttWIDTH_BUCKET : Result := ParseWidthBucketFunction;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <numeric primary> ::=                                                        }
{       <value expression primary>                                             }
{     | <numeric value function>                                               }
function TSqlParser.ParseNumericPrimary: ASqlValueExpression;
begin
  Result := ParseNumericValueFunction;
  if Assigned(Result) then
    exit;
  Result := ParseValueExpressionPrimary;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <factor> ::= [ <sign> ] <numeric primary>                                    }
function TSqlParser.ParseFactor: ASqlValueExpression;
var N : Boolean;
begin
  N := FTokenType = ttMinus;
  SkipAnyToken([ttPlus, ttMinus]);
  Result := ParseNumericPrimary;
  if N then
    Result := TSqlNegateExpression.CreateEx(Result);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <term> ::=                                                                   }
{       <factor>                                                               }
{     | <term> <asterisk> <factor>                                             }
{     | <term> <solidus> <factor>                                              }
{ <asterisk> ::= *                                                             }
{ <solidus> ::= /                                                              }
function TSqlParser.ParseTerm(const Factor: ASqlValueExpression): ASqlValueExpression;
var E : ASqlValueExpression;
    T : Integer;
begin
  if Assigned(Factor) then
    Result := Factor
  else
    Result := ParseFactor;
  while FTokenType in [ttAsterisk, ttSolidus] do
    begin
      T := FTokenType;
      GetNextToken;
      E := ParseFactor;
      if T = ttAsterisk then
        Result := TSqlMultiplyExpression.CreateEx(Result, E)
      else
        Result := TSqlDivideExpression.CreateEx(Result, E);
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <numeric value expression> ::=                                               }
{       <term>                                                                 }
{     | <numeric value expression> <plus sign> <term>                          }
{     | <numeric value expression> <minus sign> <term>                         }
function TSqlParser.ParseNumericValueExpression(const Factor: ASqlValueExpression): ASqlValueExpression;
var E : ASqlValueExpression;
    T : Integer;
begin
  Result := ParseTerm(Factor);
  if Assigned(Result) then
    try
      while FTokenType in [ttPlus, ttMinus] do
        begin
          T := FTokenType;
          GetNextToken;
          E := ParseTerm;
          if T = ttPlus then
            Result := TSqlAddExpression.CreateEx(Result, E)
          else
            Result := TSqlSubtractExpression.CreateEx(Result, E);
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99:                                                                 }
{ <character substring function> ::=                                           }
{   SUBSTRING <left paren> <character value expression> FROM <start position>  }
{       [ FOR <string length> ] <right paren>                                  }
{ <start position> ::= <numeric value expression>                              }
{ <string length> ::= <numeric value expression>                               }
{                                                                              }
{ SQL2003:                                                                     }
{ <character substring function> ::=                                           }
{   SUBSTRING <left paren> <character value expression> FROM <start position>  }
{       [ FOR <string length> ]                                                }
{       [ USING <char length units> ] <right paren>                            }
function TSqlParser.ParseCharacterSubStringFunction: TSqlCharacterSubStringFunction;
begin
  Assert(FTokenType = ttSUBSTRING);
  GetNextToken;
  Result := TSqlCharacterSubStringFunction.Create;
  with Result do
    try
      ExpectLeftParen;
      ValueExpr := ExpectCharacterValueExpression;
      if (spoExtendedSyntax in FOptions) and (FTokenType = ttComma) then
        begin
          // Extended syntax: , allowed instead of FROM and FOR
          GetNextToken;
          StartPosition := ParseNumericValueExpression;
          if SkipToken(ttComma) then
            StringLength := ParseNumericValueExpression;
        end
      else
        begin
          // SQL92: FROM and FOR required
          ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);
          StartPosition := ParseNumericValueExpression;
          if SkipToken(ttFOR) then
            StringLength := ParseNumericValueExpression;
        end;
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <trim function> ::= TRIM <left paren> <trim operands> <right paren>          }
{ <trim operands> ::=                                                          }
{     [ [ <trim specification> ] [ <trim character> ] FROM ] <trim source>     }
{ <trim specification> ::= LEADING | TRAILING | BOTH                           }
{ <trim character> ::= <character value expression>                            }
{ <trim source> ::= <character value expression>                               }
function TSqlParser.ParseCharacterTrimFunction: TSqlCharacterTrimFunction;
var R : Boolean;
    C : ASqlValueExpression;
begin
  Assert(FTokenType = ttTRIM);
  GetNextToken;
  Result := TSqlCharacterTrimFunction.Create;
  with Result do
    try
      ExpectLeftParen;
      R := True;
      case FTokenType of
        ttLEADING  : TrimOperation := stoLeading;
        ttTRAILING : TrimOperation := stoTrailing;
        ttBOTH     : TrimOperation := stoBoth;
      else
        R := False;
      end;
      if R then
        GetNextToken
      else
        TrimOperation := stoBoth;
      C := ExpectCharacterValueExpression;
      if FTokenType <> ttRightParen then
        begin
          TrimCharacters := C;
          SkipToken(ttFROM);
          ValueExpr := ExpectCharacterValueExpression;
        end
      else
        ValueExpr := C;
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <fold> ::= ( UPPER | LOWER )                                                 }
{      <left paren> <character value expression> <right paren>                 }
function TSqlParser.ParseCharacterFoldFunction: TSqlCharacterFoldFunction;
begin
  Assert(FTokenType in [ttUPPER, ttLOWER]);
  Result := TSqlCharacterFoldFunction.Create;
  with Result do
    try
      case FTokenType of
        ttUPPER : Operation := scfUpper;
        ttLOWER : Operation := scfLower;
      end;
      GetNextToken;
      ExpectLeftParen;
      ValueExpr := ExpectCharacterValueExpression;
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <form-of-use conversion> ::=                                                 }
{     CONVERT <left paren> <character value expression>                        }
{         USING <form-of-use conversion name> <right paren>                    }
{ <form-of-use conversion name> ::= <qualified name>                           }
function TSqlParser.ParseFormOfUseConversion: TSqlFormOfUseConversion;
begin
  Assert(FTokenType = ttCONVERT);
  GetNextToken;
  ExpectLeftParen;
  Result := TSqlFormOfUseConversion.Create;
  with Result do
    try
      ValueExpr := ExpectCharacterValueExpression;
      ExpectKeyword(ttUSING, SQL_KEYWORD_USING);
      ConversionName := ParseQualifiedName;
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99:                                                                 }
{ <character translation> ::=                                                  }
{     TRANSLATE <left paren> <character value expression>                      }
{         USING <translation name> <right paren>                               }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseCharacterTranslation: TSqlCharacterTranslation;
begin
  Assert(FTokenType = ttTRANSLATE);
  GetNextToken;
  ExpectLeftParen;
  Result := TSqlCharacterTranslation.Create;
  with Result do
    try
      ValueExpr := ExpectCharacterValueExpression;
      ExpectKeyword(ttUSING, SQL_KEYWORD_USING);
      TranslationName := ParseTranslationName;
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL99/SQL2003:                                                               }
{ <regular expression substring function> ::=                                  }
{       SUBSTRING <left paren> <character value expression>                    }
{       SIMILAR <character value expression>                                   }
{       ESCAPE <escape character> <right paren>                                }
function TSqlParser.ParseRegularExpressionSubStringFunction: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <character overlay function> ::=                                             }
{       OVERLAY <left paren> <character value expression>                      }
{       PLACING <character value expression>                                   }
{       FROM <start position> [ FOR <string length> ] <right paren>            }
function TSqlParser.ParseCharacterOverlayFunction: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <specific type method> ::=                                                   }
{       <user-defined type value expression> <period> SPECIFICTYPE             }
function TSqlParser.ParseSpecificTypeMethod: ASqlValueExpression;
begin
  //// ParseUserDefinedTypeValueExpression;
  SkipToken(ttPeriod);
  //// SkipToken(ttSPECIFICTYPE);
  ////
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <transcoding> ::=                                                            }
{     CONVERT <left paren> <character value expression>                        }
{         USING <transcoding name> <right paren>                               }
function TSqlParser.ParseTranscoding: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
  if SkipToken(ttCONVERT) then
    begin
    end
  else
    Result := nil;
end;

{ SQL2003:                                                                     }
{ <character transliteration> ::=                                              }
{     TRANSLATE <left paren> <character value expression>                      }
{         USING <transliteration name> <right paren>                           }
function TSqlParser.ParseCharacterTransliteration: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
  if SkipToken(ttTRANSLATE) then
    begin
    end
  else
    Result := nil;
end;

{ SQL2003:                                                                     }
{ <normalize function> ::=                                                     }
{     NORMALIZE <left paren> <character value expression> <right paren>        }
function TSqlParser.ParseNormalizeFunction: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
  if SkipToken(ttNORMALIZE) then
    begin
    end
  else
    Result := nil;
end;

{ SQL92:                                                                       }
{ <character value function> ::=                                               }
{       <character substring function>                                         }
{     | <fold>                                                                 }
{     | <form-of-use conversion>                                               }
{     | <character translation>                                                }
{     | <trim function>                                                        }
{                                                                              }
{ SQL99:                                                                       }
{ <character value function> ::=                                               }
{   		<character substring function>                                         }
{     |	<regular expression substring function>                                }
{     |	<fold>                                                                 }
{     |	<form-of-use conversion>                                               }
{     |	<character translation>                                                }
{     |	<trim function>                                                        }
{     |	<character overlay function>                                           }
{     |	<specific type method>                                                 }
{                                                                              }
{ SQL2003:                                                                     }
{ <character value function> ::=                                               }
{       <character substring function>                                         }
{     | <regular expression substring function>                                }
{     | <fold>                                                                 }
{     | <transcoding>                                                          }
{     | <character transliteration>                                            }
{     | <trim function>                                                        }
{     | <character overlay function>                                           }
{     | <normalize function>                                                   }
{     | <specific type method>                                                 }
function TSqlParser.ParseCharacterValueFunction: ASqlValueExpression;
begin
  case FTokenType of
    ttSUBSTRING : Result := ParseCharacterSubStringFunction;
    ttUPPER,
    ttLOWER     : Result := ParseCharacterFoldFunction;
    ttCONVERT   : Result := ParseFormOfUseConversion;
    ttTRANSLATE : Result := ParseCharacterTranslation;
    ttTRIM      : Result := ParseCharacterTrimFunction;
  else
    Result := nil;
  end;
  if Assigned(Result) then
    exit;
  if FCompatibility >= spcSql2003 then
    case FTokenType of
      ttNORMALIZE : ;
    end;
end;

{ SQL92/SQL99:                                                                 }
{ <bit substring function> ::=                                                 }
{     SUBSTRING <left paren> <bit value expression> FROM <start position>      }
{         [ FOR <string length> ] <right paren>                                }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseBitSubStringFunction: TSqlBitSubStringFunction;
begin
  Assert(FTokenType = ttSUBSTRING);
  GetNextToken;
  ExpectLeftParen;
  Result := TSqlBitSubStringFunction.Create;
  with Result do
    try
      ValueExpr := ParseBitValueExpression;
      ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);
      StartPos := ParseNumericValueExpression;
      if SkipToken(ttFOR) then
        StringLength := ParseNumericValueExpression;
      ExpectRightParen;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99:                                                                 }
{ <bit value function> ::= <bit substring function>                            }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseBitValueFunction: ASqlValueExpression;
begin
  if FTokenType = ttSUBSTRING then
    Result := ParseBitSubStringFunction
  else
    Result := nil;
end;

{ SQL92:                                                                       }
{ <string value function> ::=                                                  }
{       <character value function>                                             }
{     | <bit value function>                                                   }
{                                                                              }
{ SQL99:                                                                       }
{ <string value function> ::=                                                  }
{       <character value function>                                             }
{     | <blob value function>                                                  }
{     | <bit value function>                                                   }
{ <blob substring function> ::=                                                }
{     SUBSTRING <left paren> <blob value expression> FROM <start position>     }
{     [ FOR <string length> ] <right paren>                                    }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <blob value function> ::=                                                    }
{       <blob substring function>                                              }
{     | <blob trim function>                                                   }
{     | <blob overlay function>                                                }
{                                                                              }
{ SQL2003:                                                                     }
{ <string value function> ::=                                                  }
{       <character value function>                                             }
{     | <blob value function>                                                  }
function TSqlParser.ParseStringValueFunction: ASqlValueExpression;
begin
  // Not implemented: Distinguish between bit and character SUBSTRING
  Result := ParseCharacterValueFunction;
  if Assigned(Result) then
    exit;
  Result := ParseBitValueFunction;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <character primary> ::= <value expression primary> | <string value function> }
function TSqlParser.ParseCharacterPrimary: ASqlValueExpression;
begin
  Result := ParseStringValueFunction;
  if Assigned(Result) then
    exit;
  Result := ParseValueExpressionPrimary;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <character factor> ::= <character primary> [ <collate clause> ]              }
function TSqlParser.ParseCharacterFactor: ASqlValueExpression;
var C : AnsiString;
begin
  Result := ParseCharacterPrimary;
  if not Assigned(Result) then
    exit;
  C := ParseCollateClause;
  if C <> '' then
    Result := TSqlValueExpressionWithCollate.CreateEx(Result, C);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <character value expression> ::=                                             }
{       <concatenation>                                                        }
{     | <character factor>                                                     }
{                                                                              }
{ <concatenation> ::=                                                          }
{   <character value expression> <concatenation operator> <character factor>   }
{                                                                              }
{ SQL92/SQL99:                                                                 }
{ <concatenation operator> ::= ||                                              }
{                                                                              }
{ SQL2003:                                                                     }
{ <concatenation operator> ::= <vertical bar> <vertical bar>                   }
function TSqlParser.ParseCharacterValueExpression: ASqlValueExpression;
begin
  Result := ParseCharacterFactor;
  if Assigned(Result) then
    try
      while SkipToken(ttConcatenation) do
        Result := TSqlCharacterConcatenationOperation.CreateEx(Result,
            ParseCharacterFactor);
    except
      Result.Free;
      raise;
    end;
end;

function TSqlParser.ExpectCharacterValueExpression: ASqlValueExpression;
begin
  Result := ParseCharacterValueExpression;
  if not Assigned(Result) then
    ParseError('Character value expression expected');
end;

{ SQL92/SQL99:                                                                 }
{ <bit primary> ::=                                                            }
{       <value expression primary>                                             }
{     | <string value function>                                                }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseBitPrimary: ASqlValueExpression;
begin
  Result := ParseStringValueFunction;
  if Assigned(Result) then
    exit;
  Result := ParseValueExpressionPrimary;
end;

{ SQL92/SQL99:                                                                 }
{ <bit factor> ::= <bit primary>                                               }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseBitFactor: ASqlValueExpression;
begin
  Result := ParseBitPrimary;
end;

{ SQL92/SQL99:                                                                 }
{ <bit value expression> ::=                                                   }
{       <bit concatenation>                                                    }
{     | <bit factor>                                                           }
{ <bit concatenation> ::=                                                      }
{     <bit value expression> <concatenation operator> <bit factor>             }
function TSqlParser.ParseBitValueExpression: ASqlValueExpression;
var R : TSqlBitConcatenationOperation;
begin
  Result := ParseBitFactor;
  if Assigned(Result) then
    try
      while SkipToken(ttConcatenation) do
        begin
          R := TSqlBitConcatenationOperation.Create;
          try
            R.Left := Result;
            R.Right := ParseBitFactor;
          except
            R.Free;
            raise;
          end;
          Result := R;
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <string value expression> ::=                                                }
{       <character value expression>                                           }
{     | <bit value expression>                                                 }
{                                                                              }
{ SQL99:                                                                       }
{ <string value expression> ::=                                                }
{       <character value expression>                                           }
{     | <bit value expression>                                                 }
{     | <blob value expression>                                                }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <blob value expression> ::= <blob concatenation> | <blob factor>             }
{ <blob concatenation> ::=                                                     }
{     <blob value expression> <concatenation operator> <blob factor>           }
{ <blob factor> ::= <blob primary>                                             }
{ <blob primary> ::= <value expression primary> | <string value function>      }
{                                                                              }
{ SQL2003:                                                                     }
{ <string value expression> ::=                                                }
{       <character value expression>                                           }
{     | <blob value expression>                                                }
function TSqlParser.ParseStringValueExpression: ASqlValueExpression;
begin
  Result := ParseCharacterValueExpression;
  if Assigned(Result) then
    exit;
  Result := ParseBitValueExpression;
end;

{ SQL92/SQL99:                                                                 }
{ <time zone specifier> ::=                                                    }
{       LOCAL                                                                  }
{     | TIME ZONE <interval value expression>                                  }
{                                                                              }
{ SQL2003:                                                                     }
{ <time zone specifier> ::=                                                    }
{       LOCAL                                                                  }
{     | TIME ZONE <interval primary>                                           }
function TSqlParser.ParseTimeZoneSpecifier: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <time zone> ::= AT <time zone specifier>                                     }
function TSqlParser.ParseTimeZone: TSqlTimeZone;
begin
  if SkipToken(ttAT) then
    begin
      Result := TSqlTimeZone.Create;
      with Result do
        try
          case FTokenType of
            ttLOCAL :
              begin
                GetNextToken;
                Local := True;
              end;
            ttTIME  :
              begin
                GetNextToken;
                ExpectKeyword(ttZONE, SQL_KEYWORD_ZONE);
                TimeZone := ParseIntervalValueExpression;
              end;
          else
            ParseError('Time zone specifier expected');
          end;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <datetime primary> ::=                                                       }
{       <value expression primary>                                             }
{     | <datetime value function>                                              }
function TSqlParser.ParseDateTimePrimary: ASqlValueExpression;
begin
  Result := ParseDateTimeValueFunction;
  if Assigned(Result) then
    exit;
  Result := ParseValueExpressionPrimary;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <datetime factor> ::= <datetime primary> [ <time zone> ]                     }
function TSqlParser.ParseDateTimeFactor: ASqlValueExpression;
var T : TSqlTimeZone;
    R : TSqlDateTimeExprAtTimeZone;
begin
  Result := ParseDateTimePrimary;
  if not Assigned(Result) then
    exit;
  T := ParseTimeZone;
  if Assigned(T) then
    begin
      R := TSqlDateTimeExprAtTimeZone.Create;
      R.ValueExpr := Result;
      R.TimeZone := T;
      Result := R;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <datetime term> ::= <datetime factor>                                        }
function TSqlParser.ParseDateTimeTerm: ASqlValueExpression;
begin
  Result := ParseDateTimeFactor;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <datetime value expression> ::=                                              }
{       <datetime term>                                                        }
{     | <interval value expression> <plus sign> <datetime term>                }// Not implemented
{     | <datetime value expression> <plus sign> <interval term>                }
{     | <datetime value expression> <minus sign> <interval term>               }
function TSqlParser.ParseDateTimeValueExpression: ASqlValueExpression;
var T : Integer;
begin
  Result := ParseDateTimeTerm;
  while FTokenType in [ttPlus, ttMinus] do
    begin
      T := FTokenType;
      GetNextToken;
      if T = ttPlus then
        Result := TSqlAddExpression.CreateEx(Result, ParseIntervalTerm)
      else
        Result := TSqlSubtractExpression.CreateEx(Result, ParseIntervalTerm)
    end;
end;

{ SQL2003:                                                                     }
{ <interval value function> ::= <interval absolute value function>             }
{ <interval absolute value function> ::=                                       }
{     ABS <left paren> <interval value expression> <right paren>               }
function TSqlParser.ParseIntervalValueFunction: ASqlValueExpression;
begin
  ExpectKeyword(ttABS, SQL_KEYWORD_ABS);
  ExpectLeftParen;
  ParseIntervalValueExpression;
  ExpectRightParen; 
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <interval primary> ::= <value expression primary> [ <interval qualifier> ]   }// Not implemented: [ <interval qualifier> ]
{                                                                              }
{ SQL99:                                                                       }
{ <interval primary> ::=                                                       }
{       <value expression primary>                                             }
{     | <interval value function>                                              }
{                                                                              }
{ SQL2003:                                                                     }
{ <interval primary> ::=                                                       }
{       <value expression primary> [ <interval qualifier> ]                    }
{     | <interval value function>                                              }
function TSqlParser.ParseIntervalPrimary: ASqlValueExpression;
begin
  Result := ParseIntervalValueFunction;
  if Assigned(Result) then
    exit;
  Result := ParseValueExpressionPrimary;
  if FCompatibility >= spcSql2003 then
    if Assigned(Result) then
      ParseIntervalQualifier;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <interval factor> ::= [ <sign> ] <interval primary>                          }
function TSqlParser.ParseIntervalFactor: ASqlValueExpression;
var N : Boolean;
begin
  N := (SkipAnyToken([ttPlus, ttMinus]) = ttMinus);
  Result := ParseIntervalPrimary;
  if N and not Assigned(Result) then
    ParseError('Interval primary expected');
  if N then
    Result := TSqlNegateExpression.CreateEx(Result);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <interval term> ::=                                                          }
{       <interval factor>                                                      }
{     | <interval term 2> <asterisk> <factor>                                  }
{     | <interval term 2> <solidus> <factor>                                   }
{     | <term> <asterisk> <interval factor>                                    }// Not implemented: Term eval somewhere else ?
{ <interval term 2> ::= <interval term>                                        }
function TSqlParser.ParseIntervalTerm: ASqlValueExpression;
var T : Integer;
    E : ASqlValueExpression;
begin
  Result := ParseIntervalFactor;
  if not Assigned(Result) then
    exit;
  try
    while FTokenType in [ttAsterisk, ttSolidus] do
      begin
        T := FTokenType;
        GetNextToken;
        E := ParseFactor;
        if not Assigned(E) then
          ParseError('Factor expected');
        if T = ttAsterisk then
          Result := TSqlMultiplyExpression.CreateEx(Result, E)
        else
          Result := TSqlDivideExpression.CreateEx(Result, E);
      end;
  except
    Result.Free;
    raise;
  end;
end;

{ SQL92/SQL99:                                                                 }
{ <interval value expression> ::=                                              }
{       <interval term>                                                        }
{     | <interval value expression 1> <plus sign> <interval term 1>            }
{     | <interval value expression 1> <minus sign> <interval term 1>           }
{     | <left paren> <datetime value expression> <minus sign>                  }// Not implemented: Paren eval somewhere else ?
{       <datetime term> <right paren> <interval qualifier>                     }
{ <interval term 1> ::= <interval term>                                        }
{                                                                              }
{ SQL2003:                                                                     }
{ <interval value expression> ::=                                              }
{       <interval term>                                                        }
{	    | <interval value expression 1> <plus sign> <interval term 1>            }
{	    | <interval value expression 1> <minus sign> <interval term 1>           }
{	    | <left paren> <datetime value expression> <minus sign>                  }
{       <datetime term> <right paren> <interval qualifier>                     }
function TSqlParser.ParseIntervalValueExpression: ASqlValueExpression;
var T : Integer;
    E : ASqlValueExpression;
begin
  Result := ParseIntervalTerm;
  if not Assigned(Result) then
    exit;
  try
    while FTokenType in [ttPlus, ttMinus] do
      begin
        T := FTokenType;
        GetNextToken;
        E := ParseTerm;
        if not Assigned(E) then
          ParseError('Interval term expected');
        if T = ttPlus then
          Result := TSqlAddExpression.CreateEx(Result, E)
        else
          Result := TSqlSubtractExpression.CreateEx(Result, E);
      end;
  except
    Result.Free;
    raise;
  end;
end;

{ SQL99/SQL2003:                                                               }
{ <boolean value expression> ::=                                               }
{       <boolean term>                                                         }
{     | <boolean value expression> OR <boolean term>                           }
function TSqlParser.ParseBooleanValueExpression: ASqlValueExpression;
var R : ASqlSearchCondition;
    E : ASqlSearchCondition;
begin
  R := ParseBooleanTerm;
  if not Assigned(R) then
    begin
      Result := nil;
      exit;
    end;
  try
    while FTokenType = ttOR do
      begin
        GetNextToken;
        E := ParseBooleanTerm;
        if not Assigned(E) then
          ParseError('Boolean term expected');
        R := TSqlLogicalOrCondition.CreateEx(R, E);
      end;
  except
    R.Free;
    raise;
  end;
  Result := R;
end;

{ SQL2003:                                                                     }
{ <common value expression> ::=                                                }
{       <numeric value expression>                                             }
{     | <string value expression>                                              }
{     | <datetime value expression>                                            }
{     | <interval value expression>                                            }
{     | <user-defined type value expression>                                   }
{     | <reference value expression>                                           }
{     | <collection value expression>                                          }
function TSqlParser.ParseCommonValueExpression(const Factor: ASqlValueExpression): ASqlValueExpression;
begin
  Result := ParseNumericValueExpression(Factor);
  if Assigned(Result) then
    exit;
  Result := ParseStringValueExpression;
  if Assigned(Result) then
    exit;
  Result := ParseDateTimeValueExpression;
  if Assigned(Result) then
    exit;
  Result := ParseIntervalValueExpression;
  if Assigned(Result) then
    exit;
  //// TODO
end;

{ SQL99:                                                                       }
{ <user-defined type value expression> ::= <value expression primary>          }
{ <reference value expression> ::= <value expression primary>                  }

{ SQL92:                                                                       }
{ <value expression> ::=                                                       }
{       <numeric value expression>                                             }
{     | <string value expression>                                              }
{     | <datetime value expression>                                            }
{     | <interval value expression>                                            }
{                                                                              }
{ SQL99:                                                                       }
{ <value expression> ::=                                                       }
{       <numeric value expression>                                             }
{     | <string value expression>                                              }
{     | <datetime value expression>                                            }
{     | <interval value expression>                                            }
{     | <boolean value expression>                                             }
{     | <user-defined type value expression>                                   }
{     | <row value expression>                                                 }
{     | <reference value expression>                                           }
{     | <collection value expression>                                          }
{                                                                              }
{ SQL2003:                                                                     }
{ <value expression> ::=                                                       }
{       <common value expression>                                              }
{     | <boolean value expression>                                             }
{     | <row value expression>                                                 }
function TSqlParser.ParseValueExpression(const Factor: ASqlValueExpression): ASqlValueExpression;
begin
  Result := ParseNumericValueExpression(Factor);
  if Assigned(Result) then
    exit;
  Result := ParseStringValueExpression;
  if Assigned(Result) then
    exit;
  Result := ParseDateTimeValueExpression;
  if Assigned(Result) then
    exit;
  Result := ParseIntervalValueExpression;
  if Assigned(Result) then
    exit;
  if FCompatibility >= spcSql99 then
    begin
      Result := ParseBooleanValueExpression;
      if Assigned(Result) then
        exit;
      Result := ParseRowValueExpression;
      if Assigned(Result) then
        exit;
      Result := ParseValueExpressionPrimary;
    end;
end;

function TSqlParser.ExpectValueExpression(const Factor: ASqlValueExpression): ASqlValueExpression;
begin
  Result := ParseValueExpression(Factor);
  if not Assigned(Result) then
    ParseError('Value expression expected');
end;

{ SQL2003:                                                                     }
{ <all fields column name list> ::= <column name list>                         }
function TSqlParser.ParseAllFieldsColumnNameList: AnsiStringArray;
begin
  Result := ParseColumnNameList;
end;

{ SQL2003:                                                                     }
{ <all fields reference> ::=                                                   }
{     <value expression primary> <period> <asterisk>                           }
{     [ AS <left paren> <all fields column name list> <right paren> ]          }
function TSqlParser.ParseAllFieldsReference: ASqlValueExpression;
begin
  Result := ParseValueExpressionPrimary;
  //// TODO
  if SkipToken(ttAS) then
    begin
      ExpectLeftParen;
      ParseAllFieldsColumnNameList;
      ExpectRightParen;
    end;
end;

{ SQL2003:                                                                     }
{ <asterisked identifier> ::= <identifier>                                     }
function TSqlParser.ParseAsteriskedIdentifier: AnsiString;
begin
  Result := ParseIdentifier;
end;

{ SQL2003:                                                                     }
{ <asterisked identifier chain> ::=                                            }
{     <asterisked identifier> [ ( <period> <asterisked identifier> )... ]      }
function TSqlParser.ParseAsteriskedIdentifierChain: AnsiString;
begin
  Result := ParseAsteriskedIdentifier;
  while SkipToken(ttPeriod) do
    Result := Result + '.' + ParseAsteriskedIdentifier;
end;

{ SQL2003:                                                                     }
{ <qualified asterisk> ::=                                                     }
{       <asterisked identifier chain> <period> <asterisk>                      }
{     | <all fields reference>                                                 }
function TSqlParser.ParseQualifiedAsterisk: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
end;

{ SQL92 ??                                                                     }
{ SQL99/SQL2003:                                                               }
{ <as clause> ::= [ AS ] <column name>                                         }
function TSqlParser.ParseAsClause: AnsiString;
begin
  SkipToken(ttAS);
  Result := ParseColumnName;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <derived column> ::= <value expression> [ <as clause> ]                      }
function TSqlParser.ParseDerivedColumn: ASqlValueExpression;
begin
  Result := ParseValueExpression;
  if Assigned(Result) then
    ParseAsClause;
end;

{ SQL92/SQL99:                                                                 }
{ <select sublist> ::=                                                         }
{       <derived column>                                                       }
{     | <qualifier> <period> <asterisk>                                        }
{                                                                              }
{ SQL2003:                                                                     }
{ <select sublist> ::=                                                         }
{       <derived column>                                                       }
{     | <qualified asterisk>                                                   }
function TSqlParser.ParseSelectSubList: TSqlSelectItem;
var S, T : AnsiString;
    R    : Boolean;
begin
  Result := TSqlSelectItem.Create;
  with Result do
    try
      if FTokenType = ttIdentifier then
        begin
          S := ParseIdentifier;
          R := False;
          while not R and SkipToken(ttPeriod) do
            begin
              T := ParseIdentifier;
              S := S + '.' + T;
              if T = '' then
                R := True;
            end;
          if R then
            if SkipToken(ttAsterisk) then
              begin
                ValueExpr := TSqlColumnReference.CreateEx(S + '*');
                exit;
              end
            else
              ParseError('Column identifier expected');
          ValueExpr := ExpectValueExpression(TSqlColumnReference.CreateEx(S));
        end
      else
        ValueExpr := ExpectValueExpression;
      if SkipToken(ttAS) then
        AsName := ExpectIdentifier;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <select list> ::=                                                            }
{       <asterisk>                                                             }
{     | <select sublist> [ ( <comma> <select sublist> )... ]                   }
function TSqlParser.ParseSelectList: TSqlSelectList;
begin
  Result := TSqlSelectList.Create;
  with Result do
    try
      if SkipToken(ttAsterisk) then
        Wild := True
      else
        repeat
          AddItem(ParseSelectSubList);
        until not SkipToken(ttComma);
    except
      Result.Free;
      raise;
    end;
end;

{ SQL2003:                                                                     }
{ <row value constructor element list> ::=                                     }
{     <row value constructor element>                                          }
{     [ ( <comma> <row value constructor element> )... ]                       }
function TSqlParser.ParseRowValueConstructorElementList: TObject;
begin
  ParseRowValueConstructorElement;
  while SkipToken(ttComma) do
    ParseRowValueConstructorElement;
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <row subquery> ::= <subquery>                                                }
function TSqlParser.ParseRowSubQuery: ASqlQueryExpression;
begin
  Result := ParseSubQuery(False);
end;

{ SQL2003:                                                                     }
{ <explicit row value constructor> ::=                                         }
{       <left paren> <row value constructor element>                           }
{           <comma> <row value constructor element list> <right paren>         }
{	    | ROW <left paren> <row value constructor element list> <right paren>    }
{     | <row subquery>                                                         }
function TSqlParser.ParseExplicitRowValueConstructor: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
  if SkipToken(ttLeftParen) then
    begin
      ParseRowValueConstructorElement;
      ExpectComma;
      ParseRowValueConstructorElementList;
      ExpectRightParen;
    end
  else
  if SkipToken(ttROW) then
    begin
      ExpectLeftParen;
      ParseRowValueConstructorElementList;
      ExpectRightParen;
    end
  else
    Result := nil;
{  else
    Result := ParseRowSubQuery; }
end;

{ SQL99:                                                                       }
{ <row value expression> ::=                                                   }
{       <row value special case>                                               }
{     | <row value constructor>                                                }
{                                                                              }
{ SQL2003:                                                                     }
{ <row value expression> ::=                                                   }
{       <row value special case>                                               }
{     | <explicit row value constructor>                                       }
function TSqlParser.ParseRowValueExpression: ASqlValueExpression;
begin
  Result := ParseValueSpecification;
  if Assigned(Result) then
    exit;
  Result := ParseValueExpression;
  if Assigned(Result) then
    exit;
  Result := ParseRowValueConstructor;
end;

function TSqlParser.ExpectRowValueExpression: ASqlValueExpression;
begin
  Result := ParseRowValueExpression;
  if not Assigned(Result) then
    ParseError('Row value expression expected');
end;

{ SQL92:                                                                       }
{ <row value constructor element> ::=                                          }
{       <value expression>                                                     }
{     | <null specification>                                                   }
{     | <default specification>                                                }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <row value constructor element> ::=                                          }
{     <value expression>                                                       }
function TSqlParser.ParseRowValueConstructorElement: ASqlValueExpression;
begin
  if FCompatibility <= spcSql92 then
    begin
      case FTokenType of
        ttNULL    : Result := TSqlNullValue.Create;
        ttDEFAULT : Result := TSqlDefaultValue.Create;
      else
        Result := nil;
      end;
      if Assigned(Result) then
        begin
          GetNextToken;
          exit;
        end;
    end;
  Result := ParseValueExpression;
end;

function TSqlParser.ExpectRowValueConstructorElement: ASqlValueExpression;
begin
  Result := ParseRowValueConstructorElement;
  if not Assigned(Result) then
    ParseError('Row Value expected');
end;

{ SQL92:                                                                       }
{ <row value constructor list> ::=                                             }
{     <row value constructor element>                                          }
{         [ ( <comma> <row value constructor element> )... ]                   }
function TSqlParser.ParseRowValueConstructorList: ASqlValueExpressionArray;
begin
  Append(ObjectArray(Result), ParseRowValueConstructorElement);
  while SkipToken(ttComma) do
    Append(ObjectArray(Result), ParseRowValueConstructorElement);
end;

{ SQL92:                                                                       }
{ <row value constructor> ::=                                                  }
{       <row value constructor element>                                        }
{     | <left paren> <row value constructor list> <right paren>                }
{     | <row subquery>                                                         }
{                                                                              }
{ SQL99:                                                                       }
{ <row value constructor> ::=                                                  }
{       <row value constructor element>                                        }
{     | [ ROW ] <left paren>                                                   }
{               <row value constructor element list> <right paren>             }
{     | <row subquery>                                                         }
{                                                                              }
{ SQL2003:                                                                     }
{ <row value constructor> ::=                                                  }
{       <common value expression>                                              }
{     | <boolean value expression>                                             }
{     | <explicit row value constructor>                                       }
function TSqlParser.ParseRowValueConstructor: TSqlRowValueConstructor;
var E : ASqlValueExpressionArray;
    A : ASqlValueExpression;
    Q : ASqlQueryExpression;
begin
  if SkipToken(ttLeftParen) then
    begin
      Q := ParseSubQuery(True);
      if Assigned(Q) then
        begin
          Result := TSqlRowValueConstructor.Create;
          Result.RowSubQuery := Q;
          exit;
        end;
      try
        repeat
          Append(ObjectArray(E), ExpectRowValueConstructorElement);
        until not SkipToken(ttComma);
        ExpectRightParen;
      except
        FreeObjectArray(E);
        raise;
      end;
      Result := TSqlRowValueConstructor.Create;
      Result.RowElements := E;
      exit;
    end;
  A := ExpectRowValueConstructorElement;
  Result := TSqlRowValueConstructor.Create;
  Result.RowElement := A;
end;

function TSqlParser.ExpectRowValueConstructor: TSqlRowValueConstructor;
begin
  Result := ParseRowValueConstructor;
  if not Assigned(Result) then
    ParseError('Row Value Constructor expected');
end;

function TSqlParser.ParseRowValue: ASqlValueExpression;
begin
  if FCompatibility <= spcSql92 then
    Result := ParseRowValueConstructor
  else
    Result := ParseRowValueExpression;
end;

function TSqlParser.ExpectRowValue: ASqlValueExpression;
begin
  Result := ParseRowValue;
  if not Assigned(Result) then
    ParseError('Row Value expected');
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <quantifier> ::= <all> | <some>                                              }
{ <all> ::= ALL                                                                }
{ <some> ::= SOME | ANY                                                        }
function TSqlParser.ParseQuantifier: TSqlComparisonQuantifier;
begin
  case FTokenType of
    ttALL  : Result := scqAll;
    ttSOME : Result := scqSome;
    ttANY  : Result := scqAny;
  else
    Result := scqUndefined;
  end;
end;

{ SQL92:                                                                       }
{ <quantified comparison predicate> ::=                                        }
{     <row value constructor> <comp op> <quantifier> <table subquery>          }
{                                                                              }
{ SQL99:                                                                       }
{ <quantified comparison predicate> ::=                                        }
{     <row value expression> <comp op> <quantifier> <table subquery>           }
{                                                                              }
{ SQL2003:                                                                     }
{ <quantified comparison predicate> ::=                                        }
{     <row value predicand> <quantified comparison predicate part 2>           }
{ <quantified comparison predicate part 2> ::=                                 }
{     <comp op> <quantifier> <table subquery>                                  }
function TSqlParser.ParseQuantifiedComparisonPredicate(const RowValue: ASqlValueExpression;
    const CompOp: TSqlComparisonOperator): TSqlQuantifiedComparisonPredicate;
var Q : TSqlComparisonQuantifier;
begin
  Q := ParseQuantifier;
  Assert(Q <> scqUndefined);
  GetNextToken;
  Result := TSqlQuantifiedComparisonPredicate.Create;
  with Result do
    try
      CompOperator := CompOp;
      CompQuantifier := Q;
      Left := RowValue;
      Query := ExpectTableSubQuery(False);
    except
      Result.Free;
      raise;
    end;
end;

{ SQL99:                                                                       }
{ <row value special case> ::=                                                 }
{       <value specification>                                                  }
{     | <value expression>                                                     }
{                                                                              }
{ SQL2003:                                                                     }
{ <row value special case> ::=                                                 }
{     <nonparenthesized value expression primary>                              }
function TSqlParser.ParseRowValueSpecialCase: ASqlValueExpression;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <parenthesized boolean value expression> ::=                                 }
{     <left paren> <boolean value expression> <right paren>                    }
function TSqlParser.ParseParenthesizedBooleanValueExpression: ASqlValueExpression;
begin
  if SkipToken(ttLeftParen) then
    begin
      Result := ParseBooleanValueExpression;
      ExpectRightParen;
    end
  else
    Result := nil;
end;

{ SQL2003:                                                                     }
{ <boolean predicand> ::=                                                      }
{       <parenthesized boolean value expression>                               }
{     | <nonparenthesized value expression primary>                            }
function TSqlParser.ParseBooleanPredicand: ASqlValueExpression;
begin
  // Result := ParseParenthesizedBooleanValueExpression;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <row value constructor predicand> ::=                                        }
{       <common value expression>                                              }
{     | <boolean predicand>                                                    }
{     | <explicit row value constructor>                                       }
function TSqlParser.ParseRowValueConstructorPredicand: ASqlValueExpression;
begin
  Result := ParseCommonValueExpression(nil);
  if Assigned(Result) then
    exit;
  Result := ParseBooleanPredicand;
  if Assigned(Result) then
    exit;
  Result := ParseExplicitRowValueConstructor;
end;

{ SQL2003:                                                                     }
{ <row value predicand> ::=                                                    }
{       <row value special case>                                               }
{     | <row value constructor predicand>                                      }
function TSqlParser.ParseRowValuePredicand: ASqlValueExpression;
begin
  Result := ParseRowValueSpecialCase;
  if Assigned(Result) then
    exit;
  Result := ParseRowValueConstructorPredicand;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <comp op> ::=                                                                }
{       <equals operator>                                                      }
{     | <not equals operator>                                                  }
{     | <less than operator>                                                   }
{     | <greater than operator>                                                }
{     | <less than or equals operator>                                         }
{     | <greater than or equals operator>                                      }

{ SQL92:                                                                       }
{ <comparison predicate> ::=                                                   }
{     <row value constructor> <comp op> <row value constructor>                }
{                                                                              }
{ SQL99:                                                                       }
{ <comparison predicate> ::=                                                   }
{     <row value expression> <comp op> <row value expression>                  }
{                                                                              }
{ SQL2003:                                                                     }
{ <comparison predicate> ::=                                                   }
{     <row value predicand> <comparison predicate part 2>                      }
{ <comparison predicate part 2> ::=                                            }
{     <comp op> <row value predicand>                                          }
function TSqlParser.ParseComparisonPredicate(const RowValue: ASqlValueExpression): ASqlSearchCondition;
var C : TSqlComparisonOperator;
begin
  Assert(Assigned(RowValue));
  case FTokenType of
    ttEqual, ttNotEqual, ttLess, ttGreater, ttLessOrEqual, ttGreaterOrEqual :
      begin
        C := SqlTokenToComparisonOperator(FTokenType);
        GetNextToken;
        if FTokenType in [ttALL, ttSOME, ttANY] then
          Result := ParseQuantifiedComparisonPredicate(RowValue, C)
        else
          Result := TSqlComparisonCondition.CreateEx(C, RowValue,
              ExpectRowValue);
      end;
  else
    Result := nil;
  end;
end;

{ SQL92:                                                                       }
{ <between predicate> ::=                                                      }
{     <row value constructor> [ NOT ] BETWEEN                                  }
{       <row value constructor> AND <row value constructor>                    }
{                                                                              }
{ SQL99:                                                                       }
{ <between predicate> ::=                                                      }
{     <row value expression> [ NOT ] BETWEEN [ ASYMMETRIC | SYMMETRIC ]        }
{     <row value expression> AND <row value expression>                        }
{                                                                              }
{ SQL2003:                                                                     }
{ <between predicate> ::=                                                      }
{     <row value predicand> <between predicate part 2>                         }
{ <between predicate part 2> ::=                                               }
{     [ NOT ] BETWEEN [ ASYMMETRIC | SYMMETRIC ]                               }
{     <row value predicand> AND <row value predicand>                          }
function TSqlParser.ParseBetweenPredicate(const RowValue: ASqlValueExpression;
    const NotPredicate: Boolean): TSqlBetweenPredicate;
begin
  Assert(Assigned(RowValue));
  Assert(FTokenType = ttBETWEEN);
  GetNextToken;
  Result := TSqlBetweenPredicate.Create;
  with Result do
    try
      NotBetween := NotPredicate;
      Expr := RowValue;
      LowValue := ExpectRowValue;
      ExpectKeyword(ttAND, SQL_KEYWORD_AND);
      HighValue := ExpectRowValue;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <in value list> ::= <value expression> ( <comma> <value expression> )...     }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <in value list> ::= <row value expression>                                   }
{     [ ( <comma> <row value expression> )... ]                                }
function TSqlParser.ParseInValueList: ASqlValueExpressionArray;
begin
end;

{ SQL92:                                                                       }
{ <in predicate value> ::=                                                     }
{       <table subquery>                                                       }
{     | <left paren> <in value list> <right paren>                             }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <in predicate value> ::=                                                     }
{       <table subquery>                                                       }
{     | <left paren> <in value list> <right paren>                             }
function TSqlParser.ParseInPredicateValue: ASqlValueExpression;
begin
  ParseTableSubQuery(False);
  ParseInValueList;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <in predicate> ::=                                                           }
{     <row value constructor> [ NOT ] IN <in predicate value>                  }
{                                                                              }
{ SQL99:                                                                       }
{ <in predicate> ::=                                                           }
{     <row value expression> [ NOT ] IN <in predicate value>                   }
{                                                                              }
{ SQL2003:                                                                     }
{ <in predicate> ::=                                                           }
{     <row value predicand> <in predicate part 2>                              }
{ <in predicate part 2> ::= [ NOT ] IN <in predicate value>                    }
function TSqlParser.ParseInPredicate(const RowValue: ASqlValueExpression;
    const NotPredicate: Boolean): TSqlInCondition;
var E : ASqlValueExpression;
    V : ASqlValueExpressionArray;
begin
  Assert(Assigned(RowValue));
  Assert(FTokenType = ttIN);
  GetNextToken;
  Result := TSqlInCondition.CreateEx(RowValue, nil, nil, NotPredicate);
  with Result do
    try
      NotIn := NotPredicate;
      ExpectLeftParen;
      E := ParseValueExpression;
      if Assigned(E) then
        begin
          try
            Append(ObjectArray(V), E);
            while SkipToken(ttComma) do
              Append(ObjectArray(V), ParseValueExpression);
          except
            FreeObjectArray(V);
            raise;
          end;
          ValueList := V;
          ExpectRightParen;
        end
      else
        QueryExpr :=  ExpectTableSubQuery(True);
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <like predicate> ::=                                                         }
{     <match value> [ NOT ] LIKE <pattern>                                     }
{       [ ESCAPE <escape character> ]                                          }
{ <match value> ::= <character value expression>                               }
{ <pattern> ::= <character value expression>                                   }
{ <escape character> ::= <character value expression>                          }
{                                                                              }
{ SQL99:                                                                       }
{ <character like predicate> ::=                                               }
{     <character match value> [ NOT ] LIKE <character pattern>                 }
{     [ ESCAPE <escape character> ]                                            }
{ <character match value> ::= <character value expression>                     }
{ <character pattern> ::= <character value expression>                         }
{ <octet like predicate> ::=                                                   }
{     <octet match value> [ NOT ] LIKE <octet pattern>                         }
{     [ ESCAPE <escape octet> ]                                                }
{ <octet match value> ::= <blob value expression>                              }
{ <octet pattern> ::= <blob value expression>                                  }
{ <escape octet> ::= <blob value expression>                                   }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <like predicate> ::=                                                         }
{       <character like predicate>                                             }
{     | <octet like predicate>                                                 }
{                                                                              }
{ SQL2003:                                                                     }
{ <character like predicate> ::=                                               }
{     <row value predicand> <character like predicate part 2>                  }
{ <character like predicate part 2> ::=                                        }
{     [ NOT ] LIKE <character pattern> [ ESCAPE <escape character> ]           }
{ <octet like predicate> ::=                                                   }
{     <row value predicand> <octet like predicate part 2>                      }
{ <octet like predicate part 2> ::=                                            }
{     [ NOT ] LIKE <octet pattern> [ ESCAPE <escape octet> ]                   }
{ <escape character> ::= !! See the Syntax Rules                               }
function TSqlParser.ParseLikePredicate(const RowValue: ASqlValueExpression;
    const NotPredicate: Boolean): TSqlLikeCondition;
begin
  Assert(Assigned(RowValue));
  Assert(FTokenType = ttLIKE);
  GetNextToken;
  Result := TSqlLikeCondition.Create;
  with Result do
    try
      MatchValue := RowValue;
      NotLike := NotPredicate;
      Pattern := ExpectCharacterValueExpression;
      if SkipToken(ttESCAPE) then
        EscapeChar := ExpectCharacterValueExpression;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <exists predicate> ::=                                                       }
{     EXISTS <table subquery>                                                  }
{                                                                              }
{ EXT:                                                                         }
{ <exists predicate> ::=                                                       }
{       EXISTS <table subquery>                                                }
{     | EXISTS ( TABLE | INDEX | PROCEDURE | DATABASE | VIEW ) <identifier>    }
function TSqlParser.ParseExistsPredicate: ASqlSearchCondition;
var T : TSqlExistsStructureType;
begin
  Assert(FTokenType = ttEXISTS);
  GetNextToken;
  T := sesUndefined;
  if spoExtendedSyntax in FOptions then
    case FTokenType of
      ttTABLE      : T := sesTable;
      ttINDEX      : T := sesIndex;
      ttPROCEDURE,
      ttPROC       : T := sesProcedure;
      ttDATABASE   : T := sesDatabase;
      ttVIEW       : T := sesView;
    end;
  if T <> sesUndefined then
    begin
      GetNextToken;
      Result := TSqlExistsStructureCondition.CreateEx(T, ExpectIdentifier);
    end
  else
    Result := TSqlExistsCondition.CreateEx(ExpectTableSubQuery(False))
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <unique predicate> ::= UNIQUE <table subquery>                               }
function TSqlParser.ParseUniquePredicate: TSqlUniqueCondition;
begin
  Assert(FTokenType = ttUNIQUE);
  GetNextToken;
  Result := TSqlUniqueCondition.CreateEx(ExpectTableSubQuery(False))
end;

{ SQL92:                                                                       }
{ <null predicate> ::= <row value constructor> IS [ NOT ] NULL                 }
{                                                                              }
{ SQL99:                                                                       }
{ <null predicate> ::= <row value expression> IS [ NOT ] NULL                  }
{                                                                              }
{ SQL2003:                                                                     }
{ <null predicate> ::= <row value predicand> <null predicate part 2>           }
{ <null predicate part 2> ::= IS [ NOT ] NULL                                  }
function TSqlParser.ParseNullPredicate(const RowValue: ASqlValueExpression; const NotNull: Boolean): TSqlNullCondition;
begin
  Assert(Assigned(RowValue));
  Assert(FTokenType = ttNULL);
  GetNextToken;
  Result := TSqlNullCondition.CreateEx(RowValue, NotNull);
end;

{ SQL99:                                                                       }
{ <distinct predicate> ::=                                                     }
{     <row value expression 3> IS DISTINCT FROM <row value expression 4>       }
{ <row value expression 3> ::= <row value expression>                          }
{ <row value expression 4> ::= <row value expression>                          }
{                                                                              }
{ SQL2003:                                                                     }
{ <distinct predicate> ::=                                                     }
{     <row value predicand 3> <distinct predicate part 2>                      }
{ <distinct predicate part 2> ::= IS DISTINCT FROM <row value predicand 4>     }
{ <row value predicand 3> ::= <row value predicand>                            }
{ <row value predicand 4> ::= <row value predicand>                            }
function TSqlParser.ParseDistinctPredicate(const RowValue: ASqlValueExpression): TSqlDistinctPredicate;
var E : ASqlValueExpression;
begin
  Assert(Assigned(RowValue));
  Assert(FTokenType = ttDISTINCT);
  GetNextToken;
  ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);
  E := ExpectRowValueExpression;
  Result := TSqlDistinctPredicate.CreateEx(RowValue, E);
end;

{ SQL99:                                                                       }
{ <user-defined type specification> ::=                                        }
{       <inclusive user-defined type specification>                            }
{     | <exclusive user-defined type specification>                            }
{ <inclusive user-defined type specification> ::= <user-defined type>          }
{ <exclusive user-defined type specification> ::= ONLY <user-defined type>     }
function TSqlParser.ParseUserDefinedTypeSpecification: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <type list> ::=                                                              }
{       <user-defined type specification>                                      }
{       [ ( <comma> <user-defined type specification> )... ]                   }
function TSqlParser.ParseTypeList: TObject;
begin
  ParseUserDefinedTypeSpecification;
  while SkipToken(ttComma) do
    ParseUserDefinedTypeSpecification;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <type predicate> ::=                                                         }
{     <user-defined type value expression> IS [ NOT ] OF <left paren>          }
{     <type list> <right paren>                                                }
{                                                                              }
{ SQL2003:                                                                     }
{ <type predicate> ::=                                                         }
{     <row value predicand> <type predicate part 2>                            }
{ <type predicate part 2> ::=                                                  }
{     IS [ NOT ] OF <left paren> <type list> <right paren>                     }
function TSqlParser.ParseTypePredicate(const RowValue: ASqlValueExpression; const NotOf: Boolean): ASqlSearchCondition;
begin
  Assert(Assigned(RowValue));
  Assert(FTokenType = ttOF);
  GetNextToken;
  ExpectLeftParen;
  //
  Result := nil;
end;

{ EXT:                                                                         }
{ <is predicate> ::=                                                           }
{       <null predicate>                                                       }
{     | <distinct predicate>                                                   }
{     | <type predicate>                                                       }
{                                                                              }
{ SQL99:                                                                       }
{ <distinct predicate> ::=                                                     }
{     <row value expression 3> IS DISTINCT FROM <row value expression 4>       }
{ <row value expression 3> ::= <row value expression>                          }
{ <row value expression 4> ::= <row value expression>                          }
{                                                                              }
{ SQL2003:                                                                     }
{ <distinct predicate> ::=                                                     }
{     <row value predicand 3> <distinct predicate part 2>                      }
{ <distinct predicate part 2> ::= IS DISTINCT FROM <row value predicand 4>     }
{ <row value predicand 3> ::= <row value predicand>                            }
{ <row value predicand 4> ::= <row value predicand>                            }
function TSqlParser.ParseIsPredicate(const RowValue: ASqlValueExpression): ASqlSearchCondition;
var N : Boolean;
begin
  Assert(Assigned(RowValue));
  Assert(FTokenType = ttIS);
  GetNextToken;
  N := SkipToken(ttNOT);
  Result := nil;
  case FTokenType of
    ttNULL     : Result := ParseNullPredicate(RowValue, N);
    ttDISTINCT : if N then
                   ParseError('NOT not allowed for DISTINCT predicate')
                 else
                   Result := ParseDistinctPredicate(RowValue);
    ttOF       : Result := ParseTypePredicate(RowValue, N);
  else
    ParseError('Invalid IS predicate');
  end;
end;

{ SQL92:                                                                       }
{ <match predicate> ::= <row value constructor> MATCH [ UNIQUE ]               }
{     [ PARTIAL | FULL ] <table subquery>                                      }
{                                                                              }
{ SQL99:                                                                       }
{ <match predicate> ::=                                                        }
{     <row value expression> MATCH [ UNIQUE ] [ SIMPLE | PARTIAL | FULL ]      }
{     <table subquery>                                                         }
{                                                                              }
{ SQL2003:                                                                     }
{ <match predicate> ::=                                                        }
{     <row value predicand> <match predicate part 2>                           }
{ <match predicate part 2> ::=                                                 }
{     MATCH [ UNIQUE ] [ SIMPLE | PARTIAL | FULL ] <table subquery>            }
function TSqlParser.ParseMatchPredicate(const RowValue: ASqlValueExpression): TSqlMatchPredicate;
begin
  Assert(Assigned(RowValue));
  Assert(FTokenType = ttMATCH);
  GetNextToken;
  Result := TSqlMatchPredicate.Create;
  with Result do
    try
      Expr := RowValue;
      Unique := SkipToken(ttUNIQUE);
      case FTokenType of
        ttPARTIAL : MatchType := smpPartial;
        ttFULL    : MatchType := smpFull;
      else
        MatchType := smpUndefined;
      end;
      if MatchType <> smpUndefined then
        GetNextToken;
      TableSubQuery := ExpectTableSubQuery(False);
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <overlaps predicate> ::=                                                     }
{     <row value constructor 1> OVERLAPS <row value constructor 2>             }
{ <row value constructor 1> ::= <row value constructor>                        }
{ <row value constructor 2> ::= <row value constructor>                        }
{                                                                              }
{ SQL99:                                                                       }
{ <overlaps predicate> ::=                                                     }
{     <row value expression 1> OVERLAPS <row value expression 2>               }
{ <row value expression 1> ::= <row value expression>                          }
{ <row value expression 2> ::= <row value expression>                          }
{                                                                              }
{ SQL2003:                                                                     }
{ <overlaps predicate> ::=                                                     }
{     <overlaps predicate part 1> <overlaps predicate part 2>                  }
{ <overlaps predicate part 1> ::= <row value predicand 1>                      }
{ <overlaps predicate part 2> ::= OVERLAPS <row value predicand 2>             }
{ <row value predicand 1> ::= <row value predicand>                            }
{ <row value predicand 2> ::= <row value predicand>                            }
function TSqlParser.ParseOverlapsPredicate(const RowValue: ASqlValueExpression): TSqlOverlapsPredicate;
begin
  Assert(Assigned(RowValue));
  Assert(FTokenType = ttOVERLAPS);
  GetNextToken;
  Result := TSqlOverlapsPredicate.Create;
  with Result do
    try
      Expr1 := RowValue;
      Expr2 := ExpectRowValue;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL99:                                                                       }
{ <character match value> ::= <character value expression>                     }

{ SQL99:                                                                       }
{ <similar pattern> ::= <character value expression>                           }

{ SQL99:                                                                       }
{ <similar predicate> ::=                                                      }
{       <character match value> [ NOT ] SIMILAR TO                             }
{       <similar pattern> [ ESCAPE <escape character> ]                        }
function TSqlParser.ParseSimilarPredicate(const RowValue: ASqlValueExpression): TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <regular expression> define the structure that the                           }
{ <character value expression> used in <similar pattern> must have.            }
{ <regular expression> ::=                                                     }
{       <regular term>                                                         }
{     | <regular expression> <vertical bar> <regular term>                     }
{ <regular term> ::=                                                           }
{       <regular factor>                                                       }
{     | <regular term> <regular factor>                                        }
{ <regular factor> ::=                                                         }
{       <regular primary>                                                      }
{     | <regular primary> <asterisk>                                           }
{     | <regular primary> <plus sign>                                          }
{ <regular primary> ::=                                                        }
{       <character specifier>                                                  }
{     | <percent>                                                              }
{     | <regular character set>                                                }
{     | <left paren> <regular expression> <right paren>                        }
{ <character specifier> ::= <non-escaped character> | <escaped character>      }
{ <non-escaped character> ::= !! (See the Syntax Rules)                        }
{ <escaped character> ::= !! (See the Syntax Rules)                            }
{ <regular character set> ::=                                                  }
{       <underscore>                                                           }
{     | <left bracket> <character enumeration>... <right bracket>              }
{     | <left bracket> <circumflex> <character enumeration>... <right bracket> }
{     | <left bracket> <colon> <regular character set identifier> <colon>      }
{       <right bracket>                                                        }
{ <character enumeration> ::=                                                  }
{       <character specifier>                                                  }
{     | <character specifier> <minus sign> <character specifier>               }
{ <regular character set identifier> ::= <identifier>                          }

{ SQL2003:                                                                     }
{ <normalized predicate> ::= <string value expression> IS [ NOT ] NORMALIZED   }
function TSqlParser.ParseNormalizedPredicate: ASqlSearchCondition;
begin
  //// SkipToken(ttNORMALIZED);
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <member predicate> ::= <row value predicand> <member predicate part 2>       }
{ <member predicate part 2> ::=                                                }
{     [ NOT ] MEMBER [ OF ] <multiset value expression>                        }
function TSqlParser.ParseMemberPredicate: ASqlSearchCondition;
begin
  //// SkipToken(ttMEMBER);
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <submultiset predicate> ::=                                                  }
{     <row value predicand> <submultiset predicate part 2>                     }
{ <submultiset predicate part 2> ::=                                           }
{     [ NOT ] SUBMULTISET [ OF ] <multiset value expression>                   }
function TSqlParser.ParseSubMultisetPredicate: ASqlSearchCondition;
begin
  //// SkipToken(ttSUBMULTISET);
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <set predicate> ::= <row value predicand> <set predicate part 2>             }
{ <set predicate part 2> ::= IS [ NOT ] A SET                                  }
function TSqlParser.ParseSetPredicate: ASqlSearchCondition;
begin
  SkipToken(ttIS);
  SkipToken(ttNOT);
  //// SkipToken(ttA);
  SkipToken(ttSET);
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <predicate> ::=                                                              }
{       <comparison predicate>                                                 }
{     | <between predicate>                                                    }
{     | <in predicate>                                                         }
{     | <like predicate>                                                       }
{     | <null predicate>                                                       }
{     | <quantified comparison predicate>                                      }
{     | <exists predicate>                                                     }
{     | <unique predicate>                                                     }
{     | <match predicate>                                                      }
{     | <overlaps predicate>                                                   }
{                                                                              }
{ SQL99:                                                                       }
{ <predicate> ::=                                                              }
{       <comparison predicate>                                                 }
{     | <between predicate>                                                    }
{     | <in predicate>                                                         }
{     | <like predicate>                                                       }
{     | <null predicate>                                                       }
{     | <quantified comparison predicate>                                      }
{     | <exists predicate>                                                     }
{     | <unique predicate>                                                     }
{     | <match predicate>                                                      }
{     | <overlaps predicate>                                                   }
{     | <similar predicate>                                                    }
{     | <distinct predicate>                                                   }
{     | <type predicate>                                                       }
{                                                                              }
{ SQL2003:                                                                     }
{ <predicate> ::=                                                              }
{       <comparison predicate>                                                 }
{     | <between predicate>                                                    }
{     | <in predicate>                                                         }
{     | <like predicate>                                                       }
{     | <similar predicate>                                                    }
{     | <null predicate>                                                       }
{     | <quantified comparison predicate>                                      }
{     | <exists predicate>                                                     }
{     | <unique predicate>                                                     }
{     | <normalized predicate>                                                 }
{     | <match predicate>                                                      }
{     | <overlaps predicate>                                                   }
{     | <distinct predicate>                                                   }
{     | <member predicate>                                                     }
{     | <submultiset predicate>                                                }
{     | <set predicate>                                                        }
{     | <type predicate>                                                       }
function TSqlParser.ParsePredicate: ASqlSearchCondition;
var E : ASqlValueExpression;
    R : Boolean;
    N : Boolean;
begin
  Result := nil;
  R := True;
  case FTokenType of
    ttEXISTS : Result := ParseExistsPredicate;
    ttUNIQUE : Result := ParseUniquePredicate;
  else
    R := False;
  end;
  if R then
    exit;
  E := ParseRowValue;
  if not Assigned(E) then
    exit;
  case FTokenType of
    ttIS       : Result := ParseIsPredicate(E);
    ttMATCH    : Result := ParseMatchPredicate(E);
    ttOVERLAPS : Result := ParseOverlapsPredicate(E);
  end;
  if Assigned(Result) then
    exit;
  N := SkipToken(ttNOT);
  case FTokenType of
    ttBETWEEN : Result := ParseBetweenPredicate(E, N);
    ttIN      : Result := ParseInPredicate(E, N);
    ttLIKE    : Result := ParseLikePredicate(E, N);
  else
    if N then
      UnexpectedToken;
  end;
  if Assigned(Result) then
    exit;
  Result := ParseComparisonPredicate(E);
  if not Assigned(Result) then
    ParseError('Predicate expected');
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <truth value> ::= TRUE | FALSE | UNKNOWN                                     }
function TSqlParser.ParseTruthValue: TSqlTruthValue;
begin
  Result := stvUndefined;
  case FTokenType of
    ttTRUE    : Result := stvTrue;
    ttFALSE   : Result := stvFalse;
    ttUNKNOWN : Result := stvUnknown;
  else
    ParseError('Truth value expected');
  end;
end;

{ SQL2003:                                                                     }
{ <window function type> ::=                                                   }
{       <rank function type> <left paren> <right paren>                        }
{     | ROW_NUMBER <left paren> <right paren>                                  }
{     | <aggregate function>                                                   }
function TSqlParser.ParseWindowFunctionType: TObject;
begin
  ParseRankFunctionType;
  ParseAggregateFunction;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window name> ::= <identifier>                                               }
function TSqlParser.ParseWindowName: AnsiString;
begin
  Result := ExpectIdentifier;
end;

{ SQL2003:                                                                     }
{ <existing window name> ::= <window name>                                     }
function TSqlParser.ParseExistingWindowName: AnsiString;
begin
  Result := ParseWindowName;
end;

{ SQL2003:                                                                     }
{ <window partition column reference> ::=                                      }
{     <column reference> [ <collate clause> ]                                  }
function TSqlParser.ParseWindowPartitionColumnReference: ASqlValueExpression;
begin
  Result := ParseColumnReference;
  ParseCollateClause;
end;

{ SQL2003:                                                                     }
{ <window partition column reference list> ::=                                 }
{     <window partition column reference>                                      }
{     [ ( <comma> <window partition column reference> )... ]                   }
function TSqlParser.ParseWindowPartitionColumnReferenceList: ASqlValueExpressionArray;
begin
  //// Result := ParseColumnReference;
  ParseCollateClause;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window partition clause> ::=                                                }
{     PARTITION BY <window partition column reference list>                    }
function TSqlParser.ParseWindowPartitionClause: TObject;
begin
  SkipToken(ttPARTITION);
  SkipToken(ttBY);
  ParseWindowPartitionColumnReferenceList;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window order clause> ::= ORDER BY <sort specification list>                 }
function TSqlParser.ParseWindowOrderClause: TObject;
begin
  SkipToken(ttORDER);
  SkipToken(ttBY);
  ParseSortSpecificationList;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window frame units> ::= ROWS | RANGE                                        }
function TSqlParser.ParseWindowFrameUnits: Integer;
begin
  //// TODO
  Result := -1;
  case FTokenType of
    ttROWS  : ;
    ttRANGE : ;
  else
    Result := -1;
  end;
end;

{ SQL2003:                                                                     }
{ <window frame preceding> ::= <unsigned value specification> PRECEDING        }
function TSqlParser.ParseWindowFramePreceding: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window frame start> ::= UNBOUNDED PRECEDING | <window frame preceding> | CURRENT ROW }
function TSqlParser.ParseWindowFrameStart: TObject;
begin
  //// SkipToken(ttUNBOUNDED);
  //// SkipToken(ttPRECEDING);
  ParseWindowFramePreceding;
  SkipToken(ttCURRENT);
  SkipToken(ttROW);
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window frame following> ::= <unsigned value specification> FOLLOWING        }
function TSqlParser.ParseWindowFrameFollowing: TObject;
begin
  ParseUnsignedValueSpecification;
  //// SkipToken(ttFOLLOWING);
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window frame bound> ::=                                                     }
{       <window frame start>                                                   }
{     | UNBOUNDED FOLLOWING                                                    }
{     | <window frame following>                                               }
function TSqlParser.ParseWindowFrameBound: TObject;
begin
  ParseWindowFrameStart;
  //// SkipToken(ttUNBOUNDED);
  //// SkipToken(ttFOLLOWING);
  ParseWindowFrameFollowing;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window frame exclusion> ::=                                                 }
{       EXCLUDE CURRENT ROW                                                    }
{     | EXCLUDE GROUP                                                          }
{     | EXCLUDE TIES                                                           }
{     | EXCLUDE NO OTHERS                                                      }
function TSqlParser.ParseWindowFrameExclusion: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window frame between> ::=                                                   }
{     BETWEEN <window frame bound 1> AND <window frame bound 2>                }
{ <window frame bound 1> ::= <window frame bound>                              }
{ <window frame bound 2> ::= <window frame bound>                              }
function TSqlParser.ParseWindowFrameBetween: TObject;
begin
  SkipToken(ttBETWEEN);
  ParseWindowFrameBound;
  ParseWindowFrameBound;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window frame extent> ::= <window frame start> | <window frame between>      }
function TSqlParser.ParseWindowFrameExtent: TObject;
begin
  ParseWindowFrameStart;
  ParseWindowFrameBetween;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window frame clause> ::=                                                    }
{     <window frame units> <window frame extent> [ <window frame exclusion> ]  }
function TSqlParser.ParseWindowFrameClause: TObject;
begin
  ParseWindowFrameUnits;
  ParseWindowFrameExtent;
  ParseWindowFrameExclusion;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window specification details> ::=                                           }
{     [ <existing window name> ]                                               }
{     [ <window partition clause> ]                                            }
{     [ <window order clause> ]                                                }
{     [ <window frame clause> ]                                                }
function TSqlParser.ParseWindowSpecificationDetails: TObject;
begin
  ParseExistingWindowName;
  ParseWindowPartitionClause;
  ParseWindowOrderClause;
  ParseWindowFrameClause;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window specification> ::=                                                   }
{     <left paren> <window specification details> <right paren>                }
function TSqlParser.ParseWindowSpecification: TObject;
begin
  ParseWindowSpecificationDetails;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <in-line window specification> ::= <window specification>                    }
function TSqlParser.ParseInlineWindowSpecification: TObject;
begin
  Result := ParseWindowSpecification;
end;

{ SQL2003:                                                                     }
{ <window name or specification> ::=                                           }
{     <window name> | <in-line window specification>                           }
function TSqlParser.ParseWindowNameOrSpecification: TObject;
begin
  ParseWindowName;
  ParseInlineWindowSpecification;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window function> ::=                                                        }
{     <window function type> OVER <window name or specification>               }
function TSqlParser.ParseWindowFunction: ASqlSearchCondition;
begin
  ParseWindowFunctionType;
  ParseWindowNameOrSpecification;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <boolean primary> ::=                                                        }
{       <predicate>                                                            }
{     | <left paren> <search condition> <right paren>                          }
{                                                                              }
{ SQL99:                                                                       }
{ <boolean primary> ::=                                                        }
{       <predicate>                                                            }
{     | <parenthesized boolean value expression>                               }
{     | <nonparenthesized value expression primary>                            }
{                                                                              }
{ SQL2003:                                                                     }
{ <boolean primary> ::=                                                        }
{       <predicate>                                                            }
{     | <boolean predicand>                                                    }
function TSqlParser.ParseBooleanPrimary: ASqlSearchCondition;
begin
  if FCompatibility = spcSql92 then
    begin
      if SkipToken(ttLeftParen) then
        begin
          Result := ExpectSearchCondition;
          ExpectRightParen;
        end
      else
        Result := ParsePredicate;
      exit;
    end;
  Assert(FCompatibility >= spcSql99);
  {
  case FTokenType of
    ttCAST : ParseCastSpecification
  }
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <boolean test> ::= <boolean primary> [ IS [ NOT ] <truth value> ]            }
function TSqlParser.ParseBooleanTest: ASqlSearchCondition;
var T : TSqlBooleanTest;
begin
  Result := ParseBooleanPrimary;
  if SkipToken(ttIS) then
    begin
      T := TSqlBooleanTest.Create;
      with T do
        try
          Condition := Result;
          NotValue := SkipToken(ttNOT);
          TruthValue := ParseTruthValue;
        except
          T.Free;
          raise;
        end;
      Result := T;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <boolean factor> ::= [ NOT ] <boolean test>                                  }
function TSqlParser.ParseBooleanFactor: ASqlSearchCondition;
var N : Boolean;
begin
  N := False;
  while SkipToken(ttNOT) do
    N := not N;
  Result := ParseBooleanTest;
  if N then
    Result := TSqlLogicalNotCondition.CreateEx(Result);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <boolean term> ::=                                                           }
{       <boolean factor>                                                       }
{     | <boolean term> AND <boolean factor>                                    }
function TSqlParser.ParseBooleanTerm: ASqlSearchCondition;
begin
  Result := ParseBooleanFactor;
  while SkipToken(ttAND) do
    Result := TSqlLogicalAndCondition.CreateEx(Result, ParseBooleanFactor);
end;

{ SQL92:                                                                       }
{ <search condition> ::=                                                       }
{       <boolean term>                                                         }
{     | <search condition> OR <boolean term>                                   }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <search condition> ::=                                                       }
{     <boolean value expression>                                               }
function TSqlParser.ParseSearchCondition: ASqlSearchCondition;
begin
  Result := ParseBooleanTerm;
  while SkipToken(ttOR) do
    Result := TSqlLogicalOrCondition.CreateEx(Result, ParseBooleanTerm);
end;

function TSqlParser.ExpectSearchCondition: ASqlSearchCondition;
begin
  Result := ParseSearchCondition;
  if not Assigned(Result) then
    ParseError('Search condition expected');
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <grouping column reference> ::= <column reference> [ <collate clause> ]      }
function TSqlParser.ParseGroupingColumnReference: TSqlGroupingColumnReference;
begin
  Result := TSqlGroupingColumnReference.Create;
  with Result do
    try
      ColumnRef := ParseColumnReference;
      Collate := ParseCollateClause;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL2003:                                                                     }
{ <empty grouping set> ::= <left paren> <right paren>                          }
function TSqlParser.ParseEmptyGroupingSet: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <grouping sets specification> ::=                                            }
{     GROUPING SETS <left paren> <grouping set list> <right paren>             }
function TSqlParser.ParseGroupingSetsSpecification: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <cube list> ::= CUBE <left paren> <ordinary grouping set list> <right paren> }
function TSqlParser.ParseCubeList: TObject;
begin
  SkipToken(ttCUBE);
  //// ParseOrdinaryGroupingSetList;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <rollup list> ::=                                                            }
{     ROLLUP <left paren> <ordinary grouping set list> <right paren>           }
{ <ordinary grouping set list> ::=                                             }
{     <ordinary grouping set> [ ( <comma> <ordinary grouping set> )... ]       }
function TSqlParser.ParseRollupList: TObject;
begin
  SkipToken(ttROLLUP);
  //// ParseOrdinaryGroupingSetList;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <ordinary grouping set> ::=                                                  }
{       <grouping column reference>                                            }
{     | <left paren> <grouping column reference list> <right paren>            }
function TSqlParser.ParseOrdinaryGroupingSet: TObject;
begin
  ParseGroupingColumnReference;
  //// ParseGroupingColumnReferenceList;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <grouping element> ::=                                                       }
{	      <ordinary grouping set>                                                }
{     | <rollup list>                                                          }
{     | <cube list>                                                            }
{     | <grouping sets specification>                                          }
{     | <grand total>                                                          }
{                                                                              }
{ SQL2003:                                                                     }
{ <grouping element> ::=                                                       }
{       <ordinary grouping set>                                                }
{     | <rollup list>                                                          }
{     | <cube list>                                                            }
{     | <grouping sets specification>                                          }
{     | <empty grouping set>                                                   }
function TSqlParser.ParseGroupingElement: TObject;
begin
  ParseOrdinaryGroupingSet;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <grouping element list> ::=                                                  }
{     <grouping element> [ ( <comma> <grouping element> )... ]                 }
function TSqlParser.ParseGroupingElementList: TObject;
begin
  ParseGroupingElement;
  while SkipToken(ttComma) do
    ParseGroupingElement;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <group by clause> ::= GROUP BY <grouping column reference list>              }
{ <grouping column reference list> ::=                                         }
{     <grouping column reference>                                              }
{         [ ( <comma> <grouping column reference> )... ]                       }
{                                                                              }
{ SQL99:                                                                       }
{ <group by clause> ::= GROUP BY <grouping element list>                       }
{                                                                              }
{ SQL2003:                                                                     }
{ <group by clause> ::=                                                        }
{     GROUP BY [ <set quantifier> ] <grouping element list>                    }
function TSqlParser.ParseGroupByClause: TSqlGroupByClause;
var G : TSqlGroupingColumnReferenceArray;
begin
  if SkipToken(ttGROUP) then
    begin
      ExpectKeyword(ttBY, SQL_KEYWORD_BY);
      Result := TSqlGroupByClause.Create;
      try
        try
          Append(ObjectArray(G), ParseGroupingColumnReference);
          while SkipToken(ttComma) do
            Append(ObjectArray(G), ParseGroupingColumnReference);
        except
          FreeObjectArray(G);
          raise;
        end;
        Result.ColumnRefs := G;
      except
        Result.Free;
        raise;
      end;
    end
  else
    Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <table reference list> ::=                                                   }
{     <table reference> [ ( <comma> <table reference> )... ]                   }
function TSqlParser.ParseTableReferenceList: TObject;
begin
  ParseTableReference;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <from clause> ::= FROM <table reference>                                     }
{     [ ( <comma> <table reference> )... ]                                     }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <from clause> ::= FROM <table reference list>                                }
function TSqlParser.ParseFromClause: ASqlQueryExpression;
var Q : ASqlQueryExpressionArray;
begin
  ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);
  Result := ParseTableReference;
  if SkipToken(ttComma) then
    begin
      try
        Append(ObjectArray(Q), Result);
        repeat
          Append(ObjectArray(Q), ParseTableReference);
        until not SkipToken(ttComma);
      except
        FreeObjectArray(Q);
        raise;
      end;
      Result := TSqlFromMultipleQuery.CreateEx(Q);
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <where clause> ::= WHERE <search condition>                                  }
function TSqlParser.ParseWhereClause: ASqlSearchCondition;
begin
  if SkipToken(ttWHERE) then
    Result := ExpectSearchCondition
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <having clause> ::= HAVING <search condition>                                }
function TSqlParser.ParseHavingClause: ASqlSearchCondition;
begin
  if SkipToken(ttHAVING) then
    Result := ExpectSearchCondition
  else
    Result := nil;
end;

{ SQL2003:                                                                     }
{ <window definition> ::= <new window name> AS <window specification>          }
{ <new window name> ::= <window name>                                          }
function TSqlParser.ParseWindowDefinition: TObject;
begin
  ParseWindowSpecification;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window definition list> ::=                                                 }
{     <window definition> [ ( <comma> <window definition> )... ]               }
function TSqlParser.ParseWindowDefinitionList: TObject;
begin
  ParseWindowDefinition;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <window clause> ::= WINDOW <window definition list>                          }
function TSqlParser.ParseWindowClause: ASqlSearchCondition;
begin
  if SkipToken(ttWINDOW) then
    begin
      ParseWindowDefinitionList;
      //// TODO
      Result := nil;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <table expression> ::=                                                       }
{     <from clause>                                                            }
{     [ <where clause> ]                                                       }
{     [ <group by clause> ]                                                    }
{     [ <having clause> ]                                                      }
{                                                                              }
{ SQL2003:                                                                     }
{ <table expression> ::=                                                       }
{     <from clause>                                                            }
{     [ <where clause> ]                                                       }
{     [ <group by clause> ]                                                    }
{     [ <having clause> ]                                                      }
{     [ <window clause> ]                                                      }
function TSqlParser.ParseTableExpression: TSqlTableExpression;
begin
  Result := TSqlTableExpression.Create;
  with Result do
    try
      FromTable := ParseFromClause;
      Where := ParseWhereClause;
      GroupBy := ParseGroupByClause;
      Having := ParseHavingClause;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <query specification> ::=                                                    }
{     SELECT [ <set quantifier> ] <select list>                                }
{       <table expression>                                                     }
{ <select statement: single row> ::=                                           }
{     SELECT [ <set quantifier> ] <select list>                                }
{       INTO <select target list>                                              }
{       <table expression>                                                     }
function TSqlParser.ParseQuerySpecification(const AllowIntoClause: Boolean): TSqlQueryExpression;
begin
  if SkipToken(ttSELECT) then
    begin
      Result := TSqlQueryExpression.Create;
      with Result do
        try
          Quantifier := ParseSetQuantifier;
          SelectList := ParseSelectList;
          if AllowIntoClause then
            if SkipToken(ttINTO) then
              Into := ParseSelectTargetList;
          if FTokenType = ttFROM then
            TableExpr := ParseTableExpression
          else
            TableExpr := nil;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL92:                                                                       }
{ <table value constructor list> ::=                                           }
{     <row value constructor> [ ( <comma> <row value constructor> )... ]       }
{                                                                              }
{ SQL99: not used                                                              }
function TSqlParser.ParseTableValueConstructorList: TSqlTableValueConstructor;
var R : ASqlValueExpressionArray;
begin
  try
    Append(ObjectArray(R), ExpectRowValueConstructor);
    while SkipToken(ttComma) do
      Append(ObjectArray(R), ExpectRowValueConstructor);
  except
    FreeObjectArray(R);
    raise;
  end;
  Result := TSqlTableValueConstructor.CreateEx(R);
end;

{ SQL2003:                                                                     }
{ <table row value expression> ::=                                             }
{       <row value special case>                                               }
{     |	<row value constructor>                                                }
function TSqlParser.ParseTableRowValueExpression: TObject;
begin
  ParseRowValueSpecialCase;
  ParseRowValueConstructor;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <row value expression list> ::=                                              }
{     <row value expression>                                                   }
{         [ ( <comma> <row value expression> )... ]                            }
{                                                                              }
{ SQL2003:                                                                     }
{ <row value expression list> ::=                                              }
{     <table row value expression>                                             }
{         [ ( <comma> <table row value expression> )... ]                      }
function TSqlParser.ParseRowValueExprssionList: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <table value constructor> ::=                                                }
{     VALUES <table value constructor list>                                    }
{                                                                              }
{ SQL99:                                                                       }
{ <table value constructor> ::=                                                }
{     VALUES <row value expression list>                                       }
{                                                                              }
{ SQL2003:                                                                     }
{ <table value constructor> ::=                                                }
{     VALUES <row value expression list>                                       }
function TSqlParser.ParseTableValueConstructor: ASqlQueryExpression;
begin
  if SkipToken(ttVALUES) then
    Result := ParseTableValueConstructorList
  else
    Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <explicit table> ::= TABLE <table name>                                      }
{                                                                              }
{ SQL2003:                                                                     }
{ <explicit table> ::= TABLE <table or query name>                             }
function TSqlParser.ParseExplicitTable: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <simple table> ::=                                                           }
{       <query specification>                                                  }
{     | <table value constructor>                                              }
{     | <explicit table>                                                       }
function TSqlParser.ParseSimpleTable(const IsStatement: Boolean): ASqlQueryExpression;
begin
  Result := ParseQuerySpecification(IsStatement);
  if Assigned(Result) then
    exit;
  Result := ParseTableValueConstructor;
  if Assigned(Result) then
    exit;
  if SkipToken(ttTABLE) then
    Result := TSqlExplicitTable.CreateEx(ExpectIdentifier);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <query term> ::=                                                             }
{       <non-join query term>                                                  }
{     | <joined table>                                                         }
function TSqlParser.ParseQueryTerm: ASqlQueryExpression;
begin
  Result := ParseNonJoinQueryTerm;
  if Assigned(Result) then
    exit;
  Result := ParseJoinedTable(nil);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <query primary> ::=                                                          }
{       <non-join query primary>                                               }
{     | <joined table>                                                         }
function TSqlParser.ParseQueryPrimary: ASqlQueryExpression;
begin
  Result := ParseNonJoinQueryPrimary(False);
  if Assigned(Result) then
    exit;
  Result := ParseJoinedTable(nil);
end;

{ SQL92:                                                                       }
{ <non-join query term> ::=                                                    }
{       <non-join query primary>                                               }
{     | <query term> INTERSECT [ ALL ]                                         }
{           [ <corresponding spec> ] <query primary>                           }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <non-join query term> ::=                                                    }
{       <non-join query primary>                                               }
{     | <query term> INTERSECT [ ALL | DISTINCT ]                              }
{           [ <corresponding spec> ] <query primary>                           }
function TSqlParser.ParseNonJoinQueryTerm(const IsStatement: Boolean): ASqlQueryExpression;
var R : TSqlIntersectQueryExpression;
begin
  Result := ParseNonJoinQueryPrimary(IsStatement);
  if not Assigned(Result) then
    exit;
  if SkipToken(ttINTERSECT) then
    begin
      R := TSqlIntersectQueryExpression.Create;
      with R do
        try
          Query1 := Result;
          All := SkipToken(ttALL);
          Corresponding := ParseCorrespondingSpec;
          Query2 := ParseQueryPrimary;
          Result := R;
        except
          R.Free;
          raise;
        end;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <corresponding spec> ::= CORRESPONDING                                       }
{     [ BY <left paren> <corresponding column list> <right paren> ]            }
{ <corresponding column list> ::= <column name list>                           }
function TSqlParser.ParseCorrespondingSpec: TSqlCorrespondingSpec;
begin
  if SkipToken(ttCORRESPONDING) then
    begin
      Result := TSqlCorrespondingSpec.Create;
      try
        if SkipToken(ttBY) then
          begin
            ExpectLeftParen;
            Result.ColumnNames := ParseColumnNameList;
            ExpectRightParen;
          end;
      except
        Result.Free;
        raise;
      end;
    end
  else
     Result := nil;
end;

{ SQL92:                                                                       }
{ <non-join query expression> ::=                                              }
{     <non-join query term>                                                    }
{   | <query expression> UNION  [ ALL ] [ <corresponding spec> ] <query term>  }
{   | <query expression> EXCEPT [ ALL ] [ <corresponding spec> ] <query term>  }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <non-join query expression> ::=                                              }
{     <non-join query term>                                                    }
{   | <query expression body> UNION  [ ALL | DISTINCT ] [ <corresponding spec> ] <query term> }
{   |	<query expression body> EXCEPT [ ALL | DISTINCT ] [ <corresponding spec> ] <query term> }
{ <query expression body> ::= <non-join query expression> | <joined table>     }
function TSqlParser.ParseNonJoinQueryExpression(const IsStatement: Boolean): ASqlQueryExpression;
var R : TSqlUnionQueryExpression;
begin
  Result := ParseNonJoinQueryTerm(IsStatement);
  if not Assigned(Result) then
    exit;
  if FTokenType in [ttUNION, ttEXCEPT] then
    begin
      R := TSqlUnionQueryExpression.Create;
      with R do
        try
          Query1 := Result;
          case FTokenType of
            ttUNION  : UnionType := sutUnion;
            ttEXCEPT : UnionType := sutExcept;
          end;
          GetNextToken;
          All := SkipToken(ttALL);
          Corresponding := ParseCorrespondingSpec;
          Query2 := ParseQueryTerm;
        except
          R.Free;
          raise;
        end;
      Result := R;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <non-join query primary> ::=                                                 }
{       <simple table>                                                         }
{     | <left paren> <non-join query expression> <right paren>                 }
function TSqlParser.ParseNonJoinQueryPrimary(const IsStatement: Boolean): ASqlQueryExpression;
begin
  Result := ParseSimpleTable(IsStatement);
  if Assigned(Result) then
    exit;
  if SkipToken(ttLeftParen) then
    begin
      Result := ParseNonJoinQueryExpression;
      ExpectRightParen;
    end;
end;

{ SQL92:                                                                       }
{ ::= [ AS ] <correlation name>                                                }
{ <correlation name> ::= <identifier>                                          }
function TSqlParser.ParseCorrelationNameClause: AnsiString;
begin
  if SkipToken(ttAS) then
    begin
      CheckToken(ttIdentifier, 'Identifier expected');
      Result := ExpectIdentifier;
    end
  else if FTokenType = ttIdentifier then
    Result := ParseIdentifier
  else
    Result := '';
end;

{ SQL92:                                                                       }
{ ::= [ <left paren> <derived column list> <right paren> ]                     }
{ <derived column list> ::= <column name list>                                 }
function TSqlParser.ParseDerivedColumnListClause: AnsiStringArray;
begin
  if SkipToken(ttLeftParen) then
    begin
      Result := ParseColumnNameList;
      ExpectRightParen;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <subquery> ::= <left paren> <query expression> <right paren>                 }
function TSqlParser.ParseSubQuery(const GotLeftParen: Boolean): ASqlQueryExpression;
var R : Boolean;
begin
  R := GotLeftParen;
  if not R and SkipToken(ttLeftParen) then
    R := True;
  if R then
    begin
      Result := ParseQueryExpression;
      if not Assigned(Result) then
        if GotLeftParen then
          exit
        else
          ParseError('Query expression expected');
      try
        ExpectRightParen;
      except
        Result.Free;
        raise;
      end;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <table subquery> ::= <subquery>                                              }
function TSqlParser.ParseTableSubQuery(const GotLeftParen: Boolean): ASqlQueryExpression;
begin
  Result := ParseSubQuery(GotLeftParen);
end;

function TSqlParser.ExpectTableSubQuery(const GotLeftParen: Boolean): ASqlQueryExpression;
begin
  Result := ParseSubQuery(GotLeftParen);
  if not Assigned(Result) then
    ParseError('Table sub query expected');
end;

{ SQL92:                                                                       }
{ ::= <derived table> [ AS ] <correlation name>                                }
{           [ <left paren> <derived column list> <right paren> ]               }
{ <derived table> ::= <table subquery>                                         }
function TSqlParser.ParseDerivedTableReference: TSqlDerivedTableReference;
begin
  Assert(FTokenType = ttLeftParen);
  Result := TSqlDerivedTableReference.Create;
  with Result do
    try
      QueryExpr := ExpectTableSubQuery(False);
      CorrelationName := ParseCorrelationNameClause;
      DerivedColumns := ParseDerivedColumnListClause;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ ::= <table name> [ [ AS ] <correlation name>                                 }
{           [ <left paren> <derived column list> <right paren> ] ]             }
function TSqlParser.ParseSimpleTableReference: TSqlSimpleTableReference;
begin
  Assert(FTokenType = ttIdentifier);
  Result := TSqlSimpleTableReference.Create;
  with Result do
    try
      Name := ParseTableName;
      Identifier := ParseCorrelationNameClause;
      if Identifier <> '' then
        ColumnList := ParseDerivedColumnListClause;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL99:                                                                       }
{ <table primary> ::=                                                          }
{       <table or query name> [ [ AS ] <correlation name> [ <left paren> <derived column list> <right paren> ] ]   }
{     | <derived table> [ AS ] <correlation name> [ <left paren> <derived column list> <right paren> ]             }
{     | <lateral derived table> [ AS ] <correlation name> [ <left paren> <derived column list> <right paren> ]     }
{     | <collection derived table> [ AS ] <correlation name> [ <left paren> <derived column list> <right paren> ]  }
{     | <only spec> [ [ AS ] <correlation name> [ <left paren> <derived column list> <right paren> ] ]             }
{     | <left paren> <joined table> <right paren>                                                                  }
{                                                                              }
{ SQL2003:                                                                     }
{ <table primary> ::=                                                          }
{       <table or query name> [ [ AS ] <correlation name> [ <left paren> <derived column list> <right paren> ] ]      }
{     | <derived table> [ AS ] <correlation name> [ <left paren> <derived column list> <right paren> ]                }
{     | <lateral derived table> [ AS ] <correlation name> [ <left paren> <derived column list> <right paren> ]        }
{     | <collection derived table> [ AS ] <correlation name> [ <left paren> <derived column list> <right paren> ]     }
{     | <table function derived table> [ AS ] <correlation name> [ <left paren> <derived column list> <right paren> ] }
{     | <only spec> [ [ AS ] <correlation name> [ <left paren> <derived column list> <right paren> ] ]                }
{     | <left paren> <joined table> <right paren>                                                                     }
function TSqlParser.ParseTablePrimary: ASqlQueryExpression;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <sample clause> ::=                                                          }
{     TABLESAMPLE <sample method> <left paren> <sample percentage>             }
{         <right paren> [ <repeatable clause> ]                                }
{ <sample percentage> ::= <numeric value expression>                           }
{ <repeatable clause> ::=                                                      }
{     REPEATABLE <left paren> <repeat argument> <right paren>                  }
{ <repeat argument> ::= <numeric value expression>                             }

{ SQL2003:                                                                     }
{ <table primary or joined table> ::=                                          }
{       <table primary>                                                        }
{     | <joined table>                                                         }

{ SQL92:                                                                       }
{ <table reference> ::=                                                        }
{       <table name> [ [ AS ] <correlation name>                               }
{           [ <left paren> <derived column list> <right paren> ] ]             }
{     | <derived table> [ AS ] <correlation name>                              }
{           [ <left paren> <derived column list> <right paren> ]               }
{     | <joined table>                                                         }
{                                                                              }
{ SQL99:                                                                       }
{ <table reference> ::=                                                        }
{       <table primary>                                                        }
{     | <joined table>                                                         }
{                                                                              }
{ SQL2003:                                                                     }
{ <table reference> ::=                                                        }
{     <table primary or joined table> [ <sample clause> ]                      }
function TSqlParser.ParseTableReference: ASqlQueryExpression;
begin
  if FTokenType = ttLeftParen then
    Result := ParseDerivedTableReference
  else if FTokenType = ttIdentifier then
    begin
      Result := ParseSimpleTableReference;
      if FTokenType in [ttCROSS, ttNATURAL, ttINNER, ttUNION, ttLEFT, ttRIGHT,
          ttFULL, ttJOIN] then
        Result := ParseJoinedTable(Result);
    end
  else
    Result := nil;
end;

{ SQL92:                                                                       }
{ <cross join> ::= <table reference> CROSS JOIN <table reference>              }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <cross join> ::= <table reference> CROSS JOIN <table primary>                }
function TSqlParser.ParseCrossJoin(const TableRef: ASqlQueryExpression): TSqlJoinedQuery;
begin
  Assert(FTokenType = ttCROSS);
  GetNextToken;
  ExpectKeyword(ttJOIN, SQL_KEYWORD_JOIN);
  Result := TSqlJoinedQuery.Create;
  with Result do
    try
      JoinType := sjtCross;
      TableRef1 := TableRef;
      TableRef2 := ParseTableReference;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <join type> ::= INNER | <outer join type> [ OUTER ] | UNION                  }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <join type> ::= INNER | <outer join type> [ OUTER ]                          }
{                                                                              }
{ SQL92/SQL99/SQL2003:                                                         }
{ <outer join type> ::= LEFT | RIGHT | FULL                                    }
function TSqlParser.ParseJoinType: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL92:                                                                       }
{ <qualified join> ::=                                                         }
{     <table reference> [ NATURAL ] [ <join type> ] JOIN                       }
{     <table reference> [ <join specification> ]                               }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <qualified join> ::=                                                         }
{     <table reference> [ <join type> ]                                        }
{     JOIN <table reference> <join specification>                              }
function TSqlParser.ParseQualifiedJoin: ASqlQueryExpression;
begin
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <join condition> ::= ON <search condition>                                   }
function TSqlParser.ParseJoinCondition: ASqlSearchCondition;
begin
  SkipToken(ttON);
  ParseSearchCondition;
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <join column list> ::= <column name list>                                    }
function TSqlParser.ParseJoinColumnList: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <named columns join> ::= USING <left paren> <join column list> <right paren> }
function TSqlParser.ParseNamedColumnsJoin: TObject;
begin
  SkipToken(ttUSING);
  ParseJoinColumnList;
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <join specification> ::= <join condition> | <named columns join>             }
function TSqlParser.ParseJoinSpecification: TObject;
begin
  ParseJoinCondition;
  ParseNamedColumnsJoin;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <natural join> ::=                                                           }
{     <table reference> NATURAL [ <join type> ] JOIN <table primary>           }
function TSqlParser.ParseNaturalJoin: ASqlQueryExpression;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <union join> ::= <table reference> UNION JOIN <table primary>                }
function TSqlParser.ParseUnionJoin: ASqlQueryExpression;
begin
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <joined table> ::=                                                           }
{       <cross join>                                                           }
{     | <qualified join>                                                       }
{     | <left paren> <joined table> <right paren>                              }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <joined table> ::=                                                           }
{       <cross join>                                                           }
{     | <qualified join>                                                       }
{     | <natural join>                                                         }
{     | <union join>                                                           }
function TSqlParser.ParseJoinedTable(const TableRef: ASqlQueryExpression): ASqlQueryExpression;
var L : ASqlQueryExpression;
    J : TSqlJoinedQuery;
begin
  if SkipToken(ttLeftParen) then
    begin
      Result := ParseJoinedTable(nil);
      ExpectRightParen;
      exit;
    end;
  if Assigned(TableRef) then
    L := TableRef
  else
    begin
      L := ParseTableReference;
      if not Assigned(L) then
        begin
          Result := nil;
          exit;
        end;
    end;
  if FTokenType = ttCROSS then
    Result := ParseCrossJoin(L) else
  if FTokenType in [ttNATURAL, ttJOIN, ttINNER, ttLEFT, ttRIGHT, ttFULL,
      ttUNION] then
    begin
      J := TSqlJoinedQuery.Create;
      try
        J.TableRef1 := L;
        J.Natural := SkipToken(ttNATURAL);
        case FTokenType of
          ttINNER  : J.JoinType := sjtInner;
          ttLEFT   : J.JoinType := sjtLeftOuter;
          ttRIGHT  : J.JoinType := sjtRightOuter;
          ttFULL   : J.JoinType := sjtFullOuter;
          ttUNION  : J.JoinType := sjtUnion;
        else
          J.JoinType := sjtUndefined;
        end;
        if J.JoinType <> sjtUndefined then
          begin
            GetNextToken;
            if J.JoinType in [sjtLeftOuter, sjtRightOuter, sjtFullOuter] then
              SkipToken(ttOUTER);
          end
        else
          J.JoinType := sjtInner;
        ExpectKeyword(ttJOIN, SQL_KEYWORD_JOIN);
        J.TableRef2 := ParseTableReference;
        if SkipToken(ttON) then
          J.JoinCondition := ExpectSearchCondition else
        if SkipToken(ttUSING) then
          begin
            ExpectLeftParen;
            J.JoinColumnList := ParseColumnNameList;
            ExpectRightParen;
          end;
      except
        J.Free;
        raise;
      end;
      Result := J;
    end
  else
    raise ESqlParser.Create('Join expected', self);
end;

{ SQL2003:                                                                     }
{ <search or cycle clause> ::=                                                 }
{       <search clause>                                                        }
{     |	<cycle clause>                                                         }
{     | <search clause> <cycle clause>                                         }
{ <search clause> ::= SEARCH <recursive search order> SET <sequence column>    }
{ <recursive search order> ::=                                                 }
{       DEPTH FIRST BY <sort specification list>                               }
{     | BREADTH FIRST BY <sort specification list>                             }
{ <sequence column> ::= <column name>                                          }
{ <cycle clause> ::=                                                           }
{     CYCLE <cycle column list>                                                }
{     SET <cycle mark column> TO <cycle mark value>                            }
{     DEFAULT <non-cycle mark value>                                           }
{     USING <path column>                                                      }
{ <cycle column list> ::= <cycle column> [ ( <comma> <cycle column> )... ]     }
{ <cycle column> ::= <column name>                                             }
{ <cycle mark column> ::= <column name>                                        }
{ <path column> ::= <column name>                                              }
{ <cycle mark value> ::= <value expression>                                    }
{ <non-cycle mark value> ::= <value expression>                                }

{ SQL99:                                                                       }
{ <with list element> ::=                                                      }
{     <query name>                                                             }
{     [ <left paren> <with column list> <right paren> ]                        }
{     AS <left paren> <query expression> <right paren>                         }
{     [ <search or cycle clause> ]                                             }
function TSqlParser.ParseWithListElement: TObject;
begin
  //// ParseWithColumnList;
  //// ParseSearchOrCycleClause;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <with list> ::= <with list element> [ ( <comma> <with list element> )... ]   }
function TSqlParser.ParseWithList: TObject;
begin
  ParseWithListElement;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <with clause> ::= WITH [ RECURSIVE ] <with list>                             }
function TSqlParser.ParseWithClause: TObject;
begin
  SkipToken(ttWITH);
  //// SkipToken(ttRECURSIVE);
  ParseWithList;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <query expression body> ::=                                                  }
{       <non-join query expression>                                            }
{     | <joined table>                                                         }
function TSqlParser.ParseQueryExpressionBody: ASqlQueryExpression;
begin
  ParseNonJoinQueryExpression;
  //// ParseJoinedTable;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <query expression> ::=                                                       }
{       <non-join query expression>                                            }
{     | <joined table>                                                         }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <query expression> ::=                                                       }
{     [ <with clause> ] <query expression body>                                }
function TSqlParser.ParseQueryExpression(const IsStatement: Boolean): ASqlQueryExpression;
begin
  Result := ParseNonJoinQueryExpression(IsStatement);
  if Assigned(Result) then
    exit;
  Result := ParseJoinedTable(nil);
end;

function TSqlParser.ExpectQueryExpression(const IsStatement: Boolean): ASqlQueryExpression;
begin
  Result := ParseQueryExpression(IsStatement);
  if not Assigned(Result) then
    ParseError('Query expression expected');
end;

{ SQL99:                                                                       }
{ <left bracket or trigraph> ::= <left bracket> | <left bracket trigraph>      }
{ <left bracket trigraph> ::= <question mark> <question mark> <left paren>     }
{ <right bracket or trigraph> ::= <right bracket> | <right bracket trigraph>   }
{ <right bracket trigraph> ::= <question mark> <question mark> <right paren>   }

{ SQL92:                                                                       }
{ <update source> ::=                                                          }
{       <value expression>                                                     }
{     | <null specification>                                                   }
{     | DEFAULT                                                                }
{                                                                              }
{ SQL99:                                                                       }
{ <update source> ::=                                                          }
{       <value expression>                                                     }
{     | <contextually typed value specification>                               }
function TSqlParser.ParseUpdateSource: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <assigned row> ::= <contextually typed row value expression>                 }
function TSqlParser.ParseAssignedRow: TObject;
begin
  //// ParseContextuallyTypedRowValueExpression;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <multiple column assignment> ::=                                             }
{     <set target list> <equals operator> <assigned row>                       }
function TSqlParser.ParseMultipleColumnAssignment: TObject;
begin
  //// ParseSetTargetList;
  //// ParseAssignedRow;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <mutated set clause> ::= <mutated target> <period> <method name>             }
{ <mutated target> ::= <object column> | <mutated set clause>                  }
function TSqlParser.ParseMutatedSetClause: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <update target> ::=                                                          }
{       <object column>                                                        }
{     | <object column> <left bracket or trigraph>                             }
{       <simple value specification> <right bracket or trigraph>               }
function TSqlParser.ParseUpdateTarget: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <object column> ::= <column name>                                            }
function TSqlParser.ParseObjectColumn: AnsiString;
begin
  Result := ParseColumnName;
end;

{ SQL99:                                                                       }
{ <contextually typed value specification> ::=                                 }
{       <implicitly typed value specification>                                 }
{     | <default specification>                                                }

{ SQL92:                                                                       }
{ <set clause> ::= <object column> <equals operator> <update source>           }
{                                                                              }
{ SQL99:                                                                       }
{ <set clause> ::=                                                             }
{       <update target> <equals operator> <update source>                      }
{     | <mutated set clause> <equals operator> <update source>                 }
{                                                                              }
{ SQL2003:                                                                     }
{ <set clause> ::=                                                             }
{       <multiple column assignment>                                           }
{     | <set target> <equals operator> <update source>                         }
function TSqlParser.ParseUpdateSetClause: TSqlUpdateSetItem;
begin
  Result := TSqlUpdateSetItem.Create;
  with Result do
    try
      ColumnName := ExpectColumnName;
      ExpectEqualSign;
      case FTokenType of
        ttNULL    : begin
                      Value := TSqlNullValue.Create;
                      GetNextToken;
                    end;
        ttDEFAULT : begin
                      Value := TSqlDefaultValue.Create;
                      GetNextToken;
                    end;
      else
        Value := ExpectValueExpression;
      end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <set clause list> ::= <set clause> [ ( <comma> <set clause> )... ]           }
function TSqlParser.ParseUpdateSetList: TSqlUpdateSetList;
begin
  Result := TSqlUpdateSetList.Create;
  try
    repeat
      Result.AddItem(ParseUpdateSetClause);
    until not SkipToken(ttComma);
  except
    Result.Free;
    raise;
  end;
end;

{ EXT:                                                                         }
{ <update statement> ::=                                                       }
{       <dynamic update statement: positioned>                                 }
{     | <update statement: searched>                                           }
function TSqlParser.ParseUpdateStatement(const UpdateType: TSqlUpdateStatementType): TSqlUpdateStatement;
begin
  Assert(FTokenType = ttUPDATE);
  Result := TSqlUpdateStatement.Create;
  with Result do
    try
      GetNextToken;
      TableName := ExpectIdentifier;
      ExpectKeyword(ttSET, SQL_KEYWORD_SET);
      SetList := ParseUpdateSetList;
      if SkipToken(ttWHERE) then
        if SkipToken(ttCURRENT) then
          begin
            ExpectKeyword(ttOF, SQL_KEYWORD_OF);
            CursorName := ParseDynamicCursorName;
          end
        else
          Where := ExpectSearchCondition;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <preparable dynamic update statement: positioned> ::=                        }
{    UPDATE [ <table name> ]                                                   }
{       SET <set clause list>                                                  }
{       WHERE CURRENT OF <cursor name>                                         }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <preparable dynamic update statement: positioned> ::=                        }
{     UPDATE [ <target table> ]                                                }
{     SET <set clause list>                                                    }
{     WHERE CURRENT OF [ <scope option> ] <cursor name>                        }

{ SQL92:                                                                       }
{ <dynamic update statement: positioned> ::=                                   }
{     UPDATE <table name>                                                      }
{       SET <set clause> [ ( <comma> <set clause> )... ]                       }
{         WHERE CURRENT OF <dynamic cursor name>                               }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <dynamic update statement: positioned> ::=                                   }
{     UPDATE <target table>                                                    }
{       SET <set clause list>                                                  }
{       WHERE CURRENT OF <dynamic cursor name>                                 }
{ <set clause list> ::= <set clause> [ ( <comma> <set clause> )... ]           }
function TSqlParser.ParseDynamicUpdateStatementPositioned: ASqlStatement;
begin
  Result := ParseUpdateStatement(supPositioned);
end;

{ SQL92:                                                                       }
{ <update statement: positioned> ::=                                           }
{     UPDATE <table name>                                                      }
{         SET <set clause list>                                                }
{         WHERE CURRENT OF <cursor name>                                       }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <update statement: positioned> ::=                                           }
{     UPDATE <target table>                                                    }
{         SET <set clause list>                                                }
{         WHERE CURRENT OF <cursor name>                                       }
function TSqlParser.ParseUpdateStatementPositioned: ASqlStatement;
begin
  Result := ParseUpdateStatement(supPositioned);
end;

{ SQL92:                                                                       }
{ <update statement: searched> ::=                                             }
{     UPDATE <table name>                                                      }
{       SET <set clause list>                                                  }
{       [ WHERE <search condition> ]                                           }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <update statement: searched> ::=                                             }
{	    UPDATE <target table>                                                    }
{       SET <set clause list>                                                  }
{       [ WHERE <search condition> ]                                           }
function TSqlParser.ParseUpdateStatementSearched: TSqlUpdateStatement;
begin
  Result := ParseUpdateStatement(supSearched);
end;

{ SQL2003:                                                                     }
{ <merge when matched clause> ::=                                              }
{     WHEN MATCHED THEN <merge update specification>                           }
{ <merge when not matched clause> ::=                                          }
{     WHEN NOT MATCHED THEN <merge insert specification>                       }
{ <merge update specification> ::= UPDATE SET <set clause list>                }
{ <merge insert specification> ::=                                             }
{     INSERT [ <left paren> <insert column list> <right paren> ]               }
{     [ <override clause> ] VALUES <merge insert value list>                   }
{ <merge insert value list> ::=                                                }
{     <left paren> <merge insert value element>                                }
{     [ ( <comma> <merge insert value element> )... ] <right paren>            }
{ <merge insert value element> ::=                                             }
{     <value expression> | <contextually typed value specification>            }

{ SQL2003:                                                                     }
{ <merge when clause> ::=                                                      }
{     <merge when matched clause> | <merge when not matched clause >           }
function TSqlParser.ParseMergeWhenClause: TObject;
var NotMatched : Boolean;
begin
  ExpectKeyword(ttWHEN, SQL_KEYWORD_WHEN);
  NotMatched := SkipToken(ttNOT);
  ExpectKeyword(ttMATCHED, SQL_KEYWORD_MATCHED);
  ExpectKeyword(ttTHEN, SQL_KEYWORD_THEN);
  if not NotMatched then
    begin
      ExpectKeyword(ttUPDATE, SQL_KEYWORD_UPDATE);
      ExpectKeyword(ttSET, SQL_KEYWORD_SET);
      // ParseSetClauseList;
    end
  else
    begin
      ExpectKeyword(ttINSERT, SQL_KEYWORD_INSERT);
      if SkipToken(ttLeftParen) then
        begin
          ExpectRightParen;
        end;
      // ParseOverrideClause;
      ExpectKeyword(ttVALUES, SQL_KEYWORD_VALUES);
      // ParseMergeInsertValueList;
    end;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <merge operation specification> ::= <merge when clause>...                   }
function TSqlParser.ParseMergeOperationSpecification: TObject;
begin
  repeat
    ParseMergeWhenClause;
  until FTokenType <> ttWHEN;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <merge statement> ::=                                                        }
{     MERGE INTO <target table> [ [ AS ] <merge correlation name> ]            }
{     USING <table reference> ON <search condition>                            }
{           <merge operation specification>                                    }
{ <merge correlation name> ::= <correlation name>                              }
function TSqlParser.ParseMergeStatement: ASqlStatement;
begin
  Assert(FTokenType = ttMERGE);
  GetNextToken;
  ExpectKeyword(ttINTO, SQL_KEYWORD_INTO);
  ParseTargetTable;
  if SkipToken(ttAS) then
    begin
    end;
  ExpectKeyword(ttUSING, SQL_KEYWORD_USING);
  ParseTableReference;
  ExpectKeyword(ttON, SQL_KEYWORD_ON);
  ParseSearchCondition;
  ParseMergeOperationSpecification;
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <insert column list> ::= <column name list>                                  }
function TSqlParser.ParseInsertColumnList: AnsiStringArray;
begin
  Result := ParseColumnNameList;
end;

{ SQL99:                                                                       }
{ <insertion target> ::= <table name>                                          }
function TSqlParser.ParseInsertionTarget: AnsiString;
begin
end;

{ SQL99:                                                                       }
{ <from subquery> ::=                                                          }
{     [ <left paren> <insert column list> <right paren> ]                      }
{     [ <override clause> ] <query expression>                                 }
function TSqlParser.ParseFromSubQuery: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <from constructor> ::=                                                       }
{     [ <left paren> <insert column list> <right paren> ]                      }
{     [ <override clause> ] <contextually typed table value constructor>       }
{ <override clause> ::= OVERRIDING USER VALUE | OVERRIDING SYSTEM VALUE        }
function TSqlParser.ParseFromConstructor: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <contextually typed table value constructor> ::=                             }
{     VALUES <contextually typed row value expression list>                    }

{ SQL99:                                                                       }
{ <from default> ::= DEFAULT VALUES                                            }
function TSqlParser.ParseFromDefault: Boolean;
begin
  //// TODO
  Result := False;
end;

{ SQL92:                                                                       }
{ <insert columns and source> ::=                                              }
{       [ <left paren> <insert column list> <right paren> ] <query expression> }
{     | DEFAULT VALUES                                                         }
{                                                                              }
{ SQL99:                                                                       }
{ <insert columns and source> ::=                                              }
{       <from subquery>                                                        }
{     | <from constructor>                                                     }
{     | <from default>                                                         }
function TSqlParser.ParseInsertColumnsAndSource: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <insert statement> ::=                                                       }
{     INSERT INTO <table name> <insert columns and source>                     }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <insert statement> ::=                                                       }
{     INSERT INTO <insertion target> <insert columns and source>               }
function TSqlParser.ParseInsertStatement: TSqlInsertStatement;
begin
  Assert(FTokenType = ttINSERT);
  Result := TSqlInsertStatement.Create;
  with Result do
    try
      GetNextToken;
      if (spoExtendedSyntax in FOptions) and (FTokenType = ttINTO) then
        GetNextToken // Extended Syntax: INTO optional
      else
        ExpectKeyword(ttINTO, SQL_KEYWORD_INTO); // SQL92: INTO required
      TableName := ExpectIdentifier;
      DefaultValues := False;
      if SkipToken(ttDEFAULT) then // DEFAULT VALUES
        begin
          ExpectKeyword(ttVALUES, SQL_KEYWORD_VALUES);
          DefaultValues := True;
        end
      else
        begin
          if SkipToken(ttLeftParen) then
            begin
              ColumnList := ParseIdentifierList;
              ExpectRightParen;
            end;
          QueryExpr := ParseQueryExpression;
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ EXT:                                                                         }
{ <delete statement> ::=                                                       }
{     <dynamic delete statement: positioned> |                                 }
{     <delete statement: positioned> |                                         }
{     <delete statement: searched>                                             }
function TSqlParser.ParseDeleteStatement(const DeleteType: TSqlDeleteStatementType): TSqlDeleteStatement;
begin
  Assert(FTokenType = ttDELETE);
  GetNextToken;
  if (spoExtendedSyntax in FOptions) and (FTokenType = ttFROM) then // Extended syntax: FROM optional
    GetNextToken
  else
    ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);                           // SQL92: FROM required
  Result := TSqlDeleteStatement.Create;
  with Result do
    try
      TableName := ParseTableName;
      if SkipToken(ttWHERE) then
        if (DeleteType <> sdsSearched) and SkipToken(ttCURRENT) then
          begin
            ExpectKeyword(ttOF, SQL_KEYWORD_OF);
            CursorName := ParseDynamicCursorName;
          end
        else
          Where := ExpectSearchCondition
      else
        if DeleteType in [sdsPositioned, sdsDynamicPositioned] then
          ParseError('WHERE expected');
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <preparable dynamic delete statement: positioned> ::=                        }
{    DELETE [ FROM <table name> ]                                              }
{       WHERE CURRENT OF <cursor name>                                         }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <preparable dynamic delete statement: positioned> ::=                        }
{     DELETE [ FROM <target table> ]                                           }
{       WHERE CURRENT OF [ <scope option> ] <cursor name>                      }

{ SQL92:                                                                       }
{ <dynamic delete statement: positioned> ::=                                   }
{     DELETE FROM <table name>                                                 }
{         WHERE CURRENT OF <dynamic cursor name>                               }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <dynamic delete statement: positioned> ::=                                   }
{     DELETE FROM <target table>                                               }
{         WHERE CURRENT OF <dynamic cursor name>                               }
function TSqlParser.ParseDynamicDeleteStatementPositioned: ASqlStatement;
begin
  Result := ParseDeleteStatement(sdsDynamicPositioned);
end;

{ SQL92:                                                                       }
{ <delete statement: positioned> ::=                                           }
{     DELETE FROM <table name>                                                 }
{       WHERE CURRENT OF <cursor name>                                         }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <delete statement: positioned> ::=                                           }
{     DELETE FROM <target table>                                               }
{     WHERE CURRENT OF <cursor name>                                           }
function TSqlParser.ParseDeleteStatementPositioned: ASqlStatement;
begin
  Result := ParseDeleteStatement(sdsPositioned);
end;

{ SQL92:                                                                       }
{ <delete statement: searched> ::=                                             }
{     DELETE FROM <table name>                                                 }
{       [ WHERE <search condition> ]                                           }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <delete statement: searched> ::=                                             }
{     DELETE FROM <target table>                                               }
{     [ WHERE <search condition> ]                                             }
function TSqlParser.ParseDeleteStatementSearched: TSqlDeleteStatement;
begin
  Result := ParseDeleteStatement(sdsSearched);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <constraint check time> ::= INITIALLY DEFERRED | INITIALLY IMMEDIATE         }
function TSqlParser.ParseConstraintCheckTime: TSqlConstraintCheckTime;
begin
  Result := sccUndefined;
  if SkipToken(ttINITIALLY) then
    begin
      case FTokenType of
        ttDEFERRED  : Result := sccInitiallyDeferred;
        ttIMMEDIATE : Result := sccInitiallyImmediate;
      else
        ParseError('DEFERRED or IMMEDIATE expected');
      end;
      GetNextToken;
    end;
end;

{ SQL92:                                                                       }
{ ::= [ [ NOT ] DEFERRABLE ]                                                   }
function TSqlParser.ParseConstraintDeferrable: TSqlConstraintDeferrable;
begin
  if SkipToken(ttNOT) then
    begin
      ExpectKeyword(ttDEFERRABLE, SQL_KEYWORD_DEFERRABLE);
      Result := scdNotDeferrable;
    end else
  if SkipToken(ttDEFERRABLE) then
    Result := scdDeferrable
  else
    Result := scdUndefined;
end;

{ SQL92:                                                                       }
{ <constraint attributes> ::=                                                  }
{       <constraint check time> [ [ NOT ] DEFERRABLE ]                         }
{     | [ NOT ] DEFERRABLE [ <constraint check time> ]                         }
{                                                                              }
{ SQL99: Not used                                                              }
function TSqlParser.ParseConstraintAttributes: TSqlConstraintAttributes;
var C : TSqlConstraintCheckTime;
begin
  if FTokenType in [ttNOT, ttDEFERRABLE] then
    begin
      Result := TSqlConstraintAttributes.Create;
      try
        Result.Deferrable := ParseConstraintDeferrable;
        Result.CheckTime := ParseConstraintCheckTime;
      except
        Result.Free;
        raise;
      end;
    end
  else
    begin
      C := ParseConstraintCheckTime;
      if C <> sccUndefined then
        begin
          Result := TSqlConstraintAttributes.Create;
          try
            Result.CheckTime := C;
            Result.Deferrable := ParseConstraintDeferrable;
          except
            Result.Free;
            raise;
          end;
        end
      else
        Result := nil;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <constraint name definition> ::= CONSTRAINT <constraint name>                }
function TSqlParser.ParseConstraintNameDefinition: AnsiString;
begin
  if SkipToken(ttCONSTRAINT) then
    Result := ParseConstraintName
  else
    Result := '';
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <unique specification> ::= UNIQUE | PRIMARY KEY                              }
function TSqlParser.ParseUniqueSpecification: TSqlUniqueSpecification;
begin
  if SkipToken(ttUNIQUE) then
    Result := susUnique else
  if SkipToken(ttPRIMARY) then
    begin
      ExpectKeyword(ttKEY, SQL_KEYWORD_KEY);
      Result := susPrimaryKey;
    end
  else
    Result := susUndefined;
end;

{ SQL92:                                                                       }
{ <unique constraint definition> ::=                                           }
{     <unique specification>                                                   }
{     <left paren> <unique column list> <right paren>                          }
{ <unique column list> ::= <column name list>                                  }
{                                                                              }
{ SQL99:                                                                       }
{ <unique constraint definition> ::=                                           }
{       <unique specification>                                                 }
{       <left paren> <unique column list> <right paren>                        }
{     |	UNIQUE <left paren> VALUE <right paren>                                }
{                                                                              }
{ SQL2003:                                                                     }
{ <unique constraint definition> ::=                                           }
{       <unique specification>                                                 }
{       <left paren> <unique column list> <right paren>                        }
{     | UNIQUE ( VALUE )                                                       }
function TSqlParser.ParseUniqueConstraintDefinition: TSqlUniqueConstraint;
var S : TSqlUniqueSpecification;
begin
  S := ParseUniqueSpecification;
  if S <> susUndefined then
    begin
      Result := TSqlUniqueConstraint.Create;
      with Result do
        try
          Specification := S;
          ExpectLeftParen;
          UniqueColumns := ParseColumnNameList;
          ExpectRightParen;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL92:                                                                       }
{ <referential action> ::=                                                     }
{       CASCADE                                                                }
{     | SET NULL                                                               }
{     | SET DEFAULT                                                            }
{     | NO ACTION                                                              }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <referential action> ::=                                                     }
{       CASCADE                                                                }
{     | SET NULL                                                               }
{     | SET DEFAULT                                                            }
{     | RESTRICT                                                               }
{     | NO ACTION                                                              }
function TSqlParser.ParseReferentialAction: TSqlReferentialAction;
begin
  Result := sraUndefined;
  if SkipToken(ttCASCADE) then
    Result := sraCascade else
  if SkipToken(ttSET) then
    begin
      case FTokenType of
        ttNULL    : Result := sraSetNull;
        ttDEFAULT : Result := sraSetDefault;
      else
        ParseError('NULL or DEFAULT expected');
      end;
      GetNextToken;
    end else
  if SkipToken(ttNO) then
    begin
      ExpectKeyword(ttACTION, SQL_KEYWORD_ACTION);
      Result := sraNoAction;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <referential triggered action> ::=                                           }
{       <update rule> [ <delete rule> ]                                        }
{     | <delete rule> [ <update rule> ]                                        }
{ <update rule> ::= ON UPDATE <referential action>                             }
{ <delete rule> ::= ON DELETE <referential action>                             }
function TSqlParser.ParseReferentialTriggeredAction(
    var UpdateAction, DeleteAction: TSqlReferentialAction): Boolean;
var R : Boolean;
    A : TSqlReferentialAction;
begin
  if SkipToken(ttON) then
    begin
      if not (FTokenType in [ttUPDATE, ttDELETE]) then
        ParseError('UPDATE or DELETE expected');
      R := (FTokenType = ttUPDATE);
      GetNextToken;
      A := ParseReferentialAction;
      if R then
        UpdateAction := A
      else
        DeleteAction := A;
      if SkipToken(ttON) then
        begin
          if R then
            ExpectToken(ttDELETE, 'DELETE expected')
          else
            ExpectKeyword(ttUPDATE, SQL_KEYWORD_UPDATE);
          A := ParseReferentialAction;
          if R then
            UpdateAction := A
          else
            DeleteAction := A;
        end;
      Result := True;
    end
  else
    Result := False;
end;

{ SQL92:                                                                       }
{ <match type> ::= FULL | PARTIAL                                              }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <match type> ::= FULL | PARTIAL | SIMPLE                                     }
function TSqlParser.ExpectMatchType: TSqlReferencesMatchType;
begin
  Result := srmUndefined;
  case FTokenType of
    ttFULL    : Result := srmFull;
    ttPARTIAL : Result := srmPartial;
    ttSIMPLE  : Result := srmSimple;
  else
    ParseError('FULL or PARTIAL expected');
  end;
  GetNextToken;
end;

{ SQL92:                                                                       }
{ <reference column list> ::= <column name list>                               }

{ SQL92:                                                                       }
{ <referenced table and columns> ::=                                           }
{      <table name> [ <left paren> <reference column list> <right paren> ]     }

{ SQL92:                                                                       }
{ <references specification> ::=                                               }
{     REFERENCES <referenced table and columns>                                }
{       [ MATCH <match type> ]                                                 }
{       [ <referential triggered action> ]                                     }
function TSqlParser.ParseReferencesSpecification: TSqlReferencesSpecification;
var U, D : TSqlReferentialAction;
begin
  if SkipToken(ttREFERENCES) then
    begin
      Result := TSqlReferencesSpecification.Create;
      with Result do
        try
          TableName := ParseTableName;
          if SkipToken(ttLeftParen) then
            begin
              Columns := ParseColumnNameList;
              ExpectRightParen;
            end;
          if SkipToken(ttMATCH) then
            MatchType := ExpectMatchType;
          if ParseReferentialTriggeredAction(U, D) then
            begin
              UpdateAction := U;
              DeleteAction := D;
            end;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <referential constraint definition> ::=                                      }
{     FOREIGN KEY                                                              }
{         <left paren> <referencing columns> <right paren>                     }
{         <references specification>                                           }
{ <referencing columns> ::= <reference column list>                            }
{ <reference column list> ::= <column name list>                               }
function TSqlParser.ParseReferentialConstraintDefinition: TSqlReferentialConstraint;
begin
  Assert(FTokenType = ttFOREIGN);
  ExpectKeyword(ttKEY, SQL_KEYWORD_KEY);
  ExpectLeftParen;
  Result := TSqlReferentialConstraint.Create;
  with Result do
    try
      ReferencingColumns := ParseColumnNameList;
      ExpectRightParen;
      ReferencesSpec := ParseReferencesSpecification;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <check constraint definition> ::= CHECK                                      }
{         <left paren> <search condition> <right paren>                        }
function TSqlParser.ParseCheckConstraintDefinition: TSqlCheckConstraint;
begin
  if SkipToken(ttCHECK) then
    begin
      ExpectLeftParen;
      Result := TSqlCheckConstraint.Create;
      try
        Result.CheckCondition := ParseSearchCondition;
        ExpectRightParen;
      except
        Result.Free;
        raise;
      end;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <table constraint> ::=                                                       }
{       <unique constraint definition>                                         }
{     | <referential constraint definition>                                    }
{     | <check constraint definition>                                          }
function TSqlParser.ParseTableConstraint: ASqlConstraint;
begin
  case FTokenType of
    ttUNIQUE,
    ttPRIMARY : Result := ParseUniqueConstraintDefinition;
    ttFOREIGN : Result := ParseReferentialConstraintDefinition;
    ttCHECK   : Result := ParseCheckConstraintDefinition;
  else
    Result := nil;
  end;
end;

{ SQL92:                                                                       }
{ <table constraint definition> ::=                                            }
{     [ <constraint name definition> ]                                         }
{     <table constraint>                                                       }
{     [ <constraint attributes> ]                                              }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <table constraint definition> ::=                                            }
{     [ <constraint name definition> ]                                         }
{     <table constraint>                                                       }
{     [ <constraint characteristics> ]                                         }
{ <constraint check time> ::= INITIALLY DEFERRED | INITIALLY IMMEDIATE         }
function TSqlParser.ParseTableConstraintDefinition: TSqlTableConstraint;
var N : AnsiString;
    C : ASqlConstraint;
begin
  Result := nil;
  N := ParseConstraintNameDefinition;
  C := ParseTableConstraint;
  if not Assigned(C) then
    if N <> '' then
      ParseError('Table constraint expected')
    else
      exit;
  Result := TSqlTableConstraint.Create;
  with Result do
    try
      Name := N;
      Constraint := C;
      Attributes := ParseConstraintAttributes;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <table element> ::=                                                          }
{       <column definition>                                                    }
{     | <table constraint definition>                                          }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <table element> ::=                                                          }
{       <column definition>                                                    }
{     | <table constraint definition>                                          }
{     | <like clause>                                                          }
{     | <self-referencing column specification>                                }
{     | <column options>                                                       }
{                                                                              }
{ SQL99:                                                                       }
{ <like clause> ::= LIKE <table name>                                          }
{ <self-referencing column specification> ::=                                  }
{     REF IS <self-referencing column name> <reference generation>             }
{ <self-referencing column name> ::= <column name>                             }
{ <reference generation> ::= SYSTEM GENERATED | USER GENERATED | DERIVED       }
{ <column options> ::= <column name> WITH OPTIONS <column option list>         }
{ <column option list> ::=                                                     }
{     [ <scope clause> ] [ <default clause> ]                                  }
{     [ <column constraint definition>... ] [ <collate clause> ]               }
{ <scope clause> ::= SCOPE <table name>                                        }
function TSqlParser.ParseTableElement: TSqlTableElement;
begin
  Result := TSqlTableElement.Create;
  with Result do
    try
      TableConstraint := ParseTableConstraintDefinition;
      if not Assigned(TableConstraint) then
        ColumnDefinition := ParseColumnDefinition;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <table element list> ::= <left paren> <table element>                        }
{       [ ( <comma> <table element> )... ] <right paren>                       }
function TSqlParser.ParseTableElementList: TSqlTableElementArray;
begin
  Result := nil;
  try
    ExpectLeftParen;
    repeat
      Append(ObjectArray(Result), ParseTableElement);
    until not SkipToken(ttComma);
    ExpectRightParen;
  except
    FreeObjectArray(Result);
    raise;
  end;
end;

{ SQL99:                                                                       }
{ <table scope> ::= <global or local> TEMPORARY                                }
{ <global or local> ::= GLOBAL | LOCAL                                         }
function TSqlParser.ParseTableScope: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL2003:                                                                     }
{ <with or without data> ::= WITH NO DATA | WITH DATA                          }
function TSqlParser.ParseWithOrWithoutData: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL2003:                                                                     }
{ <as subquery clause> ::=                                                     }
{     [ <left paren> <column name list> <right paren> ]                        }
{         AS <subquery> <with or without data>                                 }
function TSqlParser.ParseAsSubQueryClause: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <table contents source> ::=                                                  }
{       <table element list>                                                   }
{     | OF <user-defined type> [ <subtable clause> ] [ <table element list> ]  }
{                                                                              }
{ SQL2003:                                                                     }
{ <table contents source> ::=                                                  }
{       <table element list>                                                   }
{     | OF <path-resolved user-defined type name>                              }
{       [ <subtable clause> ] [ <table element list> ]                         }
{     |	<as subquery clause>                                                   }
function TSqlParser.ParseTableContentsSource: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <table commit action> ::= PRESERVE | DELETE                                  }
function TSqlParser.ParseTableCommitAction: TSqlTableCommitAction;
begin
  Result := stcUndefined;
  case FTokenType of
    ttDELETE   : Result := stcDeleteRows;
    ttPRESERVE : Result := stcPreserveRows;
  else
    ParseError('DELETE or PRESERVE expected');
  end;
  GetNextToken;
end;

{ SQL92:                                                                       }
{ <table definition> ::=                                                       }
{     CREATE [ ( GLOBAL | LOCAL ) TEMPORARY ] TABLE                            }
{         <table name>                                                         }
{         <table element list>                                                 }
{         [ ON COMMIT ( DELETE | PRESERVE ) ROWS ]                             }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <table definition> ::=                                                       }
{     CREATE [ <table scope> ] TABLE                                           }
{         <table name>                                                         }
{         <table contents source>                                              }
{         [ ON COMMIT <table commit action> ROWS ]                             }
function TSqlParser.ParseTableDefinition: TSqlCreateTableStatement;
begin
  Result := TSqlCreateTableStatement.Create;
  with Result do
    try
      case FTokenType of
        ttGLOBAL : Scope := stsGlobal;
        ttLOCAL  : Scope := stsLocal;
      else
        Scope := stsUndefined;
      end;
      if Scope <> stsUndefined then
        GetNextToken;
      Temporary := SkipToken(ttTEMPORARY);
      ExpectKeyword(ttTABLE, SQL_KEYWORD_TABLE);
      TableName := ExpectIdentifier;
      ElementList := ParseTableElementList;
      if SkipToken(ttON) then
        begin
          ExpectKeyword(ttCOMMIT, SQL_KEYWORD_COMMIT);
          CommitAction := ParseTableCommitAction;
          ExpectKeyword(ttROWS, SQL_KEYWORD_ROWS);
        end
      else
        CommitAction := stcUndefined;
    except
      Result.Free;
      raise;
    end;
end;

{ MSSQL:                                                                       }
{ <index definition> ::=                                                       }
{     CREATE [ UNIQUE ] [ CLUSTERED | NONCLUSTERED ] INDEX index_name          }
{     ON <object> ( column [ ASC | DESC ] [ ,...n ] )                          }
{     [ INCLUDE ( column_name [ ,...n ] ) ]                                    }
{     [ WHERE <filter_predicate> ]                                             }
{     [ WITH ( <relational_index_option> [ ,...n ] ) ]                         }
{     [ ON ( partition_scheme_name ( column_name )                             }
{          | filegroup_name                                                    }
{          | default                                                           }
{          )                                                                   }
{     ]                                                                        }
{     [ FILESTREAM_ON ( filestream_filegroup_name | partition_scheme_name | "NULL" ) ] }
{ <object> ::=                                                                 }
{     [ database_name. [ schema_name ] . | schema_name. ]                      }
{       table_or_view_name                                                     }
{ <relational_index_option> ::=                                                }
{     PAD_INDEX = ( ON | OFF )                                                 }
{   | FILLFACTOR = fillfactor                                                  }
{   | SORT_IN_TEMPDB = ( ON | OFF )                                            }
{   | IGNORE_DUP_KEY = ( ON | OFF )                                            }
{   | STATISTICS_NORECOMPUTE = ( ON | OFF )                                    }
{   | DROP_EXISTING = ( ON | OFF )                                             }
{   | ONLINE = ( ON | OFF )                                                    }
{   | ALLOW_ROW_LOCKS = ( ON | OFF )                                           }
{   | ALLOW_PAGE_LOCKS = ( ON | OFF )                                          }
{   | MAXDOP = max_degree_of_parallelism                                       }
{   | DATA_COMPRESSION = ( NONE | ROW | PAGE )                                 }
{      [ ON PARTITIONS ( ( <partition_number_expression> | <range> )           }
{      [ , ...n ] ) ]                                                          }
{ <filter_predicate> ::=                                                       }
{     <conjunct> [ AND <conjunct> ]                                            }
{ <conjunct> ::=                                                               }
{     <disjunct> | <comparison>                                                }
{ <disjunct> ::=                                                               }
{         column_name IN (constant ,…)                                         }
{ <comparison> ::=                                                             }
{         column_name <comparison_op> constant                                 }
{ <comparison_op> ::=                                                          }
{     ( IS | IS NOT | = | <> | != | > | >= | !> | < | <= | !< )                }
{ <range> ::=                                                                  }
{   <partition_number_expression> TO <partition_number_expression>             }
{ Backward Compatible Relational Index                                         }
{ Important   The backward compatible relational index syntax structure will   }
{ be removed in a future version of SQL Server.                                }
{ CREATE [ UNIQUE ] [ CLUSTERED | NONCLUSTERED ] INDEX index_name              }
{     ON <object> ( column_name [ ASC | DESC ] [ ,...n ] )                     }
{     [ WITH <backward_compatible_index_option> [ ,...n ] ]                    }
{     [ ON ( filegroup_name | "default" ) ]                                    }
{ <object> ::=                                                                 }
{    [ database_name. [ owner_name ] . | owner_name. ] table_or_view_name      }
{ <backward_compatible_index_option> ::=                                       }
{     PAD_INDEX                                                                }
{   | FILLFACTOR = fillfactor                                                  }
{   | SORT_IN_TEMPDB                                                           }
{   | IGNORE_DUP_KEY                                                           }
{   | STATISTICS_NORECOMPUTE                                                   }
{   | DROP_EXISTING                                                            }
function TSqlParser.ParseIndexDefinition: TSqlCreateIndexStatement;
begin
  Result := TSqlCreateIndexStatement.Create;
  with Result do
    begin
    end;
  ParseError('Not implemented');
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <drop behavior> ::= CASCADE | RESTRICT                                       }
function TSqlParser.ParseDropBehavior: TSqlDropBehavior;
begin
  case FTokenType of
    ttCASCADE  : Result := sdbCascade;
    ttRESTRICT : Result := sdbRestrict;
  else
    Result := sdbUndefined;
  end;
  if Result <> sdbUndefined then
    GetNextToken;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <drop table statement> ::=                                                   }
{     DROP TABLE <table name> <drop behavior>                                  }
function TSqlParser.ParseDropTableStatement: TSqlDropTableStatement;
begin
  Assert(FTokenType = ttTABLE);
  GetNextToken;
  Result := TSqlDropTableStatement.Create;
  with Result do
    try
      TableName := ExpectIdentifier;
      DropBehavior := ParseDropBehavior;
    except
      Result.Free;
      raise;
    end;
end;

{ EXT:                                                                         }
{ <drop procedure statement> ::=                                               }
{     DROP ( PROC  | PROCEDURE ) <identifier>                                  }
function TSqlParser.ParseDropProcedureStatement: TSqlDropProcedureStatement;
begin
  Assert(FTokenType in [ttPROC, ttPROCEDURE]);
  GetNextToken;
  Result := TSqlDropProcedureStatement.Create;
  try
    Result.ProcName := ExpectIdentifier;
  except
    Result.Free;
    raise;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <connect statement> ::=                                                      }
{     CONNECT TO <connection target>                                           }
{                                                                              }
{ SQL92:                                                                       }
{ <connection target> ::=                                                      }
{       <SQL-server name>                                                      }
{           [ AS <connection name> ]                                           }
{           [ USER <user name> ]                                               }
{     | DEFAULT                                                                }
{ <SQL-server name> ::= <simple value specification>                           }
{ <connection name> ::= <simple value specification>                           }
{ <user name> ::= <simple value specification>                                 }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <connection target> ::=                                                      }
{     <SQL-server name>                                                        }
{         [ AS <connection name> ]                                             }
{         [ USER <connection user name> ]                                      }
{     | DEFAULT                                                                }
{ <connection user name> ::= <simple value specification>                      }
function TSqlParser.ParseConnectStatement: TSqlConnectStatement;
begin
  Assert(FTokenType = ttCONNECT);
  Result := TSqlConnectStatement.Create;
  with Result do
    try
      GetNextToken;
      ExpectKeyword(ttTO, SQL_KEYWORD_TO);
      if SkipToken(ttDEFAULT) then
        ConnectDefault := True
      else
        begin
          ConnectDefault := False;
          ServerName := ExpectSimpleValueSpecification;
          if SkipToken(ttAS) then
            ConnectionName := ExpectSimpleValueSpecification;
          if SkipToken(ttUSER) then
            UserName := ExpectSimpleValueSpecification;
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <disconnect object> ::= <connection object> | ALL | CURRENT                  }
{ <connection object> ::= DEFAULT | <connection name>                          }
function TSqlParser.ParseDisconnectObject: TSqlDisconnectObject;
begin
  Result := TSqlDisconnectObject.Create;
  with Result do
    try
      case FTokenType of
        ttALL     : ObjType := sdoAll;
        ttCURRENT : ObjType := sdoCurrent;
        ttDEFAULT : ObjType := sdoDefault;
      else
        ConnectionName := ExpectSimpleValueSpecification;
      end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <disconnect statement> ::= DISCONNECT <disconnect object>                    }
function TSqlParser.ParseDisconnectStatement: TSqlDisconnectStatement;
begin
  Assert(FTokenType = ttDISCONNECT);
  GetNextToken;
  Result := TSqlDisconnectStatement.Create;
  try
    Result.DisconnectObj := ParseDisconnectObject;
  except
    Result.Free;
    raise;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <SQL statement name> ::= <statement name> | <extended statement name>        }
{ <statement name> ::= <identifier>                                            }
{ <extended statement name> ::=                                                }
{     [ <scope option> ] <simple value specification>                          }
{ <scope option> ::= GLOBAL | LOCAL                                            }
function TSqlParser.ParseSqlStatementName: TSqlStatementName;
begin
  Result := TSqlStatementName.Create;
  with Result do
    try
      ScopeOption := ParseScopeOption;
      if ScopeOption <> ssoUndefined then
        ExtName := ExpectSimpleValueSpecification else
      if FTokenType = ttIdentifier then
        Identifier := ParseIdentifier
      else
        ExtName := ExpectSimpleValueSpecification;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <target specification> ::=                                                   }
{       <parameter specification>                                              }
{     | <variable specification>                                               }
{                                                                              }
{ SQL99:                                                                       }
{ <target specification> ::=                                                   }
{       <host parameter specification>                                         }
{     | <SQL parameter reference>                                              }
{     | <column reference>                                                     }
{     | <SQL variable reference>                                               }
{     | <dynamic parameter specification>                                      }
{     | <embedded variable specification>                                      }
{                                                                              }
{ SQL2003:                                                                     }
{ <target specification> ::=                                                   }
{       <host parameter specification>                                         }
{     | <SQL parameter reference>                                              }
{     | <column reference>                                                     }
{     | <target array element specification>                                   }
{     | <dynamic parameter specification>                                      }
{     | <embedded variable specification>                                      }
{ <target array element specification> ::=                                     }
{     <target array reference> <left bracket or trigraph>                      }
{     <simple value specification> <right bracket or trigraph>                 }
{ <target array reference> ::= <SQL parameter reference> | <column reference>  }
function TSqlParser.ParseTargetSpecification: ASqlValueExpression;
begin
  Result := ParseParameterSpecification;
  if Assigned(Result) then
    exit;
  Result := ParseVariableSpecification;
end;

{ MSSQL:                                                                       }
{ <parameter value> ::=                                                        }
{     [ @parameter = ] ( value | @variable [ OUTPUT ] | [ DEFAULT ] )          }
function TSqlParser.ParseParameterValue: TSqlParameterValue;
var A : ASqlValueExpression;
    N : AnsiString;
begin
  A := ParseValueExpression;
  if not Assigned(A) then
    begin
      Result := nil;
      exit;
    end;
  try
    N := '';
    if (FTokenType = ttEqual) and (A is TSqlParameterReference) then
      begin
        GetNextToken;
        N := TSqlParameterReference(A).Name;
        FreeAndNil(A);
        A := ParseValueExpression;
      end;
  except
    A.Free;
    raise;
  end;
  Result := TSqlParameterValue.CreateEx(N, A);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <execute immediate statement> ::=                                            }
{     EXECUTE IMMEDIATE <SQL statement variable>                               }
function TSqlParser.ParseExecuteImmediateStatement: TSqlExecuteImmediateStatement;
begin
  Assert(FTokenType = ttIMMEDIATE);
  GetNextToken;
  Result := TSqlExecuteImmediateStatement.Create;
  with Result do
    try
      StatementName := ExpectSimpleValueSpecification;
    except
      Result.Free;
      raise;
    end;
end;

{ MSSQL:                                                                       }
{ [ [ EXEC [ UTE ] ]                                                           }
{     ( [ @return_status = ]                                                   }
{             ( procedure_name [ ;number ] | @procedure_name_var )             }
{     [ <parameter value> ] [ ,...n ]                                          }
{ [ WITH RECOMPILE ]                                                           }
function TSqlParser.ParseExecuteStatementExt: TSqlExecuteStatement;
var P : Boolean;
    V : TSqlParameterValueArray;
    R : TSqlParameterValue;
begin
  Result := TSqlExecuteStatement.Create;
  with Result do
    try
      Name := ParseIdentifier;
      P := (FTokenType = ttLeftParen);
      if P then
        GetNextToken;
      try
        R := ParseParameterValue;
        if Assigned(R) then
          begin
            Append(ObjectArray(V), R);
            while SkipToken(ttComma) do
              begin
                R := ParseParameterValue;
                if not Assigned(R) then
                  ParseError('Parameter value expected');
                Append(ObjectArray(V), R);
              end;
          end;
      except
        FreeObjectArray(V);
        raise;
      end;
      Parameters := V;
      if P then
        ExpectRightParen;
      if SkipToken(ttWITH) then
        ExpectKeyword(ttRECOMPILE, SQL_KEYWORD_RECOMPILE);
    except
      Result.Free;
      raise;
    end;
end;

{ SQL99/SQL2003:                                                               }
{ <into argument> ::= <target specification>                                   }
function TSqlParser.ParseIntoArgument: TObject;
begin
  ParseTargetSpecification;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <into arguments> ::= INTO <into argument> [ ( <comma> <into argument> )... ] }
function TSqlParser.ParseIntoArguments: TObject;
begin
  SkipToken(ttINTO);
  ParseIntoArgument;
  while SkipToken(ttComma) do
    ParseIntoArgument;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <into descriptor> ::= INTO [ SQL ] DESCRIPTOR <descriptor name>              }
function TSqlParser.ParseIntoDescriptor: TObject;
begin
  SkipToken(ttINTO);
  SkipToken(ttSQL);
  SkipToken(ttDESCRIPTOR);
  ParseDescriptorName;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <output using clause> ::= <into arguments> | <into descriptor>               }
function TSqlParser.ParseOutputUsingClause: TObject;
begin
  ParseIntoArguments;
  ParseIntoDescriptor;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <using argument> ::= <general value specification>                           }
function TSqlParser.ParseUsingArgument: TObject;
begin
  ParseGeneralValueSpecification;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <using arguments> ::=                                                        }
{     USING <using argument> [ ( <comma> <using argument> )... ]               }
function TSqlParser.ParseUsingArguments: TObject;
begin
  SkipToken(ttUSING);
  ParseUsingArgument;
  while SkipToken(ttComma) do
    ParseUsingArgument;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <using input descriptor> ::= <using descriptor>                              }
function TSqlParser.ParseUsingInputDescriptor: TObject;
begin
  ParseUsingDescriptor;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <input using clause> ::= <using arguments> | <using input descriptor>        }
function TSqlParser.ParseInputUsingClause: TObject;
begin
  ParseUsingArguments;
  ParseUsingInputDescriptor;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <execute statement> ::=                                                      }
{     EXECUTE <SQL statement name>                                             }
{       [ <result using clause> ]                                              }
{       [ <parameter using clause> ]                                           }
{ <result using clause> ::= <using clause>                                     }
{ <parameter using clause> ::= <using clause>                                  }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <execute statement> ::=                                                      }
{     EXECUTE <SQL statement name>                                             }
{       [ <result using clause> ]                                              }
{       [ <parameter using clause> ]                                           }
{ <result using clause> ::= <output using clause>                              }
{ <parameter using clause> ::= <input using clause>                            }
function TSqlParser.ParseSql92ExecuteStatement: TSql92ExecuteStatement;
begin
  Result := TSql92ExecuteStatement.Create;
  with Result do
    try
      StatementName := ParseSqlStatementName;
      Clause1 := ParseUsingClause;
      if Assigned(Clause1) then
        Clause2 := ParseUsingClause;
    except
      Result.Free;
      raise;
    end;
end;

{ EXT:                                                                         }
{ <execute statement> ::=                                                      }
{       MSSQL:<execute statement>                                              }
{     | SQL92:<execute statement>                                              }
{     | SQL92:<execute immediate statement>                                    }
function TSqlParser.ParseExecuteStatementSub: ASqlStatement;
begin
  if FTokenType = ttIMMEDIATE then
    Result := ParseExecuteImmediateStatement
  else
    if spoExtendedSyntax in FOptions then
      Result := ParseExecuteStatementExt
    else
      Result := ParseSql92ExecuteStatement;
end;

function TSqlParser.ParseExecuteStatement: ASqlStatement;
begin
  Assert(FTokenType in [ttEXEC, ttEXECUTE]);
  if not (spoExtendedSyntax in FOptions) then
    ExpectToken(ttEXECUTE, 'EXECUTE expected')
  else
    GetNextToken;
  Result := ParseExecuteStatementSub;
end;

{ SQL92:                                                                       }
{ <temporary table declaration> ::=                                            }
{     DECLARE LOCAL TEMPORARY TABLE <qualified local table name>               }
{       <table element list>                                                   }
{       [ ON COMMIT ( PRESERVE | DELETE ) ROWS ]                               }
{ <qualified local table name> ::=                                             }
{     MODULE <period> <local table name>                                       }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <temporary table declaration> ::=                                            }
{     DECLARE LOCAL TEMPORARY TABLE <table name>                               }
{       <table element list>                                                   }
{       [ ON COMMIT <table commit action> ROWS ]                               }
{ <table commit action> ::= PRESERVE | DELETE                                  }
function TSqlParser.ParseTemporaryTableDeclaration: TSqlTemporaryTableDeclaration;
begin
  Assert(FTokenType = ttLOCAL);
  GetNextToken;
  ExpectKeyword(ttTEMPORARY, SQL_KEYWORD_TEMPORARY);
  ExpectKeyword(ttTABLE, SQL_KEYWORD_TABLE);
  Result := TSqlTemporaryTableDeclaration.Create;
  with Result do
    try
      TableName := ParseQualifiedLocalTableName;
      Elements := ParseTableElementList;
      if SkipToken(ttON) then
        begin
          ExpectKeyword(ttCOMMIT, SQL_KEYWORD_COMMIT);
          if SkipToken(ttPRESERVE) then
            CommitAction := stcPreserveRows else
          if SkipToken(ttDELETE) then
            CommitAction := stcDeleteRows
          else
            ParseError('PRESERVE or DELETE expected');
          ExpectKeyword(ttROWS, SQL_KEYWORD_ROWS);
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <ordering specification> ::= ASC | DESC                                      }
function TSqlParser.ParseOrderingSpecification: TSqlOrderSpecification;
begin
  case FTokenType of
    ttASC  : Result := sosAscending;
    ttDESC : Result := sosDescending;
  else
    Result := sosUndefined;
  end;
  if Result <> sosUndefined then
    GetNextToken;
end;

{ SQL2003:                                                                     }
{ <null ordering> ::= NULLS FIRST | NULLS LAST                                 }
function TSqlParser.ParseNullOrdering: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL92:                                                                       }
{ <sort key> ::= <column name> | <unsigned integer>                            }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <sort key> ::= <value expression>                                            }
function TSqlParser.ParseSortKey: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <sort specification> ::=                                                     }
{     <sort key> [ <collate clause> ] [ <ordering specification> ]             }
{                                                                              }
{ SQL99:                                                                       }
{ <sort specification> ::=                                                     }
{     <sort key> [ <ordering specification> ]                                  }
{                                                                              }
{ SQL2003:                                                                     }
{ <sort specification> ::=                                                     }
{     <sort key> [ <ordering specification> ] [ <null ordering> ]              }
function TSqlParser.ParseSortSpecification: TSqlSortSpecification;
begin
  Result := TSqlSortSpecification.Create;
  with Result do
    try
      if FTokenType = ttUnsignedInteger then
        begin
          ColumnKey := FLexer.TokenInt64;
          GetNextToken;
        end
      else
        ColumnName := ParseColumnName;
      CollateClause := ParseCollateClause;
      OrderSpec := ParseOrderingSpecification;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <sort specification list> ::=                                                }
{     <sort specification> [ ( <comma> <sort specification> )... ]             }
function TSqlParser.ParseSortSpecificationList: TSqlSortSpecificationArray;
begin
  Result := nil;
  repeat
    Append(ObjectArray(Result), ParseSortSpecification);
  until not SkipToken(ttComma);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <order by clause> ::= ORDER BY <sort specification list>                     }
function TSqlParser.ParseOrderByClause: TSqlSortSpecificationArray;
begin
  if SkipToken(ttORDER) then
    begin
      ExpectKeyword(ttBY, SQL_KEYWORD_BY);
      try
        Result := ParseSortSpecificationList;
      except
        FreeObjectArray(Result);
        raise;
      end;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <direct select statement: multiple rows> ::=                                 }
{     <query expression> [ <order by clause> ]                                 }
{                                                                              }
{ SQL2003:                                                                     }
{ <direct select statement: multiple rows> ::=                                 }
{     <cursor specification>                                                   }
function TSqlParser.ParseDirectSelectStatementMultipleRows: ASqlQueryExpression;
var C : TSqlSortSpecificationArray;
begin
  C := nil;
  Result := ParseQueryExpression;
  if not Assigned(Result) then
    exit;
  C := ParseOrderByClause;
  if Length(C) > 0 then
    Result := TSqlOrderByQuery.CreateEx(Result, C);
end;

{ SQL92/SQL99:                                                                 }
{ <direct SQL data statement> ::=                                              }
{       <delete statement: searched>                                           }
{     | <direct select statement: multiple rows>                               }
{     | <insert statement>                                                     }
{     | <update statement: searched>                                           }
{     | <temporary table declaration>                                          }
{                                                                              }
{ SQL2003:                                                                     }
{ <direct SQL data statement> ::=                                              }
{       <delete statement: searched>                                           }
{     | <direct select statement: multiple rows>                               }
{     | <insert statement>                                                     }
{     | <update statement: searched>                                           }
{     | <merge statement>                                                      }
{     | <temporary table declaration>                                          }
function TSqlParser.ParseDirectSqlDataStatement: ASqlStatement;
var Q : ASqlQueryExpression;
begin
  Result := nil;
  case FTokenType of
    ttDELETE  : Result := ParseDeleteStatementSearched;
    ttINSERT  : Result := ParseInsertStatement;
    ttUPDATE  : Result := ParseUpdateStatementSearched;
    ttDECLARE :
      case GetNextToken of
        ttLOCAL : Result := ParseTemporaryTableDeclaration;
      else
        ParseError('Declaration type expected');
      end;
    ttMERGE   : Result := ParseMergeStatement; // SQL2003
  else
    begin
      Q := ParseDirectSelectStatementMultipleRows;
      if Assigned(Q) then
        Result := TSqlSelectStatement.CreateEx(Q, nil)
      else
        Result := nil;
    end;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <set connection statement> ::= SET CONNECTION <connection object>            }
{ <connection object> ::= DEFAULT | <connection name>                          }
function TSqlParser.ParseSetConnectionStatement: TSqlSetConnectionStatement;
begin
  Assert(FTokenType = ttSET);
  GetNextToken;
  ExpectKeyword(ttCONNECTION, SQL_KEYWORD_CONNECTION);
  Result := TSqlSetConnectionStatement.Create;
  with Result do
    try
      if SkipToken(ttDEFAULT) then
        DefaultObj := True
      else
        ConnectionName := ExpectSimpleValueSpecification;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <SQL connection statement> ::=                                               }
{       <connect statement>                                                    }
{     | <set connection statement>                                             }
{     | <disconnect statement>                                                 }
function TSqlParser.ParseSqlConnectionStatement: ASqlConnectionStatement;
begin
  case FTokenType of
    ttCONNECT    : Result := ParseConnectStatement;
    ttSET        : Result := ParseSetConnectionStatement;
    ttDISCONNECT : Result := ParseDisconnectStatement;
  else
    Result := nil;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <level of isolation> ::=                                                     }
{       READ UNCOMMITTED                                                       }
{     | READ COMMITTED                                                         }
{     | REPEATABLE READ                                                        }
{     | SERIALIZABLE                                                           }
function TSqlParser.ParseLevelOfIsolation: TSqlLevelOfIsolation;
begin
  Result := sliUndefined;
  case FTokenType of
    ttREAD         :
      begin
        case GetNextToken of
          ttUNCOMMITTED : Result := sliReadUncommitted;
          ttCOMMITTED   : Result := sliReadCommitted;
        else
          ParseError('UNCOMMITTED or COMMITTED expected');
        end;
        GetNextToken;
      end;
    ttREPEATABLE   :
      begin
        GetNextToken;
        ExpectKeyword(ttREAD, SQL_KEYWORD_READ);
        Result := sliRepeatableRead;
      end;
    ttSERIALIZABLE :
      begin
        GetNextToken;
        Result := sliSerializable;
      end;
  else
    ParseError('Level of isolation expected');
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <isolation level> ::= ISOLATION LEVEL <level of isolation>                   }
function TSqlParser.ParseIsolationLevel: TSqlLevelOfIsolation;
begin
  Result := sliUndefined;
  if SkipToken(ttISOLATION) then
    begin
      ExpectKeyword(ttLEVEL, SQL_KEYWORD_LEVEL);
      Result := ParseLevelOfIsolation;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <transaction access mode> ::= READ ONLY | READ WRITE                         }
function TSqlParser.ParseTransactionAccessMode: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <diagnostics size> ::= DIAGNOSTICS SIZE <number of conditions>               }
{ <number of conditions> ::= <simple value specification>                      }
function TSqlParser.ParseDiagnosticsSize: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <transaction mode> ::=                                                       }
{       <isolation level>                                                      }
{     | <transaction access mode>                                              }
{     | <diagnostics size>                                                     }
function TSqlParser.ParseTransactionMode: TSqlTransactionMode;
begin
  Result := TSqlTransactionMode.Create;
  with Result do
    try
      if SkipToken(ttREAD) then
        begin
          case FTokenType of
            ttONLY  : AccessMode := staReadOnly;
            ttWRITE : AccessMode := staReadWrite;
          else
            ParseError('ONLY or WRITE expected');
          end;
          GetNextToken;
        end
      else if SkipToken(ttDIAGNOSTICS) then
        begin
          ExpectKeyword(ttSIZE, SQL_KEYWORD_SIZE);
          DiagnosticsSize := ParseSimpleValueSpecification;
        end
      else
        begin
          IsolationLevel := ParseIsolationLevel;
          if IsolationLevel = sliUndefined then
            ParseError('Transaction mode expected');
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL99/SQL2003:                                                               }
{ <transaction characteristics> ::=                                            }
{     TRANSACTION <transaction mode> [ ( <comma> <transaction mode> )... ]     }

{ SQL92:                                                                       }
{ <set transaction statement> ::=                                              }
{     SET TRANSACTION <transaction mode>                                       }
{         [ ( <comma> <transaction mode> )... ]                                }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <set transaction statement> ::=                                              }
{     SET [ LOCAL ] <transaction characteristics>                              }
function TSqlParser.ParseSetTransactionStatement: TSqlSetTransactionStatement;
var T : TSqlTransactionModeArray;
begin
  Assert(FTokenType = ttTRANSACTION);
  GetNextToken;
  try
    Append(ObjectArray(T), ParseTransactionMode);
    while SkipToken(ttComma) do
      Append(ObjectArray(T), ParseTransactionMode);
  except
    FreeObjectArray(T);
    raise;
  end;
  Result := TSqlSetTransactionStatement.Create;
  Result.TransactionModes := T;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <set constraints mode statement> ::=                                         }
{     SET CONSTRAINTS <constraint name list> ( DEFERRED | IMMEDIATE )          }
{ <constraint name list> ::=                                                   }
{     ALL | <constraint name> [ ( <comma> <constraint name> )... ]             }
function TSqlParser.ParseSetConstraintsModeStatement: TSqlSetConstraintsModeStatement;
var S : AnsiStringArray;
begin
  Assert(FTokenType = ttCONSTRAINTS);
  GetNextToken;
  Result := TSqlSetConstraintsModeStatement.Create;
  with Result do
    try
      All := SkipToken(ttALL);
      if not All then
        begin
          Append(S, ParseConstraintName);
          while SkipToken(ttComma) do
            Append(S, ParseConstraintName);
          NameList := S;
        end;
      if SkipToken(ttDEFERRED) then
        Deferred := True else
      if SkipToken(ttIMMEDIATE) then
        Immediate := True
      else
        UnexpectedToken;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <commit statement> ::= COMMIT [ WORK ]                                       }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <commit statement> ::= COMMIT [ WORK ] [ AND [ NO ] CHAIN ]                  }
function TSqlParser.ParseCommitStatement: TSqlCommitStatement;
begin
  Assert(FTokenType = ttCOMMIT);
  GetNextToken;
  Result := TSqlCommitStatement.Create;
  Result.Work := SkipToken(ttWORK);
  if FCompatibility >= spcSql99 then
    if SkipToken(ttAND) then
      begin
        SkipToken(ttNO);
        ExpectKeyword(ttCHAIN, SQL_KEYWORD_CHAIN);
      end;
end;

{ SQL99:                                                                       }
{ <savepoint specifier> ::= <savepoint name>                                   }
{ <savepoint name> ::= <identifier>                                            }
function TSqlParser.ParseSavepointSpecifier: TObject;
begin
  ExpectIdentifier;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <savepoint clause> ::= TO SAVEPOINT <savepoint specifier>                    }
function TSqlParser.ParseSavepointClause: TObject;
begin
  SkipToken(ttTO);
  SkipToken(ttSAVEPOINT);
  ParseSavepointSpecifier;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <rollback statement> ::= ROLLBACK [ WORK ]                                   }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <rollback statement> ::= ROLLBACK [ WORK ] [ AND [ NO ]  CHAIN ]             }
{     [ <savepoint clause> ]                                                   }
function TSqlParser.ParseRollbackStatement: TSqlRollbackStatement;
begin
  Assert(FTokenType = ttROLLBACK);
  GetNextToken;
  Result := TSqlRollbackStatement.Create;
  Result.Work := SkipToken(ttWORK);
end;

{ SQL92:                                                                       }
{ <SQL transaction statement> ::=                                              }
{       <set transaction statement>                                            }
{     | <set constraints mode statement>                                       }
{     | <commit statement>                                                     }
{     | <rollback statement>                                                   }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <SQL transaction statement> ::=                                              }
{       <start transaction statement>                                          }
{     |	<set transaction statement>                                            }
{     |	<set constraints mode statement>                                       }
{     |	<savepoint statement>                                                  }
{     |	<release savepoint statement>                                          }
{     |	<commit statement>                                                     }
{     |	<rollback statement>                                                   }
{                                                                              }
{ SQL99:                                                                       }
{ <start transaction statement> ::=                                            }
{     START TRANSACTION                                                        }
{         <transaction mode> [ ( <comma> <transaction mode> )...]              }
{ <savepoint statement> ::= SAVEPOINT <savepoint specifier>                    }
{ <release savepoint statement> ::= RELEASE SAVEPOINT <savepoint specifier>    }
function TSqlParser.ParseSqlTransactionStatement: ASqlStatement;
begin
  Result := nil;
  case FTokenType of
    ttCOMMIT   : Result := ParseCommitStatement;
    ttROLLBACK : Result := ParseRollbackStatement;
    ttSET      :
      case GetNextToken of
        ttTRANSACTION : Result := ParseSetTransactionStatement;
        ttCONSTRAINTS : Result := ParseSetConstraintsModeStatement;
      else
        ParseError('SET identifier expected');
      end;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <add column definition> ::=                                                  }
{     ADD [ COLUMN ] <column definition>                                       }
procedure TSqlParser.ParseAddColumnDefinition(const Alter: TSqlAlterTableStatement);
begin
  SkipToken(ttCOLUMN);
  with Alter do
    begin
      Action := satAddColumn;
      ColumnDefinition := ParseColumnDefinition;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <add table constraint definition> ::=                                        }
{     ADD <table constraint definition>                                        }
procedure TSqlParser.ParseAddTableConstraintDefinition(const Alter: TSqlAlterTableStatement);
begin
  with Alter do
    begin
      Action := satAddTableConstraint;
      TableConstraint := ParseTableConstraintDefinition;
    end;
end;

{ SQL92:                                                                       }
{ <alter add definition> ::=                                                   }
{     <add column definition> | <add table constraint definition>              }
{                                                                              }
{ SQL99/SQL2003: Not used                                                      }
procedure TSqlParser.ParseAlterAddDefinition(const Alter: TSqlAlterTableStatement);
begin
  Assert(FTokenType = ttADD);
  GetNextToken;
  case FTokenType of
    ttCOLUMN      : ParseAddColumnDefinition(Alter);
    ttUNIQUE,
    ttPRIMARY,
    ttREFERENCES,
    ttCHECK       : ParseAddTableConstraintDefinition(Alter);
  else
    UnexpectedToken;
  end;
end;

{ SQL2003:                                                                     }
{ <alter sequence generator restart option> ::=                                }
{     RESTART WITH <sequence generator restart value>                          }
{ <sequence generator restart value> ::= <signed numeric literal>              }
function TSqlParser.ParseAlterSequenceGeneratorRestartOption: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <alter identity column option> ::=                                           }
{       <alter sequence generator restart option>                              }
{     | SET <basic sequence generator option>                                  }
function TSqlParser.ParseAlterIdentityColumnAction: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <alter identity column specification> ::=                                    }
{     <alter identity column option>...                                        }
function TSqlParser.ParseAlterIdentityColumnSpecification: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <alter column action> ::=                                                    }
{       <set column default clause>                                            }
{     | <drop column default clause>                                           }
{ <set column default clause> ::= SET <default clause>                         }
{ <drop column default clause> ::= DROP DEFAULT                                }
{                                                                              }
{ SQL99:                                                                       }
{ <alter column action> ::=                                                    }
{       <set column default clause>                                            }
{     | <drop column default clause>                                           }
{     | <add column scope clause>                                              }
{     | <drop column scope clause>                                             }
{                                                                              }
{ SQL2003:                                                                     }
{ <alter column action> ::=                                                    }
{       <set column default clause>                                            }
{     | <drop column default clause>                                           }
{     | <add column scope clause>                                              }
{     | <drop column scope clause>                                             }
{     | <alter identity column specification>                                  }
function TSqlParser.ParseAlterColumnAction: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <alter column definition> ::=                                                }
{     ALTER [ COLUMN ] <column name> <alter column action>                     }
procedure TSqlParser.ParseAlterColumnDefinition(const Alter: TSqlAlterTableStatement);
begin
  SkipToken(ttCOLUMN);
  with Alter do
    begin
      ColumnName := ExpectColumnName;
      case FTokenType of
        ttSET  :
          begin
            GetNextToken;
            Action := satAlterColumnSetDefault;
            DefaultClause := ParseDefaultClause;
          end;
        ttDROP :
          begin
            GetNextToken;
            ExpectKeyword(ttDEFAULT, SQL_KEYWORD_DEFAULT);
            Action := satAlterColumnDropDefault;
          end;
      else
        ParseError('Alter column action expected');
      end;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <drop column definition> ::=                                                 }
{     DROP [ COLUMN ] <column name> <drop behavior>                            }
procedure TSqlParser.ParseDropColumnDefinition(const Alter: TSqlAlterTableStatement);
begin
  SkipToken(ttCOLUMN);
  with Alter do
    begin
      Action := satDropColumn;
      ColumnName := ExpectColumnName;
      DropBehavior := ParseDropBehavior;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <drop table constraint definition> ::=                                       }
{     DROP CONSTRAINT <constraint name> <drop behavior>                        }
procedure TSqlParser.ParseDropTableConstraintDefinition(const Alter: TSqlAlterTableStatement);
begin
  Assert(FTokenType = ttCONSTRAINT);
  GetNextToken;
  with Alter do
    begin
      Action := satDropTableConstraint;
      ConstraintName := ParseConstraintName;
      DropBehavior := ParseDropBehavior;
    end;
end;

{ SQL92:                                                                       }
{ <alter drop definition> ::=                                                  }
{     <drop column definition> | <drop table constraint definition>            }
{                                                                              }
{ SQL99/SQL2003: Not used                                                      }
procedure TSqlParser.ParseAlterDropDefinition(const Alter: TSqlAlterTableStatement);
begin
  Assert(FTokenType = ttDROP);
  if GetNextToken = ttCONSTRAINT then
    ParseDropTableConstraintDefinition(Alter)
  else
    ParseDropColumnDefinition(Alter);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <alter table action> ::=                                                     }
{       <add column definition>                                                }
{     | <alter column definition>                                              }
{     | <drop column definition>                                               }
{     | <add table constraint definition>                                      }
{     | <drop table constraint definition>                                     }
function TSqlParser.ParseAlterTableAction: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <alter table statement> ::= ALTER TABLE <table name> <alter table action>    }
function TSqlParser.ParseAlterTableStatement: TSqlAlterTableStatement;
begin
  Assert(FTokenType = ttTABLE);
  GetNextToken;
  Result := TSqlAlterTableStatement.Create;
  try
    Result.TableName := ExpectIdentifier;
    case FTokenType of
      ttADD   : ParseAlterAddDefinition(Result);
      ttALTER : ParseAlterColumnDefinition(Result);
      ttDROP  : ParseAlterDropDefinition(Result);
    else
      ParseError('Alter table action expected');
    end;
  except
    Result.Free;
    raise;
  end;
end;

{ SQL92:                                                                       }
{ <view definition> ::=                                                        }
{     CREATE VIEW <table name> [ <left paren> <view column list>               }
{                                   <right paren> ]                            }
{       AS <query expression>                                                  }
{       [ WITH [ <levels clause> ] CHECK OPTION ]                              }
{ <view column list> ::= <column name list>                                    }
{ <levels clause> ::= CASCADED | LOCAL                                         }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <view definition> ::=                                                        }
{     CREATE [ RECURSIVE ] VIEW <table name>                                   }
{     <view specification>                                                     }
{     AS <query expression> [ WITH [ <levels clause> ] CHECK OPTION ]          }
{ <view specification> ::=                                                     }
{     <regular view specification> | <referenceable view specification>        }
{ <regular view specification> ::=                                             }
{     [ <left paren> <view column list> <right paren> ]                        }
function TSqlParser.ParseViewDefinition: TSqlViewDefinitionStatement;
begin
  Assert(FTokenType = ttVIEW);
  GetNextToken;
  Result := TSqlViewDefinitionStatement.Create;
  with Result do
    try
      TableName := ParseTableName;
      if SkipToken(ttLeftParen) then
        begin
          ViewColumns := ParseColumnNameList;
          ExpectRightParen;
        end;
      ExpectKeyword(ttAS, SQL_KEYWORD_AS);
      QueryExpr := ParseQueryExpression;
      if SkipToken(ttWITH) then
        begin
          if SkipToken(ttCASCADED) then
            Cascaded := True else
          if SkipToken(ttLOCAL) then
            Local := True;
          ExpectKeyword(ttCHECK, SQL_KEYWORD_CHECK);
          ExpectKeyword(ttOPTION, SQL_KEYWORD_OPTION);
          WithCheckOpt := True;
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <action> ::=                                                                 }
{       SELECT                                                                 }
{     | DELETE                                                                 }
{     | INSERT [ <left paren> <privilege column list> <right paren> ]          }
{     | UPDATE [ <left paren> <privilege column list> <right paren> ]          }
{     | REFERENCES [ <left paren> <privilege column list> <right paren> ]      }
{     | USAGE                                                                  }
{ <privilege column list> ::= <column name list>                               }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <action> ::=                                                                 }
{       SELECT                                                                 }
{     | SELECT <left paren> <privilege column list> <right paren>              }
{     | SELECT <left paren> <privilege method list> <right paren>              }
{     | DELETE                                                                 }
{     | INSERT [ <left paren> <privilege column list> <right paren> ]          }
{     | UPDATE [ <left paren> <privilege column list> <right paren> ]          }
{     | REFERENCES [ <left paren> <privilege column list> <right paren> ]      }
{     | USAGE                                                                  }
{     | TRIGGER                                                                }
{     | UNDER                                                                  }
{     | EXECUTE                                                                }
function TSqlParser.ParseAction: TSqlAction;
begin
  Result := TSqlAction.Create;
  with Result do
    try
      case FTokenType of
        ttSELECT     : Action := sgaSELECT;
        ttDELETE     : Action := sgaDELETE;
        ttINSERT     : Action := sgaINSERT;
        ttUPDATE     : Action := sgaUPDATE;
        ttREFERENCES : Action := sgaREFERENCES;
        ttUSAGE      : Action := sgaUSAGE;
      else
        UnexpectedToken;
      end;
      if SkipAnyToken([ttINSERT, ttUPDATE, ttREFERENCES]) <> ttNone then
        begin
          if SkipToken(ttLeftParen) then
            begin
              Columns := ParseColumnNameList;
              ExpectRightParen;
            end;
        end
      else
        GetNextToken;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL99/SQL2003:                                                               }
{ <routine type> ::=                                                           }
{       ROUTINE                                                                }
{     | FUNCTION                                                               }
{     | PROCEDURE                                                              }
{	    |	[ INSTANCE | STATIC | CONSTRUCTOR ] METHOD                             }
function TSqlParser.ParseRoutineType: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL99:                                                                       }
{ <specific routine designator> ::=                                            }
{       SPECIFIC <routine type> <specific name>                                }
{     |	<routine type> <member name> [ FOR <user-defined type name> ]          }
{ <member name> ::= <schema qualified routine name> [ <data type list> ]       }

{ SQL92:                                                                       }
{ <object name> ::=                                                            }
{       [ TABLE ] <table name>                                                 }
{     | DOMAIN <domain name>                                                   }
{     | COLLATION <collation name>                                             }
{     | CHARACTER SET <character set name>                                     }
{     | TRANSLATION <translation name>                                         }
{                                                                              }
{ SQL99:                                                                       }
{ <object name> ::=                                                            }
{       [ TABLE ] <table name>                                                 }
{     | DOMAIN <domain name>                                                   }
{     | COLLATION <collation name>                                             }
{     | CHARACTER SET <character set name>                                     }
{     | MODULE <module name>                                                   }
{     | TRANSLATION <translation name>                                         }
{     | TYPE <user-defined type name>                                          }
{     | <specific routine designator>                                          }
{                                                                              }
{ SQL2003:                                                                     }
{ <object name> ::=                                                            }
{       [ TABLE ] <table name>                                                 }
{     | DOMAIN <domain name>                                                   }
{     | COLLATION <collation name>                                             }
{     | CHARACTER SET <character set name>                                     }
{     | TRANSLATION <transliteration name>                                     }
{     | TYPE <schema-resolved user-defined type name>                          }
{     | SEQUENCE <sequence generator name>                                     }
{     | <specific routine designator>                                          }
{ <sequence generator name> ::= <schema qualified name>                        }
function TSqlParser.ParseObjectName: TSqlObjectName;
begin
  Result := TSqlObjectName.Create;
  with Result do
    try
      case FTokenType of
        ttTABLE       :
          begin
            GetNextToken;
            ObjType := sotTABLE;
            Name := ParseTableName;
          end;
        ttDOMAIN      :
          begin
            GetNextToken;
            ObjType := sotDOMAIN;
            Name := ParseDomainName;
          end;
        ttCOLLATION   :
          begin
            GetNextToken;
            ObjType := sotCOLLATION;
            Name := ParseCollationName;
          end;
        ttCHARACTER   :
          begin
            GetNextToken;
            ExpectKeyword(ttSET, SQL_KEYWORD_SET);
            ObjType := sotCHARACTERSET;
            Name := ParseCharacterSetName;
          end;
        ttTRANSLATION :
          begin
            GetNextToken;
            ObjType := sotTRANSLATION;
            Name := ParseTranslationName;
          end;
      else
        begin
          ObjType := sotTABLE;
          Name := ParseTableName;
        end;
      end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <authorization identifier> ::= <identifier>                                  }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <authorization identifier> ::= <role name> | <user identifier>               }
function TSqlParser.ParseAuthorizationIdentifier: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <grantee> ::= PUBLIC | <authorization identifier>                            }
function TSqlParser.ParseGrantee: TSqlGrantee;
begin
  Result := TSqlGrantee.Create;
  with Result do
    try
      if SkipToken(ttPUBLIC) then
        GrantPublic := True
      else
        Authorization := ExpectIdentifier;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <privileges> ::= ALL PRIVILEGES | <action list>                              }
{ <action list> ::= <action> [ ( <comma> <action> )... ]                       }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <privileges> ::= <object privileges> ON <object name>                        }
{ <object privileges> ::= ALL PRIVILEGES | <action>                            }
{     [ ( <comma> <action> )... ]                                              }
function TSqlParser.ParsePrivileges: TSqlPrivileges;
var A : TSqlActionArray;
begin
  Result := TSqlPrivileges.Create;
  with Result do
    try
      AllPrivileges := SkipToken(ttALL);
      if AllPrivileges then
        ExpectToken(ttPRIVILEGES, 'PRIVILEGES expected')
      else
        begin
          try
            Append(ObjectArray(A), ParseAction);
            while SkipToken(ttComma) do
              Append(ObjectArray(A), ParseAction);
          except
            FreeObjectArray(A);
            raise;
          end;
          ActionList := A;
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ EXT:                                                                         }
{ <grantees> ::= <grantee> [ ( <comma> <grantee> )... ]                        }
function TSqlParser.ParseGrantees: TSqlGranteeArray;
var G : TSqlGranteeArray;
begin
  try
    Append(ObjectArray(G), ParseGrantee);
    while SkipToken(ttComma) do
      Append(ObjectArray(G), ParseGrantee);
  except
    FreeObjectArray(G);
    raise;
  end;
  Result := G;
end;

{ SQL99/SQL2003:                                                               }
{ <grantor> ::= CURRENT_USER | CURRENT_ROLE                                    }
function TSqlParser.ParseGrantor: Integer;
begin
  SkipToken(ttCURRENT_USER);
  //// SkipToken(ttCURRENT_ROLE);
  //// TODO
  Result := -1;
end;

{ SQL99:                                                                       }
{ <grant role statement> ::=                                                   }
{     GRANT <role granted> [ ( <comma> <role granted> )... ] TO <grantee>      }
{     [ ( <comma> <grantee> )... ]                                             }
{     [ WITH ADMIN OPTION ] [ GRANTED BY <grantor> ]                           }
{ <role granted> ::= <role name>                                               }
function TSqlParser.ParseGrantRoleStatement: TSqlGrantStatement;
begin
  SkipToken(ttGRANT);
  //// ParseRoleGranted;
  SkipToken(ttTO);
  ParseGrantee;
  SkipToken(ttWITH);
  SkipToken(ttADMIN);
  SkipToken(ttOPTION);
  //// SkipToken(ttGRANTED);
  SkipToken(ttBY);
  ParseGrantor;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <grant privilege statement> ::=                                              }
{     GRANT <privileges> TO <grantee> [ ( <comma> <grantee> )... ]             }
{     [ WITH HIERARCHY OPTION ] [ WITH GRANT OPTION ] [ GRANTED BY <grantor> ] }
function TSqlParser.ParseGrantPrivilegeStatement: TSqlGrantStatement;
begin
  SkipToken(ttGRANT);
  ParsePrivileges;
  SkipToken(ttTO);
  ParseGrantee;
  while SkipToken(ttComma) do
    ParseGrantee;
  SkipToken(ttWITH);
  //// SkipToken(ttHIERARCHY);
  SkipToken(ttOPTION);
  //// SkipToken(ttGRANTED);
  SkipToken(ttBY);
  ParseGrantor;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <grant statement> ::=                                                        }
{    GRANT <privileges> ON <object name>                                       }
{      TO <grantee> [ ( <comma> <grantee> )... ]                               }
{        [ WITH GRANT OPTION ]                                                 }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <grant statement> ::=                                                        }
{       <grant privilege statement>                                            }
{     | <grant role statement>                                                 }
function TSqlParser.ParseGrantStatement: TSqlGrantStatement;
begin
  Assert(FTokenType = ttGRANT);
  GetNextToken;
  Result := TSqlGrantStatement.Create;
  with Result do
    try
      Privileges := ParsePrivileges;
      ExpectKeyword(ttON, SQL_KEYWORD_ON);
      ObjName := ParseObjectName;
      ExpectKeyword(ttTO, SQL_KEYWORD_TO);
      Grantees := ParseGrantees;
      WithGrantOpt := SkipToken(ttWITH);
      if WithGrantOpt then
        begin
          ExpectKeyword(ttGRANT, SQL_KEYWORD_GRANT);
          ExpectKeyword(ttOPTION, SQL_KEYWORD_OPTION);
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <assertion definition> ::=                                                   }
{     CREATE ASSERTION <constraint name>                                       }
{         <assertion check>                                                    }
{         [ <constraint attributes> ]                                          }
{ <assertion check> ::= CHECK <left paren> <search condition> <right paren>    }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <assertion definition> ::=                                                   }
{     CREATE ASSERTION <constraint name>                                       }
{         CHECK <left paren> <search condition> <right paren>                  }
{         [ <constraint characteristics> ]                                     }
function TSqlParser.ParseAssertionDefinition: TSqlAssertionDefinitionStatement;
begin
  Assert(FTokenType = ttASSERTION);
  GetNextToken;
  Result := TSqlAssertionDefinitionStatement.Create;
  with Result do
    try
      ConstraintName := ParseConstraintName;
      ExpectKeyword(ttCHECK, SQL_KEYWORD_CHECK);
      ExpectLeftParen;
      Condition := ExpectSearchCondition;
      ExpectRightParen;
      ConstraintAttr := ParseConstraintAttributes;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <domain constraint> ::=                                                      }
{     [ <constraint name definition> ]                                         }
{     <check constraint definition> [ <constraint attributes> ]                }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <domain constraint> ::=                                                      }
{     [ <constraint name definition> ]                                         }
{     <check constraint definition> [ <constraint characteristics> ]           }
function TSqlParser.ParseDomainConstraint: TSqlDomainConstraint;
begin
  Result := TSqlDomainConstraint.Create;
  with Result do
    try
      ConstraintName := ParseConstraintNameDefinition;
      CheckConstraint := ParseCheckConstraintDefinition;
      ConstraintAttr := ParseConstraintAttributes;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <domain definition> ::=                                                      }
{     CREATE DOMAIN <domain name>                                              }
{         [ AS ] <data type>                                                   }
{       [ <default clause> ]                                                   }
{       [ <domain constraint>... ]                                             }
{       [ <collate clause> ]                                                   }
function TSqlParser.ParseDomainDefinition: TSqlDomainDefinitionStatement;
var C : TSqlDomainConstraintArray;
    D : TSqlDomainConstraint;
begin
  Assert(FTokenType = ttDOMAIN);
  GetNextToken;
  Result := TSqlDomainDefinitionStatement.Create;
  with Result do
    try
      DomainName := ParseDomainName;
      SkipToken(ttAS);
      DataType := TSqlDataTypeDefinition.Create;
      ExpectDataType(DataType);
      DefaultClause := ParseDefaultClause;
      repeat
        D := ParseDomainConstraint;
        if Assigned(D) then
          Append(ObjectArray(C), D);
      until not Assigned(D);
      DomainConstraints := C;
      CollateClause := ParseCollateClause;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <character set source> ::= GET <existing character set name>                 }
{ <existing character set name> ::=                                            }
{       <standard character repertoire name>                                   }
{     | <implementation-defined character repertoire name>                     }
{     | <schema character set name>                                            }
{ <standard character repertoire name> ::= <character set name>                }
{ <implementation-defined character repertoire name> ::= <character set name>  }
{ <schema character set name> ::= <character set name>                         }
{ <limited collation definition> ::= COLLATION FROM <collation source>         }

{ SQL92:                                                                       }
{ <character set definition> ::=                                               }
{     CREATE CHARACTER SET <character set name>                                }
{         [ AS ] <character set source>                                        }
{         [ <collate clause> | <limited collation definition> ]                }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <character set definition> ::=                                               }
{     CREATE CHARACTER SET <character set name>                                }
{         [ AS ] <character set source>                                        }
{         [ <collate clause> ]                                                 }
function TSqlParser.ParseCharacterSetDefinition: TSqlCharacterSetDefinition;
begin
  Result := TSqlCharacterSetDefinition.Create;
  with Result do
    try
      CharSetName := ParseCharacterSetName;
      SkipToken(ttAS);
      ExpectKeyword(ttGET, SQL_KEYWORD_GET);
      SourceCharSet := ParseCharacterSetName;
      CollateClause := ParseCollateClause;
      if SkipToken(ttCOLLATION) then
        begin
          ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);
          CollationSource := ParseCollationSource;
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL99/SQL2003:                                                               }
{ <parameter mode> ::= IN | OUT | INOUT                                        }
function TSqlParser.ParseParameterMode: TSqlParameterMode;
begin
  case FTokenType of
    ttIN    : Result := spmIn;
    ttOUT   : Result := spmOut;
    ttINOUT : Result := spmInOut;
  else
    Result := spmUndefined;
  end;
  if Result <> spmUndefined then
    GetNextToken;
end;

{ SQL99/SQL2003:                                                               }
{ <SQL parameter name> ::= <identifier>                                        }
function TSqlParser.ParseSqlParameterName: AnsiString;
begin
  Result := ParseIdentifier;
end;

{ SQL99/SQL2003:                                                               }
{ <parameter type> ::= <data type> [ <locator indication> ]                    }
function TSqlParser.ParseParameterType: TObject;
begin
  ExpectDataType(nil);
  ParseLocatorIndication;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <SQL parameter declaration> ::=                                              }
{     [ <parameter mode> ] [ <SQL parameter name> ]                            }
{     <parameter type> [ RESULT ]                                              }
function TSqlParser.ParseSqlParameterDeclaration: TObject;
begin
  ParseParameterMode;
  ParseSqlParameterName;
  ParseParameterType;
  SkipToken(ttRESULT);
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <SQL parameter declaration list> ::=                                         }
{     <left paren> [ <SQL parameter declaration>                               }
{     [ ( <comma> <SQL parameter declaration> )... ] ] <right paren>           }
function TSqlParser.ParseSqlParameterDeclarationList: TObject;
begin
  ExpectLeftParen;
  ParseSqlParameterDeclaration;
  while SkipToken(ttComma) do
    begin
      ParseSqlParameterDeclaration;
    end;
  ExpectRightParen;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <language clause> ::= LANGUAGE <language name>                               }
{ <language name> ::= ADA | C | COBOL | FORTRAN | MUMPS | PASCAL | PLI | SQL   }
function TSqlParser.ParseLanguageClause: TObject;
begin
  //// SkipToken(ttLANGUAGE);
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <parameter style clause> ::= PARAMETER STYLE <parameter style>               }
{ <parameter style> ::= SQL | GENERAL                                          }
function TSqlParser.ParseParameterStyleClause: TObject;
begin
  //// SkipToken(ttPARAMETER);
  //// SkipToken(ttSTYLE);
  SkipToken(ttSQL);
  //// SkipToken(ttGENERAL);
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <deterministic characteristic> ::= DETERMINISTIC | NOT DETERMINISTIC         }
function TSqlParser.ParseDeterministicCharacteristic: Integer;
begin
  SkipToken(ttNOT);
  //// SkipToken(ttDETERMINISTIC);
  //// TODO
  Result := -1;
end;

{ SQL99:                                                                       }
{ <SQL-data access indication> ::=                                             }
{       NO SQL                                                                 }
{     | CONTAINS SQL                                                           }
{     | READS SQL DATA                                                         }
{     | MODIFIES SQL DATA                                                      }
function TSqlParser.ParseSQLDataAccessIndication: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL99:                                                                       }
{ <null-call clause> ::=                                                       }
{       RETURNS NULL ON NULL INPUT                                             }
{     | CALLED ON NULL INPUT                                                   }
function TSqlParser.ParseNullCallClause: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL99:                                                                       }
{ <dynamic result sets characteristic> ::=                                     }
{     DYNAMIC RESULT SETS <maximum dynamic result sets>                        }
{ <maximum dynamic result sets> ::= <unsigned integer>                         }
function TSqlParser.ParseDynamicResultSetsCharacteristic: TObject;
begin
  //// SkipToken(ttDYNAMIC);
  SkipToken(ttRESULT);
  SkipToken(ttSET);
  ExpectUnsignedInteger;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <savepoint level indication> ::= NEW SAVEPOINT LEVEL | OLD SAVEPOINT LEVEL   }
function TSqlParser.ParseSavepointLevelIndication: Integer;
begin
  //// TODO
  Result := -1;
end;

{ SQL99:                                                                       }
{ <routine characteristic> ::=                                                 }
{       <language clause>                                                      }
{     | <parameter style clause>                                               }
{     | SPECIFIC <specific name>                                               }
{     | <deterministic characteristic>                                         }
{     | <SQL-data access indication>                                           }
{     | <null-call clause>                                                     }
{     | <dynamic result sets characteristic>                                   }
{                                                                              }
{ SQL2003:                                                                     }
{ <routine characteristic> ::=                                                 }
{       <language clause>                                                      }
{     | <parameter style clause>                                               }
{     | SPECIFIC <specific name>                                               }
{     | <deterministic characteristic>                                         }
{     | <SQL-data access indication>                                           }
{     | <null-call clause>                                                     }
{     | <dynamic result sets characteristic>                                   }
{     | <savepoint level indication>                                           }
function TSqlParser.ParseRoutineCharacteristic: TObject;
begin
  //// SkipToken(ttSPECIFIC);
  ParseLanguageClause;
  ParseParameterStyleClause;
  ParseDeterministicCharacteristic;
  ParseSQLDataAccessIndication;
  ParseNullCallClause;
  ParseDynamicResultSetsCharacteristic;
  ParseSavepointLevelIndication;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <routine characteristics> ::= [ <routine characteristic>... ]                }
function TSqlParser.ParseRoutineCharacteristics: TObject;
begin
  ParseRoutineCharacteristic;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <external routine name> ::= <identifier> | <character string literal>        }
{ <external security clause> ::=                                               }
{       EXTERNAL SECURITY DEFINER                                              }
{     | EXTERNAL SECURITY INVOKER                                              }
{     | EXTERNAL SECURITY IMPLEMENTATION DEFINED                               }

{ SQL99/SQL2003:                                                               }
{ <external body reference> ::=                                                }
{     EXTERNAL [ NAME <external routine name> ]                                }
{         [ <parameter style clause> ]                                         }
{         [ <transform group specification> ]                                  }
{         [ <external security clause> ]                                       }
function TSqlParser.ParseExternalBodyReference: TObject;
begin
  Assert(FTokenType = ttEXTERNAL);
  GetNextToken;
  if SkipToken(ttNAME) then
    begin
      // ParseExternalRoutineName;
    end;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <SQL routine body> ::= <SQL procedure statement>                             }
function TSqlParser.ParseSQLRoutineBody: TObject;
begin
  ParseSqlProcedureStatement;
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <SQL routine spec> ::= [ <rights clause> ] <SQL routine body>                }
{ <rights clause> ::= SQL SECURITY INVOKER | SQL SECURITY DEFINER              }

{ SQL99:                                                                       }
{ <routine body> ::=                                                           }
{       <SQL routine body>                                                     }
{     | <external body reference>                                              }
{                                                                              }
{ SQL2003:                                                                     }
{ <routine body> ::=                                                           }
{       <SQL routine spec>                                                     }
{     | <external body reference>                                              }
function TSqlParser.ParseRoutineBody: TObject;
begin
  if SkipToken(ttEXTERNAL) then
    Result := ParseExternalBodyReference
  else
    Result := ParseSqlProcedureStatement;
end;

{ SQL99/SQL2003:                                                               }
{ <SQL-invoked procedure> ::=                                                  }
{     PROCEDURE <schema qualified routine name>                                }
{     <SQL parameter declaration list> <routine characteristics>               }
{     <routine body>                                                           }
function TSqlParser.ParseSqlInvokedProcedure: ASqlStatement;
begin
  Assert(FTokenType = ttPROCEDURE);
  GetNextToken;
  ParseSchemaQualifiedRoutineName;
  ParseSqlParameterDeclarationList;
  ParseRoutineCharacteristics;
  ParseRoutineBody;
  //// TODO
  Result := nil;
end;

{ <locator indication> ::= AS LOCATOR                                          }
function TSqlParser.ParseLocatorIndication: Boolean;
begin
  if SkipToken(ttAS) then
    begin
      ExpectKeyword(ttLOCATOR, SQL_KEYWORD_LOCATOR);
      Result := True;
    end
  else
    Result := False;
end;

{ SQL99/SQL2003:                                                               }
{ <result cast> ::= CAST FROM <result cast from type>                          }
{ <result cast from type> ::= <data type> [ <locator indication> ]             }
function TSqlParser.ParseResultCast: TObject;
begin
  if SkipToken(ttCAST) then
    begin
      ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);
      ExpectDataType(nil);
      ParseLocatorIndication;
    end;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <returns data type> ::= <data type> [ <locator indication> ]                 }
function TSqlParser.ParseReturnsDataType: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL2003:                                                                     }
{ <returns type> ::=                                                           }
{       <returns data type> [ <result cast> ]                                  }
{     | <returns table type>                                                   }
{ <returns table type> ::= TABLE <table function column list>                  }
function TSqlParser.ParseReturnsType: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <returns clause> ::= RETURNS <returns data type> [ <result cast> ]           }
{                                                                              }
{ SQL2003:                                                                     }
{ <returns clause> ::= RETURNS <returns type>                                  }
function TSqlParser.ParseReturnsClause: TObject;
begin
  ExpectKeyword(ttRETURNS, SQL_KEYWORD_RETURNS);
  ExpectDataType(nil);
  ParseLocatorIndication;
  ParseResultCast;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <dispatch clause> ::= STATIC DISPATCH                                        }
function TSqlParser.ParseDispatchClause: Boolean;
begin
  if SkipToken(ttSTATIC) then
    begin
      ExpectKeyword(ttDISPATCH, SQL_KEYWORD_DISPATCH);
      Result := True;
    end
  else
    Result := False;
end;

{ SQL99/SQL2003:                                                               }
{ <function specification> ::=                                                 }
{     FUNCTION <schema qualified routine name>                                 }
{         <SQL parameter declaration list>                                     }
{         <returns clause>                                                     }
{         <routine characteristics>                                            }
{         [ <dispatch clause> ]                                                }
function TSqlParser.ParseFunctionSpecification: ASqlStatement;
begin
  Assert(FTokenType = ttFUNCTION);
  GetNextToken;
  ParseSchemaQualifiedRoutineName;
  ParseSqlParameterDeclarationList;
  ParseReturnsClause;
  ParseRoutineCharacteristics;
  ParseDispatchClause;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <method specification designator> ::=                                        }
{     [ INSTANCE | STATIC | CONSTRUCTOR ] METHOD <method name>                 }
{         <SQL parameter declaration list> [ <returns clause> ]                }
{         FOR <user-defined type name>                                         }
{ <schema qualified type name> ::=                                             }
{     [ <schema name> <period> ] <qualified identifier>                        }
{                                                                              }
{ SQL2003:                                                                     }
{ <method specification designator> ::=                                        }
{       SPECIFIC METHOD <specific method name>                                 }
{     |	[ INSTANCE | STATIC | CONSTRUCTOR ] METHOD <method name>               }
{           <SQL parameter declaration list>                                   }
{           [ <returns clause> ]                                               }
{           FOR <schema-resolved user-defined type name>                       }
function TSqlParser.ParseMethodSpecificationDesignator: ASqlStatement;
begin
  SkipToken(ttMETHOD);
  ParseMethodName;
  ParseSqlParameterDeclarationList;
  ParseReturnsClause;
  SkipToken(ttFOR);
  ParseSchemaQualifiedTypeName;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <SQL-invoked function> ::=                                                   }
{	    ( <function specification> | <method specification designator> )         }
{     <routine body>                                                           }
function TSqlParser.ParseSqlInvokedFunction: ASqlStatement;
begin
  case FTokenType of
    ttFUNCTION     : Result := ParseFunctionSpecification;
    ttINSTANCE,
    ttSTATIC,
    ttCONSTRUCTOR,
    ttMETHOD       : Result := ParseMethodSpecificationDesignator;
  else
    Result := nil;
  end;
end;

{ SQL99/SQL2003:                                                               }
{ <schema routine> ::= <schema procedure> | <schema function>                  }
{ <schema procedure> ::= CREATE <SQL-invoked procedure>                        }
{ <schema function> ::= CREATE <SQL-invoked function>                          }
function TSqlParser.ParseSchemaRoutine: ASqlStatement;
begin
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <trigger action time> ::= BEFORE | AFTER                                     }
function TSqlParser.ParseTriggerActionTime: Integer;
begin
  case FTokenType of
    ttBEFORE : ;
    ttAFTER  : ;
  end;
  //// TODO
  Result := -1;
end;

{ SQL99/SQL2003:                                                               }
{ <trigger column list> ::= <column name list>                                 }
function TSqlParser.ParseTriggerColumnList: AnsiStringArray;
begin
  Result := ParseColumnNameList;
end;

{ SQL99/SQL2003:                                                               }
{ <trigger event> ::= INSERT | DELETE | UPDATE [ OF <trigger column list> ]    }
function TSqlParser.ParseTriggerEvent: TObject;
begin
  //// TODO
  Result := nil;
  case FTokenType of
    ttINSERT : ;
    ttDELETE : ;
    ttUPDATE :
      begin
        GetNextToken;
        if SkipToken(ttOF) then
          ParseTriggerColumnList;
      end;
  else
    Result := nil;
  end;
end;

{ SQL99/SQL2003:                                                               }
{ <triggered SQL statement> ::=                                                }
{       <SQL procedure statement>                                              }
{     |	BEGIN ATOMIC ( <SQL procedure statement> <semicolon> )...  END         }
function TSqlParser.ParseTriggeredSqlStatement: TObject;
begin
  if SkipToken(ttBEGIN) then
    begin
      ExpectKeyword(ttATOMIC, SQL_KEYWORD_ATOMIC);
      ParseSqlProcedureStatement;
      ExpectToken(ttSemicolon, '; expected');
      ExpectKeyword(ttEND, SQL_KEYWORD_END);
    end
  else
    ParseSqlProcedureStatement;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <triggered action> ::=                                                       }
{     [ FOR EACH ( ROW | STATEMENT ) ]                                         }
{     [ WHEN <left paren> <search condition> <right paren> ]                   }
{     <triggered SQL statement>                                                }
function TSqlParser.ParseTriggeredAction: TObject;
begin
  if SkipToken(ttFOR) then
    begin
      ExpectKeyword(ttEACH, SQL_KEYWORD_EACH);
      case FTokenType of
        ttROW       : ;
        ttSTATEMENT : ;
      end;
    end;
  if SkipToken(ttWHEN) then
    begin
      ExpectLeftParen;
      ParseSearchCondition;
      ExpectRightParen;
    end;
  ParseTriggeredSqlStatement;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <trigger definition> ::=                                                     }
{     CREATE TRIGGER <trigger name> <trigger action time> <trigger event>      }
{         ON <table name>                                                      }
{         [ REFERENCING <old or new values alias list> ]                       }
{         <triggered action>                                                   }
{ <trigger name> ::= <schema qualified name>                                   }
{ <trigger column list> ::= <column name list>                                 }
{ <old or new values alias list> ::= <old or new values alias>...              }
{ <old or new values alias> ::=                                                }
{       OLD [ ROW ] [ AS ] <old values correlation name>                       }
{     | NEW [ ROW ] [ AS ] <new values correlation name>                       }
{     | OLD TABLE [ AS ] <old values table alias>                              }
{     | NEW TABLE [ AS ] <new values table alias>                              }
function TSqlParser.ParseTriggerDefinition: ASqlStatement;
begin
  Assert(FTokenType = ttTRIGGER);
  GetNextToken;
  ParseSchemaQualifiedName;
  ParseTriggerActionTime;
  ParseTriggerEvent;
  SkipToken(ttON);
  ParseTableName;
  {
  if SkipToken(ttREFERENCING) then
    begin
    end;
  }
  ParseTriggeredAction;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <transform definition> ::=                                                   }
{     CREATE ( TRANSFORM | TRANSFORMS ) FOR <user-defined type name>           }
{         <transform group>...                                                 }
{ <transform group> ::=                                                        }
{     <group name> <left paren> <transform element list> <right paren>         }
{ <transform element list> ::=                                                 }
{     <transform element> [ <comma> <transform element> ]                      }
{ <transform element> ::= <to sql> | <from sql>                                }
{ <to sql> ::= TO SQL WITH <to sql function>                                   }
{ <to sql function> ::= <specific routine designator>                          }
{ <from sql> ::= FROM SQL WITH <from sql function>                             }
{ <from sql function> ::= <specific routine designator>                        }
function TSqlParser.ParseTransformDefinition: ASqlStatement;
begin
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <user-defined type definition> ::= CREATE TYPE <user-defined type body>      }
{                                                                              }
{ SQL99:                                                                       }
{ <user-defined type body> ::=                                                 }
{     <user-defined type name> [ <subtype clause> ]                            }
{         [ AS <representation> ]                                              }
{         [ <instantiable clause> ] <finality>                                 }
{         [ <reference type specification> ]                                   }
{         [ <ref cast option>] [ <cast option> ]                               }
{         [ <method specification list> ]                                      }
{ <subtype clause> ::= UNDER <supertype name>                                  }
{ <supertype name> ::= <user-defined type>                                     }
{ <representation> ::= <predefined type> | <member list>                       }
{ <instantiable clause> ::= INSTANTIABLE | NOT INSTANTIABLE                    }
{ <finality> ::= FINAL | NOT FINAL                                             }
{ <ref cast option> ::= [ <cast to ref> ] [ <cast to type> ]                   }
{ <cast to ref> ::=                                                            }
{     CAST <left paren> SOURCE AS REF <right paren>                            }
{         WITH <cast to ref identifier>                                        }
{ <cast to ref identifier> ::= <identifier>                                    }
{ <cast to type> ::=                                                           }
{     CAST <left paren> REF AS SOURCE <right paren>                            }
{         WITH <cast to type identifier>                                       }
{ <cast to type identifier> ::= <identifier>                                   }
{ <cast option> ::= [ <cast to distinct> ] [ <cast to source> ]                }
{ <cast to distinct> ::=                                                       }
{     CAST <left paren> SOURCE AS DISTINCT <right paren>                       }
{         WITH <cast to distinct identifier>                                   }
{ <cast to distinct identifier> ::= <identifier>                               }
{ <cast to source> ::=                                                         }
{     CAST <left paren> DISTINCT AS SOURCE <right paren>                       }
{         WITH <cast to source identifier>                                     }
{ <cast to source identifier> ::= <identifier>                                 }
{ <reference type specification> ::=                                           }
{       <user-defined representation>                                          }
{     | <derived representation>                                               }
{     | <system-generated representation>                                      }
{ <user-defined representation> ::= REF USING <predefined type>                }
{ <derived representation> ::= REF FROM <list of attributes>                   }
{ <list of attributes> ::=                                                     }
{     <left paren> <attribute name>                                            }
{         [ ( <comma> <attribute name> )...] <right paren>                     }
{ <system-generated representation> ::= REF IS SYSTEM GENERATED                }
{ <method specification list> ::=                                              }
{     <method specification> [ ( <comma> <method specification> )... ]         }
{ <method specification> ::=                                                   }
{     <original method specification> | <overriding method specification>      }
{ <original method specification> ::=                                          }
{     <partial method specification> [ SELF AS RESULT ] [ SELF AS LOCATOR ]    }
{     [ <method characteristics> ]                                             }
{ <method characteristics> ::= <method characteristic>...                      }
{ <method characteristic> ::=                                                  }
{       <language clause>                                                      }
{     |	<parameter style clause>                                               }
{     |	<deterministic characteristic>                                         }
{     |	<SQL-data access indication>                                           }
{     |	<null-call clause>                                                     }
{                                                                              }
{ SQL2003:                                                                     }
{ <user-defined type body> ::=                                                 }
{     <schema-resolved user-defined type name> [ <subtype clause> ]            }
{         [ AS <representation> ]                                              }
{         [ <user-defined type option list> ]                                  }
{         [ <method specification list> ]                                      }
function TSqlParser.ParseUserDefinedTypeDefinition: ASqlStatement;
begin
  Assert(FTokenType = ttTYPE);
  GetNextToken;
  ParseUserDefinedTypeName;
  {
  ParseSubTypeClause;
  if SkipToken(ttAS) then
    ParseRepresentation;
  ParseInsantiableClause;
  ParseFinality;
  ParseReferenceTypeSpecification;
  ParseRefCastOption;
  }
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <role definition> ::= CREATE ROLE <role name> [ WITH ADMIN <grantor> ]       }
{ <role name> ::= <identifier>                                                 }
function TSqlParser.ParseRoleDefinition: ASqlStatement;
begin
  Assert(FTokenType = ttROLE);
  GetNextToken;
  ExpectIdentifier;
  if SkipToken(ttWITH) then
    begin
      ExpectKeyword(ttADMIN, SQL_KEYWORD_ADMIN);
      ParseGrantor;
    end;
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <schema element> ::=                                                         }
{       <domain definition>                                                    }
{     | <table definition>                                                     }
{     | <view definition>                                                      }
{     | <grant statement>                                                      }
{     | <assertion definition>                                                 }
{     | <character set definition>                                             }
{     | <collation definition>                                                 }
{     | <translation definition>                                               }
{                                                                              }
{ SQL99:                                                                       }
{ <schema element> ::=                                                         }
{       <table definition>                                                     }
{     | <view definition>                                                      }
{     | <domain definition>                                                    }
{     | <character set definition>                                             }
{     | <collation definition>                                                 }
{     | <translation definition>                                               }
{     | <assertion definition>                                                 }
{     | <trigger definition>                                                   }
{     | <user-defined type definition>                                         }
{     | <schema routine>                                                       }
{     | <grant statement>                                                      }
{     | <role definition>                                                      }
{     | <user-defined cast definition>                                         }
{     | <user-defined ordering definition>                                     }
{     | <transform definition>                                                 }
{                                                                              }
{ SQL2003:                                                                     }
{ <schema element> ::=                                                         }
{       <table definition>                                                     }
{     | <view definition>                                                      }
{     | <domain definition>                                                    }
{     | <character set definition>                                             }
{     | <collation definition>                                                 }
{     | <transliteration definition>                                           }
{     | <assertion definition>                                                 }
{     | <trigger definition>                                                   }
{     | <user-defined type definition>                                         }
{     | <user-defined cast definition>                                         }
{     | <user-defined ordering definition>                                     }
{     | <transform definition>                                                 }
{     | <schema routine>                                                       }
{     | <sequence generator definition>                                        }
{     | <grant statement>                                                      }
{     | <role definition>                                                      }
{ <sequence generator definition> ::=                                          }
{     CREATE SEQUENCE <sequence generator name>                                }
{         [ <sequence generator options> ]                                     }
{ <sequence generator options> ::= <sequence generator option> ...             }
{ <sequence generator option> ::=                                              }
{       <sequence generator data type option>                                  }
{     | <common sequence generator options>                                    }
function TSqlParser.ParseSchemaElement: ASqlStatement;
begin
  Result := nil;
  case FTokenType of
    ttGRANT  : Result := ParseGrantStatement;
    ttCREATE :
      begin
        GetNextToken;
        case FTokenType of
          ttDOMAIN      : Result := ParseDomainDefinition;
          ttTABLE       : Result := ParseTableDefinition;
          ttVIEW        : Result := ParseViewDefinition;
          ttASSERTION   : Result := ParseAssertionDefinition;
          ttCHARACTER   :
            begin
              GetNextToken;
              ExpectKeyword(ttSET, SQL_KEYWORD_SET);
              Result := ParseCharacterSetDefinition;
            end;
          ttCOLLATION   : Result := ParseCollationDefinition;
          ttTRANSLATION : Result := ParseTranslationDefinition;
        else
          UnexpectedToken;
        end;
      end;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <schema name clause> ::=                                                     }
{       <schema name>                                                          }
{     | AUTHORIZATION <schema authorization identifier>                        }
{     | <schema name> AUTHORIZATION                                            }
{           <schema authorization identifier>                                  }
{ <schema authorization identifier> ::= <authorization identifier>             }
function TSqlParser.ParseSchemaNameClause: TSqlSchemaNameClause;
begin
  Result := TSqlSchemaNameClause.Create;
  with Result do
    try
      if SkipToken(ttAUTHORIZATION) then
        AuthIdentifier := ExpectIdentifier
      else
        begin
          SchemaName := ParseSchemaName;
          if SkipToken(ttAUTHORIZATION) then
            AuthIdentifier := ExpectIdentifier
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <schema definition> ::=                                                      }
{     CREATE SCHEMA <schema name clause>                                       }
{       [ <schema character set specification> ]                               }
{       [ <schema element>... ]                                                }
{ <schema character set specification> ::=                                     }
{     DEFAULT CHARACTER SET <character set specification>                      }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <schema definition> ::=                                                      }
{     CREATE SCHEMA <schema name clause>                                       }
{       [ <schema character set or path> ]                                     }
{       [ <schema element>... ]                                                }
{                                                                              }
{ SQL99:                                                                       }
{ <schema name clause> ::=                                                     }
{       <schema name>                                                          }
{     | AUTHORIZATION <schema authorization identifier>                        }
{     | <schema name> AUTHORIZATION <schema authorization identifier>          }
{ <schema authorization identifier> ::= <authorization identifier>             }
{ <schema character set or path> ::=                                           }
{       <schema character set specification>                                   }
{     | <schema path specification>                                            }
{     | <schema character set specification> <schema path specification>       }
{     | <schema path specification> <schema character set specification>       }
{ <schema character set specification> ::=                                     }
{     DEFAULT CHARACTER SET <character set specification>                      }
{ <schema path specification> ::= <path specification>                         }
function TSqlParser.ParseSchemaDefinition: TSqlSchemaDefinitionStatement;
var D : ASqlStatement;
    E : ASqlStatementArray;
begin
  Assert(FTokenType = ttSCHEMA);
  GetNextToken;
  Result := TSqlSchemaDefinitionStatement.Create;
  with Result do
    try
      SchemaName := ParseSchemaNameClause;
      if SkipToken(ttDEFAULT) then
        begin
          ExpectKeyword(ttCHARACTER, SQL_KEYWORD_CHARACTER);
          ExpectKeyword(ttSET, SQL_KEYWORD_SET);
          CharSetSpec := ParseCharacterSetSpecification;
        end;
      repeat
        D := ParseSchemaElement;
        if Assigned(D) then
          Append(ObjectArray(E), D);
      until not Assigned(D);
      Elements := E;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <collation source> ::=                                                       }
{       <collating sequence definition>                                        }
{     | <translation collation>                                                }
{ <collating sequence definition> ::=                                          }
{       <external collation>                                                   }
{     | <schema collation name>                                                }
{     | DESC <left paren> <collation name> <right paren>                       }
{     | DEFAULT                                                                }
{ <translation collation> ::=                                                  }
{     TRANSLATION <translation name>                                           }
{         [ THEN COLLATION <collation name> ]                                  }
{ <external collation> ::=                                                     }
{     EXTERNAL <left paren> <quote> <external collation name> <quote>          }
{         <right paren>                                                        }
{ <external collation name> ::=                                                }
{       <standard collation name>                                              }
{     | <implementation-defined collation name>                                }
{ <standard collation name> ::= <collation name>                               }
{ <schema collation name> ::= <collation name>                                 }
{                                                                              }
{ SQL99/SQL2003: Not used                                                      }
function TSqlParser.ParseCollationSource: TSqlCollationSource;
begin
  Result := TSqlCollationSource.Create;
  with Result do
    try
      case FTokenType of
        ttTRANSLATION :
          begin
            SourceType := scsTranslation;
            TranslationName := ParseTranslationName;
            if SkipToken(ttTHEN) then
              begin
                ExpectKeyword(ttCOLLATION, SQL_KEYWORD_COLLATION);
                RefCollationName := ParseCollationName;
              end;
          end;
        ttEXTERNAL    :
          begin
            SourceType := scsExternal;
            ExpectLeftParen;
            CheckToken(ttStringLiteral, 'Quoted collation name expected');
            RefCollationName := FLexer.TokenStr;
            ExpectRightParen;
          end;
        ttDESC        :
          begin
            SourceType := scsDesc;
            ExpectLeftParen;
            CheckToken(ttStringLiteral, 'Quoted collation name expected');
            RefCollationName := FLexer.TokenStr;
            ExpectRightParen;
          end;
        ttDEFAULT     : SourceType := scsDefault;
      else
        begin
          SourceType := scsSchemaCollation;
          RefCollationName := ParseCollationName;
        end;
      end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <collation definition> ::=                                                   }
{     CREATE COLLATION <collation name> FOR <character set specification>      }
{       FROM <collation source> [ <pad attribute> ]                            }
{ <pad attribute> ::= NO PAD | PAD SPACE                                       }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <collation definition> ::=                                                   }
{     CREATE COLLATION <collation name> FOR <character set specification>      }
{     FROM <existing collation name> [ <pad characteristic> ]                  }
{ <pad characteristic> ::= NO PAD | PAD SPACE                                  }
function TSqlParser.ParseCollationDefinition: TSqlCollationDefinitionStatement;
begin
  Assert(FTokenType = ttCOLLATION);
  GetNextToken;
  Result := TSqlCollationDefinitionStatement.Create;
  with Result do
    try
      CollationName := ParseCollationName;
      ExpectKeyword(ttFOR, SQL_KEYWORD_FOR);
      ForSpec := ParseCharacterSetSpecification;
      ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);
      CollationSource := ParseCollationSource;
      if SkipToken(ttNO) then
        begin
          ExpectKeyword(ttPAD, SQL_KEYWORD_PAD);
          PadSpace := False;
        end else
      if SkipToken(ttPAD) then
        begin
          ExpectKeyword(ttSPACE, SQL_KEYWORD_SPACE);
          PadSpace := True;
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <translation specification> ::=                                              }
{       <external translation>                                                 }
{     | IDENTITY                                                               }
{     | <schema translation name>                                              }
{ <external translation> ::=                                                   }
{     EXTERNAL <left paren> <quote> <external translation name>                }
{     <quote> <right paren>                                                    }
{ <external translation name> ::=                                              }
{       <standard translation name>                                            }
{     | <implementation-defined translation name>                              }
{ <standard translation name> ::= <translation name>                           }
{ <implementation-defined translation name> ::= <translation name>             }
{ <schema translation name> ::= <translation name>                             }
{                                                                              }
{ SQL99/SQL2003: Not used                                                      }
function TSqlParser.ParseTranslationSpecification: TSqlTranslationSpecification;
begin
  Result := TSqlTranslationSpecification.Create;
  with Result do
    try
      case FTokenType of
        ttIDENTITY :
          begin
            GetNextToken;
            Identity := True;
          end;
        ttEXTERNAL :
          begin
            GetNextToken;
            ExpectLeftParen;
            CheckToken(ttStringLiteral, 'External translation name expected');
            Name := FLexer.TokenStr;
            GetNextToken;
            ExpectRightParen;
          end;
      else
        Name := ParseTranslationName;
      end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <translation definition> ::=                                                 }
{     CREATE TRANSLATION <translation name>                                    }
{       FOR <source character set specification>                               }
{         TO <target character set specification>                              }
{       FROM <translation source>                                              }
{ <source character set specification> ::= <character set specification>       }
{ <target character set specification> ::= <character set specification>       }
{ <translation source> ::= <translation specification>                         }
{                                                                              }
{ SQL99:                                                                       }
{ <translation source> ::= <existing translation name> | <translation routine> }
{ <existing translation name> ::= <translation name>                           }
{ <translation routine> ::= <specific routine designator>                      }
function TSqlParser.ParseTranslationDefinition: TSqlTranslationDefinitionStatement;
begin
  Assert(FTokenType = ttTRANSLATION);
  GetNextToken;
  Result := TSqlTranslationDefinitionStatement.Create;
  with Result do
    try
      TranslationName := ParseTranslationName;
      ExpectKeyword(ttFOR, SQL_KEYWORD_FOR);
      ForName := ParseCharacterSetSpecification;
      ExpectKeyword(ttTO, SQL_KEYWORD_TO);
      ToName := ParseCharacterSetSpecification;
      ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);
      TranslationSpec := ParseTranslationSpecification;
    except
      Result.Free;
      raise;
    end;
end;

(* TRANSACT-SQL / EXT:                                                        *)
(* <filespec> ::=                                                             *)
(* { (                                                                        *)
(*      NAME = logical_file_name ,                                            *)
(*      FILENAME = { 'os_file_name' | 'filestream_path' }                     *)
(*      [ , SIZE = size [ KB | MB | GB | TB ] ]                               *)
(*      [ , MAXSIZE = { max_size [ KB | MB | GB | TB ] | UNLIMITED } ]        *)
(*      [ , FILEGROWTH = growth_increment [ KB | MB | GB | TB | % ] ]         *)
(*   ) [ ,...n ] }                                                            *)
function TSqlParser.ParseDatabaseDefinitionFileSpec: TSqlDatabaseDefinitionFileSpec;
begin
  Result := TSqlDatabaseDefinitionFileSpec.Create;
  with Result do
    try
      ExpectKeyword(ttNAME, SQL_KEYWORD_NAME);
      ExpectEqualSign;
      LogicalFileName := ExpectIdentifier;
      while SkipToken(ttComma) do
        begin
          case FTokenType of
            ttFILENAME :
              begin
                GetNextToken;
                ExpectEqualSign;
                if FTokenType <> ttStringLiteral then
                  ParseError('String literal expected');
                OSFileName := FLexer.TokenStr;
                GetNextToken;
              end;
            ttSIZE :
              begin
                GetNextToken;
                ExpectEqualSign;
              end;
            ttMAXSIZE :
              begin
                GetNextToken;
                ExpectEqualSign;
              end;
          else
            ParseError('Database definition file specification field expected');
          end;
        end;
    except
      Result.Free;
      raise;
    end;
end;

(* TRANSACT-SQL / EXT:                                                        *)
(* <database definition> ::=                                                  *)
(* CREATE DATABASE database_name                                              *)
(*     [ ON                                                                   *)
(*        { [ PRIMARY ] [ <filespec> [ ,...n ]                                *)
(*        [ , <filegroup> [ ,...n ] ]                                         *)
(*    [ LOG ON { <filespec> [ ,...n ] } ] }                                   *)
(*    ]                                                                       *)
(*    [ COLLATE collation_name ]                                              *)
(*    [ WITH <external_access_option> ]                                       *)
(* ] [;]                                                                      *)
(* <filegroup> ::=                                                            *)
(* { FILEGROUP filegroup_name [ CONTAINS FILESTREAM ] [ DEFAULT ]             *)
(*    <filespec> [ ,...n ] }                                                  *)
(* <external_access_option> ::= {                                             *)
(*  [ DB_CHAINING { ON | OFF } ]                                              *)
(*  [ , TRUSTWORTHY { ON | OFF } ] }                                          *)
(*  <service_broker_option> ::= {                                             *)
(*   ENABLE_BROKER                                                            *)
(* | NEW_BROKER | ERROR_BROKER_CONVERSATIONS                                  *)
(*  }                                                                         *)
function TSqlParser.ParseDatabaseDefinition: TSqlDatabaseDefinitionStatement;
begin
  Assert(FTokenType = ttDATABASE);
  if not (spoExtendedSyntax in FOptions) then
    UnexpectedToken;
  GetNextToken;
  Result := TSqlDatabaseDefinitionStatement.Create;
  with Result do
    try
      DatabaseName := ExpectIdentifier;
      if SkipToken(ttON) then
        begin
          Primary := SkipToken(ttPRIMARY);
          FileSpec := ParseDatabaseDefinitionFileSpec;
        end;
      //if SkipToken(ttLOG) then
      //  begin
      //  end;
      if SkipToken(ttCOLLATE) then
        begin
        end;
      if SkipToken(ttWITH) then
        begin
        end;
    except
      Result.Free;
      raise;
    end;
end;

(* TRANSACT-SQL / EXT:                                                        *)
(* <login definition> ::=                                                     *)
(* CREATE LOGIN loginName { WITH <option_list1> | FROM <sources> }            *)
(* <option_list1> ::=                                                         *)
(*    PASSWORD = { 'password' | hashed_password HASHED } [ MUST_CHANGE ]      *)
(*    [ , <option_list2> [ ,... ] ]                                           *)
(* <option_list2> ::=                                                         *)
(*    SID = sid                                                               *)
(*    | DEFAULT_DATABASE = database                                           *)
(*    | DEFAULT_LANGUAGE = language                                           *)
(*    | CHECK_EXPIRATION = { ON | OFF}                                        *)
(*    | CHECK_POLICY = { ON | OFF}                                            *)
(*    | CREDENTIAL = credential_name                                          *)
(* <sources> ::=                                                              *)
(*    WINDOWS [ WITH <windows_options>[ ,... ] ]                              *)
(*    | CERTIFICATE certname                                                  *)
(*    | ASYMMETRIC KEY asym_key_name                                          *)
(* <windows_options> ::=                                                      *)
(*    DEFAULT_DATABASE = database                                             *)
(*    | DEFAULT_LANGUAGE = language                                           *)
function TSqlParser.ParseLoginDefinition: TSqlLoginDefinitionStatement;
begin
  Assert(FTokenType = ttLOGIN);
  if not (spoExtendedSyntax in FOptions) then
    UnexpectedToken;
  GetNextToken;
  Result := TSqlLoginDefinitionStatement.Create;
  with Result do
    try
      LoginName := ExpectIdentifier;
      if SkipToken(ttWITH) then
        begin
          if SkipToken(ttPASSWORD) then
            begin
              ExpectEqualSign;
              if FTokenType <> ttStringLiteral then
                ParseError('String literal expected');
              Password := FLexer.TokenStr;
              GetNextToken;
            end;
        end;
    except
      Result.Free;
      raise;
    end;
end;

(* TRANSACT-SQL / EXT:                                                        *)
(* CREATE USER user_name                                                      *)
(*    [ { { FOR | FROM }                                                      *)
(*      {                                                                     *)
(*        LOGIN login_name                                                    *)
(*        | CERTIFICATE cert_name                                             *)
(*        | ASYMMETRIC KEY asym_key_name                                      *)
(*      }                                                                     *)
(*      | WITHOUT LOGIN                                                       *)
(*    ]                                                                       *)
(*    [ WITH DEFAULT_SCHEMA = schema_name ]                                   *)
function TSqlParser.ParseUserDefinition: TSqlUserDefinitionStatement;
begin
  Assert(FTokenType = ttUSER);
  if not (spoExtendedSyntax in FOptions) then
    UnexpectedToken;
  GetNextToken;
  Result := TSqlUserDefinitionStatement.Create;
  with Result do
    try
      UserName := ExpectIdentifier(True);
      if SkipToken(ttFOR) or SkipToken(ttFROM) then
        begin
          if SkipToken(ttLOGIN) then
            begin
              LoginName := ExpectIdentifier(True);
            end;
        end;
      if SkipToken(ttWITH) then
        begin
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <SQL schema definition statement> ::=                                        }
{       <schema definition>                                                    }
{     | <table definition>                                                     }
{     | <view definition>                                                      }
{     | <grant statement>                                                      }
{     | <domain definition>                                                    }
{     | <character set definition>                                             }
{     | <collation definition>                                                 }
{     | <translation definition>                                               }
{     | <assertion definition>                                                 }
{                                                                              }
{ SQL99:                                                                       }
{ <SQL schema definition statement> ::=                                        }
{       <schema definition>                                                    }
{     | <table definition>                                                     }
{     | <view definition>                                                      }
{     | <SQL-invoked routine>                                                  }
{     | <grant statement>                                                      }
{     | <role definition>                                                      }
{     | <domain definition>                                                    }
{     | <character set definition>                                             }
{     | <collation definition>                                                 }
{     | <translation definition>                                               }
{     | <assertion definition>                                                 }
{     | <trigger definition>                                                   }
{     | <user-defined type definition>                                         }
{     | <user-defined cast definition>                                         }
{     | <user-defined ordering definition>                                     }
{     | <transform definition>                                                 }
{     | <SQL-server module definition>                                         }
{ <SQL-invoked routine> ::= <schema routine> | <module routine>                }
{ <module routine> ::= <module procedure> | <module function>                  }
{ <module procedure> ::= [ DECLARE ] <SQL-invoked procedure>                   }
{ <module function> ::= [ DECLARE ] <SQL-invoked function>                     }
{ <user-defined cast definition> ::=                                           }
{     CREATE CAST <left paren> <source data type>                              }
{         AS <target data type> <right paren>                                  }
{         WITH <cast function> [ AS ASSIGNMENT ]                               }
{ <source data type> ::= <data type>                                           }
{ <cast function> ::= <specific routine designator>                            }
{ <user-defined ordering definition> ::=                                       }
{     CREATE ORDERING FOR <user-defined type name> <ordering form>             }
{ <ordering form> ::= <equals ordering form> | <full ordering form>            }
{ <equals ordering form> ::= EQUALS ONLY BY <ordering category>                }
{ <ordering category> ::=                                                      }
{       <relative category>                                                    }
{     | <map category>                                                         }
{     | <state category>                                                       }
{ <relative category> ::= RELATIVE WITH <relative function specification>      }
{                                                                              }
{ SQL2003:                                                                     }
{ <SQL schema definition statement> ::=                                        }
{       <schema definition>                                                    }
{     | <table definition>                                                     }
{     | <view definition>                                                      }
{     | <SQL-invoked routine>                                                  }
{     | <grant statement>                                                      }
{     | <role definition>                                                      }
{     | <domain definition>                                                    }
{     | <character set definition>                                             }
{     | <collation definition>                                                 }
{     | <transliteration definition>                                           }
{     | <assertion definition>                                                 }
{     | <trigger definition>                                                   }
{     | <user-defined type definition>                                         }
{     | <user-defined cast definition>                                         }
{     | <user-defined ordering definition>                                     }
{     | <transform definition>                                                 }
{     | <sequence generator definition>                                        }
{                                                                              }
function TSqlParser.ParseSqlSchemaDefinitionStatement: ASqlStatement;
begin
  Result := nil;
  case FTokenType of
    ttGRANT  : Result := ParseGrantStatement;
    ttCREATE :
      case GetNextToken of
        ttSCHEMA      : Result := ParseSchemaDefinition;
        ttTABLE       : Result := ParseTableDefinition;
        ttVIEW        : Result := ParseViewDefinition;
        ttDOMAIN      : Result := ParseDomainDefinition;
        ttCHARACTER   :
          begin
            GetNextToken;
            ExpectKeyword(ttSET, SQL_KEYWORD_SET);
            Result := ParseCharacterSetDefinition;
          end;
        ttCOLLATION   : Result := ParseCollationDefinition;
        ttTRANSLATION : Result := ParseTranslationDefinition;
        ttASSERTION   : Result := ParseAssertionDefinition;
        ttDATABASE    : Result := ParseDatabaseDefinition;
      else
        UnexpectedToken;
      end;
  end;
end;

{ SQL92:                                                                       }
{ <revoke statement> ::=                                                       }
{     REVOKE [ GRANT OPTION FOR ]                                              }
{         <privileges>                                                         }
{         ON <object name>                                                     }
{       FROM <grantee> [ ( <comma> <grantee> )... ] <drop behavior>            }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <revoke statement> ::=                                                       }
{       <revoke privilege statement>                                           }
{     | <revoke role statement>                                                }
{                                                                              }
{ SQL99:                                                                       }
{ <revoke privilege statement> ::=                                             }
{	    REVOKE [ <revoke option extension> ] <privileges> FROM <grantee>         }
{     [ ( <comma> <grantee> )... ] [ GRANTED BY <grantor> ]                    }
{     <drop behavior>                                                          }
{ <revoke option extension> ::= GRANT OPTION FOR | HIERARCHY OPTION FOR        }
{ <revoke role statement> ::=                                                  }
{     REVOKE [ ADMIN OPTION FOR ] <role revoked>                               }
{     [ ( <comma> <role revoked> )... ]                                        }
{     FROM <grantee> [ ( <comma> <grantee> )... ]                              }
{     [ GRANTED BY <grantor> ] <drop behavior>                                 }
{ <role revoked> ::= <role name>                                               }
function TSqlParser.ParseRevokeStatement: TSqlRevokeStatement;
begin
  Assert(FTokenType = ttREVOKE);
  GetNextToken;
  if SkipToken(ttGRANT) then
    begin
      ExpectKeyword(ttOPTION, SQL_KEYWORD_OPTION);
      ExpectKeyword(ttFOR, SQL_KEYWORD_FOR);
    end;
  Result := TSqlRevokeStatement.Create;
  with Result do
    try
      Privileges := ParsePrivileges;
      ExpectKeyword(ttON, SQL_KEYWORD_ON);
      ObjName := ParseObjectName;
      ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);
      Grantees := ParseGrantees;
      DropBehavior := ParseDropBehavior;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <set domain default clause> ::= SET <default clause>                         }
procedure TSqlParser.ParseSetDomainDefaultClause(const A: TSqlAlterDomainStatement);
begin
  Assert(FTokenType = ttSET);
  GetNextToken;
  A.AlterType := sadSet;
  A.DefaultClause := ParseDefaultClause;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <drop domain default clause> ::= DROP DEFAULT                                }
procedure TSqlParser.ParseDropDomainDefaultClause(const A: TSqlAlterDomainStatement);
begin
  Assert(FTokenType = ttDEFAULT);
  GetNextToken;
  A.AlterType := sadDropDefault;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <add domain constraint definition> ::= ADD <domain constraint>               }
procedure TSqlParser.ParseAddDomainConstraintDefinition(const A: TSqlAlterDomainStatement);
begin
  Assert(FTokenType = ttADD);
  GetNextToken;
  A.AlterType := sadAdd;
  A.DomainConstraint := ParseDomainConstraint;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <drop domain constraint definition> ::= DROP CONSTRAINT <constraint name>    }
procedure TSqlParser.ParseDropDomainConstraintDefinition(const A: TSqlAlterDomainStatement);
begin
  Assert(FTokenType = ttCONSTRAINT);
  GetNextToken;
  A.AlterType := sadDropConstraint;
  A.ConstraintName := ParseConstraintName;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <alter domain statement> ::=                                                 }
{     ALTER DOMAIN <domain name> <alter domain action>                         }
{ <alter domain action> ::=                                                    }
{       <set domain default clause>                                            }
{     | <drop domain default clause>                                           }
{     | <add domain constraint definition>                                     }
{     | <drop domain constraint definition>                                    }
function TSqlParser.ParseAlterDomainStatement: TSqlAlterDomainStatement;
begin
  Assert(FTokenType = ttDOMAIN);
  GetNextToken;
  Result := TSqlAlterDomainStatement.Create;
  with Result do
    try
      DomainName := ParseDomainName;
      case FTokenType of
        ttSET  : ParseSetDomainDefaultClause(Result);
        ttADD  : ParseAddDomainConstraintDefinition(Result);
        ttDROP :
          case GetNextToken of
            ttDEFAULT    : ParseDropDomainDefaultClause(Result);
            ttCONSTRAINT : ParseDropDomainConstraintDefinition(Result);
          else
            ParseError('Alter domain drop action expected');
          end;
      else
        ParseError('Alter domain action expected');
      end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <drop view statement> ::=                                                    }
{     DROP VIEW <table name> <drop behavior>                                   }
function TSqlParser.ParseDropViewStatement: TSqlDropStatement;
begin
  Assert(FTokenType = ttVIEW);
  GetNextToken;
  Result := TSqlDropStatement.Create;
  with Result do
    try
      DropType := sdtView;
      Identifier := ParseTableName;
      DropBehavior := ParseDropBehavior;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <drop domain statement> ::=                                                  }
{     DROP DOMAIN <domain name> <drop behavior>                                }
function TSqlParser.ParseDropDomainStatement: TSqlDropStatement;
begin
  Assert(FTokenType = ttDOMAIN);
  GetNextToken;
  Result := TSqlDropStatement.Create;
  with Result do
    try
      DropType := sdtDomain;
      Identifier := ParseDomainName;
      DropBehavior := ParseDropBehavior;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <drop character set statement> ::=                                           }
{     DROP CHARACTER SET <character set name>                                  }
function TSqlParser.ParseDropCharacterSetStatement: TSqlDropStatement;
begin
  Result := TSqlDropStatement.Create;
  with Result do
    try
      DropType := sdtCharacterSet;
      Identifier := ParseCharacterSetName;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <drop collation statement> ::=                                               }
{     DROP COLLATION <collation name>                                          }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <drop collation statement> ::=                                               }
{     DROP COLLATION <collation name> <drop behavior>                          }
function TSqlParser.ParseDropCollationStatement: TSqlDropStatement;
begin
  Assert(FTokenType = ttCOLLATION);
  GetNextToken;
  Result := TSqlDropStatement.Create;
  with Result do
    try
      DropType := sdtCollation;
      Identifier := ParseCollationName;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99:                                                                 }
{ <drop translation statement> ::=                                             }
{     DROP TRANSLATION <translation name>                                      }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseDropTranslationStatement: TSqlDropStatement;
begin
  Assert(FTokenType = ttTRANSLATION);
  GetNextToken;
  Result := TSqlDropStatement.Create;
  with Result do
    try
      DropType := sdtTranslation;
      Identifier := ParseTranslationName;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <drop assertion statement> ::=                                               }
{     DROP ASSERTION <constraint name>                                         }
function TSqlParser.ParseDropAssertionStatement: TSqlDropStatement;
begin
  Assert(FTokenType = ttASSERTION);
  GetNextToken;
  Result := TSqlDropStatement.Create;
  with Result do
    try
      DropType := sdtAssertion;
      Identifier := ParseConstraintName;
    except
      Result.Free;
      raise;
    end;
end;

(* TRANSACT-SQL / EXT:                                                        *)
(* DROP DATABASE { database_name | database_snapshot_name } [ ,...n ] [;]     *)
function TSqlParser.ParseDropDatabaseStatement: TSqlDropStatement;
begin
  Assert(FTokenType = ttDATABASE);
  if not (spoExtendedSyntax in FOptions) then
    UnexpectedToken;
  GetNextToken;
  Result := TSqlDropStatement.Create;
  with Result do
    try
      DropType := sdtDatabase;
      Identifier := ParseIdentifier;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <drop schema statement> ::=                                                  }
{     DROP SCHEMA <schema name> <drop behavior>                                }
function TSqlParser.ParseDropSchemaStatement: TSqlDropStatement;
begin
  Assert(FTokenType = ttSCHEMA);
  GetNextToken;
  Result := TSqlDropStatement.Create;
  with Result do
    try
      DropType := sdtSchema;
      Identifier := ParseSchemaName;
      DropBehavior := ParseDropBehavior;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <SQL schema statement> ::=                                                   }
{       <SQL schema definition statement>                                      }
{     | <SQL schema manipulation statement>                                    }
{ <SQL schema manipulation statement> ::=                                      }
{       <drop schema statement>                                                }
{     | <alter table statement>                                                }
{     | <drop table statement>                                                 }
{     | <drop view statement>                                                  }
{     | <revoke statement>                                                     }
{     | <alter domain statement>                                               }
{     | <drop domain statement>                                                }
{     | <drop character set statement>                                         }
{     | <drop collation statement>                                             }
{     | <drop translation statement>                                           }
{     | <drop assertion statement>                                             }
{                                                                              }
{ SQL99:                                                                       }
{ <SQL schema manipulation statement> ::=                                      }
{       <drop schema statement>                                                }
{     | <alter table statement>                                                }
{     | <drop table statement>                                                 }
{     | <drop view statement>                                                  }
{     | <alter routine statement>                                              }
{     | <drop routine statement>                                               }
{     | <drop user-defined cast statement>                                     }
{     | <revoke statement>                                                     }
{     | <drop role statement>                                                  }
{     | <alter domain statement>                                               }
{     | <drop domain statement>                                                }
{     | <drop character set statement>                                         }
{     | <drop collation statement>                                             }
{     | <drop translation statement>                                           }
{     | <drop assertion statement>                                             }
{     | <drop trigger statement>                                               }
{     | <alter type statement>                                                 }
{     | <drop data type statement>                                             }
{     | <drop user-defined ordering statement>                                 }
{     | <drop transform statement>                                             }
{     | <drop module statement>                                                }
{                                                                              }
{ SQL2003:                                                                     }
{ <SQL schema manipulation statement> ::=                                      }
{       <drop schema statement>                                                }
{     | <alter table statement>                                                }
{     | <drop table statement>                                                 }
{     | <drop view statement>                                                  }
{     | <alter routine statement>                                              }
{     | <drop routine statement>                                               }
{     | <drop user-defined cast statement>                                     }
{     | <revoke statement>                                                     }
{     | <drop role statement>                                                  }
{     | <alter domain statement>                                               }
{     | <drop domain statement>                                                }
{     | <drop character set statement>                                         }
{     | <drop collation statement>                                             }
{     | <drop transliteration statement>                                       }
{     | <drop assertion statement>                                             }
{     | <drop trigger statement>                                               }
{     | <alter type statement>                                                 }
{     | <drop data type statement>                                             }
{     | <drop user-defined ordering statement>                                 }
{     | <alter transform statement>                                            }
{     | <drop transform statement>                                             }
{     | <alter sequence generator statement>                                   }
{     | <drop sequence generator statement>                                    }
{ <alter sequence generator statement> ::=                                     }
{     ALTER SEQUENCE <sequence generator name>                                 }
{         <alter sequence generator options>                                   }
{ <drop sequence generator statement> ::=                                      }
{     DROP SEQUENCE <sequence generator name> <drop behavior>                  }
function TSqlParser.ParseSqlSchemaStatement: ASqlStatement;
begin
  case FTokenType of
    ttCREATE,
    ttGRANT   : Result := ParseSqlSchemaDefinitionStatement;
    ttDROP    : Result := ParseDropStatement;
    ttALTER   : Result := ParseAlterStatement;
    ttREVOKE  : Result := ParseRevokeStatement;
  else
    Result := nil;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <value specification> ::= <literal> | <general value specification>          }
function TSqlParser.ParseValueSpecification: ASqlValueExpression;
begin
  Result := ParseLiteral;
  if Assigned(Result) then
    exit;
  Result := ParseGeneralValueSpecification;
end;

{ SQL92:                                                                       }
{ <set catalog statement> ::= SET CATALOG <value specification>                }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <set catalog statement> ::= SET <catalog name characteristic>                }
{ <catalog name characteristic> ::= CATALOG <value specification>              }
function TSqlParser.ParseSetCatalogStatement: TSqlSessionSetStatement;
begin
  Assert(FTokenType = ttCATALOG);
  GetNextToken;
  Result := TSqlSessionSetStatement.CreateEx(sstCatalog, ParseValueSpecification);
end;

{ SQL92:                                                                       }
{ <set schema statement> ::= SET SCHEMA <value specification>                  }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <set schema statement> ::= SET <schema name characteristic>                  }
{ <schema name characteristic> ::= SCHEMA <value specification>                }
function TSqlParser.ParseSetSchemaStatement: TSqlSessionSetStatement;
begin
  Assert(FTokenType = ttSCHEMA);
  GetNextToken;
  Result := TSqlSessionSetStatement.CreateEx(sstSchema, ParseValueSpecification);
end;

{ SQL92:                                                                       }
{ <set names statement> ::= SET NAMES <value specification>                    }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <set names statement> ::= SET <character set name characteristic>            }
{ <character set name characteristic> ::= NAMES <value specification>          }
function TSqlParser.ParseSetNamesStatement: TSqlSessionSetStatement;
begin
  Assert(FTokenType = ttNAMES);
  GetNextToken;
  Result := TSqlSessionSetStatement.CreateEx(sstNames, ParseValueSpecification);
end;

{ SQL92:                                                                       }
{ <set session authorization identifier statement> ::=                         }
{     SET SESSION AUTHORIZATION <value specification>                          }
{                                                                              }
{ SQL99/SQL2003: Not used                                                      }
function TSqlParser.ParseSetSessionAuthorizationIdentifierStatement: TSqlSessionSetStatement;
begin
  Assert(FTokenType = ttSESSION);
  GetNextToken;
  ExpectKeyword(ttAUTHORIZATION, SQL_KEYWORD_AUTHORIZATION);
  Result := TSqlSessionSetStatement.CreateEx(sstSessionAuthorization, ParseValueSpecification);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <set local time zone statement> ::=                                          }
{     SET TIME ZONE <set time zone value>                                      }
{ <set time zone value> ::= <interval value expression> | LOCAL                }
function TSqlParser.ParseSetLocalTimeZoneStatement: TSqlSetLocalTimeZoneStatement;
begin
  Assert(FTokenType = ttTIME);
  GetNextToken;
  ExpectKeyword(ttZONE, SQL_KEYWORD_ZONE);
  Result := TSqlSetLocalTimeZoneStatement.Create;
  with Result do
    try
      Local := SkipToken(ttLOCAL);
      if not Local then
        ZoneValue := ParseIntervalValueExpression;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <SQL session statement> ::=                                                  }
{       <set catalog statement>                                                }
{     | <set schema statement>                                                 }
{     | <set names statement>                                                  }
{     | <set session authorization identifier statement>                       }
{     | <set local time zone statement>                                        }
{                                                                              }
{ SQL99:                                                                       }
{ <SQL session statement> ::=                                                  }
{       <set session user identifier statement>                                }
{     | <set role statement>                                                   }
{     | <set local time zone statement>                                        }
{     | <set session characteristics statement>                                }
{     | <set catalog statement>                                                }
{     | <set schema statement>                                                 }
{     | <set names statement>                                                  }
{     | <set path statement>                                                   }
{     | <set transform group statement>                                        }
{                                                                              }
{ SQL2003:                                                                     }
{ <SQL session statement> ::=                                                  }
{       <set session user identifier statement>                                }
{     | <set role statement>                                                   }
{     | <set local time zone statement>                                        }
{     | <set session characteristics statement>                                }
{     | <set catalog statement>                                                }
{     | <set schema statement>                                                 }
{     | <set names statement>                                                  }
{     | <set path statement>                                                   }
{     | <set transform group statement>                                        }
{     | <set session collation statement>                                      }
{ <set session collation statement> ::=                                        }
{     SET COLLATION <collation specification>                                  }
{         [ FOR <character set specification list> ]                           }
{       | SET NO COLLATION [ FOR <character set specification list> ]          }
function TSqlParser.ParseSqlSessionStatement: ASqlStatement;
begin
  Assert(FTokenType = ttSET);
  GetNextToken;
  Result := nil;
  case FTokenType of
    ttCATALOG : Result := ParseSetCatalogStatement;
    ttSCHEMA  : Result := ParseSetSchemaStatement;
    ttNAMES   : Result := ParseSetNamesStatement;
    ttSESSION : Result := ParseSetSessionAuthorizationIdentifierStatement;
    ttTIME    : Result := ParseSetLocalTimeZoneStatement;
  else
    UnexpectedToken;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <directly executable statement> ::=                                          }
{       <direct SQL data statement>                                            }
{     | <SQL schema statement>                                                 }
{     | <SQL transaction statement>                                            }
{     | <SQL connection statement>                                             }
{     | <SQL session statement>                                                }
{     | <direct implementation-defined statement>                              }
function TSqlParser.ParseDirectlyExecutableStatement: ASqlStatement;
begin
  case FTokenType of
    ttDELETE,
    ttINSERT,
    ttUPDATE,
    ttDECLARE    : Result := ParseDirectSqlDataStatement;
    ttCREATE,
    ttGRANT,
    ttDROP,
    ttALTER,
    ttREVOKE     : Result := ParseSqlSchemaStatement;
    ttCOMMIT,
    ttROLLBACK   : Result := ParseSqlTransactionStatement;
    ttCONNECT,
    ttDISCONNECT : Result := ParseSqlConnectionStatement;
    ttSET        : Result := ParseSqlSessionStatement;
  else
    Result := nil;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <direct SQL statement> ::=                                                   }
{     <directly executable statement> <semicolon>                              }
function TSqlParser.ParseDirectSqlStatement: ASqlStatement;
begin
  Result := ParseDirectlyExecutableStatement;
  ExpectToken(ttSemicolon, '; expected');
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <select target list> ::=                                                     }
{     <target specification> [ ( <comma> <target specification> )... ]         }
function TSqlParser.ParseSelectTargetList: ASqlValueExpressionArray;
var R : ASqlValueExpressionArray;
begin
  try
    Append(ObjectArray(R), ParseTargetSpecification);
    while SkipToken(ttComma) do
      Append(ObjectArray(R), ParseTargetSpecification);
    Result := R;
  except
    FreeObjectArray(R);
    raise;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <select statement: single row> ::=                                           }
{     SELECT [ <set quantifier> ] <select list>                                }
{       INTO <select target list>                                              }
{         <table expression>                                                   }
function TSqlParser.ParseSelectStatementSingleRow: TSqlSelectStatement;
begin
  Assert(FTokenType = ttSELECT);
  Result := TSqlSelectStatement.CreateEx(
      ParseQuerySpecification(True), nil);
end;

{ SQL92/SQL99:                                                                 }
{ <SQL data change statement> ::=                                              }
{       <delete statement: positioned>                                         }
{     | <delete statement: searched>                                           }
{     | <insert statement>                                                     }
{     | <update statement: positioned>                                         }
{     | <update statement: searched>                                           }
{                                                                              }
{ SQL2003:                                                                     }
{ <SQL data change statement> ::=                                              }
{       <delete statement: positioned>                                         }
{     | <delete statement: searched>                                           }
{     | <insert statement>                                                     }
{     | <update statement: positioned>                                         }
{     | <update statement: searched>                                           }
{     | <merge statement>                                                      }
function TSqlParser.ParseSqlDataChangeStatement: ASqlStatement;
begin
  case FTokenType of
    ttDELETE : Result := ParseDeleteStatement(sdsUndefined);
    ttINSERT : Result := ParseInsertStatement;
    ttUPDATE : Result := ParseUpdateStatement(supUndefined);
  else
    Result := nil;
  end;
end;

{ SQL92:                                                                       }
{ <dynamic open statement> ::=                                                 }
{     OPEN <dynamic cursor name> [ <using clause> ]                            }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <dynamic open statement> ::=                                                 }
{     OPEN <dynamic cursor name> [ <input using clause> ]                      }
function TSqlParser.ParseDynamicOpenStatement: TSqlDynamicOpenStatement;
begin
  if SkipToken(ttOPEN) then
    begin
      Result := TSqlDynamicOpenStatement.Create;
      with Result do
        try
          CursorName := ExpectDynamicCursorName;
          UsingClause := ParseUsingClause;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <open statement> ::= OPEN <cursor name>                                      }
function TSqlParser.ParseOpenStatement: ASqlStatement;
begin
  Result := ParseDynamicOpenStatement;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <fetch target list> ::=                                                      }
{     <target specification> [ ( <comma> <target specification> )... ]         }
function TSqlParser.ParseFetchTargetList: ASqlValueExpressionArray;
var T : ASqlValueExpressionArray;
begin
  try
    Append(ObjectArray(T), ParseTargetSpecification);
    while SkipToken(ttComma) do
      Append(ObjectArray(T), ParseTargetSpecification);
    Result := T;
  except
    FreeObjectArray(T);
    raise;
  end;
end;

{ EXT:                                                                         }
{ <fetch statement ext> ::=                                                    }
{       <fetch statement>                                                      }
{     | <dynamic fetch statement>                                              }
{ <dynamic fetch statement> ::=                                                }
{     FETCH [ [ <fetch orientation> ] FROM ] <dynamic cursor name>             }
{         <using clause>                                                       }
{ <fetch statement> ::=                                                        }
{     FETCH [ [ <fetch orientation> ] FROM ] <cursor name>                     }
{     INTO <fetch target list>                                                 }
{                                                                              }
{ SQL2003:                                                                     }
{ <fetch orientation> ::= NEXT | PRIOR | FIRST | LAST |                        }
{     ( ABSOLUTE | RELATIVE ) <simple value specification>                     }
function TSqlParser.ParseFetchStatementExt(const FetchType: TSqlFetchType): TSqlFetchStatement;
begin
  if SkipToken(ttFETCH) then
    begin
      Result := TSqlFetchStatement.Create;
      with Result do
        try
          case FTokenType of
            ttNEXT     : Orientation := sfoNext;
            ttPRIOR    : Orientation := sfoPrior;
            ttFIRST    : Orientation := sfoFirst;
            ttLAST     : Orientation := sfoLast;
            ttABSOLUTE : Orientation := sfoAbsolute;
            ttRELATIVE : Orientation := sfoRelative;
          else
            Orientation := sfoUndefined;
          end;
          if Orientation <> sfoUndefined then
            begin
              GetNextToken;
              if Orientation in [sfoAbsolute, sfoRelative] then
                Value := ExpectSimpleValueSpecification;
              SkipToken(ttFROM);
            end;
          CursorName := ExpectDynamicCursorName;
          case FetchType of
            sftDynamic : UsingClause := ParseUsingClause;
            sftNormal  :
              begin
                ExpectKeyword(ttINTO, SQL_KEYWORD_INTO);
                TargetList := ParseFetchTargetList;
              end;
          else
            if SkipToken(ttINTO) then
              TargetList := ParseFetchTargetList
            else
              UsingClause := ParseUsingClause;
          end;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <fetch statement> ::=                                                        }
{     FETCH [ [ <fetch orientation> ] FROM ] <cursor name>                     }
{     INTO <fetch target list>                                                 }
function TSqlParser.ParseFetchStatement: TSqlFetchStatement;
begin
  Result := ParseFetchStatementExt(sftNormal);
end;

{ SQL92:                                                                       }
{ <dynamic fetch statement> ::=                                                }
{     FETCH [ [ <fetch orientation> ] FROM ] <dynamic cursor name>             }
{         <using clause>                                                       }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <dynamic fetch statement> ::=                                                }
{     FETCH [ [ <fetch orientation> ] FROM ] <dynamic cursor name>             }
{         <output using clause>                                                }
function TSqlParser.ParseDynamicFetchStatement: TSqlFetchStatement;
begin
  Result := ParseFetchStatementExt(sftDynamic);
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <dynamic close statement> ::= CLOSE <dynamic cursor name>                    }
function TSqlParser.ParseDynamicCloseStatement: TSqlDynamicCloseStatement;
begin
  if SkipToken(ttCLOSE) then
    begin
      Result := TSqlDynamicCloseStatement.Create;
      Result.CursorName := ExpectDynamicCursorName;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <close statement> ::= CLOSE <cursor name>                                    }
function TSqlParser.ParseCloseStatement: ASqlStatement;
begin
  Result := ParseDynamicCloseStatement;
end;

{ SQL92:                                                                       }
{ <SQL data statement> ::=                                                     }
{       <open statement>                                                       }
{     | <fetch statement>                                                      }
{     | <close statement>                                                      }
{     | <select statement: single row>                                         }
{     | <SQL data change statement>                                            }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <SQL data statement> ::=                                                     }
{       <open statement>                                                       }
{     | <fetch statement>                                                      }
{     | <close statement>                                                      }
{     | <select statement: single row>                                         }
{     |	<free locator statement>                                               }
{     |	<hold locator statement>                                               }
{     | <SQL data change statement>                                            }
function TSqlParser.ParseSqlDataStatement: ASqlStatement;
begin
  case FTokenType of
    ttOPEN    : Result := ParseOpenStatement;
    ttFETCH   : Result := ParseFetchStatement;
    ttCLOSE   : Result := ParseCloseStatement;
    ttSELECT  : Result := ParseSelectStatementSingleRow;
    ttDELETE,
    ttINSERT,
    ttUPDATE  : Result := ParseSqlDataChangeStatement;
  else
    Result := nil;
  end;
end;

{ SQL92:                                                                       }
{ <extended statement name> ::=                                                }
{     [ <scope option> ] <simple value specification>                          }
function TSqlParser.ParseExtendedStatementName: TObject;
begin
  ParseScopeOption;
  ParseSimpleValueSpecification;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <statement cursor> ::=                                                       }
{     [ <cursor sensitivity> ] [ SCROLL ] CURSOR [ WITH HOLD ] [ WITH RETURN ] }
{     FOR <extended statement name>                                            }
function TSqlParser.ParseStatementCursor: TObject;
begin
  ParseCursorSensitivity;
  SkipToken(ttFOR);
  ParseExtendedStatementName;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <result set cursor> ::=                                                      }
{     FOR PROCEDURE <specific routine designator>                              }
function TSqlParser.ParseResultSetCursor: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <cursor intent> ::= <statement cursor> | <result set cursor>                 }
function TSqlParser.ParseCursorIntent: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL92:                                                                       }
{ <allocate cursor statement> ::=                                              }
{     ALLOCATE <extended cursor name> [ INSENSITIVE ]                          }
{         [ SCROLL ] CURSOR                                                    }
{       FOR <extended statement name>                                          }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <allocate cursor statement> ::=                                              }
{     ALLOCATE <extended cursor name>                                          }
{     <cursor intent>                                                          }
function TSqlParser.ParseAllocateCursorStatement: TSqlAllocateCursorStatement;
begin
  Result := TSqlAllocateCursorStatement.Create;
  with Result do
    try
      CursorName := ExpectExtendedCursorName;
      Insensitive := SkipToken(ttINSENSITIVE);
      Scroll := SkipToken(ttSCROLL);
      ExpectKeyword(ttCURSOR, SQL_KEYWORD_CURSOR);
      ExpectKeyword(ttFOR, SQL_KEYWORD_FOR);
      StatementNameScope := ParseScopeOption;
      StatementNameValue := ParseSimpleValueSpecification;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <scope option> ::= GLOBAL | LOCAL                                            }
function TSqlParser.ParseScopeOption: TSqlScopeOption;
begin
  case FTokenType of
    ttGLOBAL : Result := ssoGlobal;
    ttLOCAL  : Result := ssoLocal;
  else
    Result := ssoUndefined;
  end;
  if Result <> ssoUndefined then
    GetNextToken;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <extended cursor name> ::= [ <scope option> ] <simple value specification>   }
function TSqlParser.ParseExtendedCursorName: TSqlDynamicCursorName;
var S : TSqlScopeOption;
    V : ASqlValueExpression;
begin
  S := ParseScopeOption;
  if S <> ssoUndefined then
    begin
      Result := TSqlDynamicCursorName.Create;
      with Result do
        try
          ScopeOption := S;
          ExtendedCursorName := ExpectSimpleValueSpecification;
        except
          Result.Free;
          raise;
        end;
    end
  else
    begin
      V := ParseSimpleValueSpecification;
      if Assigned(V) then
        begin
          Result := TSqlDynamicCursorName.Create;
          with Result do
            begin
              ScopeOption := ssoUndefined;
              ExtendedCursorName := V;
            end;
        end
      else
        Result := nil;
    end;
end;

function TSqlParser.ExpectExtendedCursorName: TSqlDynamicCursorName;
begin
  Result := ParseExtendedCursorName;
  if not Assigned(Result) then
    ParseError('Extended cursor name expected');
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <dynamic cursor name> ::= <cursor name> | <extended cursor name>             }
function TSqlParser.ParseDynamicCursorName: TSqlDynamicCursorName;
begin
  if FTokenType = ttIdentifier then
    begin
      Result := TSqlDynamicCursorName.Create;
      Result.CursorName := ParseCursorName;
    end
  else
    Result := ParseExtendedCursorName;
end;

function TSqlParser.ExpectDynamicCursorName: TSqlDynamicCursorName;
begin
  Result := ParseDynamicCursorName;
  if not Assigned(Result) then
    ParseError('Dynamic cursor name expected');
end;

{ SQL92:                                                                       }
{ <using clause> ::= <using arguments> | <using descriptor>                    }
{ <using arguments> ::= ( USING | INTO ) <argument>                            }
{     [ ( <comma> <argument> )... ]                                            }
{ <argument> ::= <target specification>                                        }
{ <using descriptor> ::=                                                       }
{     ( USING | INTO ) SQL DESCRIPTOR <descriptor name>                        }
{ <descriptor name> ::= [ <scope option> ] <simple value specification>        }
{                                                                              }
{ SQL99/SQL2003: Not used                                                      }
function TSqlParser.ParseUsingClause: TSqlUsingClause;
var E : ASqlValueExpressionArray;
begin
  if SkipAnyToken([ttUSING, ttINTO]) <> ttNone then
    begin
      Result := TSqlUsingClause.Create;
      with Result do
        try
          if SkipToken(ttSQL) then
            begin
              ExpectKeyword(ttDESCRIPTOR, SQL_KEYWORD_DESCRIPTOR);
              UsingType := sutDescriptor;
              DescriptorScope := ParseScopeOption;
              Descriptor := ParseSimpleValueSpecification;
            end
          else
            begin
              UsingType := sutArguments;
              Append(ObjectArray(E), ParseTargetSpecification);
              while SkipToken(ttComma) do
                Append(ObjectArray(E), ParseTargetSpecification);
              UsingArguments := E;
            end;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <SQL dynamic data statement> ::=                                             }
{       <allocate cursor statement>                                            }
{     | <dynamic open statement>                                               }
{     | <dynamic fetch statement>                                              }
{     | <dynamic close statement>                                              }
{     | <dynamic delete statement: positioned>                                 }
{     | <dynamic update statement: positioned>                                 }
function TSqlParser.ParseSqlDynamicDataStatement: ASqlStatement;
begin
  case FTokenType of
    ttALLOCATE :
      begin
        GetNextToken;
        Result := ParseAllocateCursorStatement;
      end;
    ttOPEN     : Result := ParseDynamicOpenStatement;
    ttFETCH    : Result := ParseDynamicFetchStatement;
    ttCLOSE    : Result := ParseDynamicCloseStatement;
    ttDELETE   : Result := ParseDynamicDeleteStatementPositioned;
    ttUPDATE   : Result := ParseDynamicUpdateStatementPositioned;
  else
    Result := nil;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <SQL statement variable> ::= <simple value specification>                    }
function TSqlParser.ExpectSQLStatementVariable: ASqlValueExpression;
begin
  Result := ExpectSimpleValueSpecification;
end;

{ SQL2003:                                                                     }
{ <attributes specification> ::= ATTRIBUTES <attributes variable>              }
{ <attributes variable> ::= <simple value specification>                       }
function TSqlParser.ParseAttributesSpecification: ASqlValueExpression;
begin
  if SkipToken(ttATTRIBUTES) then
    begin
      Result := ExpectSimpleValueSpecification;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99:                                                                 }
{ <prepare statement> ::=                                                      }
{     PREPARE <SQL statement name>                                             }
{     FROM <SQL statement variable>                                            }
{                                                                              }
{ SQL2003:                                                                     }
{ <prepare statement> ::=                                                      }
{     PREPARE <SQL statement name>                                             }
{     [ <attributes specification> ]                                           }
{     FROM <SQL statement variable>                                            }
function TSqlParser.ParsePrepareStatement: TSqlPrepareStatement;
begin
  Assert(FTokenType = ttPREPARE);
  GetNextToken;
  Result := TSqlPrepareStatement.Create;
  with Result do
    try
      StatementName := ParseSqlStatementName;
      ExpectKeyword(ttFROM, SQL_KEYWORD_FROM);
      Variable := ExpectSQLStatementVariable;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <deallocate prepared statement> ::=                                          }
{     DEALLOCATE PREPARE <SQL statement name>                                  }
function TSqlParser.ParseDeallocatePrepareStatement: TSqlDeallocatePrepareStatement;
begin
  Assert(FTokenType = ttPREPARE);
  GetNextToken;
  Result := TSqlDeallocatePrepareStatement.Create;
  try
    Result.StatementName := ParseSqlStatementName;
  except
    Result.Free;
    raise;
  end;
end;

{ SQL92/SQL99:                                                                 }
{ <get item information> ::=                                                   }
{     <simple target specification 2> <equals operator> <descriptor item name> }
{ <simple target specification 2> ::= <simple target specification>            }
function TSqlParser.ParseGetItemInformation: TSqlGetItemInformation;
begin
  Result := TSqlGetItemInformation.Create;
  with Result do
    try
      TargetSpec := ParseSimpleTargetSpecification;
      ExpectEqualSign;
      ItemName := ExpectIdentifier;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <get descriptor information> ::=                                             }
{       <get count>                                                            }
{     | VALUE <item number>                                                    }
{         <get item information> [ ( <comma> <get item information> )... ]     }
{ <get count> ::=                                                              }
{     <simple target specification 1> <equals operator> COUNT                  }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <get descriptor information> ::=                                             }
{       <get header information> [ ( <comma> <get header information> )... ]   }
{     |	VALUE <item number> <get item information>                             }
{       [ ( <comma> <get item information> )... ]                              }
{ <get header information> ::=                                                 }
{     <simple target specification 1> <equals operator> <header item name>     }
{ <simple target specification 1> ::= <simple target specification>            }
function TSqlParser.ParseGetDescriptorInformation: TSqlGetDescriptorInformation;
var D : TSqlGetItemInformationArray;
begin
  Result := TSqlGetDescriptorInformation.Create;
  with Result do
    try
      case FTokenType of
        ttVALUE :
          begin
            GetNextToken;
            ItemNumber := ExpectSimpleValueSpecification;
            Append(ObjectArray(D), ParseGetItemInformation);
            while SkipToken(ttComma) do
              Append(ObjectArray(D), ParseGetItemInformation);
            Items := D;
          end;
      else
        begin
          CountValue := ParseSimpleTargetSpecification;
          ExpectEqualSign;
          ExpectKeyword(ttCOUNT, SQL_KEYWORD_COUNT);
        end;
      end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <get descriptor statement> ::=                                               }
{     GET DESCRIPTOR <descriptor name> <get descriptor information>            }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <get descriptor statement> ::=                                               }
{     GET [ SQL ] DESCRIPTOR <descriptor name> <get descriptor information>    }
function TSqlParser.ParseGetDescriptorStatement: TSqlGetDescriptorStatement;
begin
  Assert(FTokenType = ttDESCRIPTOR);
  GetNextToken;
  Result := TSqlGetDescriptorStatement.Create;
  with Result do
    try
      DescriptorName := ParseDescriptorName;
      DescriptorInfo := ParseGetDescriptorInformation;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <set item information> ::=                                                   }
{     <descriptor item name> <equals operator> <simple value specification 2>  }
{ <descriptor item name> ::=                                                   }
{       TYPE | LENGTH | OCTET_LENGTH | RETURNED_LENGTH                         }
{     | RETURNED_OCTET_LENGTH | PRECISION | SCALE | DATETIME_INTERVAL_CODE     }
{     | DATETIME_INTERVAL_PRECISION | NULLABLE | INDICATOR | DATA | NAME       }
{     | UNNAMED | COLLATION_CATALOG | COLLATION_SCHEMA | COLLATION_NAME        }
{     | CHARACTER_SET_CATALOG | CHARACTER_SET_SCHEMA | CHARACTER_SET_NAME      }
{ <simple value specification 2> ::= <simple value specification>              }
{                                                                              }
{ SQL99:                                                                       }
{ <descriptor item name> ::=                                                   }
{       CARDINALITY |	CHARACTER_SET_CATALOG |	CHARACTER_SET_NAME               }
{     |	CHARACTER_SET_SCHEMA | COLLATION_CATALOG | COLLATION_NAME              }
{     |	COLLATION_SCHEMA | DATA |	DATETIME_INTERVAL_CODE                       }
{     | DATETIME_INTERVAL_PRECISION |	DEGREE | INDICATOR | KEY_MEMBER          }
{     |	LENGTH | LEVEL | NAME |	NULLABLE | OCTET_LENGTH |	PARAMETER_MODE       }
{     |	PARAMETER_ORDINAL_POSITION | PARAMETER_SPECIFIC_CATALOG                }
{     |	PARAMETER_SPECIFIC_NAME |	PARAMETER_SPECIFIC_SCHEMA                    }
{     |	PRECISION |	RETURNED_CARDINALITY | RETURNED_LENGTH                     }
{     |	RETURNED_OCTET_LENGTH |	SCALE |	SCOPE_CATALOG |	SCOPE_NAME             }
{     |	SCOPE_SCHEMA | TYPE |	UNNAMED |	USER_DEFINED_TYPE_CATALOG              }
{     |	USER_DEFINED_TYPE_NAME | USER_DEFINED_TYPE_SCHEMA                      }
{                                                                              }
{ SQL2003:                                                                     }
{ <descriptor item name> ::=                                                   }
{       CARDINALITY |	CHARACTER_SET_CATALOG |	CHARACTER_SET_NAME               }
{     | CHARACTER_SET_SCHEMA | COLLATION_CATALOG | COLLATION_NAME              }
{     |	COLLATION_SCHEMA | DATA |	DATETIME_INTERVAL_CODE                       }
{     |	DATETIME_INTERVAL_PRECISION |	DEGREE | INDICATOR | KEY_MEMBER          }
{     | LENGTH | LEVEL | NAME |	NULLABLE | OCTET_LENGTH |	PARAMETER_MODE       }
{     | PARAMETER_ORDINAL_POSITION | PARAMETER_SPECIFIC_CATALOG                }
{     | PARAMETER_SPECIFIC_NAME |	PARAMETER_SPECIFIC_SCHEMA                    }
{     | PRECISION | RETURNED_CARDINALITY | RETURNED_LENGTH                     }
{     | RETURNED_OCTET_LENGTH |	SCALE |	SCOPE_CATALOG |	SCOPE_NAME             }
{     | SCOPE_SCHEMA | TYPE |	UNNAMED |	USER_DEFINED_TYPE_CATALOG              }
{     | USER_DEFINED_TYPE_NAME | USER_DEFINED_TYPE_SCHEMA                      }
{     |	USER_DEFINED_TYPE_CODE                                                 }
function TSqlParser.ParseSetItemInformation: TSqlSetItemInformation;
begin
  Result := TSqlSetItemInformation.Create;
  with Result do
    try
      Identifier := ExpectIdentifier;
      ExpectEqualSign;
      Value := ExpectSimpleValueSpecification;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <set descriptor information> ::=                                             }
{       <set count>                                                            }
{     | VALUE <item number>                                                    }
{       <set item information> [ ( <comma> <set item information> )... ]       }
{ <set count> ::=                                                              }
{     COUNT <equals operator> <simple value specification 1>                   }
{ <simple value specification 1> ::= <simple value specification>              }
{ <item number> ::= <simple value specification>                               }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <set descriptor information> ::=                                             }
{       <set header information> [ ( <comma> <set header information> )... ]   }
{    | VALUE <item number> <set item information>                              }
{    [ ( <comma> <set item information> )... ]                                 }
function TSqlParser.ParseSetDescriptorInformation: TSqlSetDescriptorInformation;
var D : TSqlSetItemInformationArray;
begin
  Result := TSqlSetDescriptorInformation.Create;
  with Result do
    try
      case FTokenType of
        ttCOUNT :
          begin
            GetNextToken;
            ExpectEqualSign;
            CountValue := ExpectSimpleValueSpecification;
          end;
        ttVALUE :
          begin
            GetNextToken;
            ItemNumber := ExpectSimpleValueSpecification;
            Append(ObjectArray(D), ParseSetItemInformation);
            while SkipToken(ttComma) do
              Append(ObjectArray(D), ParseSetItemInformation);
            Items := D;
          end;
      else
        ParseError('Set descriptor information expected');
      end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <set descriptor statement> ::=                                               }
{     SET DESCRIPTOR <descriptor name> <set descriptor information>            }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <set descriptor statement> ::=                                               }
{     SET [ SQL ] DESCRIPTOR <descriptor name> <set descriptor information>    }
function TSqlParser.ParseSetDescriptorStatement: TSqlSetDescriptorStatement;
begin
  Assert(FTokenType = ttDESCRIPTOR);
  GetNextToken;
  Result := TSqlSetDescriptorStatement.Create;
  with Result do
    try
      DescriptorName := ParseDescriptorName;
      DescriptorInfo := ParseSetDescriptorInformation;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <allocate descriptor statement> ::=                                          }
{     ALLOCATE DESCRIPTOR <descriptor name>                                    }
{        [ WITH MAX <occurrences> ]                                            }
{ <occurrences> ::= <simple value specification>                               }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <allocate descriptor statement> ::=                                          }
{     ALLOCATE [ SQL ] DESCRIPTOR                                              }
{     <descriptor name> [ WITH MAX <occurrences> ]                             }
function TSqlParser.ParseAllocateDescriptorStatement: TSqlAllocateDescriptorStatement;
begin
  Assert(FTokenType = ttDESCRIPTOR);
  GetNextToken;
  Result := TSqlAllocateDescriptorStatement.Create;
  try
    Result.DescriptorName := ParseDescriptorName;
    if SkipToken(ttWITH) then
      begin
        ExpectKeyword(ttMAX, SQL_KEYWORD_MAX);
        Result.MaxOccurrences := ExpectSimpleValueSpecification;
      end;
  except
    Result.Free;
    raise;
  end;
end;

{ SQL92:                                                                       }
{ <deallocate descriptor statement> ::=                                        }
{     DEALLOCATE DESCRIPTOR <descriptor name>                                  }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <deallocate descriptor statement> ::=                                        }
{     DEALLOCATE [ SQL ] DESCRIPTOR <descriptor name>                          }
function TSqlParser.ParseDeallocateDescriptorStatement: TSqlDeallocateDescriptorStatement;
begin
  Assert(FTokenType = ttDESCRIPTOR);
  GetNextToken;
  Result := TSqlDeallocateDescriptorStatement.Create;
  try
    Result.DescriptorName := ParseDescriptorName;
  except
    Result.Free;
    raise;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <system descriptor statement> ::=                                            }
{       <allocate descriptor statement>                                        }
{     | <deallocate descriptor statement>                                      }
{     | <set descriptor statement>                                             }
{     | <get descriptor statement>                                             }
function TSqlParser.ParseSystemDescriptorStatement: ASqlStatement;
var T : Integer;
begin
  Result := nil;
  T := FTokenType;
  case T of
    ttALLOCATE, ttDEALLOCATE, ttSET, ttGET :
      begin
        GetNextToken;
        CheckToken(ttDESCRIPTOR, 'DESCRIPTOR expected');
        case T of
          ttALLOCATE   : Result := ParseAllocateDescriptorStatement;
          ttDEALLOCATE : Result := ParseDeallocateDescriptorStatement;
          ttSET        : Result := ParseSetDescriptorStatement;
          ttGET        : Result := ParseSetDescriptorStatement;
        end;
      end;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <descriptor name> ::= [ <scope option> ] <simple value specification>        }
function TSqlParser.ParseDescriptorName: TSqlDescriptorName;
begin
  Result := TSqlDescriptorName.Create;
  with Result do
    try
      ScopeOption := ParseScopeOption;
      NameExpr := ParseSimpleValueSpecification;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <using descriptor> ::=                                                       }
{     ( USING | INTO ) SQL DESCRIPTOR <descriptor name>                        }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <using descriptor> ::=                                                       }
{     USING [ SQL ] DESCRIPTOR <descriptor name>                               }
function TSqlParser.ParseUsingDescriptor: TSqlDescriptorName;
begin
  if SkipAnyToken([ttUSING, ttINTO]) <> ttNone then
    GetNextToken
  else
    UnexpectedToken;
  ExpectKeyword(ttSQL, SQL_KEYWORD_SQL);
  ExpectKeyword(ttDESCRIPTOR, SQL_KEYWORD_DESCRIPTOR);
  Result := ParseDescriptorName;
end;

{ SQL92:                                                                       }
{ <describe statement> ::=                                                     }
{       <describe input statement>                                             }
{     | <describe output statement>                                            }
{ <describe input statement> ::=                                               }
{     DESCRIBE INPUT <SQL statement name> <using descriptor>                   }
{ <describe output statement> ::=                                              }
{     DESCRIBE [ OUTPUT ] <SQL statement name> <using descriptor>              }
{                                                                              }
{ SQL99:                                                                       }
{ <describe input statement> ::=                                               }
{     DESCRIBE INPUT <SQL statement name> <using descriptor>                   }
{     [ <nesting option> ]                                                     }
{ <describe output statement> ::=                                              }
{     DESCRIBE [ OUTPUT ] <described object> <using descriptor>                }
{     [ <nesting option> ]                                                     }
{ <nesting option> ::= WITH NESTING | WITHOUT NESTING                          }
function TSqlParser.ParseDescribeStatement: TSqlDescribeStatement;
begin
  Assert(FTokenType = ttDESCRIBE);
  Result := TSqlDescribeStatement.Create;
  with Result do
    try
      if GetNextToken = ttINPUT then
        DescribeType := sdeInput
      else
        begin
          DescribeType := sdeOutput;
          SkipToken(ttOUTPUT);
        end;
      StatementName := ParseSqlStatementName;
      Using := ParseUsingDescriptor;
    except
      Result.Free;
      raise;
    end;
end;

{ EXT:                                                                         }
{ <allocate statement> ::=                                                     }
{       <allocate descriptor statement>                                        }
{     | <allocate cursor statement>                                            }
function TSqlParser.ParseAllocateStatement: ASqlStatement;
begin
  Assert(FTokenType = ttALLOCATE);
  Result := nil;
  case GetNextToken of
    ttDESCRIPTOR : Result := ParseAllocateDescriptorStatement;
    ttIdentifier : Result := ParseAllocateCursorStatement;
  else
    ParseError('ALLOCATE type expected');
  end;
end;

{ EXT:                                                                         }
{ <deallocate statement> ::=                                                   }
{       <deallocate descriptor statement>                                      }
{     | <deallocate prepare statement>                                         }
function TSqlParser.ParseDeallocateStatement: ASqlStatement;
begin
  Assert(FTokenType = ttDEALLOCATE);
  Result := nil;
  case GetNextToken of
    ttDESCRIPTOR : Result := ParseDeallocateDescriptorStatement;
    ttPREPARE    : Result := ParseDeallocatePrepareStatement;
  else
    ParseError('DEALLOCATE type expected');
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <SQL dynamic statement> ::=                                                  }
{       <system descriptor statement>                                          }
{     | <prepare statement>                                                    }
{     | <deallocate prepared statement>                                        }
{     | <describe statement>                                                   }
{     | <execute statement>                                                    }
{     | <execute immediate statement>                                          }
{     | <SQL dynamic data statement>                                           }
function TSqlParser.ParseSqlDynamicStatement: ASqlStatement;
begin
  case FTokenType of
    ttSET,
    ttGET        : Result := ParseSystemDescriptorStatement;
    ttPREPARE    : Result := ParsePrepareStatement;
    ttDEALLOCATE : Result := ParseDeallocateStatement;
    ttDESCRIBE   : Result := ParseDescribeStatement;
    ttEXEC,
    ttEXECUTE    : Result := ParseExecuteStatement;
    ttOPEN,
    ttFETCH,
    ttCLOSE,
    ttDELETE,
    ttUPDATE     : Result := ParseSqlDynamicDataStatement;
    ttALLOCATE   : Result := ParseAllocateStatement;
  else
    Result := nil;
  end;
end;

{ SQL92:                                                                       }
{ <simple target specification> ::=                                            }
{       <parameter name> | <embedded variable name>                            }
{                                                                              }
{ SQL99:                                                                       }
{ <simple target specification> ::=                                            }
{       <host parameter specification>                                         }
{     |	<SQL parameter reference>                                              }
{     |	<column reference>                                                     }
{     | <SQL variable reference>                                               }
{     |	<embedded variable name>                                               }
{                                                                              }
{ SQL2003:                                                                     }
{ <simple target specification> ::=                                            }
{       <host parameter specification>                                         }
{     | <SQL parameter reference>                                              }
{     | <column reference>                                                     }
{     | <embedded variable name>                                               }
function TSqlParser.ParseSimpleTargetSpecification: ASqlValueExpression;
begin
  Result := ParseParameterNameExpr;
  if Assigned(Result) then
    exit;
  Result := ParseEmbeddedVariableName;
end;

{ SQL92:                                                                       }
{ <statement information item> ::=                                             }
{     <simple target specification> <equals operator>                          }
{     <statement information item name>                                        }
{ <statement information item name> ::=                                        }
{       NUMBER                                                                 }
{     | MORE                                                                   }
{     | COMMAND_FUNCTION                                                       }
{     | DYNAMIC_FUNCTION                                                       }
{     | ROW_COUNT                                                              }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <statement information item name> ::=                                        }
{       NUMBER                                                                 }
{     | MORE                                                                   }
{     | COMMAND_FUNCTION                                                       }
{     | COMMAND_FUNCTION_CODE                                                  }
{     | DYNAMIC_FUNCTION                                                       }
{     | DYNAMIC_FUNCTION_CODE                                                  }
{     | ROW_COUNT                                                              }
{     | TRANSACTIONS_COMMITTED                                                 }
{     | TRANSACTIONS_ROLLED_BACK                                               }
{     | TRANSACTION_ACTIVE                                                     }
function TSqlParser.ParseStatementInformationItem: TSqlStatementInformationItem;
begin
  Result := TSqlStatementInformationItem.Create;
  with Result do
    try
      TargetSpec := ParseSimpleTargetSpecification;
      ExpectEqualSign;
      ItemName := ExpectIdentifier;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <statement information> ::=                                                  }
{     <statement information item>                                             }
{     [ ( <comma> <statement information item> )... ]                          }
function TSqlParser.ParseStatementInformation: TSqlStatementInformation;
var S : TSqlStatementInformationItemArray;
begin
  Result := TSqlStatementInformation.Create;
  with Result do
    try
      Append(ObjectArray(S), ParseStatementInformationItem);
      while SkipToken(ttComma) do
        Append(ObjectArray(S), ParseStatementInformationItem);
      Items := S;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <condition information item> ::=                                             }
{     <simple target specification> <equals operator>                          }
{     <condition information item name>                                        }
{ <condition information item name> ::=                                        }
{       CONDITION_NUMBER | RETURNED_SQLSTATE | CLASS_ORIGIN                    }
{     | SUBCLASS_ORIGIN | SERVER_NAME | CONNECTION_NAME | CONSTRAINT_CATALOG   }
{     | CONSTRAINT_SCHEMA | CONSTRAINT_NAME | CATALOG_NAME | SCHEMA_NAME       }
{     | TABLE_NAME | COLUMN_NAME | CURSOR_NAME | MESSAGE_TEXT                  }
{     | MESSAGE_LENGTH | MESSAGE_OCTET_LENGTH                                  }
{                                                                              }
{ SQL99:                                                                       }
{ <condition information item name> ::=                                        }
{       CATALOG_NAME                                                           }
{     | CLASS_ORIGIN                                                           }
{     | COLUMN_NAME                                                            }
{     | CONDITION_IDENTIFIER                                                   }
{     | CONDITION_NUMBER                                                       }
{     | CONNECTION_NAME                                                        }
{     | CONSTRAINT_CATALOG                                                     }
{     | CONSTRAINT_NAME                                                        }
{     | CONSTRAINT_SCHEMA                                                      }
{     | CURSOR_NAME                                                            }
{     | MESSAGE_LENGTH                                                         }
{     | MESSAGE_OCTET_LENGTH                                                   }
{     | MESSAGE_TEXT                                                           }
{     | PARAMETER_MODE                                                         }
{     | PARAMETER_NAME                                                         }
{     | PARAMETER_ORDINAL_POSITION                                             }
{     | RETURNED_SQLSTATE                                                      }
{     | ROUTINE_CATALOG                                                        }
{     | ROUTINE_NAME                                                           }
{     | ROUTINE_SCHEMA                                                         }
{     | SCHEMA_NAME                                                            }
{     | SERVER_NAME                                                            }
{     | SPECIFIC_NAME                                                          }
{     | SUBCLASS_ORIGIN                                                        }
{     | TABLE_NAME                                                             }
{     | TRIGGER_CATALOG                                                        }
{     | TRIGGER_NAME                                                           }
{     | TRIGGER_SCHEMA                                                         }
{                                                                              }
{ SQL2003:                                                                     }
{ <condition information item name> ::=                                        }
{       CATALOG_NAME                                                           }
{     | CLASS_ORIGIN                                                           }
{     | COLUMN_NAME                                                            }
{     | CONDITION_NUMBER                                                       }
{     | CONNECTION_NAME                                                        }
{     | CONSTRAINT_CATALOG                                                     }
{     | CONSTRAINT_NAME                                                        }
{     | CONSTRAINT_SCHEMA                                                      }
{     | CURSOR_NAME                                                            }
{     | MESSAGE_LENGTH                                                         }
{     | MESSAGE_OCTET_LENGTH                                                   }
{     | MESSAGE_TEXT                                                           }
{     | PARAMETER_MODE                                                         }
{     | PARAMETER_NAME                                                         }
{     | PARAMETER_ORDINAL_POSITION                                             }
{     | RETURNED_SQLSTATE                                                      }
{     | ROUTINE_CATALOG                                                        }
{     | ROUTINE_NAME                                                           }
{     | ROUTINE_SCHEMA                                                         }
{     | SCHEMA_NAME                                                            }
{     | SERVER_NAME                                                            }
{     | SPECIFIC_NAME                                                          }
{     | SUBCLASS_ORIGIN                                                        }
{     | TABLE_NAME                                                             }
{     | TRIGGER_CATALOG                                                        }
{     | TRIGGER_NAME                                                           }
{     | TRIGGER_SCHEMA                                                         }
function TSqlParser.ParseConditionInformationItem: TSqlConditionInformationItem;
begin
  Result := TSqlConditionInformationItem.Create;
  with Result do
    try
      TargetSpec := ParseSimpleTargetSpecification;
      ExpectEqualSign;
      ItemName := ExpectIdentifier;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99:                                                                 }
{ <condition information> ::=                                                  }
{     EXCEPTION <condition number>                                             }
{       <condition information item>                                           }
{       [ ( <comma> <condition information item> )... ]                        }
{ <condition number> ::= <simple value specification>                          }
{                                                                              }
{ SQL2003:                                                                     }
{ <condition information> ::=                                                  }
{     ( EXCEPTION | CONDITION ) <condition number>                             }
{       <condition information item>                                           }
{       [ ( <comma> <condition information item> )... ]                        }
{ <condition information item> ::=                                             }
{     <simple target specification> <equals operator>                          }
{         <condition information item name>                                    }
function TSqlParser.ParseConditionInformation: TSqlConditionInformation;
var C : TSqlConditionInformationItemArray;
begin
  Assert(FTokenType = ttEXCEPTION);
  GetNextToken;
  Result := TSqlConditionInformation.Create;
  with Result do
    try
      ConditionNumber := ExpectSimpleValueSpecification;
      Append(ObjectArray(C), ParseConditionInformationItem);
      while SkipToken(ttComma) do
        Append(ObjectArray(C), ParseConditionInformationItem);
      Items := C;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <SQL diagnostics statement> ::= <get diagnostics statement>                  }
{ <get diagnostics statement> ::=                                              }
{     GET DIAGNOSTICS <sql diagnostics information>                            }
{ <sql diagnostics information> ::=                                            }
{       <statement information> | <condition information>                      }
{                                                                              }
{ SQL99:                                                                       }
{ <SQL diagnostics statement> ::=                                              }
{       <get diagnostics statement>                                            }
{     | <signal statement>                                                     }
{     | <resignal statement>                                                   }
{ <signal statement> ::= SIGNAL <signal value> [ <set signal information> ]    }
{ <signal value> ::= <condition name> | <sqlstate value>                       }
{ <set signal information> ::= SET <signal information item list>              }
{ <signal information item list> ::=                                           }
{     <signal information item> [ ( <comma> <signal information item> )... ]   }
{ <signal information item> ::=                                                }
{     <condition information item name>                                        }
{     <equals operator> <simple value specification>                           }
{ <resignal statement> ::= RESIGNAL [ <signal value> ]                         }
{     [ <set signal information> ]                                             }
{                                                                              }
{ SQL2003:                                                                     }
{ <SQL diagnostics statement> ::= <get diagnostics statement>                  }
function TSqlParser.ParseSqlDiagnosticsStatement: TSqlDiagnosticsStatement;
begin
  Assert(FTokenType = ttDIAGNOSTICS);
  Result := TSqlDiagnosticsStatement.Create;
  with Result do
    try
      if GetNextToken = ttEXCEPTION then
        ConditionInformation := ParseConditionInformation
      else
        StatementInformation := ParseStatementInformation;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL99:                                                                       }
{ <SQL statement list> ::= <terminated SQL statement>...                       }
{ <terminated SQL statement> ::= <SQL procedure statement> <semicolon>         }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseSqlStatementList: ASqlStatement;
begin
  ParseSqlProcedureStatement;
  ExpectToken(ttSemicolon, '; expected');
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <if statement> ::=                                                           }
{     IF <search condition> <if statement then clause>                         }
{     [ <if statement elseif clause>... ] [ <if statement else clause> ]       }
{     END IF                                                                   }
{ <if statement then clause> ::= THEN <SQL statement list>                     }
{ <if statement elseif clause> ::= ELSEIF <search condition>                   }
{     THEN <SQL statement list>                                                }
{ <if statement else clause> ::= ELSE <SQL statement list>                     }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseSql99IfStatement: TSqlIfStatement;
begin
  Assert(FTokenType = ttIF);
  GetNextToken;
  Result := TSqlIfStatement.Create;
  try
    Result.Condition := ExpectSearchCondition;
    ExpectKeyword(ttTHEN, SQL_KEYWORD_THEN);
    if SkipToken(ttELSEIF) then
      begin
        ExpectSearchCondition;
        ExpectKeyword(ttTHEN, SQL_KEYWORD_THEN);
        ParseSqlStatementList;
      end;
    if SkipToken(ttELSE) then
      Result.FalseStatement := ParseSqlStatementList;
    ExpectKeyword(ttEND, SQL_KEYWORD_END);
    ExpectKeyword(ttIF, SQL_KEYWORD_IF);
  except
    Result.Free;
    raise;
  end;
end;

{ MSSQL:                                                                       }
{ <if statement> ::=                                                           }
{   IF Boolean_expression                                                      }
{       ( sql_statement | statement_block )                                    }
{   [ ELSE                                                                     }
{       ( sql_statement | statement_block ) ]                                  }
function TSqlParser.ParseMsSqlIfStatement: TSqlIfStatement;
begin
  Assert(FTokenType = ttIF);
  if not (spoExtendedSyntax in FOptions) then
    UnexpectedToken;
  GetNextToken;
  Result := TSqlIfStatement.Create;
  with Result do
    try
      Condition := ExpectSearchCondition;
      TrueStatement := ParseStatement;
      if SkipToken(ttELSE) then
        FalseStatement := ParseStatement;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL99/SQL2003:                                                               }
{ <routine name> ::= [ <schema name> <period> ] <qualified identifier>         }
function TSqlParser.ParseRoutineName: AnsiString;
begin
  Result := ParseSchemaName;
  if Result = '' then
    exit;
  if SkipToken(ttPeriod) then
    Result := Result + '.' + ExpectIdentifier;
end;

{ SQL99:                                                                       }
{ <user-defined type> ::= <user-defined type name>                             }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseUserDefinedType: AnsiString;
begin
  Result := ParseUserDefinedTypeName;
end;

{ SQL99/SQL2003:                                                               }
{ <SQL argument> ::=                                                           }
{       <value expression>                                                     }
{     | <generalized expression>                                               }
{     | <target specification>                                                 }
{                                                                              }
{ SQL99:                                                                       }
{ <generalized expression> ::=                                                 }
{     <value expression> AS <user-defined type>                                }
{                                                                              }
{ SQL2003:                                                                     }
{ <generalized expression> ::=                                                 }
{     <value expression> AS <path-resolved user-defined type name>             }
function TSqlParser.ParseSqlArgument: TObject;
begin
  ParseValueExpression(nil);
  if SkipToken(ttAS) then
    ParseUserDefinedType;
  ParseTargetSpecification;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <SQL argument list> ::=                                                      }
{     <left paren> [ <SQL argument> [ ( <comma> <SQL argument> )... ] ]        }
{     <right paren>                                                            }
function TSqlParser.ParseSqlArgumentList: TObject;
begin
  ExpectLeftParen;
  ParseSqlArgument;
  while SkipToken(ttComma) do
    begin
      ParseSqlArgument;
    end;
  ExpectRightParen;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <call statement> ::= CALL <routine invocation>                               }
{ <routine invocation> ::= <routine name> <SQL argument list>                  }
function TSqlParser.ParseCallStatement: ASqlStatement;
begin
  Assert(FTokenType = ttCALL);
  GetNextToken;
  ParseRoutineName;
  ParseSqlArgumentList;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <return value> ::= <value expression> | NULL                                 }
function TSqlParser.ParseReturnValue: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <return statement> ::= RETURN <return value>                                 }
function TSqlParser.ParseReturnStatement: ASqlStatement;
begin
  Assert(FTokenType = ttRETURN);
  GetNextToken;
  if not SkipToken(ttNULL) then
    ParseValueExpression(nil);
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <modified field reference> ::=                                               }
{     <modified field target> <period> <field name>                            }
{ <modified field target> ::=                                                  }
{       <target specification>                                                 }
{     | <left paren> <target specification> <right paren>                      }
{     | <modified field reference>                                             }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseModifiedFieldReference: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <mutator reference> ::=                                                      }
{     <mutated target specification> <period> <method name>                    }
{ <mutated target specification> ::=                                           }
{       <target specification>                                                 }
{     | <left paren> <target specification> <right paren>                      }
{     | <mutator reference>                                                    }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseMutatorReference: TObject;
begin
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <assignment target> ::=                                                      }
{       <target specification>                                                 }
{     | <modified field reference>                                             }
{     | <mutator reference>                                                    }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseAssignmentTarget: TObject;
begin
  ParseTargetSpecification;
  ParseModifiedFieldReference;
  ParseMutatorReference;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <assignment source> ::= <value expression> | <contextually typed source>     }
{ <contextually typed source> ::=                                              }
{       <implicitly typed value specification>                                 }
{     | <contextually typed row value expression>                              }
{ <contextually typed row value expression> ::=                                }
{       <row value special case>                                               }
{     | <contextually typed row value constructor>                             }
{ <contextually typed row value constructor> ::=                               }
{	      <contextually typed row value constructor element>                     }
{     | [ ROW ] <left paren>                                                   }
{       <contextually typed row value constructor element list> <right paren>  }
{ <contextually typed row value constructor element> ::=                       }
{     <value expression> | <contextually typed value specification>            }
{ <contextually typed value specification> ::=                                 }
{     <implicitly typed value specification> | <default specification>         }
function TSqlParser.ParseAssignmentSource: TObject;
begin
  ParseValueExpression;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <assignment statement> ::=                                                   }
{     SET <assignment target> <equals operator> <assignment source>            }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseAssignmentStatement: ASqlStatement;
begin
  Assert(FTokenType = ttSET);
  GetNextToken;
  ParseAssignmentTarget;
  ExpectEqualSign;
  ParseAssignmentSource;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <beginning label> ::= <statement label>                                      }
{ <ending label> ::= <statement label>                                         }
{ <statement label> ::= <identifier>                                           }
function TSqlParser.ParseStatementLabel: AnsiString;
begin
  Result := ParseIdentifier;
end;

{ SQL99:                                                                       }
{ <while statement> ::=                                                        }
{     [ <beginning label> <colon> ] WHILE <search condition>                   }
{     DO <SQL statement list> END WHILE [ <ending label> ]                     }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseSql99WhileStatement: TSqlWhileStatement;
begin
  if ParseStatementLabel <> '' then
    ExpectToken(ttColon, ': expected');
  ExpectKeyword(ttWHILE, SQL_KEYWORD_WHILE);
  Result := TSqlWhileStatement.Create;
  try
    Result.Condition := ParseSearchCondition;
    ExpectKeyword(ttDO, SQL_KEYWORD_DO);
    Result.Statement := ParseSqlStatementList;
    ExpectKeyword(ttEND, SQL_KEYWORD_END);
    ExpectKeyword(ttWHILE, SQL_KEYWORD_WHILE);
    ParseStatementLabel;
  except
    Result.Free;
    raise;
  end;
end;

{ SQL99:                                                                       }
{ <repeat statement> ::=                                                       }
{     [ <beginning label> <colon> ] REPEAT <SQL statement list>                }
{     UNTIL <search condition> END REPEAT [ <ending label> ]                   }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseRepeatStatement: ASqlStatement;
begin
  if ParseStatementLabel <> '' then
    ExpectToken(ttColon, ': expected');
  ExpectKeyword(ttREPEAT, SQL_KEYWORD_REPEAT);
  ParseSqlStatementList;
  ExpectKeyword(ttUNTIL, SQL_KEYWORD_UNTIL);
  ParseSearchCondition;
  ExpectKeyword(ttEND, SQL_KEYWORD_END);
  ExpectKeyword(ttREPEAT, SQL_KEYWORD_REPEAT);
  ParseStatementLabel;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <SQL variable name> ::= <identifier>                                         }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseSqlVariableName: AnsiString;
begin
  Result := ParseIdentifier;
end;

{ SQL99:                                                                       }
{ <SQL variable name list> ::=                                                 }
{     <SQL variable name> [ ( <comma> <SQL variable name> )... ]               }
function TSqlParser.ParseSqlVariableNameList: TObject;
begin
  ParseSqlVariableName;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <SQL variable declaration> ::=                                               }
{     DECLARE <SQL variable name list> <data type> [ <default clause> ]        }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseSqlVariableDeclaration: TObject;
begin
  Assert(FTokenType = ttDECLARE);
  GetNextToken;
  ParseSQLVariableNameList;
  ExpectDataType(nil);
  ParseDefaultClause;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <condition name> ::= <identifier>                                            }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseConditionName: AnsiString;
begin
  Result := ParseIdentifier;
end;

{ SQL99:                                                                       }
{ <sqlstate value> ::= SQLSTATE [ VALUE ] <character string literal>           }
function TSqlParser.ParseSqlStateValue: TObject;
begin
  ExpectKeyword(ttSQLSTATE, SQL_KEYWORD_SQLSTATE);
  SkipToken(ttVALUE);
  ParseCharacterStringLiteral;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <condition declaration> ::=                                                  }
{     DECLARE <condition name> CONDITION                                       }
{         [ FOR <sqlstate value> ]                                             }
{                                                                              }
{ SQL2003: Not used                                                            }
function TSqlParser.ParseConditionDeclaration: TObject;
begin
  Assert(FTokenType = ttDECLARE);
  GetNextToken;
  ParseConditionName;
  ExpectKeyword(ttCONDITION, SQL_KEYWORD_CONDITION);
  if SkipToken(ttFOR) then
    ParseSqlStateValue;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <local declaration list> ::= <terminated local declaration>...               }
{ <terminated local declaration> ::= <local declaration> <semicolon>           }
{ <local declaration> ::=                                                      }
{       <SQL variable declaration>                                             }
{     | <condition declaration>                                                }
function TSqlParser.ParseLocalDeclarationList: TObject;
begin
  ParseSqlVariableDeclaration;
  ParseConditionDeclaration;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <local cursor declaration list> ::= <terminated local cursor declaration>... }
{ <terminated local cursor declaration> ::= <declare cursor> <semicolon>       }
function TSqlParser.ParseLocalCursorDeclarationList: TObject;
begin
  ParseDeclareCursor;
  ExpectToken(ttSemicolon, '; expected');
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <handler type> ::= CONTINUE | EXIT | UNDO                                    }
function TSqlParser.ParseHandlerType: Integer;
begin
  case FTokenType of
    ttCONTINUE : ;
    ttEXIT     : ;
    ttUNDO     : ;
  end;
  //// TODO
  Result := -1;
end;

{ SQL99:                                                                       }
{ <condition value> ::=                                                        }
{       <sqlstate value>                                                       }
{     | <condition name>                                                       }
{     | SQLEXCEPTION                                                           }
{     | SQLWARNING                                                             }
{     | NOT FOUND                                                              }
function TSqlParser.ParseConditionValue: TObject;
begin
  ParseSqlStateValue;
  ParseConditionName;
  case FTokenType of
    ttSQLEXCEPTION : ;
    ttSQLWARNING   : ;
    ttNOT          :
      begin
        GetNextToken;
        ExpectKeyword(ttFOUND, SQL_KEYWORD_FOUND);
      end;
  end;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <condition value list> ::=                                                   }
{     <condition value> [ ( <comma> <condition value> )... ]                   }
function TSqlParser.ParseConditionValueList: TObject;
begin
  ParseConditionValue;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <local handler declaration list> ::=                                         }
{     <terminated local handler declaration>...                                }
{ <terminated local handler declaration> ::= <handler declaration> <semicolon> }
{ <handler declaration> ::=                                                    }
{     DECLARE <handler type> HANDLER FOR <condition value list>                }
{     <handler action>                                                         }
{ <handler action> ::= <SQL procedure statement>                               }
function TSqlParser.ParseLocalHandlerDeclarationList: TObject;
begin
  Assert(FTokenType = ttDECLARE);
  GetNextToken;
  ParseHandlerType;
  ExpectKeyword(ttHANDLER, SQL_KEYWORD_HANDLER);
  ExpectKeyword(ttFOR, SQL_KEYWORD_FOR);
  ParseConditionValueList;
  ParseSqlProcedureStatement;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <compound statement> ::=                                                     }
{    [ <beginning label> <colon> ] BEGIN [ [ NOT ] ATOMIC ]                    }
{    [ <local declaration list> ]                                              }
{    [ <local cursor declaration list> ]                                       }
{    [ <local handler declaration list> ]                                      }
{    [ <SQL statement list> ] END [ <ending label> ]                           }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseCompoundStatement: ASqlStatement;
begin
  if ParseStatementLabel <> '' then
    ExpectToken(ttColon, ': expected');
  ExpectKeyword(ttBEGIN, SQL_KEYWORD_BEGIN);
  SkipToken(ttNOT);
  SkipToken(ttATOMIC);
  ParseLocalDeclarationList;
  ParseLocalCursorDeclarationList;
  ParseLocalHandlerDeclarationList;
  ParseSqlStatementList;
  ExpectKeyword(ttEND, SQL_KEYWORD_END);
  ParseStatementLabel;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <simple case statement> ::=                                                  }
{     CASE <simple case operand 1> <simple case statement when clause>...      }
{     [ <case statement else clause> ] END CASE                                }
{ <simple case operand 1> ::= <value expression>                               }
{ <simple case statement when clause> ::=                                      }
{     WHEN <simple case operand 2> THEN <SQL statement list>                   }
{ <simple case operand 2> ::= <value expression>                               }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseSimpleCaseStatement: ASqlStatement;
begin
  Assert(FTokenType = ttCASE);
  GetNextToken;
  ParseValueExpression(nil);
  ExpectKeyword(ttWHEN, SQL_KEYWORD_WHEN);
  ParseValueExpression(nil);
  ExpectKeyword(ttTHEN, SQL_KEYWORD_THEN);
  ParseSqlStatementList;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <searched case statement> ::=                                                }
{     CASE <searched case statement when clause>...                            }
{         [ <case statement else clause> ] END CASE                            }
{ <searched case statement when clause> ::=                                    }
{     WHEN <search condition> THEN <SQL statement list>                        }
{ <case statement else clause> ::= ELSE <SQL statement list>                   }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseSearchedCaseStatement: ASqlStatement;
begin
  Assert(FTokenType = ttCASE);
  GetNextToken;
  ExpectKeyword(ttWHEN, SQL_KEYWORD_WHEN);
  ParseSearchCondition;
  ExpectKeyword(ttTHEN, SQL_KEYWORD_THEN);
  ParseSqlStatementList;
  if SkipToken(ttELSE) then
    ParseSqlStatementList;
  ExpectKeyword(ttEND, SQL_KEYWORD_END);
  ExpectKeyword(ttCASE, SQL_KEYWORD_CASE);
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <case statement> ::=                                                         }
{       <simple case statement>                                                }
{     | <searched case statement>                                              }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseCaseStatement: ASqlStatement;
begin
  Assert(FTokenType = ttCASE);
  GetNextToken;
  //// TODO
  Result := nil;
end;

{ SQL99/SQL2003:                                                               }
{ <cursor sensitivity> ::= SENSITIVE | INSENSITIVE | ASENSITIVE                }
function TSqlParser.ParseCursorSensitivity: Integer;
begin
  case FTokenType of
    ttSENSITIVE   : ;
    ttINSENSITIVE : ;
    ttASENSITIVE  : ;
  end;
  //// TODO
  Result := -1;
end;

{ SQL99:                                                                       }
{ <for statement> ::=                                                          }
{     [ <beginning label> <colon> ]                                            }
{     FOR <for loop variable name> AS                                          }
{         [ <cursor name> [ <cursor sensitivity> ] CURSOR FOR ]                }
{         <cursor specification>                                               }
{         DO <SQL statement list> END FOR [ <ending label> ]                   }
{ <for loop variable name> ::= <identifier>                                    }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseForStatement: ASqlStatement;
begin
  if ParseStatementLabel <> '' then
    ExpectToken(ttColon, ': expected');
  ExpectKeyword(ttFOR, SQL_KEYWORD_FOR);
  ParseIdentifier;
  ExpectKeyword(ttAS, SQL_KEYWORD_AS);
  if ParseCursorName <> '' then
    begin
      ParseCursorSensitivity;
      ExpectKeyword(ttCURSOR, SQL_KEYWORD_CURSOR);
      ExpectKeyword(ttFOR, SQL_KEYWORD_FOR);
    end;
  ParseCursorSpecification;
  ExpectKeyword(ttDO, SQL_KEYWORD_DO);
  ParseSqlStatementList;
  ExpectKeyword(ttEND, SQL_KEYWORD_END);
  ExpectKeyword(ttFOR, SQL_KEYWORD_FOR);
  ParseStatementLabel;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <loop statement> ::=                                                         }
{     [ <beginning label> <colon> ]                                            }
{     LOOP <SQL statement list> END LOOP [ <ending label> ]                    }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseLoopStatement: ASqlStatement;
begin
  if ParseStatementLabel <> '' then
    ExpectToken(ttColon, ': expected');
  ExpectKeyword(ttLOOP, SQL_KEYWORD_LOOP);
  ParseSqlStatementList;
  ExpectKeyword(ttEND, SQL_KEYWORD_END);
  ExpectKeyword(ttLOOP, SQL_KEYWORD_LOOP);
  ParseStatementLabel;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <iterate statement> ::= ITERATE <statement label>                            }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseIterateStatement: ASqlStatement;
begin
  Assert(FTokenType = ttITERATE);
  GetNextToken;
  ParseStatementLabel;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <leave statement> ::= LEAVE <statement label>                                }
{                                                                              }
{ SQL2003: Not used ??                                                         }
function TSqlParser.ParseLeaveStatement: ASqlStatement;
begin
  Assert(FTokenType = ttLEAVE);
  GetNextToken;
  ParseStatementLabel;
  //// TODO
  Result := nil;
end;

{ SQL99:                                                                       }
{ <SQL control statement> ::=                                                  }
{       <call statement>                                                       }
{     | <return statement>                                                     }
{     | <assignment statement>                                                 }
{     | <compound statement>                                                   }
{     | <case statement>                                                       }
{     | <if statement>                                                         }
{     | <iterate statement>                                                    }
{     | <leave statement>                                                      }
{     | <loop statement>                                                       }
{     | <while statement>                                                      }
{     | <repeat statement>                                                     }
{     | <for statement>                                                        }
{                                                                              }
{ SQL2003:                                                                     }
{ <SQL control statement> ::=                                                  }
{       <call statement>                                                       }
{     | <return statement>                                                     }
{ ??                                                                           }
function TSqlParser.ParseSqlControlStatement: ASqlStatement;
begin
  case FTokenType of
    ttCALL    : Result := ParseCallStatement;
    ttRETURN  : Result := ParseReturnStatement;
    ttSET     : Result := ParseAssignmentStatement;
    ttBEGIN   : Result := ParseCompoundStatement;
    ttCASE    : Result := ParseCaseStatement;
    ttIF      : Result := ParseSql99IfStatement;
    ttITERATE : Result := ParseIterateStatement;
    ttLEAVE	  : Result := ParseLeaveStatement;
    ttLOOP    : Result := ParseLoopStatement;
    ttWHILE   : Result := ParseSql99WhileStatement;
    ttREPEAT  : Result := ParseRepeatStatement;
    ttFOR     : Result := ParseForStatement;
  else
    Result := nil;
  end;
end;

{ SQL92:                                                                       }
{ <SQL procedure statement> ::=                                                }
{       <SQL schema statement>                                                 }
{     | <SQL data statement>                                                   }
{     | <SQL transaction statement>                                            }
{     | <SQL connection statement>                                             }
{     | <SQL session statement>                                                }
{     | <SQL dynamic statement>                                                }
{     | <SQL diagnostics statement>                                            }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <SQL procedure statement> ::= <SQL executable statement>                     }
{ <SQL executable statement> ::=                                               }
{       <SQL schema statement>                                                 }
{     | <SQL data statement>                                                   }
{     | <SQL control statement>                                                }
{     | <SQL transaction statement>                                            }
{     | <SQL connection statement>                                             }
{     | <SQL session statement>                                                }
{     | <SQL diagnostics statement>                                            }
{     | <SQL dynamic statement>                                                }
function TSqlParser.ParseSqlProcedureStatement: ASqlStatement;
begin
  Result := nil;
  case FTokenType of
    ttCREATE,
    ttGRANT,
    ttDROP,
    ttALTER,
    ttREVOKE     : Result := ParseSqlSchemaStatement;
    ttSELECT,
    ttINSERT     : Result := ParseSqlDataStatement;
    ttCOMMIT,
    ttROLLBACK   : Result := ParseSqlTransactionStatement;
    ttCONNECT,
    ttDISCONNECT : Result := ParseSqlConnectionStatement;
    ttALLOCATE,
    ttDEALLOCATE,
    ttPREPARE,
    ttDESCRIBE,
    ttEXEC,
    ttEXECUTE,
    ttOPEN,
    ttFETCH,
    ttCLOSE      : Result := ParseSqlDynamicStatement;
    ttDELETE     : Result := ParseDeleteStatement(sdsUndefined);
    ttUPDATE     : Result := ParseUpdateStatement(supUndefined);
    ttSET        :
      case GetNextToken of
        ttCATALOG    : Result := ParseSetCatalogStatement;
        ttSCHEMA     : Result := ParseSetSchemaStatement;
        ttNAMES      : Result := ParseSetNamesStatement;
        ttSESSION    : Result := ParseSetSessionAuthorizationIdentifierStatement;
        ttTIME       : Result := ParseSetLocalTimeZoneStatement;
        ttDESCRIPTOR : Result := ParseSetDescriptorStatement;
      else
        ParseError('SET identifier expected');
      end;
    ttGET        :
      case GetNextToken of
        ttDESCRIPTOR  : Result := ParseGetDescriptorStatement;
        ttDIAGNOSTICS : Result := ParseSqlDiagnosticsStatement;
      else
        ParseError('GET identifier expected');
      end;
  else
    if FCompatibility >= spcSql99 then
      Result := ParseSqlControlStatement
    else
      Result := nil;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <updatability clause> ::= FOR                                                }
{         ( READ ONLY | UPDATE [ OF <column name list> ] )                     }
function TSqlParser.ParseUpdatabilityClause: TSqlUpdatabilityClause;
begin
  if SkipToken(ttFOR) then
    begin
      Result := TSqlUpdatabilityClause.Create;
      with Result do
        try
          case FTokenType of
            ttREAD :
              begin
                GetNextToken;
                ExpectKeyword(ttONLY, SQL_KEYWORD_ONLY);
                UpdatabilityType := sucReadOnly;
              end;
            ttUPDATE :
              begin
                GetNextToken;
                UpdatabilityType := sucUpdate;
                if SkipToken(ttOF) then
                  ColumnNameList := ParseColumnNameList;
              end;
          else
            ParseError('READ ONLY or UPDATE expected');
          end;
        except
          Result.Free;
          raise;
        end;
    end
  else
    Result := nil;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <cursor specification> ::=                                                   }
{     <query expression> [ <order by clause> ]                                 }
{       [ <updatability clause> ]                                              }
function TSqlParser.ParseCursorSpecification: TSqlCursorSpecification;
begin
  Result := TSqlCursorSpecification.Create;
  with Result do
    try
      QueryExpr := ExpectQueryExpression;
      OrderBy := ParseOrderByClause;
      Updatability := ParseUpdatabilityClause;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <declare cursor> ::=                                                         }
{     DECLARE <cursor name>                                                    }
{     [ INSENSITIVE ] [ SCROLL ]                                               }
{     CURSOR                                                                   }
{     FOR <cursor specification>                                               }
{ <dynamic declare cursor> ::=                                                 }
{     DECLARE <cursor name>                                                    }
{     [ INSENSITIVE ] [ SCROLL ]                                               }
{     CURSOR                                                                   }
{     FOR <statement name>                                                     }
{ <statement name> ::= <identifier>                                            }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <declare cursor> ::=                                                         }
{     DECLARE <cursor name>                                                    }
{     [ <cursor sensitivity> ] [ <cursor scrollability> ]                      }
{     CURSOR                                                                   }
{     [ <cursor holdability> ] [ <cursor returnability> ]                      }
{     FOR <cursor specification>                                               }
{ <dynamic declare cursor> ::=                                                 }
{     DECLARE <cursor name>                                                    }
{     [ <cursor sensitivity> ] [ <cursor scrollability> ]                      }
{     CURSOR                                                                   }
{     [ <cursor holdability> ] [ <cursor returnability> ]                      }
{     FOR <statement name>                                                     }
{ <cursor scrollability> ::= SCROLL | NO SCROLL                                }
{ <cursor holdability> ::= WITH HOLD | WITHOUT HOLD                            }
{ <cursor returnability> ::= WITH RETURN | WITHOUT RETURN                      }
{ <cursor sensitivity> ::= SENSITIVE | INSENSITIVE | ASENSITIVE                }
function TSqlParser.ParseDeclareCursor: TSqlDeclareCursorStatement;
begin
  Result := TSqlDeclareCursorStatement.Create;
  with Result do
    try
      CursorName := ParseCursorName;
      Insensitive := SkipToken(ttINSENSITIVE);
      Scroll := SkipToken(ttSCROLL);
      ExpectKeyword(ttCURSOR, SQL_KEYWORD_CURSOR);
      ExpectKeyword(ttFOR, SQL_KEYWORD_FOR);
      if FTokenType = ttIdentifier then
        StatementName := ParseIdentifier
      else
        CursorSpec := ParseCursorSpecification;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <condition> ::= SQLERROR | NOT FOUND                                         }
{                                                                              }
{ SQL99:                                                                       }
{ <condition> ::= <SQL condition>                                              }
{ <SQL condition> ::=                                                          }
{       <major category>                                                       }
{     | SQLSTATE <left paren> <SQLSTATE class value>                           }
{       [ <comma> <SQLSTATE subclass value> ] <right paren>                    }
{     | CONSTRAINT <constraint name>                                           }
{ <major category> ::= SQLEXCEPTION | SQLWARNING | NOT FOUND                   }
{ <SQLSTATE class value> ::=                                                   }
{     <SQLSTATE char><SQLSTATE char> !! (See the Syntax Rules.)                }
{ <SQLSTATE char> ::= <simple Latin upper case letter> | <digit>               }
{                                                                              }
{ SQL2003:                                                                     }
{ <SQL condition> ::=                                                          }
{       <major category>                                                       }
{     | SQLSTATE ( <SQLSTATE class value> [ , <SQLSTATE subclass value> ] )    }
{     | CONSTRAINT <constraint name>                                           }
{ <SQLSTATE class value> ::=                                                   }
{     <SQLSTATE char><SQLSTATE char> !! See the Syntax Rules.                  }
{ <SQLSTATE subclass value> ::=                                                }
{     <SQLSTATE char><SQLSTATE char><SQLSTATE char> !! See the Syntax Rules.   }
function TSqlParser.ParseCondition: TSqlExceptionCondition;
begin
  Result := secUndefined;
  case FTokenType of
    ttSQLERROR :
      begin
        GetNextToken;
        Result := secSqlError;
      end;
    ttNOT :
      begin
        GetNextToken;
        ExpectKeyword(ttFOUND, SQL_KEYWORD_FOUND);
      end;
  else
    ParseError('Exception condition expected');
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <condition action> ::= CONTINUE | <go to>                                    }
{ <go to> ::= ( GOTO | GO TO ) <goto target>                                   }
{ <goto target> ::=                                                            }
{       <host label identifier>                                                }
{     | <unsigned integer>                                                     }
{     | <host PL/I label variable>                                             }
function TSqlParser.ParseConditionAction: TSqlExceptionConditionAction;
begin
  Result := TSqlExceptionConditionAction.Create;
  with Result do
    try
      case FTokenType of
        ttCONTINUE : ActionType := seaContinue;
        ttGOTO     : ActionType := seaGoTo;
        ttGO       :
          begin
            GetNextToken;
            ExpectKeyword(ttTO, SQL_KEYWORD_TO);
            ActionType := seaGoTo;
          end;
      else
        ParseError('Exception condition action expected');
      end;
      if Result.ActionType = seaGoTo then
        case FTokenType of
          ttUnsignedInteger : Index := ExpectUnsignedInteger;
          ttIdentifier      : Identifier := ParseIdentifier;
        else
          ParseError('GOTO target expected');
        end;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <embedded exception declaration> ::=                                         }
{     WHENEVER <condition> <condition action>                                  }
function TSqlParser.ParseEmbeddedExceptionDeclaration: TSqlEmbeddedExceptionDeclaration;
begin
  Assert(FTokenType = ttWHENEVER);
  GetNextToken;
  Result := TSqlEmbeddedExceptionDeclaration.Create;
  with Result do
    try
      Condition := ParseCondition;
      Action := ParseConditionAction;
    except
      Result.Free;
      raise;
    end;
end;

{ SQL92:                                                                       }
{ <statement or declaration> ::=                                               }
{       <declare cursor>                                                       }
{     | <dynamic declare cursor>                                               }
{     | <temporary table declaration>                                          }
{     | <embedded exception declaration>                                       }
{     | <SQL procedure statement>                                              }
{                                                                              }
{ SQL99:                                                                       }
{ <statement or declaration> ::=                                               }
{       <declare cursor>                                                       }
{     | <dynamic declare cursor>                                               }
{     | <temporary table declaration>                                          }
{     | <embedded authorization declaration>                                   }
{     | <embedded path specification>                                          }
{     | <embedded transform group specification>                               }
{     | <embedded exception declaration>                                       }
{     | <handler declaration>                                                  }
{     | <SQL-invoked routine>                                                  }
{     | <SQL procedure statement>                                              }
{                                                                              }
{ SQL2003:                                                                     }
{ <statement or declaration> ::=                                               }
{       <declare cursor>                                                       }
{     | <dynamic declare cursor>                                               }
{     | <temporary table declaration>                                          }
{     | <embedded authorization declaration>                                   }
{     | <embedded path specification>                                          }
{     | <embedded transform group specification>                               }
{     | <embedded collation specification>                                     }
{     | <embedded exception declaration>                                       }
{     | <handler declaration>                                                  }
{     | <SQL procedure statement>                                              }
function TSqlParser.ParseStatementOrDeclaration: ASqlStatement;
begin
  case FTokenType of
    ttDECLARE :
      begin
        case GetNextToken of
          ttLOCAL      : Result := ParseTemporaryTableDeclaration;
          ttIdentifier : Result := ParseDeclareCursor;
        else
          Result := nil;
        end;
        if not Assigned(Result) then
          ParseError('Declaration type expected');
        exit;
      end;
    ttWHENEVER :
      Result := ParseEmbeddedExceptionDeclaration;
  else
    Result := ParseSqlProcedureStatement;;
  end;
end;

{ SQL92:                                                                       }
{ ::= EXEC SQL <statement or declaration> END-EXEC | <semicolon>               }
function TSqlParser.ParseEmbeddedSqlStatementForm1: TSqlEmbeddedSqlStatement;
begin
  Assert(FTokenType = ttSQL);
  GetNextToken;
  Result := TSqlEmbeddedSQLStatement.Create;
  try
    Result.SQLStatement := ParseStatementOrDeclaration;
    if not SkipToken(ttSemiColon) then
      ExpectToken(ttENDEXEC, 'END-EXEC expected');
  except
    Result.Free;
    raise;
  end;
end;

{ SQL92:                                                                       }
{ ::= <ampersand>SQL<left paren> <statement or declaration> <right paren>      }
function TSqlParser.ParseEmbeddedSqlStatementForm2: TSqlEmbeddedSqlStatement;
begin
  Assert(FTokenType = ttEmbeddedSQLPrefix);
  GetNextToken;
  Result := TSqlEmbeddedSQLStatement.Create;
  try
    Result.SQLStatement := ParseStatementOrDeclaration;
    ExpectRightParen;
  except
    Result.Free;
    raise;
  end;
end;

{ SQL92/SQL99/SQL2003:                                                         }
{ <embedded SQL statement> ::=                                                 }
{     <SQL prefix>                                                             }
{       <statement or declaration>                                             }
{     [ <SQL terminator> ]                                                     }
{ <SQL prefix> ::= EXEC SQL | <ampersand>SQL<left paren>                       }
{ <SQL terminator> ::= END-EXEC | <semicolon> | <right paren>                  }
function TSqlParser.ParseEmbeddedSqlStatement: ASqlStatement;
begin
  case FTokenType of
    ttEXEC :
      begin
        GetNextToken;
        CheckToken(ttSQL, 'SQL expected');
        Result := ParseEmbeddedSqlStatementForm1;
      end;
    ttEmbeddedSqlPrefix :
      Result := ParseEmbeddedSqlStatementForm2;
  else
    Result := nil;
  end;
end;

{ SQL92/SQL99:                                                                 }
{ <preparable SQL data statement> ::=                                          }
{       <delete statement: searched>                                           }
{     | <dynamic single row select statement>                                  }
{     | <insert statement>                                                     }
{     | <dynamic select statement>                                             }
{     | <update statement: searched>                                           }
{     | <preparable dynamic delete statement: positioned>                      }
{     | <preparable dynamic update statement: positioned>                      }
{ <dynamic single row select statement> ::= <query specification>              }
{ <dynamic select statement> ::= <cursor specification>                        }
{                                                                              }
{ SQL2003:                                                                     }
{ <preparable SQL data statement> ::=                                          }
{ 		<delete statement: searched>                                             }
{ 	|	<dynamic single row select statement>                                    }
{ 	|	<insert statement>                                                       }
{   |	<dynamic select statement>                                               }
{   |	<update statement: searched>                                             }
{   |	<merge statement>                                                        }
{ 	|	<preparable dynamic delete statement: positioned>                        }
{   |	<preparable dynamic update statement: positioned>                        }
function TSqlParser.ParsePreparableSqlDataStatement: ASqlStatement;
begin
  case FTokenType of
    ttDELETE : Result := ParseDeleteStatementSearched;
    ttSELECT : Result := ParseSelectStatement;
    ttINSERT : Result := ParseInsertStatement;
    ttUPDATE : Result := ParseUpdateStatementSearched;
    ttMERGE  : Result := ParseMergeStatement;
  else
    Result := nil;
  end;
end;

{ SQL92:                                                                       }
{ <preparable statement> ::=                                                   }
{       <preparable SQL data statement>                                        }
{     | <preparable SQL schema statement>                                      }
{     | <preparable SQL transaction statement>                                 }
{     | <preparable SQL session statement>                                     }
{     | <preparable implementation-defined statement>                          }
{ <preparable SQL schema statement> ::= <SQL schema statement>                 }
{ <preparable SQL transaction statement> ::= <SQL transaction statement>       }
{ <preparable SQL session statement> ::= <SQL session statement>               }
{ <preparable implementation-defined statement> ::= #EXT                       }
{                                                                              }
{ SQL99:                                                                       }
{ <preparable SQL control statement> ::= <SQL control statement>               }
{                                                                              }
{ SQL99/SQL2003:                                                               }
{ <preparable statement> ::=                                                   }
{       <preparable SQL data statement>                                        }
{     | <preparable SQL schema statement>                                      }
{     | <preparable SQL transaction statement>                                 }
{     | <preparable SQL control statement>                                     }
{     | <preparable SQL session statement>                                     }
{     | <preparable implementation-defined statement>                          }
function TSqlParser.ParsePreparableStatement: ASqlStatement;
begin
  case FTokenType of
    ttDELETE,
    ttSELECT,
    ttINSERT,
    ttUPDATE   : Result := ParsePreparableSqlDataStatement;
    ttCREATE,
    ttGRANT,
    ttDROP,
    ttALTER,
    ttREVOKE   : Result := ParseSqlSchemaStatement;
    ttCOMMIT,
    ttROLLBACK : Result := ParseSqlTransactionStatement;
    ttSET      : Result := ParseSqlSessionStatement;
  else
    Result := nil;
  end;
end;

{ EXT:                                                                         }
{ <USE statement> ::= USE <database name>                                      }
function TSqlParser.ParseUseStatement: TSqlUseStatement;
begin
  if FTokenType = ttUSE then
    begin
      if not (spoExtendedSyntax in FOptions) then
        UnexpectedToken;
      GetNextToken;
      Result := TSqlUseStatement.Create;
      try
        Result.DatabaseName := ExpectIdentifier(True);
      except
        Result.Free;
        raise;
      end;
    end
  else
    Result := nil;
end;

{ MSSQL:                                                                       }
{ <parameter definition> ::=                                                   }
{     ( @parameter data_type ) [ VARYING ] [ = default ] [ OUTPUT ]            }
function TSqlParser.ParseParameterDefinition: TSqlParameterDefinition;
var V : ASqlValueExpression;
begin
  if FTokenType = ttLocalIdentifier then
    begin
      Result := TSqlParameterDefinition.Create;
      try
        Result.Name := FLexer.TokenStr;
        GetNextToken;
        if (SqlTokenToDataType(FTokenType) <> stUndefined) or (FTokenType = ttNATIONAL) then
          begin
            Result.TypeDef := TSqlDataTypeDefinition.Create;
            ExpectDataType(Result.TypeDef);
          end;
        Result.Varying := (FTokenType = ttVARYING);
        if Result.Varying then
          GetNextToken;
        if SkipToken(ttEqual) then
          begin
            V := ParseLiteral;
            Result.DefaultValue := V.Evaluate(ASqlDatabaseEngine(nil), nil, nil);
          end;
        SkipToken(ttOUTPUT);
      except
        Result.Free;
        raise;
      end;
    end
  else
    Result := nil;
end;

{ MSSQL:                                                                       }
{ <procedure definition> ::=                                                   }
{ [ owner. ] procedure_name [ ; number ]                                       }
{     [ <parameter definition> ] [ ,...n ]                                     }
{ [ WITH ( RECOMPILE | ENCRYPTION | RECOMPILE , ENCRYPTION ) ]                 }
{ [ FOR REPLICATION ]                                                          }
{ AS sql_statement [ ...n ]                                                    }
function TSqlParser.ParseProcedureDefinition: TSqlProcedureDefinition;
var D : TSqlParameterDefinition;
    E : TSqlParameterDefinitionArray;
    S : ASqlStatementArray;
    P : Boolean;
    R : Boolean;
begin
  Result := TSqlProcedureDefinition.Create;
  try
    Result.Name := ExpectIdentifier;
    if SkipToken(ttPeriod) then
      Result.Name := Result.Name + ExpectIdentifier;
    P := SkipToken(ttLeftParen);
    D := ParseParameterDefinition;
    if Assigned(D) then
      repeat
        Append(ObjectArray(E), D);
        R := SkipToken(ttComma);
        if R then
          D := ParseParameterDefinition;
      until not R;
    Result.Parameters := E;
    if P then
      ExpectRightParen;
    if SkipToken(ttWITH) then
      ExpectKeyword(ttRECOMPILE, SQL_KEYWORD_RECOMPILE);
    ExpectKeyword(ttAS, SQL_KEYWORD_AS);
    while not (FTokenType in [ttGO, ttEof]) do
      Append(ObjectArray(S), ParseStatement);
    Result.Statements := S;
  except
    Result.Free;
    raise;
  end;
end;

{ MSSQL:                                                                       }
{ <create procedure statement> ::=                                             }
{     CREATE PROC [ EDURE ] <procedure definition>                             }
function TSqlParser.ParseCreateProcedureStatement: TSqlCreateProcedureStatement;
begin
  Assert(FTokenType in [ttPROC, ttPROCEDURE]);
  GetNextToken;
  Result := TSqlCreateProcedureStatement.Create;
  try
    Result.Definition := ParseProcedureDefinition;
  except
    Result.Free;
    raise;
  end;
end;

{ EXT:                                                                         }
{ <statement_block> ::=                                                        }
{   BEGIN ( sql_statement [ <semicolon> ] )... END                             }
function TSqlParser.ParseStatementBlock: TSqlStatementBlock;
var F : Boolean;
begin
  Assert(FTokenType = ttBEGIN);
  if not (spoExtendedSyntax in FOptions) then
    UnexpectedToken;
  GetNextToken;
  Result := TSqlStatementBlock.Create;
  try
    repeat
      while SkipToken(ttSemicolon) do ;
      F := (FTokenType in [ttEND, ttEof]);
      if not F then
        Result.Add(ParseStatement);
    until F;
    ExpectKeyword(ttEND, SQL_KEYWORD_END);
  except
    Result.Free;
    raise;
  end;
end;

{ EXT:                                                                         }
{ <while statement> ::=                                                        }
{     WHILE <condition> <statement>                                            }
function TSqlParser.ParseWhileStatement: TSqlWhileStatement;
begin
  Assert(FTokenType = ttWHILE);
  if not (spoExtendedSyntax in FOptions) then
    UnexpectedToken;
  GetNextToken;
  Result := TSqlWhileStatement.Create;
  with Result do
    try
      Condition := ExpectSearchCondition;
      Statement := ParseStatement;
    except
      Result.Free;
      raise;
    end;
end;

{ EXT:                                                                         }
{ <select statement> ::=                                                       }
{     ( <query expression> | <select statement: single row> )                  }
{     [ <order by clause> ]                                                    }
function TSqlParser.ParseSelectStatement: TSqlSelectStatement;
begin
  Assert(FTokenType = ttSELECT);
  Result := TSqlSelectStatement.Create;
  with Result do
    try
      QueryExpr := ParseQueryExpression(True);
      OrderBy := ParseOrderByClause;
    except
      Result.Free;
      raise;
    end;
end;

{ EXT:                                                                         }
{ <create statement> ::=                                                       }
{     <create procedure statement> |                                           }
{     <definition statement>                                                   }
{ <definition statement> ::=                                                   }
{     <table definition> |                                                     }
{     <schema definition> |                                                    }
{     <view definition> |                                                      }
{     <domain definition> |                                                    }
{     <collation definition> |                                                 }
{     <translation definition> |                                               }
{     <assertion definition> |                                                 }
{     <character set definition> |                                             }
{     <index definition> |                                                     }
{     <database definition> |                                                  }
{     <login definition> |                                                     }
{     <user definition>                                                        }                                                                                                          
function TSqlParser.ParseCreateStatement: ASqlStatement;
begin
  Assert(FTokenType = ttCREATE);
  Result := nil;
  case GetNextToken of
    ttPROC,
    ttPROCEDURE    : Result := ParseCreateProcedureStatement;
    ttGLOBAL,
    ttLOCAL,
    ttTEMPORARY,
    ttTABLE        : Result := ParseTableDefinition;
    ttSCHEMA       : Result := ParseSchemaDefinition;
    ttVIEW         : Result := ParseViewDefinition;
    ttDOMAIN       : Result := ParseDomainDefinition;
    ttCOLLATION    : Result := ParseCollationDefinition;
    ttTRANSLATION  : Result := ParseTranslationDefinition;
    ttASSERTION    : Result := ParseAssertionDefinition;
    ttCHARACTER    :
      begin
        GetNextToken;
        ExpectKeyword(ttSET, SQL_KEYWORD_SET);
        Result := ParseCharacterSetDefinition;
      end;
    ttINDEX        : Result := ParseIndexDefinition;
    ttDATABASE     : Result := ParseDatabaseDefinition;
    ttLOGIN        : Result := ParseLoginDefinition;
    ttUSER         : Result := ParseUserDefinition;	
  else
    UnexpectedToken;
  end;
end;

{ EXT:                                                                         }
{ <drop statement> ::=                                                         }
{       <drop table statement>                                                 }
{     | <drop procedure statement>                                             }
{     | <drop schema statement>                                                }
{     | <drop view statement>                                                  }
{     | <drop domain statement>                                                }
{     | <drop character set statement>                                         }
{     | <drop collation statement>                                             }
{     | <drop translation statement>                                           }
{     | <drop assertion statement>                                             }
function TSqlParser.ParseDropStatement: ASqlStatement;
begin
  Assert(FTokenType = ttDROP);
  Result := nil;
  case GetNextToken of
    ttTABLE       : Result := ParseDropTableStatement;
    ttPROC,
    ttPROCEDURE   : Result := ParseDropProcedureStatement;
    ttSCHEMA      : Result := ParseDropSchemaStatement;
    ttVIEW        : Result := ParseDropViewStatement;
    ttDOMAIN      : Result := ParseDropDomainStatement;
    ttCHARACTER   :
      begin
        GetNextToken;
        ExpectKeyword(ttSET, SQL_KEYWORD_SET);
        Result := ParseDropCharacterSetStatement;
      end;
    ttCOLLATION   : Result := ParseDropCollationStatement;
    ttTRANSLATION : Result := ParseDropTranslationStatement;
    ttASSERTION   : Result := ParseDropAssertionStatement;
    ttDATABASE    : Result := ParseDropDatabaseStatement;
  else
    UnexpectedToken;
  end;
end;

{ MSSQL:                                                                       }
{ <set local variable> ::=                                                     }
{   SET ( @local_variable = expression )                                       }
function TSqlParser.ParseSetLocalVariable: TSqlSetLocalVariableStatement;
begin
  Assert(FTokenType = ttLocalIdentifier);
  Result := TSqlSetLocalVariableStatement.Create;
  with Result do
    try
      Name := FLexer.TokenStr;
      GetNextToken;
      ExpectEqualSign;
      ValueExpr := ParseValueExpression;
    except
      Result.Free;
      raise;
    end;
end;

{ EXT:                                                                         }
{ <set statement> ::=                                                          }
{       <set local variable>                                                   }
{     | <SQL session statement>                                                }
{     | <set session authorization identifier statement>                       }
{     | <local time zone statement>                                            }
{     | <set connection statement>                                             }
{     | <set descriptor statement>                                             }
function TSqlParser.ParseSetStatement: ASqlStatement;
begin
  Assert(FTokenType = ttSET);
  Result := nil;
  case GetNextToken of
    ttLocalIdentifier : Result := ParseSetLocalVariable;
    ttTRANSACTION     : Result := ParseSetTransactionStatement;
    ttCONSTRAINTS     : Result := ParseSetConstraintsModeStatement;
    ttCATALOG         : Result := ParseSetCatalogStatement;
    ttSCHEMA          : Result := ParseSetSchemaStatement;
    ttNAMES           : Result := ParseSetNamesStatement;
    ttSESSION         : Result := ParseSetSessionAuthorizationIdentifierStatement;
    ttTIME            : Result := ParseSetLocalTimeZoneStatement;
    ttCONNECTION      : Result := ParseSetConnectionStatement;
    ttDESCRIPTOR      : Result := ParseSetDescriptorStatement;
  else
    UnexpectedToken;
  end;
end;

{ MSSQL:                                                                       }
{ <declare local variable> ::=                                                 }
{ DECLARE                                                                      }
{     (( @local_variable [AS] data_type )                                      }
{         | ( @cursor_variable_name CURSOR )                                   }
{         | ( table_type_definition )                                          }
{     ) [ ,...n]                                                               }
function TSqlParser.ParseDeclareLocalVariable: TSqlDeclareLocalVariableStatement;
begin
  Assert(FTokenType = ttLocalIdentifier);
  Result := TSqlDeclareLocalVariableStatement.Create;
  with Result do
    try
      Name := FLexer.TokenStr;
      GetNextToken;
      SkipToken(ttAS);
      TypeDef := TSqlDataTypeDefinition.Create;
      ExpectDataType(TypeDef);
    except
      Result.Free;
      raise;
    end;
end;

{ EXT:                                                                         }
{ <declare statement> ::=                                                      }
{       <declare local variable>                                               }
{     | <temporary table declaration>                                          }
{     | <declare cursor>                                                       }
function TSqlParser.ParseDeclareStatement: ASqlStatement;
begin
  Assert(FTokenType = ttDECLARE);
  Result := nil;
  case GetNextToken of
    ttLocalIdentifier : Result := ParseDeclareLocalVariable;
    ttLOCAL           : Result := ParseTemporaryTableDeclaration;
    ttIdentifier      : Result := ParseDeclareCursor;
  else
    ParseError('Declaration type expected');
  end;
end;

{ EXT:                                                                         }
{ <alter statement> ::=                                                        }
{       <alter table statement>                                                }
{     | <alter domain statement>                                               }
function TSqlParser.ParseAlterStatement: ASqlStatement;
begin
  Assert(FTokenType = ttALTER);
  Result := nil;
  case GetNextToken of
    ttTABLE  : Result := ParseAlterTableStatement;
    ttDOMAIN : Result := ParseAlterDomainStatement;
  else
    ParseError('Alter type expected');
  end;
end;

{ EXT:                                                                         }
{ <exec statement> ::=                                                         }
{       <execute statement>                                                    }
{     | <embedded SQL statement>                                               }
function TSqlParser.ParseExecStatement: ASqlStatement;
begin
  Assert(FTokenType = ttEXEC);
  if GetNextToken = ttSQL then
    Result := ParseEmbeddedSqlStatementForm1
  else
    Result := ParseExecuteStatementSub;
end;

{ EXT:                                                                         }
{ <statement> ::= #                                                            }
function TSqlParser.ParseStatement: ASqlStatement;
begin
  Result := nil;
  case FTokenType of
    ttEof               : ;
    ttCREATE            : Result := ParseCreateStatement;
    ttDROP              : Result := ParseDropStatement;
    ttSELECT            : Result := ParseSelectStatement;
    ttUPDATE,
    ttINSERT,
    ttDELETE            : Result := ParseDirectSqlDataStatement;
    ttCOMMIT,
    ttROLLBACK          : Result := ParseSqlTransactionStatement;
    ttCONNECT,
    ttDISCONNECT        : Result := ParseSqlConnectionStatement;
    ttSET               : Result := ParseSetStatement;
    ttEXEC              : Result := ParseExecStatement;
    ttEXECUTE           : Result := ParseExecuteStatement;
    ttIF                : Result := ParseMsSqlIfStatement;
    ttBEGIN             : Result := ParseStatementBlock;
    ttWHILE             : Result := ParseWhileStatement;
    ttDECLARE           : Result := ParseDeclareStatement;
    ttALTER             : Result := ParseAlterStatement;
    ttOPEN              : Result := ParseOpenStatement;
    ttCLOSE             : Result := ParseCloseStatement;
    ttFETCH             : Result := ParseFetchStatementExt(sftUndefined);
    ttGRANT             : Result := ParseGrantStatement;
    ttREVOKE            : Result := ParseRevokeStatement;
    ttWHENEVER          : Result := ParseEmbeddedExceptionDeclaration;
    ttDESCRIBE          : Result := ParseDescribeStatement;
    ttPREPARE           : Result := ParsePrepareStatement;
    ttALLOCATE          : Result := ParseAllocateStatement;
    ttDEALLOCATE        : Result := ParseDeallocateStatement;
    ttUSE               : Result := ParseUseStatement;
    ttEmbeddedSqlPrefix : Result := ParseEmbeddedSqlStatementForm2;
  else
    UnexpectedToken;
  end;
end;

{ EXT:                                                                         }
{ <SQL> ::=                                                                    }
{     ( <statement> [ GO | <semicolon> ] )...                                  }
function TSqlParser.ParseSql(const Sql: AnsiString): ASqlStatement;
var R, T : ASqlStatement;
    L    : TSqlStatementSequence;
    F    : Boolean;
    E    : THPTimer;
begin
  StartTimer(E);
  R := nil;
  L := nil;
  FLineNr := 1;
  FLexer.SetText(Sql);
  if spoExtendedSyntax in FOptions then
    FLexer.Options := [sloAllowLineComment, sloAllowBlockComment, sloExtendedSyntax]
  else
    FLexer.Options := [];
  GetNextToken;
  F := False;
  try
    repeat
      case FTokenType of
        ttEof        : F := True;
        ttSemicolon,
        ttGO         : GetNextToken;
      else
        begin
          T := ParseStatement;
          Assert(Assigned(T));
          if Assigned(L) then
            L.Add(T) else
          if Assigned(R) then
            begin
              L := TSqlStatementSequence.Create;
              L.Add(R);
              R := L;
              L.Add(T);
            end
          else
            R := T;
        end;
      end;
    until F;
  except
    R.Free;
    raise;
  end;
  FParseTime := MicrosecondsElapsed(E, True);
  Result := R;
end;

function TSqlParser.ParseSqlProcedureDefinition(const Sql: AnsiString): TSqlProcedureDefinition;
var S : ASqlStatement;
begin
  S := ParseSql(Sql);
  if not (S is TSqlCreateProcedureStatement) then
    ParseError('Not a procedure declaration');
  Result := TSqlCreateProcedureStatement(S).ReleaseDefinition;
  S.Free;
end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF SQL_SELFTEST}
{$ASSERTIONS ON}
procedure TestSql_SqlStr(const Sql: AnsiString);
var P : TSqlParser;
    S : ASqlStatement;
begin
  P := TSqlParser.Create;
  try
    S := P.ParseSql(Sql);
    try
      Assert(S.GetAsSql = Sql);
    finally
      S.Free;
    end;
  finally
    P.Free;
  end;
end;

procedure SelfTest;
begin
  TestSql_SqlStr('SELECT * FROM ABC');
  TestSql_SqlStr('SELECT (1 + 1)');
end;
{$ENDIF}



end.

