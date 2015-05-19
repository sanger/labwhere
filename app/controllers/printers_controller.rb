class PrintersController < ApplicationController

  before_action :printers, only: [:index]

  def index
  end

  def new
    @printer = Printer.new
  end

  def create
    @printer = Printer.new(printer_params)
    if @printer.save
      redirect_to printers_path, notice: "Printer successfully created"
    else
      render :new
    end
  end

  def edit
    @printer = current_resource
  end

  def update
     @printer = current_resource
    if @printer.update_attributes(printer_params)
      redirect_to printers_path, notice: "Printer successfully updated"
    else
      render :new
    end
  end

  def printers
    @printers ||= Printer.all 
  end

  helper_method :printers

private

  def printer_params
    params.require(:printer).permit(:name, :uuid)
  end

  def current_resource
    @current_resource ||=Printer.find(params[:id]) if params[:id]
  end
end
