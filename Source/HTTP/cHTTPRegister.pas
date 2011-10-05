{$INCLUDE cDefines.inc}

unit cHTTPRegister;

interface

procedure Register;

implementation

uses
  Classes,
  cHTTPClient,
  cHTTPServer;

procedure Register;
begin
  RegisterComponents('Fundamentals', [
      TFnd4HTTPClient,
      TFnd4HTTPServer]);
end;



end.
