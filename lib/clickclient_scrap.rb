begin
  require 'rubygems'
rescue LoadError
end
require 'mechanize'
require 'date'
require 'kconv'
require 'set'

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
# require 'clickclient_scrap'
# 
# c = ClickClient::Client.new 
# # c = ClickClientScrap::Client.new https://<プロキシホスト>:<プロキシポート> # プロキシを利用する場合
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
module ClickClientScrap

  # クライアント
  class Client
    # ホスト名
    DEFAULT_HOST_NAME = "https://sec-sso.click-sec.com/mf/"
    DEFAULT_DEMO_HOST_NAME = "https://www.click-sec.com/m/demo/"
    
    #
    #===コンストラクタ
    #
    #*proxy*:: プロキシホストを利用する場合、そのホスト名とパスを指定します。
    # 例) https://proxyhost.com:80
    #
    def initialize( proxy=ENV["http_proxy"], demo=false )
      @client = WWW::Mechanize.new {|c|
        # プロキシ
        if proxy 
          uri = URI.parse( proxy )
          c.set_proxy( uri.host, uri.port )
        end
      }
      @client.keep_alive = false
      @client.max_history=0
      @client.user_agent_alias = 'Windows IE 7'
      @demo = demo
      @host_name = @demo ?  DEFAULT_DEMO_HOST_NAME : DEFAULT_HOST_NAME
    end

    #ログインし、セッションを開始します。
    #-ブロックを指定した場合、引数としてセッションを指定してブロックを実行します。ブロック実行後、ログアウトします。
    #-そうでない場合、セッションを返却します。この場合、ClickClientScrap::FX::FxSession#logoutを実行しログアウトしてください。
    #
    #userid:: ユーザーID
    #password:: パスワード
    #options:: オプション 
    #戻り値:: ClickClientScrap::FX::FxSession
    def fx_session( userid, password, options={}, &block )
      page = @client.get(@host_name)
      ClickClientScrap::Client.error(page)  if page.forms.length <= 0
      form = page.forms.first
      form.j_username = userid
      form.j_password = password
      result = @client.submit(form, form.buttons.first) 
      # デモサイトではjsによるリダイレクトは不要。
      if !@demo
        if result.body.toutf8 =~ /<META HTTP-EQUIV="REFRESH" CONTENT="0;URL=([^"]*)">/
           result = @client.get($1)
           ClickClientScrap::Client.error( result ) if result.links.size <= 0
        else
           ClickClientScrap::Client.error( result )
        end
      end
      session = FX::FxSession.new( @client, result.links, options )
      if block_given?
        begin
          yield session
        ensure
          session.logout
        end
      else
        return session
      end
    end
    def self.error( page )
        msgs = page.body.scan( /<font color="red">([^<]*)</ ).flatten
        error = !msgs.empty? ? msgs.map{|m| m.strip}.join(",") : page.body
        raise "operation failed.detail=#{error}".toutf8 
    end
    
    #ホスト名
    attr :host_name, true  
  end
  
  module FX
    
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
    ORDER_TYPE_MARKET_ORDER = "00"
    # 注文タイプ: 通常
    ORDER_TYPE_NORMAL = "01"
    # 注文タイプ: IFD
    ORDER_TYPE_IFD = "11"
    # 注文タイプ: OCO
    ORDER_TYPE_OCO = "21"
    # 注文タイプ: IFD-OCO
    ORDER_TYPE_IFD_OCO = "31"

    # 有効期限: 当日限り
    EXPIRATION_TYPE_TODAY = 0
    # 有効期限: 週末まで
    EXPIRATION_TYPE_WEEK_END = 1
    # 有効期限: 無期限
    EXPIRATION_TYPE_INFINITY = 2
    # 有効期限: 日付指定
    EXPIRATION_TYPE_SPECIFIED = 3
    
    # 注文状況: すべて
    ORDER_CONDITION_ALL = ""
    # 注文状況: 注文中
    ORDER_CONDITION_ON_ORDER = "0"
    # 注文状況: 取消済
    ORDER_CONDITION_CANCELED = "1"
    # 注文状況: 約定
    ORDER_CONDITION_EXECUTION = "2"
    # 注文状況: 不成立
    ORDER_CONDITION_FAILED = "3"
    
    # トレード種別: 新規
    TRADE_TYPE_NEW = "新規"
    # トレード種別: 決済
    TRADE_TYPE_SETTLEMENT = "決済"
    
    # 執行条件: 成行
    EXECUTION_EXPRESSION_MARKET_ORDER = "成行"
    # 執行条件: 指値
    EXECUTION_EXPRESSION_LIMIT_ORDER = "指値"
    # 執行条件: 逆指値
    EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER = "逆指値"
    
    #=== FX取引のためのセッションクラス
    #Client#fx_sessionのブロックの引数として渡されます。詳細はClient#fx_sessionを参照ください。
    class FxSession
      
      def initialize( client, links, options={} )
        @client = client
        @links = links
        @options = options
      end
      
      #レート一覧を取得します。
      #
      #戻り値:: 通貨ペアをキーとするClickClientScrap::FX::Rateのハッシュ。
      def list_rates
        result =  link_click( "1" )
         if !@last_update_time_of_swaps \
           || Time.now.to_i - @last_update_time_of_swaps  > (@options[:swap_update_interval] || 60*60)
          @swaps  = list_swaps
          @last_update_time_of_swaps = Time.now.to_i
        end
        reg = />([A-Z]+\/[A-Z]+)<\/a>[^\-\.\d]*?([\d]+\.[\d]+)\-[^\-\.\d]*([\d\.]+)/
        tokens = result.body.toutf8.scan( reg )
        ClickClientScrap::Client.error( result ) if !tokens || tokens.empty?
        return  tokens.inject({}) {|r,l|
             pair = to_pair( l[0] )
             swap = @swaps[pair]
             rate = FxSession.convert_rate "#{l[1]}-#{l[2]}"
             if ( rate && swap )
               r[pair]  = Rate.new( pair, rate[0], rate[1], swap.sell_swap, swap.buy_swap ) 
             end
             r
        }
      end
      #12.34-35 形式の文字列をbidレート、askレートに変換する。
      def self.convert_rate( str ) #:nodoc:
        if str =~ /^([\d]+)\.([\d]+)\-([\d]+)$/
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
        elsif str =~ /^([\d]+\.[\d]+)\-([\d]+\.[\d]+)$/
             return [$1.to_f,$2.to_f]
        end
      end
    
      #スワップの一覧を取得します。
      #
      #戻り値:: 通貨ペアをキーとするClickClientScrap::FX::Swapのハッシュ。
      def list_swaps
        result =  link_click( "8" )
        reg = /<dd>([A-Z]+\/[A-Z]+) <font[^>]*>売<\/font>[^\-\d]*?([\-\d,]+)[^\-\d]*<font[^>]*>買<\/font>[^\-\d]*([\-\d,]+)[^\-\d]*<\/dd>/
        return  result.body.toutf8.scan( reg ).inject({}) {|r,l|
             pair = to_pair( l[0] )
             r[pair]  = Swap.new( pair, l[1].sub(/,/,"").to_i, l[2].sub(/,/,"").to_i ); r
        }
      end
      
      #
      #注文を行います。
      #
      #currency_pair_code:: 通貨ペアコード(必須)
      #sell_or_buy:: 売買区分。ClickClientScrap::FX::BUY,ClickClientScrap::FX::SELLのいずれかを指定します。(必須)
      #unit:: 取引数量(必須)
      #options:: 注文のオプション。注文方法に応じて以下の情報を設定できます。
      #            - <b>成り行き注文</b>
      #              - <tt>:slippage</tt> .. スリッページ (オプション)。何pips以内かを整数で指定します。
      #            - <b>通常注文</b> ※注文レートが設定されていれば通常取引となります。
      #              - <tt>:rate</tt> .. 注文レート(必須)
      #              - <tt>:execution_expression</tt> .. 執行条件。ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER等を指定します(必須)
      #              - <tt>:expiration_type</tt> .. 有効期限。ClickClientScrap::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #              - <tt>:expiration_date</tt> .. 有効期限が「日付指定(ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #            - <b>OCO注文</b> ※逆指値レートが設定されていればOCO取引となります。
      #              - <tt>:rate</tt> .. 注文レート(必須)
      #              - <tt>:stop_order_rate</tt> .. 逆指値レート(必須)
      #              - <tt>:expiration_type</tt> .. 有効期限。ClickClientScrap::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #              - <tt>:expiration_date</tt> .. 有効期限が「日付指定(ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #            - <b>IFD注文</b> ※決済取引の指定があればIFD取引となります。
      #              - <tt>:rate</tt> .. 注文レート(必須)
      #              - <tt>:execution_expression</tt> .. 執行条件。ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER等を指定します(必須)
      #              - <tt>:expiration_type</tt> .. 有効期限。ClickClientScrap::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #              - <tt>:expiration_date</tt> .. 有効期限が「日付指定(ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #              - <tt>:settle</tt> .. 決済取引の指定。マップで指定します。
      #                - <tt>:unit</tt> .. 決済取引の取引数量(必須)
      #                - <tt>:sell_or_buy</tt> .. 決済取引の売買区分。ClickClientScrap::FX::BUY,ClickClientScrap::FX::SELLのいずれかを指定します。(必須)
      #                - <tt>:rate</tt> .. 決済取引の注文レート(必須)
      #                - <tt>:execution_expression</tt> .. 決済取引の執行条件。ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER等を指定します(必須)
      #                - <tt>:expiration_type</tt> .. 決済取引の有効期限。ClickClientScrap::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #                - <tt>:expiration_date</tt> .. 決済取引の有効期限が「日付指定(ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #            - <b>IFD-OCO注文</b> ※決済取引の指定と逆指値レートの指定があればIFD-OCO取引となります。
      #              - <tt>:rate</tt> .. 注文レート(必須)
      #              - <tt>:execution_expression</tt> .. 執行条件。ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER等を指定します(必須)
      #              - <tt>:expiration_type</tt> .. 有効期限。ClickClientScrap::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #              - <tt>:expiration_date</tt> .. 有効期限が「日付指定(ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #              - <tt>:settle</tt> .. 決済取引の指定。マップで指定します。
      #                - <tt>:unit</tt> .. 決済取引の取引数量(必須)
      #                - <tt>:sell_or_buy</tt> .. 決済取引の売買区分。ClickClientScrap::FX::BUY,ClickClientScrap::FX::SELLのいずれかを指定します。(必須)
      #                - <tt>:rate</tt> .. 決済取引の注文レート(必須)
      #                - <tt>:stop_order_rate</tt> .. 決済取引の逆指値レート(必須)
      #                - <tt>:expiration_type</tt> .. 決済取引の有効期限。ClickClientScrap::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #                - <tt>:expiration_date</tt> .. 決済取引の有効期限が「日付指定(ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #戻り値:: ClickClientScrap::FX::OrderResult
      #
      def order ( currency_pair_code, sell_or_buy, unit, options={} )
        
        # 取り引き種別の判別とパラメータチェック
        type = ORDER_TYPE_MARKET_ORDER
        if ( options && options[:settle] != nil  )
          if ( options[:settle][:stop_order_rate] != nil)
             # 逆指値レートと決済取引の指定があればIFD-OCO取引
             raise "options[:settle][:rate] is required." if options[:settle][:rate] == nil
             type = ORDER_TYPE_IFD_OCO
          else
             # 決済取引の指定のみがあればIFD取引
             raise "options[:settle][:rate] is required." if options[:settle][:rate] == nil
             raise "options[:settle][:execution_expression] is required." if options[:settle][:execution_expression] == nil
             type = ORDER_TYPE_IFD
          end
          raise "options[:rate] is required." if options[:rate] == nil
          raise "options[:execution_expression] is required." if options[:execution_expression] == nil
          raise "options[:expiration_type] is required." if options[:expiration_type] == nil
          raise "options[:settle][:rate] is required." if options[:settle][:rate] == nil
          raise "options[:settle][:sell_or_buy] is required." if options[:settle][:sell_or_buy] == nil
          raise "options[:settle][:unit] is required." if options[:settle][:unit] == nil
          raise "options[:settle][:expiration_type] is required." if options[:expiration_type] == nil
        elsif ( options && options[:rate] != nil )
          if ( options[:stop_order_rate] != nil )
            # 逆指値レートが指定されていればOCO取引
            type = ORDER_TYPE_OCO
          else
            # そうでなければ通常取引
            raise "options[:execution_expression] is required." if options[:execution_expression] == nil
            type = ORDER_TYPE_NORMAL
          end
          raise "options[:expiration_type] is required." if options[:expiration_type] == nil
        else
          # 成り行き
          type = ORDER_TYPE_MARKET_ORDER
        end
        
        #注文前の注文一覧
        before = list_orders( ORDER_CONDITION_ON_ORDER ).inject(Set.new) {|s,o| s << o[0]; s }
        
        # レート一覧
        result =  link_click( "1" )

        ClickClientScrap::Client.error( result ) if result.forms.empty?
        form = result.forms.first
        
        # 通貨ペア
        option = form.fields.find{|f| f.name == "P001" }.options.find {|o|
           to_pair( o.text.strip ) == currency_pair_code
        }
        raise "illegal currency_pair_code. currency_pair_code=#{currency_pair_code.to_s}" unless option
        option.select
        
        #注文方式
        form["P100"] = type
        
        # 詳細設定画面へ
        result = @client.submit(form) 
        ClickClientScrap::Client.error( result ) if result.forms.empty?
        form = result.forms.first
        case type
          when ORDER_TYPE_MARKET_ORDER
            # 成り行き
            form["P003"] = unit.to_s # 取り引き数量
            form["P002.0"] = sell_or_buy == ClickClientScrap::FX::SELL ? "1" : "0" #売り/買い  
            form["P005"] = options[:slippage].to_s if ( options && options[:slippage] != nil ) # スリッページ
          when ORDER_TYPE_NORMAL
            # 指値
            form["P003"] = options[:rate].to_s # レート
            form["P005"] = unit.to_s # 取り引き数量
            form["P002.0"] = sell_or_buy == ClickClientScrap::FX::SELL ? "1" : "0" #売り/買い
            exp =  options[:execution_expression]
            form["P004.0"] = exp  == ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER ? "2" : "1" #指値/逆指値
            set_expiration( form,  options, "P008", "P009" ) # 有効期限
          when ORDER_TYPE_OCO
            # OCO
            form["P003"] = options[:rate].to_s # レート
            form["P005"] = options[:stop_order_rate].to_s # 逆指値レート
            form["P007"] = unit.to_s # 取り引き数量
            form["P002.0"] = sell_or_buy == ClickClientScrap::FX::SELL ? "1" : "0" #売り/買い
            set_expiration( form,  options, "P010", "P011" ) # 有効期限
          else
            raise "not supported yet."
        end
        
        # 確認画面へ
        result = @client.submit(form) 
        ClickClientScrap::Client.error( result ) if result.forms.empty?
        result = @client.submit(result.forms.first)
        ClickClientScrap::Client.error( result ) unless result.body.toutf8 =~ /注文受付完了/
        
        #注文前の一覧と注文後の一覧を比較して注文を割り出す。
        #成り行き注文の場合、即座に約定するのでnilになる(タイミングによっては取得できるかも)
        tmp = list_orders( ORDER_CONDITION_ON_ORDER ).find {|o| !before.include?(o[0]) }
        return OrderResult.new( tmp ? tmp[1].order_no : nil )
      end
      
      # 有効期限を設定する
      #form:: フォーム
      #options:: パラメータ
      #input_type:: 有効期限の種別を入力するinput要素名
      #input_date:: 有効期限が日付指定の場合に、日付を入力するinput要素名
      def set_expiration( form,  options, input_type, input_date )
        case options[:expiration_type]
          when ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
              form[input_type] = "0"
          when ClickClientScrap::FX::EXPIRATION_TYPE_WEEK_END
              form[input_type] = "1"
          when ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED
              form[input_type] = "3"
              raise "options[:expiration_date] is required." unless options[:expiration_date]
              form["#{input_date}.Y"] = options[:expiration_date].year
              form["#{input_date}.M"] = options[:expiration_date].month
              form["#{input_date}.D"] = options[:expiration_date].day
              form["#{input_date}.h"] = options[:expiration_date].respond_to?(:hour) ? options[:expiration_date].hour : "0"
          else
              form[input_type] = "2"
        end
      end
      
      #
      #=== 注文をキャンセルします。
      #
      #order_no:: 注文番号
      #戻り値:: なし
      #
      def cancel_order( order_no ) 
        
        raise "order_no is nil." unless order_no
        
        # 注文一覧
        result =  link_click( "2" )
        ClickClientScrap::Client.error( result ) if result.forms.empty?
        form = result.forms.first
        form["P002"] = ORDER_CONDITION_ON_ORDER
        result = @client.submit(form)
        
        # 対象となる注文をクリック 
        link =  result.links.find {|l|
            l.href =~ /[^"]*GKEY=([a-zA-Z0-9]*)[^"]*/ && $1 == order_no
        }
        raise "illegal order_no. order_no=#{order_no}" unless link
        result =  @client.click(link)
        ClickClientScrap::Client.error( result ) if result.forms.empty?
        
        # キャンセル
        form = result.forms[1]
        result = @client.submit(form)
        ClickClientScrap::Client.error( result ) if result.forms.empty?
        form = result.forms.first
        result = @client.submit(form)
        ClickClientScrap::Client.error( result ) unless result.body.toutf8 =~ /注文取消受付完了/
      end
      
      
      #
      #=== 決済注文を行います。
      #
      #*open_interest_id*:: 決済する建玉番号
      #*unit*:: 取引数量
      #*options*:: 決済注文のオプション。注文方法に応じて以下の情報を設定できます。
      #            - <b>成り行き注文</b>
      #              - <tt>:slippage</tt> .. スリッページ (オプション)
      #              - <tt>:slippage_base_rate</tt> .. スリッページの基準となる取引レート(スリッページが指定された場合、必須。)
      #            - <b>通常注文</b>  <b>※未実装</b> ※注文レートが設定されていれば通常取引となります。
      #              - <tt>:rate</tt> .. 注文レート(必須)
      #              - <tt>:execution_expression</tt> .. 執行条件。ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER等を指定します(必須)
      #              - <tt>:expiration_type</tt> .. 有効期限。ClickClientScrap::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #              - <tt>:expiration_date</tt> .. 有効期限が「日付指定(ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #            - <b>OCO注文</b>  <b>※未実装</b> ※注文レートと逆指値レートが設定されていればOCO取引となります。
      #              - <tt>:rate</tt> .. 注文レート(必須)
      #              - <tt>:stop_order_rate</tt> .. 逆指値レート(必須)
      #              - <tt>:expiration_type</tt> .. 有効期限。ClickClientScrap::FX::EXPIRATION_TYPE_TODAY等を指定します(必須)
      #              - <tt>:expiration_date</tt> .. 有効期限が「日付指定(ClickClientScrap::FX::EXPIRATION_TYPE_SPECIFIED)」の場合の有効期限をDateで指定します。(有効期限が「日付指定」の場合、必須)
      #<b>戻り値</b>:: なし
      #
      def settle ( open_interest_id, unit, options={} )
        if ( options[:rate] != nil && options[:stop_order_rate] != nil )
          # レートと逆指値レートが指定されていればOCO取引
          raise "options[:expiration_type] is required." if options[:expiration_type] == nil
        elsif ( options[:rate] != nil )
          # レートが指定されていれば通常取引
          raise "options[:execution_expression] is required." if options[:execution_expression] == nil
          raise "options[:expiration_type] is required." if options[:expiration_type] == nil
        else
          # 成り行き
          if ( options[:slippage] != nil )
            raise "if you use a slippage,  options[:slippage_base_rate] is required." if options[:slippage_base_rate] == nil
          end
        end
        
        # 建玉一覧
        result =  link_click( "3" )
        
        # 対象となる建玉をクリック 
        link =  result.links.find {|l|
            l.href =~ /[^"]*ORDERNO=([a-zA-Z0-9]*)[^"]*/ && $1 == open_interest_id
        }
        raise "illegal open_interest_id. open_interest_id=#{open_interest_id}" unless link
        result =  @client.click(link)
        
        # 決済
        form = result.forms.first
        form["P100"] = "00" # 成り行き TODO 通常(01),OCO取引(21)対応
        result = @client.submit(form)
        ClickClientScrap::Client.error( result ) if result.forms.empty?
        
        # 設定
        form = result.forms.first
        form["L111"] = unit.to_s
        form["P005"] = options[:slippage].to_s if options[:slippage]
        result = @client.submit(form)
        ClickClientScrap::Client.error( result ) if result.forms.empty?
        
        # 確認
        form = result.forms.first
        result = @client.submit(form)
        ClickClientScrap::Client.error( result ) unless result.body.toutf8 =~ /完了/
      end

      
      #
      #=== 注文一覧を取得します。
      #
      #order_condition_code:: 注文状況コード(必須)
      #currency_pair_code:: 通貨ペアコード <b>※未実装</b>
      #戻り値:: 注文番号をキーとするClickClientScrap::FX::Orderのハッシュ。
      #
      def list_orders(  order_condition_code=ClickClientScrap::FX::ORDER_CONDITION_ALL, currency_pair_code=nil )
        result =  link_click( "2" )
        ClickClientScrap::Client.error( result ) if result.forms.empty?
        form = result.forms.first
        form["P001"] = "" # TODO currency_pair_codeでの絞り込み
        form["P002"] = order_condition_code
        result = @client.submit(form) 
        
        list = result.body.toutf8.scan( /<a href="[^"]*GKEY=([a-zA-Z0-9]*)">([A-Z]{3}\/[A-Z]{3}) ([^<]*)<\/a><br>[^;]*;([^<]*)<font[^>]*>([^<]*)<\/font>([^@]*)@([\d\.]*)([^\s]*) ([^<]*)<br>/m )
        tmp = {}
        list.each {|i|
          order_no = i[0] 
          order_type = to_order_type_code(i[2])
          trade_type = i[3] == "新" ? ClickClientScrap::FX::TRADE_TYPE_NEW : ClickClientScrap::FX::TRADE_TYPE_SETTLEMENT
          pair = to_pair( i[1] )
          sell_or_buy = i[4] == "売" ?  ClickClientScrap::FX::SELL : ClickClientScrap::FX::BUY
          count =  pair == :ZARJPY ?  i[5].to_i/10 : i[5].to_i
          rate =  i[6].to_f
          execution_expression = if i[7] == "指"
            ClickClientScrap::FX::EXECUTION_EXPRESSION_LIMIT_ORDER
          elsif i[7] == "逆"
            ClickClientScrap::FX::EXECUTION_EXPRESSION_REVERSE_LIMIT_ORDER
          else
            ClickClientScrap::FX::EXECUTION_EXPRESSION_MARKET_ORDER
          end
          tmp[order_no] = Order.new( order_no, trade_type, order_type, execution_expression, sell_or_buy, pair, count, rate, i[8])
        }
        return tmp
      end
      
      #
      #=== 建玉一覧を取得します。
      #
      #currency_pair_code:: 通貨ペアコード。<b>※未実装</b>
      #戻り値:: 建玉IDをキーとするClickClientScrap::FX::OpenInterestのハッシュ。
      #
      def  list_open_interests( currency_pair_code=nil ) 
        result =  link_click( "3" )
        ClickClientScrap::Client.error( result ) if result.forms.empty?
        form = result.forms.first
        form["P001"] = "" # TODO currency_pair_codeでの絞り込み
        result = @client.submit(form) 
        
        list = result.body.toutf8.scan( /<a href="[^"]*">([A-Z]{3}\/[A-Z]{3}):([^<]*)<\/a><br>[^;]*;<font[^>]*>([^<]*)<\/font>([\d\.]*)[^\s@]*@([\d\.]*).*?<font[^>]*>([^<]*)<\/font>/m )

        if /ページ選択/ =~ result.body.toutf8 # 複数ページに分割される場合
          current_page = 1
          link_to_next_arr = result.links.select{|i| i.text == (current_page + 1).to_s}
          while !link_to_next_arr.empty?
            result = @client.click( link_to_next_arr[0] )
            list = list + result.body.toutf8.scan( /<a href="[^"]*">([A-Z]{3}\/[A-Z]{3}):([^<]*)<\/a><br>[^;]*;<font[^>]*>([^<]*)<\/font>([\d\.]*)[^\s@]*@([\d\.]*).*?<font[^>]*>([^<]*)<\/font>/m )
            current_page = current_page + 1
            link_to_next_arr = result.links.select{|i| i.text == (current_page + 1).to_s}
          end
        end

        tmp = {}
        list.each {|i|
          open_interest_id = i[1] 
          pair = to_pair( i[0] )
          sell_or_buy = i[2] == "売" ?  ClickClientScrap::FX::SELL : ClickClientScrap::FX::BUY
          count =  i[3].to_i
          rate =  i[4].to_f
          profit_or_loss =  i[5].to_i
          tmp[open_interest_id] = OpenInterest.new(open_interest_id, pair, sell_or_buy, count, rate, profit_or_loss  )
        }
        return tmp
      end
      
      #
      #=== 余力情報を取得します。
      #
      #戻り値:: ClickClientScrap::FX::Marginのハッシュ。
      #
      def get_margin
        result =  link_click( "7" )
        list = result.body.toutf8.scan( /【([^<]*)[^>]*>[^>]*>([^<]*)</m )
        values = list.inject({}) {|r,i|
          if ( i[0] == "証拠金維持率】" )
            r[i[0]] = i[1]
          else
            r[i[0]] = i[1].gsub(/,/, "").to_i
          end
          r
        }
        return Margin.new(
          values["時価評価総額】"],
          values["建玉評価損益】"],
          values["口座残高】"],
          values["証拠金維持率】"],
          values["余力】"],
          values["拘束証拠金】"],
          values["必要証拠金】"],
          values["注文中必要証拠金】"],
          values["振替可能額】"]
        )
      end
      
      # ログアウトします。
      def logout
        @client.click( @links.find {|i|
            i.text == "\303\233\302\270\303\236\302\261\302\263\303\204" \
            || i.text == "ﾛｸﾞｱｳﾄ"
        })
      end
      
    private
      # "USD/JPY"を:USDJPYのようなシンボルに変換します。
      def to_pair( str )
        str.gsub( /\//, "" ).to_sym
      end
      
      # 注文種別を注文種別コードに変換します。
      def to_order_type_code( order_type )
        return  case order_type
          when "成行注文"
            ClickClientScrap::FX::ORDER_TYPE_MARKET_ORDER
          when "通常注文"
            ClickClientScrap::FX::ORDER_TYPE_NORMAL
          when "OCO注文"
            ClickClientScrap::FX::ORDER_TYPE_OCO
          when "IFD注文"
            ClickClientScrap::FX::ORDER_TYPE_IFD
          when "IFD-OCO注文"
            ClickClientScrap::FX::ORDER_TYPE_IFD_OCO
          else
            raise "illegal order_type. order_type=#{order_type}"
        end
      end
      
      def link_click( no )
        link = @links.find {|i|
            i.attributes["accesskey"] == no
        }
        raise "link isnot found. accesskey=#{no}"  unless link
        @client.click( link )
      end
    end
    
    # オプション
    attr :options, true
    
    #=== スワップ
    Swap = Struct.new(:pair, :sell_swap, :buy_swap)
    #=== レート
    Rate = Struct.new(:pair, :bid_rate, :ask_rate, :sell_swap, :buy_swap )
    #===注文
    Order = Struct.new(:order_no, :trade_type, :order_type, :execution_expression, :sell_or_buy, :pair,  :count, :rate, :order_state )
    #===注文結果
    OrderResult = Struct.new(:order_no )
    #===建玉
    OpenInterest = Struct.new(:open_interest_id, :pair, :sell_or_buy, :count, :rate, :profit_or_loss  )
    #===余力
    Margin = Struct.new( 
      :market_value, #時価評価の総額
      :appraisal_profit_or_loss_of_open_interest, #建玉の評価損益
      :balance_in_account, # 口座残高
      :guarantee_money_maintenance_ratio, #証拠金の維持率
      :margin, #余力
      :freezed_guarantee_money, #拘束されている証拠金
      :required_guarantee_money, #必要な証拠金
      :ordered_guarantee_money, #注文中の証拠金
      :transferable_money_amount #振替可能額 
    )
  end
end

class << WWW::Mechanize::Util
  def from_native_charset(s, code)
    if WWW::Mechanize.html_parser == Nokogiri::HTML
      return unless s
      Iconv.iconv(code, "UTF-8", s).join("") rescue s # エラーになった場合、変換前の文字列を返す
    else
      return s       
    end
  end
end


