##
# Form object for creating or updating a User
class UserForm
  include AuthenticationForm
  include Auditor

  set_attributes :login, :swipe_card_id, :barcode, :type, :status, :team_id

  delegate :becomes, to: :user
end
