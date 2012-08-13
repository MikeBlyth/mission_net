class AppLogsController < ApplicationController
#  include AuthenticationHelper

  active_scaffold :app_log do |config|
    config.columns = [:created_at, :severity, :code, :description]
    list.sorting = {:created_at => 'DESC'}
  end

  def list_authorized2?
    current_user.roles_include?(:member)
  end
end
