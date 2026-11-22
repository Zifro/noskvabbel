# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Newskvabbel
  # The main application class
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # The vendored Tailwind CSS 4 build (app/assets/stylesheets/tailwind-daisyui.css)
    # uses modern CSS (range media queries, oklch, ...) that libsass cannot parse,
    # so disable the default sassc CSS compressor and serve the file as-is.
    config.assets.css_compressor = nil

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
