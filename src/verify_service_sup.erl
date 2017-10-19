%%%-------------------------------------------------------------------
%% @doc verify_service top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(verify_service_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).
-define(MUMSCONFIG,ums_config).
-define(MCHANNELCHECK,channel_check).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->

    UmsConfig = {?MUMSCONFIG,
        {?MUMSCONFIG, start_link, []},
        permanent, 2000, worker, [?MUMSCONFIG]},

    ChannelCheck = {?MCHANNELCHECK,
        {?MCHANNELCHECK, start_link, []},
        permanent, 2000, worker, [?MCHANNELCHECK]},

    Children = [UmsConfig,ChannelCheck],
    RestartStrategy = {one_for_one, 4, 60},
    {ok, {RestartStrategy, Children}}.


%%====================================================================
%% Internal functions
%%====================================================================
