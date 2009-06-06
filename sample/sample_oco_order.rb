
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
  
  ##OCO注文
  session.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::BUY, 1, {
    :rate=>rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5, # 指値レート
    :stop_order_rate=>rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5, # 逆指値レート
    :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER, # 執行条件: 指値 
    :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY  # 有効期限: 当日限り 
  })
  session.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
    :rate=>rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5, # 指値レート
    :stop_order_rate=>rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5, # 逆指値レート
    :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER, # 執行条件: 指値 
    :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED,  # 有効期限: 指定
    :expiration_date=>Date.today+2 # 2日後
  })

  # 注文のキャンセルをお忘れなく。
}
