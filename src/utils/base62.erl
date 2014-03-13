-module(base62).
-export([
    encode/1,
    fix_size/2,
    decode/1
]).

-define(BASE, 62).
-define(CHAR_SET, "1Ho5uJn0LR8XcySqQEzCPfwGIA97tYmdxN4aBv6pWMebVZTOrhijsKgl3kU2DF").

encode(Num) -> encode(Num, []).
encode(Num, Acc) when Num < 0 -> encode(-Num, Acc); 
encode(Num, []) when Num =:= 0 -> [lists:nth(1, ?CHAR_SET)];
encode(Num, Acc) when Num =:= 0 -> Acc;
encode(Num, Acc) ->
    R = Num rem ?BASE,
    D = Num div ?BASE,
    Acc1 = [lists:nth(R+1, ?CHAR_SET)|Acc],
    encode(D, Acc1).

fix_size(Str, MinSize) when length(Str) >= MinSize ->
    Str;
fix_size(Str, MinSize) ->
    fix_size([lists:nth(1, ?CHAR_SET)|Str], MinSize).

decode(Str) ->
    Fun = fun(Char, {CurVal, Pos}) ->
        Num = char_to_num(Char),
        {CurVal+Num*math:pow(?BASE, Pos), Pos-1}
    end,
    {Value, _} = lists:foldl(Fun, {0, length(Str)-1}, Str),
    erlang:trunc(Value).

%%-----------------------------------------------------------------------------------------
%% internal functions
%%-----------------------------------------------------------------------------------------
char_to_num(Char) ->
    char_to_num(Char, ?CHAR_SET, 0).

char_to_num(Char, [], _) ->
    erlang:throw({error, <<"bad character">>});
char_to_num(Char, [H|T], Pos) when H =:= Char ->
    Pos;
char_to_num(Char, [H|T], Pos) ->
    char_to_num(Char, T, Pos+1). 

