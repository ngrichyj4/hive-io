#
# => Manages dependency path by adding project to load path
# => Require this file first
#
root_path = File.dirname(__FILE__)
relative_load_paths = [ root_path + '/lib' ]  # This path can be added by RubyGems automatically, if lambda-cli was installed as a gem
relative_load_paths.each do |path|
 path = File.expand_path(path, File.dirname(__FILE__))
 $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

# $:.unshift.inspect