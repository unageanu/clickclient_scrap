
$: << "../lib"

require 'clickclient_scrap'

USER=IO.read("./user")
PASS=IO.read("./pass")

c = ClickClient::Client.new
c.fx_session( USER, PASS ) {|session|
  puts "You are logged in."
}
