
$: << "../lib"

require 'clickclient_scrap'

# ※sample.rbと同じディレクトリにuser,passファイルを作成し、
#    ユーザー名,パスワードを設定しておくこと。
USER=IO.read("./user")
PASS=IO.read("./pass")

# ログイン
c = ClickClient::Client.new
c.fx_session( USER, PASS ) {|session|

  #成り行き注文
  session.order( ClickClient::FX::EURJPY, ClickClient::FX::BUY, 1)
}
