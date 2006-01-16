class BookmarksController < ApplicationController
  def list
    @bookmark_pages, @bookmarks = paginate :bookmarks, :per_page => 3, :order_by => 'created_at DESC, id DESC'
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
end
