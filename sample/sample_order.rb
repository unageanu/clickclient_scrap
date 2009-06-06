
$: << "../lib"

require 'clickclient_scrap'
require 'constants'

# ログイン
c = ClickClientScrap::Client.new
c.fx_session( USER, PASS ) {|session|

  # レートを取得
  rates = session.list_rates
  rates.each_pair {|k,v|
    puts "#{k} : #{v.bid_rate} : #{v.ask_rate} : #{v.sell_swap} : #{v.buy_swap}"
  }
  
  order_ids = []
  
  ## 指値注文
  order_ids << session.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::BUY, 1, {
    :rate=>rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5, # 指値レート
    :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER, # 執行条件: 指値 
    :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY  # 有効期限: 当日限り 
  })
  order_ids << session.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
    :rate=>rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5, # 指値レート
    :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER, # 執行条件: 指値 
    :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_WEEK_END  # 有効期限: 週末まで
  })

  # 逆指値注文
  order_ids << session.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::BUY, 1, {
    :rate=>rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5, # 逆指値レート
    :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER, # 執行条件: 逆指値 
    :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_INFINITY  # 有効期限: 無限
  }) 
  order_ids << session.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
    :rate=>rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5, # 逆指値レート
    :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER, # 執行条件: 逆指値 
    :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED,  # 有効期限: 指定
    :expiration_date=>Date.today+2 # 2日後
  })

  # 注文一覧を取得
  orders = session.list_orders
  orders.each_pair {|k,v|
   puts <<-STR
---
order_no : #{v.order_no} 
trade_type : #{v.trade_type}
order_type : #{v.order_type}
execution_expression : #{v.execution_expression} 
sell_or_buy : #{v.sell_or_buy} 
pair : #{v.pair}
count : #{v.count} 
rate : #{v.rate} 
order_state : #{v.order_state}

STR
  }
  
  # すべての注文をキャンセル
  order_ids.each{|id| session.cancel_order(id.order_no) }
}
