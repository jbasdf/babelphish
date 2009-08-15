module Babelphish
  module YmlTranslator

    SUBSTITUTION_PLACE_HOLDER = '{{---}}'
    
    class << self
      
      # Translates the given yml file into the specified languages.  Will attempt to auto detect the from langauge
      # using the name of the yml file.
      # yml           - Path to the yml file to be translated
      # overwrite     - Boolean indicating whether or not existing translations should be overwritten.
      # translate_to  - A single language to translate the file into.  (Valid values are specified in languages.rb)
      #                 When this value is nil tos or Babelphish::GoogleTranslate::LANGUAGES is used to determine the languages
      # tos           - An array containing the languages to translate the yml file into.  If nil or not specified then
      #                 Babelphish::GoogleTranslate::LANGUAGES is used.
      def translate(yml, overwrite = false, translate_to = nil, tos = nil)
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
          translate_and_write_many_yml(yml, tos, language, overwrite)
        end
      end

      def translate_and_write_yml(yml, to, from, overwrite)
        return if to == from
        return unless File.exist?(yml)
        translated_filename = File.join(File.dirname(yml), "#{to}.yml")
        return if File.exist?(translated_filename) && !overwrite
        source = YAML.load_file(yml)
        translate_keys(source, to, from)
        # change the top level key from the source language to the destination language
        source[to] = source[from]
        source.delete(from)
        File.open(translated_filename, 'w') { |f| f.write(source.ya2yaml) }
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
              replacements = parse_substitutions(translate_hash[key])
              translate_hash[key] = Babelphish::Translator.translate(translate_hash[key], to, from)
              replacements.each do |r|
                translate_hash[key].sub!(SUBSTITUTION_PLACE_HOLDER, r)
              end
            else
              puts "Key #{key} contains no data"
            end
          end
        end
      end
      
      def translate_and_write_many_yml(yml, tos, from, overwrite)
        return unless File.exist?(yml)
        source = YAML.load_file(yml)
        translated_source = YAML.load_file(yml)
        translate_many_yml_keys(translated_source, tos, from)
        # At this point translated_source contains a translation for every language.  Cut it apart into individual hashes
        tos.each do |to|
          next if to == from # don't want to overwrite the source file
          extracted_translation = {}
          extract_yml_translation(source, translated_source, extracted_translation, to)
          # change the top level key from the source language to the destination language
          translated_filename = File.join(File.dirname(yml), "#{to}.yml")
          return if File.exist?(translated_filename) && !overwrite
          extracted_translation[to] = extracted_translation[from]
          extracted_translation.delete(from)
          File.open(translated_filename, 'w') { |f| f.write(extracted_translation.ya2yaml) }
        end
      end

      def extract_yml_translation(source, translated_source, extracted, language)
        source.each_key do |key|
          if source[key].is_a?(Hash)
            extracted[key] = {}
            extract_yml_translation(source[key], translated_source[key], extracted[key], language)
          else
            extracted[key] = translated_source[key][language]
          end
        end
      end
          
      def translate_many_yml_keys(translate_hash, tos, from)
        translate_hash.each_key do |key|
          if translate_hash[key].is_a?(Hash)
            translate_many_yml_keys(translate_hash[key], tos, from)
          else
            if key == false
              puts "Key #{key} was evaluated as false.  Check your yml file and be sure it does not include values like no: No"
            elsif key == true
              puts "Key #{key} was evaluated as true.  Check your yml file and be sure it does not include values like yes: Yes"
            elsif !translate_hash[key].nil?
              replacements = parse_substitutions(translate_hash[key])
              translations = Babelphish::Translator.multiple_translate(translate_hash[key], tos, from)
              translations.each_key do |locale|
                replacements.each do |r|
                  translations[locale].sub!(SUBSTITUTION_PLACE_HOLDER, r)
                end
              end
              translate_hash[key] = translations
            else
              puts "Key #{key} contains no data"
            end
          end
        end
      end
      
      def parse_substitutions(translate_text)
        # pull out all the string substitutions so that google doesn't translate those
        pattern = /\{\{.+?\}\}/ # non greedy pattern match so that we properly match strings like: "{{name}} on {{application_name}}"
        replacements = translate_text.scan(pattern)
        translate_text.gsub!(pattern, SUBSTITUTION_PLACE_HOLDER)
        replacements
      end
      
    end
  end
end