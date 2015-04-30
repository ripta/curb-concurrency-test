require 'bundler'
Bundler.require(:default)

require_relative 'lib/curb-concurrency-test'
run Rack::URLMap.new(
  '/backend/easy'  => CurbConcurrencyTestApp::Easy.new,
  '/backend/multi' => CurbConcurrencyTestApp::Multi.new,
  '/sleep'         => CurbConcurrencyTestApp::Sleep.new
)
