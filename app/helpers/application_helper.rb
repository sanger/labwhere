# frozen_string_literal: true

module ApplicationHelper
  ##
  # If the record has a status attribute.
  # Adds a link to activate or deactivate depending on the current status.
  # The method will deduce the controller and action based on the object and it's state.
  def link_to_change_status(object)
    action = object.active? ? "Deactivate" : "Activate"
    link_to action, { controller: object.class.to_s.tableize, action: action.downcase, id: object }, method: :patch
  end

  ##
  # Add a link to a particular data behavior with a class and accessibility tags.
  def behavior_link(behavior, image, help)
    link_to image_tag(image, alt: help, title: help), '#', data: { behavior: behavior }, class: "no-decoration"
  end

  ##
  # Add a link to allow the user to drilldown through the data.
  def drilldown_link
    behavior_link "drilldown", "plus.png", "drilldown"
  end

  ##
  # Add a link to allow the user to view the audits.
  def audits_link
    behavior_link "audits", "audit-on.png", "Audit history"
  end

  ##
  # Add a link to allow the user to view further information for the record
  def info_link
    behavior_link "info", "info.png", "Further information"
  end

  def print_link
    behavior_link "print", "print.png", "Print Barcode"
  end
end
