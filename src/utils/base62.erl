-module(base62).
-export([encode/1, decode/1]).
 
-define(CHAR_SET, "1Ho5uJn0LR8XcySqQEzCPfwGIA97tYmdxN4aBv6pWMebVZTOrhijsKgl3kU2DF").

encode(Num) -> encode(Num, []).
encode(Num, Acc) when Num < 0 -> encode(-Num, Acc); 
encode(Num, []) when Num =:= 0 -> [lists:nth(1, ?CHAR_SET)];
encode(Num, Acc) when Num =:= 0 -> Acc;
encode(Num, Acc) ->
    R = Num rem 62,
    D = Num div 62,
    Acc1 = [lists:nth(R+1, ?CHAR_SET)|Acc],
    encode(D, Acc1).

decode(Str) ->
  Str.
