# frozen_string_literal: true

class PrintersController < ApplicationController
  before_action :printers, only: [:index]

  def index; end

  def new
    @printer = PrinterForm.new
  end

  def create
    @printer = PrinterForm.new
    if @printer.submit(params)
      redirect_to printers_path, notice: I18n.t('success.messages.created', resource: 'Printer')
    else
      render :new
    end
  end

  def edit
    @printer = PrinterForm.new(current_resource)
  end

  def update
    @printer = PrinterForm.new(current_resource)
    if @printer.submit(params)
      redirect_to printers_path, notice: I18n.t('success.messages.updated', resource: 'Printer')
    else
      render :new
    end
  end

  def printers
    @printers ||= Printer.all
  end

  helper_method :printers

  private

  def current_resource
    @current_resource ||= Printer.find(params[:id]) if params[:id]
  end
end
