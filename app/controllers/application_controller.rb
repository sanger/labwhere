class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def header
    @header ||= Header.new(params)
  end

  def flash_keep(message)
    flash[:notice] = message
    flash.keep(:notice)
  end

  helper_method :header

end
