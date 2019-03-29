local libcurl = {}

require("libcurl.curl")
require("libcurl.easy")

local ffi = require("ffi")
local loaded, curl = pcall(ffi.load, "curl")
if not loaded then
  curl = ffi.load("libcurl.so.4")
end

function libcurl.easy_init()
  return curl.curl_easy_init()
end

return libcurl
