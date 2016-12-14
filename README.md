Name
====

lua-resty-postgres - Lua PostgreSQL client library, based on LuaJIT/libpq

Status
======

This library is considered experimental and still under active development.

The API is still in flux and may change without notice.

Synopsis
========

```lua

local cjson    = require 'cjson'
local postgres = require 'resty.postgres'

local strfmt   = string.format

local db, err = postgres:connect('host=localhost user=xx dbname=xx')
if err then
    -- has error, exit
end

local version, err = db:version()
if not err then
    print(cjson.encode(version))
    -- out:
    -- {"lib":90601, "server":90601}
end

local rows, err = db:query('SELECT tableowner, tablename FROM pg_tables LIMIT 2')
if not err then
    print(cjson.encode(rows))
    -- out:
    -- [{"tablename":"products","tableowner":"xx"},{"tablename":"pg_statistic","tableowner":"postgres"}}]
end

local num, err = db:execute("UPDATE xx SET xx='hahaha' WHERE xx=xx")
-- check error
if not err then
    print('update rows:' .. num)
end

db:close()
```

Dependencies
============

This library depends on the following Lua libraries:

* [LuaJIT](http://luajit.org/ext_ffi.html)
* [libpq - PostgreSQL C Library](https://www.postgresql.org/docs/current/static/libpq.html)

[Back to TOC](#table-of-contents)

Author
======

Copyright (C) 2016, by Chen "smallfish" Xiaoyu (陈小玉) <smallfish.xy@gmail.com>

[Back to TOC](#table-of-contents)

