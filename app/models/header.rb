class Header
  def initialize(params)
    @action = params[:action]
    @controller = params[:controller].split("/").last
  end

  def to_s
    return controller.gsub('_', ' ').titleize if action == "index"
    "#{action.capitalize} #{controller.singularize.gsub('_', ' ').titleize}"
  end

  def to_css_class
    return controller.gsub('_', '-') if action == "index"
    "#{action}-#{controller.singularize.gsub('_', '-')}"
  end

private

  attr_reader :action, :controller
end