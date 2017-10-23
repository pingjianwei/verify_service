%%%-------------------------------------------------------------------
%%% @author pingjianwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 十月 2017 16:10
%%%-------------------------------------------------------------------
-module(aes).
-author("pingjianwei").

%% API
-export([]).
-compile(export_all).
test1() ->
  Key = <<"abcdefghijklmnop">>,
  Content = <<"abcdefghijklmnop"/utf8>>,
  Bin = crypto:block_encrypt(aes_ecb , Key,pkcs5_padding(Content, 16)),
  hexstring(Bin).


pkcs5_padding(PlainText, BlockSize) when is_binary(PlainText) ->
  Rem = size(PlainText) rem BlockSize,
  Padding = lists:duplicate(BlockSize - Rem, BlockSize - Rem),
  Binary = list_to_binary(Padding),
  <<PlainText/binary, Binary/binary>>;
pkcs5_padding(PlainText, BlockSize) when is_list(PlainText) ->
  Rem = length(PlainText) rem BlockSize,
  Padding = lists:duplicate(BlockSize - Rem, BlockSize - Rem),
  PlainText ++ Padding.



hexstring(Binary) when is_binary(Binary)->
  lists:flatten(lists:map(
    fun(X)-> io_lib:format("~2.16.0b", [X]) end,
    binary_to_list(Binary))).