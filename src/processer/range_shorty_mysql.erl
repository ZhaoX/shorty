-module(range_shorty_mysql).

-compile(export_all).

-include_lib("shorty/include/shorty.hrl").

-define(RANGE_NUM, 62).

init() ->
    {ok, Conn} = mysql_util:get_connection(),
    create_range(Conn, ?RANGE_NUM-1).

get_code(Url) ->
    {ok, Conn} = mysql_util:get_connection(),
    PS = connection:get_prepared_statement_handle(Conn, "select code from shorty.shorty where url = ?"),
    {_Metadata, Res} = connection:execute_statement(Conn, PS, [?VARCHAR], [binary_to_list(Url)]),
    connection:close_statement(Conn, PS),
    Result = case Res of
        [] ->
            try
                mysql_util:start_transaction(Conn),
                {ok, Id} = get_next_id(Conn),
                Code = list_to_binary(base62:fix_size(base62:encode(Id), ?SHORTY_SIZE)),
                create_shorty(Conn, Url, Code),
                mysql_util:commit_transaction(Conn),
                {ok, Code}
            catch E:R ->
                lager:error("error:~p, reason:~p, trace:~p", [E, R, erlang:get_stacktrace()]),
                mysql_util:rollback_transaction(Conn),
                {error, "mysql exception"}
            end;
        [[Code]|_] ->
            {ok, list_to_binary(Code)}
    end,
    mysql_util:return_connection(Conn),
    Result.

get_url(Code) ->
    {ok, Conn} = mysql_util:get_connection(),
    PS = connection:get_prepared_statement_handle(Conn, "select url from shorty.shorty where code = ?"),
    {_Metadata, Res} = connection:execute_statement(Conn, PS, [?VARCHAR], [binary_to_list(Code)]),
    connection:close_statement(Conn, PS),
    Url = case Res of
        [] -> <<>>;
        [[Url_]|_] -> list_to_binary(Url_)
    end,
    mysql_util:return_connection(Conn),
    {ok, Url}.

add_access_log(ClientIP, Code, Url) ->
    {ok, Conn} = mysql_util:get_connection(),
    PS = connection:get_prepared_statement_handle(Conn, "insert into shorty.log(code, url, client_ip) values(?,?,?)"),
    connection:execute_statement(Conn, PS, [?VARCHAR, ?VARCHAR, ?VARCHAR], [binary_to_list(Code), binary_to_list(Url), binary_to_list(ClientIP)]),
    connection:close_statement(Conn, PS),
    mysql_util:return_connection(Conn).

%%---------------------------------------------------------------------------------------------------------
%% internal functions
%%---------------------------------------------------------------------------------------------------------
get_next_id(Conn) ->
    <<A:32, B:32, C:32>> = crypto:rand_bytes(12),
    random:seed({A,B,C}),
    RangeIndex = erlang:trunc(random:uniform(?RANGE_NUM)-1),
    {_Metadata, [[Id]|_]} = connection:execute_query(Conn, "select id from shorty.range_id where `range` = " ++ integer_to_list(RangeIndex)),
    connection:execute_query(Conn, "update shorty.range_id set id = id +1 where `range` = " ++ integer_to_list(RangeIndex)),
    io:format(".............id:......~p...~n", [Id]),
    {ok, Id+1}.
    

create_shorty(Conn, Url, Code) ->
    PS = connection:get_prepared_statement_handle(Conn, "insert into shorty.shorty(code,url) values(?,?)"),
    connection:execute_statement(Conn, PS, [?VARCHAR, ?VARCHAR], [binary_to_list(Code), binary_to_list(Url)]),
    connection:close_statement(Conn, PS).

create_range(Conn, RangeIndex) when RangeIndex < 0 ->
    mysql_util:return_connection(Conn);
create_range(Conn, RangeIndex) ->
    <<A:32, B:32, C:32>> = crypto:rand_bytes(12),
    random:seed({A,B,C}),
    InitId_ = RangeIndex*math:pow(62, 5) + random:uniform(erlang:trunc(8*math:pow(62, 4))), 
    InitId =  erlang:trunc(InitId_),
    connection:execute_query(Conn, "insert into shorty.range_id(`range`,id) values(" ++ integer_to_list(RangeIndex) ++ "," ++ integer_to_list(InitId) ++ ")"),
    create_range(Conn, RangeIndex-1).
