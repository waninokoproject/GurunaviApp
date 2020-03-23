class RestaurantsController < ApplicationController

  #改善の余地あり。１ページで完結できない為。
  def top
  end

  #周辺のレストラン情報が表示される。
  def index
    @page = 1
    #ぐるなびapi呼び出し
    restaurants_api
  end

  #検索を絞り込むためのアクション。freewordとかetc..
  def search
    #puts "\n\n-------parmas--------\n\n"
    #puts params
    #puts "\n\n"

    #paramsで送られてきた情報をsessionに入れる。
    params.each_key{|key|
      session[key] = params[key]
      puts key
      puts session[key]
    }

    session[:offset_page] = 1
    puts "\n\n\n\n~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n\n"
    puts session[:offset_page]

    redirect_to restaurants_path
  end

  # ページの移動をsessionで管理
  def page
    if params[:page] == "1" then
      session[:offset_page] -= 1
    elsif params[:page] == "2" then
      session[:offset_page] += 1
    end

    redirect_to restaurants_path
  end

  #ajaxで送られてきたdataをsessionに格納
  def coordinate
    #位置情報をsessionで管理
    session[:latitude] = params[:latitude]
    session[:longitude] = params[:longitude]
    session[:offset_page] = 1
    puts "\n~~~~~~~~~this is update@longitude~~~~~~~~~~~\n"
    puts params
    redirect_to restaurants_path
    #redirect_to restaurants_path(latitude: params[:latitude], longitude: params[:longitude])
  end

  private

  #ぐるなびapiを使って周辺情報を検索
  def restaurants_api
    require 'json'
    require 'net/https'
    require "uri"

    data = {
      "keyid": "272a4e4561b20e404f0c4f59e7fd22a2",
      "freeword": session[:freeword],
      "input_coordinates_mode": 1,
      "latitude": session[:latitude],
      "longitude": session[:longitude],
      "range": session[:range],
      "lunch": session[:lunch],
      "no_smoking": session[:no_smoking],
      "bottomless_cup": session[:bottomless_cup],
      "buffet": session[:buffet],
      "private_room": session[:private_room],
      "e_money": session[:e_money],
      "web_reserve": session[:web_reserve],
      "parking": session[:parking],
      "birthday_privilege": session[:birthday_privilege],
      "offset_page": session[:offset_page]
    }

    puts "\n~~~~~~~~data~~~~~~~~\n"
    puts data

    query=data.to_query #ハッシュをURL文字列に変換
    uri = URI("https://api.gnavi.co.jp/RestSearchAPI/20150630/?"+query)
    #puts "\n~~~~~~~~uri~~~~~~~~\n"
    #puts uri

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
        @total = hash[:total_hit_count]
        @page = session[:offset_page]
        if @page.nil?
          @page = 1
          session[:offset_page] = 1
        end
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
