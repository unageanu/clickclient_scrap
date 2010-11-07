# -*- coding: utf-8 -*- 

$: << "../lib"

require 'clickclient_scrap'
require 'common'

describe "list_orders" do
  include TestBase
  it "複数のページがあってもすべてのデータが取得できる" do
    do_test {|s|
      10.times{|i|
        @order_ids << @s.order( ClickClientScrap::FX::USDJPY, ClickClientScrap::FX::BUY, 1, {
          :rate=>@rates[ClickClientScrap::FX::USDJPY].ask_rate - 0.5,
          :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
          :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
        })
      }
     10.times{|i|
        @order_ids << @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::BUY, 1, {
          :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5, 
          :stop_order_rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5,
          :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
        })
      }
      result = @s.list_orders(ClickClientScrap::FX::ORDER_CONDITION_ON_ORDER)
      result.size.should == 20
    }
  end
end
