ActionController::Routing::Routes.draw do |map|
  map.root :controller => "query", :controller => "query", :action => "index", :format => 'html'
  map.query '/query.:format', :controller => "query", :action => "index"
  map.help '/help', :controller => "query", :action => "help", :format => 'html'
  map.about '/about', :controller => "query", :action => "about", :format => 'html'
  map.advanced_query_help '/advanced_query_help', :controller => "query", :action => "advanced_query_help", :format => 'html'
end
