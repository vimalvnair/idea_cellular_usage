module IdeaCellular
  def get_with_cookie url, cookie
    uri = URI(url)
    req = Net::HTTP::Get.new(uri)
    req['Cookie'] = cookie
    req['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36"

    res = Net::HTTP.start(uri.hostname, uri.port,  :use_ssl => true) do |http|
      http.request(req)
    end
    puts "GET: #{res.code} #{url} #{res.body}"
    res
  end

  def post_with_cookie url, data, cookie
    uri = URI(url)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(data)
    req['Cookie'] = cookie
    req['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36"

    res = Net::HTTP.start(uri.hostname, uri.port,  :use_ssl => true) do |http|
      http.request(req)
    end
    puts "POST: #{res.code} #{url} data :#{data} resp: #{res.body}"
    res
  end

  def get_login_url
    host = "https://care.ideacellular.com"
    response = get_with_cookie "https://care.ideacellular.com/wps/portal/account/account-login", nil
    html = Nokogiri::HTML(response.body)
    scr = html.css("script")
    res_script_text = scr.select{|b| b.text.include?("LoginAction") }.first.text
    path = res_script_text.match(/action=(.*?);/)[1]
    login_url = host + path.tr("'", "")
  end

  def get_auth_cookie login_url, mobile, password
    cookie = get_auth_from_db
    return cookie unless cookie.nil?
    get_auth_cookie_from_network login_url, mobile, password
  end

  def get_auth_from_db
    begin
      session = Session.first
      puts "Session: #{session.inspect} "
      return nil if session.nil?
      puts "Cookie from DB..." 
      session.cookie
    rescue Exception => e
      nil
    end
  end

  def get_auth_cookie_from_network login_url, mobile, password
    params = {mobileNumber: mobile, password: password}
    login_res = post_with_cookie login_url, params, nil
    cookie = login_res.get_fields('Set-Cookie').map{|c| c.gsub("Path=/;", "").gsub("HttpOnly", "").gsub(";", "").strip}.join('; ')
    Session.delete_all
    Session.create(cookie: cookie)
    puts "Cookie from network...#{params}" 
    cookie
  end

  def get_main_balance_html cookie
    res = get_with_cookie('https://care.ideacellular.com/wps/myportal/prepaid/dedicated-account', cookie)
    html = Nokogiri::HTML(res.body)
  end

  def get_all_balance cookie
    html = get_main_balance_html cookie
    h = {}
    current_key = nil
    html.css("div.plan table.table_small tr").each do |tr|
      tds = tr.css("td")
      if( tds.count == 1)
        current_key = tds.first.text.strip
        h[current_key] = []
      end
      if (tds.count == 4)
        tds.each{ |td| h[current_key] << td.text.strip }
      end
    end
    h
  end

  def get_data_balance all_hash
    all_hash['Data'][2]
  end

  def get_data_expiry all_hash
    all_hash['Data'][3]
  end

  def get_main_balance all_hash
    all_hash['Balance'][2]
  end

  def get_usage mobile, password
    begin
      retries ||= 0
      login_url = get_login_url
      cookie = get_auth_cookie login_url, mobile, password

      all_balance_hash  = get_all_balance cookie

      {data: get_data_balance(all_balance_hash), data_expiry: get_data_expiry(all_balance_hash), main_balance: get_main_balance(all_balance_hash)}
    rescue Exception => e
      Session.delete_all
      puts e.inspect
      sleep 2
      retry if (retries += 1 ) < 3
      {error: e.message}
    end
  end
end
