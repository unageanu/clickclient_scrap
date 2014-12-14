# -*- coding: utf-8 -*- 

$: << "../lib"

require 'clickclient_scrap'
require 'common'

describe "OCO" do
  include TestBase

  it "OCO-買" do
    do_test {|s|
      @order_id = @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::BUY, 1, {
        :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5, 
        :stop_order_rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5,
        :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
      })
      @order_ids << @order_id
      orders = @s.list_orders
      @order = orders[@order_id.order_no]
      expect(@order_id).not_to be_nil
      expect(@order_id.order_no).not_to be_nil
      expect(@order).not_to be_nil
      expect(@order.order_no).to eq @order_id.order_no
      expect(@order.trade_type).to eq ClickClientScrap::FX::TRADE_TYPE_NEW
      expect(@order.execution_expression).to eq ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      expect(@order.sell_or_buy).to eq ClickClientScrap::FX::BUY
      expect(@order.pair).to eq ClickClientScrap::FX::EURJPY
      expect(@order.count).to eq 1
      expect(@order.rate).to eq @rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5
      expect(@order.stop_order_rate).to eq @rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5
      expect(@order.stop_order_execution_expression).to eq ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.order_type= ClickClientScrap::FX::ORDER_TYPE_OCO
    }
  end
  
  it "OCO-売" do
     do_test {|s|
      @order_id = @s.order( ClickClientScrap::FX::GBPJPY, ClickClientScrap::FX::SELL, 1, {
        :rate=>@rates[ClickClientScrap::FX::GBPJPY].ask_rate + 0.5, 
        :stop_order_rate=>@rates[ClickClientScrap::FX::GBPJPY].ask_rate - 0.5,
        :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_WEEK_END
      })
      @order_ids << @order_id
      orders = @s.list_orders
      @order = orders[@order_id.order_no]
      expect(@order_id).not_to be_nil
      expect(@order_id.order_no).not_to be_nil
      expect(@order).not_to be_nil
      expect(@order.order_no).to eq @order_id.order_no
      expect(@order.trade_type).to eq ClickClientScrap::FX::TRADE_TYPE_NEW
      expect(@order.execution_expression).to eq ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      expect(@order.sell_or_buy).to eq ClickClientScrap::FX::SELL
      expect(@order.pair).to eq ClickClientScrap::FX::GBPJPY
      expect(@order.count).to eq 1
      expect(@order.rate).to eq @rates[ClickClientScrap::FX::GBPJPY].ask_rate + 0.5
      expect(@order.stop_order_rate).to eq @rates[ClickClientScrap::FX::GBPJPY].ask_rate - 0.5
      expect(@order.stop_order_execution_expression).to eq ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.order_type= ClickClientScrap::FX::ORDER_TYPE_OCO
    }
  end
end
