program dbfix;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  libcrc32 in 'libcrc32.pas',
  libge.dbroot in 'libge.dbroot.pas',
  u_GeoCacherCache in 'u_GeoCacherCache.pas';

procedure DoDbRootFix(const AGeoCacherPath: string);
var
  VCount: Integer;
  VDbRootCache: TGeoCacherDbRootCache;
begin
  VDbRootCache := TGeoCacherDbRootCache.Create(AGeoCacherPath);
  try
    VCount := VDbRootCache.PatchAll;
    Writeln(Format('Processed %d files', [VCount]));
  finally
    VDbRootCache.Free;
  end;
end;

var
  VPath: string;
begin
  try
    if ParamCount > 0 then begin
      VPath := ParamStr(1);
    end else begin
      VPath := ExtractFilePath(ParamStr(0));
    end;
    
    Writeln(Format('Processing directory: "%s"', [VPath]));

    DoDbRootFix(VPath);
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end.
