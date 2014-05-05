-module(mysql_util).

-include_lib("shorty/include/shorty.hrl").

-compile(export_all).

get_connection() ->
    Conn = datasource:get_connection(mysql_datasource),
    {ok, Conn}.

return_connection(Conn) ->
    datasource:return_connection(mysql_datasource, Conn).

start_transaction(Conn) ->
    {_,[#ok_packet{}]} = connection:execute_query(Conn, "START TRANSACTION").

commit_transaction(Conn) ->
    {_,[#ok_packet{}]} = connection:execute_query(Conn, "COMMIT").

rollback_transaction(Conn) ->
    {_,[#ok_packet{}]} = connection:execute_query(Conn, "ROLLBACK").
