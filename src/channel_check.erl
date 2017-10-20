%%%-------------------------------------------------------------------
%%% @author pingjianwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 十月 2017 17:47
%%%-------------------------------------------------------------------
-module(channel_check).
-include("include/store.hrl").
-author("pingjianwei").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).
-define(APP, verify_service).
-define(MILLIISECONDS, 60 * 1000).

-record(state, {ref_time, interval_time}).

%%%===================================================================
%%% API
%%%===================================================================
-export([update_state/1]).
update_state(CurrentTmie) ->
  gen_server:cast(channel_check, CurrentTmie).


%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  State = #state{
    ref_time = erlang:timestamp(),
    interval_time = xfutils:get_path(?APP, check_interval) * ?MILLIISECONDS
  },
  {ok, State, 0}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(Request, State) ->
  lager:debug("Ref_time before updating:~p interval_time before updating:~p ", [calendar:now_to_local_time(State#state.ref_time), State#state.interval_time]),
  NewState = State#state{ref_time = Request},
  {noreply, NewState, 1000}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(timeout, State) ->
  CheckList = ums_config:get_config(check_list),
  case is_overtime(erlang:timestamp(), State) of
    true ->
      NewState = State#state{ref_time = erlang:timestamp()},
      {noreply, NewState, 1000};
    false ->
%%      lager:info("time is not arrived!"),
      {noreply, State, 1000}
  end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
check(CheckList) ->
  F = fun(Channel, Acc) ->
    CheckResult=case Channel of
      ums_bankcad ->
        Result  = utils_verify:handle_req(ums, ums_check_params());
      zt_bankcad ->
        utils_verify:handle_req(zt, zt_check_params())
    end,
    maps:get(httpCode,CheckResult)
      end,
   lists:foldl(F, [], CheckList).


is_overtime(CurrentTime, State) ->
  MicroInterval = timer:now_diff(CurrentTime, State#state.ref_time),
  MilliInterval = erlang:trunc(MicroInterval * 1.0e-3),
%%  lager:debug("Ref_time:~p interval_time:~p ", [calendar:now_to_local_time(State#state.ref_time), State#state.interval_time]),
  MilliInterval >= State#state.interval_time.
%%---------------------------------------------------------------------
update_channel(ChannelType,RespMap) ->
  [Repo]=mnesia:dirty_index_read(channel,ChannelType,#channel.type),

  ok.

update(TableName, {IndexName, IndexValue}, ValueList)
  when is_atom(TableName), is_atom(IndexName), is_list(ValueList) ->
  Map = column_integer_map(TableName),
  Repo = mnesia:dirty_index_read(TableName,IndexValue,IndexName),
  F = fun({Key,Value},Repo)->
    setelement(maps:get(Key),Repo,Value)
    end,
  NewRepo = lists:foldl(F,Repo,ValueList),
  mnesia:dirty_write(NewRepo).

column_integer_map(TableName)->
  FieldsList = mnesia:table_info(TableName,attributes),
  lists:zip(FieldsList,lists:seq(2,length(FieldsList))).


%%----------------------------------------------------------------------
change_verify_channel() ->

  ok.

ums_check_params() ->
  [{<<"acctName">>, <<229, 185, 179, 229, 187, 186, 228, 188, 159>>},
    {<<"acctNo">>, <<"6222520623231350">>},
    {<<"certNo">>, <<"410183198810141016">>},
    {<<"certType">>, <<"01">>},
    {<<"phone">>, <<"13721422283">>},
    {<<"tranId">>, <<"20171018110139948943588">>},
    {<<"tranTime">>, <<"20171018110139">>},
    {<<"umsAcctType">>, <<"1">>},
    {<<"verifyType">>, <<"0040">>},
    {<<"signature">>, <<"KfuTir5rKu7+vTLF72Fa08egznqiaC0tVtF2KdaIwOg8uYru9t44e3Kks9DVzeWDm3epk3uBM1frycrJDgW756TkSc2YroBnmB9eYz0dOJA+EE5hmTPK5NOk4Wwmvk7sGsuFV1C9kqpPWE2GucBsWBDq/hKfP5CR7kVB1URuC9o=">>}].

zt_check_params() ->
  ok.



