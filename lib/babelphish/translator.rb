module Babelphish
  module Translator

    class << self

      # from: http://ruby.geraldbauer.ca/google-translation-api.html
      # translate text from 'from' to 'to'
      def translate(text, to, from = 'en', tries = 0)
        return if to == from
        if text.is_a? Symbol 
           return text
        end
        
        if text.length > 1000  #actually the USI length limit is 2000
           text_now = ""
           text_rem = ""
           text.split(".") do |text_chunk|
              if text_now.length < 1000
                 text_now += (text_now.length == 0 ? "" : ".") + text_chunk
              else
                 text_rem += (text_now.length == 0 ? "" : ".") + text_chunk
              end 
           end
           return translate(text_now, to, from) + "." + translate(text_rem, to, from)
        end
        
        base = Babelphish.google_ajax_url 
        if Babelphish.api_version == 'v2'
          # assemble query params
          params = {
            :source => "#{from}", 
            :target => "#{to}", 
            :q => text,
            :key => Babelphish.settings['api_key']
          }
        else
          base << 'translate' 
          # assemble query params
          params = {
            :langpair => "#{from}|#{to}", 
            :source => "#{from}", 
            :target => "#{to}", 
            :q => text,
            :v => 1.0  
          }
        end
        
        # send get request
        uri = URI.parse(base)
        uri.query = params.map{ |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
        http = Net::HTTP.new( uri.host, uri.port )
        http.use_ssl = true if uri.scheme == "https" # enable SSL/TLS
        
        # TODO kind of dangerous to turn off all verification. Should try to get a valid cert file at some point.
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        # cacert_file = File.join(File.expand_path("~"), "cacert.pem")
        # if File.exist?(cacert_file)
        #   http.ca_file = cacert_file
        # end
        
        response = nil
        
        http.start {|http| response = http.request_get(uri.request_uri) }
        
        if response.code == "200" 
          json = JSON.parse(response.body)
          if Babelphish.api_version == 'v2'
            json['data']['translations'][0]['translatedText']
          else
            json['responseData']['translatedText']
          end
        else
          if tries <= Babelphish::MAX_RETRIES
            # Try again a few more times
            translate(text, to, from, tries+=1)
          else
            raise Exceptions::GoogleResponseError, "A problem occured while translating from #{from} to #{to}.  #{response.body}"
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

        tos.each do |to|
          if !Babelphish::GoogleTranslate::LANGUAGES.include?(to)
            raise Exceptions::GoogleResponseError, "#{to} is not a valid Google Translate code.  Please be sure language codes are one of: #{Babelphish::GoogleTranslate::LANGUAGES.join(',')}"
          end
        end
        
        if Babelphish.api_version == 'v2'
          results = {}
          tos.each do |to|
            results[to] = translate(text, to, from)
          end
          results
        else
          base = Babelphish.google_ajax_url + 'translate'
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
            if json['responseData'].is_a?(Array)
              json['responseData'].each_with_index do |data, index|
                results[tos[index]] = data['responseData']['translatedText']
              end
            else
              results[tos[0]] = json['responseData']['translatedText']
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

      end

      # Sends a string to google to attempt to detect the language.  
      # Returns an array indicating success/fail and the resulting data from google in a hash:
      # {"language"=>"en", "confidence"=>0.08594032, "isReliable"=>false}
      def detect_language(text)
        request = Babelphish.google_ajax_url + "detect?v=1.0&q=" + CGI.escape(text) 
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
