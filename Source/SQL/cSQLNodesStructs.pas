{******************************************************************************}
(*                                                                            *)
(*    Library:       Fundamentals SQL                                         *)
(*    Description:   SQL nodes helper structures.                             *)
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
(*  Revision history:                                                         *)
(*    2005/04/08  1.00  Initial version.                                      *)
(*                                                                            *)
{******************************************************************************}

{$INCLUDE cSQL.inc}

unit cSQLNodesStructs;

interface

uses
  { SQL }
  cSQLStructs,
  cSQLDatabase,
  cSQLNodes;



{                                                                              }
{ TSqlProcedureDefinition                                                      }
{   SQL Procedure Definition.                                                  }
{                                                                              }
type
  TSqlParameterDefinition = class
  protected
    FName         : AnsiString;
    FTypeDef      : TSqlDataTypeDefinition;
    FVarying      : Boolean;
    FDefaultValue : ASqlLiteral;

  public
    destructor Destroy; override;

    property  Name: AnsiString read FName write FName;
    property  TypeDef: TSqlDataTypeDefinition read FTypeDef write FTypeDef;
    property  Varying: Boolean read FVarying write FVarying;
    property  DefaultValue: ASqlLiteral read FDefaultValue write FDefaultValue;

    procedure TextOutputSql(const Output: TSqlTextOutput);
  end;
  TSqlParameterDefinitionArray = Array of TSqlParameterDefinition;

  TSqlProcedureDefinition = class
  protected
    FName        : AnsiString;
    FParameters  : TSqlParameterDefinitionArray;
    FStatements  : ASqlStatementArray;

  public
    destructor Destroy; override;

    property  Name: AnsiString read FName write FName;
    property  Parameters: TSqlParameterDefinitionArray read FParameters write FParameters;
    property  Statements: ASqlStatementArray read FStatements write FStatements;

    procedure TextOutputStructure(const Output: TSqlTextOutput);
    procedure TextOutputSql(const Output: TSqlTextOutput);
    procedure Iterate(const Proc: TSqlNodeIterateProc);
    procedure Simplify;
  end;



{                                                                              }
{ TSqlStoredProcedure                                                          }
{   SQL Stored Procedure implementation.                                       }
{                                                                              }
type
  TSqlStoredProcedure = class(ASqlStoredProcedure)
  protected
    FDefinition      : TSqlProcedureDefinition;
    FDefinitionOwner : Boolean;

  public
    constructor CreateEx(const Definition: TSqlProcedureDefinition;
                const DefinitionOwner: Boolean);
    destructor Destroy; override;

    property  Definition: TSqlProcedureDefinition read FDefinition write FDefinition;

    function  GetAsString: AnsiString; override;
    function  Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope;
              const Parameters: ASqlLiteralArray): ASqlCursor; override;
  end;



{                                                                              }
{ TSqlParameterValue                                                           }
{   SQL Procedure Parameter Value.                                             }
{                                                                              }
type
  TSqlParameterValue = class
  protected
    FName      : AnsiString;
    FValueExpr : ASqlValueExpression;

  public
    constructor CreateEx(const Name: AnsiString; const ValueExpr: ASqlValueExpression);
    destructor Destroy; override;

    property  Name: AnsiString read FName write FName;
    property  ValueExpr: ASqlValueExpression read FValueExpr write FValueExpr;

    procedure Simplify;
    function  Evaluate(const Scope: ASqlScope): ASqlLiteral;
  end;
  TSqlParameterValueArray = Array of TSqlParameterValue;



implementation

uses
  { System }
  SysUtils,

  { Fundamentals }
  cUtils,

  { SQL }
  cSQLUtils,
  cSQLLexer;



{                                                                              }
{ TSqlParameterDefinition                                                      }
{                                                                              }
destructor TSqlParameterDefinition.Destroy;
begin
  FreeAndNil(FDefaultValue);
  FreeAndNil(FTypeDef);
  inherited Destroy;
end;

procedure TSqlParameterDefinition.TextOutputSql(const Output: TSqlTextOutput);
begin
  with Output do
    begin
      Identifier(FName);
      if Assigned(FTypeDef) then
        begin
          Space;
          FTypeDef.TextOutputSql(Output);
        end;
      if Assigned(FDefaultValue) then
        begin
          Space;
          Symbol('=');
          Space;
          Literal(FDefaultValue.AsSql);
        end;
    end;
end;



{                                                                              }
{ TSqlProcedureDefinition                                                      }
{                                                                              }
destructor TSqlProcedureDefinition.Destroy;
begin
  inherited Destroy;
  FreeObjectArray(FStatements);
  FreeObjectArray(FParameters);
end;

procedure TSqlProcedureDefinition.TextOutputStructure(const Output: TSqlTextOutput);
var I : Integer;
begin
  Output.StructureName(ClassToSqlStructureName(self.ClassType));
  Output.StructureParamBegin(True);
  Output.Identifier(FName);
  Output.Space;
  for I := 0 to Length(FStatements) - 1 do
    FStatements[I].TextOutputStructure(Output);
  Output.StructureParamEnd(True);
end;

procedure TSqlProcedureDefinition.TextOutputSql(const Output: TSqlTextOutput);
var I, L : Integer;
begin
  with Output do
    begin
      Keyword(SQL_KEYWORD_CREATE);
      Space;
      Keyword(SQL_KEYWORD_PROCEDURE);
      Space;
      Identifier(FName);
      L := Length(FParameters);
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
              FParameters[I].TextOutputSql(Output);
            end;
          Symbol(')');
        end;
      Space;
      Keyword(SQL_KEYWORD_AS);
      NewLine;
      for I := 0 to Length(FStatements) - 1 do
        begin
          if I > 0 then
            NewLine;
          FStatements[I].TextOutputSql(Output);
        end;
    end;
end;

procedure TSqlProcedureDefinition.Iterate(const Proc: TSqlNodeIterateProc);
var I : Integer;
begin
  for I := 0 to Length(FStatements) - 1 do
    begin
      Proc(self, FStatements[I]);
      FStatements[I].Iterate(Proc);
    end;
end;

procedure TSqlProcedureDefinition.Simplify;
var I : Integer;
begin
  for I := 0 to Length(FStatements) - 1 do
    FStatements[I] := FStatements[I].Simplify;
end;



{                                                                              }
{ TSqlStoredProcedureScope                                                     }
{                                                                              }
type
  TSqlStoredProcedureScope = class(TSqlMemoryScope)
  protected
  public
  end;



{                                                                              }
{ TSqlStoredProcedure                                                          }
{                                                                              }
constructor TSqlStoredProcedure.CreateEx(const Definition: TSqlProcedureDefinition;
    const DefinitionOwner: Boolean);
begin
  inherited Create;
  Assert(Assigned(Definition));
  FDefinition := Definition;
  FDefinitionOwner := DefinitionOwner;
end;

destructor TSqlStoredProcedure.Destroy;
begin
  if FDefinitionOwner then
    FreeAndNil(FDefinition);
  inherited Destroy;
end;

function TSqlStoredProcedure.GetAsString: AnsiString;
var O : TSqlTextOutput;
begin
  O := TSqlTextOutput.Create;
  try
    FDefinition.TextOutputSql(O);
    Result := O.GetAsString;
  finally
    O.Free;
  end;
end;

function TSqlStoredProcedure.Execute(const Engine: ASqlDatabaseEngine; const Scope: ASqlScope;
    const Parameters: ASqlLiteralArray): ASqlCursor;
var S : TSqlStoredProcedureScope;
    I, L, M : Integer;
    P : TSqlParameterDefinition;
    C : ASqlCursor;
begin
  L := Length(FDefinition.Parameters);
  M := Length(Parameters);
  if M > L then
    raise ESqlStatement.Create('Too many arguments');
  S := TSqlStoredProcedureScope.Create;
  try
    for I := 0 to L - 1 do
      begin
        P := FDefinition.Parameters[I];
        if I < M then
          S.AddObject(P.Name, Parameters[I])
        else
          S.AddObject(P.Name, P.DefaultValue);
      end;
    Result := nil;
    for I := 0 to Length(FDefinition.Statements) - 1 do
      begin
        C := FDefinition.Statements[I].Execute(Engine, S);
        if Assigned(C) then
          begin
            FreeAndNil(Result);
            Result := C;
          end;
      end;
  finally
    S.Free;
  end;
end;



{                                                                              }
{ TSqlParameterValue                                                           }
{                                                                              }
constructor TSqlParameterValue.CreateEx(const Name: AnsiString; const ValueExpr: ASqlValueExpression);
begin
  inherited Create;
  Assert(Assigned(ValueExpr));
  FName := Name;
  FValueExpr := ValueExpr;
end;

destructor TSqlParameterValue.Destroy;
begin
  FreeAndNil(FValueExpr);
  inherited Destroy;
end;

procedure TSqlParameterValue.Simplify;
begin
  FValueExpr := FValueExpr.Simplify;
end;

function TSqlParameterValue.Evaluate(const Scope: ASqlScope): ASqlLiteral;
begin
  Result := FValueExpr.Evaluate(ASqlDatabaseEngine(nil), nil, Scope);
end;



end.

