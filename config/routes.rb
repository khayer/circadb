
Rails.application.routes.draw do
#ActionController::Routing::Routes.draw do |map|
  root 'query#index'
  #map.root :controller => "query", :controller => "query", :action => "index", :format => 'html'
  get '/query' => 'query#format'
  get '/about' => 'query#about', :format => 'html'
  get '/help' => 'query#help', :format => 'html'
  #get '/help' => 'query#help', :format => 'html'
  get '/select_more_than_one' => 'query#help', :format => 'html', :anchor => 'faq'
  #map.query '/query.:format', :controller => "query", :action => "index"
  ##map.table '/table.:format', :controller => "table", :action => "write" , :format => 'html'
  #map.help '/help', :controller => "query", :action => "help", :format => 'html'
  #map.about '/about', :controller => "query", :action => "about", :format => 'html'
  #map.advanced_query_help "/help", :anchor => 'querying', :controller => "query", :action => "help", :format => 'html'
  #map.select_more_than_one "/help", :anchor => 'faq', :controller => "query", :action => "help", :format => 'html'
  #map.results "/help", :anchor => 'results', :controller => "query", :action => "help", :format => 'html'
end
