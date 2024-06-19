# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

RedmineApp::Application.routes.draw do
  match '/work_wechat/js_sdk_config', :controller => 'work_wechat',
        :action => 'js_sdk_config', via: [:get]
end
