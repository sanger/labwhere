# frozen_string_literal: true

##
# This will upload multiple labware at once into existing locations.
# It can be used from a view or elsewhere.
class UploadLabwareForm
  include ActiveModel::Model

  attr_reader :file, :current_user, :controller, :action, :params

  validate :check_required_params, :check_file_format

  def submit(params)
    @params = params
    assign_params
    @current_user = User.find_by_code(@user_code)

    return false unless valid?

    uploader = ManifestUploader.new(json: format_file_to_json, current_user: current_user, controller: controller, action: action)

    unless uploader.valid? && uploader.run
      uploader.errors.full_messages.each { |error| errors.add(:base, error) }
      return false
    end
    true
  end

  # Convert CSV file to json
  # return e.g. { labwares: [{ location_barcode: 'loc-1', labware_barcode: 'DN1'}] }
  def format_file_to_json
    parsed = ::CSV.parse(file.tempfile.open.read).drop(1)
    { labwares: parsed.collect { |row| { location_barcode: row[0], labware_barcode: row[1] } } }
  end

  def form_sym
    :upload_labware_form
  end

  def assign_params
    @controller = params[:controller]
    @action = params[:action]
    @user_code = params[:upload_labware_form][:user_code]
    @file = params[:upload_labware_form][:file]
  end

  def check_required_params
    params.require([:controller, :action])
    params.require(:upload_labware_form).permit([:user_code, :file]).tap do |form_params|
      form_params.require([:user_code, :file])
    end
  rescue ActionController::ParameterMissing
    errors.add(:base, 'The required fields must be filled in')
  end

  def check_file_format
    CsvFileValidator.new.validate(self)
  end
end
