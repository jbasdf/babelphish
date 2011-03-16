$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'cgi'
require 'json'
#require 'net/http'
require 'net/https'

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
  
  MAX_RETRIES = 3
  
  def self.google_ajax_url
    if api_version == 'v2'
      "https://www.googleapis.com/language/translate/v2"
    else
      "http://ajax.googleapis.com/ajax/services/language/"
    end
  end
  
  def self.api_version
    self.settings['version']
  end
  
  def self.settings
    return @settings if @settings
    babelphish_settings_file = File.join(File.expand_path("~"), ".babelphish.yml")
    if File.exist?(babelphish_settings_file)
      @settings = YAML.load_file(babelphish_settings_file)
    else
      @settings = {"api_key"=>"", "version"=>"v1"}
    end
  end
  
  def self.set_settings(settings)
    @settings = settings
  end
  
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
