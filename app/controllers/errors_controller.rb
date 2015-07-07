##
# Will show particular styled pages for a small number of standard errors.
class ErrorsController < ApplicationController

  ##
  # We need to return json or html depending on whether we are using the ui or api.
  # forwarded to the page signified by the error code.
  def show
    @exception = env["action_dispatch.exception"]
    respond_to do |format|
      format.html { render action: request.path[1..-1] }
      format.json { render json: {status: request.path[1..-1], error: @exception.message} }
    end
  end
end