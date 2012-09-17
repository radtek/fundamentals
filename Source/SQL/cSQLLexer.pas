{******************************************************************************}
(*                                                                            *)
(*    Library:       Fundamentals SQL                                         *)
(*    Description:   SQL lexical parser.                                      *)
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
(*    2005/03/31  1.01  String literals.                                      *)
(*    2005/04/02  1.02  Comments.                                             *)
(*    2009/11/27  1.03  SQL99 development.                                    *)
(*    2011/07/17  1.04  Test cases.                                           *)
{     2011/10/19  1.05  Minor changes.                                        *)
(*                                                                            *)
(*  Features:                                                                 *)
(*    * Fast parsing.                                                         *)
(*                                                                            *)
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLLexer;

interface

uses
  { Fundamentals }
  cStreams,

  { SQL }
  cSQLUtils,
  cSQLDataTypes;



{                                                                              }
{ SQL characters                                                               }
{                                                                              }
const
  SQL_CHAR_Space             = [' '];
  SQL_CHAR_WhiteSpace        = [#0..#9, #11..#12, #14..#31] +
                               SQL_CHAR_Space;
  SQL_CHAR_NewLine           = [#10, #13];
  SQL_CHAR_NonNewLine        = [#0..#255] - SQL_CHAR_NewLine;
  SQL_CHAR_SimpleLatinLetter = ['A'..'Z', 'a'..'z'];
  SQL_CHAR_Digit             = ['0'..'9'];
  SQL_CHAR_HexDigit          = SQL_CHAR_Digit +
                               ['A'..'F', 'a'..'F'];
  SQL_CHAR_Special           = [' ', '"', '%', '&', '''', '(', ')', '*', '+',
                                ',', '-', '.', '/', ':', ';', '<', '=', '>',
                                '?', '_', '|'];
  SQL_CHAR_IdentifierStart   = SQL_CHAR_SimpleLatinLetter + ['_'];
  SQL_CHAR_Identifier        = SQL_CHAR_IdentifierStart +
                               SQL_CHAR_Digit;
  SQL_CHAR_IdentifierExt     = SQL_CHAR_Identifier + ['@'];
  SQL_CHAR_EmbeddedLanguage  = ['[', ']'];
  SQL_CHAR_Language          = SQL_CHAR_SimpleLatinLetter +
                               SQL_CHAR_Digit +
                               SQL_CHAR_Special;
  SQL_CHAR_Terminal          = SQL_CHAR_Language +
                               SQL_CHAR_EmbeddedLanguage;
  SQL_CHAR_NonQuote          = [#0..#255] - [''''];

  SQL_STR_Quote              = '''';
  SQL_STR_QuoteSequence      = SQL_STR_QUOTE + SQL_STR_QUOTE;



{                                                                              }
{ SQL keywords                                                                 }
{                                                                              }
const
  // Statements
  SQL_KEYWORD_CONNECT           = 'CONNECT';
  SQL_KEYWORD_DISCONNECT        = 'DISCONNECT';
  SQL_KEYWORD_CREATE            = 'CREATE';
  SQL_KEYWORD_DROP              = 'DROP';
  SQL_KEYWORD_ALTER             = 'ALTER';
  SQL_KEYWORD_INSERT            = 'INSERT';
  SQL_KEYWORD_DELETE            = 'DELETE';
  SQL_KEYWORD_UPDATE            = 'UPDATE';
  SQL_KEYWORD_SELECT            = 'SELECT';
  SQL_KEYWORD_COMMIT            = 'COMMIT';
  SQL_KEYWORD_ROLLBACK          = 'ROLLBACK';
  SQL_KEYWORD_PROCEDURE         = 'PROCEDURE';
  SQL_KEYWORD_EXECUTE           = 'EXECUTE';
  SQL_KEYWORD_EXEC              = 'EXEC';
  SQL_KEYWORD_DECLARE           = 'DECLARE';
  SQL_KEYWORD_PREPARE           = 'PREPARE';
  SQL_KEYWORD_GO                = 'GO';
  SQL_KEYWORD_SQL               = 'SQL';

  //
  SQL_KEYWORD_ALLOCATE          = 'ALLOCATE';
  SQL_KEYWORD_INSENSITIVE       = 'INSENSITIVE';
  SQL_KEYWORD_SCROLL            = 'SCROLL';
  SQL_KEYWORD_CURSOR            = 'CURSOR';
  SQL_KEYWORD_OPEN              = 'OPEN';
  SQL_KEYWORD_FETCH             = 'FETCH';
  SQL_KEYWORD_NEXT              = 'NEXT';
  SQL_KEYWORD_PRIOR             = 'PRIOR';
  SQL_KEYWORD_FIRST             = 'FIRST';
  SQL_KEYWORD_LAST              = 'LAST';
  SQL_KEYWORD_ABSOLUTE          = 'ABSOLUTE';
  SQL_KEYWORD_RELATIVE          = 'RELATIVE';
  SQL_KEYWORD_CLOSE             = 'CLOSE';
  SQL_KEYWORD_OF                = 'OF';

  // Statements
  SQL_KEYWORD_FROM              = 'FROM';
  SQL_KEYWORD_TO                = 'TO';
  SQL_KEYWORD_BY                = 'BY';
  SQL_KEYWORD_AS                = 'AS';
  SQL_KEYWORD_FOR               = 'FOR';
  SQL_KEYWORD_INTO              = 'INTO';
  SQL_KEYWORD_ALL               = 'ALL';
  SQL_KEYWORD_WHERE             = 'WHERE';
  SQL_KEYWORD_HAVING            = 'HAVING';
  SQL_KEYWORD_GROUP             = 'GROUP';
  SQL_KEYWORD_ORDER             = 'ORDER';
  SQL_KEYWORD_DISTINCT          = 'DISTINCT';
  SQL_KEYWORD_UNIQUE            = 'UNIQUE';
  SQL_KEYWORD_VALUES            = 'VALUES';
  SQL_KEYWORD_DEFAULT           = 'DEFAULT';
  SQL_KEYWORD_DESC              = 'DESC';
  SQL_KEYWORD_ASC               = 'ASC';
  SQL_KEYWORD_SET               = 'SET';
  SQL_KEYWORD_UNION             = 'UNION';
  SQL_KEYWORD_JOIN              = 'JOIN';
  SQL_KEYWORD_LEFT              = 'LEFT';
  SQL_KEYWORD_RIGHT             = 'RIGHT';
  SQL_KEYWORD_INNER             = 'INNER';
  SQL_KEYWORD_OUTER             = 'OUTER';
  SQL_KEYWORD_TABLE             = 'TABLE';
  SQL_KEYWORD_VIEW              = 'VIEW';
  SQL_KEYWORD_COLUMN            = 'COLUMN';
  SQL_KEYWORD_CONSTRAINT        = 'CONSTRAINT';
  SQL_KEYWORD_USER              = 'USER';
  SQL_KEYWORD_PRIMARY           = 'PRIMARY';
  SQL_KEYWORD_KEY               = 'KEY';
  SQL_KEYWORD_VARYING           = 'VARYING';
  SQL_KEYWORD_GLOBAL            = 'GLOBAL';
  SQL_KEYWORD_LOCAL             = 'LOCAL';
  SQL_KEYWORD_TEMPORARY         = 'TEMPORARY';
  SQL_KEYWORD_CASCADE           = 'CASCADE';
  SQL_KEYWORD_RESTRICT          = 'RESTRICT';
  SQL_KEYWORD_LEADING           = 'LEADING';
  SQL_KEYWORD_TRAILING          = 'TRAILING';
  SQL_KEYWORD_BOTH              = 'BOTH';
  SQL_KEYWORD_CROSS             = 'CROSS';
  SQL_KEYWORD_NATURAL           = 'NATURAL';
  SQL_KEYWORD_FULL              = 'FULL';
  SQL_KEYWORD_ON                = 'ON';
  SQL_KEYWORD_USING             = 'USING';
  SQL_KEYWORD_COLLATE           = 'COLLATE';
  SQL_KEYWORD_REFERENCES        = 'REFERENCES';
  SQL_KEYWORD_CHECK             = 'CHECK';

  // Data Types
  SQL_KEYWORD_CHARACTER         = 'CHARACTER';
  SQL_KEYWORD_CHAR              = 'CHAR';
  SQL_KEYWORD_VARCHAR           = 'VARCHAR';
  SQL_KEYWORD_NCHAR             = 'NCHAR';
  SQL_KEYWORD_TEXT              = 'TEXT';
  SQL_KEYWORD_NUMERIC           = 'NUMERIC';
  SQL_KEYWORD_DECIMAL           = 'DECIMAL';
  SQL_KEYWORD_DEC               = 'DEC';
  SQL_KEYWORD_INTEGER           = 'INTEGER';
  SQL_KEYWORD_INT               = 'INT';
  SQL_KEYWORD_SMALLINT          = 'SMALLINT';
  SQL_KEYWORD_FLOAT             = 'FLOAT';
  SQL_KEYWORD_REAL              = 'REAL';
  SQL_KEYWORD_DOUBLE            = 'DOUBLE';
  SQL_KEYWORD_PRECISION         = 'PRECISION';
  SQL_KEYWORD_DATE              = 'DATE';
  SQL_KEYWORD_TIME              = 'TIME';
  SQL_KEYWORD_TIMESTAMP         = 'TIMESTAMP';
  SQL_KEYWORD_WITH              = 'WITH';
  SQL_KEYWORD_ZONE              = 'ZONE';
  SQL_KEYWORD_INTERVAL          = 'INTERVAL';
  SQL_KEYWORD_NATIONAL          = 'NATIONAL';
  SQL_KEYWORD_BIGINT            = 'BIGINT';

  // Expressions
  SQL_KEYWORD_NULL              = 'NULL';
  SQL_KEYWORD_AND               = 'AND';
  SQL_KEYWORD_OR                = 'OR';
  SQL_KEYWORD_NOT               = 'NOT';
  SQL_KEYWORD_IN                = 'IN';
  SQL_KEYWORD_LIKE              = 'LIKE';
  SQL_KEYWORD_IS                = 'IS';
  SQL_KEYWORD_EXISTS            = 'EXISTS';
  SQL_KEYWORD_BETWEEN           = 'BETWEEN';
  SQL_KEYWORD_WHEN              = 'WHEN';
  SQL_KEYWORD_THEN              = 'THEN';
  SQL_KEYWORD_ELSE              = 'ELSE';
  SQL_KEYWORD_CASE              = 'CASE';
  SQL_KEYWORD_END               = 'END';
  SQL_KEYWORD_CAST              = 'CAST';
  SQL_KEYWORD_CONVERT           = 'CONVERT';
  SQL_KEYWORD_NULLIF            = 'NULLIF';
  SQL_KEYWORD_SUBSTRING         = 'SUBSTRING';
  SQL_KEYWORD_UPPER             = 'UPPER';
  SQL_KEYWORD_LOWER             = 'LOWER';
  SQL_KEYWORD_TRIM              = 'TRIM';
  SQL_KEYWORD_TRUE              = 'TRUE';
  SQL_KEYWORD_FALSE             = 'FALSE';
  SQL_KEYWORD_POSITION          = 'POSITION';
  SQL_KEYWORD_MODULE            = 'MODULE';
  SQL_KEYWORD_MATCH             = 'MATCH';
  SQL_KEYWORD_OVERLAPS          = 'OVERLAPS';
  SQL_KEYWORD_PARTIAL           = 'PARTIAL';
  SQL_KEYWORD_ESCAPE            = 'ESCAPE';
  SQL_KEYWORD_VALUE             = 'VALUE';
  SQL_KEYWORD_INDICATOR         = 'INDICATOR';
  SQL_KEYWORD_SECOND            = 'SECOND';
  SQL_KEYWORD_MINUTE            = 'MINUTE';
  SQL_KEYWORD_HOUR              = 'HOUR';
  SQL_KEYWORD_DAY               = 'DAY';
  SQL_KEYWORD_MONTH             = 'MONTH';
  SQL_KEYWORD_YEAR              = 'YEAR';
  SQL_KEYWORD_AT                = 'AT';
  SQL_KEYWORD_SOME              = 'SOME';
  SQL_KEYWORD_ANY               = 'ANY';
  SQL_KEYWORD_INTERSECT         = 'INTERSECT';
  SQL_KEYWORD_EXCEPT            = 'EXCEPT';
  SQL_KEYWORD_PRESERVE          = 'PRESERVE';
  SQL_KEYWORD_ROWS              = 'ROWS';
  SQL_KEYWORD_TRANSACTION       = 'TRANSACTION';
  SQL_KEYWORD_READ              = 'READ';
  SQL_KEYWORD_WRITE             = 'WRITE';
  SQL_KEYWORD_ONLY              = 'ONLY';
  SQL_KEYWORD_IF                = 'IF';     // Ext
  SQL_KEYWORD_BEGIN             = 'BEGIN';  // Ext
  SQL_KEYWORD_WHILE             = 'WHILE';  // Ext
  SQL_KEYWORD_NO                = 'NO';
  SQL_KEYWORD_CHAR_LENGTH       = 'CHAR_LENGTH';
  SQL_KEYWORD_CHARACTER_LENGTH  = 'CHARACTER_LENGTH';
  SQL_KEYWORD_BREAK             = 'BREAK';
  SQL_KEYWORD_CONTINUE          = 'CONTINUE';
  SQL_KEYWORD_PROC              = 'PROC';   // Ext
  SQL_KEYWORD_RECOMPILE         = 'RECOMPILE';
  SQL_KEYWORD_OUTPUT            = 'OUTPUT';
  SQL_KEYWORD_INDEX             = 'INDEX';  // Ext
  SQL_KEYWORD_ISNULL            = 'ISNULL'; // Ext
  SQL_KEYWORD_INITIALLY         = 'INITIALLY';
  SQL_KEYWORD_DEFERRED          = 'DEFERRED';
  SQL_KEYWORD_IMMEDIATE         = 'IMMEDIATE';
  SQL_KEYWORD_DEFERRABLE        = 'DEFERRABLE';
  SQL_KEYWORD_ACTION            = 'ACTION';
  SQL_KEYWORD_FOREIGN           = 'FOREIGN';
  SQL_KEYWORD_COALESCE          = 'COALESCE';

  // Set Functions
  SQL_KEYWORD_AVG               = 'AVG';
  SQL_KEYWORD_MAX               = 'MAX';
  SQL_KEYWORD_MIN               = 'MIN';
  SQL_KEYWORD_SUM               = 'SUM';
  SQL_KEYWORD_COUNT             = 'COUNT';

  // Expressions
  SQL_KEYWORD_CURRENT_DATE      = 'CURRENT_DATE';
  SQL_KEYWORD_CURRENT_TIME      = 'CURRENT_TIME';
  SQL_KEYWORD_CURRENT_TIMESTAMP = 'CURRENT_TIMESTAMP';
  SQL_KEYWORD_CURRENT_USER      = 'CURRENT_USER';
  SQL_KEYWORD_SESSION_USER      = 'SESSION_USER';
  SQL_KEYWORD_SYSTEM_USER       = 'SYSTEM_USER';

  //
  SQL_KEYWORD_DOMAIN            = 'DOMAIN';
  SQL_KEYWORD_GRANT             = 'GRANT';
  SQL_KEYWORD_PRIVILEGES        = 'PRIVILEGES';
  SQL_KEYWORD_OPTION            = 'OPTION';
  SQL_KEYWORD_PUBLIC            = 'PUBLIC';
  SQL_KEYWORD_COLLATION         = 'COLLATION';
  SQL_KEYWORD_TRANSLATION       = 'TRANSLATION';
  SQL_KEYWORD_USAGE             = 'USAGE';
  SQL_KEYWORD_CASCADED          = 'CASCADED';
  SQL_KEYWORD_GET               = 'GET';
  SQL_KEYWORD_ASSERTION         = 'ASSERTION';
  SQL_KEYWORD_DEALLOCATE        = 'DEALLOCATE';
  SQL_KEYWORD_DESCRIBE          = 'DESCRIBE';
  SQL_KEYWORD_REVOKE            = 'REVOKE';
  SQL_KEYWORD_INPUT             = 'INPUT';
  SQL_KEYWORD_WHENEVER          = 'WHENEVER';
  SQL_KEYWORD_SQLERROR          = 'SQLERROR';
  SQL_KEYWORD_FOUND             = 'FOUND';
  SQL_KEYWORD_GOTO              = 'GOTO';
  SQL_KEYWORD_PAD               = 'PAD';
  SQL_KEYWORD_SPACE             = 'SPACE';
  SQL_KEYWORD_CONSTRAINTS       = 'CONSTRAINTS';
  SQL_KEYWORD_CATALOG           = 'CATALOG';
  SQL_KEYWORD_SCHEMA            = 'SCHEMA';
  SQL_KEYWORD_NAMES             = 'NAMES';
  SQL_KEYWORD_AUTHORIZATION     = 'AUTHORIZATION';
  SQL_KEYWORD_SESSION           = 'SESSION';
  SQL_KEYWORD_DESCRIPTOR        = 'DESCRIPTOR';
  SQL_KEYWORD_ADD               = 'ADD';
  SQL_KEYWORD_ISOLATION         = 'ISOLATION';
  SQL_KEYWORD_LEVEL             = 'LEVEL';
  SQL_KEYWORD_REPEATABLE        = 'REPEATABLE';
  SQL_KEYWORD_SERIALIZABLE      = 'SERIALIZABLE';
  SQL_KEYWORD_UNCOMMITTED       = 'UNCOMMITTED';
  SQL_KEYWORD_COMMITTED         = 'COMMITTED';
  SQL_KEYWORD_DIAGNOSTICS       = 'DIAGNOSTICS';
  SQL_KEYWORD_SIZE              = 'SIZE';
  SQL_KEYWORD_CONNECTION        = 'CONNECTION';
  SQL_KEYWORD_ENDEXEC           = 'END-EXEC';
  SQL_KEYWORD_EXCEPTION         = 'EXCEPTION';
  SQL_KEYWORD_CURRENT           = 'CURRENT';
  SQL_KEYWORD_IDENTITY          = 'IDENTITY';
  SQL_KEYWORD_EXTERNAL          = 'EXTERNAL';
  SQL_KEYWORD_WORK              = 'WORK';
  SQL_KEYWORD_CORRESPONDING     = 'CORRESPONDING';
  SQL_KEYWORD_UNKNOWN           = 'UNKNOWN';
  SQL_KEYWORD_TRANSLATE         = 'TRANSLATE';
  SQL_KEYWORD_EXTRACT           = 'EXTRACT';
  SQL_KEYWORD_OCTET_LENGTH      = 'OCTET_LENGTH';
  SQL_KEYWORD_BIT_LENGTH        = 'BUT_LENGTH';
  SQL_KEYWORD_TIMEZONE_HOUR     = 'TIMEZONE_HOUR';
  SQL_KEYWORD_TIMEZONE_MINUTE   = 'TIMEZONE_MINUTE';

  // new (mostly SQL99)
  SQL_KEYWORD_ROLE              = 'ROLE';
  SQL_KEYWORD_ADMIN             = 'ADMIN';
  SQL_KEYWORD_TYPE              = 'TYPE';
  SQL_KEYWORD_STATIC            = 'STATIC';
  SQL_KEYWORD_DISPATCH          = 'DISPATCH';
  SQL_KEYWORD_RETURNS           = 'RETURNS';
  SQL_KEYWORD_LOCATOR           = 'LOCATOR';
  SQL_KEYWORD_NAME              = 'NAME';
  SQL_KEYWORD_OUT               = 'OUT';
  SQL_KEYWORD_INOUT             = 'INOUT';
  SQL_KEYWORD_RESULT            = 'RESULT';
  SQL_KEYWORD_ELSEIF            = 'ELSEIF';
  SQL_KEYWORD_CALL              = 'CALL';
  SQL_KEYWORD_RETURN            = 'RETURN';
  SQL_KEYWORD_DO                = 'DO';
  SQL_KEYWORD_REPEAT            = 'REPEAT';
  SQL_KEYWORD_UNTIL             = 'UNTIL';
  SQL_KEYWORD_ATOMIC            = 'ATOMIC';
  SQL_KEYWORD_CONDITION         = 'CONDITION';
  SQL_KEYWORD_SQLSTATE          = 'SQLSTATE';
  SQL_KEYWORD_EXIT              = 'EXIT';
  SQL_KEYWORD_UNDO              = 'UNDO';
  SQL_KEYWORD_SQLEXCEPTION      = 'SQLEXCEPTION';
  SQL_KEYWORD_SQLWARNING        = 'SQLWARNING';
  SQL_KEYWORD_HANDLER           = 'HANDLER';
  SQL_KEYWORD_SENSITIVE         = 'SENSITIVE';
  SQL_KEYWORD_ASENSITIVE        = 'ASENSITIVE';
  SQL_KEYWORD_LOOP              = 'LOOP';
  SQL_KEYWORD_ITERATE           = 'ITERATE';
  SQL_KEYWORD_LEAVE             = 'LEAVE';
  SQL_KEYWORD_CHAIN             = 'CHAIN';
  SQL_KEYWORD_FUNCTION          = 'FUNCTION';
  SQL_KEYWORD_METHOD            = 'METHOD';
  SQL_KEYWORD_INSTANCE          = 'INSTANCE';
  SQL_KEYWORD_CONSTRUCTOR       = 'CONSTRUCTOR';
  SQL_KEYWORD_TRIGGER           = 'TRIGGER';
  SQL_KEYWORD_EACH              = 'EACH';
  SQL_KEYWORD_ROW               = 'ROW';
  SQL_KEYWORD_STATEMENT         = 'STATEMENT';
  SQL_KEYWORD_CARDINALITY       = 'CARDINALITY';
  SQL_KEYWORD_ABS               = 'ABS';
  SQL_KEYWORD_MOD               = 'MOD';
  SQL_KEYWORD_ARRAY             = 'ARRAY';
  SQL_KEYWORD_SIMPLE            = 'SIMPLE';
  SQL_KEYWORD_EVERY             = 'EVERY';
  SQL_KEYWORD_GROUPING          = 'GROUPING';
  SQL_KEYWORD_SAVEPOINT         = 'SAVEPOINT';
  SQL_KEYWORD_ARE               = 'ARE';
  SQL_KEYWORD_CHECKED           = 'CHECKED';

  // SQL2003
  SQL_KEYWORD_BEFORE            = 'BEFORE';
  SQL_KEYWORD_AFTER             = 'AFTER';
  SQL_KEYWORD_MERGE             = 'MERGE';
  SQL_KEYWORD_MATCHED           = 'MATCHED';
  SQL_KEYWORD_GENERATED         = 'GENERATED';
  SQL_KEYWORD_ALWAYS            = 'ALWAYS';
  SQL_KEYWORD_START             = 'START';
  SQL_KEYWORD_INCREMENT         = 'INCREMENT';
  SQL_KEYWORD_MAXVALUE          = 'MAXVALUE';
  SQL_KEYWORD_MINVALUE          = 'MINVALUE';
  SQL_KEYWORD_CYCLE             = 'CYCLE';
  SQL_KEYWORD_LN                = 'LN';
  SQL_KEYWORD_EXP               = 'EXP';
  SQL_KEYWORD_SQRT              = 'SQRT';
  SQL_KEYWORD_FLOOR             = 'FLOOR';
  SQL_KEYWORD_CEIL              = 'CEIL';
  SQL_KEYWORD_CEILING           = 'CEILING';
  SQL_KEYWORD_WIDTH_BUCKET      = 'WIDTH_BUCKET';
  SQL_KEYWORD_NORMALIZE         = 'NORMALIZE';
  SQL_KEYWORD_WINDOW            = 'WINDOW';
  SQL_KEYWORD_ATTRIBUTES        = 'ATTRIBUTES';
  SQL_KEYWORD_MULTISET          = 'MULTISET';
  SQL_KEYWORD_WITHIN            = 'WITHIN';
  SQL_KEYWORD_PARTITION         = 'PARTITION';
  SQL_KEYWORD_RANGE             = 'RANGE';
  SQL_KEYWORD_CUBE              = 'CUBE';
  SQL_KEYWORD_ROLLUP            = 'ROLLUP';
  SQL_KEYWORD_STDDEV_POP        = 'STDDEV_POP';
  SQL_KEYWORD_STDDEV_SAMP       = 'STDDEV_SAMP';
  SQL_KEYWORD_VAR_SAMP          = 'VAR_SAMP';
  SQL_KEYWORD_VAR_POP           = 'VAR_POP';
  SQL_KEYWORD_COLLECT           = 'COLLECT';
  SQL_KEYWORD_FUSION            = 'FUSION';
  SQL_KEYWORD_INTERSECTION      = 'INTERSECTION';

  // EXT
  SQL_KEYWORD_DATABASE          = 'DATABASE';
  SQL_KEYWORD_FILENAME          = 'FILENAME';
  SQL_KEYWORD_MAXSIZE           = 'MAXSIZE';
  SQL_KEYWORD_USE               = 'USE';
  SQL_KEYWORD_LOGIN             = 'LOGIN';
  SQL_KEYWORD_PASSWORD          = 'PASSWORD';



{                                                                              }
{ SQL tokens                                                                   }
{                                                                              }
const
  // Special tokens
  ttNone              = $00;
  ttEof               = $01;
  ttInvalidChar       = $02;
  ttWhiteSpace        = $03;
  ttNewLine           = $04;
  ttIdentifier        = $05;
  ttUnsignedInteger   = $06;
  ttRealNumber        = $07;
  ttStringLiteral     = $08;
  ttQuotedIdentifier  = $09;
  ttSciRealNumber     = $0A;
  ttNStringLiteral    = $0B;
  ttHexStringLiteral  = $0C;
  ttBitStringLiteral  = $0D;
  ttLineComment       = $0E;
  ttBlockComment      = $0F;
  ttLocalIdentifier   = $10;
  ttEmbeddedSqlPrefix = $11;

  // Symbols
  ttLeftParen         = $20;
  ttRightParen        = $21;
  ttPlus              = $22;
  ttMinus             = $23;
  ttAsterisk          = $24;
  ttSolidus           = $25;
  ttPower             = $26;
  ttLess              = $27;
  ttGreater           = $28;
  ttLessOrEqual       = $29;
  ttGreaterOrEqual    = $2A;
  ttEqual             = $2B;
  ttNotEqual          = $2C;
  ttComma             = $2D;
  ttPercent           = $2E;
  ttAmpersand         = $2F;
  ttPeriod            = $30;
  ttDoublePeriod      = $31;
  ttColon             = $32;
  ttSemicolon         = $33;
  ttQuestionMark      = $34;
  ttVerticalBar       = $35;
  ttConcatenation     = $36;
  ttLeftBracket       = $37;
  ttRightBracket      = $38;

  // Keywords
  tt__FirstKeyword    = $40;

  // Reserved keywords
  tt__FirstReserved   = $40;

  ttGO                = $40;
  ttINTO              = $41;
  ttNULL              = $42;
  ttAND               = $43;
  ttOR                = $44;
  ttNOT               = $45;
  ttTRUE              = $46;
  ttFALSE             = $47;
  ttBEGIN             = $48;
  ttEND               = $49;

  tt__LastReserved    = $5F;

  ttALL               = $60;
  ttSOME              = $61;
  ttANY               = $62;
  ttUNION             = $63;
  ttIN                = $64;
  ttLIKE              = $65;
  ttIS                = $66;
  ttEXISTS            = $67;
  ttBETWEEN           = $68;
  ttWHEN              = $69;
  ttTHEN              = $6A;
  ttELSE              = $6B;
  ttCASE              = $6C;
  ttUnused013         = $6D;
  ttCAST              = $6E;
  ttCONVERT           = $6F;
  ttNULLIF            = $70;
  ttSUBSTRING         = $71;
  ttUPPER             = $72;
  ttLOWER             = $73;
  ttTRIM              = $74;
  ttUnused009         = $75;
  ttUnused010         = $76;
  ttPOSITION          = $77;
  ttMODULE            = $78;
  ttMATCH             = $79;
  ttOVERLAPS          = $7A;
  ttPARTIAL           = $7B;
  ttESCAPE            = $7C;
  ttVALUE             = $7D;
  ttINDICATOR         = $7E;
  ttEXCEPT            = $7F;

  ttCONNECT           = $80;
  ttDISCONNECT        = $81;
  ttCREATE            = $82;
  ttDROP              = $83;
  ttALTER             = $84;
  ttINSERT            = $85;
  ttDELETE            = $86;
  ttUPDATE            = $87;
  ttSELECT            = $88;
  ttCOMMIT            = $89;
  ttROLLBACK          = $8A;
  ttPROCEDURE         = $8B;
  ttEXECUTE           = $8C;
  ttEXEC              = $8D;
  ttDECLARE           = $8E;
  ttPREPARE           = $8F;
  ttUnused001         = $90;
  ttSQL               = $91;
  ttALLOCATE          = $92;
  ttINSENSITIVE       = $93;
  ttSCROLL            = $94;
  ttCURSOR            = $95;
  ttOPEN              = $96;
  ttFETCH             = $97;
  ttNEXT              = $98;
  ttPRIOR             = $99;
  ttFIRST             = $9A;
  ttLAST              = $9B;
  ttABSOLUTE          = $9C;
  ttRELATIVE          = $9D;
  ttCLOSE             = $9E;
  ttOF                = $9F;

  ttFROM              = $A0;
  ttTO                = $A1;
  ttBY                = $A2;
  ttAS                = $A3;
  ttFOR               = $A4;
  ttUnused002         = $A5;
  ttUnused003         = $A6;
  ttWHERE             = $A7;
  ttHAVING            = $A8;
  ttGROUP             = $A9;
  ttORDER             = $AA;
  ttDISTINCT          = $AB;
  ttUNIQUE            = $AC;
  ttVALUES            = $AD;
  ttDEFAULT           = $AE;
  ttDESC              = $AF;
  ttASC               = $B0;
  ttSET               = $B1;
  ttUnused011         = $B2;
  ttJOIN              = $B3;
  ttLEFT              = $B4;
  ttRIGHT             = $B5;
  ttINNER             = $B6;
  ttOUTER             = $B7;
  ttTABLE             = $B8;
  ttVIEW              = $B9;
  ttCOLUMN            = $BA;
  ttCONSTRAINT        = $BB;
  ttUSER              = $BC;
  ttPRIMARY           = $BD;
  ttKEY               = $BE;
  ttVARYING           = $BF;
  ttGLOBAL            = $C0;
  ttLOCAL             = $C1;
  ttTEMPORARY         = $C2;
  ttCASCADE           = $C3;
  ttRESTRICT          = $C4;
  ttLEADING           = $C5;
  ttTRAILING          = $C6;
  ttBOTH              = $C7;
  ttCROSS             = $C8;
  ttNATURAL           = $C9;
  ttFULL              = $CA;
  ttON                = $CB;
  ttUSING             = $CC;
  ttCOLLATE           = $CD;
  ttREFERENCES        = $CE;
  ttCHECK             = $CF;

  ttCHARACTER         = $D0;
  ttCHAR              = $D1;
  ttVARCHAR           = $D2;
  ttNCHAR             = $D3;
  ttTEXT              = $D4;
  ttNUMERIC           = $D5;
  ttDECIMAL           = $D6;
  ttDEC               = $D7;
  ttINTEGER           = $D8;
  ttINT               = $D9;
  ttSMALLINT          = $DA;
  ttFLOAT             = $DB;
  ttREAL              = $DC;
  ttDOUBLE            = $DD;
  ttPRECISION         = $DE;
  ttDATE              = $DF;
  ttTIME              = $E0;
  ttTIMESTAMP         = $E1;
  ttWITH              = $E2;
  ttZONE              = $E3;
  ttINTERVAL          = $E4;
  ttNATIONAL          = $E5;
  ttBIGINT            = $E6;

  ttPROC              = $F0;
  ttIMMEDIATE         = $F1;
  ttDEFERRABLE        = $F2;

  //
  ttSECOND            = $1CF;
  ttMINUTE            = $1D0;
  ttHOUR              = $1D1;
  ttDAY               = $1D2;
  ttMONTH             = $1D3;
  ttYEAR              = $1D4;
  ttAT                = $1D5;
  ttUnused004         = $1D6;
  ttUnused005         = $1D7;
  ttINTERSECT         = $1D8;
  ttUnused006         = $1D9;
  ttPRESERVE          = $1DA;
  ttROWS              = $1DB;
  ttTRANSACTION       = $1DC;
  ttREAD              = $1DD;
  ttWRITE             = $1DE;
  ttONLY              = $1DF;
  ttIF                = $1E0;
  ttUnused012         = $1E1;
  ttWHILE             = $1E2;
  ttNO                = $1E3;
  ttCHAR_LENGTH       = $1E4;
  ttCHARACTER_LENGTH  = $1E5;
  ttBREAK             = $1E6;
  ttCONTINUE          = $1E7;
  ttRECOMPILE         = $1E9;
  ttOUTPUT            = $1EA;
  ttINDEX             = $1EB;
  ttISNULL            = $1EC;
  ttINITIALLY         = $1ED;
  ttDEFERRED          = $1EE;
  ttUnused007         = $1EF;
  ttUnused008         = $1F0;
  ttACTION            = $1F1;
  ttFOREIGN           = $1F2;
  ttCOALESCE          = $1F3;

  // Set functions
  ttAVG               = $1F4;
  ttMAX               = $1F5;
  ttMIN               = $1F6;
  ttSUM               = $1F7;
  ttCOUNT             = $1F8;

  // Special values
  ttCURRENT_DATE      = $1F9;
  ttCURRENT_TIME      = $1FA;
  ttCURRENT_TIMESTAMP = $1FB;
  ttCURRENT_USER      = $1FC;
  ttSESSION_USER      = $1FD;
  ttSYSTEM_USER       = $1FE;

  //
  ttDOMAIN            = $200;
  ttGRANT             = $201;
  ttPRIVILEGES        = $202;
  ttOPTION            = $203;
  ttPUBLIC            = $204;
  ttCOLLATION         = $205;
  ttTRANSLATION       = $206;
  ttUSAGE             = $207;
  ttCASCADED          = $208;
  ttGET               = $209;
  ttASSERTION         = $20A;
  ttDEALLOCATE        = $20B;
  ttDESCRIBE          = $20C;
  ttREVOKE            = $20D;
  ttINPUT             = $20E;
  ttWHENEVER          = $20F;
  ttSQLERROR          = $210;
  ttFOUND             = $211;
  ttGOTO              = $212;
  ttPAD               = $213;
  ttSPACE             = $214;
  ttCONSTRAINTS       = $215;
  ttCATALOG           = $216;
  ttSCHEMA            = $217;
  ttNAMES             = $218;
  ttAUTHORIZATION     = $219;
  ttSESSION           = $21A;
  ttDESCRIPTOR        = $21B;
  ttADD               = $21C;
  ttISOLATION         = $21D;
  ttLEVEL             = $21E;
  ttREPEATABLE        = $21F;
  ttSERIALIZABLE      = $220;
  ttUNCOMMITTED       = $221;
  ttCOMMITTED         = $222;
  ttDIAGNOSTICS       = $223;
  ttSIZE              = $224;
  ttCONNECTION        = $225;
  ttENDEXEC           = $226;
  ttEXCEPTION         = $227;
  ttCURRENT           = $228;
  ttIDENTITY          = $229;
  ttEXTERNAL          = $22A;
  ttWORK              = $22B;
  ttCORRESPONDING     = $22C;
  ttUNKNOWN           = $22D;
  ttTRANSLATE         = $22E;
  ttEXTRACT           = $22F;
  ttOCTET_LENGTH      = $230;
  ttBIT_LENGTH        = $231;
  ttTIMEZONE_HOUR     = $232;
  ttTIMEZONE_MINUTE   = $233;

  // new (SQL99 mostly, some SQL92)
  ttROLE              = $300;
  ttADMIN             = $301;
  ttTYPE              = $302;
  ttSTATIC            = $303;
  ttDISPATCH          = $304;
  ttRETURNS           = $305;
  ttLOCATOR           = $306;
  ttNAME              = $307;
  ttOUT               = $308;
  ttINOUT             = $309;
  ttRESULT            = $310;
  ttELSEIF            = $311;
  ttCALL              = $312;
  ttRETURN            = $313;
  ttDO                = $314;
  ttREPEAT            = $315;
  ttUNTIL             = $316;
  ttATOMIC            = $317;
  ttCONDITION         = $318;
  ttSQLSTATE          = $319;
  ttEXIT              = $320;
  ttUNDO              = $321;
  ttSQLEXCEPTION      = $322;
  ttSQLWARNING        = $323;
  ttHANDLER           = $324;
  ttSENSITIVE         = $325;
  ttASENSITIVE        = $326;
  ttLOOP              = $327;
  ttITERATE           = $328;
  ttLEAVE             = $329;
  ttCHAIN             = $330;
  ttFUNCTION          = $331;
  ttMETHOD            = $332;
  ttINSTANCE          = $333;
  ttCONSTRUCTOR       = $334;
  ttTRIGGER           = $335;
  ttEACH              = $336;
  ttROW               = $337;
  ttSTATEMENT         = $338;
  ttCARDINALITY       = $339;
  ttABS               = $340;
  ttMOD               = $341;
  ttARRAY             = $342;
  ttBEFORE            = $343;
  ttAFTER             = $344;
  ttSIMPLE            = $345;
  ttEVERY             = $346;
  ttGROUPING          = $347;
  ttSAVEPOINT         = $348;
  ttARE               = $349;
  ttCHECKED           = $34A;

  // SQL2003
  ttMERGE             = $400;
  ttMATCHED           = $401;
  ttGENERATED         = $402;
  ttALWAYS            = $403;
  ttSTART             = $404;
  ttINCREMENT         = $405;
  ttMAXVALUE          = $406;
  ttMINVALUE          = $407;
  ttCYCLE             = $408;
  ttLN                = $409;
  ttEXP               = $40A;
  ttSQRT              = $40B;
  ttFLOOR             = $40C;
  ttCEIL              = $40D;
  ttCEILING           = $40E;
  ttWIDTH_BUCKET      = $40F;
  ttNORMALIZE         = $410;
  ttWINDOW            = $411;
  ttATTRIBUTES        = $412;
  ttMULTISET          = $413;
  ttWITHIN            = $414;
  ttPARTITION         = $415;
  ttRANGE             = $416;
  ttCUBE              = $417;
  ttROLLUP            = $418;
  ttSTDDEV_POP        = $419;
  ttSTDDEV_SAMP       = $41A;
  ttVAR_SAMP          = $41B;
  ttVAR_POP           = $41C;
  ttCOLLECT           = $41D;
  ttFUSION            = $41E;
  ttINTERSECTION      = $41F;

  // EXT
  ttDATABASE          = $500;
  ttFILENAME          = $501;
  ttMAXSIZE           = $502;
  ttUSE               = $503;
  ttLOGIN             = $504;
  ttPASSWORD          = $505;

  tt__LastKeyword     = $FFF;

  

function  SqlIdentifierStrToToken(const Identifier: AnsiString): Integer;
function  SqlTokenName(const TokenType: Integer): AnsiString;
function  SqlTokenToDataType(const TokenType: Integer): TSqlDataType;
function  SqlTokenToComparisonOperator(const TokenType: Integer): TSqlComparisonOperator;
function  SqlTokenToNumericOperator(const TokenType: Integer): TSqlNumericOperator;
function  SqlTokenToSetFunction(const TokenType: Integer): TSqlSetFunctionType;
function  SqlTokenToSetQuantifier(const TokenType: Integer): TSqlSetQuantifier;



{                                                                              }
{ TSqlLexer                                                                    }
{   SQL Lexical Parser.                                                        }
{                                                                              }
type
  TSqlLexerOptions = Set of (
      sloAllowLineComment,    //  --  Comment until EOL
      sloAllowBlockComment,   //  /*  Comment block  */
      sloExtendedSyntax);     //  Extended syntax
  TSqlLexer = class
  protected
    FOptions   : TSqlLexerOptions;
    FReader    : TLongStringReader;
    FTokenType : Integer;
    FTokenStr  : AnsiString;

    function  GetTokenInt64: Int64;
    function  ParseIdentifierToken(const C: AnsiChar): Integer;
    function  ParseParameterIdentifierToken: Integer;
    function  ParseSimpleNumberToken: Integer;
    function  ParseNumberToken: Integer;
    function  ExtractQuotedString(const QuoteCh: AnsiChar): AnsiString;
    function  GetTokenID: AnsiString;

  public
    constructor Create;
    destructor Destroy; override;

    property  Options: TSqlLexerOptions read FOptions write FOptions;
    procedure SetText(const Text: AnsiString);
    function  GetNextToken: Integer;
    property  TokenType: Integer read FTokenType;
    property  TokenStr: AnsiString read FTokenStr;
    property  TokenInt64: Int64 read GetTokenInt64;
    function  TokenStrIs(const TokenStr: AnsiString): Boolean;
    function  TokenIsReservedKeyword: Boolean;
    function  TokenIsKeyword: Boolean;
    property  TokenID: AnsiString read GetTokenID;
    function  GetTokenIDSequence: AnsiString;
  end;
  ESqlLexer = class(ESqlError);



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF SQL_SELFTEST}
procedure SelfTest;
{$ENDIF}



implementation

uses
  { System }
  SysUtils,

  { Fundamentals }
  cUtils,
  cStrings;



{                                                                              }
{ SQL tokens                                                                   }
{                                                                              }
function SqlIdentifierStrToToken(const Identifier: AnsiString): Integer;
begin
  if Identifier = '' then
    Result := ttNone
  else
    begin
      Result := ttIdentifier;
      case UpCase(PAnsiChar(Pointer(Identifier))^) of
        'A' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ALL) then
                Result := ttALL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ALTER) then
                Result := ttALTER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_AND) then
                Result := ttAND else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_AS) then
                Result := ttAS else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ASC) then
                Result := ttASC else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_AVG) then
                Result := ttAVG else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_AT) then
                Result := ttAT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ANY) then
                Result := ttANY else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ACTION) then
                Result := ttACTION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ALLOCATE) then
                Result := ttALLOCATE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ABSOLUTE) then
                Result := ttABSOLUTE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ADD) then
                Result := ttADD else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_AUTHORIZATION) then
                Result := ttAUTHORIZATION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ASSERTION) then
                Result := ttASSERTION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ADMIN) then
                Result := ttADMIN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ATOMIC) then
                Result := ttATOMIC else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ASENSITIVE) then
                Result := ttASENSITIVE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ABS) then
                Result := ttABS else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ARRAY) then
                Result := ttARRAY else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_AFTER) then
                Result := ttAFTER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ALWAYS) then
                Result := ttALWAYS else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ATTRIBUTES) then
                Result := ttATTRIBUTES else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ARE) then
                Result := ttARE;
        'B' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_BETWEEN) then
                Result := ttBETWEEN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_BY) then
                Result := ttBY else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_BOTH) then
                Result := ttBOTH else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_BEGIN) then
                Result := ttBEGIN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_BREAK) then
                Result := ttBREAK else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_BIT_LENGTH) then
                Result := ttBIT_LENGTH else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_BEFORE) then
                Result := ttBEFORE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_BIGINT) then
                Result := ttBIGINT;
        'C' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CREATE) then
                Result := ttCREATE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_COMMIT) then
                Result := ttCOMMIT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CONNECTION) then
                Result := ttCONNECTION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CONNECT) then
                Result := ttCONNECT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CASCADE) then
                Result := ttCASCADE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_COLUMN) then
                Result := ttCOLUMN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CONSTRAINT) then
                Result := ttCONSTRAINT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CASE) then
                Result := ttCASE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CAST) then
                Result := ttCAST else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CONVERT) then
                Result := ttCONVERT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CHARACTER) then
                Result := ttCHARACTER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CHAR) then
                Result := ttCHAR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_COUNT) then
                Result := ttCOUNT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CURRENT_DATE) then
                Result := ttCURRENT_DATE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CURRENT_TIME) then
                Result := ttCURRENT_TIME else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CURRENT_TIMESTAMP) then
                Result := ttCURRENT_TIMESTAMP else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CURRENT_USER) then
                Result := ttCURRENT_USER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CROSS) then
                Result := ttCROSS else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_COLLATE) then
                Result := ttCOLLATE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CHECK) then
                Result := ttCHECK else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CHAR_LENGTH) then
                Result := ttCHAR_LENGTH else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CHARACTER_LENGTH) then
                Result := ttCHARACTER_LENGTH else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CONTINUE) then
                Result := ttCONTINUE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_COALESCE) then
                Result := ttCOALESCE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CURSOR) then
                Result := ttCURSOR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CLOSE) then
                Result := ttCLOSE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_COMMITTED) then
                Result := ttCOMMITTED else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CONSTRAINTS) then
                Result := ttCONSTRAINTS else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CATALOG) then
                Result := ttCATALOG else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_COLLATION) then
                Result := ttCOLLATION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CASCADED) then
                Result := ttCASCADED else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CURRENT) then
                Result := ttCURRENT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CORRESPONDING) then
                Result := ttCORRESPONDING else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CALL) then
                Result := ttCALL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CONDITION) then
                Result := ttCONDITION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CHAIN) then
                Result := ttCHAIN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CONSTRUCTOR) then
                Result := ttCONSTRUCTOR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CARDINALITY) then
                Result := ttCARDINALITY else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CYCLE) then
                Result := ttCYCLE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CEIL) then
                Result := ttCEIL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CEILING) then
                Result := ttCEILING else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CUBE) then
                Result := ttCUBE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_COLLECT) then
                Result := ttCOLLECT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_CHECKED) then
                Result := ttCHECKED;
        'D' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DELETE) then
                Result := ttDELETE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DISCONNECT) then
                Result := ttDISCONNECT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DECLARE) then
                Result := ttDECLARE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DROP) then
                Result := ttDROP else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DESC) then
                Result := ttDESC else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DEC) then
                Result := ttDEC else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DECIMAL) then
                Result := ttDECIMAL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DATE) then
                Result := ttDATE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DOUBLE) then
                Result := ttDOUBLE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DISTINCT) then
                Result := ttDISTINCT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DEFAULT) then
                Result := ttDEFAULT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DAY) then
                Result := ttDAY else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DEFERRED) then
                Result := ttDEFERRED else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DEFERRABLE) then
                Result := ttDEFERRABLE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DESCRIPTOR) then
                Result := ttDESCRIPTOR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DIAGNOSTICS) then
                Result := ttDIAGNOSTICS else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DOMAIN) then
                Result := ttDOMAIN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DEALLOCATE) then
                Result := ttDEALLOCATE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DESCRIBE) then
                Result := ttDESCRIBE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DISPATCH) then
                Result := ttDISPATCH else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DO) then
                Result := ttDO else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_DATABASE) then
                Result := ttDATABASE;
        'E' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_EXISTS) then
                Result := ttEXISTS else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_EXEC) then
                Result := ttEXEC else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_EXECUTE) then
                Result := ttEXECUTE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_END) then
                Result := ttEND else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ELSE) then
                Result := ttELSE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ESCAPE) then
                Result := ttESCAPE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_EXCEPT) then
                Result := ttEXCEPT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_EXCEPTION) then
                Result := ttEXCEPTION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_EXTERNAL) then
                Result := ttEXTERNAL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ELSEIF) then
                Result := ttELSEIF else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_EXIT) then
                Result := ttEXIT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_EACH) then
                Result := ttEACH else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_EXP) then
                Result := ttEXP else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_EVERY) then
                Result := ttEVERY;
        'F' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FROM) then
                Result := ttFROM else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FLOAT) then
                Result := ttFLOAT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FALSE) then
                Result := ttFALSE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FOR) then
                Result := ttFOR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FULL) then
                Result := ttFULL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FOREIGN) then
                Result := ttFOREIGN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FETCH) then
                Result := ttFETCH else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FIRST) then
                Result := ttFIRST else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FOUND) then
                Result := ttFOUND else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FUNCTION) then
                Result := ttFUNCTION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FLOOR) then
                Result := ttFLOOR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FUSION) then
                Result := ttFUSION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_FILENAME) then
                Result := ttFILENAME;
        'G' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_GROUP) then
                Result := ttGROUP else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_GLOBAL) then
                Result := ttGLOBAL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_GO) then
                Result := ttGO else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_GRANT) then
                Result := ttGRANT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_GET) then
                Result := ttGET else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_GOTO) then
                Result := ttGOTO else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_GENERATED) then
                Result := ttGENERATED else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_GROUPING) then
                Result := ttGROUPING;
        'H' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_HAVING) then
                Result := ttHAVING else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_HOUR) then
                Result := ttHOUR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_HANDLER) then
                Result := ttHANDLER;
        'I' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INSERT) then
                Result := ttINSERT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INTO) then
                Result := ttINTO else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_IN) then
                Result := ttIN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_IS) then
                Result := ttIS else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INT) then
                Result := ttINT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INTEGER) then
                Result := ttINTEGER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INNER) then
                Result := ttINNER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INTERVAL) then
                Result := ttINTERVAL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INDICATOR) then
                Result := ttINDICATOR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INTERSECT) then
                Result := ttINTERSECT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_IF) then
                Result := ttIF else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INDEX) then
                Result := ttINDEX else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ISNULL) then
                Result := ttISNULL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INITIALLY) then
                Result := ttINITIALLY else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_IMMEDIATE) then
                Result := ttIMMEDIATE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INSENSITIVE) then
                Result := ttINSENSITIVE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ISOLATION) then
                Result := ttISOLATION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INPUT) then
                Result := ttINPUT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_IDENTITY) then
                Result := ttIDENTITY else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INOUT) then
                Result := ttINOUT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ITERATE) then
                Result := ttITERATE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INSTANCE) then
                Result := ttINSTANCE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INCREMENT) then
                Result := ttINCREMENT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_INTERSECTION) then
                Result := ttINTERSECTION;
        'J' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_JOIN) then
                Result := ttJOIN;
        'K' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_KEY) then
                Result := ttKEY;
        'L' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LIKE) then
                Result := ttLIKE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LEFT) then
                Result := ttLEFT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LOCAL) then
                Result := ttLOCAL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LOWER) then
                Result := ttLOWER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LEADING) then
                Result := ttLEADING else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LAST) then
                Result := ttLAST else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LEVEL) then
                Result := ttLEVEL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LOCATOR) then
                Result := ttLOCATOR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LOOP) then
                Result := ttLOOP else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LEAVE) then
                Result := ttLEAVE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LOGIN) then
                Result := ttLOGIN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_LN) then
                Result := ttLN;
        'M' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MAX) then
                Result := ttMAX else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MIN) then
                Result := ttMIN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MODULE) then
                Result := ttMODULE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MATCH) then
                Result := ttMATCH else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MINUTE) then
                Result := ttMINUTE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MONTH) then
                Result := ttMONTH else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_METHOD) then
                Result := ttMETHOD else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MOD) then
                Result := ttMOD else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MERGE) then
                Result := ttMERGE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MATCHED) then
                Result := ttMATCHED else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MAXVALUE) then
                Result := ttMAXVALUE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MINVALUE) then
                Result := ttMINVALUE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MAXSIZE) then
                Result := ttMAXSIZE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_MULTISET) then
                Result := ttMULTISET;
        'N' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NOT) then
                Result := ttNOT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NUMERIC) then
                Result := ttNUMERIC else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NCHAR) then
                Result := ttNCHAR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NULL) then
                Result := ttNULL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NULLIF) then
                Result := ttNULLIF else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NATURAL) then
                Result := ttNATURAL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NATIONAL) then
                Result := ttNATIONAL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NO) then
                Result := ttNO else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NEXT) then
                Result := ttNEXT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NAMES) then
                Result := ttNAMES else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NAME) then
                Result := ttNAME else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_NORMALIZE) then
                Result := ttNORMALIZE;
        'O' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ORDER) then
                Result := ttORDER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_OR) then
                Result := ttOR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_OUTER) then
                Result := ttOUTER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ON) then
                Result := ttON else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_OVERLAPS) then
                Result := ttOVERLAPS else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ONLY) then
                Result := ttONLY else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_OUTPUT) then
                Result := ttOUTPUT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_OPEN) then
                Result := ttOPEN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_OF) then
                Result := ttOF else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_OPTION) then
                Result := ttOPTION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_OCTET_LENGTH) then
                Result := ttOCTET_LENGTH else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_OUT) then
                Result := ttOUT;
        'P' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PRIMARY) then
                Result := ttPRIMARY else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PRECISION) then
                Result := ttPRECISION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PROCEDURE) then
                Result := ttPROCEDURE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PREPARE) then
                Result := ttPREPARE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_POSITION) then
                Result := ttPOSITION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PARTIAL) then
                Result := ttPARTIAL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PRESERVE) then
                Result := ttPRESERVE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PROC) then
                Result := ttPROC else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PRIOR) then
                Result := ttPRIOR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PRIVILEGES) then
                Result := ttPRIVILEGES else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PUBLIC) then
                Result := ttPUBLIC else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PAD) then
                Result := ttPAD else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PASSWORD) then
                Result := ttPASSWORD else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_PARTITION) then
                Result := ttPARTITION;
        'R' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_REAL) then
                Result := ttREAL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ROLLBACK) then
                Result := ttROLLBACK else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_RIGHT) then
                Result := ttRIGHT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_RESTRICT) then
                Result := ttRESTRICT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_REFERENCES) then
                Result := ttREFERENCES else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ROWS) then
                Result := ttROWS else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_READ) then
                Result := ttREAD else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_RECOMPILE) then
                Result := ttRECOMPILE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_RELATIVE) then
                Result := ttRELATIVE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_REPEATABLE) then
                Result := ttREPEATABLE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_REVOKE) then
                Result := ttREVOKE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ROLE) then
                Result := ttROLE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_RETURNS) then
                Result := ttRETURNS else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_RESULT) then
                Result := ttRESULT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_RETURN) then
                Result := ttRETURN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_REPEAT) then
                Result := ttREPEAT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ROW) then
                Result := ttROW else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_RANGE) then
                Result := ttRANGE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ROLLUP) then
                Result := ttROLLUP;
        'S' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SELECT) then
                Result := ttSELECT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SET) then
                Result := ttSET else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SMALLINT) then
                Result := ttSMALLINT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SUM) then
                Result := ttSUM else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SUBSTRING) then
                Result := ttSUBSTRING else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SESSION_USER) then
                Result := ttSESSION_USER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SYSTEM_USER) then
                Result := ttSYSTEM_USER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SECOND) then
                Result := ttSECOND else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SOME) then
                Result := ttSOME else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SQL) then
                Result := ttSQL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SCROLL) then
                Result := ttSCROLL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SERIALIZABLE) then
                Result := ttSERIALIZABLE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SIZE) then
                Result := ttSIZE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SCHEMA) then
                Result := ttSCHEMA else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SESSION) then
                Result := ttSESSION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SQLERROR) then
                Result := ttSQLERROR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SPACE) then
                Result := ttSPACE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_STATIC) then
                Result := ttSTATIC else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SQLSTATE) then
                Result := ttSQLSTATE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SQLEXCEPTION) then
                Result := ttSQLEXCEPTION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SQLWARNING) then
                Result := ttSQLWARNING else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SENSITIVE) then
                Result := ttSENSITIVE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_STATEMENT) then
                Result := ttSTATEMENT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_START) then
                Result := ttSTART else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SQRT) then
                Result := ttSQRT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SIMPLE) then
                Result := ttSIMPLE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_SAVEPOINT) then
                Result := ttSAVEPOINT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_STDDEV_POP) then
                Result := ttSTDDEV_POP else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_STDDEV_SAMP) then
                Result := ttSTDDEV_SAMP;
        'T' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TABLE) then
                Result := ttTABLE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_THEN) then
                Result := ttTHEN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TIME) then
                Result := ttTIME else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TIMESTAMP) then
                Result := ttTIMESTAMP else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TEXT) then
                Result := ttTEXT else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TO) then
                Result := ttTO else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TRIM) then
                Result := ttTRIM else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TRUE) then
                Result := ttTRUE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TEMPORARY) then
                Result := ttTEMPORARY else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TRAILING) then
                Result := ttTRAILING else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TRANSACTION) then
                Result := ttTRANSACTION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TRANSLATION) then
                Result := ttTRANSLATION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TRANSLATE) then
                Result := ttTRANSLATE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TIMEZONE_HOUR) then
                Result := ttTIMEZONE_HOUR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TIMEZONE_MINUTE) then
                Result := ttTIMEZONE_MINUTE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TYPE) then
                Result := ttTYPE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_TRIGGER) then
                Result := ttTRIGGER;
        'U' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_UPDATE) then
                Result := ttUPDATE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_UNIQUE) then
                Result := ttUNIQUE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_UNION) then
                Result := ttUNION else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_USER) then
                Result := ttUSER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_USE) then
                Result := ttUSE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_UPPER) then
                Result := ttUPPER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_USING) then
                Result := ttUSING else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_UNCOMMITTED) then
                Result := ttUNCOMMITTED else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_USAGE) then
                Result := ttUSAGE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_UNKNOWN) then
                Result := ttUNKNOWN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_UNTIL) then
                Result := ttUNTIL else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_UNDO) then
                Result := ttUNDO;
        'V' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_VARCHAR) then
                Result := ttVARCHAR else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_VALUES) then
                Result := ttVALUES else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_VARYING) then
                Result := ttVARYING else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_VIEW) then
                Result := ttVIEW else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_VARYING) then
                Result := ttVARYING else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_VALUE) then
                Result := ttVALUE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_VAR_SAMP) then
                Result := ttVAR_SAMP else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_VAR_POP) then
                Result := ttVAR_POP;
        'W' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_WHERE) then
                Result := ttWHERE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_WHEN) then
                Result := ttWHEN else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_WITH) then
                Result := ttWITH else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_WRITE) then
                Result := ttWRITE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_WHILE) then
                Result := ttWHILE else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_WHENEVER) then
                Result := ttWHENEVER else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_WORK) then
                Result := ttWORK else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_WIDTH_BUCKET) then
                Result := ttWIDTH_BUCKET else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_WINDOW) then
                Result := ttWINDOW else
              if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_WITHIN) then
                Result := ttWITHIN;
        'Y' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_YEAR) then
                Result := ttYEAR;
        'Z' : if StrEqualNoAsciiCaseA(Identifier, SQL_KEYWORD_ZONE) then
                Result := ttZONE;
      end;
    end;
end;

const
  SqlTokenNameTable: Array[$00..$3F] of AnsiString = (
      'NONE', 'EOF', 'INVALID_CHAR', 'SP', 'NL', 'IDEN', 'U_INT', 'REAL',
      'STR', 'Q_IDEN', 'SCI_REAL', 'NSTR', 'HEX_STR', 'BIT_STR', 'LINE_COMMENT', 'BLOCK_COMMENT',
      'LOCAL_IDEN', 'EMBEDDED_SQL', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      'L_PAREN', 'R_PAREN', 'PLUS', 'MINUS', 'ASTERISK', 'SOLIDUS', 'POWER', 'LE',
      'GR', 'LE_OR_EQ', 'GR_OR_EQ', 'EQ', 'NOT_EQ', 'COMMA', 'PERCENT', 'AMPERSAND',
      'PERIOD', 'DOUBLE_PERIOD', 'COLON', 'SEMICOLON', 'Q_MARK', 'VERT_BAR',
      'CONCAT', 'L_BRACKET', 'R_BRACKET', '', '', '', '', '', '', '');

function SqlTokenName(const TokenType: Integer): AnsiString;
begin
  if (TokenType < 0) or (TokenType > $3F) then
    Result := ''
  else
    Result := SqlTokenNameTable[TokenType];
end;

function SqlTokenToDataType(const TokenType: Integer): TSqlDataType;
begin
  case TokenType of
    ttCHARACTER : Result := stChar;
    ttCHAR      : Result := stChar;
    ttVARCHAR   : Result := stVarChar;
    ttNCHAR     : Result := stNChar;
    ttTEXT      : Result := stText;
    ttNUMERIC   : Result := stNumeric;
    ttDECIMAL   : Result := stDecimal;
    ttDEC       : Result := stDecimal;
    ttINTEGER   : Result := stInt;
    ttINT       : Result := stInt;
    ttSMALLINT  : Result := stSmallInt;
    ttFLOAT     : Result := stFloat;
    ttREAL      : Result := stReal;
    ttDATE      : Result := stDate;
    ttTIME      : Result := stTime;
    ttTIMESTAMP : Result := stDateTime;
    ttINTERVAL  : Result := stInterval;
    ttBIGINT    : Result := stBigInt;
  else
    Result := stUndefined;
  end;
end;

function SqlTokenToComparisonOperator(const TokenType: Integer): TSqlComparisonOperator;
begin
  case TokenType of
    ttEqual          : Result := scoEqual;
    ttNotEqual       : Result := scoNotEqual;
    ttLess           : Result := scoLess;
    ttGreater        : Result := scoGreater;
    ttLessOrEqual    : Result := scoLessOrEqual;
    ttGreaterOrEqual : Result := scoGreaterOrEqual;
  else
    Result := scoUndefined;
  end;
end;

function SqlTokenToNumericOperator(const TokenType: Integer): TSqlNumericOperator;
begin
  case TokenType of
    ttPlus     : Result := snoAdd;
    ttMinus    : Result := snoSubtract;
    ttAsterisk : Result := snoMultiply;
    ttSolidus  : Result := snoDivide;
    ttPower    : Result := snoPower;
  else
    Result := snoUndefined;
  end;
end;

function SqlTokenToSetFunction(const TokenType: Integer): TSqlSetFunctionType;
begin
  case TokenType of
    ttAVG   : Result := scmAvg;
    ttMAX   : Result := scmMax;
    ttMIN   : Result := scmMin;
    ttSUM   : Result := scmSum;
    ttCOUNT : Result := scmCount;
  else
    Result := scmUndefined;
  end;
end;

function SqlTokenToSetQuantifier(const TokenType: Integer): TSqlSetQuantifier;
begin
  case TokenType of
    ttDISTINCT : Result := ssqDistinct;
    ttALL      : Result := ssqAll
  else
    Result := ssqNone;
  end;
end;



{                                                                              }
{ TSqlLexer                                                                    }
{                                                                              }
constructor TSqlLexer.Create;
begin
  inherited Create;
  FOptions := [sloAllowLineComment, sloAllowBlockComment];
  FReader := TLongStringReader.Create('');
end;

destructor TSqlLexer.Destroy;
begin
  FreeAndNil(FReader);
  inherited Destroy;
end;

procedure TSqlLexer.SetText(const Text: AnsiString);
begin
  FReader.DataString := Text;
  FTokenType := ttNone;
  FTokenStr := '';
end;

function TSqlLexer.GetTokenInt64: Int64;
begin
  Result := StringToInt64A(FTokenStr);
end;

function TSqlLexer.ParseIdentifierToken(const C: AnsiChar): Integer;
var B : array[0..4] of AnsiChar;
begin
  if C in ['B', 'b', 'N', 'n', 'X', 'x'] then
    if FReader.Peek(B[0], 2) = 2 then
      if B[1] = '''' then
        begin
          FReader.SkipByte;
          FTokenStr := ExtractQuotedString('''');
          case C of
            'B', 'b' : Result := ttBitStringLiteral;
            'N', 'n' : Result := ttNStringLiteral;
          else
            Result := ttHexStringLiteral;
          end;
          exit;
        end;
  FTokenStr := FReader.ExtractAll(SQL_CHAR_Identifier, False, -1);
  Assert(FTokenStr <> '');
  Result := SqlIdentifierStrToToken(FTokenStr);
  if Result = ttEND then
    if FReader.Peek(B[0], 5) = 5 then
      if (B[0] = '-') and (UpCase(B[1]) = 'E') and (UpCase(B[2]) = 'X') and
         (UpCase(B[3]) = 'E') and (UpCase(B[4]) = 'X') then
        begin
          FReader.Skip(5);
          FTokenStr := SQL_KEYWORD_ENDEXEC;
          Result := ttENDEXEC;
        end;
end;

function TSqlLexer.ParseParameterIdentifierToken: Integer;
begin
  FTokenStr := FReader.ExtractAll(SQL_CHAR_IdentifierExt, False, -1);
  Result := ttLocalIdentifier;
end;

function TSqlLexer.ParseSimpleNumberToken: Integer;
begin
  FTokenStr := FReader.ExtractAll(SQL_CHAR_Digit, False, -1);
  Assert(FTokenStr <> '');
  Result := ttUnsignedInteger;
  if not FReader.EOF and (Char(FReader.PeekByte) = '.') then
    begin
      FReader.SkipByte;
      FTokenStr := FTokenStr + '.' +
          FReader.ExtractAll(SQL_CHAR_Digit, False, -1);
      Result := ttRealNumber;
    end;
end;

function TSqlLexer.ParseNumberToken: Integer;
var M : AnsiString;
begin
  Result := ParseSimpleNumberToken;
  if not FReader.EOF and (AnsiChar(FReader.PeekByte) in ['e', 'E']) then
    begin
      FReader.SkipByte;
      M := FTokenStr;
      ParseSimpleNumberToken;
      FTokenStr := M + 'e' + FTokenStr;
      Result := ttSciRealNumber;
    end;
end;

function TSqlLexer.ExtractQuotedString(const QuoteCh: AnsiChar): AnsiString;
var S : AnsiString;
    R : Boolean;
    Q : Boolean;
    C : CharSet;
    B : Array[0..1] of AnsiChar;
begin
  C := CompleteCharSet;
  Exclude(C, QuoteCh);
  S := '';
  R := False;
  repeat
    S := S + FReader.ExtractAll(C, False, -1);
    if FReader.EOF then
      raise ESqlLexer.Create('Quote character expected');
    Q := False;
    if FReader.Peek(B[0], 2) = 2 then
      if (B[0] = QuoteCh) and (B[1] = QuoteCh) then
        begin
          FTokenStr := FTokenStr + QuoteCh;
          FReader.Skip(2);
          Q := True;
        end;
    if not Q then
      begin
        Assert(AnsiChar(FReader.PeekByte) = QuoteCh);
        FReader.SkipByte;
        R := True
      end;
  until R;
  Result := S;
end;

function TSqlLexer.GetNextToken: Integer;
var C, D : AnsiChar;
    B    : Array[0..3] of AnsiChar;
begin
  FTokenStr := '';
  if FReader.EOF then
    begin
      FTokenType := ttEof;
      Result := ttEof;
      exit;
    end;
  C := AnsiChar(FReader.PeekByte);
  case C of
    'A'..'Z', 'a'..'z', '_' :
      Result := ParseIdentifierToken(C);
    '@' :
      if sloExtendedSyntax in FOptions then
        Result := ParseParameterIdentifierToken
      else
        begin
          FReader.SkipByte;
          Result := ttInvalidChar;
        end;
    '0'..'9' :
      Result := ParseNumberToken;
  else
    begin
      FReader.SkipByte;
      case C of
        #10,
        #13      :
          begin
            if not FReader.EOF then
              begin
                D := AnsiChar(FReader.PeekByte);
                if (D in [#10, #13]) and (D <> C) then
                  FReader.SkipByte;
              end;
            Result := ttNewLine;
          end;
        #0..#9,
        #11,
        #12,
        #14..#32 :
          begin
            FReader.SkipAll(SQL_CHAR_WhiteSpace, False, -1);
            Result := ttWhiteSpace;
          end;
        '('      : Result := ttLeftParen;
        ')'      : Result := ttRightParen;
        '['      : Result := ttLeftBracket;
        ']'      : Result := ttRightBracket;
        ','      : Result := ttComma;
        '+'      : Result := ttPlus;
        '-'      :
          if (sloAllowLineComment in FOptions) and not FReader.EOF and
             (Char(FReader.PeekByte) = '-') then
            begin
              FReader.SkipByte;
              Result := ttLineComment;
              FTokenStr := FReader.ExtractAll(SQL_CHAR_NonNewLine, False, -1);
            end
          else
            Result := ttMinus;
        '/'      :
          if (sloAllowBlockComment in FOptions) and not FReader.EOF and
             (Char(FReader.PeekByte) = '*') then
            begin
              FReader.SkipByte;
              Result := ttBlockComment;
              FTokenStr := FReader.ExtractToStr('*/');
              if FReader.EOF then
                raise ESqlLexer.Create('Undelimited comment');
              FReader.Skip(2);
            end
          else
            Result := ttSolidus;
        '"'      : begin
                     FTokenStr := ExtractQuotedString('"');;
                     Result := ttQuotedIdentifier;
                   end;
        ''''     : begin
                     FTokenStr := ExtractQuotedString('''');;
                     Result := ttStringLiteral;
                   end;
        '%'      : Result := ttPercent;
        '&'      :
          begin
            Result := ttAmpersand;
            if not FReader.EOF and (FReader.Peek(B[0], 4) = 4) then
              if (UpCase(B[0]) = 'S') and (UpCase(B[1]) = 'Q') and
                 (UpCase(B[2]) = 'L') and (B[3] = '(') then
                begin
                  FReader.Skip(4);
                  Result := ttEmbeddedSqlPrefix;
                end;
          end;
        '.'      :
          if not FReader.EOF and (Char(FReader.PeekByte) = '.') then
            begin
              FReader.SkipByte;
              Result := ttDoublePeriod;
            end
          else
            Result := ttPeriod;
        ':'      : Result := ttColon;
        ';'      : Result := ttSemicolon;
        '?'      : Result := ttQuestionMark;
        '|'      :
          if not FReader.EOF and (Char(FReader.PeekByte) = '|') then
            begin
              FReader.SkipByte;
              Result := ttConcatenation;
            end
          else
            Result := ttVerticalBar;
        '*'      :
          if not FReader.EOF and (Char(FReader.PeekByte) = '*') then
            begin
              FReader.SkipByte;
              Result := ttPower;
            end
          else
            Result := ttAsterisk;
        '='      : Result := ttEqual;
        '<'      :
          if FReader.EOF then
            Result := ttLess
          else
            case AnsiChar(FReader.PeekByte) of
              '='  :
                begin
                  FReader.SkipByte;
                  Result := ttLessOrEqual;
                end;
              '>'  :
                begin
                  FReader.SkipByte;
                  Result := ttNotEqual;
                end
            else
              Result := ttLess;
            end;
        '>'      :
          if not FReader.EOF and (Char(FReader.PeekByte) = '=') then
            begin
              FReader.SkipByte;
              Result := ttGreaterOrEqual;
            end
          else
            Result := ttGreater;
      else
        Result := ttInvalidChar;
      end;
    end;
  end;
  FTokenType := Result;
end;

function TSqlLexer.TokenStrIs(const TokenStr: AnsiString): Boolean;
begin
  Result := StrEqualNoAsciiCaseA(FTokenStr, TokenStr);
end;

function TSqlLexer.TokenIsReservedKeyword: Boolean;
begin
  Result :=
      (FTokenType >= tt__FirstReserved) and
      (FTokenType <= tt__LastReserved);
end;

function TSqlLexer.TokenIsKeyword: Boolean;
begin
  Result :=
      (FTokenType >= tt__FirstKeyword) and
      (FTokenType <= tt__LastKeyword);
end;

function TSqlLexer.GetTokenID: AnsiString;
var R, S : AnsiString;
begin
  case FTokenType of
    ttWhiteSpace       : R := '.';
    ttIdentifier,
    ttLocalIdentifier  : R := '[' + FTokenStr + ']';
    ttUnsignedInteger,
    ttRealNumber,
    ttSciRealNumber    : R := '(' + FTokenStr + ')';
    ttStringLiteral,
    ttNStringLiteral   : R := '("' + FTokenStr + '")';
  else
    begin
      S := SqlTokenName(FTokenType);
      if S <> '' then
        R := '<' + S + '>' else
      if TokenIsKeyword then
        R := '{' + TokenStr + '}'
      else
        R := '<#' + IntToStringA(FTokenType) + '>';
    end;
  end;
  if FTokenType in [
      ttQuotedIdentifier, ttHexStringLiteral, ttBitStringLiteral,
      ttBlockComment, ttLineComment  
      ] then
    R := R + '"' + FTokenStr + '"';
  Result := R;
end;

function TSqlLexer.GetTokenIDSequence: AnsiString;
var B : TAnsiStringBuilder;
begin
  B := TAnsiStringBuilder.Create;
  try
    while GetNextToken <> ttEof do
      B.Append(TokenID);
    Result := B.AsAnsiString;
  finally
    B.Free;
  end;
end;



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF SQL_SELFTEST}
{$ASSERTIONS ON}
procedure SelfTest_Simple;
var P : TSqlLexer;
begin
  P := TSqlLexer.Create;
  try
    P.SetText('SELECT * FROM ABC');
    Assert(P.TokenType = ttNone);
    Assert(P.GetNextToken = ttSELECT);
    Assert(P.TokenIsKeyword);
    Assert(P.TokenStr = 'SELECT');
    Assert(P.GetNextToken = ttWhiteSpace);
    Assert(P.GetNextToken = ttAsterisk);
    Assert(P.GetNextToken = ttWhiteSpace);
    Assert(P.GetNextToken = ttFROM);
    Assert(P.GetNextToken = ttWhiteSpace);
    Assert(P.GetNextToken = ttIdentifier);
    Assert(not P.TokenIsKeyword);
    Assert(P.TokenStr = 'ABC');
    Assert(P.GetNextToken = ttEof);
  finally
    P.Free;
  end;
end;

procedure SelfTest_Seq(const SqlStr, SeqStr: AnsiString);
var P : TSqlLexer;
    S : AnsiString;
begin
  P := TSqlLexer.Create;
  try
    P.SetText(SqlStr);
    S := P.GetTokenIDSequence;
    Assert(S = SeqStr);
  finally
    P.Free;
  end;
end;

procedure SelfTest;
begin
  SelfTest_Simple;
  SelfTest_Seq(
      'SELECT * FROM TABLE1 WHERE X=2  OR  Y=''A''',
      '{SELECT}.<ASTERISK>.{FROM}.[TABLE1].{WHERE}.[X]<EQ>(2).{OR}.[Y]<EQ>("A")');
  SelfTest_Seq(
      '1 + /* Comment */ 2',
      '(1).<PLUS>.<BLOCK_COMMENT>" Comment ".(2)');
  SelfTest_Seq(
      'INSERT -- Comment',
      '{INSERT}.<LINE_COMMENT>" Comment"');
  SelfTest_Seq(
      '1.23 ''A'' TRUE NULL GO',
      '(1.23).("A").{TRUE}.{NULL}.{GO}');
end;
{$ENDIF}



end.

