# -*- coding: utf-8 -*- 

$: << "../lib"

require 'clickclient_scrap'
require 'common'

# 成り行きで発注および決済を行うテスト。
# <b>注意:</b> 決済まで行う為、実行すると資金が減少します。
describe "market order" do
  include TestBase
  
  it "成り行きで発注し決済するテスト" do
    do_test {|s|
      prev = @s.list_open_interests
      
      # 成り行きで注文
      @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::BUY, 1, {
        :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
      })
      @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
        :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_WEEK_END
      })
      sleep 1
      
      #建玉一覧取得
      after = @s.list_open_interests
      positions = after.find_all {|i| !prev.include?(i[0]) }.map{|i| i[1] }
      expect(positions.length).to eq 2 # 新規の建玉が2つ存在することを確認
      positions.each {|p|
        expect(p.open_interest_id).not_to be_nil
        expect(p.pair).not_to be_nil
        expect(p.sell_or_buy).not_to be_nil
        expect(p.count).to eq 1
        expect(p.rate).not_to be_nil
        expect(p.profit_or_loss).not_to be_nil
      }
      
      # 決済注文
      @s.settle( positions[0].open_interest_id, 1 )
      @s.settle( positions[1].open_interest_id, 1 )
      sleep 1
      
      after_settle =  @s.list_open_interests
      expect( after_settle.key?( positions[0].open_interest_id )).to eq false
      expect( after_settle.key?( positions[1].open_interest_id )).to eq false
    }
  end
  
  it "部分決済のテスト" do
    do_test {|s|
      prev = @s.list_open_interests
      
      # 成り行きで注文
      @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::BUY, 2, {
        :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
      })
      @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 2, {
        :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_WEEK_END
      })
      sleep 1
      
      #建玉一覧取得
      after = @s.list_open_interests
      positions = after.find_all {|i| !prev.include?(i[0]) }.map{|i| i[1] }
      expect(positions.length).to eq 2 # 新規の建玉が2つ存在することを確認
      positions.each {|p|
        expect(p.open_interest_id).not_to be_nil
        expect(p.pair).not_to be_nil
        expect(p.sell_or_buy).not_to be_nil
        expect(p.count).to eq 2
        expect(p.rate).not_to be_nil
        expect(p.profit_or_loss).not_to be_nil
      }
      
      # 決済注文
      @s.settle( positions[0].open_interest_id, 1 ) # 1つだけ決済
      @s.settle( positions[1].open_interest_id, 1 )
      sleep 1
      
      after_settle =  @s.list_open_interests
      expect( after_settle.key?( positions[0].open_interest_id ) ).to eq true
      expect( after_settle.key?( positions[1].open_interest_id ) ).to eq true
      
      @s.settle( positions[0].open_interest_id, 1 )
      @s.settle( positions[1].open_interest_id, 1 )
      after_settle =  @s.list_open_interests
      expect( after_settle.key?( positions[0].open_interest_id ) ).to eq false
      expect( after_settle.key?( positions[1].open_interest_id ) ).to eq false
    }
  end
  
  it "建玉が多数ある場合のテスト" do
    do_test {|s|
      prev = @s.list_open_interests
      
      # 成り行きで注文
      4.times {
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::BUY, 1, {
          :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_TODAY
        })
        @s.order( ClickClientScrap::FX::EURJPY, ClickClientScrap::FX::SELL, 1, {
          :expiration_type=>ClickClientScrap::FX::EXPIRATION_TYPE_WEEK_END
        })
      }
      sleep 1
      
      #建玉一覧取得
      after = @s.list_open_interests
      positions = after.find_all {|i| !prev.include?(i[0]) }.map{|i| i[1] }
      expect(positions.length).to eq 8 # 新規の建玉が2つ存在することを確認
      positions.each {|p|
        expect(p.open_interest_id).not_to be_nil
        expect(p.pair).not_to be_nil
        expect(p.sell_or_buy).not_to be_nil
        expect(p.count).to eq 1
        expect(p.rate).not_to be_nil
        expect(p.profit_or_loss).not_to be_nil
      }
      
      # 決済注文
      positions.each {|p|
        @s.settle( p.open_interest_id, 1 )
      }
      sleep 1
      
      after_settle =  @s.list_open_interests
      positions.each {|p|
        expect( after_settle.key?( p.open_interest_id ) ).to eq false
      }
    }
  end
end
