require 'evil-proxy'
require 'zlib'
require 'webrick'

WEBrick::HTTPRequest.class_eval do
  def redefine_uri new_unparsed_uri, change_host: false
    @unparsed_uri = new_unparsed_uri
    #begin
      setup_forwarded_info
      @request_uri = parse_uri(@unparsed_uri)
      @path = WEBrick::HTTPUtils::unescape(@request_uri.path)
      @path = WEBrick::HTTPUtils::normalize_path(@path)
      @host = @request_uri.host
      @port = @request_uri.port
      @query_string = @request_uri.query
      @script_name = ""
      @path_info = @path.dup
    #rescue
    #  raise WEBrick::HTTPStatus::BadRequest, "bad URI `#{@unparsed_uri}'."
    #end
    if change_host
      puts "Request URI: changing host from #{@header['host']} to #{@host}"
      @header['host'] = [@request_uri.host]
    end
  end
end

proxy = EvilProxy::MITMProxyServer.new Port: (ENV["PORT"] || 3128)
line = "\n" + '-' * 20 + "\n"
count = 0

proxy.start
