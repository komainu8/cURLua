local ffi = require("ffi")

ffi.cdef[[
CURL_EXTERN CURL *curl_easy_init(void);
]]
