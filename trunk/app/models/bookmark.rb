class Bookmark < ActiveRecord::Base
  acts_as_taggable
  before_destroy :destroy_tags

  before_save :strip

  attr_accessible :url, :title, :notes

  # url
  validates_uniqueness_of :url
  validates_format_of :url, :with => %r<^http(s)?://[^/]+/>
  # title
  validates_presence_of :title

  # acts_as_taggable
  def tags_str
    self.tags.collect { |t| t.name }.join(' / ')
  end
  def set_tags(param_tags)
    new_tags = param_tags.split('/').collect{ |t| t.strip }.delete_if{ |t| t.length == 0 }
    delete_tag_names = self.tag_names - new_tags
    self.tag(new_tags, :clear => true)
    Tag.destroy_by_names_if_zero_tagged(delete_tag_names)
  end

  protected
  def destroy_tags
    delete_tag_names = self.tag_names
    self.tag(nil, :clear => true)
    Tag.destroy_by_names_if_zero_tagged(delete_tag_names)
  end

  # 先頭と末尾の空白文字を削除
  def strip
    self.url.strip!   if self.url
    self.title.strip! if self.title
    self.notes.strip! if self.notes
  end

  # import/export set options
  def self.set_options(options = nil)
    default_options = {
      :service   => 'hatena_bookmark',
      :overwrite => false,
    }

    if options.class == Hash
      return [] unless ['hatena_bookmark', 'delicious'].include? options[:service]

      options = default_options.merge(options)
      unless [true, false].include? options[:overwrite]
        options[:overwrite] = options[:overwrite] == 'true' ? true : false
      end
    else
      options = default_options
    end

    options
  end

  public
  def self.import(options)
    options = self.set_options(options)

    exist_bookmarks = {}
    Bookmark.find(:all).each do |b|
      exist_bookmarks[b.url] = true
    end

    # get all bookmarks
    bookmarks = nil
    if options[:service] == 'hatena_bookmark'
      bookmarks = HatenaBookmark.get_all_bookmarks(options[:user_id], options[:password])
    elsif options[:service] == 'delicious'
      bookmarks = Delicious.get_all_bookmarks(options[:user_id], options[:password])
    end

    # insert table
    import_bookmarks = []
    bookmarks.each do |b|
      bookmark = nil
      if exist_bookmarks.has_key? b[:url]
        if options[:overwrite]
          bookmark = Bookmark.find_by_url(b[:url])
        else
          if b.has_key? :hb_eid
            bookmark = Bookmark.find_by_url(b[:url])
            bookmark.hb_eid = b[:hb_eid]
            bookmark.save!
          end
          next
        end
      else
        bookmark = Bookmark.new
      end

      bookmark.url         = b[:url]
      bookmark.title       = b[:title]
      bookmark.notes       = b[:notes]
      bookmark.hb_eid      = b[:hb_eid] if b.has_key? :hb_eid
      bookmark.import_from = options[:service]
      bookmark.created_at  = Time.parse(b[:time])
      bookmark.updated_at  = bookmark.created_at
      bookmark.save! # bookmark_idが必要なのでタグ設定前にsaveする必要がある
      bookmark.tag(b[:tag], :clear => true)

      import_bookmarks << bookmark
    end

    import_bookmarks
  end
end

# A patch that work on PostgreSQL
# acts_as_taggable 1.0.4
# http://rubyforge.org/tracker/index.php?func=detail&aid=2482&group_id=923&atid=3629
if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  module ActiveRecord
    module Acts
      module Taggable
        module SingletonMethods
          def find_tagged_with(options = {}) 
            options = { :separator => ' ' }.merge(options)

            tag_names = ActiveRecord::Acts::Taggable.split_tag_names(options[:any] || options[:all], options[:separator])
            raise "No tags were passed to :any or :all options" if tag_names.empty?

            o, o_pk, o_fk, t, t_pk, t_fk, jt = set_locals_for_sql
            sql = "SELECT #{o}.* FROM #{o} WHERE #{o}.#{o_pk} IN (
                  SELECT #{jt}.#{o_fk} FROM #{jt}, #{t} WHERE #{jt}.#{t_fk} = #{t}.#{t_pk}
                  AND (#{t}.name = '#{tag_names.join("' OR #{t}.name='")}')
                  GROUP BY #{jt}.#{o_fk}"
            sql << " HAVING COUNT(#{jt}.#{o_fk}) = #{tag_names.length}" if options[:all]
            sql << " )"
            sql << " AND #{sanitize_sql(options[:conditions])}" if options[:conditions]
            sql << " ORDER BY #{options[:order]} " if options[:order]
            add_limit!(sql, options)

            find_by_sql(sql)
          end
        end
      end
    end
  end
end
