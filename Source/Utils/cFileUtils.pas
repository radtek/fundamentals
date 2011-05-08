{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 4.00                                        }
{   File name:        cFileUtils.pas                                           }
{   File version:     4.10                                                     }
{   Description:      File name and file system functions                      }
{                                                                              }
{   Copyright:        Copyright © 2002-2010, David J Butler                    }
{                     All rights reserved.                                     }
{                     Redistribution and use in source and binary forms, with  }
{                     or without modification, are permitted provided that     }
{                     the following conditions are met:                        }
{                     Redistributions of source code must retain the above     }
{                     copyright notice, this list of conditions and the        }
{                     following disclaimer.                                    }
{                     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND   }
{                     CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED          }
{                     WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED   }
{                     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          }
{                     PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL     }
{                     THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,    }
{                     INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR             }
{                     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,    }
{                     PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF     }
{                     USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)         }
{                     HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER   }
{                     IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING        }
{                     NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE   }
{                     USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE             }
{                     POSSIBILITY OF SUCH DAMAGE.                              }
{                                                                              }
{   Home page:        http://fundementals.sourceforge.net                      }
{   Forum:            http://sourceforge.net/forum/forum.php?forum_id=2117     }
{   E-mail:           fundamentalslib at gmail.com                             }
{                                                                              }
{ Revision history:                                                            }
{                                                                              }
{   2002/06/01  3.01  Created cFileUtils from cSysUtils.                       }
{   2002/12/12  3.02  Revision.                                                }
{   2005/07/22  4.03  Compilable with FreePascal 2 Win32 i386.                 }
{   2005/08/21  4.04  Compilable with FreePascal 2 Linux i386.                 }
{   2005/09/20  4.05  Improved error handling.                                 }
{   2005/09/21  4.06  Revised for Fundamentals 4.                              }
{   2008/12/30  4.07  Revision.                                                }
{   2009/06/05  4.08  File access functions.                                   }
{   2009/07/30  4.09  File access functions.                                   }
{   2010/06/27  4.10  Compilable with FreePascal 2.4.0 OSX x86-64              }
{                                                                              }
{ Supported compilers:                                                         }
{                                                                              }
{   Borland Delphi 5/6/7/2005/2006/2007 Win32 i386                             }
{   FreePascal 2 Win32 i386                                                    }
{   FreePascal 2 Linux i386                                                    }
{                                                                              }
{******************************************************************************}

{$INCLUDE cDefines.inc}
{$IFDEF FREEPASCAL}
  {$WARNINGS OFF}{$HINTS OFF}
{$ENDIF}
{$IFDEF DELPHI6_UP}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}
unit cFileUtils;

interface

uses
  { System }
  {$IFDEF MSWIN}
  Windows,
  {$ENDIF}
  SysUtils;



{                                                                              }
{ Path functions                                                               }
{                                                                              }
const
  PathSeperator = {$IFDEF UNIX}  '/' {$ENDIF}
                  {$IFDEF MSWIN} '\' {$ENDIF};

function  PathHasDriveLetter(const Path: AnsiString): Boolean;
function  PathIsDriveLetter(const Path: AnsiString): Boolean;
function  PathIsDriveRoot(const Path: AnsiString): Boolean;
function  PathIsRoot(const Path: AnsiString): Boolean;
function  PathIsUNCPath(const Path: AnsiString): Boolean;
function  PathIsAbsolute(const Path: AnsiString): Boolean;
function  PathIsDirectory(const Path: AnsiString): Boolean;
function  PathInclSuffix(const Path: AnsiString;
          const PathSep: AnsiChar = PathSeperator): AnsiString;
function  PathExclSuffix(const Path: AnsiString;
          const PathSep: AnsiChar = PathSeperator): AnsiString;
procedure PathEnsureSuffix(var Path: AnsiString;
          const PathSep: AnsiChar = PathSeperator);
procedure PathEnsureNoSuffix(var Path: AnsiString;
          const PathSep: AnsiChar = PathSeperator);
function  PathCanonical(const Path: AnsiString;
          const PathSep: AnsiChar = PathSeperator): AnsiString;
function  PathExpand(const Path: AnsiString; const BasePath: AnsiString = '';
          const PathSep: AnsiChar = PathSeperator): AnsiString;

function  PathLeftElement(const Path: AnsiString;
          const PathSep: AnsiChar = PathSeperator): AnsiString;
procedure PathSplitLeftElement(const Path: AnsiString;
          var LeftElement, RightPath: AnsiString;
          const PathSep: AnsiChar = PathSeperator);

procedure DecodeFilePath(const FilePath: AnsiString;
          var Path, FileName: AnsiString;
          const PathSep: AnsiChar = PathSeperator);

function  FileNameValid(const FileName: AnsiString): AnsiString;
function  FilePath(const FileName, Path: AnsiString; const BasePath: AnsiString = '';
          const PathSep: AnsiChar = PathSeperator): AnsiString;

function  DirectoryExpand(const Path: AnsiString; const BasePath: AnsiString = '';
          const PathSep: AnsiChar = PathSeperator): AnsiString;

function  UnixPathToWinPath(const Path: AnsiString): AnsiString;
function  WinPathToUnixPath(const Path: AnsiString): AnsiString;



{                                                                              }
{ File errors                                                                  }
{                                                                              }
type
  TFileError = (
    feNone             {$IFDEF SupportEnumValue} = $00 {$ENDIF},
    feInvalidParameter {$IFDEF SupportEnumValue} = $01 {$ENDIF},

    feFileError        {$IFDEF SupportEnumValue} = $10 {$ENDIF},
    feFileOpenError    {$IFDEF SupportEnumValue} = $11 {$ENDIF},
    feFileCreateError  {$IFDEF SupportEnumValue} = $12 {$ENDIF},
    feFileSharingError {$IFDEF SupportEnumValue} = $13 {$ENDIF},
    feFileSeekError    {$IFDEF SupportEnumValue} = $14 {$ENDIF},
    feFileReadError    {$IFDEF SupportEnumValue} = $15 {$ENDIF},
    feFileWriteError   {$IFDEF SupportEnumValue} = $16 {$ENDIF},
    feFileSizeError    {$IFDEF SupportEnumValue} = $17 {$ENDIF},
    feFileExists       {$IFDEF SupportEnumValue} = $18 {$ENDIF},
    feFileDoesNotExist {$IFDEF SupportEnumValue} = $19 {$ENDIF},
    feFileMoveError    {$IFDEF SupportEnumValue} = $1A {$ENDIF},
    feFileDeleteError  {$IFDEF SupportEnumValue} = $1B {$ENDIF},

    feOutOfSpace       {$IFDEF SupportEnumValue} = $20 {$ENDIF},
    feOutOfResources   {$IFDEF SupportEnumValue} = $21 {$ENDIF},
    feInvalidFilePath  {$IFDEF SupportEnumValue} = $22 {$ENDIF},
    feInvalidFileName  {$IFDEF SupportEnumValue} = $23 {$ENDIF},
    feAccessDenied     {$IFDEF SupportEnumValue} = $24 {$ENDIF},
    feDeviceFailure    {$IFDEF SupportEnumValue} = $25 {$ENDIF}
  );

  EFileError = class(Exception)
  private
    FFileError : TFileError;

  public
    constructor Create(const FileError: TFileError; const Msg: string);
    constructor CreateFmt(const FileError: TFileError; const Msg: string; const Args: array of const);

    property FileError: TFileError read FFileError;
  end;



{                                                                              }
{ File operations                                                              }
{                                                                              }
type
  TFileHandle = Integer;

  TFileAccess = (
    faRead,
    faWrite,
    faReadWrite);

  TFileSharing = (
    fsDenyNone,
    fsDenyRead,
    fsDenyWrite,
    fsDenyReadWrite,
    fsExclusive);

  TFileOpenFlags = set of (
    foDeleteOnClose,
    foNoBuffering,
    foWriteThrough,
    foRandomAccessHint,
    foSequentialScanHint,
    foSeekToEndOfFile);

  TFileCreationMode = (
    fcCreateNew,
    fcCreateAlways,
    fcOpenExisting,
    fcOpenAlways,
    fcTruncateExisting);

  TFileSeekPosition = (
    fpOffsetFromStart,
    fpOffsetFromCurrent,
    fpOffsetFromEnd);

  PFileOpenWait = ^TFileOpenWait;
  TFileOpenWaitProcedure = procedure (const FileOpenWait: PFileOpenWait);
  TFileOpenWait = packed record
    Wait           : Boolean;
    UserData       : LongWord;
    Timeout        : Integer;
    RetryInterval  : Integer;
    RetryRandomise : Boolean;
    Callback       : TFileOpenWaitProcedure;
    Aborted        : Boolean;
    {$IFDEF MSWIN}
    Signal         : THandle;
    {$ENDIF}
  end;

function  FileOpenExA(
          const FileName: AnsiString;
          const FileAccess: TFileAccess = faRead;
          const FileSharing: TFileSharing = fsDenyNone;
          const FileOpenFlags: TFileOpenFlags = [];
          const FileCreationMode: TFileCreationMode = fcOpenExisting;
          const FileOpenWait: PFileOpenWait = nil): TFileHandle;

function  FileSeekEx(
          const FileHandle: TFileHandle;
          const FileOffset: Int64;
          const FilePosition: TFileSeekPosition = fpOffsetFromStart): Int64;
function  FileReadEx(
          const FileHandle: TFileHandle;
          var Buf; const BufSize: Integer): Integer;
function  FileWriteEx(
          const FileHandle: TFileHandle;
          const Buf; const BufSize: Integer): Integer;
procedure FileCloseEx(
          const FileHandle: TFileHandle);

function  FileExistsA(const FileName: AnsiString): Boolean;
function  FileGetSizeA(const FileName: AnsiString): Int64;
function  FileGetDateTimeA(const FileName: AnsiString): TDateTime;
function  FileGetDateTime2A(const FileName: AnsiString): TDateTime;
function  FileIsReadOnlyA(const FileName: AnsiString): Boolean;

procedure FileDeleteExA(
          const FileName: AnsiString);
procedure FileRenameExA(
          const OldFileName, NewFileName: AnsiString);

function  ReadFileBufA(
          const FileName: AnsiString;
          var Buf; const BufSize: Integer;
          const FileSharing: TFileSharing = fsDenyNone;
          const FileCreationMode: TFileCreationMode = fcOpenExisting;
          const FileOpenWait: PFileOpenWait = nil): Integer;
function  ReadFileStrA(
          const FileName: AnsiString;
          const FileSharing: TFileSharing = fsDenyNone;
          const FileCreationMode: TFileCreationMode = fcOpenExisting;
          const FileOpenWait: PFileOpenWait = nil): AnsiString;

procedure AppendFileA(
          const FileName: AnsiString;
          const Buf; const BufSize: Integer;
          const FileSharing: TFileSharing;
          const FileCreationMode: TFileCreationMode;
          const FileOpenWait: PFileOpenWait);
procedure AppendFileStrA(
          const FileName: AnsiString;
          const Buf: AnsiString;
          const FileSharing: TFileSharing = fsDenyWrite;
          const FileCreationMode: TFileCreationMode = fcOpenAlways;
          const FileOpenWait: PFileOpenWait = nil);

function  DirectoryEntryExistsA(const Name: AnsiString): Boolean;
function  DirectoryEntrySizeA(const Name: AnsiString): Int64;

function  DirectoryExistsA(const DirectoryName: AnsiString): Boolean;
function  DirectoryGetDateTimeA(const DirectoryName: AnsiString): TDateTime;
procedure DirectoryCreateA(const DirectoryName: AnsiString);


{                                                                              }
{ File / Directory operations                                                  }
{   MoveFile first attempts a rename, then a copy and delete.                  }
{                                                                              }
function  GetFirstFileNameMatching(const FileMask: AnsiString): AnsiString;
function  DirEntryGetAttr(const FileName: AnsiString): Integer;
function  DirEntryIsDirectory(const FileName: AnsiString): Boolean;
function  FileHasAttr(const FileName: AnsiString; const Attr: Word): Boolean;

procedure CopyFile(const FileName, DestName: AnsiString);
procedure MoveFile(const FileName, DestName: AnsiString);
function  DeleteFiles(const FileMask: AnsiString): Boolean;



{$IFDEF MSWIN}
{                                                                              }
{ Logical Drive functions                                                      }
{                                                                              }
type
  TLogicalDriveType = (
      DriveRemovable,
      DriveFixed,
      DriveRemote,
      DriveCDRom,
      DriveRamDisk,
      DriveTypeUnknown);

function  DriveIsValid(const Drive: AnsiChar): Boolean;
function  DriveGetType(const Path: AnsiString): TLogicalDriveType;
function  DriveFreeSpace(const Path: AnsiString): Int64;
{$ENDIF}



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DEBUG}{$IFDEF SELFTEST}
procedure SelfTest;
{$ENDIF}{$ENDIF}



implementation

uses
  { Fundamentals }
  cUtils,
  cStrings
  {$IFDEF UNIX}
  , BaseUnix
  {$IFDEF FREEPASCAL}
  , Unix
  {$ELSE}
  , libc
  {$ENDIF}
  {$ENDIF};

  

{$IFDEF DELPHI6_UP}
  {$WARN SYMBOL_DEPRECATED OFF}
{$ENDIF}


resourcestring
  SCannotOpenFile          = 'Cannot open file: %s: %s';
  SCannotCreateFile        = 'Cannot create file: %s: %s';
  SCannotMoveFile          = 'Cannot move file: %s: %s';
  SFileSizeError           = 'File size error: %s';
  SFileReadError           = 'File read error: %s';
  SFileWriteError          = 'File write error: %s: %s';
  SInvalidFileCreationMode = 'Invalid file creation mode';
  SFileExists              = 'File exists: %s';
  SFileDoesNotExist        = 'File does not exist: %s';
  SInvalidFileHandle       = 'Invalid file handle';
  SInvalidFilePosition     = 'Invalid file position';
  SFileSeekError           = 'File seek error: %s';
  SInvalidFileName         = 'Invalid file name';
  SInvalidPath             = 'Invalid path';
  SFileDeleteError         = 'File delete error: %s';



{                                                                              }
{ Path functions                                                               }
{                                                                              }
function PathHasDriveLetter(const Path: AnsiString): Boolean;
var P: PAnsiChar;
begin
  Result := False;
  if Length(Path) < 2 then
    exit;
  P := Pointer(Path);
  if not (P^ in ['A'..'Z', 'a'..'z']) then
    exit;
  Inc(P);
  if P^ <> ':' then
    exit;
  Result := True;
end;

function PathIsDriveLetter(const Path: AnsiString): Boolean;
begin
  Result := (Length(Path) = 2) and PathHasDriveLetter(Path);
end;

function PathIsDriveRoot(const Path: AnsiString): Boolean;
begin
  Result := (Length(Path) = 3) and PathHasDriveLetter(Path) and
            (Path[3] = '\');
end;

function PathIsRoot(const Path: AnsiString): Boolean;
begin
  Result := ((Length(Path) = 1) and (Path[1] in csSlash)) or
            PathIsDriveRoot(Path);
end;

function PathIsUNCPath(const Path: AnsiString): Boolean;
var P: PAnsiChar;
begin
  Result := False;
  if Length(Path) < 2 then
    exit;
  P := Pointer(Path);
  if P^ <> '\' then
    exit;
  Inc(P);
  if P^ <> '\' then
    exit;
  Result := True;
end;

function PathIsAbsolute(const Path: AnsiString): Boolean;
begin
  if Path = '' then
    Result := False else
  if PathHasDriveLetter(Path) then
    Result := True else
  if PAnsiChar(Pointer(Path))^ in ['\', '/'] then
    Result := True else
    Result := False;
end;

function PathIsDirectory(const Path: AnsiString): Boolean;
var L: Integer;
    P: PAnsiChar;
begin
  L := Length(Path);
  if L = 0 then
    Result := False else
  if (L = 2) and PathHasDriveLetter(Path) then
    Result := True else
    begin
      P := Pointer(Path);
      Inc(P, L - 1);
      Result := P^ in csSlash;
    end;
end;

function PathInclSuffix(const Path: AnsiString; const PathSep: AnsiChar): AnsiString;
var L: Integer;
    P: PAnsiChar;
begin
  L := Length(Path);
  if L = 0 then
    Result := '' else
    begin
      P := Pointer(Path);
      Inc(P, L - 1);
      if P^ = PathSep then
        Result := Path else
        Result := Path + PathSep;
    end;
end;

procedure PathEnsureSuffix(var Path: AnsiString; const PathSep: AnsiChar);
begin
  Path := PathInclSuffix(Path, PathSep);
end;

procedure PathEnsureNoSuffix(var Path: AnsiString; const PathSep: AnsiChar);
begin
  Path := PathExclSuffix(Path, PathSep);
end;

function PathExclSuffix(const Path: AnsiString; const PathSep: AnsiChar): AnsiString;
var L: Integer;
    P: PAnsiChar;
begin
  L := Length(Path);
  if L = 0 then
    Result := '' else
    begin
      P := Pointer(Path);
      Inc(P, L - 1);
      if P^ = PathSep then
        Result := Copy(Path, 1, L - 1) else
        Result := Path;
    end;
end;

function PathCanonical(const Path: AnsiString; const PathSep: AnsiChar): AnsiString;
var L, M : Integer;
    I, J : Integer;
    P    : AnsiStringArray;
    Q    : PAnsiChar;
begin
  Result := Path;
  // \.\ references
  M := Length(Result);
  Repeat
    L := M;
    if L = 0 then
      exit;
    Result := StrReplace('\.\', '\', Result);
    Result := StrReplace('/./', '/', Result);
    M := Length(Result);
  Until L = M;
  // .\ prefix
  StrEnsureNoPrefix(Result, '.\');
  StrEnsureNoPrefix(Result, './');
  // \. suffix
  StrEnsureNoSuffix(Result, '\.');
  StrEnsureNoSuffix(Result, '/.');
  // ..
  if Pos('..', Result) > 0 then
    begin
      P := StrSplitChar(Result, PathSep);
      Repeat
        J := -1;
        For I := Length(P) - 1 downto 0 do
          if P[I] = '..' then
            begin
              J := I;
              break;
            end;
        if J = -1 then
          break;
        M := -1;
        For I := J - 1 downto 0 do
          if (P[I] = '') or ((I = 0) and PathHasDriveLetter(P[I])) then
            break else
          if P[I] <> '..' then
            begin
              M := I;
              break;
            end;
        if M = -1 then
          break;
        cUtils.Remove(P, J, 1);
        cUtils.Remove(P, M, 1);
      Until False;
      Result := StrJoinChar(P, PathSep);
    end;
  // \..\ prefix
  While StrMatchLeft(Result, '\..\') do
    Delete(Result, 1, 3);
  While StrMatchLeft(Result, '/../') do
    Delete(Result, 1, 3);
  if (Result = '\..') or (Result = '/..') then
    Result := '';
  L := Length(Result);
  if L = 0 then
    exit;
  // X:\..\ prefix
  Q := Pointer(Result);
  if Q^ in ['A'..'Z', 'a'..'z'] then
    begin
      if StrMatch(Result, ':\..\', 2) then
        Delete(Result, 4, 3) else
      if (L = 5) and StrMatch(Result, ':\..', 2) then
        begin
          SetLength(Result, 2);
          exit;
        end;
      L := Length(Result);
    end;
  // single dot
  Q := Pointer(Result);
  if L = 1 then
    begin
      if Q^ = '.' then
        Result := '';
      exit;
    end;
  // final dot
  Inc(Q, L - 2);
  if not (Q^ in ['.', '\', '/', ':']) then
    begin
      Inc(Q);
      if Q^ = '.' then
        Delete(Result, L, 1);
    end;
end;

function PathExpand(const Path: AnsiString; const BasePath: AnsiString;
    const PathSep: AnsiChar): AnsiString;
begin
  if Path = '' then
    Result := BasePath else
  if PathIsAbsolute(Path) then
    Result := Path else
    Result := PathInclSuffix(BasePath, PathSep) + Path;
  Result := PathCanonical(Result, PathSep);
end;

function PathLeftElement(const Path: AnsiString; const PathSep: AnsiChar): AnsiString;
var I: Integer;
begin
  I := PosChar(PathSep, Path);
  if I <= 0 then
    Result := Path else
    Result := Copy(Path, 1, I - 1);
end;

procedure PathSplitLeftElement(const Path: AnsiString;
    var LeftElement, RightPath: AnsiString; const PathSep: AnsiChar);
var I: Integer;
begin
  I := PosChar(PathSep, Path);
  if I <= 0 then
    begin
      LeftElement := Path;
      RightPath := '';
    end else
    begin
      LeftElement := Copy(Path, 1, I - 1);
      RightPath := CopyFrom(Path, I + 1);
    end;
end;

procedure DecodeFilePath(const FilePath: AnsiString; var Path, FileName: AnsiString;
    const PathSep: AnsiChar);
var I: Integer;
begin
  I := PosCharRev(PathSep, FilePath);
  if I <= 0 then
    begin
      Path := '';
      FileName := FilePath;
    end else
    begin
      Path := Copy(FilePath, 1, I);
      FileName := CopyFrom(FilePath, I + 1);
    end;
end;

function FileNameValid(const FileName: AnsiString): AnsiString;
begin
  Result := StrReplaceChar(['\', '/', ':', '>', '<', '*', '?'], '_', FileName);
  if Result = '.' then
    Result := '' else
  if Result = '..' then
    Result := '_';
end;

function FilePath(const FileName, Path: AnsiString; const BasePath: AnsiString;
    const PathSep: AnsiChar): AnsiString;
var P, F: AnsiString;
begin
  F := FileNameValid(FileName);
  if F = '' then
    begin
      Result := '';
      exit;
    end;
  P := PathExpand(Path, BasePath, PathSep);
  if P = '' then
    Result := F
  else
    Result := PathInclSuffix(P, PathSep) + F;
end;

function DirectoryExpand(const Path: AnsiString; const BasePath: AnsiString;
    const PathSep: AnsiChar): AnsiString;
begin
  Result := PathExpand(PathInclSuffix(Path, PathSep),
      PathInclSuffix(BasePath, PathSep), PathSep);
end;

function UnixPathToWinPath(const Path: AnsiString): AnsiString;
begin
  Result := StrReplaceChar('/', '\',
            StrReplaceChar(['\', ':', '<', '>', '|'], '_', Path));
end;

function WinPathToUnixPath(const Path: AnsiString): AnsiString;
begin
  Result := Path;
  if PathHasDriveLetter(Path) then
    begin
      // X: -> \X
      Result[2] := Result[1];
      Result[1] := '\';
    end else
  if StrMatchLeft(Path, '\\.\') then
    // \\.\ -> \
    Delete(Result, 1, 3) else
  if PathIsUncPath(Path) then
    // \\ -> \
    Delete(Result, 1, 1);
  Result := StrReplaceChar('\', '/',
            StrReplaceChar(['/', ':', '<', '>', '|'], '_', Result));
end;



{                                                                              }
{ System helper functions                                                      }
{                                                                              }
resourcestring
  SSystemError = 'System error #%s';

{$IFDEF MSWIN}
function GetLastOSErrorMessage: String;
const MAX_ERRORMESSAGE_LENGTH = 256;
var Err: LongWord;
    Buf: Array[0..MAX_ERRORMESSAGE_LENGTH - 1] of Byte;
    Len: LongWord;
begin
  Err := Windows.GetLastError;
  FillChar(Buf, Sizeof(Buf), #0);
  Len := Windows.FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, nil, Err, 0,
      @Buf, MAX_ERRORMESSAGE_LENGTH, nil);
  if Len = 0 then
    Result := Format(SSystemError, [IntToStr(Err)])
  else
    Result := StrPas(PAnsiChar(@Buf));
end;
{$ELSE}
{$IFDEF UNIX}
{$IFDEF FREEPASCAL}
function GetLastOSErrorMessage: String;
begin
  Result := SysErrorMessage(GetLastOSError);
end;
{$ELSE}
function GetLastOSErrorMessage: String;
var Err: LongWord;
    Buf: Array[0..1023] of AnsiChar;
begin
  Err := BaseUnix.fpgeterrno;
  FillChar(Buf, Sizeof(Buf), #0);
  libc.strerror_r(Err, @Buf, SizeOf(Buf));
  if Buf[0] = #0 then
    Result := Format(SSystemError, [IntToStr(Err)])
  else
    Result := StrPas(@Buf);
end;
{$ENDIF}{$ENDIF}{$ENDIF}

{$IFDEF WindowsPlatform}
function GetTick: LongWord;
begin
  Result := GetTickCount;
end;
{$ELSE}{$IFDEF UNIX}
function GetTick: LongWord;
begin
  Result := LongWord(DateTimeToTimeStamp(Now).Time);
end;
{$ENDIF}{$ENDIF}



{                                                                              }
{ File errors                                                                  }
{                                                                              }
constructor EFileError.Create(const FileError: TFileError; const Msg: string);
begin
  FFileError := FileError;
  inherited Create(Msg);
end;

constructor EFileError.CreateFmt(const FileError: TFileError; const Msg: string; const Args: array of const);
begin
  FFileError := FileError;
  inherited CreateFmt(Msg, Args);
end;

{$IFDEF MSWIN}
function WinErrorCodeToFileError(const ErrorCode: LongWord): TFileError;
begin
  case ErrorCode of
    0                             : Result := feNone;
    ERROR_INVALID_HANDLE          : Result := feInvalidParameter;
    ERROR_FILE_NOT_FOUND,
    ERROR_PATH_NOT_FOUND          : Result := feFileDoesNotExist;
    ERROR_ALREADY_EXISTS,
    ERROR_FILE_EXISTS             : Result := feFileExists;
    ERROR_WRITE_PROTECT,
    ERROR_OPEN_FAILED             : Result := feFileOpenError;
    ERROR_CANNOT_MAKE             : Result := feFileCreateError;
    ERROR_NEGATIVE_SEEK           : Result := feFileSeekError;
    ERROR_ACCESS_DENIED,
    ERROR_NETWORK_ACCESS_DENIED   : Result := feAccessDenied;
    ERROR_SHARING_VIOLATION,
    ERROR_LOCK_VIOLATION,
    ERROR_SHARING_PAUSED,
    ERROR_LOCK_FAILED             : Result := feFileSharingError;
    ERROR_HANDLE_DISK_FULL,
    ERROR_DISK_FULL               : Result := feOutOfSpace;
    ERROR_BAD_NETPATH,
    ERROR_DIRECTORY,
    ERROR_INVALID_DRIVE           : Result := feInvalidFilePath;
    ERROR_INVALID_NAME,
    ERROR_FILENAME_EXCED_RANGE,
    ERROR_BAD_NET_NAME,
    ERROR_BUFFER_OVERFLOW         : Result := feInvalidFileName;
    ERROR_OUTOFMEMORY,
    ERROR_NOT_ENOUGH_MEMORY,
    ERROR_TOO_MANY_OPEN_FILES,
    ERROR_SHARING_BUFFER_EXCEEDED : Result := feOutOfResources;
    ERROR_SEEK,
    ERROR_READ_FAULT,
    ERROR_WRITE_FAULT,
    ERROR_GEN_FAILURE,
    ERROR_CRC,
    ERROR_NETWORK_BUSY,
    ERROR_NET_WRITE_FAULT,
    ERROR_REM_NOT_LIST,
    ERROR_DEV_NOT_EXIST,
    ERROR_NETNAME_DELETED         : Result := feDeviceFailure;
  else
    Result := feFileError;
  end;
end;
{$ENDIF}



{                                                                              }
{ File operations                                                              }
{                                                                              }
{$IFDEF MSWIN}
{$ELSE}
function FileOpenShareMode(
         const FileAccess: TFileAccess;
         const FileSharing: TFileSharing): LongWord;
var FileShareMode : LongWord;
begin
  case FileAccess of
    faRead      : FileShareMode := fmOpenRead;
    faWrite     : FileShareMode := fmOpenWrite;
    faReadWrite : FileShareMode := fmOpenReadWrite;
  else
    raise EFileError.Create(feInvalidParameter, 'Invalid requested file access');
  end;
  case FileSharing of
    fsDenyNone      : FileShareMode := FileShareMode or fmShareDenyNone;
    fsDenyRead      : FileShareMode := FileShareMode or fmShareDenyRead;
    fsDenyWrite     : FileShareMode := FileShareMode or fmShareDenyWrite;
    fsDenyReadWrite : FileShareMode := FileShareMode or fmShareDenyRead or fmShareDenyWrite;
    fsExclusive     : FileShareMode := FileShareMode or fmShareExclusive;
  else
    raise EFileError.Create(feInvalidParameter, 'Invalid requested file sharing');
  end;
  Result := FileShareMode;
end;

function FileCreateWithShareMode(
         const FileName: AnsiString;
         const FileShareMode: LongWord): Integer;
var FileHandle : Integer;
begin
  FileHandle := FileCreate(FileName);
  if FileHandle < 0 then
    exit;
  FileClose(FileHandle);
  FileHandle := FileOpen(FileName, FileShareMode);
  Result := FileHandle;
end;
{$ENDIF}

function FileOpenExA(
         const FileName: AnsiString;
         const FileAccess: TFileAccess;
         const FileSharing: TFileSharing;
         const FileOpenFlags: TFileOpenFlags;
         const FileCreationMode: TFileCreationMode;
         const FileOpenWait: PFileOpenWait): TFileHandle;

var FileHandle     : Integer;
    FileShareMode  : LongWord;
    {$IFDEF MSWIN}
    FileOpenAccess : LongWord;
    FileFlags      : LongWord;
    FileCreateDisp : LongWord;
    ErrorCode      : LongWord;
    ErrorSharing   : Boolean;
    Retry          : Boolean;
    WaitStart      : LongWord;
    WaitOpen       : Boolean;
    WaitTime       : LongWord;
    WaitResult     : LongInt;
    {$ENDIF}

  function RandomRetryWait: Integer;
  var Seed : Integer;
  begin
    if not FileOpenWait^.RetryRandomise then
      Result := 0
    else
    if FileOpenWait^.RetryInterval < 0 then
      Result := 0
    else
      Result := FileOpenWait^.RetryInterval div 8;
    if Result = 0 then
      exit;
    Seed := Integer(GetTick);
    Inc(Seed, Integer(FileOpenWait));
    Result := Seed mod Result;
  end;

begin
  {$IFDEF MSWIN}
  FileFlags := 0;
  if foDeleteOnClose in FileOpenFlags then
    FileFlags := FileFlags or FILE_FLAG_DELETE_ON_CLOSE;
  if foNoBuffering in FileOpenFlags then
    FileFlags := FileFlags or FILE_FLAG_NO_BUFFERING;
  if foWriteThrough in FileOpenFlags then
    FileFlags := FileFlags or FILE_FLAG_WRITE_THROUGH;
  if foRandomAccessHint in FileOpenFlags then
    FileFlags := FileFlags or FILE_FLAG_RANDOM_ACCESS;
  if foSequentialScanHint in FileOpenFlags then
    FileFlags := FileFlags or FILE_FLAG_SEQUENTIAL_SCAN;
  case FileCreationMode of
    fcCreateNew        : FileCreateDisp := CREATE_NEW;
    fcCreateAlways     : FileCreateDisp := CREATE_ALWAYS;
    fcOpenExisting     : FileCreateDisp := OPEN_EXISTING;
    fcOpenAlways       : FileCreateDisp := OPEN_ALWAYS;
    fcTruncateExisting : FileCreateDisp := TRUNCATE_EXISTING;
  else
    raise EFileError.Create(feInvalidParameter, SInvalidFileCreationMode);
  end;
  case FileAccess of
    faRead      : FileShareMode := FILE_SHARE_READ;
    faWrite     : FileShareMode := FILE_SHARE_WRITE;
    faReadWrite : FileShareMode := FILE_SHARE_READ or FILE_SHARE_WRITE;
  else
    raise EFileError.Create(feInvalidParameter, 'Invalid requested file access');
  end;
  case FileSharing of
    fsDenyNone      : ;
    fsDenyRead      : ;
    fsDenyWrite     : ;
    fsDenyReadWrite : ;
    fsExclusive     : ;
  else
    raise EFileError.Create(feInvalidParameter, 'Invalid requested file sharing');
  end;
  case FileAccess of
    faRead      : FileOpenAccess := GENERIC_READ;
    faWrite     : FileOpenAccess := GENERIC_WRITE;
    faReadWrite : FileOpenAccess := GENERIC_READ or GENERIC_WRITE;
  else
    raise EFileError.Create(feInvalidParameter, 'Invalid requested file access');
  end;
  WaitOpen := False;
  WaitStart := 0;
  if Assigned(FileOpenWait) then
    if FileOpenWait^.Wait and (FileOpenWait^.Timeout > 0) then
      begin
        WaitOpen := True;
        WaitStart := GetTick;
      end;
  Retry := False;
  repeat
    FileHandle := Integer(Windows.CreateFileA(
        PAnsiChar(FileName),
        FileOpenAccess,
        FileShareMode,
        nil,
        FileCreateDisp,
        FileFlags,
        0));
    if FileHandle < 0 then
      begin
        ErrorCode := GetLastError;
        ErrorSharing :=
            (ErrorCode = ERROR_SHARING_VIOLATION) or
            (ErrorCode = ERROR_LOCK_VIOLATION);
      end
    else
      begin
        ErrorCode := 0;
        ErrorSharing := False;
      end;
    if WaitOpen and ErrorSharing then
      begin
        if FileOpenWait^.Signal <> 0 then
          begin
            if FileOpenWait^.RetryInterval < 0 then
              WaitTime := INFINITE
            else
              WaitTime := FileOpenWait^.RetryInterval + RandomRetryWait;
            WaitResult := WaitForSingleObject(FileOpenWait^.Signal, WaitTime);
            if WaitResult = WAIT_TIMEOUT then
              Retry := True;
          end
        else
        if Assigned(FileOpenWait^.Callback) then
          begin
            FileOpenWait^.Aborted := False;
            FileOpenWait^.Callback(FileOpenWait);
            if not FileOpenWait^.Aborted then
              Retry := True;
          end
        else
          begin
            Sleep(FileOpenWait^.RetryInterval + RandomRetryWait);
            Retry := True;
          end;
        if Retry then
          if LongInt(Int64(GetTick) - Int64(WaitStart)) >= FileOpenWait^.Timeout then
            Retry := False;
      end;
  until not Retry;
  if FileHandle < 0 then
    raise EFileError.CreateFmt(WinErrorCodeToFileError(ErrorCode), SCannotOpenFile,
        [GetLastOSErrorMessage{GetOSErrorMessage(ErrorCode)}, FileName]);
  {$ELSE}
  FileShareMode := FileOpenShareMode(FileAccess, FileSharing);
  case FileCreationMode of
    fcCreateNew :
      if FileExists(FileName) then
        raise EFileError.CreateFmt(feFileExists, SFileExists, [FileName])
      else
        FileHandle := FileCreateWithShareMode(FileName, FileShareMode);
    fcCreateAlways :
      FileHandle := FileCreateWithShareMode(FileName, FileShareMode);
    fcOpenExisting :
      FileHandle := FileOpen(FileName, FileShareMode);
    fcOpenAlways :
      if not FileExists(FileName) then
        FileHandle := FileCreateWithShareMode(FileName, FileShareMode)
      else
        FileHandle := FileOpen(FileName, FileShareMode);
    fcTruncateExisting :
      if not FileExists(FileName) then
        raise EFileError.CreateFmt(feFileDoesNotExist, SFileDoesNotExist, [FileName])
      else
        FileHandle := FileCreateWithShareMode(FileName, FileShareMode)
  else
    raise EFileError.CreateFmt(feInvalidParameter, SInvalidFileCreationMode, []);
  end;
  if FileHandle < 0 then
    raise EFileError.CreateFmt(feFileOpenError, SCannotOpenFile, [GetLastOSErrorMessage, FileName]);
  {$ENDIF}
  if foSeekToEndOfFile in FileOpenFlags then
    FileSeekEx(FileHandle, 0, fpOffsetFromEnd);
  Result := FileHandle;
end;

function FileSeekEx(
         const FileHandle: TFileHandle;
         const FileOffset: Int64;
         const FilePosition: TFileSeekPosition): Int64;
begin
  if FileHandle = 0 then
    raise EFileError.CreateFmt(feInvalidParameter, SInvalidFileHandle, []);
  case FilePosition of
    fpOffsetFromStart   : Result := FileSeek(FileHandle, FileOffset, 0);
    fpOffsetFromCurrent : Result := FileSeek(FileHandle, FileOffset, 1);
    fpOffsetFromEnd     : Result := FileSeek(FileHandle, FileOffset, 2);
  else
    raise EFileError.CreateFmt(feInvalidParameter, SInvalidFilePosition, []);
  end;
  if Result < 0 then
    raise EFileError.CreateFmt(feFileSeekError, SFileSeekError, [GetLastOSErrorMessage]);
end;

function FileReadEx(
         const FileHandle: TFileHandle;
         var Buf; const BufSize: Integer): Integer;
begin
  {$IFDEF MSWIN}
  if not ReadFile(FileHandle, Buf, BufSize, LongWord(Result), nil) then
    raise EFileError.CreateFmt(feFileReadError, SFileReadError, [GetLastOSErrorMessage]);
  {$ELSE}
  Result := FileRead(FileHandle, Buf, BufSize);
  if Result < 0 then
    raise EFileError.Create(feFileReadError, SFileReadError);
  {$ENDIF}
end;

function FileWriteEx(
         const FileHandle: TFileHandle;
         const Buf; const BufSize: Integer): Integer;
begin
  {$IFDEF MSWIN}
  if not WriteFile(FileHandle, Buf, BufSize, LongWord(Result), nil) then
    raise EFileError.CreateFmt(feFileWriteError, SFileWriteError, [GetLastOSErrorMessage]);
  {$ELSE}
  Result := FileWrite(FileHandle, Buf, BufSize);
  if Result < 0 then
    raise EFileError.Create(feFileWriteError, SFileWriteError);
  {$ENDIF}
end;

procedure FileCloseEx(const FileHandle: TFileHandle);
begin
  FileClose(FileHandle);
end;

function FileExistsA(const FileName: AnsiString): Boolean;
{$IFDEF MSWIN}
var Attr : LongWord;
{$ELSE}
var SRec : TSearchRec;
{$ENDIF}
begin
  if FileName = '' then
    raise EFileError.Create(feInvalidParameter, SInvalidFileName);
  {$IFDEF MSWIN}
  Attr := GetFileAttributesA(PAnsiChar(FileName));
  if Attr = $FFFFFFFF then
    Result := False
  else
    Result := Attr and FILE_ATTRIBUTE_DIRECTORY = 0;
  {$ELSE}
  if FindFirst(FileName, faAnyFile, SRec) <> 0 then
    Result := False
  else
    begin
      Result := SRec.Attr and faDirectory = 0;
      FindClose(SRec);
    end;
  {$ENDIF}
end;

function FileGetSizeA(const FileName: AnsiString): Int64;
var SRec : TSearchRec;
begin
  if FileName = '' then
    raise EFileError.Create(feInvalidParameter, SInvalidFileName);
  if FindFirst(FileName, faAnyFile, SRec) <> 0 then
    Result := -1
  else
  begin
    if SRec.Attr and faDirectory <> 0 then
      Result := -1
    else
      begin
        {$IFDEF MSWIN}
        Int64Rec(Result).Lo := SRec.FindData.nFileSizeLow;
        Int64Rec(Result).Hi := SRec.FindData.nFileSizeHigh;
        {$ELSE}
        Result := SRec.Size;
        {$ENDIF}
      end;
    FindClose(SRec);
  end;
end;

function FileGetDateTimeA(const FileName: AnsiString): TDateTime;
var SRec : TSearchRec;
begin
  if FileName = '' then
    raise EFileError.Create(feInvalidParameter, SInvalidFileName);
  if FindFirst(FileName, faAnyFile, SRec) <> 0 then
    Result := 0.0
  else
    begin
      if SRec.Attr and faDirectory <> 0 then
        Result := 0.0
      else
        Result := FileDateToDateTime(SRec.Time);
      FindClose(SRec);
    end;
end;

function FileGetDateTime2A(const FileName: AnsiString): TDateTime;
var Age : LongInt;
begin
  Age := FileAge(FileName);
  if Age = -1 then
    Result := 0.0
  else
    Result := FileDateToDateTime(Age);
end;

function FileIsReadOnlyA(const FileName: AnsiString): Boolean;
var SRec : TSearchRec;
begin
  if FileName = '' then
    raise EFileError.Create(feInvalidParameter, SInvalidFileName);
  if FindFirst(FileName, faAnyFile, SRec) <> 0 then
    Result := False
  else
    begin
      Result := SRec.Attr and (faReadOnly or faDirectory) = faReadOnly;
      FindClose(SRec);
    end;
end;

procedure FileDeleteExA(const FileName: AnsiString);
begin
  if FileName = '' then
    raise EFileError.Create(feInvalidParameter, SInvalidFileName);
  if not DeleteFile(FileName) then
    raise EFileError.CreateFmt(feFileDeleteError, SFileDeleteError, [GetLastOSErrorMessage]);
end;

procedure FileRenameExA(
          const OldFileName, NewFileName: AnsiString);
begin
  RenameFile(OldFileName, NewFileName);
end;

function ReadFileBufA(
         const FileName: AnsiString;
         var Buf; const BufSize: Integer;
         const FileSharing: TFileSharing;
         const FileCreationMode: TFileCreationMode;
         const FileOpenWait: PFileOpenWait): Integer;
var FileHandle : Integer;
    FileSize   : Int64;
begin
  Result := 0;
  FileHandle := FileOpenExA(FileName, faRead, FileSharing,
      [foSequentialScanHint], FileCreationMode, FileOpenWait);
  try
    FileSize := FileGetSizeA(FileName);
    if FileSize = 0 then
      exit;
    if FileSize < 0 then
      raise EFileError.CreateFmt(feFileSizeError, SFileSizeError, [FileName]);
    if FileSize > MaxInteger then
      raise EFileError.CreateFmt(feFileSizeError, SFileSizeError, [FileName]);
    if FileSize > BufSize then
      raise EFileError.CreateFmt(feFileSizeError, SFileSizeError, [FileName]);
    Result := FileReadEx(FileHandle, Buf, FileSize);
  finally
    FileClose(FileHandle);
  end;
end;

function ReadFileStrA(
         const FileName: AnsiString;
         const FileSharing: TFileSharing;
         const FileCreationMode: TFileCreationMode;
         const FileOpenWait: PFileOpenWait): AnsiString;
var FileHandle : Integer;
    FileSize   : Int64;
    ReadBytes  : Integer;
begin
  FileHandle := FileOpenExA(FileName, faRead, FileSharing,
      [foSequentialScanHint], FileCreationMode, FileOpenWait);
  try
    FileSize := FileGetSizeA(FileName);
    if FileSize < 0 then
      raise EFileError.CreateFmt(feFileSizeError, SFileSizeError, [FileName]);
    if FileSize > MaxInteger then
      raise EFileError.CreateFmt(feFileSizeError, SFileSizeError, [FileName]);
    SetLength(Result, FileSize);
    if FileSize = 0 then
      exit;
    ReadBytes := FileReadEx(FileHandle, Result[1], FileSize);
    if ReadBytes < FileSize then
      SetLength(Result, ReadBytes);
  finally
    FileClose(FileHandle);
  end;
end;

procedure AppendFileA(
          const FileName: AnsiString;
          const Buf; const BufSize: Integer;
          const FileSharing: TFileSharing;
          const FileCreationMode: TFileCreationMode;
          const FileOpenWait: PFileOpenWait);
var FileHandle : Integer;
begin
  if BufSize <= 0 then
    exit;
  FileHandle := FileOpenExA(FileName, faWrite, FileSharing, [foSeekToEndOfFile],
      FileCreationMode, FileOpenWait);
  try
    if FileWriteEx(FileHandle, Buf, BufSize) <> BufSize then
      raise EFileError.CreateFmt(feFileWriteError, SFileWriteError, [GetLastOSErrorMessage, FileName]);
  finally
    FileClose(FileHandle);
  end;
end;

procedure AppendFileStrA(
          const FileName: AnsiString;
          const Buf: AnsiString;
          const FileSharing: TFileSharing;
          const FileCreationMode: TFileCreationMode;
          const FileOpenWait: PFileOpenWait);
var BufSize    : Integer;
begin
  BufSize := Length(Buf);
  if BufSize <= 0 then
    exit;
  AppendFileA(FileName, Buf[1], BufSize, FileSharing, FileCreationMode, FileOpenWait);
end;

function DirectoryEntryExistsA(const Name: AnsiString): Boolean;
var SRec : TSearchRec;
begin
  if FindFirst(Name, faAnyFile, SRec) <> 0 then
    Result := False
  else
    begin
      Result := True;
      FindClose(SRec);
    end;
end;

function DirectoryEntrySizeA(const Name: AnsiString): Int64;
var SRec : TSearchRec;
begin
  if FindFirst(Name, faAnyFile, SRec) <> 0 then
    Result := -1
  else
    begin
      if SRec.Attr and faDirectory <> 0 then
        Result := 0
      else
        begin
          {$IFDEF MSWIN}
          {$WARNINGS OFF}
          Int64Rec(Result).Lo := SRec.FindData.nFileSizeLow;
          Int64Rec(Result).Hi := SRec.FindData.nFileSizeHigh;
          {$IFDEF DEBUG}{$IFNDEF FREEPASCAL}{$WARNINGS ON}{$ENDIF}{$ENDIF}
          {$ELSE}
          Result := SRec.Size;
          {$ENDIF}
        end;
      FindClose(SRec);
    end;
end;

function DirectoryExistsA(const DirectoryName: AnsiString): Boolean;
{$IFDEF MSWIN}
var Attr : LongWord;
{$ELSE}
var SRec : TSearchRec;
{$ENDIF}
begin
  if DirectoryName = '' then
    raise EFileError.Create(feInvalidParameter, SInvalidPath);
  {$IFDEF MSWIN}
  Attr := GetFileAttributesA(PAnsiChar(DirectoryName));
  if Attr = $FFFFFFFF then
    Result := False
  else
    Result := Attr and FILE_ATTRIBUTE_DIRECTORY <> 0;
  {$ELSE}
  if FindFirst(DirectoryName, faAnyFile, SRec) <> 0 then
    Result := False
  else
    begin
      Result := SRec.Attr and faDirectory <> 0;
      FindClose(SRec);
    end;
  {$ENDIF}
end;

function DirectoryGetDateTimeA(const DirectoryName: AnsiString): TDateTime;
var SRec : TSearchRec;
begin
  if DirectoryName = '' then
    raise EFileError.Create(feInvalidParameter, SInvalidPath);
  if FindFirst(DirectoryName, faAnyFile, SRec) <> 0 then
    Result := 0.0
  else
    begin
      if SRec.Attr and faDirectory = 0 then
        Result := 0.0
      else
        Result := FileDateToDateTime(SRec.Time);
      FindClose(SRec);
    end;
end;

procedure DirectoryCreateA(const DirectoryName: AnsiString);
begin
  if DirectoryName = '' then
    raise EFileError.Create(feInvalidParameter, SInvalidPath);
  if not CreateDir(DirectoryName) then
    raise EFileError.Create(feFileError, SCannotCreateFile);
end;



{                                                                              }
{ File operations                                                              }
{                                                                              }
function GetFirstFileNameMatching(const FileMask: AnsiString): AnsiString;
var SRec : TSearchRec;
begin
  Result := '';
  if FindFirst(FileMask, faAnyFile, SRec) = 0 then
    try
      Repeat
        if SRec.Attr and faDirectory = 0 then
          begin
            Result := ExtractFilePath(FileMask) + SRec.Name;
            exit;
          end;
      Until FindNext(SRec) <> 0;
    finally
      FindClose(SRec);
    end;
end;

function DirEntryGetAttr(const FileName: AnsiString): Integer;
var SRec : TSearchRec;
begin
  if (FileName = '') or PathIsDriveLetter(FileName) then
    Result := -1 else
  if PathIsRoot(FileName) then
    Result := $0800 or faDirectory else
  if FindFirst(PathExclSuffix(FileName), faAnyFile, SRec) = 0 then
    begin
      Result := SRec.Attr;
      FindClose(SRec);
    end
  else
    Result := -1;
end;

function DirEntryIsDirectory(const FileName: AnsiString): Boolean;
var SRec : TSearchRec;
begin
  if (FileName = '') or PathIsDriveLetter(FileName) then
    Result := False else
  if PathIsRoot(FileName) then
    Result := True else
  if FindFirst(PathExclSuffix(FileName), faDirectory, SRec) = 0 then
    begin
      Result := SRec.Attr and faDirectory <> 0;
      FindClose(SRec);
    end
  else
    Result := False;
end;

{$IFDEF DELPHI6_UP}{$WARN SYMBOL_PLATFORM OFF}{$ENDIF}
function FileHasAttr(const FileName: AnsiString; const Attr: Word): Boolean;
var A : Integer;
begin
  A := FileGetAttr(FileName);
  Result := (A >= 0) and (A and Attr <> 0);
end;

procedure CopyFile(const FileName, DestName: AnsiString);
const BufferSize = 16384;
var DestFileName : AnsiString;
    SourceHandle : Integer;
    DestHandle   : Integer;
    Buffer       : Array[0..BufferSize - 1] of Byte;
    BufferUsed   : Integer;
begin
  DestFileName := ExpandFileName(DestName);
  if FileHasAttr(DestFileName, faDirectory) then // if destination is a directory, append file name
    DestFileName := DestFileName + '\' + ExtractFileName(FileName);
  SourceHandle := FileOpen(FileName, fmShareDenyWrite);
  if SourceHandle < 0 then
    raise EFileError.CreateFmt(feFileOpenError, SCannotOpenFile, [GetLastOSErrorMessage,
        FileName]);
  try
    DestHandle := FileCreate(DestFileName);
    if DestHandle < 0 then
      raise EFileError.CreateFmt(feFileCreateError, SCannotCreateFile, [GetLastOSErrorMessage,
          DestFileName]);
    try
      repeat
        BufferUsed := FileRead(SourceHandle, Buffer[0], BufferSize);
        if BufferUsed > 0 then
          FileWrite(DestHandle, Buffer[0], BufferUsed);
      until BufferUsed < BufferSize;
    finally
      FileClose(DestHandle);
    end;
  finally
    FileClose(SourceHandle);
  end;
end;

procedure MoveFile(const FileName, DestName: AnsiString);
var Destination : AnsiString;
    Attr        : Integer;
begin
  Destination := ExpandFileName(DestName);
  if not RenameFile(FileName, Destination) then
    begin
      Attr := FileGetAttr(FileName);
      if (Attr < 0) or (Attr and faReadOnly <> 0) then
        raise EFileError.CreateFmt(feFileMoveError, SCannotMoveFile, [GetLastOSErrorMessage,
            FileName]);
      CopyFile(FileName, Destination);
      DeleteFile(FileName);
    end;
end;

function DeleteFiles(const FileMask: AnsiString): Boolean;
var SRec : TSearchRec;
    Path : AnsiString;
begin
  Result := FindFirst(FileMask, faAnyFile, SRec) = 0;
  if not Result then
    exit;
  try
    Path := ExtractFilePath(FileMask);
    Repeat
      if (SRec.Name <> '') and (SRec.Name  <> '.') and (SRec.Name <> '..') and
         (SRec.Attr and (faVolumeID + faDirectory) = 0) then
        begin
          Result := DeleteFile(Path + SRec.Name);
          if not Result then
            break;
        end;
    Until FindNext(SRec) <> 0;
  finally
    FindClose(SRec);
  end;
end;
{$IFDEF DELPHI6_UP}{$WARN SYMBOL_PLATFORM ON}{$ENDIF}



{$IFDEF MSWIN}
{                                                                              }
{ Logical Drive functions                                                      }
{                                                                              }
function DriveIsValid(const Drive: AnsiChar): Boolean;
var D : AnsiChar;
begin
  D := UpCase(Drive);
  Result := D in ['A'..'Z'];
  if not Result then
    exit;
  Result := IsBitSet(GetLogicalDrives, Ord(D) - Ord('A'));
end;

function DriveGetType(const Path: AnsiString): TLogicalDriveType;
begin
  Case GetDriveTypeA(PAnsiChar(Path)) of
    DRIVE_REMOVABLE : Result := DriveRemovable;
    DRIVE_FIXED     : Result := DriveFixed;
    DRIVE_REMOTE    : Result := DriveRemote;
    DRIVE_CDROM     : Result := DriveCDRom;
    DRIVE_RAMDISK   : Result := DriveRamDisk;
  else
    Result := DriveTypeUnknown;
  end;
end;

function DriveFreeSpace(const Path: AnsiString): Int64;
var D: Byte;
begin
  if PathHasDriveLetter(Path) then
    D := Ord(UpCase(PAnsiChar(Path)^)) - Ord('A') + 1 else
  if PathIsUNCPath(Path) then
    begin
      Result := -1;
      exit;
    end
  else
    D := 0;
  Result := DiskFree(D);
end;
{$ENDIF}



{                                                                              }
{ Test cases                                                                   }
{                                                                              }
{$IFDEF DEBUG}{$IFDEF SELFTEST}
{$ASSERTIONS ON}
procedure SelfTest;
begin
  Assert(PathHasDriveLetter('A:'), 'PathHasDriveLetter');
  Assert(PathHasDriveLetter('a:'), 'PathHasDriveLetter');
  Assert(PathHasDriveLetter('A:\'), 'PathHasDriveLetter');
  Assert(not PathHasDriveLetter('a\'), 'PathHasDriveLetter');
  Assert(not PathHasDriveLetter('\a\'), 'PathHasDriveLetter');
  Assert(not PathHasDriveLetter('::'), 'PathHasDriveLetter');

  Assert(PathIsDriveLetter('B:'), 'PathIsDriveLetter');
  Assert(not PathIsDriveLetter('B:\'), 'PathIsDriveLetter');

  Assert(PathIsDriveRoot('C:\'), 'PathIsDriveRoot');
  Assert(not PathIsDriveRoot('C:'), 'PathIsDriveRoot');
  Assert(not PathIsDriveRoot('C:\A'), 'PathIsDriveRoot');

  Assert(PathIsAbsolute('\'), 'PathIsAbsolute');
  Assert(PathIsAbsolute('\C'), 'PathIsAbsolute');
  Assert(PathIsAbsolute('\C\'), 'PathIsAbsolute');
  Assert(PathIsAbsolute('C:\'), 'PathIsAbsolute');
  Assert(PathIsAbsolute('C:'), 'PathIsAbsolute');
  Assert(PathIsAbsolute('\C\..\'), 'PathIsAbsolute');
  Assert(not PathIsAbsolute(''), 'PathIsAbsolute');
  Assert(not PathIsAbsolute('C'), 'PathIsAbsolute');
  Assert(not PathIsAbsolute('C\'), 'PathIsAbsolute');
  Assert(not PathIsAbsolute('C\D'), 'PathIsAbsolute');
  Assert(not PathIsAbsolute('C\D\'), 'PathIsAbsolute');
  Assert(not PathIsAbsolute('..\'), 'PathIsAbsolute');

  Assert(PathIsDirectory('\'), 'PathIsDirectory');
  Assert(PathIsDirectory('\C\'), 'PathIsDirectory');
  Assert(PathIsDirectory('C:'), 'PathIsDirectory');
  Assert(PathIsDirectory('C:\'), 'PathIsDirectory');
  Assert(PathIsDirectory('C:\D\'), 'PathIsDirectory');
  Assert(not PathIsDirectory(''), 'PathIsDirectory');
  Assert(not PathIsDirectory('D'), 'PathIsDirectory');
  Assert(not PathIsDirectory('C\D'), 'PathIsDirectory');

  Assert(PathInclSuffix('', '\') = '', 'PathInclSuffix');
  Assert(PathInclSuffix('C', '\') = 'C\', 'PathInclSuffix');
  Assert(PathInclSuffix('C\', '\') = 'C\', 'PathInclSuffix');
  Assert(PathInclSuffix('C\D', '\') = 'C\D\', 'PathInclSuffix');
  Assert(PathInclSuffix('C\D\', '\') = 'C\D\', 'PathInclSuffix');
  Assert(PathInclSuffix('C:', '\') = 'C:\', 'PathInclSuffix');
  Assert(PathInclSuffix('C:\', '\') = 'C:\', 'PathInclSuffix');

  Assert(PathExclSuffix('', '\') = '', 'PathExclSuffix');
  Assert(PathExclSuffix('C', '\') = 'C', 'PathExclSuffix');
  Assert(PathExclSuffix('C\', '\') = 'C', 'PathExclSuffix');
  Assert(PathExclSuffix('C\D', '\') = 'C\D', 'PathExclSuffix');
  Assert(PathExclSuffix('C\D\', '\') = 'C\D', 'PathExclSuffix');
  Assert(PathExclSuffix('C:', '\') = 'C:', 'PathExclSuffix');
  Assert(PathExclSuffix('C:\', '\') = 'C:', 'PathExclSuffix');

  Assert(PathCanonical('', '\') = '', 'PathCanonical');
  Assert(PathCanonical('.', '\') = '', 'PathCanonical');
  Assert(PathCanonical('.\', '\') = '', 'PathCanonical');
  Assert(PathCanonical('..\', '\') = '..\', 'PathCanonical');
  Assert(PathCanonical('\..\', '\') = '\', 'PathCanonical');
  Assert(PathCanonical('\X\..\..\', '\') = '\', 'PathCanonical');
  Assert(PathCanonical('\..', '\') = '', 'PathCanonical');
  Assert(PathCanonical('X', '\') = 'X', 'PathCanonical');
  Assert(PathCanonical('\X', '\') = '\X', 'PathCanonical');
  Assert(PathCanonical('X.', '\') = 'X', 'PathCanonical');
  Assert(PathCanonical('.', '\') = '', 'PathCanonical');
  Assert(PathCanonical('\X.', '\') = '\X', 'PathCanonical');
  Assert(PathCanonical('\X.Y', '\') = '\X.Y', 'PathCanonical');
  Assert(PathCanonical('\X.Y\', '\') = '\X.Y\', 'PathCanonical');
  Assert(PathCanonical('\A\X..Y\', '\') = '\A\X..Y\', 'PathCanonical');
  Assert(PathCanonical('\A\.Y\', '\') = '\A\.Y\', 'PathCanonical');
  Assert(PathCanonical('\A\..Y\', '\') = '\A\..Y\', 'PathCanonical');
  Assert(PathCanonical('\A\Y..\', '\') = '\A\Y..\', 'PathCanonical');
  Assert(PathCanonical('\A\Y..', '\') = '\A\Y..', 'PathCanonical');
  Assert(PathCanonical('X', '\') = 'X', 'PathCanonical');
  Assert(PathCanonical('X\', '\') = 'X\', 'PathCanonical');
  Assert(PathCanonical('X\Y\..', '\') = 'X', 'PathCanonical');
  Assert(PathCanonical('X\Y\..\', '\') = 'X\', 'PathCanonical');
  Assert(PathCanonical('\X\Y\..', '\') = '\X', 'PathCanonical');
  Assert(PathCanonical('\X\Y\..\', '\') = '\X\', 'PathCanonical');
  Assert(PathCanonical('\X\Y\..\..', '\') = '', 'PathCanonical');
  Assert(PathCanonical('\X\Y\..\..\', '\') = '\', 'PathCanonical');
  Assert(PathCanonical('\A\.\.\X\.\Y\..\.\..\.\', '\') = '\A\', 'PathCanonical');
  Assert(PathCanonical('C:', '\') = 'C:', 'PathCanonical');
  Assert(PathCanonical('C:\', '\') = 'C:\', 'PathCanonical');
  Assert(PathCanonical('C:\A\..', '\') = 'C:', 'PathCanonical');
  Assert(PathCanonical('C:\A\..\', '\') = 'C:\', 'PathCanonical');
  Assert(PathCanonical('C:\..\', '\') = 'C:\', 'PathCanonical');
  Assert(PathCanonical('C:\..', '\') = 'C:', 'PathCanonical');
  Assert(PathCanonical('C:\A\..\..', '\') = 'C:', 'PathCanonical');
  Assert(PathCanonical('C:\A\..\..\', '\') = 'C:\', 'PathCanonical');
  Assert(PathCanonical('\A\B\..\C\D\..\', '\') = '\A\C\', 'PathCanonical');
  Assert(PathCanonical('\A\B\..\C\D\..\..\', '\') = '\A\', 'PathCanonical');
  Assert(PathCanonical('\A\B\..\C\D\..\..\..\', '\') = '\', 'PathCanonical');
  Assert(PathCanonical('\A\B\..\C\D\..\..\..\..\', '\') = '\', 'PathCanonical');

  Assert(PathExpand('', '', '\') = '', 'PathExpand');
  Assert(PathExpand('', '\', '\') = '\', 'PathExpand');
  Assert(PathExpand('', '\C', '\') = '\C', 'PathExpand');
  Assert(PathExpand('', '\C\', '\') = '\C\', 'PathExpand');
  Assert(PathExpand('..\', '\C\', '\') = '\', 'PathExpand');
  Assert(PathExpand('..', '\C\', '\') = '', 'PathExpand');
  Assert(PathExpand('\..', '\C\', '\') = '', 'PathExpand');
  Assert(PathExpand('\..\', '\C\', '\') = '\', 'PathExpand');
  Assert(PathExpand('A', '..\', '\') = '..\A', 'PathExpand');
  Assert(PathExpand('..\', '..\', '\') = '..\..\', 'PathExpand');
  Assert(PathExpand('\', '', '\') = '\', 'PathExpand');
  Assert(PathExpand('\', '\C', '\') = '\', 'PathExpand');
  Assert(PathExpand('\A', '\C\', '\') = '\A', 'PathExpand');
  Assert(PathExpand('\A\', '\C\', '\') = '\A\', 'PathExpand');
  Assert(PathExpand('\A\B', '\C', '\') = '\A\B', 'PathExpand');
  Assert(PathExpand('A\B', '\C', '\') = '\C\A\B', 'PathExpand');
  Assert(PathExpand('A\B', '\C', '\') = '\C\A\B', 'PathExpand');
  Assert(PathExpand('A\B', '\C\', '\') = '\C\A\B', 'PathExpand');
  Assert(PathExpand('A\B', '\C\', '\') = '\C\A\B', 'PathExpand');
  Assert(PathExpand('A\B', 'C\D', '\') = 'C\D\A\B', 'PathExpand');
  Assert(PathExpand('..\A\B', 'C\D', '\') = 'C\A\B', 'PathExpand');
  Assert(PathExpand('..\A\B', '\C\D', '\') = '\C\A\B', 'PathExpand');
  Assert(PathExpand('..\..\A\B', 'C\D', '\') = 'A\B', 'PathExpand');
  Assert(PathExpand('..\..\A\B', '\C\D', '\') = '\A\B', 'PathExpand');
  Assert(PathExpand('..\..\..\A\B', '\C\D', '\') = '\A\B', 'PathExpand');
  Assert(PathExpand('\..\A\B', '\C\D', '\') = '\A\B', 'PathExpand');
  Assert(PathExpand('..\A\B', '\..\C\D', '\') = '\C\A\B', 'PathExpand');
  Assert(PathExpand('..\A\B', '..\C\D', '\') = '..\C\A\B', 'PathExpand');
  Assert(PathExpand('..\A\B', 'C:\C\D', '\') = 'C:\C\A\B', 'PathExpand');
  Assert(PathExpand('..\A\B\', 'C:\C\D', '\') = 'C:\C\A\B\', 'PathExpand');

  Assert(FilePath('C', '..\X\Y', 'A\B', '\') = 'A\X\Y\C', 'FilePath');
  Assert(FilePath('C', '\X\Y', 'A\B', '\') = '\X\Y\C', 'FilePath');
  Assert(FilePath('C', '', 'A\B', '\') = 'A\B\C', 'FilePath');
  Assert(FilePath('', '\X\Y', 'A\B', '\') = '', 'FilePath');
  Assert(FilePath('C', 'X\Y', 'A\B', '\') = 'A\B\X\Y\C', 'FilePath');
  Assert(FilePath('C', 'X\Y', '', '\') = 'X\Y\C', 'FilePath');

  Assert(DirectoryExpand('', '', '\') = '', 'DirectoryExpand');
  Assert(DirectoryExpand('', '\X', '\') = '\X\', 'DirectoryExpand');
  Assert(DirectoryExpand('\', '\X', '\') = '\', 'DirectoryExpand');
  Assert(DirectoryExpand('\A', '\X', '\') = '\A\', 'DirectoryExpand');
  Assert(DirectoryExpand('\A\', '\X', '\') = '\A\', 'DirectoryExpand');
  Assert(DirectoryExpand('\A\B', '\X', '\') = '\A\B\', 'DirectoryExpand');
  Assert(DirectoryExpand('A', '\X', '\') = '\X\A\', 'DirectoryExpand');
  Assert(DirectoryExpand('A\', '\X', '\') = '\X\A\', 'DirectoryExpand');
  Assert(DirectoryExpand('C:', '\X', '\') = 'C:\', 'DirectoryExpand');
  Assert(DirectoryExpand('C:\', '\X', '\') = 'C:\', 'DirectoryExpand');

  Assert(UnixPathToWinPath('/c/d.f') = '\c\d.f', 'UnixPathToWinPath');
  Assert(WinPathToUnixPath('\c\d.f') = '/c/d.f', 'WinPathToUnixPath');
end;
{$ENDIF}{$ENDIF}



end.

