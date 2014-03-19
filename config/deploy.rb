require 'capistrano/ext/multistage'
require "rvm/capistrano"
require "bundler/capistrano"


set :stages, %w(development staging production)
set :default_stage, 'development'



