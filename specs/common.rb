
# ※「../etc」ディレクトリにuser,passファイルを作成し、
#    ユーザー名,パスワードを設定しておくこと。
USER=IO.read("../etc/user")
PASS=IO.read("../etc/pass")
DEMO_USER=IO.read("../etc/demo_user")
DEMO_PASS=IO.read("../etc/demo_pass")


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
