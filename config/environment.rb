# Be sure to restart your server when you modify this file
#require 'will_paginate'
#require 'will_paginate/data_mapper'
# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '4.2.1' unless defined? RAILS_GEM_VERSION
#
## Bootstrap the Rails environment, frameworks, and default configuration
#require File.join(File.dirname(__FILE__), 'boot')
#Encoding.default_external = Encoding::UTF_8
#Encoding.default_internal = Encoding::UTF_8
#Rails::Initializer.run do |config|
#  config.gem 'will_paginate'
#  config.gem 'haml'
#  config.gem "jrails"
#  config.gem "thinking-sphinx", :lib => 'thinking_sphinx'
#  config.frameworks -= [ :active_resource, :action_mailer ]
#  config.time_zone = 'UTC'
#end
#
#gem 'will_paginate', '~> 2.2'
#require 'will_paginate'

# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

