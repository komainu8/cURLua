local libcurl = {}

require("libcurl.easy")

local ffi = require("ffi")
local loaded, culr = pcall(ffi.load, "culr")
if not loaded then
  culr = ffi.load("libculr.so.2")
end

function libcurl.easy_init()
  return curl.easy_init()
end
