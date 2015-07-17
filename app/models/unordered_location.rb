class UnorderedLocation < Location

  has_many :children, class_name: "Location", foreign_key: "parent_id"
  has_many :labwares, foreign_key: "location_id"

  before_save :synchronise_status_of_children
  after_update :cascade_parentage

  ##
  # If the status of a location changes we need to ensure that all of its children are synchonised.
  # For example if a location is deactivated then all of its children need to be.
  def synchronise_status_of_children
    if status_changed?
      inactive? ? deactivate_children : activate_children
    end
  end

  ##
  # Deactivate the child location as well of all of its childrens' children
  def deactivate_children
    children.each do |child|
      child.deactivate 
      child.deactivate_children
    end
  end

  ##
  # Activate the child location as well of all of its childrens' children
  def activate_children
    children.each do |child|
      child.activate 
      child.activate_children
    end
  end

   ##
  # Ensure that the parentage attribute stays current.
  # If the parent changes then we need to ensure that all of its childrens parentage is updated.
  def cascade_parentage
    children.each do |child|
      child.update_attribute(:parentage, child.set_parentage)
    end
  end
  
end