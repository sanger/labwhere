module ApplicationHelper

  ##
  # If the record has a status attribute.
  # Adds a link to activate or deactivate depending on the current status.
  # The method will deduce the controller and action based on the object and it's state.
  def link_to_change_status(object)
    action = object.active? ? "Deactivate" : "Activate"
    link_to action, { controller: object.class.to_s.tableize, action: action.downcase, id: object }, method: :patch
  end

  def behavior_link(behavior, image, help)
    link_to image_tag(image, alt: help, title: help), '#', data: { behavior: behavior}, class: "no-decoration"
  end

  def drilldown_link
    behavior_link "drilldown", "plus.png", "drilldown"
  end

  def audits_link
    behavior_link "audits", "audit-on.png", "Audit history"
  end

  def info_link
    behavior_link "info", "info.png", "Further information"
  end
 
end
