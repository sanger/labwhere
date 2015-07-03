class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  ##
  # Creates a standard header in case no other header is passed.
  def header
    @header ||= Header.new(params)
  end

  def current_year
    @current_year ||= Date.today.year
  end

  ##
  # Useful for Ajax calls.
  # This will keep any messages across a request.
  def flash_keep(message)
    flash[:notice] = message
    flash.keep(:notice)
  end

  helper_method :header, :current_year

end
