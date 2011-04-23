desc "Create TAGS file"
task(:tags) do
  puts "generating ctags..."
  `ctags-exuberant -e -f TAGS --tag-relative -R lib spec`
  puts "ctags generation completed."
end

