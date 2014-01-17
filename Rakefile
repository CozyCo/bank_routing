# encoding: utf-8

require 'rubygems'
require 'bundler'

begin
	Bundler.setup(:development)
rescue Bundler::BundlerError => e
	warn e.message
	warn "Run `bundle install` to install missing gems."
	exit e.status_code
end

desc "Run rspec tests"
task :spec do
	require 'rspec/core/rake_task'
	RSpec::Core::RakeTask.new
end

desc "Build the YARD Docs"
task :doc do
	require 'yard'
	YARD::Rake::YardocTask.new  
	Rake::Task[:yard].invoke
end

desc "Build a coverage report"
task :coverage do
	require 'simplecov'
	SimpleCov.start
	Rake::Task[:spec].invoke
end

task :test => :spec
task :default => :spec

Bundler::GemHelper.install_tasks

