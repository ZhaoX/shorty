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

find_one(Connection, Database, Collection, Selector, Projector) ->
    mongo:do(safe, master, Connection,
        Database,
        fun() ->
            Cursor = mongo:find(Collection, Selector, Projector),
            Result = mongo_cursor:next(Cursor),
            mongo_cursor:close(Cursor),
            Result
        end
    ).

find(Connection, Database, Collection, Selector, Projector) ->
    mongo:do(safe, master, Connection,
        Database,
        fun() ->
            Cursor = mongo:find(Collection, Selector, Projector),
            Result = mongo_cursor:rest(Cursor),
            mongo_cursor:close(Cursor),
            Result
        end
    ).


