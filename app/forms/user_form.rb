class UserForm

  include AuditForm

  set_attributes :login, :swipe_card_id, :barcode, :type, :status, :team_id

  delegate :becomes, to: :user
  
end