local luaunit = require("luaunit")
local libcurl = require("libcurl")
local ffi = require("ffi")

TestLibcurl = {}

function TestLibcurl.test_easy_init()
  local curl = libcurl.easy_init()
  luaunit.assertEquals(ffi.typeof(curl),
                       ffi.typeof("CURL *"))
  libcurl.easy_cleanup(curl)
end

function TestLibcurl.test_global_init()
  libcurl.global_init(1)
end

function TestLibcurl.test_easy_setopt()
  local curl = libcurl.easy_init()
  local result =
    libcurl.easy_setopt(curl, ffi.C.CURLOPT_URL, "http://example.com")
  luaunit.assertEquals(tonumber(result), ffi.C.CURLE_OK)
  libcurl.easy_cleanup(curl)
end

function TestLibcurl.test_easy_perform()
  local curl = libcurl.easy_init()
  libcurl.easy_setopt(curl, ffi.C.CURLOPT_URL, "http://localhost")
  local response = libcurl.easy_perform(curl)
  luaunit.assertEquals(tonumber(response), ffi.C.CURLE_COULDNT_CONNECT)
  libcurl.easy_cleanup(curl)
end
