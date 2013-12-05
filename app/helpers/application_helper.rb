module ApplicationHelper
  def is_active?(page_name)
    "active_link" if params[:action] == page_name
  end
end
