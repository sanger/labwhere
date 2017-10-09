class LocationsController < ApplicationController

  before_action :locations, only: [:index]
  before_action :set_location, except: [:index, :activate, :deactivate]

  def index
  end

  def new
  end

  def show
    @location = current_resource
  end

  def create

    # @location = LocationForm.new
    # if @location.submit(params)
    #   redirect_to locations_path, notice: "Location successfully created"
    # else
    #   render :new
    # end
    
    location_forms, err = create_location_forms(params)
    unless err
      # puts "!!! LOCATION FORMS !!!", location_forms.inspect
      run_transaction do
        location_forms.each do |form|
          form.save_model
        end
      end
      redirect_to locations_path, notice: "Location successfully created"
    else
      # puts 'ERROR: Cannot generate location_forms'
      @location = location_forms[0]
      render :new      
    end
  end

  def edit
  end

  def update
    if @location.submit(params)
      redirect_to locations_path, notice: "Location successfully updated"
    else
      render :edit
    end
  end

  def delete
    respond_to do |format|
      format.js
    end
  end

  def destroy
    respond_to do |format|
      if @location.destroy(params)
        flash_keep "Location successfully deleted"
        format.js { render js: "window.location.pathname='#{locations_path}'" }
      else
        format.js 
      end
    end
  end

  def deactivate
    @location = current_resource
    @location.deactivate
    redirect_to locations_path, notice: "Location successfully deactivated"
  end

  def activate
    @location = current_resource
    @location.activate
    redirect_to locations_path, notice: "Location successfully activated"
  end

protected

  def locations
    @locations = Location.by_root
  end

  helper_method :locations

private

  def set_location
    @location = LocationForm.new(current_resource)
  end

  def current_resource
    @current_resource ||= Location.includes(:labwares).find(params[:id]) if params[:id]
  end

  def pos_int?(value)
    if /\A\d+\Z/.match(value.to_s)
      true
    else
      false
    end
  end

  def generate_names(prefix, start_from, end_to, &block)
    if pos_int?(start_from) and pos_int?(end_to) and start_from.to_i < end_to.to_i
      (prefix + start_from..prefix + end_to).each do |name|
        yield name
      end
    end
  end

  def create_location_forms(params)
    locations_batch = []
    err = false
    loc = params[:location]
    start_from = loc.fetch(:start_from, "")
    end_to = loc.fetch(:end_to, "")
    prefix = loc.fetch(:name)
    # puts "PREFIX:", prefix
    # puts "START:", start_from
    # puts "END:", end_to
    unless start_from.empty? or end_to.empty?
      # puts "GENERATE NAMES:"
      generate_names(prefix, start_from, end_to) do |name|
        # puts name
        loc[:name] = name
        location_form = LocationForm.new(current_resource)
        location_form.fill_model(params)
        # puts "LOCATION FORM", location_form.inspect
        if location_form.valid?
          locations_batch.push location_form
        else
          err = true
          locations_batch = [location_form]
        end 
      end  
    else
      location_form = LocationForm.new(current_resource)
      location_form.fill_model(params)
      if location_form.valid?
        locations_batch.push location_form
      else
        err = true
        locations_batch = [location_form]
      end
    end
    return locations_batch, err
  end

  def run_transaction(&block)
    begin
      ActiveRecord::Base.transaction do
        yield
      end
      true
    rescue
      false
    end
  end
end
