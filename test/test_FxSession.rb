#!/usr/bin/ruby

$: << "../lib"

require "runit/testcase"
require "runit/cui/testrunner"
require 'clickclient_scrap'

class FxSessionTest <  RUNIT::TestCase
 
  #convert_rate のテスト
  def test_convert_rate
    rate = ClickClient::FX::FxSession.convert_rate("123.34-37").map {|i| i.to_s }
    assert_equals rate, [ "123.34", "123.37" ]
    
    rate = ClickClient::FX::FxSession.convert_rate("123.534-37").map {|i| i.to_s }
    assert_equals rate, [ "123.534", "123.537" ]
    
    rate = ClickClient::FX::FxSession.convert_rate("123.594-02").map {|i| i.to_s }
    assert_equals rate, [ "123.594", "123.602" ]
    
    rate = ClickClient::FX::FxSession.convert_rate("123.00-02").map {|i| i.to_s }
    assert_equals rate, [ "123.0", "123.02" ]
    
    rate = ClickClient::FX::FxSession.convert_rate("123.34-33").map {|i| i.to_s }
    assert_equals rate, [ "123.34", "124.33" ]
    
    rate = ClickClient::FX::FxSession.convert_rate("123.34-34").map {|i| i.to_s }
    assert_equals rate, [ "123.34", "123.34" ]
    
    rate = ClickClient::FX::FxSession.convert_rate("0.334-335").map {|i| i.to_s }
    assert_equals rate, [ "0.334", "0.335" ]
    
    rate = ClickClient::FX::FxSession.convert_rate("0.334-333").map {|i| i.to_s }
    assert_equals rate, [ "0.334", "1.333" ]
  end
  
end