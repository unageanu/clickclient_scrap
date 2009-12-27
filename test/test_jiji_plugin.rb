#!/usr/bin/ruby

$: << "../lib"

require "runit/testcase"
require "logger"
require "runit/cui/testrunner"
require 'clickclient_scrap'
require 'jiji/plugin/plugin_loader'
require 'jiji/plugin/securities_plugin'

# jijiプラグインのテスト
# ※実際に取引を行うので注意!
class JIJIPluginTest <  RUNIT::TestCase

  def setup
    @logger = Logger.new STDOUT
    @user = IO.read( "../etc/user" )
    @pass = IO.read( "../etc/pass" )
  end
 
  def test_basic
    # ロード
    JIJI::Plugin::Loader.new.load
    plugins = JIJI::Plugin.get( JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME )
    plugin = plugins.find {|i| i.plugin_id == :click_securities }
    assert_not_nil plugin
    assert_equals plugin.display_name, "CLICK Securities"
    
    begin
      plugin.init_plugin( {:user=>@user, :password=>@pass}, @logger )
      
      # 利用可能な通貨ペア一覧とレート
      pairs = plugin.list_pairs
      rates =  plugin.list_rates
      pairs.each {|p|
        # 利用可能とされたペアのレートが取得できていることを確認
        assert_not_nil p.name
        assert_not_nil p.trade_unit
        assert_not_nil rates[p.name]
        assert_not_nil rates[p.name].bid
        assert_not_nil rates[p.name].ask
        assert_not_nil rates[p.name].sell_swap
        assert_not_nil rates[p.name].buy_swap
      }
      sleep 1
      
      3.times {
        rates =  plugin.list_rates
        pairs.each {|p|
          # 利用可能とされたペアのレートが取得できていることを確認
          assert_not_nil p.name
          assert_not_nil p.trade_unit
          assert_not_nil rates[p.name]
          assert_not_nil rates[p.name].bid
          assert_not_nil rates[p.name].ask
          assert_not_nil rates[p.name].sell_swap
          assert_not_nil rates[p.name].buy_swap
        }
        sleep 10
      }
      
#      # 売り/買い
#      sell = plugin.order( :USDJPY, :sell, 1 )      
#      buy  = plugin.order( :USDJPY, :buy, 1 ) 
#      assert_not_nil sell.position_id
#      assert_not_nil buy.position_id
#      
#      # 約定
#      plugin.commit sell.position_id, 1 
#      plugin.commit buy.position_id, 1
    ensure
      plugin.destroy_plugin
    end
  end
  
end