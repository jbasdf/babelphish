require 'yaml'
require 'fileutils'
require 'babelphish/languages'
require 'ruby-debug'

module Babelphish
  module Translator
    class << self
      
      def translate_yaml(yml, overwrite = false)
        language = File.basename(yml, ".yml")
        if !Babelphish::GoogleTranslate::LANGUAGES.include?(language)
          STDERR.puts "#{language} is not one of the available languages.  Please choose a standard localized yml file.  i.e. en.yml."
          return
        end
        Babelphish::GoogleTranslate::LANGUAGES.each do |to|
          translate_and_write_yml(yml, to, language, overwrite)
        end
      end

      def translate_and_write_yml(yml, to, from, overwrite)
        return if to == from
        return unless File.exist?(yml)
        translated_filename = File.join(File.dirname(yml), "#{to}.yml")
        return if File.exist?(translated_filename) && !overwrite
        text = IO.read(yml)
        translated_text = translate(text, to, from)
        File.open(translated_filename, 'w') { |f| f.write(translated_text) }
      end

      # from: http://ruby.geraldbauer.ca/google-translation-api.html
      def translate(text, to, from = 'en')

        return if to == from

        require 'cgi'
        require 'json'
        require 'net/http'

        base = 'http://ajax.googleapis.com/ajax/services/language/translate' 
        # assemble query params
        params = {
          :langpair => "#{from}|#{to}", 
          :q => text,
          :v => 1.0  
        }
        query = params.map{ |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
        # send get request
        response = Net::HTTP.get_response( URI.parse( "#{base}?#{query}" ) )
        json = JSON.parse( response.body )
        if json['responseStatus'] == 200
          json['responseData']['translatedText']
        else
          puts response
          puts to
          puts from
          raise StandardError, response['responseDetails']
        end
      end

    end
  end
end