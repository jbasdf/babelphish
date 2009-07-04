module Babelphish
  module Translator

    class << self
      
      GOOGLE_AJAX_URL = "http://ajax.googleapis.com/ajax/services/language/"
      MAX_RETRIES = 3
      
      def translate_yaml(yml, overwrite = false, translate_to = nil)
        @yml = yml
        language = File.basename(yml, ".yml")
        if !Babelphish::GoogleTranslate::LANGUAGES.include?(language)
          STDERR.puts "#{language} is not one of the available languages.  Please choose a standard localized yml file.  i.e. en.yml."
          return
        end
        if translate_to
          puts "Translating #{language} to #{translate_to}"
          translate_and_write_yml(yml, translate_to, language, overwrite)
          puts "Finished translating #{language} to #{translate_to}"
        else
          translate_and_write_yml(yml, language, overwrite)
        end
      end

      def translate_and_write_yml(yml, from, overwrite)
        return unless File.exist?(yml)
        source_yml = YAML.load_file(yml)
        translated_hashes = {}
        translate_keys(source_yml, translated_hashes, from)
        translated_hashes.each_key do |key|
          translated_hash = translated_hashes[key]
          # change the top level key from the source language to the destination language
          translated_hash[key] = translated_hash[from]
          translated_hash.delete(from)
          translated_filename = File.join(File.dirname(yml), "#{key}.yml")
          if !File.exist?(translated_filename) || overwrite
            File.open(translated_filename, 'w') { |f| f.write(translated_hash.ya2yaml) }
          end
        end
      end

      def translate_keys(source_hash, translated_hashes, from)
        source_hash.each_key do |key|
          if source_hash[key].is_a?(Hash)
            translate_keys(source_hash[key], translated_hashes, from)
          else
            if key == false
              puts "Key #{key} was evaluated as false.  Check your yml file and be sure there are no values like no: No.  They will evaluate to false and produce a bad key."
            elsif key == true
              puts "Key #{key} was evaluated as true.  Check your yml file and be sure there are no values like yes: Yes.  They will evaluate to true and produce a bad key."
            elsif !source_hash[key].nil?
              # pull out all the string substitutions so that google doesn't translate those
              pattern = /\{\{.+\}\}/
              holder = '{{---}}'
              replacements = source_hash[key].scan(pattern)
              source_hash[key].gsub!(pattern, holder)
              translations = Babelphish::Translator.multiple_translate(source_hash[key], from)
              translations.each_key do |key|
                replacements.each do |r|
                  translations[key].sub!(holder, r)
                end
                translated_hashes[key] ||= {}
                # have to reconstruct the hash.
              end
            else
              puts "Key #{key} contains no data"
            end
          end
        end
      end

      # from: http://ruby.geraldbauer.ca/google-translation-api.html
      def translate(text, to, from = 'en', tries = 0)

        return if to == from
        base = GOOGLE_AJAX_URL + 'translate' 
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
          if tries <= MAX_RETRIES
            # Try again a few more times
            translate(text, to, from, tries+=1)
          else
            puts "A problem occured while translating from #{from} to #{to}. "
            puts "#{json['responseDetails']} "
            puts "To retry only this translation try: 'babelphish -o -y #{@yml} -t #{to}' to retry the translation.  Response: #{response}" if defined?(@yml)
            raise Exceptions::GoogleResponseError, "#{json['responseDetails']}"
          end
        end
      end

      # translate from the 'from' language into all available languages

      # multiple strings and multiple languages
      #
      # http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=hello%20world&langpair=en|it&q=goodbye&langpair=en|fr
      # results from google look like this:
      # {"responseData": [{"responseData":{"translatedText":"ciao mondo"},"responseDetails":null,"responseStatus":200},{"responseData":{"translatedText":"au revoir"},"responseDetails":null,"responseStatus":200}], "responseDetails": null, "responseStatus": 200}
      #
      # One string into multiple languages
      # http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=hello%20world&langpair=en|it&langpair=en|fr
      # results from google look like this:
      # {"responseData": [{"responseData":{"translatedText":"ciao mondo"},"responseDetails":null,"responseStatus":200},{"responseData":{"translatedText":"Bonjour le Monde"},"responseDetails":null,"responseStatus":200}], "responseDetails": null, "responseStatus": 200}
      #      
      def multiple_translate(text, from = 'en', tos = Babelphish::GoogleTranslate::LANGUAGES, tries = 0)
        base = GOOGLE_AJAX_URL + 'translate'
        # assemble query params
        params = {
          :q => text,
          :v => 1.0  
        }
        query = params.map{ |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
        
        tos.each do |to|
          query <<  "&langpair=" + CGI.escape("#{from}|#{to}")
        end

        response = Net::HTTP.get_response( URI.parse( "#{base}?#{query}" ) )
        json = JSON.parse( response.body )

        if json['responseStatus'] == 200
          results = {}
          json['responseData'].each_with_index do |data, index|
            if data['responseStatus'] == 200
              results[Babelphish::GoogleTranslate::LANGUAGES[index]] = data['responseData']['translatedText']
            else
              # retry the single translation
              translate(text, Babelphish::GoogleTranslate::LANGUAGES[index], from)
            end
          end
          results
        else
          if tries <= MAX_RETRIES
            # Try again a few more times
            multiple_translate(text, to, from, tries+=1)
          else
            puts "A problem occured while translating from #{from} to #{to}.  To retry only this translation try: 'babelphish -o -y #{@yml} -t #{to}' to retry the translation.  Response: #{response}"
          end
        end
      end

      # Sends a string to google to attempt to detect the language.  
      # Returns an array indicating success/fail and the resulting data from google in a hash:
      # {"language"=>"en", "confidence"=>0.08594032, "isReliable"=>false}
      def detect_language(text)
        request = GOOGLE_AJAX_URL + "detect?v=1.0&q=" + CGI.escape(text) 
        # send get request
        response = Net::HTTP.get_response( URI.parse( request ) )
        json = JSON.parse( response.body )
        [json['responseStatus'] == 200, json['responseData']]
      end
      
      def supported_languages
        Babelphish::GoogleTranslate::LANGUAGES
      end
      
    end
  end
end