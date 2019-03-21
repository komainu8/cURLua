#!/usr/bin/env luajit

require("test.test-libcurl")

luaunit = require("luaunit")
os.exit(luaunit.LuaUnit.run())
