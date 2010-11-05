ActionController::Routing::Routes.draw do |map|
  map.root :controller => "query", :controller => "query", :action => "index", :format => 'html'
  map.query '/query.:format', :controller => "query", :action => "index", :method => [:get,:post]
end
