-module(get_shorty_handler).

-include_lib("shorty/include/shorty.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
try
    % check parameter
    {QS, Req1} = cowboy_req:qs_vals(Req),
    lager:debug("qs:~p", [QS]),
    Url	= proplists:get_value(<<"url">>, QS),
    
    case Url of
        <<>> -> erlang:throw({400, <<"bad request">>});
        _    -> ok
    end,

    % get shorty
    ShortyProcesser = ?SHORTY_PROCESSER,
    {ok, ShortyCode} = ShortyProcesser:get_code(Url),
    Shorty = <<?SHORTY_DOMAIN/binary, <<"/">>/binary, ShortyCode/binary>>,

    % response
    ResponHeader = [
        {<<"HIT">>, ?HOSTNAME}, 
        {<<"Content-Type">>, <<"application/json">>}
    ],
    ResponseData = [
        {url, Url},
        {shorty, Shorty}
    ],
    ResponseBody = shorty_util:generate_response_body(200, <<"ok">>, ResponseData),
    lager:debug("response body:~p", [ResponseBody]),
    {ok, Req2} = cowboy_req:reply(200, ResponHeader, ResponseBody, Req1),
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
