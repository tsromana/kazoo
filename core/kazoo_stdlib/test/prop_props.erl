%%%-------------------------------------------------------------------
%%% @copyright (C) 2010-2017, 2600Hz INC
%%% @doc
%%% @end
%%% @contributors
%%%   James Aimonetti
%%%   Karl Anderson
%%%-------------------------------------------------------------------
-module(prop_props).

-ifdef(PROPER).
-include_lib("proper/include/proper.hrl").
-include_lib("kazoo_stdlib/include/kz_types.hrl").
-include_lib("eunit/include/eunit.hrl").

prop_set_value() ->
    ?FORALL({KV, Before, After}
           ,{test_property(), test_proplist(), test_proplist()}
           ,?WHENFAIL(?debugFmt("failed: props:is_defined(~p, ~p ++ props:set_value(~p, ~p)).~n", [KV, Before, KV, After])
                     ,props:is_defined(KV, Before ++ props:set_value(KV, After))
                     )
           ).

prop_set_values() ->
    ?FORALL({KVs, Before, After}
           ,{list(test_property()), test_proplist(), test_proplist()}
           ,?WHENFAIL(?debugFmt("Props = ~p ++ props:set_values(~p, ~p)~n", [Before, KVs, After])
                     ,begin
                          Props = Before ++ props:set_values(KVs, After),
                          lists:all(fun(KV) -> props:is_defined(KV, Props) end
                                   ,KVs
                                   )
                      end
                     )
           ).

prop_get_value() ->
    ?FORALL({Props, KV}
           ,test_proplist_and_kv()
           ,begin
                K = case is_tuple(KV) of 'true' -> element(1, KV); 'false' -> KV end,
                V = case is_tuple(KV) of 'true' -> element(2, KV); 'false' -> 'true' end,
                ?WHENFAIL(?debugFmt("~p = props:get_value(~p, ~p).~n"
                                   ,[V, K, Props]
                                   )
                         ,V =:= props:get_value(K, Props)
                         )
            end
           ).

test_proplist() ->
    list(test_property()).

test_property() ->
    oneof([test_key()
          ,{test_key(), test_value()}
          ]).

%% TODO: generate recursive proplists and key paths to test get/set on nested proplists
test_value() -> any().

test_key() ->
    oneof([atom(), binary()]).

test_proplist_and_kv() ->
    ?LET(Props
        ,?SUCHTHAT(UniqueProps
                  ,?LET(GenProps, non_empty(test_proplist()), props:unique(GenProps))
                  ,is_list(UniqueProps)
                  )
        ,{Props, elements(Props)}
        ).

-endif.
