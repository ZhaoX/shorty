-compile([{parse_transform, lager_transform}]).

-define(LOG_LEVEL, debug). % debug, info, notice, warning, error, critical, alert, emergency, none

-define(HTTP_PORT, 8888).

-define(HTTP_DOMAIN, <<"shorty.com">>).

-define(MONGODB_HOST, "127.0.0.1").
-define(MONGODB_PORT, 27017).
-define(DATABASE, shorty).
-define(COLLECTION_ID, shorty_id).
-define(COLLECTION_URL, shorty_url).

-define(HOSTNAME, shorty_util:get_hostname()).

-define(ROUTER, [ 
    {'_', [ 
        {"/get_shorty",  get_shorty_handler ,[]} 
    ]} 
]).
