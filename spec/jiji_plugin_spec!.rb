# -*- coding: utf-8 -*- 

$:.unshift "../lib"

require "rubygems"
require "logger"
require 'clickclient_scrap'
require "common"
require 'jiji/plugin/plugin_loader'
require 'jiji/plugin/securities_plugin'
require 'jiji_plugin'

# jijiプラグインのテスト
# ※実際に取引を行うので注意!
describe "market order" do
  before(:all) {
    # ロード
    @logger = Logger.new STDOUT
  } 
  it "jiji pluginのテスト(DEMO)" do
    plugins = JIJI::Plugin.get( JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME )
    plugin = plugins.find {|i| i.plugin_id == :click_securities_demo }
    
    expect(plugin).not_to be_nil
    expect(plugin.display_name).to eq "CLICK Securities DEMO"
    
    begin
      plugin.init_plugin( {:user=>DEMO_USER, :password=>DEMO_PASS}, @logger )
      
      # 利用可能な通貨ペア一覧とレート
      pairs = plugin.list_pairs
      rates = plugin.list_rates
      pairs.each {|p|
        # 利用可能とされたペアのレートが取得できていることを確認
        expect(p.name).not_to be_nil
        expect(p.trade_unit).not_to be_nil
        expect(rates[p.name]).not_to be_nil
        expect(rates[p.name].bid).not_to be_nil
        expect(rates[p.name].ask).not_to be_nil
        expect(rates[p.name].sell_swap).not_to be_nil
        expect(rates[p.name].buy_swap).not_to be_nil
      }
      sleep 1
      
      # 売り/買い
      sell = plugin.order( :EURJPY, :sell, 1 )      
      buy  = plugin.order( :EURJPY, :buy, 1 ) 
      expect(sell.position_id).not_to be_nil
      expect(buy.position_id).not_to be_nil
      
      # 約定
      plugin.commit sell.position_id, 1 
      plugin.commit buy.position_id, 1
    ensure
      plugin.destroy_plugin
    end
  end
  
  it "jiji pluginのテスト" do
    plugins = JIJI::Plugin.get( JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME )
    plugin = plugins.find {|i| i.plugin_id == :click_securities }
    
    expect(plugin).not_to be_nil
    expect(plugin.display_name).to eq "CLICK Securities"
    
    begin
      plugin.init_plugin( {:user=>USER, :password=>PASS}, @logger )
      
      # 利用可能な通貨ペア一覧とレート
      pairs = plugin.list_pairs
      rates = plugin.list_rates
      pairs.each {|p|
        # 利用可能とされたペアのレートが取得できていることを確認
        expect(p.name).not_to be_nil
        expect(p.trade_unit).not_to be_nil
        expect(rates[p.name]).not_to be_nil
        expect(rates[p.name].bid).not_to be_nil
        expect(rates[p.name].ask).not_to be_nil
        expect(rates[p.name].sell_swap).not_to be_nil
        expect(rates[p.name].buy_swap).not_to be_nil
      }
      sleep 1
      
      # 売り/買い
      sell = plugin.order( :EURJPY, :sell, 1 )      
      buy  = plugin.order( :EURJPY, :buy, 1 ) 
      expect(sell.position_id).not_to be_nil
      expect(buy.position_id).not_to be_nil
      
      # 約定
      plugin.commit sell.position_id, 1 
      plugin.commit buy.position_id, 1
    ensure
      plugin.destroy_plugin
    end
  end
end
