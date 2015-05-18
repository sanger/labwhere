module ApplicationHelper

  def link_to_add_data(name, path)
    link_to(name, '#', class: "add-data", data: {path: path})
  end

  def link_to_change_status(object)
    action = object.active? ? "Deactivate" : "Activate"
    link_to action, { controller: object.class.to_s.tableize, action: action.downcase, id: object }, method: :patch
  end

  def cancel_path(record)
    link_to "Cancel", { controller: record.class.model_name.name.tableize }
  end
 
end
