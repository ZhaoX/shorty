-module(pre_alloc_shorty_mongo).

-compile(export_all).

-include_lib("shorty/include/shorty.hrl").

%%Candidate range: [?LOW_BOUNDARY, ?HIGH_BOUNDARYR)
-define(LOW_BOUNDARY, 0).
-define(HIGH_BOUNDARY, 916132831).
