  -module(crud_basket).
  -behaviour(gen_server).
 
  -export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
 
  -export([checkout/2, get_basket/1,update_basket/2,delete_basket/1, start_link/0]).
-record(item,{id}).
-record(basket,{id,items=[]::item}).
 
  start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% ====================================================================
%% Basket functions 
%% ====================================================================

%% **************checkout the customer basket*****************************
-spec checkout(Customer::term(),Basket::basket)->term().
  checkout(Customer, Basket) -> gen_server:call(?MODULE, {checkout, Customer, Basket}).
%%*****************get the basket for the customer************************
-spec get_basket(Customer::term())->basket.
  get_basket(Customer) -> gen_server:call(?MODULE, {get_basket, Customer}).
%%********************* update basket - upserts based on the basket composition*****************
update_basket(Customer,Basket)->gen_server:call(?MODULE, {update_basket,Customer,Basket}).
%%********************* Delete Basket that belongs to the customer*****************
delete_basket(Customer) -> gen_server:call(?MODULE, {delete_basket, Customer}).

%% ====================================================================
%% End Basket functions 
%% ====================================================================


  init([]) ->
       Tab = ets:new(?MODULE, []),
       {ok, Tab}.
 %% handle checkout method
  handle_call({checkout, Customer, Basket}, _From, Tab) ->
       OnCheckOut = {proceed_to_payment_section,ok},
       {reply, OnCheckOut, Tab};
  %% get_basket method implemention here
  handle_call({get_basket, Customer}, _From, Tab) ->
        OnGetBasket = case ets:lookup(Tab, Customer) of
               [{Customer, Basket}] ->
                   Basket;
               [] ->
                   none
        end,
        {reply, OnGetBasket, Tab};
%% update_basket method implemention here
handle_call({update_basket,Customer, NewBasket},_From, Tab)->
	OnUpdate = case ets:lookup(Tab, Customer) of
				   [{Customer,Basket}]->
					  ets:update_element(Tab, Customer,{2,NewBasket}),
					   {item_updated, NewBasket};
				   []->
					   ets:insert(Tab, {Customer,NewBasket}) ,NewBasket end, {reply, OnUpdate, Tab}
					   ;
%%delete basket
handle_call({delete_basket,Customer},_From, Tab) ->
	OnDelete = ets:delete(Tab, Customer),{deleted_table_for,Customer},  {reply, OnDelete, Tab}.
 
  handle_cast(_Msg, State) -> {noreply, State}.
  handle_info(_Msg, State) -> {noreply, State}.
  terminate(_Reason, _State) -> ok.
  code_change(_OldVersion, State, _Extra) -> {ok, State}.
