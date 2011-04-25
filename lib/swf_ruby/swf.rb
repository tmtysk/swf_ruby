require 'zlib'
Dir[File.join(File.dirname(__FILE__), 'swf', '*.rb')].sort.each { |f| require f }
