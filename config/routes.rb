ActionController::Routing::Routes.draw do |map|
  map.root :controller => "query", :controller => "query", :action => "index", :format => 'html'
  map.query '/query.:format', :controller => "query", :action => "index"
  map.help '/help', :controller => "query", :action => "help", :format => 'html'
  map.about '/about', :controller => "query", :action => "about", :format => 'html'
  map.advanced_query_help "/help", :anchor => 'querying', :controller => "query", :action => "help", :format => 'html'
  map.select_more_than_one "/help", :anchor => 'faq', :controller => "query", :action => "help", :format => 'html'
  map.results "/help", :anchor => 'results', :controller => "query", :action => "help", :format => 'html'
end
