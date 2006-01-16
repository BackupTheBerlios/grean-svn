require 'digest/md5'
require 'rexml/document'
require 'net/http'
Net::HTTP.version_1_2

class Delicious
  def self.get_all_bookmarks(user_id, password)
    xml = nil
    Net::HTTP.start('del.icio.us') do |http|
      req = Net::HTTP::Get.new('/api/posts/all', { 'User-Agent' => "Ruby/#{VERSION}" })
      req.basic_auth(user_id, password)
      response = http.request(req)
      xml = response.body
    end

    bookmarks = []

    root = REXML::Document.new(xml).elements['posts']
    root.elements.each('post') do |elem|
      bookmark = {}
      bookmark[:url]   = elem.attributes['href']
      bookmark[:title] = elem.attributes['description']
      bookmark[:notes] = elem.attributes['extended']
      bookmark[:tag]   = elem.attributes['tag'].split
      bookmark[:time]  = elem.attributes['time']
      bookmarks << bookmark
    end

    bookmarks.reverse
  end
end
