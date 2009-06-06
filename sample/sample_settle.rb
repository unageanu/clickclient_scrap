
$: << "../lib"

require 'clickclient_scrap'
require 'constants'

# ログイン
c = ClickClientScrap::Client.new
c.fx_session( USER, PASS ) {|session|
  
  # 建玉一覧を取得
  list = session.list_open_interests
  list.each_pair {|k,v|
    # すべて決済
    session.settle( v.open_interest_id, v.count )
  }
  
}