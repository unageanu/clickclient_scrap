
require 'rubygems'
require 'jiji/plugin/securities_plugin'
require 'clickclient_scrap'
require 'thread'

# クリック証券アクセスプラグイン
class ClickSecuritiesPlugin
  include JIJI::Plugin::SecuritiesPlugin
  
  #プラグインの識別子を返します。
  def plugin_id
    :click_securities
  end
  #プラグインの表示名を返します。
  def display_name
    "CLICK Securities"
  end
  #「jiji setting」でユーザーに入力を要求するデータの情報を返します。
  def input_infos
    [ Input.new( :user, "Please input a user name of CLICK Securities.", false, nil ),
      Input.new( :password, "Please input a password of CLICK Securities.", true, nil ),
      Input.new( :proxy, "Please input a proxy. example: http://example.com:80 (default: nil )", false, nil ) ]
  end
  
  #プラグインを初期化します。
  def init_plugin( props, logger ) 
    @session = ClickSecuritiesPluginSession.new( props, logger )
  end
  #プラグインを破棄します。
  def destroy_plugin
    @session.close
  end
  
  #利用可能な通貨ペア一覧を取得します。
  def list_pairs
    return ALL_PAIRS.map {|pair|
      Pair.new( pair, pair == ClickClientScrap::FX::ZARJPY ? 100000 : 10000 )
    }
  end
  
  #現在のレートを取得します。
  def list_rates
    @session.list_rates.inject({}) {|r,p|
        r[p[0]] = Rate.new( p[1].bid_rate, p[1].ask_rate, p[1].sell_swap, p[1].buy_swap )
        r
    }
  end
  
  #成り行きで発注を行います。
  def order( pair, sell_or_buy, count )
    
    # 建玉一覧を取得
    before = @session.list_open_interests.inject( Set.new ) {|s,i| s << i[0]; s }
    # 発注
    @session.order( pair, sell_or_buy == :buy ? ClickClientScrap::FX::BUY : ClickClientScrap::FX::SELL,  count )
    # 建玉を特定
    position = nil
    # 10s待っても取得できなければあきらめる
    20.times {|i|
      sleep 0.5
      position = @session.list_open_interests.find {|i| !before.include?(i[0]) }
      break if position
    }
    raise "order fialed." unless position
    return JIJI::Plugin::SecuritiesPlugin::Position.new( position[1].open_interest_id )
  end
  
  #建玉を決済します。
  def commit( position_id, count )
    @session.settle( position_id, count )
  end

private 
  
  ALL_PAIRS =  [
    ClickClientScrap::FX::USDJPY, ClickClientScrap::FX::EURJPY, 
    ClickClientScrap::FX::GBPJPY, ClickClientScrap::FX::AUDJPY, 
    ClickClientScrap::FX::NZDJPY, ClickClientScrap::FX::CADJPY, 
    ClickClientScrap::FX::CHFJPY, ClickClientScrap::FX::ZARJPY, 
    ClickClientScrap::FX::EURUSD, ClickClientScrap::FX::GBPUSD, 
    ClickClientScrap::FX::AUDUSD, ClickClientScrap::FX::EURCHF, 
    ClickClientScrap::FX::GBPCHF, ClickClientScrap::FX::USDCHF
  ]
end

class ClickSecuritiesPluginSession
  def initialize( props, logger ) 
    @props = props
    @logger = logger
    @m = Mutex.new
  end
  def method_missing( name, *args )
    @m.synchronize { 
      begin
        session.send( name, *args )
      rescue
        # エラーになった場合はセッションを再作成する
        close
        raise $!
      end
    }
  end
  def close
    begin
      @session.logout if @session
    rescue
      @logger.error $!
    ensure
      @session = nil
      @client = nil
    end
  end
  def session
    begin
      proxy = nil
      if @props.key?(:proxy) && @props[:proxy] != nil && @props[:proxy].length > 0
        proxy = @props[:proxy]
      end
      @client ||= ClickClientScrap::Client.new( proxy )
      @session ||= @client.fx_session( @props[:user], @props[:password] )
    rescue
      @logger.error $!
      raise $!
    end
    @session
  end
end

JIJI::Plugin.register( 
  JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME, 
  ClickSecuritiesPlugin.new )

