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
          Babelphish::GoogleTranslate::LANGUAGES.each do |to|
            puts "Translating #{language} to #{to}"
            translate_and_write_yml(yml, to, language, overwrite)
            puts "Finished translating #{language} to #{to}"
          end
        end
      end

      def translate_and_write_yml(yml, to, from, overwrite)
        return if to == from
        return unless File.exist?(yml)
        translated_filename = File.join(File.dirname(yml), "#{to}.yml")
        return if File.exist?(translated_filename) && !overwrite
        translated_yml = YAML.load_file(yml)
        translate_keys(translated_yml, to, from)
        # change the top level key from the source language to the destination language
        translated_yml[to] = translated_yml[from]
        translated_yml.delete(from)
        File.open(translated_filename, 'w') { |f| f.write(translated_yml.ya2yaml) }
      end

      def translate_keys(translate_hash, to, from)
        translate_hash.each_key do |key|
          if translate_hash[key].is_a?(Hash)
            translate_keys(translate_hash[key], to, from)
          else
            if key == false
              puts "Key #{key} was evaluated as false.  Check your yml file and be sure to escape values like no with 'no'.  ie 'no': 'No'"
            elsif key == true
              puts "Key #{key} was evaluated as true.  Check your yml file and be sure to escape values like yes with 'yes'. ie 'yes': 'Yes'"
            elsif !translate_hash[key].nil?
              # pull out all the string substitutions so that google doesn't translate those
              pattern = /\{\{.+\}\}/
              holder = '{{---}}'
              replacements = translate_hash[key].scan(pattern)
              translate_hash[key].gsub!(pattern, holder)
              translate_hash[key] = translate(translate_hash[key], to, from)
              replacements.each do |r|
                translate_hash[key].sub!(holder, r)
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