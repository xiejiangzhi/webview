require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :test do
  system("cd ext && ruby extconf.rb && make clean && make && make install")
  Rake::Task[:spec].invoke
end
