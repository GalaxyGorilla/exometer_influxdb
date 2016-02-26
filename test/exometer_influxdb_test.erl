-module(exometer_influxdb_test).

-include_lib("eunit/include/eunit.hrl").

-import(exometer_report_influxdb, [evaluate_subscription_options/2, make_packet/5]).

evaluate_subscription_options_test() ->
    ?assertEqual({[a, b, c], #{}},
                 evaluate_subscription_options([a, b, c], [])),

    ?assertEqual({[a, b, c], #{tag => d}},
                 evaluate_subscription_options([a, b, c], [{tags, [{tag, d}]}])),

    ?assertEqual({[a, b, c], #{tag => a}},
                 evaluate_subscription_options([a, b, c], [{tags, [{tag, {from_name, 1}}]}])),

    ?assertEqual({[a, b, c], #{}},
                 evaluate_subscription_options([a, b, c], [{tags, [{tag, {from_name, 4}}]}])),

    ?assertEqual({[a, b, c], #{tag => a}},
                 evaluate_subscription_options([a, b, c], [{tags, [{tag, a}]}])),

    ?assertEqual({[b, c], #{tag => a}},
                 evaluate_subscription_options([a, b, c], [{tags, [{tag, {from_name, 1}}]}, {formatting, [{hide, all_from_name}]}])),

    ?assertEqual({[b, c], #{tag => a}},
                 evaluate_subscription_options([a, b, c], [{tags, [{tag, {from_name, a}}], {formatting, [{hide, all_from_name}]}])),

    ?assertEqual({[b, c], #{}},
                 evaluate_subscription_options([undefined, b, c], [{tags, [{tag, {from_name, 1}}], {formatting, [{purge, {tag_key, undefined}}]}])),

    ?assertEqual({[b, c], #{}},
                 evaluate_subscription_options([a, b, c], [{tags, [{tag, undefined}], {formatting, [{purge, {tag_value, undefined}}]}])),

    ?assertEqual({test_key, #{}},
                 evaluate_subscription_options([a, b, c], [{series_key, test_key}])),

    ok.

make_packet_without_timestamping_test() ->
    {Name1, Tags1} = evaluate_subscription_options([a, b, c], []),
    ?assertEqual(<<"a_b_c value=1i ">>, 
                 make_bin_packet(Name1, Tags1, #{value => 1}, false, u)),

    {Name2, Tags2} = evaluate_subscription_options([a, b, c], [{tags, [{tag, d}]}]),
    ?assertEqual(<<"a_b_c,tag=d value=1i ">>, 
                 make_bin_packet(Name2, Tags2, #{value => 1}, false, u)),

    {Name3, Tags3} = evaluate_subscription_options([a, b, c], [{tags, [{tag, {from_name, 2}}]}, {formatting, [{hide, all_from_name}]}]),
    ?assertEqual(<<"a_c,tag=b value=1i ">>, 
                 make_bin_packet(Name3, Tags3, #{value => 1}, false, u)),

    {Name4, Tags4} = evaluate_subscription_options([a, b, c], [{tags, [{tag1, d}, {tag2, {from_name, 2}}]}, {formatting, [{hide, all_from_name}]}]),
    ?assertEqual(<<"a_c,tag1=d,tag2=b value=1i ">>, 
                 make_bin_packet(Name4, Tags4, #{value => 1}, false, u)),

    {Name5, Tags5} = evaluate_subscription_options([a, b, c], [{tags, [{tag, d}]}]),
    ?assertEqual(<<"a_b_c,tag=d value=1i,value2=2i ">>, 
                 make_bin_packet(Name5, Tags5, #{value => 1, value2 => 2}, false, u)),

    {Name6, Tags6} = evaluate_subscription_options([a, b, c], [{tag1, d}, {tag2, {from_name, 2}}]}, {formatting, [{hide, all_from_name}]}]),
    ?assertEqual(<<"a_c,tag1=d,tag2=b value=1i,value2=2i ">>, 
                 make_bin_packet(Name6, Tags6, #{value => 1, value2 => 2}, false, u)),
    ok.

-define(VALID_PRECISIONS, [n, u, ms, s, m, h]).
make_packet_with_timestamping_test() ->
    {Name1, Tags1} = evaluate_subscription_options([a, b, c], []),

    ?assertEqual(<<"a_b_c value=1i 1456993524527361000">>, 
                 make_bin_packet(Name1, Tags1, #{value => 1}, true, n)),

    ?assertEqual(<<"a_b_c value=1i 1456993524527361">>, 
                 make_bin_packet(Name1, Tags1, #{value => 1}, true, u)),

    ?assertEqual(<<"a_b_c value=1i 1456993524527">>, 
                 make_bin_packet(Name1, Tags1, #{value => 1}, true, ms)),

    ?assertEqual(<<"a_b_c value=1i 1456993525">>, 
                 make_bin_packet(Name1, Tags1, #{value => 1}, true, s)),

    ?assertEqual(<<"a_b_c value=1i 24283225">>, 
                 make_bin_packet(Name1, Tags1, #{value => 1}, true, m)),

    ?assertEqual(<<"a_b_c value=1i 404720">>, 
                 make_bin_packet(Name1, Tags1, #{value => 1}, true, h)),
    ok.

make_bin_packet(Name, Tags, Fields, Timestamping, Precision) ->
    binary:list_to_bin(make_packet(Name, Tags, Fields, Timestamping, Precision)).
