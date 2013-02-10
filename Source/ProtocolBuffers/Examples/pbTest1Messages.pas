{ Unit pbTest1Messages.pas }
{ Generated from Test1.proto }
{ Package Test1 }

unit pbTest1Messages;

interface

uses
  cUtils,
  cStrings,
  cProtoBufUtils,
  pbTestImport1Messages;



{ TEnumG0 }

type
  TEnumG0 = (
    enumg0G1 = 1,
    enumg0G2 = 2
  );

function pbEncodeValueEnumG0(var Buf; const BufSize: Integer; const Value: TEnumG0): Integer;
function pbEncodeFieldEnumG0(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TEnumG0): Integer;
function pbDecodeValueEnumG0(const Buf; const BufSize: Integer; var Value: TEnumG0): Integer;
procedure pbDecodeFieldEnumG0(const Field: TpbProtoBufDecodeField; var Value: TEnumG0);



{ TTestMsg0Record }

type
  TTestMsg0Record = record
    Field1 : LongInt;
    Field2 : Int64;
  end;
  PTestMsg0Record = ^TTestMsg0Record;

procedure TestMsg0RecordInit(var A: TTestMsg0Record);
procedure TestMsg0RecordFinalise(var A: TTestMsg0Record);
function pbEncodeDataTestMsg0Record(var Buf; const BufSize: Integer; const A: TTestMsg0Record): Integer;
function pbEncodeValueTestMsg0Record(var Buf; const BufSize: Integer; const A: TTestMsg0Record): Integer;
function pbEncodeFieldTestMsg0Record(var Buf; const BufSize: Integer; const FieldNum: Integer; const A: TTestMsg0Record): Integer;
function pbDecodeValueTestMsg0Record(const Buf; const BufSize: Integer; var Value: TTestMsg0Record): Integer;
procedure pbDecodeFieldTestMsg0Record(const Field: TpbProtoBufDecodeField; var Value: TTestMsg0Record);



{ TEnum1 }

type
  TEnum1 = (
    enum1Val1 = 1,
    enum1Val2 = 2
  );

function pbEncodeValueEnum1(var Buf; const BufSize: Integer; const Value: TEnum1): Integer;
function pbEncodeFieldEnum1(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TEnum1): Integer;
function pbDecodeValueEnum1(const Buf; const BufSize: Integer; var Value: TEnum1): Integer;
procedure pbDecodeFieldEnum1(const Field: TpbProtoBufDecodeField; var Value: TEnum1);



{ TDynArrayInt32 }

type
  TDynArrayInt32 = array of LongInt;

function pbEncodeFieldDynArrayInt32(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayInt32): Integer;
function pbEncodeFieldDynArrayInt32_Packed(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayInt32): Integer;
procedure pbDecodeFieldDynArrayInt32(const Field: TpbProtoBufDecodeField; var Value: TDynArrayInt32);
procedure pbDecodeFieldDynArrayInt32_Packed(const Field: TpbProtoBufDecodeField; var Value: TDynArrayInt32);



{ TDynArrayString }

type
  TDynArrayString = array of AnsiString;

function pbEncodeFieldDynArrayString(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayString): Integer;
function pbEncodeFieldDynArrayString_Packed(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayString): Integer;
procedure pbDecodeFieldDynArrayString(const Field: TpbProtoBufDecodeField; var Value: TDynArrayString);
procedure pbDecodeFieldDynArrayString_Packed(const Field: TpbProtoBufDecodeField; var Value: TDynArrayString);



{ TDynArrayEnum1 }

type
  TDynArrayEnum1 = array of TEnum1;

function pbEncodeFieldDynArrayEnum1(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayEnum1): Integer;
function pbEncodeFieldDynArrayEnum1_Packed(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayEnum1): Integer;
procedure pbDecodeFieldDynArrayEnum1(const Field: TpbProtoBufDecodeField; var Value: TDynArrayEnum1);
procedure pbDecodeFieldDynArrayEnum1_Packed(const Field: TpbProtoBufDecodeField; var Value: TDynArrayEnum1);



{ TDynArrayTestMsg0Record }

type
  TDynArrayTestMsg0Record = array of TTestMsg0Record;

function pbEncodeFieldDynArrayTestMsg0Record(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayTestMsg0Record): Integer;
function pbEncodeFieldDynArrayTestMsg0Record_Packed(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayTestMsg0Record): Integer;
procedure pbDecodeFieldDynArrayTestMsg0Record(const Field: TpbProtoBufDecodeField; var Value: TDynArrayTestMsg0Record);
procedure pbDecodeFieldDynArrayTestMsg0Record_Packed(const Field: TpbProtoBufDecodeField; var Value: TDynArrayTestMsg0Record);



{ TTestNested1Record }

type
  TTestNested1Record = record
    Field1 : LongInt;
  end;
  PTestNested1Record = ^TTestNested1Record;

procedure TestNested1RecordInit(var A: TTestNested1Record);
procedure TestNested1RecordFinalise(var A: TTestNested1Record);
function pbEncodeDataTestNested1Record(var Buf; const BufSize: Integer; const A: TTestNested1Record): Integer;
function pbEncodeValueTestNested1Record(var Buf; const BufSize: Integer; const A: TTestNested1Record): Integer;
function pbEncodeFieldTestNested1Record(var Buf; const BufSize: Integer; const FieldNum: Integer; const A: TTestNested1Record): Integer;
function pbDecodeValueTestNested1Record(const Buf; const BufSize: Integer; var Value: TTestNested1Record): Integer;
procedure pbDecodeFieldTestNested1Record(const Field: TpbProtoBufDecodeField; var Value: TTestNested1Record);



{ TTestMsg1Record }

type
  TTestMsg1Record = record
    DefField1 : LongInt;
    DefField2 : Int64;
    DefField3 : AnsiString;
    DefField4 : Double;
    DefField5 : Boolean;
    DefField6 : TEnumG0;
    DefField7 : Int64;
    DefField8 : LongWord;
    DefField9 : Single;
    FieldMsg1 : TTestMsg0Record;
    FieldE1 : TEnum1;
    FieldE2 : TEnum1;
    FieldNested1 : TTestNested1Record;
    FieldNested2 : TTestNested1Record;
    FieldArr1 : TDynArrayInt32;
    FieldArr2 : TDynArrayInt32;
    FieldArr3 : TDynArrayString;
    FieldArrE1 : TDynArrayEnum1;
    FieldMArr2 : TDynArrayTestMsg0Record;
    FieldImp1 : TEnumGlobal;
    FieldImp2 : TEnumGlobal;
  end;
  PTestMsg1Record = ^TTestMsg1Record;

procedure TestMsg1RecordInit(var A: TTestMsg1Record);
procedure TestMsg1RecordFinalise(var A: TTestMsg1Record);
function pbEncodeDataTestMsg1Record(var Buf; const BufSize: Integer; const A: TTestMsg1Record): Integer;
function pbEncodeValueTestMsg1Record(var Buf; const BufSize: Integer; const A: TTestMsg1Record): Integer;
function pbEncodeFieldTestMsg1Record(var Buf; const BufSize: Integer; const FieldNum: Integer; const A: TTestMsg1Record): Integer;
function pbDecodeValueTestMsg1Record(const Buf; const BufSize: Integer; var Value: TTestMsg1Record): Integer;
procedure pbDecodeFieldTestMsg1Record(const Field: TpbProtoBufDecodeField; var Value: TTestMsg1Record);



{ TTestIden1Record }

type
  TTestIden1Record = record
    FieldNameTest1 : LongInt;
    FieldNameTest2 : LongInt;
  end;
  PTestIden1Record = ^TTestIden1Record;

procedure TestIden1RecordInit(var A: TTestIden1Record);
procedure TestIden1RecordFinalise(var A: TTestIden1Record);
function pbEncodeDataTestIden1Record(var Buf; const BufSize: Integer; const A: TTestIden1Record): Integer;
function pbEncodeValueTestIden1Record(var Buf; const BufSize: Integer; const A: TTestIden1Record): Integer;
function pbEncodeFieldTestIden1Record(var Buf; const BufSize: Integer; const FieldNum: Integer; const A: TTestIden1Record): Integer;
function pbDecodeValueTestIden1Record(const Buf; const BufSize: Integer; var Value: TTestIden1Record): Integer;
procedure pbDecodeFieldTestIden1Record(const Field: TpbProtoBufDecodeField; var Value: TTestIden1Record);



implementation



{ TEnumG0 }

function pbEncodeValueEnumG0(var Buf; const BufSize: Integer; const Value: TEnumG0): Integer;
begin
  Result := pbEncodeValueInt32(Buf, BufSize, Ord(Value));
end;

function pbEncodeFieldEnumG0(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TEnumG0): Integer;
begin
  Result := pbEncodeFieldInt32(Buf, BufSize, FieldNum, Ord(Value));
end;

function pbDecodeValueEnumG0(const Buf; const BufSize: Integer; var Value: TEnumG0): Integer;
var I : LongInt;
begin
  Result := pbDecodeValueInt32(Buf, BufSize, I);
  Value := TEnumG0(I);
end;

procedure pbDecodeFieldEnumG0(const Field: TpbProtoBufDecodeField; var Value: TEnumG0);
var I : LongInt;
begin
  pbDecodeFieldInt32(Field, I);
  Value := TEnumG0(I);
end;



{ TTestMsg0Record }

procedure TestMsg0RecordInit(var A: TTestMsg0Record);
begin
  with A do
  begin
    Field1 := 0;
    Field2 := 0;
  end;
end;

procedure TestMsg0RecordFinalise(var A: TTestMsg0Record);
begin
  with A do
  begin
  end;
end;

function pbEncodeDataTestMsg0Record(var Buf; const BufSize: Integer; const A: TTestMsg0Record): Integer;
var
  P : PByte;
  L : Integer;
  I : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbEncodeFieldInt32(P^, L, 1, A.Field1);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldInt64(P^, L, 2, A.Field2);
  Dec(L, I);
  Result := BufSize - L;
end;

function pbEncodeValueTestMsg0Record(var Buf; const BufSize: Integer; const A: TTestMsg0Record): Integer;
var
  P : PByte;
  L, N, I : Integer;
begin
  P := @Buf;
  L := BufSize;
  N := pbEncodeDataTestMsg0Record(P^, 0, A);
  I := pbEncodeValueInt32(P^, L, N);
  Inc(P, I);
  Dec(L, I);
  I := pbEncodeDataTestMsg0Record(P^, L, A);
  Assert(I = N);
  Dec(L, I);
  Result := BufSize - L;
end;

function pbEncodeFieldTestMsg0Record(var Buf; const BufSize: Integer; const FieldNum: Integer; const A: TTestMsg0Record): Integer;
var
  P : PByte;
  L : Integer;
  I : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbEncodeFieldKey(P^, L, FieldNum, pwtVarBytes);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeValueTestMsg0Record(P^, L, A);
  Dec(L, I);
  Result := BufSize - L;
end;

procedure pbDecodeFieldTestMsg0Record_CallbackProc(const Field: TpbProtoBufDecodeField; const Data: Pointer);
var
  A : PTestMsg0Record;
begin
  A := Data;
  case Field.FieldNum of
    1 : pbDecodeFieldInt32(Field, A^.Field1);
    2 : pbDecodeFieldInt64(Field, A^.Field2);
  end;
end;

function pbDecodeValueTestMsg0Record(const Buf; const BufSize: Integer; var Value: TTestMsg0Record): Integer;
var
  P : PByte;
  L, I, N : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbDecodeValueInt32(P^, L, N);
  Dec(L, I);
  Inc(P, I);
  pbDecodeProtoBuf(P^, N, pbDecodeFieldTestMsg0Record_CallbackProc, @Value);
  Dec(L, N);
  Result := BufSize - L;
end;

procedure pbDecodeFieldTestMsg0Record(const Field: TpbProtoBufDecodeField; var Value: TTestMsg0Record);
begin
  pbDecodeProtoBuf(Field.ValueVarBytesPtr^, Field.ValueVarBytesLen, pbDecodeFieldTestMsg0Record_CallbackProc, @Value);
end;



{ TEnum1 }

function pbEncodeValueEnum1(var Buf; const BufSize: Integer; const Value: TEnum1): Integer;
begin
  Result := pbEncodeValueInt32(Buf, BufSize, Ord(Value));
end;

function pbEncodeFieldEnum1(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TEnum1): Integer;
begin
  Result := pbEncodeFieldInt32(Buf, BufSize, FieldNum, Ord(Value));
end;

function pbDecodeValueEnum1(const Buf; const BufSize: Integer; var Value: TEnum1): Integer;
var I : LongInt;
begin
  Result := pbDecodeValueInt32(Buf, BufSize, I);
  Value := TEnum1(I);
end;

procedure pbDecodeFieldEnum1(const Field: TpbProtoBufDecodeField; var Value: TEnum1);
var I : LongInt;
begin
  pbDecodeFieldInt32(Field, I);
  Value := TEnum1(I);
end;



{ TDynArrayInt32 }

function pbEncodeFieldDynArrayInt32(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayInt32): Integer;
var
  P : PByte;
  I, L, N : Integer;
begin
  P := @Buf;
  L := BufSize;
  for I := 0 to Length(Value) - 1 do
    begin
      N := pbEncodeFieldInt32(P^, L, FieldNum, Value[I]);
      Inc(P, N);
      Dec(L, N);
    end;
  Result := BufSize - L;
end;

function pbEncodeFieldDynArrayInt32_Packed(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayInt32): Integer;
var
  P : PByte;
  I, T, L, N : Integer;
begin
  P := @Buf;
  T := 0;
  for I := 0 to Length(Value) - 1 do
    Inc(T, pbEncodeValueInt32(P^, 0, Value[I]));
  L := BufSize;
  N := pbEncodeFieldVarBytesHdr(P^, L, FieldNum, T);
  Inc(P, N);
  Dec(L, N);
  for I := 0 to Length(Value) - 1 do
    begin
      N := pbEncodeValueInt32(P^, L, Value[I]);
      Inc(P, N);
      Dec(L, N);
    end;
  Result := BufSize - L;
end;

procedure pbDecodeFieldDynArrayInt32(const Field: TpbProtoBufDecodeField; var Value: TDynArrayInt32);
var
  L : Integer;
begin
  L := Length(Value);
  SetLength(Value, L + 1);
  pbDecodeFieldInt32(Field, Value[L]);
end;

procedure pbDecodeFieldDynArrayInt32_Packed(const Field: TpbProtoBufDecodeField; var Value: TDynArrayInt32);
var
  P : PByte;
  L, N, I : Integer;
begin
  P := Field.ValueVarBytesPtr;
  L := 0;
  N := Field.ValueVarBytesLen;
  while N > 0 do
    begin
      SetLength(Value, L + 1);
      I := pbDecodeValueInt32(P^, N, Value[L]);
      Inc(L);
      Inc(P, I);
      Dec(N, I);
    end;
end;



{ TDynArrayString }

function pbEncodeFieldDynArrayString(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayString): Integer;
var
  P : PByte;
  I, L, N : Integer;
begin
  P := @Buf;
  L := BufSize;
  for I := 0 to Length(Value) - 1 do
    begin
      N := pbEncodeFieldString(P^, L, FieldNum, Value[I]);
      Inc(P, N);
      Dec(L, N);
    end;
  Result := BufSize - L;
end;

function pbEncodeFieldDynArrayString_Packed(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayString): Integer;
var
  P : PByte;
  I, T, L, N : Integer;
begin
  P := @Buf;
  T := 0;
  for I := 0 to Length(Value) - 1 do
    Inc(T, pbEncodeValueString(P^, 0, Value[I]));
  L := BufSize;
  N := pbEncodeFieldVarBytesHdr(P^, L, FieldNum, T);
  Inc(P, N);
  Dec(L, N);
  for I := 0 to Length(Value) - 1 do
    begin
      N := pbEncodeValueString(P^, L, Value[I]);
      Inc(P, N);
      Dec(L, N);
    end;
  Result := BufSize - L;
end;

procedure pbDecodeFieldDynArrayString(const Field: TpbProtoBufDecodeField; var Value: TDynArrayString);
var
  L : Integer;
begin
  L := Length(Value);
  SetLength(Value, L + 1);
  pbDecodeFieldString(Field, Value[L]);
end;

procedure pbDecodeFieldDynArrayString_Packed(const Field: TpbProtoBufDecodeField; var Value: TDynArrayString);
var
  P : PByte;
  L, N, I : Integer;
begin
  P := Field.ValueVarBytesPtr;
  L := 0;
  N := Field.ValueVarBytesLen;
  while N > 0 do
    begin
      SetLength(Value, L + 1);
      I := pbDecodeValueString(P^, N, Value[L]);
      Inc(L);
      Inc(P, I);
      Dec(N, I);
    end;
end;



{ TDynArrayEnum1 }

function pbEncodeFieldDynArrayEnum1(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayEnum1): Integer;
var
  P : PByte;
  I, L, N : Integer;
begin
  P := @Buf;
  L := BufSize;
  for I := 0 to Length(Value) - 1 do
    begin
      N := pbEncodeFieldEnum1(P^, L, FieldNum, Value[I]);
      Inc(P, N);
      Dec(L, N);
    end;
  Result := BufSize - L;
end;

function pbEncodeFieldDynArrayEnum1_Packed(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayEnum1): Integer;
var
  P : PByte;
  I, T, L, N : Integer;
begin
  P := @Buf;
  T := 0;
  for I := 0 to Length(Value) - 1 do
    Inc(T, pbEncodeValueEnum1(P^, 0, Value[I]));
  L := BufSize;
  N := pbEncodeFieldVarBytesHdr(P^, L, FieldNum, T);
  Inc(P, N);
  Dec(L, N);
  for I := 0 to Length(Value) - 1 do
    begin
      N := pbEncodeValueEnum1(P^, L, Value[I]);
      Inc(P, N);
      Dec(L, N);
    end;
  Result := BufSize - L;
end;

procedure pbDecodeFieldDynArrayEnum1(const Field: TpbProtoBufDecodeField; var Value: TDynArrayEnum1);
var
  L : Integer;
begin
  L := Length(Value);
  SetLength(Value, L + 1);
  pbDecodeFieldEnum1(Field, Value[L]);
end;

procedure pbDecodeFieldDynArrayEnum1_Packed(const Field: TpbProtoBufDecodeField; var Value: TDynArrayEnum1);
var
  P : PByte;
  L, N, I : Integer;
begin
  P := Field.ValueVarBytesPtr;
  L := 0;
  N := Field.ValueVarBytesLen;
  while N > 0 do
    begin
      SetLength(Value, L + 1);
      I := pbDecodeValueEnum1(P^, N, Value[L]);
      Inc(L);
      Inc(P, I);
      Dec(N, I);
    end;
end;



{ TDynArrayTestMsg0Record }

function pbEncodeFieldDynArrayTestMsg0Record(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayTestMsg0Record): Integer;
var
  P : PByte;
  I, L, N : Integer;
begin
  P := @Buf;
  L := BufSize;
  for I := 0 to Length(Value) - 1 do
    begin
      N := pbEncodeFieldTestMsg0Record(P^, L, FieldNum, Value[I]);
      Inc(P, N);
      Dec(L, N);
    end;
  Result := BufSize - L;
end;

function pbEncodeFieldDynArrayTestMsg0Record_Packed(var Buf; const BufSize: Integer; const FieldNum: Integer; const Value: TDynArrayTestMsg0Record): Integer;
var
  P : PByte;
  I, T, L, N : Integer;
begin
  P := @Buf;
  T := 0;
  for I := 0 to Length(Value) - 1 do
    Inc(T, pbEncodeValueTestMsg0Record(P^, 0, Value[I]));
  L := BufSize;
  N := pbEncodeFieldVarBytesHdr(P^, L, FieldNum, T);
  Inc(P, N);
  Dec(L, N);
  for I := 0 to Length(Value) - 1 do
    begin
      N := pbEncodeValueTestMsg0Record(P^, L, Value[I]);
      Inc(P, N);
      Dec(L, N);
    end;
  Result := BufSize - L;
end;

procedure pbDecodeFieldDynArrayTestMsg0Record(const Field: TpbProtoBufDecodeField; var Value: TDynArrayTestMsg0Record);
var
  L : Integer;
begin
  L := Length(Value);
  SetLength(Value, L + 1);
  TestMsg0RecordInit(Value[L]);
  pbDecodeFieldTestMsg0Record(Field, Value[L]);
end;

procedure pbDecodeFieldDynArrayTestMsg0Record_Packed(const Field: TpbProtoBufDecodeField; var Value: TDynArrayTestMsg0Record);
var
  P : PByte;
  L, N, I : Integer;
begin
  P := Field.ValueVarBytesPtr;
  L := 0;
  N := Field.ValueVarBytesLen;
  while N > 0 do
    begin
      SetLength(Value, L + 1);
      TestMsg0RecordInit(Value[L]);
      I := pbDecodeValueTestMsg0Record(P^, N, Value[L]);
      Inc(L);
      Inc(P, I);
      Dec(N, I);
    end;
end;



{ TTestNested1Record }

procedure TestNested1RecordInit(var A: TTestNested1Record);
begin
  with A do
  begin
    Field1 := 0;
  end;
end;

procedure TestNested1RecordFinalise(var A: TTestNested1Record);
begin
  with A do
  begin
  end;
end;

function pbEncodeDataTestNested1Record(var Buf; const BufSize: Integer; const A: TTestNested1Record): Integer;
var
  P : PByte;
  L : Integer;
  I : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbEncodeFieldInt32(P^, L, 1, A.Field1);
  Dec(L, I);
  Result := BufSize - L;
end;

function pbEncodeValueTestNested1Record(var Buf; const BufSize: Integer; const A: TTestNested1Record): Integer;
var
  P : PByte;
  L, N, I : Integer;
begin
  P := @Buf;
  L := BufSize;
  N := pbEncodeDataTestNested1Record(P^, 0, A);
  I := pbEncodeValueInt32(P^, L, N);
  Inc(P, I);
  Dec(L, I);
  I := pbEncodeDataTestNested1Record(P^, L, A);
  Assert(I = N);
  Dec(L, I);
  Result := BufSize - L;
end;

function pbEncodeFieldTestNested1Record(var Buf; const BufSize: Integer; const FieldNum: Integer; const A: TTestNested1Record): Integer;
var
  P : PByte;
  L : Integer;
  I : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbEncodeFieldKey(P^, L, FieldNum, pwtVarBytes);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeValueTestNested1Record(P^, L, A);
  Dec(L, I);
  Result := BufSize - L;
end;

procedure pbDecodeFieldTestNested1Record_CallbackProc(const Field: TpbProtoBufDecodeField; const Data: Pointer);
var
  A : PTestNested1Record;
begin
  A := Data;
  case Field.FieldNum of
    1 : pbDecodeFieldInt32(Field, A^.Field1);
  end;
end;

function pbDecodeValueTestNested1Record(const Buf; const BufSize: Integer; var Value: TTestNested1Record): Integer;
var
  P : PByte;
  L, I, N : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbDecodeValueInt32(P^, L, N);
  Dec(L, I);
  Inc(P, I);
  pbDecodeProtoBuf(P^, N, pbDecodeFieldTestNested1Record_CallbackProc, @Value);
  Dec(L, N);
  Result := BufSize - L;
end;

procedure pbDecodeFieldTestNested1Record(const Field: TpbProtoBufDecodeField; var Value: TTestNested1Record);
begin
  pbDecodeProtoBuf(Field.ValueVarBytesPtr^, Field.ValueVarBytesLen, pbDecodeFieldTestNested1Record_CallbackProc, @Value);
end;



{ TTestMsg1Record }

procedure TestMsg1RecordInit(var A: TTestMsg1Record);
begin
  with A do
  begin
    DefField1 := 2;
    DefField2 := -1;
    DefField3 := 'yes';
    DefField4 := 1.1;
    DefField5 := True;
    DefField6 := enumg0G2;
    DefField7 := 100;
    DefField8 := 1;
    DefField9 := 12.3;
    TestMsg0RecordInit(FieldMsg1);
    FieldE1 := enum1Val1;
    FieldE2 := enum1Val2;
    TestNested1RecordInit(FieldNested1);
    TestNested1RecordInit(FieldNested2);
    FieldArr1 := nil;
    FieldArr2 := nil;
    FieldArr3 := nil;
    FieldArrE1 := nil;
    FieldMArr2 := nil;
    FieldImp1 := enumglobalGVal1;
    FieldImp2 := enumglobalGVal1;
  end;
end;

procedure TestMsg1RecordFinalise(var A: TTestMsg1Record);
begin
  with A do
  begin
    TestNested1RecordFinalise(FieldNested2);
    TestNested1RecordFinalise(FieldNested1);
    TestMsg0RecordFinalise(FieldMsg1);
  end;
end;

function pbEncodeDataTestMsg1Record(var Buf; const BufSize: Integer; const A: TTestMsg1Record): Integer;
var
  P : PByte;
  L : Integer;
  I : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbEncodeFieldInt32(P^, L, 1, A.DefField1);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldInt64(P^, L, 2, A.DefField2);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldString(P^, L, 3, A.DefField3);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldDouble(P^, L, 4, A.DefField4);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldBool(P^, L, 5, A.DefField5);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldEnumG0(P^, L, 6, A.DefField6);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldSInt64(P^, L, 7, A.DefField7);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldFixed32(P^, L, 8, A.DefField8);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldFloat(P^, L, 9, A.DefField9);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldTestMsg0Record(P^, L, 20, A.FieldMsg1);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldEnum1(P^, L, 21, A.FieldE1);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldEnum1(P^, L, 22, A.FieldE2);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldTestNested1Record(P^, L, 30, A.FieldNested1);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldTestNested1Record(P^, L, 31, A.FieldNested2);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldDynArrayInt32(P^, L, 40, A.FieldArr1);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldDynArrayInt32_Packed(P^, L, 41, A.FieldArr2);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldDynArrayString(P^, L, 42, A.FieldArr3);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldDynArrayEnum1(P^, L, 43, A.FieldArrE1);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldDynArrayTestMsg0Record(P^, L, 44, A.FieldMArr2);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldEnumGlobal(P^, L, 50, A.FieldImp1);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldEnumGlobal(P^, L, 51, A.FieldImp2);
  Dec(L, I);
  Result := BufSize - L;
end;

function pbEncodeValueTestMsg1Record(var Buf; const BufSize: Integer; const A: TTestMsg1Record): Integer;
var
  P : PByte;
  L, N, I : Integer;
begin
  P := @Buf;
  L := BufSize;
  N := pbEncodeDataTestMsg1Record(P^, 0, A);
  I := pbEncodeValueInt32(P^, L, N);
  Inc(P, I);
  Dec(L, I);
  I := pbEncodeDataTestMsg1Record(P^, L, A);
  Assert(I = N);
  Dec(L, I);
  Result := BufSize - L;
end;

function pbEncodeFieldTestMsg1Record(var Buf; const BufSize: Integer; const FieldNum: Integer; const A: TTestMsg1Record): Integer;
var
  P : PByte;
  L : Integer;
  I : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbEncodeFieldKey(P^, L, FieldNum, pwtVarBytes);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeValueTestMsg1Record(P^, L, A);
  Dec(L, I);
  Result := BufSize - L;
end;

procedure pbDecodeFieldTestMsg1Record_CallbackProc(const Field: TpbProtoBufDecodeField; const Data: Pointer);
var
  A : PTestMsg1Record;
begin
  A := Data;
  case Field.FieldNum of
    1 : pbDecodeFieldInt32(Field, A^.DefField1);
    2 : pbDecodeFieldInt64(Field, A^.DefField2);
    3 : pbDecodeFieldString(Field, A^.DefField3);
    4 : pbDecodeFieldDouble(Field, A^.DefField4);
    5 : pbDecodeFieldBool(Field, A^.DefField5);
    6 : pbDecodeFieldEnumG0(Field, A^.DefField6);
    7 : pbDecodeFieldSInt64(Field, A^.DefField7);
    8 : pbDecodeFieldFixed32(Field, A^.DefField8);
    9 : pbDecodeFieldFloat(Field, A^.DefField9);
    20 : pbDecodeFieldTestMsg0Record(Field, A^.FieldMsg1);
    21 : pbDecodeFieldEnum1(Field, A^.FieldE1);
    22 : pbDecodeFieldEnum1(Field, A^.FieldE2);
    30 : pbDecodeFieldTestNested1Record(Field, A^.FieldNested1);
    31 : pbDecodeFieldTestNested1Record(Field, A^.FieldNested2);
    40 : pbDecodeFieldDynArrayInt32(Field, A^.FieldArr1);
    41 : pbDecodeFieldDynArrayInt32_Packed(Field, A^.FieldArr2);
    42 : pbDecodeFieldDynArrayString(Field, A^.FieldArr3);
    43 : pbDecodeFieldDynArrayEnum1(Field, A^.FieldArrE1);
    44 : pbDecodeFieldDynArrayTestMsg0Record(Field, A^.FieldMArr2);
    50 : pbDecodeFieldEnumGlobal(Field, A^.FieldImp1);
    51 : pbDecodeFieldEnumGlobal(Field, A^.FieldImp2);
  end;
end;

function pbDecodeValueTestMsg1Record(const Buf; const BufSize: Integer; var Value: TTestMsg1Record): Integer;
var
  P : PByte;
  L, I, N : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbDecodeValueInt32(P^, L, N);
  Dec(L, I);
  Inc(P, I);
  pbDecodeProtoBuf(P^, N, pbDecodeFieldTestMsg1Record_CallbackProc, @Value);
  Dec(L, N);
  Result := BufSize - L;
end;

procedure pbDecodeFieldTestMsg1Record(const Field: TpbProtoBufDecodeField; var Value: TTestMsg1Record);
begin
  pbDecodeProtoBuf(Field.ValueVarBytesPtr^, Field.ValueVarBytesLen, pbDecodeFieldTestMsg1Record_CallbackProc, @Value);
end;



{ TTestIden1Record }

procedure TestIden1RecordInit(var A: TTestIden1Record);
begin
  with A do
  begin
    FieldNameTest1 := 0;
    FieldNameTest2 := 0;
  end;
end;

procedure TestIden1RecordFinalise(var A: TTestIden1Record);
begin
  with A do
  begin
  end;
end;

function pbEncodeDataTestIden1Record(var Buf; const BufSize: Integer; const A: TTestIden1Record): Integer;
var
  P : PByte;
  L : Integer;
  I : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbEncodeFieldInt32(P^, L, 1, A.FieldNameTest1);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeFieldInt32(P^, L, 2, A.FieldNameTest2);
  Dec(L, I);
  Result := BufSize - L;
end;

function pbEncodeValueTestIden1Record(var Buf; const BufSize: Integer; const A: TTestIden1Record): Integer;
var
  P : PByte;
  L, N, I : Integer;
begin
  P := @Buf;
  L := BufSize;
  N := pbEncodeDataTestIden1Record(P^, 0, A);
  I := pbEncodeValueInt32(P^, L, N);
  Inc(P, I);
  Dec(L, I);
  I := pbEncodeDataTestIden1Record(P^, L, A);
  Assert(I = N);
  Dec(L, I);
  Result := BufSize - L;
end;

function pbEncodeFieldTestIden1Record(var Buf; const BufSize: Integer; const FieldNum: Integer; const A: TTestIden1Record): Integer;
var
  P : PByte;
  L : Integer;
  I : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbEncodeFieldKey(P^, L, FieldNum, pwtVarBytes);
  Dec(L, I);
  Inc(P, I);
  I := pbEncodeValueTestIden1Record(P^, L, A);
  Dec(L, I);
  Result := BufSize - L;
end;

procedure pbDecodeFieldTestIden1Record_CallbackProc(const Field: TpbProtoBufDecodeField; const Data: Pointer);
var
  A : PTestIden1Record;
begin
  A := Data;
  case Field.FieldNum of
    1 : pbDecodeFieldInt32(Field, A^.FieldNameTest1);
    2 : pbDecodeFieldInt32(Field, A^.FieldNameTest2);
  end;
end;

function pbDecodeValueTestIden1Record(const Buf; const BufSize: Integer; var Value: TTestIden1Record): Integer;
var
  P : PByte;
  L, I, N : Integer;
begin
  P := @Buf;
  L := BufSize;
  I := pbDecodeValueInt32(P^, L, N);
  Dec(L, I);
  Inc(P, I);
  pbDecodeProtoBuf(P^, N, pbDecodeFieldTestIden1Record_CallbackProc, @Value);
  Dec(L, N);
  Result := BufSize - L;
end;

procedure pbDecodeFieldTestIden1Record(const Field: TpbProtoBufDecodeField; var Value: TTestIden1Record);
begin
  pbDecodeProtoBuf(Field.ValueVarBytesPtr^, Field.ValueVarBytesLen, pbDecodeFieldTestIden1Record_CallbackProc, @Value);
end;



end.

