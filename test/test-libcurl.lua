local luaunit = require("luaunit")
local libcurl = require("libcurl")
local ffi = require("ffi")

TestLibcurl = {}

function TestLibcurl.test_east_init()
  luaunit.assertEquals(ffi.typeof(libcurl.easy_init()),
                       ffi.typeof("CURL *"))
end
