# -*- coding: utf-8 -*- 

$: << "../lib"

require 'clickclient_scrap'
require 'common'

describe "cancel_order" do
  include TestBase
  
  it "複数のページがあってもキャンセルできる" do
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
      
      # 末尾から消していき、すべて削除できればOK。
      @order_ids.reverse.each {|id| 
        @s.cancel_order(id.order_no)
        @order_ids.pop
      }
      expect(@s.list_orders(ClickClientScrap::FX::ORDER_CONDITION_ON_ORDER).size).to eq 0
    }
  end
  
  it "削除対象が存在しない" do
    do_test {|s|
      expect {
        @s.cancel_order("not found")
      }.to raise_error( RuntimeError, "illegal order_no. order_no=not found" )
    }
  end
  
end
