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
require File.dirname(__FILE__) + '/../lib/babelphish/yml_translator'
require File.dirname(__FILE__) + '/../lib/babelphish/html_translator'

$KCODE = 'UTF8'
  
module Babelphish
  VERSION = '0.2.6'
  GOOGLE_AJAX_URL = "http://ajax.googleapis.com/ajax/services/language/"
  MAX_RETRIES = 3
  
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