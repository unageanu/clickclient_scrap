
$: << "../lib"

require 'clickclient_scrap'
require 'constants'

# ログイン
c = ClickClientScrap::Client.new
c.fx_session( USER, PASS ) {|session|

  #成り行き注文
  session.order( ClickClient::FX::USDJPY, ClickClient::FX::BUY, 1)
  session.order( ClickClient::FX::USDJPY, ClickClient::FX::SELL, 1)
}
