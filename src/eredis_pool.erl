%%%-------------------------------------------------------------------
%%% @author Hiroe Shin <shin@mac-hiroe-orz-17.local>
%%% @copyright (C) 2011, Hiroe Shin
%%% @doc
%%%
%%% @end
%%% Created :  9 Oct 2011 by Hiroe Shin <shin@mac-hiroe-orz-17.local>
%%%-------------------------------------------------------------------
-module(eredis_pool).

%% Include
-include_lib("eunit/include/eunit.hrl").

%% Default timeout for calls to the client gen_server
%% Specified in http://www.erlang.org/doc/man/gen_server.html#call-3
-define(TIMEOUT, 5000).

%% API
-export([start/0, stop/0]).
-export([q/2, q/3, 
         qp/2, qp/3,
         create_pool/2, create_pool/3, create_pool/4, create_pool/5,
         create_pool/6, create_pool/7, 
         delete_pool/1]).

%%%===================================================================
%%% API functions
%%%===================================================================

start() ->
    application:start(?MODULE).

stop() ->
    application:stop(?MODULE).

%% ===================================================================
%% @doc create new pool.
%% @end
%% ===================================================================
-spec(create_pool(PoolName::atom(), Size::integer()) -> 
             {ok, pid()} | {error,{already_started, pid()}}).

create_pool(PoolName, Size) ->
    eredis_pool_sup:create_pool(PoolName, Size, []).

-spec(create_pool(PoolName::atom(), Size::integer(), Host::string()) -> 
             {ok, pid()} | {error,{already_started, pid()}}).

create_pool(PoolName, Size, Host) ->
    eredis_pool_sup:create_pool(PoolName, Size, [{host, Host}]).

-spec(create_pool(PoolName::atom(), Size::integer(), 
                  Host::string(), Port::integer()) -> 
             {ok, pid()} | {error,{already_started, pid()}}).

create_pool(PoolName, Size, Host, Port) ->
    eredis_pool_sup:create_pool(PoolName, Size, [{host, Host}, {port, Port}]).

-spec(create_pool(PoolName::atom(), Size::integer(), 
                  Host::string(), Port::integer(), Database::string()) -> 
             {ok, pid()} | {error,{already_started, pid()}}).

create_pool(PoolName, Size, Host, Port, Database) ->
    eredis_pool_sup:create_pool(PoolName, Size, [{host, Host}, {port, Port},
                                                 {database, Database}]).

-spec(create_pool(PoolName::atom(), Size::integer(), 
                  Host::string(), Port::integer(), 
                  Database::string(), Password::string()) -> 
             {ok, pid()} | {error,{already_started, pid()}}).

create_pool(PoolName, Size, Host, Port, Database, Password) ->
    eredis_pool_sup:create_pool(PoolName, Size, [{host, Host}, {port, Port},
                                                 {database, Database},
                                                 {password, Password}]).

-spec(create_pool(PoolName::atom(), Size::integer(), 
                  Host::string(), Port::integer(), 
                  Database::string(), Password::string(),
                  ReconnectSleep::integer()) -> 
             {ok, pid()} | {error,{already_started, pid()}}).

create_pool(PoolName, Size, Host, Port, Database, Password, ReconnectSleep) ->
    eredis_pool_sup:create_pool(PoolName, Size, [{host, Host}, {port, Port},
                                                 {database, Database},
                                                 {password, Password},
                                                 {reconnect_sleep, ReconnectSleep}]).


%% ===================================================================
%% @doc delet pool and disconnected to Redis.
%% @end
%% ===================================================================
-spec(delete_pool(PoolName::atom()) -> ok | {error,not_found}).

delete_pool(PoolName) ->
    eredis_pool_sup:delete_pool(PoolName).

%%--------------------------------------------------------------------
%% @doc
%% Executes the given command in the specified connection. The
%% command must be a valid Redis command and may contain arbitrary
%% data which will be converted to binaries. The returned values will
%% always be binaries.
%%
%% WorkerはcheckoutしてPidを得た後にすぐさまcheckinしています。
%% eredisがnon-blockingなクエリ処理をする仕組みを活かす為です。
%%
%% @end
%%--------------------------------------------------------------------
-spec q(PoolName::atom(), Command::iolist()) ->
               {ok, binary() | [binary()]} | {error, Reason::binary()}.

q(PoolName, Command) ->
    q(PoolName, Command, ?TIMEOUT).

-spec q(PoolName::atom(), Command::iolist(), Timeout::integer()) ->
               {ok, binary() | [binary()]} | {error, Reason::binary()}.

q(PoolName, Command, Timeout) ->
    Worker = poolboy:checkout(PoolName),
    Reply = eredis:q(Worker, Command, Timeout),
    poolboy:checkin(PoolName, Worker),
    Reply.

-spec qp(PoolName::atom(), [Command::iolist()]) ->
               {ok, [binary()]}.

qp(PoolName, Commands) ->
    qp(PoolName, Commands, ?TIMEOUT).

-spec qp(PoolName::atom(), [Command::iolist()], Timeout::integer()) ->
               {ok, [binary()]}.

qp(PoolName, Commands, Timeout) ->
    Worker = poolboy:checkout(PoolName),
    Reply = eredis:qp(Worker, Commands, Timeout),
    poolboy:checkin(PoolName, Worker),
    Reply.

