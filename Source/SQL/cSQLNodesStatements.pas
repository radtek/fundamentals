{******************************************************************************}
(*                                                                            *)
(*    Library:       Fundamentals SQL                                         *)
(*    Description:   SQL nodes: Statements                                    *)
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
(*    2003/07/29  0.02  Created cSQLNodesStatement unit.                      *)
(*    2005/03/27  0.03  Implement execute for INSERT, UPDATE, DELETE.         *)
(*    2005/03/28  0.04  Revision.                                             *)
(*    2005/04/08  0.05  Development.                                          *)
(*                                                                            *)
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLNodesStatements;

interface

uses
  { Fundamentals }
  cUtils,

  { SQL }
  cSQLUtils,
  cSQLStructs,
  cSQLDatabase,
  cSQLNodes,
  cSQLNodesStructs;



{                                                                              }
{ TSqlReferencesSpecification                                                  }
{                                                                              }
type
  TSqlReferencesMatchType = (
      srmUndefined,
      srmFull,
      srmPartial,
      srmSimple);
  TSqlReferentialAction = (
      sraUndefined,
      sraCascade,
      sraSetNull,
      sraSetDefault,
      sraNoAction);
  TSqlReferencesSpecification = class
    TableName    : AnsiString;
    Columns      : AnsiStringArray;
    MatchType    : TSqlReferencesMatchType;
    UpdateAction : TSqlReferentialAction;
    DeleteAction : TSqlReferentialAction;
  end;



{                                                                              }
type
  ASqlConstraint = class
  end;

  TSqlCheckConstraint = class(ASqlConstraint)
  protected
    FCheckCondition : ASqlSearchCondition;
  public
    property CheckCondition: ASqlSearchCondition read FCheckCondition write FCheckCondition;
  end;

  TSqlUniqueSpecification = (
      susUndefined,
      susUnique,
      susPrimaryKey);
  TSqlUniqueConstraint = class(ASqlConstraint)
    Specification : TSqlUniqueSpecification;
    UniqueColumns : AnsiStringArray;
  end;

  TSqlReferentialConstraint = class(ASqlConstraint)
    ReferencesSpec     : TSqlReferencesSpecification;
    ReferencingColumns : AnsiStringArray;
  end;



{                                                                              }
{ TSqlColumnConstraintDefinition                                               }
{                                                                              }
type
  TSqlColumnConstraintDefinition = class
    Name            : AnsiString;
    UniqueSpec      : TSqlUniqueSpecification;
    ReferencesSpec  : TSqlReferencesSpecification;
    CheckConstraint : TSqlCheckConstraint;
    NotNull         : Boolean;
  end;



{                                                                              }
type
  TSqlColumnDefinitionEx = class(TSqlColumnDefinition)
    DefaultClause    : ASqlValueExpression;
    ColumnConstraint : TSqlColumnConstraintDefinition;
    Collate          : AnsiString;
  end;



{                                                                              }
{ ASqlStatementList                                                            }
{   Base class for a list of statements.                                       }
{                                                                              }
type
  ASqlStatementList = class(ASqlStatement)
  protected
    FList : ASqlStatementArray;

  public
    constructor CreateEx(const List: ASqlStatementArray);
    destructor Destroy; override;

    property  List: ASqlStatementArray read FList write FList;
    procedure Add(const Statement: ASqlStatement);

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlStatement; override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlStatementSequence                                                        }
{   A sequence of statements.                                                  }
{                                                                              }
type
  TSqlStatementSequence = class(ASqlStatementList)
  public
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
  end;



{                                                                              }
{ TSqlStatementBlock                                                           }
{   A BEGIN .. END statement block.                                            }
{                                                                              }
type
  TSqlStatementBlock = class(ASqlStatementList)
  public
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
  end;



{                                                                              }
{ ASqlConnectionStatement                                                      }
{   Base class for connection statements.                                      }
{                                                                              }
type
  ASqlConnectionStatement = class(ASqlStatement);



{                                                                              }
{ TSqlConnectStatement                                                         }
{   CONNECT Statement.                                                         }
{                                                                              }
type
  TSqlConnectStatement = class(ASqlConnectionStatement)
  protected
    FConnectDefault : Boolean;
    FServerName     : ASqlValueExpression;
    FConnectionName : ASqlValueExpression;
    FUserName       : ASqlValueExpression;

  public
    constructor CreateDefault;
    constructor CreateEx(const ServerName, ConnectionName, UserName: ASqlValueExpression);

    property  ConnectDefault: Boolean read FConnectDefault write FConnectDefault;
    property  ServerName: ASqlValueExpression read FServerName write FServerName;
    property  ConnectionName: ASqlValueExpression read FConnectionName write FConnectionName;
    property  UserName: ASqlValueExpression read FUserName write FUserName;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlDisconnectStatement                                                      }
{   DISCONNECT Statement.                                                      }
{                                                                              }
type
  TSqlDisconnectObjectType = (sdoUndefined, sdoAll, sdoCurrent, sdoDefault);
  TSqlDisconnectObject = class
    ObjType        : TSqlDisconnectObjectType;
    ConnectionName : ASqlValueExpression;
  end;
  TSqlDisconnectStatement = class(ASqlConnectionStatement)
  protected
    FDisconnectObj : TSqlDisconnectObject;

  public
    property  DisconnectObj: TSqlDisconnectObject read FDisconnectObj write FDisconnectObj;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlSetConnectionStatement                                                   }
{                                                                              }
type
  TSqlSetConnectionStatement = class(ASqlConnectionStatement)
  protected
    FDefaultObj     : Boolean;
    FConnectionName : ASqlValueExpression;

  public
    property  DefaultObj: Boolean read FDefaultObj write FDefaultObj;
    property  ConnectionName: ASqlValueExpression read FConnectionName write FConnectionName;
  end;



{                                                                              }
{ TSqlUseStatement                                                             }
{                                                                              }
type
  TSqlUseStatement = class(ASqlStatement)
  protected
    FDatabaseName : AnsiString;

  public
    property  DatabaseName: AnsiString read FDatabaseName write FDatabaseName;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;

  

{                                                                              }
{ TSqlCreateTableStatement                                                     }
{   CREATE TABLE Statement.                                                    }
{                                                                              }
type
  TSqlConstraintDeferrable = (scdUndefined, scdDeferrable, scdNotDeferrable);
  TSqlConstraintAttributes = class
    Deferrable : TSqlConstraintDeferrable;
    CheckTime  : TSqlConstraintCheckTime;
  end;
  TSqlTableConstraint = class
    Name       : AnsiString;
    Constraint : ASqlConstraint;
    Attributes : TSqlConstraintAttributes;
  end;
  TSqlTableConstraintArray = Array of TSqlTableConstraint;

  TSqlTableElement = class
    ColumnDefinition : TSqlColumnDefinitionEx;
    TableConstraint  : TSqlTableConstraint;
  end;
  TSqlTableElementArray = Array of TSqlTableElement;

  TSqlCreateTableStatement = class(ASqlStatement)
  protected
    FScope        : TSqlTableScope;
    FTemporary    : Boolean;
    FTableName    : AnsiString;
    FCommitAction : TSqlTableCommitAction;
    FElementList  : TSqlTableElementArray;

  public
    constructor Create;
    constructor CreateEx(const TableName: AnsiString;
                const Columns: TSqlColumnDefinitionList);
    destructor Destroy; override;

    property  Scope: TSqlTableScope read FScope write FScope;
    property  Temporary: Boolean read FTemporary write FTemporary;
    property  TableName: AnsiString read FTableName write FTableName;
    property  CommitAction: TSqlTableCommitAction read FCommitAction write FCommitAction;
    property  ElementList: TSqlTableElementArray read FElementList write FElementList;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlCreateIndexStatement                                                     }
{                                                                              }
type
  TSqlCreateIndexStatement = class(ASqlStatement)
  protected
    FIndexName : AnsiString;
    FTableName : AnsiString;

  public
    property  IndexName: AnsiString read FIndexName write FIndexName;
    property  TableName: AnsiString read FTableName write FTableName;
  end;



{                                                                              }
{ TSqlDropStatement                                                            }
{   Generic DROP Statement.                                                    }
{                                                                              }
type
  TSqlDropType = (
      sdtUndefined,
      sdtView,
      sdtDomain,
      sdtCharacterSet,
      sdtCollation,
      sdtTranslation,
      sdtAssertion,
      sdtSchema,
      sdtDatabase);
  TSqlDropStatement = class(ASqlStatement)
  protected
    FDropType     : TSqlDropType;
    FIdentifier   : AnsiString;
    FDropBehavior : TSqlDropBehavior;

  public
    property  DropType: TSqlDropType read FDropType write FDropType;
    property  Identifier: AnsiString read FIdentifier write FIdentifier;
    property  DropBehavior: TSqlDropBehavior read FDropBehavior write FDropBehavior;

    function  Execute(const Database: ASqlDatabase; const Scope: ASqlScope): ASqlCursor; override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlDropTableStatement                                                       }
{   DROP TABLE Statement.                                                      }
{                                                                              }
type
  TSqlDropTableStatement = class(ASqlStatement)
  protected
    FTableName    : AnsiString;
    FDropBehavior : TSqlDropBehavior;

  public
    constructor CreateEx(const TableName: AnsiString;
                const DropBehavior: TSqlDropBehavior);

    property  TableName: AnsiString read FTableName write FTableName;
    property  DropBehavior: TSqlDropBehavior read FDropBehavior write FDropBehavior;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlInsertStatement                                                          }
{   INSERT Statement.                                                          }
{                                                                              }
type
  TSqlInsertStatement = class(ASqlStatement)
  protected
    FTableName     : AnsiString;
    FColumnList    : AnsiStringArray;
    FQueryExpr     : ASqlQueryExpression;
    FDefaultValues : Boolean;

  public
    constructor CreateEx(const TableName: AnsiString;
                const ColumnList: AnsiStringArray;
                const QueryExpr: ASqlQueryExpression;
                const DefaultValues: Boolean);
    destructor Destroy; override;

    property  TableName: AnsiString read FTableName write FTableName;
    property  ColumnList: AnsiStringArray read FColumnList write FColumnList;
    property  QueryExpr: ASqlQueryExpression read FQueryExpr write FQueryExpr;
    property  DefaultValues: Boolean read FDefaultValues write FDefaultValues;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlStatement; override;
    procedure Prepare(const Database: ASqlDatabase; const Scope: ASqlScope); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlSelectStatement                                                          }
{   SELECT Statement.                                                          }
{                                                                              }
type
  TSqlSelectStatement = class(ASqlStatement)
  protected
    FQueryExpr : ASqlQueryExpression;
    FOrderBy   : TSqlSortSpecificationArray;

  public
    constructor CreateEx(const QueryExpr: ASqlQueryExpression;
                const OrderBy: TSqlSortSpecificationArray);
    destructor Destroy; override;

    property  QueryExpr: ASqlQueryExpression read FQueryExpr write FQueryExpr;
    property  OrderBy: TSqlSortSpecificationArray read FOrderBy write FOrderBy;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlStatement; override;
    procedure Prepare(const Database: ASqlDatabase; const Scope: ASqlScope); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlUpdateStatement                                                          }
{   UPDATE Statement.                                                          }
{                                                                              }
type
  TSqlUpdateSetItem = class
  protected
    FColumnName : AnsiString;
    FValue      : ASqlValueExpression;

  public
    constructor CreateEx(const ColumnName: AnsiString;
                const Value: ASqlValueExpression);
    destructor Destroy; override;

    property  ColumnName: AnsiString read FColumnName write FColumnName;
    property  Value: ASqlValueExpression read FValue write FValue;

    procedure TextOutputSql(const Output: TSqlTextOutput);
    procedure Simplify;
  end;
  TSqlUpdateSetItemArray = Array of TSqlUpdateSetItem;

  TSqlUpdateSetList = class
  protected
    FList : TSqlUpdateSetItemArray;

  public
    destructor Destroy; override;

    procedure AddItem(const Item: TSqlUpdateSetItem);
    function  Count: Integer;
    function  Item(const Idx: Integer): TSqlUpdateSetItem;

    procedure TextOutputSql(const Output: TSqlTextOutput);
    procedure Simplify;
    procedure Execute(const Engine: ASqlDatabaseEngine; const Cursor: ASqlCursor);
  end;

  TSqlUpdateStatementType = (supUndefined, supSearched, supPositioned);
  TSqlUpdateStatement = class(ASqlStatement)
  protected
    FUpdateType : TSqlUpdateStatementType;
    FTableName  : AnsiString;
    FSetList    : TSqlUpdateSetList;
    FWhere      : ASqlSearchCondition;
    FCursorName : ASqlValueExpression;

  public
    constructor CreateEx(const TableName: AnsiString;
                const SetList: TSqlUpdateSetList;
                const Where: ASqlSearchCondition);
    destructor Destroy; override;

    property  UpdateType: TSqlUpdateStatementType read FUpdateType write FUpdateType;
    property  TableName: AnsiString read FTableName write FTableName;
    property  SetList: TSqlUpdateSetList read FSetList write FSetList;
    property  Where: ASqlSearchCondition read FWhere write FWhere;
    property  CursorName: ASqlValueExpression read FCursorName write FCursorName;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlStatement; override;
    procedure Prepare(const Database: ASqlDatabase; const Scope: ASqlScope); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlDeleteStatement                                                          }
{   DELETE Statement.                                                          }
{                                                                              }
type
  TSqlDeleteStatementType = (sdsUndefined, sdsPositioned, sdsSearched,
      sdsDynamicPositioned);
  TSqlDeleteStatement = class(ASqlStatement)
  protected
    FDeleteType : TSqlDeleteStatementType;
    FTableName  : AnsiString;
    FWhere      : ASqlSearchCondition;
    FCursorName : ASqlValueExpression;

  public
    constructor CreateEx(const TableName: AnsiString;
                const Where: ASqlSearchCondition);
    destructor Destroy; override;

    property  DeleteType: TSqlDeleteStatementType read FDeleteType write FDeleteType;
    property  TableName: AnsiString read FTableName write FTableName;
    property  Where: ASqlSearchCondition read FWhere write FWhere;
    property  CursorName: ASqlValueExpression read FCursorName write FCursorName;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlStatement; override;
    procedure Prepare(const Database: ASqlDatabase; const Scope: ASqlScope); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ ASqlTransactionStatement                                                     }
{   Base class for Transaction Statements.                                     }
{                                                                              }
type
  ASqlTransactionStatement = class(ASqlStatement);



{                                                                              }
{ TSqlCommitStatement                                                          }
{   COMMIT Statement.                                                          }
{                                                                              }
type
  TSqlCommitStatement = class(ASqlTransactionStatement)
  protected
    FWork : Boolean;

  public
    property  Work: Boolean read FWork write FWork;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlRollbackStatement                                                        }
{   ROLLBACK Statement.                                                        }
{                                                                              }
type
  TSqlRollbackStatement = class(ASqlTransactionStatement)
  protected
    FWork : Boolean;

  public
    property  Work: Boolean read FWork write FWork;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlIfStatement                                                              }
{   IF Statement.                                                              }
{                                                                              }
type
  TSqlIfStatement = class(ASqlStatement)
  protected
    FCondition      : ASqlSearchCondition;
    FTrueStatement  : ASqlStatement;
    FFalseStatement : ASqlStatement;

  public
    property  Condition: ASqlSearchCondition read FCondition write FCondition;
    property  TrueStatement: ASqlStatement read FTrueStatement write FTrueStatement;
    property  FalseStatement: ASqlStatement read FFalseStatement write FFalseStatement;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlStatement; override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlWhileStatement                                                           }
{   WHILE Statement.                                                           }
{                                                                              }
type
  TSqlWhileStatement = class(ASqlStatement)
  protected
    FCondition : ASqlSearchCondition;
    FStatement : ASqlStatement;

  public
    property  Condition: ASqlSearchCondition read FCondition write FCondition;
    property  Statement: ASqlStatement read FStatement write FStatement;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlStatement; override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlCreateProcedureStatement                                                 }
{   CREATE PROCEDURE Statement.                                                }
{                                                                              }
type
  TSqlCreateProcedureStatement = class(ASqlStatement)
  protected
    FDefinition : TSqlProcedureDefinition;

  public
    destructor Destroy; override;

    property  Definition: TSqlProcedureDefinition read FDefinition write FDefinition;

    function  ReleaseDefinition: TSqlProcedureDefinition;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Simplify: ASqlStatement; override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlDropProcedureStatement                                                   }
{   DROP PROCEDURE Statement.                                                  }
{                                                                              }
type
  TSqlDropProcedureStatement = class(ASqlStatement)
  protected
    FProcName : AnsiString;

  public
    constructor CreateEx(const ProcName: AnsiString);

    property  ProcName: AnsiString read FProcName write FProcName;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlStatementName / TSqlDescriptorName                                       }
{                                                                              }
type
  TSqlStatementName = class
    Identifier  : AnsiString;
    ScopeOption : TSqlScopeOption;
    ExtName     : ASqlValueExpression;
  end;

  TSqlDescriptorName = class
    ScopeOption : TSqlScopeOption;
    NameExpr    : ASqlValueExpression;
  end;



{                                                                              }
{ TSqlUsingClause                                                              }
{                                                                              }
type
  TSqlUsingType =
      (sutUndefined,
       sutArguments,
       sutDescriptor);
  TSqlUsingClause = class
    UsingType       : TSqlUsingType;
    UsingArguments  : ASqlValueExpressionArray;
    DescriptorScope : TSqlScopeOption;
    Descriptor      : ASqlValueExpression;
  end;



{                                                                              }
{ TSqlExecuteStatement                                                         }
{   EXECUTE Statement.                                                         }
{                                                                              }
type
  TSqlExecuteStatement = class(ASqlStatement)
  protected
    FName       : AnsiString;
    FParameters : TSqlParameterValueArray;

  public
    destructor Destroy; override;

    property  Name: AnsiString read FName write FName;
    property  Parameters: TSqlParameterValueArray read FParameters write FParameters;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Simplify: ASqlStatement; override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;

  TSqlExecuteImmediateStatement = class(ASqlStatement)
  protected
    FStatementName : ASqlValueExpression;

  public
    property StatementName: ASqlValueExpression read FStatementName write FStatementName;
  end;

  TSql92ExecuteStatement = class(ASqlStatement)
  protected
    FStatementName : TSqlStatementName;
    FClause1       : TSqlUsingClause;
    FClause2       : TSqlUsingClause;

  public
    property  StatementName: TSqlStatementName read FStatementName write FStatementName;
    property  Clause1: TSqlUsingClause read FClause1 write FClause1;
    property  Clause2: TSqlUsingClause read FClause2 write FClause2;
  end;



{                                                                              }
{ TSqlDeclareLocalVariableStatement                                            }
{   DECLARE @Local Statement.                                                  }
{                                                                              }
type
  TSqlDeclareLocalVariableStatement = class(ASqlStatement)
  protected
    FName    : AnsiString;
    FTypeDef : TSqlDataTypeDefinition;

  public
    destructor Destroy; override;

    property  Name: AnsiString read FName write FName;
    property  TypeDef: TSqlDataTypeDefinition read FTypeDef write FTypeDef;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlSetLocalVariableStatement                                                }
{   SET @Local Statement.                                                      }
{                                                                              }
type
  TSqlSetLocalVariableStatement = class(ASqlStatement)
  protected
    FName      : AnsiString;
    FValueExpr : ASqlValueExpression;

  public
    destructor Destroy; override;

    property  Name: AnsiString read FName write FName;
    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;

    procedure TextOutputStructureParameters(const Output: TSqlTextOutput); override;
    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    procedure Iterate(const Proc: TSqlNodeIterateProc); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlDynamicOpenStatement                                                     }
{   OPEN Statement.                                                            }
{                                                                              }
type
  TSqlDynamicOpenStatement = class(ASqlStatement)
  protected
    FCursorName  : ASqlValueExpression;
    FUsingClause : TSqlUsingClause;

  public
    property  CursorName: ASqlValueExpression read FCursorName write FCursorName;
    property  UsingClause: TSqlUsingClause read FUsingClause write FUsingClause;
  end;



{                                                                              }
{ TSqlDynamicCloseStatement                                                    }
{   CLOSE Statement.                                                           }
{                                                                              }
type
  TSqlDynamicCloseStatement = class(ASqlStatement)
  protected
    FCursorName  : ASqlValueExpression;

  public
    property  CursorName: ASqlValueExpression read FCursorName write FCursorName;
  end;



{                                                                              }
{ TSqlDynamicFetchStatement                                                    }
{   FETCH Statement.                                                           }
{                                                                              }
type
  TSqlFetchOrientation = (sfoUndefined, sfoNext, sfoPrior, sfoFirst, sfoLast,
      sfoAbsolute, sfoRelative);
  TSqlFetchType = (sftUndefined, sftNormal, sftDynamic);
  TSqlFetchStatement = class(ASqlStatement)
  protected
    FFetchType   : TSqlFetchType;
    FCursorName  : ASqlValueExpression;
    FOrientation : TSqlFetchOrientation;
    FValue       : ASqlValueExpression;
    FUsingClause : TSqlUsingClause;
    FTargetList  : ASqlValueExpressionArray;

  public
    property  FetchType: TSqlFetchType read FFetchType write FFetchType;
    property  CursorName: ASqlValueExpression read FCursorName write FCursorName;
    property  Orientation: TSqlFetchOrientation read FOrientation write FOrientation;
    property  Value: ASqlValueExpression read FValue write FValue;
    property  UsingClause: TSqlUsingClause read FUsingClause write FUsingClause;
    property  TargetList: ASqlValueExpressionArray read FTargetList write FTargetList;
  end;



{                                                                              }
{ TSqlAllocateCursorStatement                                                  }
{   ALLOCATE Statement.                                                        }
{                                                                              }
type
  TSqlAllocateCursorStatement = class(ASqlStatement)
  protected
    FCursorName         : ASqlValueExpression;
    FInsensitive        : Boolean;
    FScroll             : Boolean;
    FStatementNameScope : TSqlScopeOption;
    FStatementNameValue : ASqlValueExpression;

  public
    property  CursorName: ASqlValueExpression read FCursorName write FCursorName;
    property  Insensitive: Boolean read FInsensitive write FInsensitive;
    property  Scroll: Boolean read FScroll write FScroll;
    property  StatementNameScope: TSqlScopeOption read FStatementNameScope write FStatementNameScope;
    property  StatementNameValue: ASqlValueExpression read FStatementNameValue write FStatementNameValue;
  end;



{                                                                              }
{ TSqlAlterTableStatement                                                      }
{   ALTER TABLE Statement.                                                     }
{                                                                              }
type
  TSqlAlterTableAction = (satUndefined, satAddColumn, satAlterColumnSetDefault,
      satAlterColumnDropDefault, satDropColumn, satAddTableConstraint,
      satDropTableConstraint);
  TSqlAlterTableStatement = class(ASqlStatement)
  protected
    FTableName        : AnsiString;
    FAction           : TSqlAlterTableAction;
    FColumnDefinition : TSqlColumnDefinitionEx;
    FTableConstraint  : TSqlTableConstraint;
    FColumnName       : AnsiString;
    FDropBehavior     : TSqlDropBehavior;
    FConstraintName   : AnsiString;
    FDefaultClause    : ASqlValueExpression;

  public
    property  TableName: AnsiString read FTableName write FTableName;
    property  Action: TSqlAlterTableAction read FAction write FAction;
    property  ColumnDefinition: TSqlColumnDefinitionEx read FColumnDefinition write FColumnDefinition;
    property  TableConstraint: TSqlTableConstraint read FTableConstraint write FTableConstraint;
    property  ColumnName: AnsiString read FColumnName write FColumnName;
    property  DropBehavior: TSqlDropBehavior read FDropBehavior write FDropBehavior;
    property  ConstraintName: AnsiString read FConstraintName write FConstraintName;
    property  DefaultClause: ASqlValueExpression read FDefaultClause write FDefaultClause;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlSetTransactionStatement                                                  }
{   SET TRANSACTION Statement.                                                 }
{                                                                              }
type
  TSqlTransactionMode = class
  protected
    FIsolationLevel  : TSqlLevelOfIsolation;
    FAccessMode      : TSqlTransactionAccessMode;
    FDiagnosticsSize : ASqlValueExpression;

  public
    property  IsolationLevel: TSqlLevelOfIsolation read FIsolationLevel write FIsolationLevel;
    property  AccessMode: TSqlTransactionAccessMode read FAccessMode write FAccessMode;
    property  DiagnosticsSize: ASqlValueExpression read FDiagnosticsSize write FDiagnosticsSize;
  end;
  TSqlTransactionModeArray = Array of TSqlTransactionMode;

  TSqlSetTransactionStatement = class(ASqlTransactionStatement)
  protected
    FTransactionModes : TSqlTransactionModeArray;

  public
    property  TransactionModes: TSqlTransactionModeArray read FTransactionModes write FTransactionModes;
  end;



{                                                                              }
{ TSqlSetConstraintsModeStatement                                              }
{   SET CONSTRAINTS Statement.                                                 }
{                                                                              }
type
  TSqlSetConstraintsModeStatement = class(ASqlStatement)
  protected
    FAll       : Boolean;
    FNameList  : AnsiStringArray;
    FDeferred  : Boolean;
    FImmediate : Boolean;

  public
    property  All: Boolean read FAll write FAll;
    property  NameList: AnsiStringArray read FNameList write FNameList;
    property  Deferred: Boolean read FDeferred write FDeferred;
    property  Immediate: Boolean read FImmediate write FImmediate;
  end;



{                                                                              }
{ TSqlGrantStatement                                                           }
{                                                                              }
type
  TSqlGrantAction = (sgaUndefined, sgaSELECT, sgaDELETE, sgaINSERT, sgaUPDATE,
      sgaREFERENCES, sgaUSAGE);
  TSqlAction = class
    Action  : TSqlGrantAction;
    Columns : AnsiStringArray;
  end;
  TSqlActionArray = Array of TSqlAction;
  TSqlPrivileges = class
    AllPrivileges : Boolean;
    ActionList    : TSqlActionArray;
  end;
  TSqlGrantee = class
    GrantPublic   : Boolean;
    Authorization : AnsiString;
  end;
  TSqlGranteeArray = Array of TSqlGrantee;
  TSqlObjectType = (sotUndefined, sotTABLE, sotDOMAIN, sotCOLLATION,
      sotCHARACTERSET, sotTRANSLATION);
  TSqlObjectName = class
    ObjType : TSqlObjectType;
    Name    : AnsiString;
  end;
  TSqlGrantStatement = class(ASqlStatement)
  protected
    FPrivileges   : TSqlPrivileges;
    FGrantees     : TSqlGranteeArray;
    FObjName      : TSqlObjectName;
    FWithGrantOpt : Boolean;

  public
    property  Privileges: TSqlPrivileges read FPrivileges write FPrivileges;
    property  Grantees: TSqlGranteeArray read FGrantees write FGrantees;
    property  ObjName: TSqlObjectName read FObjName write FObjName;
    property  WithGrantOpt: Boolean read FWithGrantOpt write FWithGrantOpt;
  end;



{                                                                              }
{ TSqlRevokeStatement                                                          }
{                                                                              }
type
  TSqlRevokeStatement = class(ASqlStatement)
  protected
    FPrivileges   : TSqlPrivileges;
    FObjName      : TSqlObjectName;
    FGrantees     : TSqlGranteeArray;
    FDropBehavior : TSqlDropBehavior;

  public
    property  Privileges: TSqlPrivileges read FPrivileges write FPrivileges;
    property  ObjName: TSqlObjectName read FObjName write FObjName;
    property  Grantees: TSqlGranteeArray read FGrantees write FGrantees;
    property  DropBehavior: TSqlDropBehavior read FDropBehavior write FDropBehavior;
  end;



{                                                                              }
{ TSqlViewDefinitionStatement                                                  }
{                                                                              }
type
  TSqlViewDefinitionStatement = class(ASqlStatement)
  protected
    FTableName    : AnsiString;
    FViewColumns  : AnsiStringArray;
    FQueryExpr    : ASqlQueryExpression;
    FWithCheckOpt : Boolean;
    FCascaded     : Boolean;
    FLocal        : Boolean;

  public
    property  TableName: AnsiString read FTableName write FTableName;
    property  ViewColumns: AnsiStringArray read FViewColumns write FViewColumns;
    property  QueryExpr: ASqlQueryExpression read FQueryExpr write FQueryExpr;
    property  WithCheckOpt: Boolean read FWithCheckOpt write FWithCheckOpt;
    property  Cascaded: Boolean read FCascaded write FCascaded;
    property  Local: Boolean read FLocal write FLocal;
  end;



{                                                                              }
{ TSqlAssertionDefinitionStatement                                             }
{                                                                              }
type
  TSqlAssertionDefinitionStatement = class(ASqlStatement)
  protected
    FConstraintName : AnsiString;
    FCondition      : ASqlSearchCondition;
    FConstraintAttr : TSqlConstraintAttributes;

  public
    property  ConstraintName: AnsiString read FConstraintName write FConstraintName;
    property  Condition: ASqlSearchCondition read FCondition write FCondition;
    property  ConstraintAttr: TSqlConstraintAttributes read FConstraintAttr write FConstraintAttr;
  end;



{                                                                              }
{ TSqlDomainDefinitionStatement                                                }
{                                                                              }
type
  TSqlDomainConstraint = class
    ConstraintName  : AnsiString;
    CheckConstraint : TSqlCheckConstraint;
    ConstraintAttr  : TSqlConstraintAttributes;
  end;
  TSqlDomainConstraintArray = Array of TSqlDomainConstraint;
  TSqlDomainDefinitionStatement = class(ASqlStatement)
  protected
    FDomainName        : AnsiString;
    FDataType          : TSqlDataTypeDefinition;
    FDefaultClause     : ASqlValueExpression;
    FDomainConstraints : TSqlDomainConstraintArray;
    FCollateClause     : AnsiString;

  public
    property  DomainName: AnsiString read FDomainName write FDomainName;
    property  DataType: TSqlDataTypeDefinition read FDataType write FDataType;
    property  DefaultClause: ASqlValueExpression read FDefaultClause write FDefaultClause;
    property  DomainConstraints: TSqlDomainConstraintArray read FDomainConstraints write FDomainConstraints;
    property  CollateClause: AnsiString read FCollateClause write FCollateClause;
  end;



{                                                                              }
{ TSqlTranslationDefinitionStatement                                           }
{                                                                              }
type
  TSqlTranslationSpecification = class
    Identity : Boolean;
    Name     : AnsiString;
  end;
  TSqlTranslationDefinitionStatement = class(ASqlStatement)
  protected
    FTranslationName : AnsiString;
    FForName         : AnsiString;
    FToName          : AnsiString;
    FTranslationSpec : TSqlTranslationSpecification;

  public
    property  TranslationName: AnsiString read FTranslationName write FTranslationName;
    property  ForName: AnsiString read FForName write FForName;
    property  ToName: AnsiString read FToName write FToName;
    property  TranslationSpec: TSqlTranslationSpecification read FTranslationSpec write FTranslationSpec;
  end;



{                                                                              }
{ TSqlDatabaseDefinitionStatement                                              }
{                                                                              }
type
  TSqlDatabaseDefinitionFileSpec = class
  protected
    FLogicalFileName : AnsiString;
    FOSFileName      : AnsiString;

  public
    property  LogicalFileName: AnsiString read FLogicalFileName write FLogicalFileName;
    property  OSFileName: AnsiString read FOSFileName write FOSFileName;

    procedure TextOutputSql(const Output: TSqlTextOutput);
  end;

  TSqlDatabaseDefinitionStatement = class(ASqlStatement)
  protected
    FDatabaseName : AnsiString;
    FPrimary      : Boolean;
    FFileSpec     : TSqlDatabaseDefinitionFileSpec;
    
  public
    property  DatabaseName: AnsiString read FDatabaseName write FDatabaseName;
    property  Primary: Boolean read FPrimary write FPrimary;
    property  FileSpec: TSqlDatabaseDefinitionFileSpec read FFileSpec write FFileSpec;

    procedure TextOutputSql(const Output: TSqlTextOutput); override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlLoginDefinitionStatement                                                 }
{                                                                              }
type
  TSqlLoginDefinitionStatement = class(ASqlStatement)
  protected
    FLoginName : AnsiString;
    FPassword  : AnsiString;
    
  public
    property  LoginName: AnsiString read FLoginName write FLoginName;
    property  Password: AnsiString read FPassword write FPassword;

    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlUserDefinitionStatement                                                  }
{                                                                              }
type
  TSqlUserDefinitionStatement = class(ASqlStatement)
  protected
    FUserName  : AnsiString;
    FLoginName : AnsiString;

  public
    property  UserName: AnsiString read FUserName write FUserName;
    property  LoginName: AnsiString read FLoginName write FLoginName;

    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlSchemaDefinitionStatement                                                }
{                                                                              }
type
  TSqlSchemaNameClause = class
    SchemaName     : AnsiString;
    AuthIdentifier : AnsiString;
  end;
  TSqlSchemaDefinitionStatement = class(ASqlStatement)
  protected
    FSchemaName  : TSqlSchemaNameClause;
    FCharSetSpec : AnsiString;
    FElements    : ASqlStatementArray;

  public
    property  SchemaName: TSqlSchemaNameClause read FSchemaName write FSchemaName;
    property  CharSetSpec: AnsiString read FCharSetSpec write FCharSetSpec;
    property  Elements: ASqlStatementArray read FElements write FElements;
  end;



{                                                                              }
{ TSqlCollationDefinitionStatement                                             }
{                                                                              }
type
  TSqlCollationSourceType = (scsUndefined, scsTranslation, scsExternal,
      scsDesc, scsDefault, scsSchemaCollation);
  TSqlCollationSource = class
    SourceType       : TSqlCollationSourceType;
    TranslationName  : AnsiString;
    RefCollationName : AnsiString;
  end;
  TSqlCollationDefinitionStatement = class(ASqlStatement)
  protected
    FCollationName   : AnsiString;
    FForSpec         : AnsiString;
    FCollationSource : TSqlCollationSource;
    FPadSpace        : Boolean;
    FSchemaCollation : AnsiString;

  public
    property  CollationName: AnsiString read FCollationName write FCollationName;
    property  ForSpec: AnsiString read FForSpec write FForSpec;
    property  CollationSource: TSqlCollationSource read FCollationSource write FCollationSource;
    property  PadSpace: Boolean read FPadSpace write FPadSpace;
    property  SchemaCollation: AnsiString read FSchemaCollation write FSchemaCollation;
  end;



{                                                                              }
{ TSqlSessionSetStatement                                                      }
{                                                                              }
type
  TSqlSessionSetType = (sstUndefined, sstSessionAuthorization, sstNames,
      sstSchema, sstCatalog);
  TSqlSessionSetStatement = class(ASqlStatement)
  protected
    FSetType : TSqlSessionSetType;
    FValue   : ASqlValueExpression;

  public
    constructor CreateEx(const SetType : TSqlSessionSetType;
                const Value: ASqlValueExpression);

    property  SetType: TSqlSessionSetType read FSetType write FSetType;
    property  Value: ASqlValueExpression read FValue write FValue;
  end;



{                                                                              }
{ TSqlDeclareCursorStatement                                                   }
{                                                                              }
type
  TSqlUpdatabilityType = (sucUndefined, sucReadOnly, sucUpdate);
  TSqlUpdatabilityClause = class
    UpdatabilityType : TSqlUpdatabilityType;
    ColumnNameList   : AnsiStringArray;
  end;
  TSqlCursorSpecification = class
    QueryExpr    : ASqlQueryExpression;
    OrderBy      : TSqlSortSpecificationArray;
    Updatability : TSqlUpdatabilityClause;
  end;
  TSqlDeclareCursorStatement = class(ASqlStatement)
  protected
    FCursorName    : AnsiString;
    FInsensitive   : Boolean;
    FScroll        : Boolean;
    FCursorSpec    : TSqlCursorSpecification;
    FStatementName : AnsiString;

  public
    property  CursorName: AnsiString read FCursorName write FCursorName;
    property  Insensitive: Boolean read FInsensitive write FInsensitive;
    property  Scroll: Boolean read FScroll write FScroll;
    property  CursorSpec: TSqlCursorSpecification read FCursorSpec write FCursorSpec;
    property  StatementName: AnsiString read FStatementName write FStatementName;
  end;



{                                                                              }
{ TSqlTemporaryTableDeclaration                                                }
{                                                                              }
type
  TSqlTemporaryTableDeclaration = class(ASqlStatement)
  protected
    FTableName    : AnsiString;
    FElements     : TSqlTableElementArray;
    FCommitAction : TSqlTableCommitAction;

  public
    property  TableName: AnsiString read FTableName write FTableName;
    property  Elements: TSqlTableElementArray read FElements write FElements;
    property  CommitAction: TSqlTableCommitAction read FCommitAction write FCommitAction;
  end;



{                                                                              }
{ TSqlAlterDomainStatement                                                     }
{                                                                              }
type
  TSqlAlterDomainType = (sadUndefined, sadSet, sadAdd, sadDropConstraint,
      sadDropDefault);
  TSqlAlterDomainStatement = class(ASqlStatement)
  protected
    FAlterType        : TSqlAlterDomainType;
    FDomainName       : AnsiString;
    FConstraintName   : AnsiString;
    FDomainConstraint : TSqlDomainConstraint;
    FDefaultClause    : ASqlValueExpression;

  public
    property  AlterType: TSqlAlterDomainType read FAlterType write FAlterType;
    property  DomainName: AnsiString read FDomainName write FDomainName;
    property  ConstraintName: AnsiString read FConstraintName write FConstraintName;
    property  DomainConstraint: TSqlDomainConstraint read FDomainConstraint write FDomainConstraint;
    property  DefaultClause: ASqlValueExpression read FDefaultClause write FDefaultClause;
  end;



{                                                                              }
{ TSqlEmbeddedSqlStatement                                                     }
{                                                                              }
type
  TSqlEmbeddedSqlStatement = class(ASqlStatement)
  protected
    FSQLStatement : ASqlStatement;
  public
    property  SQLStatement: ASqlStatement read FSQLStatement write FSQLStatement;
  end;



{                                                                              }
{ TSqlEmbeddedExceptionDeclaration                                             }
{                                                                              }
type
  TSqlExceptionConditionActionType = (seaUndefined, seaContinue, seaGoTo);
  TSqlExceptionConditionAction = class
    ActionType : TSqlExceptionConditionActionType;
    Identifier : AnsiString;
    Index      : Integer;
  end;

  TSqlExceptionCondition = (
      secUndefined,
      secSqlError,
      secNotFound);
  TSqlEmbeddedExceptionDeclaration = class(ASqlStatement)
  protected
    FCondition : TSqlExceptionCondition;
    FAction    : TSqlExceptionConditionAction;

  public
    property  Condition: TSqlExceptionCondition read FCondition write FCondition;
    property  Action: TSqlExceptionConditionAction read FAction write FAction;
  end;



{                                                                              }
{ TSqlDiagnosticsStatement                                                     }
{                                                                              }
type
  TSqlStatementInformationItem = class
    TargetSpec : ASqlValueExpression;
    ItemName   : AnsiString;
  end;
  TSqlStatementInformationItemArray = Array of TSqlStatementInformationItem;
  TSqlStatementInformation = class
    Items : TSqlStatementInformationItemArray;
  end;
  TSqlConditionInformationItem = class
    TargetSpec : ASqlValueExpression;
    ItemName   : AnsiString;
  end;
  TSqlConditionInformationItemArray = Array of TSqlConditionInformationItem;
  TSqlConditionInformation = class
    ConditionNumber : ASqlValueExpression;
    Items           : TSqlConditionInformationItemArray;
  end;
  TSqlDiagnosticsStatement = class(ASqlStatement)
  protected
    FStatementInformation : TSqlStatementInformation;
    FConditionInformation : TSqlConditionInformation;

  public
    property  StatementInformation: TSqlStatementInformation read FStatementInformation write FStatementInformation;
    property  ConditionInformation: TSqlConditionInformation read FConditionInformation write FConditionInformation;
  end;



{                                                                              }
{ TSqlDescribeStatement                                                        }
{                                                                              }
type
  TSqlDescribeType = (sdeUndefined, sdeInput, sdeOutput);
  TSqlDescribeStatement = class(ASqlStatement)
  protected
    FDescribeType  : TSqlDescribeType;
    FStatementName : TSqlStatementName;
    FUsing         : TSqlDescriptorName;

  public
    property  DescribeType: TSqlDescribeType read FDescribeType write FDescribeType;
    property  StatementName: TSqlStatementName read FStatementName write FStatementName;
    property  Using: TSqlDescriptorName read FUsing write FUsing;
  end;



{                                                                              }
{ TSqlAllocateDescriptorStatement                                              }
{                                                                              }
type
  TSqlAllocateDescriptorStatement = class(ASqlStatement)
  protected
    FDescriptorName : TSqlDescriptorName;
    FMaxOccurrences : ASqlValueExpression;

  public
    property  DescriptorName: TSqlDescriptorName read FDescriptorName write FDescriptorName;
    property  MaxOccurrences: ASqlValueExpression read FMaxOccurrences write FMaxOccurrences;
  end;



{                                                                              }
{ TSqlDeallocateDescriptorStatement                                            }
{                                                                              }
type
  TSqlDeallocateDescriptorStatement = class(ASqlStatement)
  protected
    FDescriptorName : TSqlDescriptorName;

  public
    property  DescriptorName: TSqlDescriptorName read FDescriptorName write FDescriptorName;
  end;



{                                                                              }
{ TSqlSetDescriptorStatement                                                   }
{                                                                              }
type
  TSqlSetItemInformation = class
    Identifier : AnsiString;
    Value      : ASqlValueExpression;
  end;
  TSqlSetItemInformationArray = Array of TSqlSetItemInformation;
  TSqlSetDescriptorInformation = class
    ItemNumber : ASqlValueExpression;
    Items      : TSqlSetItemInformationArray;
    CountValue : ASqlValueExpression;
  end;
  TSqlSetDescriptorStatement = class(ASqlStatement)
  protected
    FDescriptorName : TSqlDescriptorName;
    FDescriptorInfo : TSqlSetDescriptorInformation;

  public
    property  DescriptorName: TSqlDescriptorName read FDescriptorName write FDescriptorName;
    property  DescriptorInfo: TSqlSetDescriptorInformation read FDescriptorInfo write FDescriptorInfo;
  end;


{                                                                              }
{ TSqlGetDescriptorStatement                                                   }
{                                                                              }
type
  TSqlGetItemInformation = class
    TargetSpec : ASqlValueExpression;
    ItemName   : AnsiString;
  end;
  TSqlGetItemInformationArray = Array of TSqlGetItemInformation;
  TSqlGetDescriptorInformation = class
    ItemNumber : ASqlValueExpression;
    Items      : TSqlGetItemInformationArray;
    CountValue : ASqlValueExpression;
  end;
  TSqlGetDescriptorStatement = class(ASqlStatement)
  protected
    FDescriptorName : TSqlDescriptorName;
    FDescriptorInfo : TSqlGetDescriptorInformation;

  public
    property  DescriptorName: TSqlDescriptorName read FDescriptorName write FDescriptorName;
    property  DescriptorInfo: TSqlGetDescriptorInformation read FDescriptorInfo write FDescriptorInfo;
  end;



{                                                                              }
{ TSqlPrepareStatement                                                         }
{                                                                              }
type
  TSqlPrepareStatement = class(ASqlStatement)
  protected
    FStatementName : TSqlStatementName;
    FVariable      : ASqlValueExpression;

  public
    property  StatementName: TSqlStatementName read FStatementName write FStatementName;
    property  Variable: ASqlValueExpression read FVariable write FVariable;
  end;



{                                                                              }
{ TSqlDeallocatePrepareStatement                                               }
{                                                                              }
type
  TSqlDeallocatePrepareStatement = class(ASqlStatement)
  protected
    FStatementName : TSqlStatementName;

  public
    property  StatementName: TSqlStatementName read FStatementName write FStatementName;
  end;



{                                                                              }
{ TSqlSetLocalTimeZoneStatement                                                }
{                                                                              }
type
  TSqlSetLocalTimeZoneStatement = class(ASqlStatement)
  protected
    FLocal     : Boolean;
    FZoneValue : ASqlValueExpression;

  public
    property  Local: Boolean read FLocal write FLocal;
    property  ZoneValue: ASqlValueExpression read FZoneValue write FZoneValue;
  end;



{                                                                              }
{ TSqlCharacterSetDefinition                                                   }
{                                                                              }
type
  TSqlCharacterSetDefinition = class(ASqlStatement)
  protected
    FCharSetName     : AnsiString;
    FSourceCharSet   : AnsiString;
    FCollateClause   : AnsiString;
    FCollationSource : TSqlCollationSource;

  public
    property  CharSetName: AnsiString read FCharSetName write FCharSetName;
    property  SourceCharSet: AnsiString read FSourceCharSet write FSourceCharSet;
    property  CollateClause: AnsiString read FCollateClause write FCollateClause;
    property  CollationSource: TSqlCollationSource read FCollationSource write FCollationSource;
  end;



implementation

uses
  { System }
  SysUtils,

  { Fundamentals }
  cStrings,

  { SQL }
  cSQLLexer;



{                                                                              }
{ ASqlStatementList                                                            }
{                                                                              }
constructor ASqlStatementList.CreateEx(const List: ASqlStatementArray);
begin
  inherited Create;
  FList := List;
end;

destructor ASqlStatementList.Destroy;
begin
  FreeAndNilObjectArray(ObjectArray(FList));
  inherited Destroy;
end;

procedure ASqlStatementList.TextOutputStructureParameters(const Output: TSqlTextOutput);
var I : Integer;
begin
  inherited TextOutputStructureParameters(Output);
  for I := 0 to Length(FList) - 1 do
    FList[I].TextOutputStructure(Output);
end;

procedure ASqlStatementList.Iterate(const Proc: TSqlNodeIterateProc);
var I : Integer;
begin
  for I := 0 to Length(FList) - 1 do
    begin
      Proc(self, FList[I]);
      FList[I].Iterate(Proc);
    end;
end;

function ASqlStatementList.Simplify: ASqlStatement;
var I, L : Integer;
begin
  L := Length(FList);
  // simplify individual statements
  for I := 0 to L - 1 do
    FList[I] := FList[I].Simplify;
  // remove empty items
  for I := L - 1 downto 0 do
    if not Assigned(FList[I]) then
      Remove(ObjectArray(FList), I, 1, False);
  // return result
  L := Length(FList);
  if L = 0 then
    begin
      Result := nil;
      Destroy;
    end else
  if L = 1 then
    begin
      Result := FList[0];
      FList[0] := nil;
      Destroy;
    end
  else
    Result := self;
end;

function ASqlStatementList.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var I : Integer;
    R : ASqlCursor;
    S : ASqlStatement;
begin
  Result := nil;
  try
    for I := 0 to Length(FList) - 1 do
      begin
        S := FList[I];
        S.Prepare(Engine, Scope);
        R := S.Execute(Engine, Scope);
        if Assigned(R) then
          begin
            FreeAndNil(Result);
            Result := R;
          end;
      end;
  except
    Result.Free;
    raise;
  end;
end;

procedure ASqlStatementList.Add(const Statement: ASqlStatement);
begin
  Assert(Assigned(Statement));
  Append(ObjectArray(FList), Statement);
end;



{                                                                              }
{ TSqlStatementSequence                                                        }
{                                                                              }
procedure TSqlStatementSequence.TextOutputSql(const Output: TSqlTextOutput);
var I : Integer;
begin
  Assert(Assigned(Output));
  with Output do
    for I := 0 to Length(FList) - 1 do
      begin
        if I > 0 then
          NewLine(2);
        FList[I].TextOutputSql(Output);
        NewLine;
        Keyword(SQL_KEYWORD_GO);
      end;
end;



{                                                                              }
{ TSqlStatementBlock                                                           }
{                                                                              }
procedure TSqlStatementBlock.TextOutputSql(const Output: TSqlTextOutput);
var I : Integer;
begin
  Assert(Assigned(Output));
  with Output do
    begin
      Keyword(SQL_KEYWORD_BEGIN);
      NewLine;
      for I := 0 to Length(FList) - 1 do
        begin
          FList[I].TextOutputSql(Output);
          NewLine;
        end;
      Keyword(SQL_KEYWORD_END);
      NewLine;
    end;
end;



{                                                                              }
{ TSqlConnectStatement                                                         }
{                                                                              }
constructor TSqlConnectStatement.CreateDefault;
begin
  inherited Create;
  FConnectDefault := True;
end;

constructor TSqlConnectStatement.CreateEx(const ServerName, ConnectionName,
    UserName: ASqlValueExpression);
begin
  inherited Create;
  FConnectDefault := False;
  FServerName := ServerName;
  FConnectionName := ConnectionName;
  FUserName := UserName;
end;

procedure TSqlConnectStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  Assert(Assigned(Output));
  with Output do
    begin
      Keyword(SQL_KEYWORD_CONNECT);
      Space;
      Keyword(SQL_KEYWORD_TO);
      Space;
      if FConnectDefault then
        Keyword(SQL_KEYWORD_DEFAULT)
      else
        begin
          FServerName.TextOutputSql(Output);
          if Assigned(FConnectionName) then
            begin
              Space;
              Keyword(SQL_KEYWORD_AS);
              Space;
              FConnectionName.TextOutputSql(Output);
            end;
          if Assigned(FUserName) then
            begin
              Space;
              Keyword(SQL_KEYWORD_USER);
              Space;
              FUserName.TextOutputSql(Output);
            end;
        end;
    end;
end;

function TSqlConnectStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var S, C, U : AnsiString;
    D : ASqlDatabase;
begin
  Assert(Assigned(Engine));
  //
  D := Engine.CurrentDatabase;
  if FConnectDefault then
    D.ConnectDefault
  else
    begin
      S := SqlEvaluateAsString(FServerName, Engine, nil, Scope);
      C := SqlEvaluateAsString(FConnectionName, Engine, nil, Scope);
      U := SqlEvaluateAsString(FUserName, Engine, nil, Scope);
      D.Connect(S, C, U);
    end;
  Result := nil;
end;



{                                                                              }
{ TSqlDisconnectStatement                                                      }
{                                                                              }
procedure TSqlDisconnectStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  Assert(Assigned(Output));
  Output.Keyword(SQL_KEYWORD_DISCONNECT);
end;

function TSqlDisconnectStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  Assert(Assigned(Engine));
  //
  Engine.CurrentDatabase.Disconnect;
  Result := nil;
end;



{                                                                              }
{ TSqlUseStatement                                                             }
{                                                                              }
procedure TSqlUseStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_USE);
      Space;
      Identifier(FDatabaseName);
    end;
end;

function TSqlUseStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  Engine.UseDatabase(FDatabaseName);
  Result := nil;
end;



{                                                                              }
{ TSqlCreateTableStatement                                                     }
{                                                                              }
constructor TSqlCreateTableStatement.Create;
begin
  inherited Create;
//  FColumns := TSqlColumnDefinitionList.Create;
end;

constructor TSqlCreateTableStatement.CreateEx(const TableName: AnsiString;
    const Columns: TSqlColumnDefinitionList);
begin
  inherited Create;
  Assert(FTableName <> '');
  Assert(Assigned(Columns));
  FTableName := TableName;
//  FColumns := Columns;
end;

destructor TSqlCreateTableStatement.Destroy;
begin
//  FreeAndNil(FColumns);
  inherited Destroy;
end;

procedure TSqlCreateTableStatement.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  Output.Identifier(FTableName);
end;

procedure TSqlCreateTableStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  Assert(Assigned(Output));
  with Output do
    begin
      Keyword(SQL_KEYWORD_CREATE);
      Space;
      Keyword(SQL_KEYWORD_TABLE);
      Space;
      Identifier(FTableName);
      Space;
      Symbol('(');
//      FColumns.TextOutputSql(Output);
      Symbol(')');
    end;
end;

function TSqlCreateTableStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var C : TSqlColumnDefinitionList;
    I : Integer;
begin
  Assert(Assigned(Engine));
  C := TSqlColumnDefinitionList.Create;
  C.ColumnOwner := False;
  for I := 0 to Length(ElementList) - 1 do
    if Assigned(ElementList[I].ColumnDefinition) then
      C.Add(ElementList[I].ColumnDefinition);
  Engine.CurrentDatabase.CreateTable(FTableName, C);
  C.Free;
  Result := nil;
end;



{                                                                              }
{ TSqlDropStatement                                                            }
{                                                                              }
function TSqlDropStatement.Execute(const Database: ASqlDatabase; const Scope: ASqlScope): ASqlCursor;
begin
  Result := inherited Execute(Database, Scope);
end;

function TSqlDropStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  Result := nil;
  case FDropType of
    sdtDatabase : Engine.DropDatabase(FIdentifier);
  else
    Result := inherited Execute(Engine, Scope);
  end;
end;



{                                                                              }
{ TSqlDropTableStatement                                                       }
{                                                                              }
constructor TSqlDropTableStatement.CreateEx(const TableName: AnsiString;
    const DropBehavior: TSqlDropBehavior);
begin
  inherited Create;
  Assert(TableName <> '');
  FTableName := TableName;
  FDropBehavior := DropBehavior;
end;

procedure TSqlDropTableStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  Assert(Assigned(Output));
  with Output do
    begin
      Keyword(SQL_KEYWORD_DROP);
      Space;
      Keyword(SQL_KEYWORD_TABLE);
      Space;
      Identifier(FTableName);
      if FDropBehavior <> sdbUndefined then
        begin
          Space;
          Case FDropBehavior of
            sdbCascade  : Keyword(SQL_KEYWORD_CASCADE);
            sdbRestrict : Keyword(SQL_KEYWORD_RESTRICT);
          end;
        end;
    end;
end;

function TSqlDropTableStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  Assert(Assigned(Engine));
  Engine.CurrentDatabase.DropTable(FTableName);
  Result := nil;
end;



{                                                                              }
{ TSqlInsertStatement                                                          }
{                                                                              }
constructor TSqlInsertStatement.CreateEx(const TableName: AnsiString;
    const ColumnList: AnsiStringArray; const QueryExpr: ASqlQueryExpression;
    const DefaultValues: Boolean);
begin
  inherited Create;
  Assert(TableName <> '');
  FTableName := TableName;
  FColumnList := ColumnList;
  FQueryExpr := QueryExpr;
  FDefaultValues := DefaultValues;
end;

destructor TSqlInsertStatement.Destroy;
begin
  FreeAndNil(FQueryExpr);
  inherited Destroy;
end;

procedure TSqlInsertStatement.TextOutputStructureParameters(const Output: TSqlTextOutput);
var I : Integer;
begin
  inherited TextOutputStructureParameters(Output);
  Output.Identifier(FTableName);
  Output.Space;
  for I := 0 to Length(FColumnList) - 1 do
    begin
      Output.Identifier(FColumnList[I]);
      Output.Space;
    end;
  FQueryExpr.TextOutputStructure(Output);
end;

procedure TSqlInsertStatement.TextOutputSql(const Output: TSqlTextOutput);
var I, L : Integer;
begin
  Assert(Assigned(Output));
  with Output do
    begin
      Keyword(SQL_KEYWORD_INSERT);
      Space;
      Keyword(SQL_KEYWORD_INTO);
      Space;
      Identifier(FTableName);
      L := Length(FColumnList);
      if L > 0 then
        begin
          Space;
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
      Space;
      if FDefaultValues then
        begin
          Keyword(SQL_KEYWORD_DEFAULT);
          Space;
          Keyword(SQL_KEYWORD_VALUES);
        end
      else
        begin
          Keyword(SQL_KEYWORD_SELECT);
          Space;
          FQueryExpr.TextOutputSql(Output);
        end;
    end;
end;

procedure TSqlInsertStatement.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FQueryExpr);
  FQueryExpr.Iterate(Proc);
end;

function TSqlInsertStatement.Simplify: ASqlStatement;
begin
  FQueryExpr := FQueryExpr.Simplify;
  Result := self;
end;

procedure TSqlInsertStatement.Prepare(const Database: ASqlDatabase; const Scope: ASqlScope);
begin
  if Assigned(FQueryExpr) then
    FQueryExpr.Prepare(Database, nil, Scope);
end;

function TSqlInsertStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var Q : ASqlCursor;
    T : ASqlTable;
    I : Integer;
    J : Integer;
    L : Integer;
    M : Integer;
    C : TSqlColumnDefinition;
    F : TSqlFieldArray;
    G : TSqlField;
    V : ASqlLiteral;
    R : Boolean;
begin
  Assert(Assigned(Engine));
  Result := nil;
  // Execute query
  Q := FQueryExpr.GetCursor(Engine, nil, Scope);
  if not Assigned(Q) then
    exit;
  try
    if Q.Eof then
      exit;
    // Get field definitions
    T := Engine.CurrentDatabase.GetTable(FTableName);
    L := Length(FColumnList);
    if L = 0 then
      begin
        L := T.Columns.Count;
        SetLength(F, L);
        for I := 0 to L - 1 do
          begin
            C := T.Columns.Item[I];
            V := SqlLiteralClassFromDataType(C.TypeDefinition.DataType).Create;
            G := TSqlField.Create(C, V, True);
            F[I] := G;
          end;
      end
    else
      begin
        SetLength(F, L);
        for I := 0 to L - 1 do
          begin
            C := T.Columns.GetColumnByName(FColumnList[I]);
            V := SqlLiteralClassFromDataType(C.TypeDefinition.DataType).Create;
            G := TSqlField.Create(C, V, True);
            F[I] := G;
          end;
      end;
    try
      // Insert records
      repeat
        for I := 0 to L - 1 do
          F[I].Column.SetDefaultValue(F[I].Value);
        M := Q.FieldCount;
        if M > L then
          raise ESqlStatement.Create('Too many values in row');
        for I := 0 to MinI(M, L) - 1 do
          begin
            G := Q.FieldByIndex[I];
            if G.Column.Name = '' then
              F[I].Value.AssignLiteral(G.Value)
            else
              begin
                R := False;
                for J := 0 to L - 1 do
                  if F[J].Column.IsName(G.Column.Name) then
                    begin
                      F[J].Value.AssignLiteral(G.Value);
                      R := True;
                      break;
                    end;
                if not R then
                  raise ESqlStatement.Create('Field not defined: ' + G.Column.Name);
              end;
          end;
        T.InsertRecord(F);
        Q.Next;
      until Q.Eof;
    finally
      FreeObjectArray(F);
    end;
  finally
    Q.Free;
  end;
end;



{                                                                              }
{ TSqlSelectStatement                                                          }
{                                                                              }
constructor TSqlSelectStatement.CreateEx(const QueryExpr: ASqlQueryExpression;
    const OrderBy: TSqlSortSpecificationArray);
begin
  inherited Create;
  Assert(Assigned(QueryExpr));
  FQueryExpr := QueryExpr;
  FOrderBy := OrderBy;
end;

destructor TSqlSelectStatement.Destroy;
begin
  FreeAndNil(FQueryExpr);
  inherited Destroy;
end;

procedure TSqlSelectStatement.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FQueryExpr.TextOutputStructure(Output);
end;

procedure TSqlSelectStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Keyword(SQL_KEYWORD_SELECT);
  Output.Space;
  FQueryExpr.TextOutputSql(Output);
end;

procedure TSqlSelectStatement.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FQueryExpr);
  FQueryExpr.Iterate(Proc);
end;

function TSqlSelectStatement.Simplify: ASqlStatement;
begin
  FQueryExpr := FQueryExpr.Simplify;
  Result := self;
end;

procedure TSqlSelectStatement.Prepare(const Database: ASqlDatabase; const Scope: ASqlScope);
begin
  FQueryExpr.Prepare(Database, nil, Scope);
end;

function TSqlSelectStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  Result := FQueryExpr.GetCursor(Engine, nil, Scope);
  if Assigned(FOrderBy) then
    Result := Result.OrderBy(FOrderBy); 
end;



{                                                                              }
{ TSqlUpdateSetItem                                                            }
{                                                                              }
constructor TSqlUpdateSetItem.CreateEx(const ColumnName: AnsiString;
    const Value: ASqlValueExpression);
begin
  inherited Create;
  FColumnName := ColumnName;
  FValue := Value;
end;

destructor TSqlUpdateSetItem.Destroy;
begin
  FreeAndNil(FValue);
  inherited Destroy;
end;

procedure TSqlUpdateSetItem.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Identifier(FColumnName);
      Space;
      Symbol('=');
      Space;
      FValue.TextOutputSql(Output);
    end;
end;

procedure TSqlUpdateSetItem.Simplify;
begin
  FValue := FValue.Simplify;
end;



{                                                                              }
{ TSqlUpdateSetList                                                            }
{                                                                              }
destructor TSqlUpdateSetList.Destroy;
begin
  FreeAndNilObjectArray(ObjectArray(FList));
  inherited Destroy;
end;

procedure TSqlUpdateSetList.AddItem(const Item: TSqlUpdateSetItem);
begin
  Append(ObjectArray(FList), Item);
end;

function TSqlUpdateSetList.Count: Integer;
begin
  Result := Length(FList);
end;

function TSqlUpdateSetList.Item(const Idx: Integer): TSqlUpdateSetItem;
begin
  Result := FList[Idx];
end;

procedure TSqlUpdateSetList.TextOutputSql(const Output: TSqlTextOutput);
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

procedure TSqlUpdateSetList.Simplify;
var I : Integer;
begin
  for I := 0 to Length(FList) - 1 do
    FList[I].Simplify;
end;

procedure TSqlUpdateSetList.Execute(const Engine: ASqlDatabaseEngine;
    const Cursor: ASqlCursor);
var I : Integer;
    V : ASqlLiteral;
    T : TSqlUpdateSetItem;
begin
  for I := 0 to Length(FList) - 1 do
    begin
      T := FList[I];
      V := T.FValue.Evaluate(Engine, Cursor, nil);
      Cursor.Field[T.FColumnName].Value.AssignLiteral(V);
      V.ReleaseReference;
    end;
end;



{                                                                              }
{ TSqlUpdateStatement                                                          }
{                                                                              }
constructor TSqlUpdateStatement.CreateEx(const TableName: AnsiString;
    const SetList: TSqlUpdateSetList; const Where: ASqlSearchCondition);
begin
  inherited Create;
  Assert(FTableName <> '');
  Assert(Assigned(SetList));
  FTableName := TableName;
  FSetList := SetList;
  FWhere := Where;
end;

destructor TSqlUpdateStatement.Destroy;
begin
  FreeAndNil(FWhere);
  FreeAndNil(FSetList);
  inherited Destroy;
end;

procedure TSqlUpdateStatement.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  Output.Identifier(FTableName);
  Output.Symbol(',');
  FSetList.TextOutputSql(Output);
  Output.Symbol(',');
  if Assigned(FWhere) then
    FWhere.TextOutputStructure(Output);
end;

procedure TSqlUpdateStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  Assert(Assigned(Output));
  with Output do
    begin
      Keyword(SQL_KEYWORD_UPDATE);
      Space;
      Identifier(FTableName);
      Space;
      Keyword(SQL_KEYWORD_SET);
      Space;
      FSetList.TextOutputSql(Output);
      if Assigned(FWhere) then
        begin
          Space;
          Keyword(SQL_KEYWORD_WHERE);
          Space;
          FWhere.TextOutputSql(Output);
        end;
    end;
end;

procedure TSqlUpdateStatement.Iterate(const Proc: TSqlNodeIterateProc);
begin
  if Assigned(FWhere) then
    begin
      Proc(self, FWhere);
      FWhere.Iterate(Proc);
    end;
end;

function TSqlUpdateStatement.Simplify: ASqlStatement;
begin
  FSetList.Simplify;
  if Assigned(FWhere) then
    FWhere := FWhere.Simplify;
  Result := self;
end;

procedure TSqlUpdateStatement.Prepare(const Database: ASqlDatabase; const Scope: ASqlScope);
begin
  if Assigned(FWhere) then
    FWhere.Prepare(Database, nil, Scope);
end;

function TSqlUpdateStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var T : ASqlTable;
    C : ASqlCursor;
begin
  Assert(Assigned(Engine));
  //
  T := Engine.CurrentDatabase.GetTable(FTableName);
  C := T.GetCursor;
  try
    if Assigned(FWhere) then
      C := FWhere.FilterCursor(Engine.CurrentDatabase, C);
    while not C.Eof do
      begin
        FSetList.Execute(Engine, C);
        C.UpdateRecord;
        C.Next;
      end;
  finally
    C.Free;
  end;
  Result := nil;
end;



{                                                                              }
{ TSqlDeleteStatement                                                          }
{                                                                              }
constructor TSqlDeleteStatement.CreateEx(const TableName: AnsiString;
    const Where: ASqlSearchCondition);
begin
  inherited Create;
  Assert(TableName <> '');
  FTableName := TableName;
  FWhere := Where;
end;

destructor TSqlDeleteStatement.Destroy;
begin
  FreeAndNil(FWhere);
  inherited Destroy;
end;

procedure TSqlDeleteStatement.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  Output.Identifier(FTableName);
  Output.Space;
  if Assigned(FWhere) then
    FWhere.TextOutputStructure(Output);
end;

procedure TSqlDeleteStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  Assert(Assigned(Output));
  with Output do
    begin
      Keyword(SQL_KEYWORD_DELETE);
      Space;
      Keyword(SQL_KEYWORD_FROM);
      Space;
      Identifier(FTableName);
      if Assigned(FWhere) then
        begin
          Space;
          Keyword(SQL_KEYWORD_WHERE);
          Space;
          FWhere.TextOutputSql(Output);
        end;
    end;
end;

procedure TSqlDeleteStatement.Iterate(const Proc: TSqlNodeIterateProc);
begin
  if Assigned(FWhere) then
    begin
      Proc(self, FWhere);
      FWhere.Iterate(Proc);
    end;
end;

function TSqlDeleteStatement.Simplify: ASqlStatement;
begin
  if Assigned(FWhere) then
    FWhere := FWhere.Simplify;
  Result := self;
end;

procedure TSqlDeleteStatement.Prepare(const Database: ASqlDatabase; const Scope: ASqlScope);
begin
  if Assigned(FWhere) then
    FWhere.Prepare(Database, nil, Scope);
end;

function TSqlDeleteStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var T : ASqlTable;
    C : ASqlCursor;
begin
  Assert(Assigned(Engine));
  T := Engine.CurrentDatabase.GetTable(FTableName);
  C := T.GetCursor;
  try
    if Assigned(FWhere) then
      C := FWhere.FilterCursor(Engine, C);
    C.Delete;
  finally
    C.Free;
  end;
  Result := nil;
end;



{                                                                              }
{ TSqlCommitStatement                                                          }
{                                                                              }
procedure TSqlCommitStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Keyword(SQL_KEYWORD_COMMIT);
end;

function TSqlCommitStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  Engine.CurrentDatabase.CommitTransaction;
  Result := nil;
end;



{                                                                              }
{ TSqlRollbackStatement                                                        }
{                                                                              }
procedure TSqlRollbackStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  Output.Keyword(SQL_KEYWORD_ROLLBACK);
end;

function TSqlRollbackStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  Engine.CurrentDatabase.CancelTransaction;
  Result := nil;
end;



{                                                                              }
{ TSqlIfStatement                                                              }
{                                                                              }
procedure TSqlIfStatement.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FCondition.TextOutputStructure(Output);
  FTrueStatement.TextOutputStructure(Output);
  if Assigned(FFalseStatement) then
    FFalseStatement.TextOutputStructure(Output);
end;

procedure TSqlIfStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_IF);
      Space;
      FCondition.TextOutputSql(Output);
      Space;
      FTrueStatement.TextOutputSql(Output);
      if Assigned(FFalseStatement) then
        begin
          Space;
          Keyword(SQL_KEYWORD_ELSE);
          Space;
          FFalseStatement.TextOutputSql(Output);
        end;
    end;
end;

procedure TSqlIfStatement.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FCondition);
  FCondition.Iterate(Proc);
  Proc(self, FTrueStatement);
  FTrueStatement.Iterate(Proc);
  if Assigned(FFalseStatement) then
    begin
      Proc(self, FFalseStatement);
      FFalseStatement.Iterate(Proc);
    end;
end;

function TSqlIfStatement.Simplify: ASqlStatement;
begin
  FCondition := FCondition.Simplify;
  FTrueStatement := FTrueStatement.Simplify;
  if Assigned(FFalseStatement) then
    FFalseStatement := FFalseStatement.Simplify;
  Result := self;
end;

function TSqlIfStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var R : Boolean;
begin
  FCondition.Prepare(Engine.CurrentDatabase, nil, Scope);
  R := FCondition.Match(Engine, nil, Scope);
  if R then
    begin
      FTrueStatement.Prepare(Engine, Scope);
      Result := FTrueStatement.Execute(Engine, Scope);
    end
  else
    if Assigned(FFalseStatement) then
      begin
        FFalseStatement.Prepare(Engine, Scope);
        Result := FFalseStatement.Execute(Engine, Scope);
      end
    else
      Result := nil;
end;



{                                                                              }
{ TSqlWhileStatement                                                           }
{                                                                              }
procedure TSqlWhileStatement.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FCondition.TextOutputStructure(Output);
  FStatement.TextOutputStructure(Output);
end;

procedure TSqlWhileStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_WHILE);
      Space;
      FCondition.TextOutputSql(Output);
      NewLine;
      FStatement.TextOutputSql(Output);
    end;
end;

procedure TSqlWhileStatement.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FCondition);
  FCondition.Iterate(Proc);
  Proc(self, FStatement);
  FStatement.Iterate(Proc);
end;

function TSqlWhileStatement.Simplify: ASqlStatement;
begin
  FCondition := FCondition.Simplify;
  FStatement := FStatement.Simplify;
  Result := self;
end;

function TSqlWhileStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var R : Boolean;
begin
  repeat
    FCondition.Prepare(Engine.CurrentDatabase, nil, Scope);
    R := FCondition.Match(Engine, nil, Scope);
    if not R then
      break;
    FStatement.Prepare(Engine, Scope);
    Result := FStatement.Execute(Engine, Scope);
    FreeAndNil(Result);
  until False;
end;



{                                                                              }
{ TSqlCreateProcedureStatement                                                 }
{                                                                              }
destructor TSqlCreateProcedureStatement.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FDefinition);
end;

function TSqlCreateProcedureStatement.ReleaseDefinition: TSqlProcedureDefinition;
begin
  Result := FDefinition;
  FDefinition := nil;
end;

procedure TSqlCreateProcedureStatement.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  FDefinition.TextOutputStructure(Output);
end;

procedure TSqlCreateProcedureStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  FDefinition.TextOutputSql(Output);
end;

procedure TSqlCreateProcedureStatement.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FDefinition);
  FDefinition.Iterate(Proc);
end;

function TSqlCreateProcedureStatement.Simplify: ASqlStatement;
begin
  FDefinition.Simplify;
  Result := self;
end;

function TSqlCreateProcedureStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var P : TSqlStoredProcedure;
begin
  P := TSqlStoredProcedure.CreateEx(FDefinition, False);
  Engine.CurrentDatabase.CreateProcedure(P.Definition.Name, P);
  P.Free;
  Result := nil;
end;



{                                                                              }
{ TSqlDropProcedureStatement                                                   }
{                                                                              }
constructor TSqlDropProcedureStatement.CreateEx(const ProcName: AnsiString);
begin
  inherited Create;
  Assert(ProcName <> '');
  FProcName := ProcName;
end;

procedure TSqlDropProcedureStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  Assert(Assigned(Output));
  with Output do
    begin
      Keyword(SQL_KEYWORD_DROP);
      Space;
      Keyword(SQL_KEYWORD_PROCEDURE);
      Space;
      Identifier(FProcName);
    end;
end;

function TSqlDropProcedureStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  Assert(Assigned(Engine));
  Engine.CurrentDatabase.DropProcedure(FProcName);
  Result := nil;
end;



{                                                                              }
{ TSqlExecuteStatement                                                         }
{                                                                              }
destructor TSqlExecuteStatement.Destroy;
begin
  FreeObjectArray(FParameters);
  inherited Destroy;
end;

procedure TSqlExecuteStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_EXECUTE);
      Space;
      Identifier(FName);
    end;
end;

function TSqlExecuteStatement.Simplify: ASqlStatement;
var I : Integer;
begin
  for I := 0 to Length(FParameters) - 1 do
    FParameters[I].Simplify;
  Result := self;
end;

function TSqlExecuteStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var V : ASqlStoredProcedure;
    I, L : Integer;
    A : ASqlLiteralArray;
begin
  V := Engine.CurrentDatabase.GetProcedure(FName);
  if not Assigned(V) then
    raise ESqlStatement.Create('Identifier not defined: ' + FName);
  L := Length(FParameters);
  SetLength(A, L);
  for I := 0 to L - 1 do
    A[I] := FParameters[I].Evaluate(Scope);
  try
    Result := V.Execute(Engine, Scope, A);
  finally
    for I := L - 1 downto 0 do
      A[I].ReleaseReference;
  end;
end;



{                                                                              }
{ TSqlDeclareLocalVariableStatement                                            }
{                                                                              }
destructor TSqlDeclareLocalVariableStatement.Destroy;
begin
  FreeAndNil(FTypeDef);
  inherited Destroy;
end;

procedure TSqlDeclareLocalVariableStatement.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  Output.Identifier(FName);
  Output.Space;
  FTypeDef.TextOutputStructure(Output);
end;

procedure TSqlDeclareLocalVariableStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_DECLARE);
      Space;
      Identifier(FName);
      Space;
      FTypeDef.TextOutputSql(Output);
    end;
end;

function TSqlDeclareLocalVariableStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  Assert(Assigned(Scope));
  Scope.AddObject(FName, FTypeDef.CreateLiteralInstance);
  Result := nil;
end;



{                                                                              }
{ TSqlSetLocalVariableStatement                                                }
{                                                                              }
destructor TSqlSetLocalVariableStatement.Destroy;
begin
  FreeAndNil(FValueExpr);
  inherited Destroy;
end;

procedure TSqlSetLocalVariableStatement.TextOutputStructureParameters(const Output: TSqlTextOutput);
begin
  inherited TextOutputStructureParameters(Output);
  Output.Identifier(FName);
  Output.Space;
  FValueExpr.TextOutputStructure(Output);
end;

procedure TSqlSetLocalVariableStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_SET);
      Space;
      Identifier(FName);
      Space;
      Symbol('=');
      Space;
    end;
  FValueExpr.TextOutputSql(Output);
end;

procedure TSqlSetLocalVariableStatement.Iterate(const Proc: TSqlNodeIterateProc);
begin
  Proc(self, FValueExpr);
  FValueExpr.Iterate(Proc);
end;

function TSqlSetLocalVariableStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
var A : ASqlLiteral;
    B : ASqlLiteral;
begin
  Assert(Assigned(Scope));
  A := Scope.RequireLiteral(FName);
  B := FValueExpr.Evaluate(Engine, nil, Scope);
  try
    A.AssignLiteral(B);
  finally
    B.ReleaseReference;
  end;
  Result := nil;
end;



{                                                                              }
{ TSqlAlterTableStatement                                                      }
{                                                                              }
procedure TSqlAlterTableStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_ALTER);
      Space;
      Keyword(SQL_KEYWORD_TABLE);
      Space;
      Identifier(FTableName);
      Space;
      case FAction of
        satAddColumn :
          begin
            Keyword(SQL_KEYWORD_ADD);
            Space;
            Keyword(SQL_KEYWORD_COLUMN);
            Space;
            FColumnDefinition.TextOutputSql(Output);
          end;
        satAlterColumnSetDefault :
          begin
            //
          end;
        satAlterColumnDropDefault :
          begin
            //
          end;
        satDropColumn :
          begin
            Keyword(SQL_KEYWORD_DROP);
            Space;
            Keyword(SQL_KEYWORD_COLUMN);
            Space;
            Identifier(FColumnName);
          end;
        satAddTableConstraint :
          begin
            Keyword(SQL_KEYWORD_ADD);
            Space;
            Keyword(SQL_KEYWORD_CONSTRAINT);
            Space;
            Identifier(FConstraintName);
            //
          end;
        satDropTableConstraint :
          begin
            //
          end;
      end;
    end;
end;

function TSqlAlterTableStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  case FAction of
    satAddColumn : Engine.CurrentDatabase.GetTable(FTableName).AddColumn(FColumnDefinition);
  end;
  Result := nil;
end;



{                                                                              }
{ TSqlDatabaseDefinitionFileSpec                                               }
{                                                                              }
procedure TSqlDatabaseDefinitionFileSpec.TextOutputSql(const Output: TSqlTextOutput);
begin

end;



{                                                                              }
{ TSqlDatabaseDefinitionStatement                                              }
{                                                                              }
function TSqlDatabaseDefinitionStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  Engine.CreateDatabase(FDatabaseName, FFileSpec.FLogicalFileName, -1);
  Result := nil;
end;

procedure TSqlDatabaseDefinitionStatement.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_CREATE);
      Space;
      Keyword(SQL_KEYWORD_DATABASE);
      Space;
      Identifier(DatabaseName);
      FFileSpec.TextOutputSql(Output);
    end;
end;



{                                                                              }
{ TSqlLoginDefinitionStatement                                                 }
{                                                                              }
function TSqlLoginDefinitionStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  raise ESqlStatement.Create('not implemented');
end;



{                                                                              }
{ TSqlUserDefinitionStatement                                                  }
{                                                                              }
function TSqlUserDefinitionStatement.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope): ASqlCursor;
begin
  raise ESqlStatement.Create('not implemented');
end;



{                                                                              }
{ TSqlSessionSetStatement                                                      }
{                                                                              }
constructor TSqlSessionSetStatement.CreateEx(const SetType : TSqlSessionSetType;
    const Value: ASqlValueExpression);
begin
  inherited Create;
  self.SetType := SetType;
  self.Value := Value;
end;



end.

