# -*- coding: utf-8 -*- 

$: << "."
$: << "../lib"

require 'clickclient_scrap'
require 'constants'

# ログイン
c = ClickClientScrap::Client.new
c.fx_session( USER, PASS ) {|session|
  
  # 建玉一覧を取得
  list = session.list_open_interests
  list.each_pair {|k,v|
   puts <<-STR
---
open_interest_id : #{v.open_interest_id} 
sell_or_buy : #{v.sell_or_buy} 
pair : #{v.pair}
count : #{v.count} 
rate : #{v.rate} 
profit or loss : #{v.profit_or_loss}

STR
  }
}
