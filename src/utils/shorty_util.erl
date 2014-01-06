-module(shorty_util).

-compile(export_all).

get_hostname() ->
    {ok, HostName} = inet:gethostname(),
    list_to_binary(HostName).

generate_response_body(Code, Msg, Data) ->
    Term = [
        {code, Code},
        {msg,  Msg},
        {data, Data}
    ],
    list_to_binary(erlson:to_json(Term)).

