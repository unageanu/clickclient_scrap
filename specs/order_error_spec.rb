$: << "../lib"

require 'clickclient_scrap'
require 'common'

describe "注文の異常系テスト" do
  include TestBase
  
  it "指値/逆指値" do
    do_test {|s|
      # 執行条件の指定がない
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
            :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5,
            :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
          })
      }.should raise_error( RuntimeError, "options[:execution_expression] is required." )
      
      # 有効期限の指定がない
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
            :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5,
            :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
          })
      }.should raise_error( RuntimeError, "options[:expiration_type] is required." )
      
      # 日付指定であるのに日時の指定がない
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
            :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5,
            :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
            :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED
          })
      }.should raise_error( RuntimeError, "options[:expiration_date] is required." )
  
      # 日付指定の範囲が不正
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
            :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5,
            :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
            :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED,
            :expiration_date=>Date.today
          })
      }.should raise_error( RuntimeError )
  
      # レートが不正
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
            :rate=>"-10000000",
            :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
            :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
          })
      }.should raise_error( RuntimeError )
  
      # 取引数量が不正
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, -1, {
            :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5,
            :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
            :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
          })
      }.should raise_error( RuntimeError )
  
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 0, {
            :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5,
            :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
            :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
          })
      }.should raise_error( RuntimeError )
  
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1000, {
            :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5,
            :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
            :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
          })
      }.should raise_error( RuntimeError )
  
      # 不利な注文
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
            :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5,
            :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
            :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
          })
      }.should raise_error( RuntimeError )
      
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
            :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5,
            :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
            :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
          })
      }.should raise_error( RuntimeError )
    }
  end

  it "OCO" do
    do_test {|s|
      # 執行条件の指定がない
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
          :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5, 
          :stop_order_rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5
        })
      }.should raise_error( RuntimeError, "options[:expiration_type] is required." )
      
      # 有効期限の指定がない
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
          :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5, 
          :stop_order_rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5,
          :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
        })
      }.should raise_error( RuntimeError, "options[:expiration_type] is required." )
      
      # 不利な注文
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
            :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5,
            :stop_order_rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate - 0.5,
            :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER,
            :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
          })
      }.should raise_error( RuntimeError )
      
      proc {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
            :rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5,
            :stop_order_rate=>@rates[ClickClientScrap::FX::EURJPY].ask_rate + 0.5,
            :execution_expression=>ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER,
            :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
          })
      }.should raise_error( RuntimeError )
    }
  end
 
end
