unit libge.dbroot;

interface

const
  libge_dbroot_dll = 'libge.dbroot.dll';

type
  size_t = Cardinal;
  uint32_t = Cardinal;

  dbroot_t = record
    obj: Pointer;
    error: PAnsiChar;
  end;

  string_t = record
    data: Pointer;
    size: size_t;
  end;

function dbroot_open(const data: Pointer; const length: size_t; out dbroot: dbroot_t): Boolean; cdecl; external libge_dbroot_dll;
function dbroot_close(var dbroot: dbroot_t): Boolean; cdecl; external libge_dbroot_dll;

function dbroot_get_quadtree_version(out version: uint32_t; var dbroot: dbroot_t): Boolean; cdecl; external libge_dbroot_dll;
function dbroot_set_quadtree_version(const version: uint32_t; var dbroot: dbroot_t): Boolean; cdecl; external libge_dbroot_dll;

function dbroot_set_use_ge_logo(const val: Boolean; var dbroot: dbroot_t): Boolean; cdecl; external libge_dbroot_dll;
function dbroot_set_max_requests_per_query(const val: uint32_t; var dbroot: dbroot_t): Boolean; cdecl; external libge_dbroot_dll;
function dbroot_set_discoverability_altitude_meters(const val: uint32_t; var dbroot: dbroot_t): Boolean; cdecl; external libge_dbroot_dll;

function dbroot_clear_copyright_string(out cleared_count: uint32_t; var dbroot: dbroot_t): Boolean; cdecl; external libge_dbroot_dll;

function dbroot_pack(var str: string_t; var dbroot: dbroot_t): Boolean; cdecl; external libge_dbroot_dll;

implementation

end.
