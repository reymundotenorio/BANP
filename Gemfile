source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.5.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 5.2.1"
# Use mysql as the database for Active Record
gem "mysql2", ">= 0.4.4", "< 0.6.0"
# Use Puma as the app server
gem "puma", "~> 3.11"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem "mini_racer", platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 4.2"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"
# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use ActiveStorage variant
# gem "mini_magick", "~> 4.8"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

gem "railties", ">= 5.2.2.1"
gem "actionview", ">= 5.2.2.1"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem "chromedriver-helper"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]


# ********** BANP Dependencies ********** #

# For development
group :development do
  # Better errors
  gem "better_errors"
  gem "binding_of_caller"

  # Create Entity Relationship Diagram
  gem "rails-erd", "~> 1.4", ">= 1.4.7"
  # Create models for ActiveRecord
  gem "railroady", "~> 1.4", ">= 1.4.2"

  # Console colorize
  gem "colorize"
end

# Use jquery as the JavaScript library
gem "jquery-rails"

# Faker - fill data
gem "faker", git: "https://github.com/stympy/faker.git", branch: "master"

# Paperclip - Easy file attachment management for ActiveRecord
# gem "paperclip", "~> 5.2.0"

# Fiendly id - Pretty URL
gem "friendly_id", "~> 5.2"

# Audited - Audits models
gem "audited", "~> 4.7"

# Will Paginate - Pagination
gem "will_paginate", "~> 3.1", ">= 3.1.5"
# Will Paginate - Bootstrap Pagination
gem "will_paginate-bootstrap", "~> 1.0", ">= 1.0.1"

# Render_Sync - Realtime partials
gem "render_sync", git: "https://github.com/reymundotenorio/render_sync", branch: "master"
# Render_Sync with Pusher
gem "pusher", "~> 1.3", ">= 1.3.1"
# Faye (Only to prevent precompile heroku error)
gem "faye", "~> 1.2"

# Bootstrap 3
gem "bootstrap-sass", ">= 3.4.1"

# Wicked PDF
gem "wicked_pdf", "~> 1.1"
gem "wkhtmltopdf-binary", "~> 0.12.3"

# Rails HTML Sanitizer (Heroku fix)
gem "rails-html-sanitizer", "~> 1.0.4 "

# AWS - Amazon Web Services
# gem "aws-sdk", "~> 2.3"

# Figaro - Configuration using ENV and a single YAML file
gem "figaro", "~> 1.1", ">= 1.1.1"

# Use ActiveModel has_secure_password
gem "bcrypt", "~> 3.1.7"

# Device detector
gem "device_detector"

# Geocoder - IP location
gem "geocoder"

# Twilio SMS
gem "twilio-ruby", "~> 5.14.1"

# Google recaptcha
gem "recaptcha"

# Time Zone database
gem "tzinfo-data", "~> 1.2018", ">= 1.2018.5"

# AWS SDK S3 - Amazon Web Services
gem "aws-sdk-s3", require: false

# HTML Abstraction Markup Language
gem "haml"

# Haml-rails provides Haml generators
gem "haml-rails", "~> 1.0"

# Erubis - Rendering Rails views on js.erb
gem "erubis", "~> 2.7"

# Barcode generator
gem "barby"

# Charts
gem "chartkick"
# gem "chartkick", git: "https://github.com/reymundotenorio/chartkick", branch: "master"

# Group by date
gem "groupdate"

# JSON
gem "json", "~> 1.8"

# HTTParty - Request HTTP
gem "httparty", "~> 0.13.7"

# Paypal SDK
gem "paypal-sdk-rest"

# Get Zip code information
gem "zip-codes"

# Stripe Payments
gem "stripe"

# Datepicker
gem "momentjs-rails", ">= 2.9.0"
gem "bootstrap3-datetimepicker-rails", "~> 4.17.47"

# Cocoon - Easier nested form
gem "cocoon"

# Font Awesome 5 (local)
gem "font_awesome5_rails"

# Excel export
gem "rubyzip", ">= 1.2.1"
gem "axlsx", git: "https://github.com/randym/axlsx.git", ref: "c8ac844"
gem "axlsx_rails"
