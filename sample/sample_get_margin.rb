
$: << "../lib"

require 'clickclient_scrap'
require 'constants'

# ログイン
c = ClickClientScrap::Client.new
c.fx_session( USER, PASS ) {|session|
  
  # 与力を取得
  margin = session.get_margin
  puts <<-STR
時価評価の総額 : #{margin.market_value}
建玉の評価損益 : #{margin.appraisal_profit_or_loss_of_open_interest}
口座残高 : #{margin.balance_in_account}
証拠金の維持率 : #{margin.guarantee_money_maintenance_ratio}
余力 : #{margin.margin}
拘束されている証拠金 : #{margin.freezed_guarantee_money}
必要な証拠金 : #{margin.required_guarantee_money}
注文中の証拠金 : #{margin.ordered_guarantee_money}
振替可能額  : #{margin.transferable_money_amount}
STR
}
