begin
  require 'rubygems'
rescue LoadError
end
require 'httpclient'
require 'rexml/document'
require 'date'
require 'kconv'

module ClickClient
  class Client
    # ホスト名
    DEFAULT_HOST_NAME = "https://sec-sso.click-sec.com/mf"

    #
    #===コンストラクタ
    #
    #*proxy*:: プロキシホストを利用する場合、そのホスト名とパスを指定します。
    # 例) https://proxyhost.com:80
    #
    def initialize( proxy=nil  )
      @client = HTTPClient.new( proxy, "Mozilla/5.0")
      #@client.debug_dev=STDOUT
      @client.set_cookie_store("cookie.dat")
      @host_name = DEFAULT_HOST_NAME
    end

    # ログインします。
    def fx_session( userid, password, &block )
      @client.get("#{@host_name}/" )
      result = @client.post_content("#{@host_name}/sso-redirect", {
        "j_username"=>userid, 
        "j_password"=>password,
        "LoginForm"=>"ログイン".tosjis,
        "s"=>"02",
        "p"=>"80"
      })
      if result.toutf8 =~ /<META HTTP-EQUIV="REFRESH" CONTENT="0;URL=([^"]*)">/
         uri = URI.parse( $1 )
         base = "#{uri.scheme}://#{uri.host}:#{uri.port}"
         result = @client.get_content($1)
         commands = result.toutf8.scan( /<a href="([^"]*)">([^<]*)<\/a>/).inject({}) {|r,l|
           r[l[1]] = "#{base}#{l[0]}"; r
         }
         session = FxSession.new( @client, commands )
         if block_given?
           begin
             yield session
           ensure
             session.logout
           end
         else
           return session
         end
      else
        error = result.toutf8 =~ /<font color="red">([^<]*)</ ? $1.strip : result
        raise "login failed.detail=#{error}".toutf8 
      end
    end
    
    #ホスト名
    attr :host_name, true  
  end
  
  class FxSession
    def initialize( client, commands )
      @client = client
      @commands = commands
    end
    
    # ログアウトする。
    def logout
      @client.get_content( @commands["ログアウト"] ) 
    end
  end
end



