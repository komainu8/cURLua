local ffi = require("ffi")
local lcpp = require("lcpp")

ffi.cdef[[
typedef struct Curl_easy CURL;
#define CURL_EXTERN
]]
