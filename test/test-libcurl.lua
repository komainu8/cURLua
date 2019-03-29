local luaunit = require("luaunit")
local libcurl = require("libcurl")
local ffi = require("ffi")

TestLibcurl = {}

function TestLibcurl.test_east_init()
  local curl = libcurl.easy_init()
  luaunit.assertEquals(ffi.typeof(curl),
                       ffi.typeof("CURL *"))
  libcurl.easy_cleanup(curl)
end
