class AppLogsController < ApplicationController
#  include AuthenticationHelper
  load_and_authorize_resource

  active_scaffold :app_log do |config|
    config.columns = [:created_at, :severity, :code, :description]
    list.sorting = {:created_at => 'DESC'}
  end
end
