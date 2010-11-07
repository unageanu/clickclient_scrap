# -*- coding: utf-8 -*- 

$: << "."
$: << "../lib"

require 'clickclient_scrap'
require 'constants'

# ログイン
c = ClickClientScrap::Client.new
c.fx_session( USER, PASS ) {|session|
  
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
}
