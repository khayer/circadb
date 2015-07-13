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

module TestRails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true


    config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'ALLOW-FROM http://biogps.org'
    }
  end
end
