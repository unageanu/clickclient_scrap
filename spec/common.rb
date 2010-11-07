# -*- coding: utf-8 -*- 

# ※「../etc/auth.yaml」を作成し、以下の内容を設定しておくこと。
# <pre>
# ---
# user: <クリック証券のアクセスユーザー名>
# pass: <クリック証券のアクセスユーザーパスワード>
# demo_user: <クリック証券デモ取引のアクセスユーザー名>
# demo_pass: <クリック証券デモ取引のアクセスユーザーパスワード>
# </pre>
require 'yaml'

auth = YAML.load_file "#{File.dirname(__FILE__)}/../etc/auth.yaml"
USER=auth["user"]
PASS=auth["pass"]
DEMO_USER=auth["demo_user"]
DEMO_PASS=auth["demo_pass"]

# ベース
module TestBase
  # 通常/デモのそれぞれのセッションでブロックを実行する。
  def do_test 
    [{:c=>ClickClientScrap::Client.new, :p=>PASS, :u=>USER },
     {:c=>ClickClientScrap::Client.new(nil, true), :p=>DEMO_PASS, :u=>DEMO_USER }].each {|i| 
      @s = i[:c].fx_session( i[:u], i[:p] )
      @rates = @s.list_rates
      @order_ids = []
      begin
        yield @s
      ensure
        begin 
          @order_ids.each {|order| @s.cancel_order(order.order_no) } if @s
        ensure
          @s.logout if @s 
        end
      end
    }
  end
end
