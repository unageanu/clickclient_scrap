
$: << "../lib"

require 'clickclient_scrap'
require 'constants'

# ログイン
c = ClickClient::Client.new
c.fx_session( USER, PASS ) {|session|

  #成り行き注文
  session.order( ClickClient::FX::EURJPY, ClickClient::FX::BUY, 1)
}
