local ffi = require("ffi")

ffi.cdef[[
CURL_EXTERN CURL *curl_easy_init(void);
void curl_easy_cleanup(CURL *data);
CURLcode curl_easy_setopt(struct Curl_easy *data, CURLoption tag, ...);
]]
