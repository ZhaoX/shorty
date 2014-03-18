-define(HOSTNAME, shorty_util:get_hostname()).

%%-------------------------------------------------------------------------------------------------
%% log
%%-------------------------------------------------------------------------------------------------
-define(LOG_LEVEL, debug). % debug, info, notice, warning, error, critical, alert, emergency, none

%%-------------------------------------------------------------------------------------------------
%% shorty
%%-------------------------------------------------------------------------------------------------
-define(SHORTY_DOMAIN, <<"http://10.100.1.15/l">>).
-define(SHORTY_SIZE, 6).


%%-------------------------------------------------------------------------------------------------
%% http
%%-------------------------------------------------------------------------------------------------
-define(HTTP_PORT, 8888).
-define(ROUTER, [ 
    {'_', [ 
        {"/get_shorty",  get_shorty_handler ,  []}, 
        {"/:code",       redirect_handler ,    []} 
    ]} 
]).

%%-------------------------------------------------------------------------------------------------
%% shorty processer
%%-------------------------------------------------------------------------------------------------
-define(SHORTY_PROCESSER, range_shorty_mongo).

%%-------------------------------------------------------------------------------------------------
%% mongodb 
%%-------------------------------------------------------------------------------------------------
-define(MONGODB_HOST, "127.0.0.1").
-define(MONGODB_PORT, 24011).
-define(DATABASE, shorty).
-define(COLLECTION_ID, id).
-define(COLLECTION_SHORTY, shorty).
-define(COLLECTION_LOG, log).
-define(COLLECTION_RANGE_ID, range_id).
