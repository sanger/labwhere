# frozen_string_literal: true

# ApplicationController - base for all controllers
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Reset the connection check for every request so it will only
  # try to connect once for every request
  include RabbitmqConnection

  ##
  # Creates a standard header in case no other header is passed.
  def header
    @header ||= Header.new(params)
  end

  ##
  # Current year necessary for copyright.
  def current_year
    @current_year ||= Time.zone.today.year
  end

  ##
  # Useful for Ajax calls.
  # This will keep any messages across a request.
  def flash_keep(message)
    flash[:notice] = message
    flash.keep(:notice)
  end

  helper_method :header, :current_year

  # Ensure that the exception notifier is working. It will send an email to the standard email address.
  def test_exception_notifier
    raise 'This is a test. This is only a test.'
  end
end
