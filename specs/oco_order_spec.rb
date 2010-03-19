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
      @order_id.should_not be_nil
      @order_id.order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_id.order_no
      @order.trade_type.should == ClickClientScrap::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == ClickClientScrap::FX::BUY
      @order.pair.should == ClickClientScrap::FX::EURJPY
      @order.count.should == 1
      @order.rate.should == @rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5
      @order.stop_order_rate.should == @rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5
      @order.stop_order_execution_expression.should == ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
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
      @order_id.should_not be_nil
      @order_id.order_no.should_not be_nil
      @order.should_not be_nil
      @order.order_no.should == @order_id.order_no
      @order.trade_type.should == ClickClientScrap::FX::TRADE_TYPE_NEW
      @order.execution_expression.should == ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
      @order.sell_or_buy.should == ClickClientScrap::FX::SELL
      @order.pair.should == ClickClientScrap::FX::GBPJPY
      @order.count.should == 1
      @order.rate.should == @rates[ClickClientScrap::FX::GBPJPY].ask_rate + 0.5
      @order.stop_order_rate.should == @rates[ClickClientScrap::FX::GBPJPY].ask_rate - 0.5
      @order.stop_order_execution_expression.should == ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
      @order.order_type= ClickClientScrap::FX::ORDER_TYPE_OCO
    }
  end
end
