-module(shorty_mongo).

-compile(export_all).

-include_lib("shorty/include/shorty.hrl").

get_shorty_code(Url) ->
    {ok, Conn} = mongo_util:get_connection(?MONGODB_HOST, ?MONGODB_PORT),
    {ok, Id} = get_next_id(Conn),
    Code = list_to_binary(base62:encode(Id)),
    create_shorty(Conn, Url, Code),
    Code.
    

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
    
