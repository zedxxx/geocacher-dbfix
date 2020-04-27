unit u_GeoCacherCache;

interface

uses
  Classes,
  SysUtils;

const
  CFakeVersion = $2020;

type
  TGeoCacherDbRootCache = class
  private
    FRootPath: string;

    function DoPatchProto(const AFileName: string): Cardinal;
    function DoPatchXml(const AFileName: string): Cardinal;
    procedure DoUpdateIni(const AFileName: string; const ACrc32: Cardinal);
  public
    function PatchAll: Integer;
  public
    constructor Create(const ARootPath: string);
  end;

implementation

uses
  IniFiles,
  libcrc32,
  libge.dbroot;

{ TGeoCacherDbRootCache }

constructor TGeoCacherDbRootCache.Create(const ARootPath: string);
begin
  inherited Create;

  FRootPath := IncludeTrailingPathDelimiter(ARootPath) + 'cache\dbroot\earth';
end;

function TGeoCacherDbRootCache.PatchAll: Integer;
var
  VPath: string;
  VName: string;
  VCrc32: Cardinal;
  VSearch: TSearchRec;
begin
  Result := 0;
  VPath := IncludeTrailingPathDelimiter(FRootPath);

  if FindFirst(VPath + '*.ini', faAnyFile - faDirectory, VSearch) = 0 then
  try
    repeat
      VName := VPath + ChangeFileExt(VSearch.Name, '');
      if FileExists(VName) then begin
        if Pos('output=proto', LowerCase(VName)) > 0 then begin
          VCrc32 := DoPatchProto(VName);
        end else begin
          VCrc32 := DoPatchXml(VName);
        end;
        if VCrc32 <> 0 then begin
          DoUpdateIni(VName + '.ini', VCrc32);
          Inc(Result);
        end;
      end else begin
        Assert(False, 'Can''t locate dbRoot for ini: ' +  VName + '.ini');
        //DeleteFile(VName + '.ini');
      end;
    until FindNext(VSearch) <> 0;
  finally
    FindClose(VSearch);
  end;
end;

function TGeoCacherDbRootCache.DoPatchProto(const AFileName: string): Cardinal;
var
  VStr: string_t;
  VRoot: dbroot_t;
  VStream: TMemoryStream;
  VIsPatched: Boolean;
begin
  Result := 0;
  VIsPatched := False;

  VStream := TMemoryStream.Create;
  try
    VStream.LoadFromFile(AFileName);

    if dbroot_open(VStream.Memory, VStream.Size, VRoot) then begin
      try
        if dbroot_set_quadtree_version(CFakeVersion, VRoot) then begin
          if dbroot_pack(VStr, VRoot) then begin
            VStream.Clear;
            VStream.WriteBuffer(VStr.data^, VStr.size);
            VIsPatched := True;
          end else begin
            Assert(False, string(VRoot.error));
          end;
        end else begin
          Assert(False, string(VRoot.error));
        end;
      finally
        if not dbroot_close(VRoot) then begin
          Assert(False, string(VRoot.error));
        end;
      end;
    end else begin
      Assert(False, string(VRoot.error));
    end;

    if VIsPatched then begin
      Result := crc32(0, VStream.Memory, VStream.Size);
      VStream.SaveToFile(AFileName);
    end;
  finally
    VStream.Free;
  end;
end;

type
  TXmlDbRootHeader = packed record
    MagicId: Cardinal;
    Unknown: Word;
    Version: Word;
  end;
  PXmlDbRootHeader = ^TXmlDbRootHeader;

const
  CXmlDbRootMagic = $4E876494;

function TGeoCacherDbRootCache.DoPatchXml(const AFileName: string): Cardinal;
var
  VHeader: PXmlDbRootHeader;
  VStream: TMemoryStream;
  VIsPatched: Boolean;
begin
  Result := 0;
  VIsPatched := False;

  VStream := TMemoryStream.Create;
  try
    VStream.LoadFromFile(AFileName);

    if VStream.Size > SizeOf(TXmlDbRootHeader) then begin
      VHeader := PXmlDbRootHeader(VStream.Memory);
      if VHeader.MagicId = CXmlDbRootMagic then begin
        VHeader.Version := $4200 xor CFakeVersion;
        VIsPatched := True;
      end;
    end;

    if VIsPatched then begin
      Result := crc32(0, VStream.Memory, VStream.Size);
      VStream.SaveToFile(AFileName);
    end;
  finally
    VStream.Free;
  end;
end;

procedure TGeoCacherDbRootCache.DoUpdateIni(const AFileName: string; const ACrc32: Cardinal);
var
  VIniFile: TMemIniFile;
begin
  VIniFile := TMemIniFile.Create(AFileName);
  try
    VIniFile.WriteString('Main', 'CRC32', '$' + IntToHex(ACrc32, 8));
    VIniFile.DeleteKey('Main', 'LastModified');
    VIniFile.UpdateFile;
  finally
    VIniFile.Free;
  end;
end;

end.
