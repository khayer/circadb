ActionController::Routing::Routes.draw do |map|
  map.root :controller => "query", :controller => "query", :action => "index", :format => 'html'
  map.query '/query.:format', :controller => "query", :action => "index", :method => [:get,:post]
  map.help '/help', :controller => "query", :action => "help", :format => 'html'
  map.about '/about', :controller => "query", :action => "about", :format => 'html'
end
