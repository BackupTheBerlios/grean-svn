class BookmarksController < ApplicationController
  before_filter :set_params_search

  def list
    unescape_tags # CGI.unescape params[:tags]

    per_page = 3
    order    = 'bookmarks.created_at DESC, bookmarks.id DESC'
    # search case-insensitive
    conditions = params[:search] ? ['(UPPER(bookmarks.title) LIKE UPPER(?) OR UPPER(bookmarks.notes) LIKE UPPER(?))']+["%#{params[:search]}%"]*2 : nil

    # tag filter
    if params[:tags]
      @bookmark_count = Bookmark.find_tagged_with(:all => params[:tags], :conditions => conditions).length
      @bookmark_pages = Paginator.new(self, @bookmark_count, per_page, params[:page])
      @bookmarks = Bookmark.find_tagged_with(:all        => params[:tags],
                                             :order      => order,
                                             :offset     => @bookmark_pages.current.to_sql[1],
                                             :limit      => @bookmark_pages.current.to_sql[0],
                                             :conditions => conditions)
    # not tag filter
    else
      @bookmark_count = Bookmark.count(conditions)
      @bookmark_pages, @bookmarks = paginate(:bookmarks, :per_page => per_page, :order => order, :conditions => conditions)
    end
  end

  def show
    @bookmark = Bookmark.find(params[:id])
  end

  def new
    @bookmark = Bookmark.new
    @bookmark.url   = params[:url]
    @bookmark.title = params[:title]
  end

  def create
    @bookmark = Bookmark.new(params[:bookmark])
    if @bookmark.save && @bookmark.set_tags(params[:bookmark][:tags_str])
      flash[:notice] = 'Bookmark was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @bookmark = Bookmark.find(params[:id])
  end

  def update
    @bookmark = Bookmark.find(params[:id])
    if @bookmark.update_attributes(params[:bookmark]) && @bookmark.set_tags(params[:bookmark][:tags_str])
      flash[:notice] = 'Bookmark was successfully updated.'
      redirect_to :action => 'show', :id => @bookmark
    else
      render :action => 'edit'
    end
  end

  def destroy
    Bookmark.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def config
  end

  def import
    options = {
      :service   => params[:service],
      :overwrite => params[:overwrite],
      :user_id   => params[:user_id],
      :password  => params[:password],
    }
    @bookmarks = Bookmark.import(options)
  end

  def destroy_all
    Bookmark.destroy_all
    Tag.destroy_all

    flash[:notice] = 'All bookmarks destroyed.'
    redirect_to :action => 'config'
  end

  protected
  def unescape_tags
    if params[:tags].nil? || params[:tags].length == 0
      params[:tags] = nil
    else
      params[:tags].collect! { |t| CGI.unescape(t) }
    end
  end

  # params[:search] strip
  def set_params_search
    if params[:search]
      params[:search].strip!
      return if params[:search].length > 0
    end
    params[:search] = nil
  end
end
