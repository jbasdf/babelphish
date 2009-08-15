module Babelphish
  module Translator

    class << self

      # from: http://ruby.geraldbauer.ca/google-translation-api.html
      # translate text from 'from' to 'to'
      def translate(text, to, from = 'en', tries = 0)

        return if to == from
        base = Babelphish::GOOGLE_AJAX_URL + 'translate' 
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
          if tries <= Babelphish::MAX_RETRIES
            # Try again a few more times
            translate(text, to, from, tries+=1)
          else
            raise Exceptions::GoogleResponseError, "A problem occured while translating from #{from} to #{to}.  #{json['responseDetails']}"
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
      def multiple_translate(text, tos, from = 'en', tries = 0)
        return {} if text.strip.empty? # Google doesn't like it when you send them an empty string
        base = Babelphish::GOOGLE_AJAX_URL + 'translate'
        # assemble query params
        params = {
          :q => text,
          :v => 1.0
        }
        query = params.map{ |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
        
        tos.each do |to|
          if !Babelphish::GoogleTranslate::LANGUAGES.include?(to)
            raise Exceptions::GoogleResponseError, "#{to} is not a valid Google Translate code.  Please be sure language codes are one of: #{Babelphish::GoogleTranslate::LANGUAGES.join(',')}"
          end
          query <<  "&langpair=" + CGI.escape("#{from}|#{to}")
        end

        response = Net::HTTP.get_response( URI.parse( "#{base}?#{query}" ) )
        json = JSON.parse( response.body )

        if json['responseStatus'] == 200
          results = {}
          json['responseData'].each_with_index do |data, index|
            if data['responseStatus'] == 200
              results[tos[index]] = data['responseData']['translatedText']
            else
              # retry the single translation
              translate(text, tos[index], from)
            end
          end
          results
        else
          if tries <= Babelphish::MAX_RETRIES
            # Try again a few more times
            multiple_translate(text, tos, from, tries+=1)
          else
            raise Exceptions::GoogleResponseError, "A problem occured while translating.  #{response} -- #{response.body} -- From: #{from} -- Text: #{text}"
          end
        end
      end

      # Sends a string to google to attempt to detect the language.  
      # Returns an array indicating success/fail and the resulting data from google in a hash:
      # {"language"=>"en", "confidence"=>0.08594032, "isReliable"=>false}
      def detect_language(text)
        request = Babelphish::GOOGLE_AJAX_URL + "detect?v=1.0&q=" + CGI.escape(text) 
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