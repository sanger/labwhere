# frozen_string_literal: true

##
# This will upload multiple labware at once into existing locations.
# It can be used from a view or elsewhere.
class UploadFileForm
  include ActiveModel::Model

  attr_reader :current_user, :controller, :action

  validate :check_user

  def submit(params)
    assign_params(params)
    @current_user = User.find_by_code(@user_code)

    if valid?
      # TODO: uploader = ManifestUploader.new(@file)
      # TODO: uploader.run
      true
    else
      false
    end
  end

  def assign_params(params)
    @controller = params[:controller]
    @action = params[:action]
    @user_code = params[:upload_file_form][:user_code]
    @file =  params[:upload_file_form][:file]
  end

  def check_user
    UserValidator.new.validate(self)
  end
end
