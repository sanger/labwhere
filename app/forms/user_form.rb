##
# Form object for creating or updating a User
class UserForm

  include Auditor

  set_attributes :login, :swipe_card_id, :barcode, :type, :status, :team_id

  delegate :becomes, to: :user

  ##
  # Because the swipe card id and barcode are password fields
  # we need to ensure that these are not wiped if they are not updated.
  # When the user is updated and these are nil then they are
  # removed from the parameters.
  def submit(params)
    set_instance_variables(params)
    set_current_user(params)
    remove_password_fields(params)
    set_model_attributes(params)
    save_if_valid
  end

private

  def remove_password_fields(params)
    if action == "update"
      [:swipe_card_id, :barcode].each do |field|
        params[:user] = params[:user].slice!(field) unless params[:user][field].present?
      end
    end
  end
  
end