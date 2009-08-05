class WelcomeIndexHook < Redmine::Hook::ViewListener
 
  render_on :view_welcome_index_left, :partial => "show_global_filters"

end