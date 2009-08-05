# Global filter redmine plguin
require 'redmine'
require 'dispatcher'

require_dependency 'welcome_index_hook'
require RAILS_ROOT+'/app/helpers/issues_helper'

Dispatcher.to_prepare do
  WelcomeHelper.send(:include, IssuesHelper)
end

RAILS_DEFAULT_LOGGER.info 'Starting Global Filter Plugin for RedMine'
#RAILS_DEFAULT_LOGGER.info 'Listeners: '+ Redmine::Hook.listeners.inspect

Redmine::Plugin.register :global_filter_plugin do
  name 'Global filter plugin'
  author 'Kumudha Rangachari'
  description 'This is a global filter plugin for Redmine that is used to display issues that satisfy a global filter across projects. Has the ability to filter on the projects displayed.'
  version '0.0.1'
end

