class ScansController < ApplicationController
  def new
    @scan = ScanForm.new
  end

  def create
    @scan = ScanForm.new

    if @scan.submit(params[:scan])
      flash[:notice] = "Scan done!"
      redirect_to root_path
    else
      render :new
    end
  end
end
