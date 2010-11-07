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
      @order_ids[0].should_not be_nil
      @order_ids[0].order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_ids[0].order_no
      @order.trade_type.should == ClickClientScrap::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == ClickClientScrap::FX::BUY
      @order.pair.should == ClickClientScrap::FX::EURJPY
      @order.count.should == 1
      @order.rate.should == @rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5
      @order.stop_order_rate.should be_nil
      @order.stop_order_execution_expression.should be_nil
      @order.order_type= ClickClientScrap::FX::ORDER_TYPE_NORMAL
      
      #指値-売り
      @order_ids[1] = @s.order( ClickClientScrap::FX::USDJPY, ClickClientScrap::FX::SELL, 1, {
        :rate=>@rates[ClickClientScrap::FX::USDJPY].ask_rate + 0.5,
        :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_WEEK_END
      })
      @order = @s.list_orders[@order_ids[1].order_no]
      @order_ids[1].should_not be_nil
      @order_ids[1].order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_ids[1].order_no
      @order.trade_type.should == ClickClientScrap::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == ClickClientScrap::FX::SELL
      @order.pair.should == ClickClientScrap::FX::USDJPY
      @order.count.should == 1
      @order.rate.should == @rates[ClickClientScrap::FX::USDJPY].ask_rate + 0.5
      @order.stop_order_rate.should be_nil
      @order.stop_order_execution_expression.should be_nil
      @order.order_type= ClickClientScrap::FX::ORDER_TYPE_NORMAL
      
      #逆指値-買い
      @order_ids[2] = @s.order( ClickClientScrap::FX::EURUSD, ClickClientScrap::FX::BUY, 1, {
       :rate=>@rates[ClickClientScrap::FX::EURUSD].ask_rate + 0.05,
       :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
       :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
      })
      @order = @s.list_orders[@order_ids[2].order_no]
      @order_ids[2].should_not be_nil
      @order_ids[2].order_no.should_not be_nil
      @order = @s.list_orders[@order_ids[2].order_no]
      @order.should_not be_nil
      @order.order_no.should == @order_ids[2].order_no
      @order.trade_type.should == ClickClientScrap::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.sell_or_buy.should == ClickClientScrap::FX::BUY
      @order.pair.should == ClickClientScrap::FX::EURUSD
      @order.count.should == 1
      @order.rate.to_s.should == (@rates[ClickClientScrap::FX::EURUSD].ask_rate + 0.05).to_s
      @order.stop_order_rate.should be_nil
      @order.stop_order_execution_expression.should be_nil
      @order.order_type= ClickClientScrap::FX::ORDER_TYPE_NORMAL
      
      #逆指値-売り
      @order_ids[3] = @s.order( ClickClientScrap::FX::GBPJPY, ClickClientScrap::FX::SELL, 2, {
        :rate=>@rates[ClickClientScrap::FX::GBPJPY].ask_rate - 0.5,
        :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
        :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED,  # 有効期限: 指定
        :expiration_date=>Date.today+2 # 2日後
      })
      @order = @s.list_orders[@order_ids[3].order_no]
      @order_ids[3].should_not be_nil
      @order_ids[3].order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_ids[3].order_no
      @order.trade_type.should == ClickClientScrap::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.sell_or_buy.should == ClickClientScrap::FX::SELL
      @order.pair.should == ClickClientScrap::FX::GBPJPY
      @order.count.should == 2
      @order.rate.should == @rates[ClickClientScrap::FX::GBPJPY].ask_rate - 0.5
      @order.stop_order_rate.should be_nil
      @order.stop_order_execution_expression.should be_nil
      @order.order_type= ClickClientScrap::FX::ORDER_TYPE_NORMAL
    }
  end
end
