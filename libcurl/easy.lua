local ffi = require("ffi")

ffi.cdef[[
CURLcode curl_global_init(long flags);
CURL_EXTERN CURL *curl_easy_init(void);
void curl_easy_cleanup(CURL *data);
CURLcode curl_easy_setopt(struct Curl_easy *data, CURLoption tag, ...);
CURL_EXTERN CURLcode curl_easy_perform(CURL *curl);
]]
