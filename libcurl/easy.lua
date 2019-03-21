local ffi = require("ffi")

ffi.cdef[[
struct connectdata {
  /* 'data' is the CURRENT Curl_easy using this connection -- take great
     caution that this might very well vary between different times this
     connection is used! */
  struct Curl_easy *data;

  struct curl_llist_element bundle_node; /* conncache */

  /* chunk is for HTTP chunked encoding, but is in the general connectdata
     struct only because we can do just about any protocol through a HTTP proxy
     and a HTTP proxy may in fact respond using chunked encoding */
  struct Curl_chunker chunk;

  curl_closesocket_callback fclosesocket; /* function closing the socket(s) */
  void *closesocket_client;

  /* This is used by the connection cache logic. If this returns TRUE, this
     handle is being used by one or more easy handles and can only used by any
     other easy handle without careful consideration (== only for
     pipelining/multiplexing) and it cannot be used by another multi
     handle! */
#define CONN_INUSE(c) ((c)->send_pipe.size + (c)->recv_pipe.size)

  /**** Fields set when inited and not modified again */
  long connection_id; /* Contains a unique number to make it easier to
                         track the connections in the log output */

  /* 'dns_entry' is the particular host we use. This points to an entry in the
     DNS cache and it will not get pruned while locked. It gets unlocked in
     Curl_done(). This entry will be NULL if the connection is re-used as then
     there is no name resolve done. */
  struct Curl_dns_entry *dns_entry;

  /* 'ip_addr' is the particular IP we connected to. It points to a struct
     within the DNS cache, so this pointer is only valid as long as the DNS
     cache entry remains locked. It gets unlocked in Curl_done() */
  Curl_addrinfo *ip_addr;
  Curl_addrinfo *tempaddr[2]; /* for happy eyeballs */

  /* 'ip_addr_str' is the ip_addr data as a human readable string.
     It remains available as long as the connection does, which is longer than
     the ip_addr itself. */
  char ip_addr_str[MAX_IPADR_LEN];

  unsigned int scope_id;  /* Scope id for IPv6 */

  int socktype;  /* SOCK_STREAM or SOCK_DGRAM */

  struct hostname host;
  char *hostname_resolve; /* host name to resolve to address, allocated */
  char *secondaryhostname; /* secondary socket host name (ftp) */
  struct hostname conn_to_host; /* the host to connect to. valid only if
                                   bits.conn_to_host is set */

  struct proxy_info socks_proxy;
  struct proxy_info http_proxy;

  long port;       /* which port to use locally */
  int remote_port; /* the remote port, not the proxy port! */
  int conn_to_port; /* the remote port to connect to. valid only if
                       bits.conn_to_port is set */
  unsigned short secondary_port; /* secondary socket remote port to connect to
                                    (ftp) */

  /* 'primary_ip' and 'primary_port' get filled with peer's numerical
     ip address and port number whenever an outgoing connection is
     *attempted* from the primary socket to a remote address. When more
     than one address is tried for a connection these will hold data
     for the last attempt. When the connection is actually established
     these are updated with data which comes directly from the socket. */

  char primary_ip[MAX_IPADR_LEN];
  long primary_port;

  /* 'local_ip' and 'local_port' get filled with local's numerical
     ip address and port number whenever an outgoing connection is
     **established** from the primary socket to a remote address. */

  char local_ip[MAX_IPADR_LEN];
  long local_port;

  char *user;    /* user name string, allocated */
  char *passwd;  /* password string, allocated */
  char *options; /* options string, allocated */

  char *oauth_bearer; /* bearer token for OAuth 2.0, allocated */

  int httpversion;        /* the HTTP version*10 reported by the server */
  int rtspversion;        /* the RTSP version*10 reported by the server */

  struct curltime now;     /* "current" time */
  struct curltime created; /* creation time */
  curl_socket_t sock[2]; /* two sockets, the second is used for the data
                            transfer when doing FTP */
  curl_socket_t tempsock[2]; /* temporary sockets for happy eyeballs */
  bool sock_accepted[2]; /* TRUE if the socket on this index was created with
                            accept() */
  Curl_recv *recv[2];
  Curl_send *send[2];

#ifdef USE_RECV_BEFORE_SEND_WORKAROUND
  struct postponed_data postponed[2]; /* two buffers for two sockets */
#endif /* USE_RECV_BEFORE_SEND_WORKAROUND */
  struct ssl_connect_data ssl[2]; /* this is for ssl-stuff */
  struct ssl_connect_data proxy_ssl[2]; /* this is for proxy ssl-stuff */
#ifdef USE_SSL
  void *ssl_extra; /* separately allocated backend-specific data */
#endif
  struct ssl_primary_config ssl_config;
  struct ssl_primary_config proxy_ssl_config;
  bool tls_upgraded;

  struct ConnectBits bits;    /* various state-flags for this connection */

 /* connecttime: when connect() is called on the current IP address. Used to
    be able to track when to move on to try next IP - but only when the multi
    interface is used. */
  struct curltime connecttime;
  /* The two fields below get set in Curl_connecthost */
  int num_addr; /* number of addresses to try to connect to */
  time_t timeoutms_per_addr; /* how long time in milliseconds to spend on
                                trying to connect to each IP address */

  const struct Curl_handler *handler; /* Connection's protocol handler */
  const struct Curl_handler *given;   /* The protocol first given */

  long ip_version; /* copied from the Curl_easy at creation time */

  /* Protocols can use a custom keepalive mechanism to keep connections alive.
     This allows those protocols to track the last time the keepalive mechanism
     was used on this connection. */
  struct curltime keepalive;

  long upkeep_interval_ms;      /* Time between calls for connection upkeep. */

  /**** curl_get() phase fields */

  curl_socket_t sockfd;   /* socket to read from or CURL_SOCKET_BAD */
  curl_socket_t writesockfd; /* socket to write to, it may very
                                well be the same we read from.
                                CURL_SOCKET_BAD disables */

  /** Dynamically allocated strings, MUST be freed before this **/
  /** struct is killed.                                      **/
  struct dynamically_allocated_data {
    char *proxyuserpwd;
    char *uagent;
    char *accept_encoding;
    char *userpwd;
    char *rangeline;
    char *ref;
    char *host;
    char *cookiehost;
    char *rtsp_transport;
    char *te; /* TE: request header */
  } allocptr;

#ifdef HAVE_GSSAPI
  int sec_complete; /* if Kerberos is enabled for this connection */
  enum protection_level command_prot;
  enum protection_level data_prot;
  enum protection_level request_data_prot;
  size_t buffer_size;
  struct krb5buffer in_buffer;
  void *app_data;
  const struct Curl_sec_client_mech *mech;
  struct sockaddr_in local_addr;
#endif

#if defined(USE_KERBEROS5)    /* Consider moving some of the above GSS-API */
  struct kerberos5data krb5;  /* variables into the structure definition, */
#endif                        /* however, some of them are ftp specific. */

  /* the two following *_inuse fields are only flags, not counters in any way.
     If TRUE it means the channel is in use, and if FALSE it means the channel
     is up for grabs by one. */

  bool readchannel_inuse;  /* whether the read channel is in use by an easy
                              handle */
  bool writechannel_inuse; /* whether the write channel is in use by an easy
                              handle */
  struct curl_llist send_pipe; /* List of handles waiting to send on this
                                  pipeline */
  struct curl_llist recv_pipe; /* List of handles waiting to read their
                                  responses on this pipeline */
  char *master_buffer; /* The master buffer allocated on-demand;
                          used for pipelining. */
  size_t read_pos; /* Current read position in the master buffer */
  size_t buf_len; /* Length of the buffer?? */


  curl_seek_callback seek_func; /* function that seeks the input */
  void *seek_client;            /* pointer to pass to the seek() above */

  /*************** Request - specific items ************/
#if defined(USE_WINDOWS_SSPI) && defined(SECPKG_ATTR_ENDPOINT_BINDINGS)
  CtxtHandle *sslContext;
#endif

#if defined(USE_NTLM)
  struct ntlmdata ntlm;     /* NTLM differs from other authentication schemes
                               because it authenticates connections, not
                               single requests! */
  struct ntlmdata proxyntlm; /* NTLM data for proxy */

#if defined(NTLM_WB_ENABLED)
  /* used for communication with Samba's winbind daemon helper ntlm_auth */
  curl_socket_t ntlm_auth_hlpr_socket;
  pid_t ntlm_auth_hlpr_pid;
  char *challenge_header;
  char *response_header;
#endif
#endif

  char syserr_buf [256]; /* buffer for Curl_strerror() */
  /* data used for the asynch name resolve callback */
  struct Curl_async async;

  /* These three are used for chunked-encoding trailer support */
  char *trailer; /* allocated buffer to store trailer in */
  int trlMax;    /* allocated buffer size */
  int trlPos;    /* index of where to store data */

  union {
    struct ftp_conn ftpc;
    struct http_conn httpc;
    struct ssh_conn sshc;
    struct tftp_state_data *tftpc;
    struct imap_conn imapc;
    struct pop3_conn pop3c;
    struct smtp_conn smtpc;
    struct rtsp_conn rtspc;
    struct smb_conn smbc;
    void *generic; /* RTMP and LDAP use this */
  } proto;

  int cselect_bits; /* bitmask of socket events */
  int waitfor;      /* current READ/WRITE bits to wait for */

#if defined(HAVE_GSSAPI) || defined(USE_WINDOWS_SSPI)
  int socks5_gssapi_enctype;
#endif

  /* When this connection is created, store the conditions for the local end
     bind. This is stored before the actual bind and before any connection is
     made and will serve the purpose of being used for comparison reasons so
     that subsequent bound-requested connections aren't accidentally re-using
     wrong connections. */
  char *localdev;
  unsigned short localport;
  int localportrange;
  struct http_connect_state *connect_state; /* for HTTP CONNECT */
  struct connectbundle *bundle; /* The bundle we are member of */
  int negnpn; /* APLN or NPN TLS negotiated protocol, CURL_HTTP_VERSION* */

#ifdef USE_UNIX_SOCKETS
  char *unix_domain_socket;
  bool abstract_unix_socket;
#endif
};

/* The end of connectdata. */

struct Curl_easy {
  /* first, two fields for the linked list of these */
  struct Curl_easy *next;
  struct Curl_easy *prev;

  struct connectdata *conn;
  struct curl_llist_element connect_queue;
  struct curl_llist_element pipeline_queue;
  struct curl_llist_element sh_queue; /* list per Curl_sh_entry */

  CURLMstate mstate;  /* the handle's state */
  CURLcode result;   /* previous result */

  struct Curl_message msg; /* A single posted message. */

  /* Array with the plain socket numbers this handle takes care of, in no
     particular order. Note that all sockets are added to the sockhash, where
     the state etc are also kept. This array is mostly used to detect when a
     socket is to be removed from the hash. See singlesocket(). */
  curl_socket_t sockets[MAX_SOCKSPEREASYHANDLE];
  int actions[MAX_SOCKSPEREASYHANDLE]; /* action for each socket in
                                          sockets[] */
  int numsocks;

  struct Names dns;
  struct Curl_multi *multi;    /* if non-NULL, points to the multi handle
                                  struct to which this "belongs" when used by
                                  the multi interface */
  struct Curl_multi *multi_easy; /* if non-NULL, points to the multi handle
                                    struct to which this "belongs" when used
                                    by the easy interface */
  struct Curl_share *share;    /* Share, handles global variable mutexing */
#ifdef USE_LIBPSL
  struct PslCache *psl;        /* The associated PSL cache. */
#endif
  struct SingleRequest req;    /* Request-specific data */
  struct UserDefined set;      /* values set by the libcurl user */
  struct DynamicStatic change; /* possibly modified userdefined data */
  struct CookieInfo *cookies;  /* the cookies, read from files and servers.
                                  NOTE that the 'cookie' field in the
                                  UserDefined struct defines if the "engine"
                                  is to be used or not. */
  struct Progress progress;    /* for all the progress meter data */
  struct UrlState state;       /* struct for fields used for state info and
                                  other dynamic purposes */
  struct WildcardData wildcard; /* wildcard download state info */
  struct PureInfo info;        /* stats, reports and info data */
  struct curl_tlssessioninfo tsi; /* Information about the TLS session, only
                                     valid after a client has asked for it */
#if defined(CURL_DOES_CONVERSIONS) && defined(HAVE_ICONV)
  iconv_t outbound_cd;         /* for translating to the network encoding */
  iconv_t inbound_cd;          /* for translating from the network encoding */
  iconv_t utf8_cd;             /* for translating to UTF8 */
#endif /* CURL_DOES_CONVERSIONS && HAVE_ICONV */
  unsigned int magic;          /* set to a CURLEASY_MAGIC_NUMBER */
};

typedef struct Curl_easy CURL;

CURL_EXTERN CURL *curl_easy_init(void);
]]
