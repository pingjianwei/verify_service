%%%-------------------------------------------------------------------
%% @doc verify_service public API
%% @end
%%%-------------------------------------------------------------------

-module(verify_service_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    pre_handle(),
    verify_service_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
pre_handle()->
    {ok,RootPath} = file:get_cwd(),
    NewPath = RootPath ++ "/userc.erl",
    lager:info("userc path:~p",[NewPath]),
    case filelib:is_regular(NewPath) of
        true  ->
            {ok,T}=compile:file(userc, [{parse_transform, lager_transform},
                {parse_transform, exprecs}, report, verbose]),
            c:l(T);
        false ->io:format("userc.erl is not exited!")
    end.

