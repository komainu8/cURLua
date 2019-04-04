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

function TestLibcurl.test_easy_setopt()
  local curl = libcurl.easy_init()
  local result = libcurl.easy_setopt(curl, 10002, "http://example.com")
  luaunit.assertEquals(tonumber(result),0)
  libcurl.easy_cleanup(curl)
end
