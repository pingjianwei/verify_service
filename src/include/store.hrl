%%%-------------------------------------------------------------------
%%% @author pingjianwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 十月 2017 9:27
%%%-------------------------------------------------------------------
-author("pingjianwei").

-record(channel, {
  id
  , type
  , status
  , default
  , facilitator
  , update_ts = erlang:timestamp() 
}).
-type channel() :: #channel{}.
-export_type([channel/0]).
