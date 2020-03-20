class RestaurantsController < ApplicationController

  def top
  end

  def index

    @hai = "itimotu"
    @hentai = params[:latitude]

    #lat = 43.770883
    #log = 142.365008
    if params
      @latitude = params[:latitude]
      @longitude = params[:longitude]
      puts "\n~~~~~~~~~index @longitude~~~~~~~~~~~\n"
      puts session[:latitude]
      restaurants_api(session[:latitude], session[:longitude])
      #restaurants_api(lat, log)
      #redirect_to root_path
      #render('restaurants/index')
    end
  end

  def update
    #restaurants_api(params[:latitude], params[:longitude])
    session[:latitude] = params[:latitude]
    session[:longitude] = params[:longitude]
    puts "\n~~~~~~~~~this is update@longitude~~~~~~~~~~~\n"
    puts @latitude
    redirect_to restaurants_path
    puts "jjjjjjjjjjjjjjj"
    #redirect_to restaurants_path(latitude: params[:latitude], longitude: params[:longitude])
  end

  private

  def restaurants_api(lat, log)
    require 'json'
    require 'net/https'
    require "uri"

    data = {
      "keyid": "272a4e4561b20e404f0c4f59e7fd22a2",
      #{}"freeword": word,
      "input_coordinates_mode": 1,
      "latitude": lat,
      "longitude": log,
      "hit_per_page": 10
    }

    #print("alalalalalalallalala")
    puts "\n~~~~~~~~data~~~~~~~~\n"
    puts data

    query=data.to_query #ハッシュをURL文字列に変換
    uri = URI("https://api.gnavi.co.jp/RestSearchAPI/20150630/?"+query)
    puts "\n~~~~~~~~uri~~~~~~~~\n"
    puts uri
    #http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #req = Net::HTTP::Get.new(uri)
    #res = http.request(req)

    begin
      response = Net::HTTP.new(uri.host, uri.port).yield_self do |http|
        http.use_ssl = true
        # 接続時に待つ最大秒数を設定
        http.open_timeout = 5
        # 読み込み一回でブロックして良い最大秒数を設定
        http.read_timeout = 30
        # Net::HTTPResponseのインスタンスが返ってくる
        http.get(uri.request_uri)
      end

      case response
      when Net::HTTPSuccess

        hash = JSON.parse(response.body, symbolize_names: true)

        @hash = hash[:rest]

        # puts @hash ["rest"][0]["name"]
        # puts @hash ["rest"][2]["name"]
      when Net::HTTPRedirection
        logger.warn("Redirection: code=#{response.code} message=#{response.message}")
        @message = "Redirection: code=#{response.code} message=#{response.message}"
      else
        logger.error("HTTP ERROR: code=#{response.code} message=#{response.message}")
        @message = "HTTP ERROR: code=#{response.code} message=#{response.message}"
      end
    rescue IOError => e
      logger.error(e.message)
    rescue TimeoutError => e
      logger.error(e.message)
    rescue JSON::ParserError => e
      logger.error(e.message)
    rescue StandardError => e
      logger.error(e.message)
    end
  end
end
