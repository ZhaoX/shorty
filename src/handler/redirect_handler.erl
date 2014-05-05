-module(redirect_handler).

-include_lib("shorty/include/shorty.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
try
    % check parameter
    {Bindings, Req1} = cowboy_req:bindings(Req),
    lager:debug("bindings:~p", [Bindings]),
    Code = proplists:get_value(code, Bindings),
    case Code of
        <<>> -> erlang:throw({400, <<"bad request">>});
        _    -> ok
    end,

    % get url
    ShortyProcesser = ?SHORTY_PROCESSER,
    {ok, Url} = ShortyProcesser:get_url(Code),
    case Url of 
        <<>> -> erlang:throw({404, <<"not found">>});
        _ -> ok
    end,

    % add access log
    {ClientIP, _} = cowboy_req:header(<<"x-real-ip">>, Req1),
    ShortyProcesser:add_access_log(ClientIP, Code, Url), 

    % response
    ResponHeader = [
        {<<"HIT">>, ?HOSTNAME}, 
        {<<"Location">>, Url}
    ],
    ResponseData = [],
    ResponseBody = shorty_util:generate_response_body(200, <<"ok">>, ResponseData),
    lager:debug("response body:~p", [ResponseBody]),
    {ok, Req2} = cowboy_req:reply(302, ResponHeader, ResponseBody, Req1),
    {ok, Req2, State}
catch
    throw:{XCode, XMsg} ->
        XResponseBody = shorty_util:generate_response_body(XCode, XMsg, []),
        {ok, XReq} = cowboy_req:reply(200, [], XResponseBody, Req),
        {ok, XReq, State};
    XError:XReason  -> 
        lager:error("error:~p, reason:~p, strace:~p", [XError, XReason, erlang:get_stacktrace()]),
        XResponseBody = shorty_util:generate_response_body(500, <<"unknown error">>, []),
        {ok, XReq} = cowboy_req:reply(500, [], XResponseBody, Req),
        {ok, XReq, State}
end.

terminate(_Reason, _Req, _State) ->
    ok.
