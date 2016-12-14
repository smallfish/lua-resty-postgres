-- Copyright (C) Chen Xiaoyu (smallfish)

local ffi    = require 'ffi'
local ffistr = ffi.string

local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end

ffi.cdef([[
typedef unsigned int Oid;
typedef long int pg_int64;
typedef enum
{
	CONNECTION_OK,
	CONNECTION_BAD,
	CONNECTION_STARTED,			
	CONNECTION_MADE,			
	CONNECTION_AWAITING_RESPONSE,
	CONNECTION_AUTH_OK,	
	CONNECTION_SETENV,			
	CONNECTION_SSL_STARTUP,		
	CONNECTION_NEEDED			
} ConnStatusType;
typedef enum
{
	PGRES_POLLING_FAILED = 0,
	PGRES_POLLING_READING,		
	PGRES_POLLING_WRITING,		
	PGRES_POLLING_OK,
	PGRES_POLLING_ACTIVE
} PostgresPollingStatusType;
typedef enum
{
	PGRES_EMPTY_QUERY = 0,		
	PGRES_COMMAND_OK,
	PGRES_TUPLES_OK,
	PGRES_COPY_OUT,				
	PGRES_COPY_IN,				
	PGRES_BAD_RESPONSE,
	PGRES_NONFATAL_ERROR,		
	PGRES_FATAL_ERROR,			
	PGRES_COPY_BOTH,			
	PGRES_SINGLE_TUPLE			
} ExecStatusType;
typedef enum
{
	PQTRANS_IDLE,				
	PQTRANS_ACTIVE,				
	PQTRANS_INTRANS,			
	PQTRANS_INERROR,			
	PQTRANS_UNKNOWN				
} PGTransactionStatusType;
typedef enum
{
	PQERRORS_TERSE,				
	PQERRORS_DEFAULT,			
	PQERRORS_VERBOSE			
} PGVerbosity;
typedef enum
{
	PQSHOW_CONTEXT_NEVER,		
	PQSHOW_CONTEXT_ERRORS,		
	PQSHOW_CONTEXT_ALWAYS		
} PGContextVisibility;
typedef enum
{
	PQPING_OK,					
	PQPING_REJECT,				
	PQPING_NO_RESPONSE,			
	PQPING_NO_ATTEMPT			
} PGPing;
typedef struct pg_conn PGconn;
typedef struct pg_result PGresult;
typedef struct pg_cancel PGcancel;
typedef struct pgNotify
{
	char	   *relname;		
	int	   be_pid;			
	char	   *extra;			
	struct pgNotify *next;		
} PGnotify;
typedef void (*PQnoticeReceiver) (void *arg, const PGresult *res);
typedef void (*PQnoticeProcessor) (void *arg, const char *message);
typedef char pqbool;
typedef struct _PQprintOpt
{
	pqbool	header;			
	pqbool	align;			
	pqbool	standard;		
	pqbool	html3;			
	pqbool	expanded;		
	pqbool	pager;			
	char	*fieldSep;		
	char	*tableOpt;		
	char	*caption;		
	char	 **fieldName;
} PQprintOpt;
typedef struct _PQconninfoOption
{
	char	*keyword;		
	char	*envvar;			
	char	*compiled;		
	char	*val;			
	char	*label;			
	char	*dispchar;
	int	dispsize;		
} PQconninfoOption;
typedef struct
{
	int	len;
	int	isint;
	union
	{
		int     *ptr;		
		int	integer;
	}			u;
} PQArgBlock;
typedef struct pgresAttDesc
{
	char	*name;			
	Oid	tableid;		
	int	columnid;		
	int	format;			
	Oid	typid;			
	int	typlen;			
	int	atttypmod;		
} PGresAttDesc;
extern PGconn *PQconnectStart(const char *conninfo);
extern PGconn *PQconnectStartParams(const char *const * keywords, const char *const * values, int expand_dbname);
extern PostgresPollingStatusType PQconnectPoll(PGconn *conn);
extern PGconn *PQconnectdb(const char *conninfo);
extern PGconn *PQconnectdbParams(const char *const * keywords, const char *const * values, int expand_dbname);
extern PGconn *PQsetdbLogin(const char *pghost, const char *pgport, const char *pgoptions, const char *pgtty, const char *dbName, const char *login, const char *pwd);
extern void PQfinish(PGconn *conn);
extern PQconninfoOption *PQconndefaults(void);
extern PQconninfoOption *PQconninfoParse(const char *conninfo, char **errmsg);
extern PQconninfoOption *PQconninfo(PGconn *conn);
extern void PQconninfoFree(PQconninfoOption *connOptions);
extern int	PQresetStart(PGconn *conn);
extern PostgresPollingStatusType PQresetPoll(PGconn *conn);
extern void PQreset(PGconn *conn);
extern PGcancel *PQgetCancel(PGconn *conn);
extern void PQfreeCancel(PGcancel *cancel);
extern int	PQcancel(PGcancel *cancel, char *errbuf, int errbufsize);
extern int	PQrequestCancel(PGconn *conn);
extern char *PQdb(const PGconn *conn);
extern char *PQuser(const PGconn *conn);
extern char *PQpass(const PGconn *conn);
extern char *PQhost(const PGconn *conn);
extern char *PQport(const PGconn *conn);
extern char *PQtty(const PGconn *conn);
extern char *PQoptions(const PGconn *conn);
extern ConnStatusType PQstatus(const PGconn *conn);
extern PGTransactionStatusType PQtransactionStatus(const PGconn *conn);
extern const char *PQparameterStatus(const PGconn *conn, const char *paramName);
extern int	PQprotocolVersion(const PGconn *conn);
extern int	PQserverVersion(const PGconn *conn);
extern char *PQerrorMessage(const PGconn *conn);
extern int	PQsocket(const PGconn *conn);
extern int	PQbackendPID(const PGconn *conn);
extern int	PQconnectionNeedsPassword(const PGconn *conn);
extern int	PQconnectionUsedPassword(const PGconn *conn);
extern int	PQclientEncoding(const PGconn *conn);
extern int	PQsetClientEncoding(PGconn *conn, const char *encoding);
extern int	PQsslInUse(PGconn *conn);
extern void *PQsslStruct(PGconn *conn, const char *struct_name);
extern const char *PQsslAttribute(PGconn *conn, const char *attribute_name);
extern const char *const * PQsslAttributeNames(PGconn *conn);
extern void *PQgetssl(PGconn *conn);
extern void PQinitSSL(int do_init);
extern void PQinitOpenSSL(int do_ssl, int do_crypto);
extern PGVerbosity PQsetErrorVerbosity(PGconn *conn, PGVerbosity verbosity);
extern PGContextVisibility PQsetErrorContextVisibility(PGconn *conn, PGContextVisibility show_context);
extern void PQuntrace(PGconn *conn);
extern PQnoticeReceiver PQsetNoticeReceiver(PGconn *conn, PQnoticeReceiver proc, void *arg);
extern PQnoticeProcessor PQsetNoticeProcessor(PGconn *conn, PQnoticeProcessor proc, void *arg);
typedef void (*pgthreadlock_t) (int acquire);
extern pgthreadlock_t PQregisterThreadLock(pgthreadlock_t newhandler);
extern PGresult *PQexec(PGconn *conn, const char *query);
extern PGresult *PQexecParams(PGconn *conn, const char *command, int nParams, const Oid *paramTypes, const char *const * paramValues, const int *paramLengths, const int *paramFormats, int resultFormat);
extern PGresult *PQprepare(PGconn *conn, const char *stmtName, const char *query, int nParams, const Oid *paramTypes);
extern PGresult *PQexecPrepared(PGconn *conn, const char *stmtName, int nParams, const char *const * paramValues, const int *paramLengths, const int *paramFormats, int resultFormat);
extern int	PQsendQuery(PGconn *conn, const char *query);
extern int PQsendQueryParams(PGconn *conn, const char *command, int nParams, const Oid *paramTypes, const char *const * paramValues, const int *paramLengths, const int *paramFormats, int resultFormat);
extern int PQsendPrepare(PGconn *conn, const char *stmtName, const char *query, int nParams, const Oid *paramTypes);
extern int PQsendQueryPrepared(PGconn *conn, const char *stmtName, int nParams, const char *const * paramValues, const int *paramLengths, const int *paramFormats, int resultFormat);
extern int	PQsetSingleRowMode(PGconn *conn);
extern PGresult *PQgetResult(PGconn *conn);
extern int	PQisBusy(PGconn *conn);
extern int	PQconsumeInput(PGconn *conn);
extern PGnotify *PQnotifies(PGconn *conn);
extern int	PQputCopyData(PGconn *conn, const char *buffer, int nbytes);
extern int	PQputCopyEnd(PGconn *conn, const char *errormsg);
extern int	PQgetCopyData(PGconn *conn, char **buffer, int async);
extern int	PQgetline(PGconn *conn, char *string, int length);
extern int	PQputline(PGconn *conn, const char *string);
extern int	PQgetlineAsync(PGconn *conn, char *buffer, int bufsize);
extern int	PQputnbytes(PGconn *conn, const char *buffer, int nbytes);
extern int	PQendcopy(PGconn *conn);
extern int	PQsetnonblocking(PGconn *conn, int arg);
extern int	PQisnonblocking(const PGconn *conn);
extern int	PQisthreadsafe(void);
extern PGPing PQping(const char *conninfo);
extern PGPing PQpingParams(const char *const * keywords, const char *const * values, int expand_dbname);
extern int	PQflush(PGconn *conn);
extern PGresult *PQfn(PGconn *conn, int fnid, int *result_buf, int *result_len, int result_is_int, const PQArgBlock *args, int nargs);
extern ExecStatusType PQresultStatus(const PGresult *res);
extern char *PQresStatus(ExecStatusType status);
extern char *PQresultErrorMessage(const PGresult *res);
extern char *PQresultVerboseErrorMessage(const PGresult *res, PGVerbosity verbosity, PGContextVisibility show_context);
extern char *PQresultErrorField(const PGresult *res, int fieldcode);
extern int	PQntuples(const PGresult *res);
extern int	PQnfields(const PGresult *res);
extern int	PQbinaryTuples(const PGresult *res);
extern char *PQfname(const PGresult *res, int field_num);
extern int	PQfnumber(const PGresult *res, const char *field_name);
extern Oid	PQftable(const PGresult *res, int field_num);
extern int	PQftablecol(const PGresult *res, int field_num);
extern int	PQfformat(const PGresult *res, int field_num);
extern Oid	PQftype(const PGresult *res, int field_num);
extern int	PQfsize(const PGresult *res, int field_num);
extern int	PQfmod(const PGresult *res, int field_num);
extern char *PQcmdStatus(PGresult *res);
extern char *PQoidStatus(const PGresult *res);	
extern Oid	PQoidValue(const PGresult *res);	
extern char *PQcmdTuples(PGresult *res);
extern char *PQgetvalue(const PGresult *res, int tup_num, int field_num);
extern int	PQgetlength(const PGresult *res, int tup_num, int field_num);
extern int	PQgetisnull(const PGresult *res, int tup_num, int field_num);
extern int	PQnparams(const PGresult *res);
extern Oid	PQparamtype(const PGresult *res, int param_num);
extern PGresult *PQdescribePrepared(PGconn *conn, const char *stmt);
extern PGresult *PQdescribePortal(PGconn *conn, const char *portal);
extern int	PQsendDescribePrepared(PGconn *conn, const char *stmt);
extern int	PQsendDescribePortal(PGconn *conn, const char *portal);
extern void PQclear(PGresult *res);
extern void PQfreemem(void *ptr);
extern PGresult *PQmakeEmptyPGresult(PGconn *conn, ExecStatusType status);
extern PGresult *PQcopyResult(const PGresult *src, int flags);
extern int	PQsetResultAttrs(PGresult *res, int numAttributes, PGresAttDesc *attDescs);
extern void *PQresultAlloc(PGresult *res, size_t nBytes);
extern int	PQsetvalue(PGresult *res, int tup_num, int field_num, char *value, int len);
extern size_t PQescapeStringConn(PGconn *conn, char *to, const char *from, size_t length, int *error);
extern char *PQescapeLiteral(PGconn *conn, const char *str, size_t len);
extern char *PQescapeIdentifier(PGconn *conn, const char *str, size_t len);
extern unsigned char *PQescapeByteaConn(PGconn *conn, const unsigned char *from, size_t from_length, size_t *to_length);
extern unsigned char *PQunescapeBytea(const unsigned char *strtext, size_t *retbuflen);
extern size_t PQescapeString(char *to, const char *from, size_t length);
extern unsigned char *PQescapeBytea(const unsigned char *from, size_t from_length, size_t *to_length);
extern int	lo_open(PGconn *conn, Oid lobjId, int mode);
extern int	lo_close(PGconn *conn, int fd);
extern int	lo_read(PGconn *conn, int fd, char *buf, size_t len);
extern int	lo_write(PGconn *conn, int fd, const char *buf, size_t len);
extern int	lo_lseek(PGconn *conn, int fd, int offset, int whence);
extern pg_int64 lo_lseek64(PGconn *conn, int fd, pg_int64 offset, int whence);
extern Oid	lo_creat(PGconn *conn, int mode);
extern Oid	lo_create(PGconn *conn, Oid lobjId);
extern int	lo_tell(PGconn *conn, int fd);
extern pg_int64 lo_tell64(PGconn *conn, int fd);
extern int	lo_truncate(PGconn *conn, int fd, size_t len);
extern int	lo_truncate64(PGconn *conn, int fd, pg_int64 len);
extern int	lo_unlink(PGconn *conn, Oid lobjId);
extern Oid	lo_import(PGconn *conn, const char *filename);
extern Oid	lo_import_with_oid(PGconn *conn, const char *filename, Oid lobjId);
extern int	lo_export(PGconn *conn, Oid lobjId, const char *filename);
extern int	PQlibVersion(void);
extern int	PQmblen(const char *s, int encoding);
extern int	PQdsplen(const char *s, int encoding);
extern int	PQenv2encoding(void);
extern char     *PQencryptPassword(const char *passwd, const char *user);
extern int	pg_char_to_encoding(const char *name);
extern const char *pg_encoding_to_char(int encoding);
extern int	pg_valid_server_encoding_id(int encoding);
]])

local libpq = ffi.load('libpq')

local _M = { _VERSION = '0.01' }

local mt = { __index = _M }

function _M.connect(self, conninfo)
    local db = libpq.PQconnectdb(conninfo)

    local err = ffistr(libpq.PQerrorMessage(db))
    if err == '' then
        err = nil
    end

    return setmetatable({ db = db }, mt), err
end

function _M.version(self)
    local db = self.db
    if db == nil then
        return {}, 'db object not init and connected'
    end

    return {lib = libpq.PQlibVersion(), server = libpq.PQserverVersion(db)}
end

function _M.errmsg(self)
    local db = self.db
    if db == nil then
        return 0, 'db object not init and connected'
    end

    local err = ffistr(libpq.PQerrorMessage(db))
    if err == '' then
        return nil
    end

    return err
end

function _M.query(self, query)
    local db = self.db
    if db == nil then
        return 0, 'db object not init and connected'
    end

    local exec = libpq.PQexec(db, query)

    local err = self:errmsg()
    if err ~= nil then
        return nil, err
    end

    local fields_len = libpq.PQnfields(exec)
    local fields     = new_tab(fields_len, 0)

    for i=1, fields_len do
        fields[i] = ffistr(libpq.PQfname(exec, i-1))
    end

    local rows_len = libpq.PQntuples(exec)
    local rows     = new_tab(rows_len, 0)

    for i=1, rows_len do
        local row = {}
        for j=1, fields_len do
            local name  = fields[j]
            local ftype = libpq.PQftype(exec, j-1)
            local val = ffistr(libpq.PQgetvalue(exec, i-1, j-1))
            if ftype == 23 or ftype == 701 then -- TODO: add some type convert
                val = tonumber(val)
            end
            row[name] = val
        end
        rows[i] = row
    end

    libpq.PQclear(exec)

    return rows, nil
end

function _M.execute(self, query)
    local db = self.db
    if db == nil then
        return 0, 'db object not init and connected'
    end

    local exec = libpq.PQexec(db, query)
    local err  = self:errmsg()

    if err ~= nil then
        return 0, nil
    end

    local num = libpq.PQntuples(exec) -- TODO: always return 0

    libpq.PQclear(exec)

    return num, nil
end

function _M.close(self)
    if self.db then
        libpq.PQfinish(self.db)
    end
    self.db = nil
end

return _M
