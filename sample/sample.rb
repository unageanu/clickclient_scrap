
$: << "../lib"

require 'clickclient_scrap'

USER=IO.read("./user")
PASS=IO.read("./pass")

# ログイン
c = ClickClient::Client.new
c.fx_session( USER, PASS ) {|session|

  # 通貨ペアの一覧を取得
  session.list_rates.each_pair {|k,v|
    puts "#{k} : #{v.bid_rate} : #{v.ask_rate} : #{v.sell_swap} : #{v.buy_swap}"
  }
}
