unit cProtoBufProtoParserSelfTest;

interface



procedure SelfTest;



implementation

uses
  cProtoBufProtoNodes,
  cProtoBufProtoParser;



const
  CRLF = #$D#$A;

  ProtoText1 =
      'message test { ' +
      '  required int32 field1 = 1; ' +
      '} ';
  ProtoText1_ProtoString =
      'message test {' + CRLF +
      'required int32 field1 = 1;' +
      '}' + CRLF;

procedure SelfTest;
var
  P : TpbProtoParser;
  A : TpbProtoPackage;
begin
  P := TpbProtoParser.Create;
  P.SetTextStr(ProtoText1);
  A := P.Parse(GetDefaultProtoNodeFactory);
  Assert(Assigned(A));
  Assert(A.GetAsProtoString = ProtoText1_ProtoString);
  P.Free;
end;



end.

