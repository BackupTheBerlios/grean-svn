# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  # Use Unicode Strings
  # http://wiki.rubyonrails.com/rails/pages/HowToUseUnicodeStrings
  before_filter :set_charset
  def set_charset
    @headers['Content-Type'] = 'text/html; charset=utf-8'
  end
  after_filter :fix_unicode_for_safari
  def fix_unicode_for_safari
    if @headers['Content-Type'] == 'text/html; charset=utf-8' and @request.env['HTTP_USER_AGENT'].to_s.include?('AppleWebKit') and request.xhr?
      @response.body = @response.body.gsub(/([^\x00-\xa0])/u) { |s| "&#x%x;" % $1.unpack('U')[0] }
    end
  end
end