require 'mkmf'

unless find_executable 'go'
  puts "Not found go command, please install golang compile environment"
  exit 1
end

$makefile_created = true
