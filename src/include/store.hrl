%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc 存放和mnesia长期存储有关的结构/表定义
%%%
%%% @end
%%% Created : 08. Apr 2016 16:10
%%%-------------------------------------------------------------------
-author("simonxu").

-define(TXNLOG, txn_log).
-define(MCHTINFO, mcht_info).

-type table() :: mcht_txn_log|up_txn_log | txn_log|mcht_info.
-type txn_type() :: pay | refund | query.
-type txn_status() :: success | waiting |fail.
-type txn_amt() :: non_neg_integer().

-type payment_method() :: [gw_netbank | gw_wap | gw_app].
-type mchants_status() :: normal | forizon | closed.

-record(mcht_txn_log, {
  mcht_index_key
  , txn_type :: txn_type()
  , mcht_id
  , mcht_txn_date
  , mcht_txn_time
  , mcht_txn_seq
  , mcht_txn_amt :: txn_amt()
  , mcht_order_desc
  , gateway_id
  , bank_id
  , prod_id
  , prod_bank_acct_id
  , prod_bank_acct_corp_name
  , prod_bank_name
  , mcht_back_url
  , mcht_front_url
  , prod_memo

  , query_id
  , settle_date
  , quota
  , resp_code
  , resp_msg

  , orig_mcht_txn_date
  , orig_mcht_txn_seq
  , orig_query_id

  , txn_status :: txn_status()


}).
-opaque mcht_txn_log() :: #mcht_txn_log{}.
-export_type([mcht_txn_log/0]).

-record(?TXNLOG, {
  mcht_index_key
  %% mcht req related

  % 考虑支付/退货两种交易的支持,先考虑支付
  , txn_type

  , mcht_id
  , mcht_txn_date
  , mcht_txn_time
  , mcht_txn_seq
  , mcht_order_seq
  , mcht_txn_amt
  , mcht_order_desc
  , mcht_gateway_id
  %, mcht_signature = <<>> :: mcht_signature()
  , mcht_prod_id
  , mcht_prod_bank_acct_id
  , mcht_prod_bank_acct_corp_name
  , mcht_prod_bank_name
  , mcht_back_info_url
  , mcht_front_succ_url


  %% unionpay req related
  %, certId = <<>> :: up_certId()
  %, signature = <<>> :: up_signature()
  , up_merId
  , up_orderId
  , up_txnTime
  %, up_accType = <<>> :: up_accType()
  , up_txnAmt
  %, customerInfo = <<>> :: up_customerInfo()
  %, orderTimeOut = <<>> :: up_orderTimeout()
  %, payTimeout = <<>> :: up_payTimeout()
  %, termId = <<>> :: up_termId()
  , up_reqReserved
  %, reserved = <<>> :: up_reserved()
  %, riskRateInfo = <<>> :: up_riskRateInfo()
  %, encryptCertId = <<>> :: up_encryptCertId()
  %, frontFailUrl = <<>> :: up_frontFailUrl()
  %, instalTransInfo = <<>> :: up_instalTransInfo()
  %, issInsCode = <<>> :: up_issInsCode()
  %, supPayType = <<>> :: up_supPayType()
  , up_orderDesc
  , up_index_key


%% unionpay resp related

  , up_queryId
  , up_respCode
  , up_respMsg
  , up_settleAmt
  , up_settleDate :: binary()
  , up_traceNo
  , up_traceTime

  , up_query_index_key
  %% mcht resp related
  , txn_status
  , up_cardno
}).

-type txn_log() :: #?TXNLOG{}.
-export_type([txn_log/0]).

-record(up_txn_log, {
  mcht_index_key
  %% mcht req related

  % 考虑支付/退货两种交易的支持,先考虑支付
  , txn_type

  , up_merId
  , up_txnTime
  , up_orderId
  , up_txnAmt
  , up_reqReserved
  , up_orderDesc
  , up_issInsCode
  , up_index_key

%% unionpay resp related
  , up_queryId
  , up_respCode
  , up_respMsg
  , up_settleAmt
  , up_settleDate :: binary()
  , up_traceNo
  , up_traceTime
  , up_query_index_key
  %% mcht resp related
  , txn_status
  , up_cardno
}).
-type up_txn_log() :: #up_txn_log{}.
-export_type([up_txn_log/0]).

-record(mchants, {
  id = 0 :: id()
  , mcht_full_name = <<"">> :: name()
  , mcht_short_name = <<"">> :: name()
  , status = normal :: status()
  , payment_method = [gw_netbank] :: payment_method()
  , up_mcht_id = <<"">> :: binary()
  , quota = [{txn, -1}, {daily, -1}, {monthly, -1},{total,0}] :: list()
  , up_term_no = <<"12345678">> :: binary()
  , update_ts = erlang:timestamp() :: ts()
}).
-type mchants() :: #mchants{}.
-export_type([mchants/0]).


-record(channel, {
  id = 0 :: id()
  , type = <<"">> :: name()
  , statue = <<"">> :: name()
  , status = normal :: status()
  , default = [gw_netbank] :: payment_method()
  , facilitator = <<"">> :: binary()
  , timestamp = [{txn, -1}, {daily, -1}, {monthly, -1},{total,0}] :: list()
  , up_term_no = <<"12345678">> :: binary()
  , update_ts = erlang:timestamp() :: ts()
}).
-type mchants() :: #mchants{}.
-export_type([mchants/0]).
5.在pg中添加新表channel,该表的选项列表为[{attributes,record_info(fields,channel)},{disc_copies,[node()]}]
编号	字段名字	字段说明	备注
1	id	通道编号：integer
2	type	服务类型：bankcard，realname
3	statue	通道状态：0或1（0：正常，1：不正常）
4	default	默认通道标识：Y代表默认，N代表非默认
5	facilitator	服务提供者：ums，zt
6	timestamp	通道状态最后更新时间



