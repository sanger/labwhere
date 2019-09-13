##
# An unorderd location is one which can contain locations or labware e.g. shelf
class UnorderedLocation < Location

  before_save :synchronise_status_of_children

  ##
  # If the status of a location changes we need to ensure that all of its children are synchronised.
  # For example if a location is deactivated then all of its children need to be.
  def synchronise_status_of_children
    if status_changed?
      inactive? ? deactivate_children : activate_children
    end
  end

  ##
  # Deactivate the child location as well of all of its childrens' children
  def deactivate_children
    descendants.each &:deactivate
  end

  ##
  # Activate the child location as well of all of its childrens' children
  def activate_children
    descendants.each &:activate
  end

end