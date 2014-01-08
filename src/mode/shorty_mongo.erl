-module(shorty_mongo).

-compile(export_all).

-include_lib("shorty/include/shorty.hrl").

get_next_id() ->
    {ok, MongoConn} = mongo_util:get_connection(?MONGODB_HOST, ?MONGODB_PORT),
    DB = ?DATABASE,
    Collection = ?COLLECTION_ID,
    Selector = {},
    Updater = {'$inc', {shorty_id, 1}},
    Upsert = true,
    New = true,
    case mongo_util:find_and_modify(MongoConn, DB, Collection, Selector, Updater, Upsert, New) of
        {value,{'_id', _ID, shorty_id, NextId},_,_,_,_} ->
          {ok, NextId};
        Res ->
          lager:debug("~p", [Res]),
          {error, "mongodb exception"}
    end.
