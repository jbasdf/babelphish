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
                  
      # def translate_directory(directory, language = 'en', overwrite = false)
      #   Dir.glob(File.join("#{directory}", "*")).each do |f|
      #     Babelphish::GoogleTranslate::LANGUAGES.each do |to|
      #       translate_and_write_page(f, to, language, overwrite)
      #     end
      #   end
      # end
      # 
      # def translate_and_write_page(page_path, to, from, overwrite)
      #   return if to == from
      #   return unless File.exist?(page_path)
      #   translated_filename = get_translated_file(page_path, to, from)
      #   return if File.exist?(translated_filename) && !overwrite
      #   text = IO.read(page_path)
      # #      yam = YAML.load_file(page_path)
      #   translated_text = translate(text, to, from)
      #   translated_directory = File.dirname(translated_filename)
      #   FileUtils.mkdir_p(translated_directory)
      #   File.open(translated_filename, 'w') { |f| f.write(translated_text) }
      # end
      # 
      # def get_translated_file(page, to, from)
      #   segments = page.split('/')
      #   index = segments.index(from)
      #   segments[index] = to
      #   segments.join('/')
      # end

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