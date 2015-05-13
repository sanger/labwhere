class Guest < User

  include Permissions

  def swipe_card_id
    0
  end

  def barcode
    "Guest:1"
  end

  def login
    "Guest"
  end

  def team_id
    1
  end
  
end