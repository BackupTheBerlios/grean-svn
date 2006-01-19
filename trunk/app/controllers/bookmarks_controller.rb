class BookmarksController < ApplicationController
  def list
    unescape_tags # CGI.unescape params[:tags]

    # tag filter
    if params[:tags]
      @bookmark_pages = Paginator.new(self, Bookmark.find_tagged_with(:all => params[:tags]).length, 3, params[:page])
      @bookmarks = Bookmark.find_tagged_with(:all    => params[:tags],
                                             :order  => ["bookmarks.created_at DESC, bookmarks.id DESC"],
                                             :offset => @bookmark_pages.current.to_sql[1],
                                             :limit  => @bookmark_pages.current.to_sql[0])
    else
      @bookmark_pages, @bookmarks = paginate(:bookmarks, :per_page => 3, :order_by => 'created_at DESC, id DESC')
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
end
