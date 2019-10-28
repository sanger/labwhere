##
# A couple of useful methods to create hash attributes.
module HashAttributes
  ##
  # Takes a list of attributes and their values and create instance variables.
  def set_attributes(attributes)
    create_attributes(attributes)
  end

  ##
  # Useful for form objects.
  # Create an instance variable for the controller and action
  #
  # creates a top level instance variable for each attribute in the key hash.
  def set_params_attributes(key, attributes)
    create_attributes(attributes.slice(:controller, :action))
    create_attributes(attributes[key])
  end

  private

  def create_attributes(attributes)
    attributes.each do |k, v|
      instance_variable_set "@#{k}", v
    end
  end
end
