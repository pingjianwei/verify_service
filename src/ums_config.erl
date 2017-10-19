%%%-------------------------------------------------------------------
%%% @author pingjianwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 十月 2017 18:02
%%%-------------------------------------------------------------------
-module(ums_config).
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

-record(state, { mer_list_map, public_key}).

%%%===================================================================
%%% API
%%%===================================================================
-export([get_config/1,
  get_mer_prop/2]).

get_mer_prop(MerId, Key) when is_atom(MerId) ->
%%  io:format("code test!").
  gen_server:call(?SERVER, {get_mer_prop, MerId, Key}).

get_config(Key) when is_atom(Key) ->
%%  io:format("code test!").
  gen_server:call(?SERVER, {get_config, Key}).
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
    mer_list_map = get_mer_list()
    , public_key = get_ums_public_key()
  },
  lager:debug("~p get env config = ~p", [?SERVER, State]),
  {ok, State}.

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
handle_call({get_mer_prop, MerId, Key}, _From, #state{mer_list_map = MerListMap} = State)
  when is_atom(Key) ->
  MerPropsMap = maps:get(MerId, MerListMap),
  Value = maps:get(Key, MerPropsMap, undefined),
  {reply, Value, State};
handle_call({get_config, Key}, _From, State) ->
  Return = do_get_config(Key, State),
  {reply, Return, State}.

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
handle_cast(_Request, State) ->
  {noreply, State}.

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
handle_info(_Info, State) ->
  {noreply, State}.

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
get_mer_list() ->
  {ok, MerPropsMap} = application:get_env(ums_mer_props),
%%  lager:debug("maps origal = ~p", [MerPropsMap]),
  F = fun
        (MerId, PropMap) when is_atom(MerId), is_map(PropMap) ->
%%          lager:debug("maps origal = ~p", [PropMap]),
          PrivateKey = load_private_key(MerId),
          MapsRet = maps:put(privateKey, PrivateKey, PropMap),
%%          lager:debug("maps with pk = ~p", [MapsRet]),
          MapsRet
      end,
  MerPropsMapWithPK = maps:map(F, MerPropsMap),
  MerPropsMapWithPK.


get_ums_public_key() ->
  PublicKeyFileName = xfutils:get_filename([home, priv_dir, ums_keys_dir, ums_public_key_file]),
  lager:debug("PublicKeyFileName = ~p", [PublicKeyFileName]),
  PublicKey = xfutils:load_public_key(PublicKeyFileName),
  PublicKey.

do_get_config(public_key, #state{public_key = PublicKey} = State) when is_record(State, state) ->
  PublicKey;
do_get_config(Key, _) when is_atom(Key) ->
  {ok, Value} = application:get_env(Key),
  Value.

%%--------------------------------------------------------------------
load_private_key(MerId) when is_atom(MerId) ->
  MerIdBin = atom_to_binary(MerId, utf8),
  KeyPath = xfutils:get_path([home, priv_dir, ums_keys_dir]),
  KeyFileName = list_to_binary([KeyPath, MerIdBin, ".key"]),
  lager:debug("private key file name = ~p", [KeyFileName]),
  {ok, Pwd} = application:get_env(private_key_default_pwd),
  PrivateKey = xfutils:load_private_key(KeyFileName, Pwd),
  PrivateKey.

%%--------------------------------------------------------------------