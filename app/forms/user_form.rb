##
# Form object for creating or updating a User
class UserForm

  include AuthenticationForm

  set_attributes :login, :swipe_card_id, :barcode, :type, :status, :team_id

  delegate :becomes, to: :user

  # def submit(params)
  #   set_instance_variables(params)
  #   set_current_user(params)
  #   set_model_attributes(params)
  #   save_if_valid
  # end
  
end