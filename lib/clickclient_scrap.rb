begin
  require 'rubygems'
rescue LoadError
end
require 'mechanize'
require 'date'
require 'kconv'

#
#=== クリック証券アクセスクライアント
#
#*Version*::   -
#*License*::   Ruby ライセンスに準拠
#
#クリック証券を利用するためのクライアントライブラリです。携帯向けサイトのスクレイピングにより以下の機能を提供します。
#- 外為証拠金取引(FX)取引
#
#====基本的な使い方
#
# require 'clickclient'
# 
# c = ClickClient::Client.new 
# # c = ClickClient::Client.new https://<プロキシホスト>:<プロキシポート> # プロキシを利用する場合
# c.fx_session( "<ユーザー名>", "<パスワード>" ) { | fx_session |
#   # 通貨ペア一覧取得
#   list = fx_session.list_rates
#   puts list
# } 
#
#====免責
#- 本ライブラリの利用は自己責任でお願いします。
#- ライブラリの不備・不具合等によるあらゆる損害について、作成者は責任を負いません。
#
module ClickClient

  # クライアント
  class Client
    # ホスト名
    DEFAULT_HOST_NAME = "https://sec-sso.click-sec.com/mf/"

    # 通貨ペア: 米ドル-円
    USDJPY = :USDJPY
    # 通貨ペア: ユーロ-円
    EURJPY = :EURJPY
    # 通貨ペア: イギリスポンド-円
    GBPJPY = :GBPJPY
    # 通貨ペア: 豪ドル-円
    AUDJPY = :AUDJPY
    # 通貨ペア: ニュージーランドドル-円
    NZDJPY = :NZDJPY
    # 通貨ペア: カナダドル-円
    CADJPY = :CADJPY
    # 通貨ペア: スイスフラン-円
    CHFJPY = :CHFJPY
    # 通貨ペア: 南アランド-円
    ZARJPY = :ZARJPY
    # 通貨ペア: ユーロ-米ドル
    EURUSD = :EURUSD
    # 通貨ペア: イギリスポンド-米ドル
    GBPUSD = :GBPUSD
    # 通貨ペア: 豪ドル-米ドル
    AUDUSD = :AUDUSD
    # 通貨ペア: ユーロ-スイスフラン
    EURCHF = :EURCHF
    # 通貨ペア: イギリスポンド-スイスフラン
    GBPCHF = :GBPCHF
    # 通貨ペア: 米ドル-スイスフラン
    USDCHF = :USDCHF

    # 売買区分: 買い
    BUY = 0
    # 売買区分: 売り
    SELL = 1

    # 注文タイプ: 通常
    ORDER_TYPE_NORMAL = 0
    # 注文タイプ: IFD
    ORDER_TYPE_IFD = 1
    # 注文タイプ: OCO
    ORDER_TYPE_OCO = 2
    # 注文タイプ: IFD-OCO
    ORDER_TYPE_IFD_OCO = 3


    #
    #===コンストラクタ
    #
    #*proxy*:: プロキシホストを利用する場合、そのホスト名とパスを指定します。
    # 例) https://proxyhost.com:80
    #
    def initialize( proxy=nil  )
      @client = WWW::Mechanize.new {|c|
        # プロキシ
        if proxy 
          uri = URI.parse( proxy )
          c.set_proxy( uri.host, uri.port )
        end
      }
      @client.user_agent_alias = 'Windows IE 7'
      @host_name = DEFAULT_HOST_NAME
    end

    #ログインし、セッションを開始します。
    #-ブロックを指定した場合、引数としてセッションを指定してブロックを実行します。ブロック実行後、ログアウトします。
    #-そうでない場合、セッションを返却します。この場合、ClickClient::FX::FxSession#logoutを実行しログアウトしてください。
    #
    #戻り値:: ClickClient::FX::FxSession
    def fx_session( userid, password, &block )
      page = @client.get(@host_name)
      ClickClient::Client.error(page)  if page.forms.length <= 0
      form = page.forms.first
      form.j_username = userid
      form.j_password = password
      result = @client.submit(form, form.buttons.first) 
      if result.body.toutf8 =~ /<META HTTP-EQUIV="REFRESH" CONTENT="0;URL=([^"]*)">/
         result = @client.get($1)
         session = FX::FxSession.new( @client, result.links )
         if block_given?
           begin
             yield session
           ensure
             session.logout
           end
         else
           return session
         end
      else
        ClickClient::Client.error( result )
      end
    end
    def self.error( page )
        error = page.body.toutf8 =~ /<font color="red">([^<]*)</ ? $1.strip : page.body
        raise "login failed.detail=#{error}".toutf8 
    end
    
    #ホスト名
    attr :host_name, true  
  end
  
  module FX
    #=== FX取引のためのセッションクラス
    #Client#fx_sessionのブロックの引数として渡されます。詳細はClient#fx_sessionを参照ください。
    class FxSession
      
      def initialize( client, links )
        @client = client
        @links = links
      end
      
      #レート一覧を取得します。
      #
      #戻り値:: 通貨ペアをキーとするClickClient::FX::Rateのハッシュ。
      def list_rates
        result =  @client.click( @links.find {|i|
            i.attributes["accesskey"] == "1"
        })
        @swaps = list_swaps unless @swaps
        reg = />([A-Z]+\/[A-Z]+)<\/a>[^\-\.\d]*?([\d]+\.[\d]+\-[\d]+)/
        return  result.body.toutf8.scan( reg ).inject({}) {|r,l|
             pair = l[0].gsub( /\//, "" ).to_sym
             swap = @swaps[pair]
             rate = FxSession.convert_rate l[1]
             if ( rate && swap )
               r[pair]  = Rate.new( pair, rate[0], rate[1], swap.sell_swap, swap.buy_swap ) 
             end
             r
        }
      end
      #12.34-35 形式の文字列をbidレート、askレートに変換する。
      def self.convert_rate( str ) #:nodoc:
        if str =~ /([\d]+)\.([\d]+)\-([\d]+)/
             high = $1
             low = $2
             low2 = $3
             bid = high.to_f+(low.to_f/(10**low.length))
             ask_low = (low[0...low.length-low2.length] + low2).to_f
             if low.to_f > ask_low
               ask_low += 10**low2.length
             end
             ask = high.to_f+(ask_low/10**low.length)
             return [bid,ask]
        end
      end
    
      #スワップの一覧を取得します。
      #
      #戻り値:: 通貨ペアをキーとするClickClient::FX::Swapのハッシュ。
      def list_swaps
        result =  @client.click( @links.find {|i|
            i.attributes["accesskey"] == "8"
        })
        reg = /<dd>([A-Z]+\/[A-Z]+) <font[^>]*>売<\/font>[^\-\d]*?([\-\d]+)[^\-\d]*<font[^>]*>買<\/font>[^\-\d]*([\-\d]+)[^\-\d]*<\/dd>/
        return  result.body.toutf8.scan( reg ).inject({}) {|r,l|
             pair = l[0].gsub( /\//, "" ).to_sym
             r[pair]  = Swap.new( pair, l[1].to_i, l[2].to_i ); r
        }
      end
      
      # ログアウトします。
      def logout
        @client.click( @links.find {|i|
            i.text == "\303\233\302\270\303\236\302\261\302\263\303\204"
        })
      end
    end
    
    #=== スワップ
    Swap = Struct.new(:pair, :sell_swap, :buy_swap)
    #=== レート
    Rate = Struct.new(:pair, :bid_rate, :ask_rate, :sell_swap, :buy_swap )
  end
end



