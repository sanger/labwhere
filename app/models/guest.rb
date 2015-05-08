class Guest

  include Permissions

  def name
    "Guest"
  end

  def swipe_card_id
    0
  end

  def barcode
    ""
  end

  def valid?
    true
  end

  def guest?
    true
  end
  
end