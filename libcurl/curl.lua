local ffi = require("ffi")
local lcpp = require("lcpp")

ffi.cdef[[
#define CURL_EXTERN
typedef struct Curl_easy CURL;

void curl_easy_cleanup(CURL *data);
]]
