
$: << "../lib"

require 'clickclient_scrap'
require 'constants'

# ログイン
c = ClickClientScrap::Client.new
c.fx_session( USER, PASS ) {|session|

  #成り行き注文
  session.order( ClickClientScrap::FX::USDJPY, ClickClientScrap::FX::BUY, 1)
  session.order( ClickClientScrap::FX::USDJPY, ClickClientScrap::FX::SELL, 1)
}
