%%%-------------------------------------------------------------------
%%% @author pingjianwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 十月 2017 11:34
%%%-------------------------------------------------------------------
-module(utils_verify).
-author("pingjianwei").

%% API
-export([handle_req/2]).

handle_req(ums,ReqParams)->
  ReqParams2 = key_change({signature,sign},ReqParams),
  ReqBody = jsx:encode(ReqParams2),
  UmsUrl = ums_config:get_config(ums_bank_url),
  Timeout = ums_config:get_config(ums_timeout),
  case httpc:request(post, {UmsUrl, [], "application/json;charset=UTF-8", ReqBody}, [{timeout,Timeout}], []) of
    {ok, {{_, 200, _}, _, RespBody}} ->
      UpRespBody = jsx:decode(list_to_binary(RespBody), [return_maps]),
      lager:debug("Up response body = ~p", [UpRespBody]),
      maps:put(httpCode,200,UpRespBody);

    {ok, {{_, RespCode, _}, _, RespBody}} ->
      lager:error("Verify failed:~p ReqUrl = ~p ReqParams =~p  ",[ {RespCode,RespBody},UmsUrl,ReqParams]),
      #{httpCode=>RespCode};
    {error, Reason} ->
      lager:error("Connetion failed :~p ReqUrl = ~p ReqParams =~p  ",[ Reason,UmsUrl,ReqParams]),
      #{httpCode=>error}
  end;
handle_req(zt,ReqParams)->
  ok.
%%--------------------------------------------------------
key_change({From,To},ReqParams) when is_map(ReqParams)->
  Proplist = maps:to_list(ReqParams),
  key_change({From,To},Proplist);
key_change({From,To},ReqParams) when is_list(ReqParams)->
  FromBin = convert_to_binary(From),
  ToBin = convert_to_binary(To),
  Value = proplists:get_value(FromBin,ReqParams),
  proplists:delete(FromBin,ReqParams) ++ [{ToBin,Value}].

convert_to_binary(X) when is_atom(X)->
  atom_to_binary(X,utf8);
convert_to_binary(X) when is_binary(X)->
  X.
%%----------------------------------------------------------