module HashAttributes

  def set_attributes(attributes)
    create_attributes(attributes)
  end

  def set_params_attributes(key, attributes)
    create_attributes(attributes.slice(:controller, :action))
    create_attributes(attributes[key])
  end

private

  def create_attributes(attributes)
    attributes.each do |k,v|
      instance_variable_set "@#{k.to_s}", v
    end
  end
  
end