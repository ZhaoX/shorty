-module(shorty_mongo).

-compile(export_all).

-include_lib("shorty/include/shorty.hrl").

get_code(Url) ->
    {ok, Conn} = mongo_util:get_connection(?MONGODB_HOST, ?MONGODB_PORT),
    Selector = {url, Url},
    Projector = {code, 1, '_id', 0},
    Res = mongo_util:find_one(Conn, ?DATABASE, ?COLLECTION_SHORTY, Selector, Projector),
    case Res of
        {} ->
            {ok, Id} = get_next_id(Conn),
            Code = list_to_binary(base62:fix_size(base62:encode(Id), ?SHORTY_SIZE)),
            create_shorty(Conn, Url, Code),
            {ok, Code};
        {{code, Code}} ->
            {ok, Code}
    end.

get_url(Code) ->
    {ok, Conn} = mongo_util:get_connection(?MONGODB_HOST, ?MONGODB_PORT),
    Selector = {code, Code},
    Projector = {url, 1, '_id', 0},
    Res = mongo_util:find_one(Conn, ?DATABASE, ?COLLECTION_SHORTY, Selector, Projector),
    case Res of
        {} -> {ok, <<>>};
        {{url, Url}} -> {ok, Url}
    end.

add_access_log(ClientIP, Code, Url) ->
    {ok, Conn} = mongo_util:get_connection(?MONGODB_HOST, ?MONGODB_PORT),
    Values = [{client_ip, ClientIP, code, Code, url, Url,  atime, now()}], 
    mongo_util:save(Conn, ?DATABASE, ?COLLECTION_LOG, Values).

%%---------------------------------------------------------------------------------------------------------
%% internal functions
%%---------------------------------------------------------------------------------------------------------
get_next_id(Conn) ->
    Selector = {},
    Updater = {'$inc', {shorty_id, 1}},
    case mongo_util:find_and_modify(Conn, ?DATABASE, ?COLLECTION_ID, Selector, Updater, true, true) of
        {value,{'_id', _ID, shorty_id, NextId},_,_,_,_} ->
          {ok, NextId};
        Res ->
          lager:error("~p", [Res]),
          {error, "mongodb exception"}
    end.

create_shorty(Conn, Url, Code) ->
    Values = [{url, Url, code, Code, ctime, now()}], 
    mongo_util:save(Conn, ?DATABASE, ?COLLECTION_SHORTY, Values).
