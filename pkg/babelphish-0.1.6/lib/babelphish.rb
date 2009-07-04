$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'cgi'
require 'json'
require 'net/http'

begin
  require 'jcode'
rescue LoadError
  begin
    gem 'jcode'
  rescue Gem::LoadError
    puts "Please install the jcode gem"
  end
end

begin
  require 'ya2yaml'
rescue LoadError
  begin
    gem 'ya2yaml'
  rescue Gem::LoadError
    puts "Please install the ya2yaml gem"
  end
end

require File.dirname(__FILE__) + '/../lib/babelphish/translator'
require File.dirname(__FILE__) + '/../lib/babelphish/languages'
require File.dirname(__FILE__) + '/../lib/babelphish/exceptions'

$KCODE = 'UTF8'
  
module Babelphish
  VERSION = '0.1.6'

  def self.load_tasks
    if File.exists?('Rakefile')
      load 'Rakefile'
      Dir[File.join(File.dirname(__FILE__), 'tasks', '**/*.rake')].each { |rake| load rake }
      return true
    else
      return false
    end
  end

end