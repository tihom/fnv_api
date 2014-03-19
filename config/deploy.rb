require 'capistrano/ext/multistage'
require "bundler/capistrano"

set :stages, %w(development staging production)
set :default_stage, 'development'



