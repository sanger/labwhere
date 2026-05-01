# frozen_string_literal: true

# ApplicationController - base for all controllers
class ApplicationController < ActionController::Base
  # LabWhere is not vulnerable to CSRF attacks as it does not have user logins or sessions
  # but we want to handle the issues gracefully if an idle user tries to perform an action after the session has expired
  protect_from_forgery with: :reset_session

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
