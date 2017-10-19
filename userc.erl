%%%-------------------------------------------------------------------
%%% @author pingjianwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 十月 2017 23:30
%%%-------------------------------------------------------------------
-module(userc).
-author("pingjianwei").
%% API
-compile(export_all).
%%常用的测试目录：请保证路径正确，注意路径里面是用/ 或\\的
-define(WORK_DIRS, [
  "src/",
  "src/repo/",
  "src/model/",
  "src/protocol/model/",
  "src/protocol/model/mcht/",
  "src/protocol/model/ums/",
  "src/protocol/model/up/",
  "src/protocol/processor/",
  "src/ums/",
  "src/utils/",
  "src/web_handle/",
  "src/web_rest_api/"
]).
-define(INCLUDE_DIRS, ["/src/include/"]).

cfile(FileName) ->
%%  code:add_path(?OUT_DIR),
  {ok,RootPath} =file:get_cwd(),
  try
    cfile(FileName, ?WORK_DIRS)
  catch
     Exception :ErrorMsg-> io:format("~p:~p",[Exception,ErrorMsg])
  after
    c:cd(RootPath)
  end.

cfile(FileName, []) ->
  {erlang:atom_to_list(FileName) ++ ":not find", ?WORK_DIRS};
cfile(FileName, [Path | Left]) ->
  FileDir = Path ++ erlang:atom_to_list(FileName) ++ ".erl",
  case file:read_file_info(FileDir) of
    {ok, _} ->
      c:cd(Path),
      IncludeDirs = [begin {i, Dir} end || Dir <- ?INCLUDE_DIRS],
      io:format("outdir : ~p ~n",[get_out_dir(FileName)]),

      CompileOptions = [{outdir, get_out_dir(FileName)}, {parse_transform, lager_transform},
        {parse_transform, exprecs}, report, verbose] ++ IncludeDirs,

      case compile:file(FileName, CompileOptions) of
        {ok, T} -> c:l(T), {ok, T};
        Err -> Err
      end;
    _ ->
      cfile(FileName, Left)
  end.


get_out_dir(FileName) when is_atom(FileName) ->
  Path = code:which(FileName),
  PathBin = list_to_binary(Path),
  {Pos,_} =binary:match(PathBin,list_to_binary([atom_to_binary(FileName,utf8),<<".beam">>])),
  OutDirBin =binary:part(PathBin,0,Pos),
  binary_to_list(OutDirBin).

test()->
  file:get_cwd().


