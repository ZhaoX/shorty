-module(mongo_util).

-compile(export_all).

get_connection(Host, Port) ->
    mongo_connection:start_link({Host, Port}, []).

find_and_modify(Connection, Database, Collection, Query, Update) ->
    find_and_modify(Connection, Database, Collection, Query, Update, false).
find_and_modify(Connection, Database, Collection, Query, Update, Upsert) ->
    find_and_modify(Connection, Database, Collection, Query, Update, Upsert, false).
find_and_modify(Connection, Database, Collection, Query, Update, Upsert, New) ->
    mongo:do(safe, master, Connection,
        Database,
        fun() ->
          mongo:command({findAndModify, Collection, 'query', Query, update, Update, upsert, Upsert, new, New})
        end
    ).

save(Connection, Database, Collection, Values) ->
    mongo:do(safe, master, Connection, 
        Database, 
        fun() ->
            mongo:insert(Collection, Values) 
        end
    ).

