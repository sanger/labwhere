module ApplicationHelper

  def link_to_add_data(name, path)
    link_to(name, '#', class: "add-data", data: {path: path})
  end
 
end
