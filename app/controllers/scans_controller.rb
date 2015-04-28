class ScansController < ApplicationController
  def new
    @scan = CreateScan.new
  end

  def create
    @scan = CreateScan.new

    if @scan.submit(params[:scan])
      redirect_to root_path, notice: "Scan done!"
    else
      render :new
    end
  end
end
