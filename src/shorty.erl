-module(shorty).
-export([start/0, log/1]).

-include_lib("shorty/include/shorty.hrl").

start() ->
    ok = application:start(inets),
    ok = application:start(crypto),

    ok = application:start(cowlib),
    ok = application:start(ranch),
    ok = application:start(cowboy),

    ok = application:start(syntax_tools),
    ok = application:start(compiler),
    ok = application:start(erlson),

    ok = application:start(goldrush),
    ok = application:start(lager),

    case ?SHORTY_PROCESSER of
      range_shorty_mongo ->
        ok = application:start(bson),
        ok = application:start(mongodb);
      range_shorty_mysql ->
        my:start_client(),
        {ok, _} = my:new_datasource(mysql_datasource, ?MYSQL_DATASOURCE, [{when_exhausted_action, grow}, {max_active, 100}, {test_on_borrow, true}, {test_on_return,true}])
    end,

    ok = application:start(shorty),
    lager:set_loglevel(lager_console_backend, ?LOG_LEVEL).

log(Level) when is_atom(Level) ->
    lager:set_loglevel(lager_console_backend, Level).
