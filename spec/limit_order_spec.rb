# -*- coding: utf-8 -*- 

$: << "../lib"

require 'clickclient_scrap'
require 'common'

describe "limit" do
  include TestBase
  
  it "指値/逆指値での注文テスト" do
    do_test {|s|
      #指値-買い
      @order_ids[0] = @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::BUY, 1, {
        :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5,
        :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
      })
      @order = @s.list_orders[@order_ids[0].order_no]
      expect(@order_ids[0]).not_to be_nil
      expect(@order_ids[0].order_no).not_to be_nil
      expect(@order).not_to be_nil
      expect(@order.order_no).to eq @order_ids[0].order_no
      expect(@order.trade_type).to eq ClickClientScrap::FX::TRADE_TYPE_NEW
      expect(@order.execution_expression).to eq ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      expect(@order.sell_or_buy).to eq ClickClientScrap::FX::BUY
      expect(@order.pair).to eq ClickClientScrap::FX::EURJPY
      expect(@order.count).to eq 1
      expect(@order.rate).to eq @rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5
      expect(@order.stop_order_rate).to be_nil
      expect(@order.stop_order_execution_expression).to be_nil
      @order.order_type= ClickClientScrap::FX::ORDER_TYPE_NORMAL
      
      #指値-売り
      @order_ids[1] = @s.order( ClickClientScrap::FX::USDJPY, ClickClientScrap::FX::SELL, 1, {
        :rate=>@rates[ClickClientScrap::FX::USDJPY].ask_rate + 0.5,
        :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_WEEK_END
      })
      @order = @s.list_orders[@order_ids[1].order_no]
      expect(@order_ids[1]).not_to be_nil
      expect(@order_ids[1].order_no).not_to be_nil
      expect(@order).not_to be_nil
      expect(@order.order_no).to eq @order_ids[1].order_no
      expect(@order.trade_type).to eq ClickClientScrap::FX::TRADE_TYPE_NEW
      expect(@order.execution_expression).to eq ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      expect(@order.sell_or_buy).to eq ClickClientScrap::FX::SELL
      expect(@order.pair).to eq ClickClientScrap::FX::USDJPY
      expect(@order.count).to eq 1
      expect(@order.rate).to eq @rates[ClickClientScrap::FX::USDJPY].ask_rate + 0.5
      expect(@order.stop_order_rate).to be_nil
      expect(@order.stop_order_execution_expression).to be_nil
      @order.order_type= ClickClientScrap::FX::ORDER_TYPE_NORMAL
      
      #逆指値-買い
      @order_ids[2] = @s.order( ClickClientScrap::FX::EURUSD, ClickClientScrap::FX::BUY, 1, {
       :rate=>@rates[ClickClientScrap::FX::EURUSD].ask_rate + 0.05,
       :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
       :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
      })
      @order = @s.list_orders[@order_ids[2].order_no]
      expect(@order_ids[2]).not_to be_nil
      expect(@order_ids[2].order_no).not_to be_nil
      @order = @s.list_orders[@order_ids[2].order_no]
      expect(@order).not_to be_nil
      expect(@order.order_no).to eq @order_ids[2].order_no
      expect(@order.trade_type).to eq ClickClientScrap::FX::TRADE_TYPE_NEW
      expect(@order.execution_expression).to eq ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      expect(@order.sell_or_buy).to eq ClickClientScrap::FX::BUY
      expect(@order.pair).to eq ClickClientScrap::FX::EURUSD
      expect(@order.count).to eq 1
      expect(@order.rate.to_s).to eq( (@rates[ClickClientScrap::FX::EURUSD].ask_rate + 0.05).to_s)
      expect(@order.stop_order_rate).to be_nil
      expect(@order.stop_order_execution_expression).to be_nil
      @order.order_type= ClickClientScrap::FX::ORDER_TYPE_NORMAL
      
      #逆指値-売り
      @order_ids[3] = @s.order( ClickClientScrap::FX::GBPJPY, ClickClientScrap::FX::SELL, 2, {
        :rate=>@rates[ClickClientScrap::FX::GBPJPY].ask_rate - 0.5,
        :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
        :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED,  # 有効期限: 指定
        :expiration_date=>Date.today+2 # 2日後
      })
      @order = @s.list_orders[@order_ids[3].order_no]
      expect(@order_ids[3]).not_to be_nil
      expect(@order_ids[3].order_no).not_to be_nil
      expect(@order).not_to be_nil
      expect(@order.order_no).to eq @order_ids[3].order_no
      expect(@order.trade_type).to eq ClickClientScrap::FX::TRADE_TYPE_NEW
      expect(@order.execution_expression).to eq ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      expect(@order.sell_or_buy).to eq ClickClientScrap::FX::SELL
      expect(@order.pair).to eq ClickClientScrap::FX::GBPJPY
      expect(@order.count).to eq 2
      expect(@order.rate).to eq @rates[ClickClientScrap::FX::GBPJPY].ask_rate - 0.5
      expect(@order.stop_order_rate).to be_nil
      expect(@order.stop_order_execution_expression).to be_nil
      @order.order_type= ClickClientScrap::FX::ORDER_TYPE_NORMAL
    }
  end
end
