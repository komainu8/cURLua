local luaunit = require("luaunit")
local libcurl = require("libcurl")

TestLibcurlEasy = {}
function TestLibcurlEasyInit.init()
  -- This is dummy
  luaunit.assertEquals(libcurl.easy_init(), true)
end
