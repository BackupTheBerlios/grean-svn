require 'uri'
require 'cgi'
require 'xmlrpc/client'
require 'time'
require 'digest/sha1'
require 'net/http'
Net::HTTP.version_1_2

class HatenaBookmark
  # 注目エントリーのURLとドメイン名
  def self.entrylist_url_and_domain(url)
    entrylist_url = 'http://b.hatena.ne.jp/entrylist?url='
    if md = %r<^(http://d\.hatena\.ne\.jp/([^/]+)/)>.match(url)
      entrylist_url += CGI.escape(md[1])
      domain         = "d:id:#{md[2]}"
    else
      url_array = URI.split(url).fill(nil, 4) # path以降の情報は使用しない
      entrylist_url += CGI.escape(URI::Generic.build(url_array).to_s + '/')
      domain         = url_array[3] ? "#{url_array[2]}:#{url_array[3]}" : url_array[2]
    end
    [entrylist_url, domain]
  end

  # AtomAPI WSSE認証 HTTP X-WSSEヘッダを作成
  protected
  def self.wsse_header(user_id, password)
    # Nonce : HTTPリクエスト毎に生成したセキュリティ・トークン
    # ランダムなバイト列 http://sheepman.parfait.ne.jp/20050104.html
    nonce = Array.new(10){ rand(0x100000000) }.pack('I*')
    nonce_base64 = [nonce].pack("m").chomp # Base64エンコード

    # Created : Nonceが作成された日時をISO-8601表記で記述したもの
    now = Time.now.utc.iso8601

    # PasswordDigest : Nonce, Created, パスワードを文字列連結しSHA1アルゴリズムでダイジェスト化して生成された文字列を、Base64エンコードした文字列
    digest = [Digest::SHA1.digest(nonce + now + password)].pack("m").chomp

    credentials = sprintf(%Q<UsernameToken Username="%s", PasswordDigest="%s", Nonce="%s", Created="%s">,
                          user_id, digest, nonce_base64, now)
    { 'X-WSSE' => credentials }
  end

  public
  def self.get_all_bookmarks(user_id, password)
    bookmarks = []

    Net::HTTP.start('b.hatena.ne.jp') do |http|
      offset = 0
      has_next = true

      while has_next
        header = { 'User-Agent' => "Ruby/#{VERSION}" }.update(wsse_header(user_id, password))
        response = http.get('/atom/feed?of=' + offset.to_s, header)
        raise "HatenaBookmark.get_all_bookmarks HTTP #{response.code} #{response.message}" unless response.code == '200'

        root = REXML::Document.new(response.body).elements['feed']

        total_results  = root.elements['openSearch:totalResults'].text.to_i
        start_index    = root.elements['openSearch:startIndex'].text.to_i
        items_per_page = root.elements['openSearch:itemsPerPage'].text.to_i
        if total_results >= start_index + items_per_page
          offset += items_per_page
        else
          has_next = false
        end

        root.elements.each('entry') do |elem|
          bookmark = {}
          bookmark[:title]  = elem.elements['title'].text
          bookmark[:url]    = elem.elements['link[@rel="related"]'].attributes['href']
          bookmark[:hb_eid] = elem.elements['link[@rel="service.edit"]'].attributes['href'].split('/')[-1]
          bookmark[:time]   = elem.elements['issued'].text
          bookmark[:notes]  = elem.elements['summary'].text
          bookmark[:tag] = []
          elem.elements.each('dc:subject') do |tag|
            bookmark[:tag] << tag.text
          end

          bookmarks << bookmark
        end
      end
    end

    bookmarks.reverse
  end
end
