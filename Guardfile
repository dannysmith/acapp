# # Guardfile
notification :growl

# Reload the app (but not the browser) on changes to ruby files
# guard :shotgun, server: 'thin', port: 3001 do
#   watch %r{^(lib|models)/.*\.rb}
#   watch %r{^articles/.*\.md}
#   watch 'config.ru'
#   watch 'dasmith.rb'
# end

guard 'puma', :port => 3001 do
  watch('Gemfile.lock')
  watch %r{^(lib|models)/.*\.rb}
  watch %r{^articles/.*\.md}
  watch 'config.ru'
  watch 'dasmith.rb'
end

# Restart the bundles if I change the Gemfile
guard :bundler do
  watch('Gemfile')
end
