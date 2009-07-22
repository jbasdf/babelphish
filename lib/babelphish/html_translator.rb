module Babelphish
  module HtmlTranslator

    class << self
      
      # Translates all files in the given path from the language 
      # specififed by 'translate_from' into the languages in 'translate_tos'.
      # Translations that already exist will not be overwritten unless overwrite = true
      def translate(path, translate_tos, translate_from = 'en', overwrite = false)
        @path = path
        if !Babelphish::GoogleTranslate::LANGUAGES.include?(translate_from)
          STDERR.puts "#{translate_from} is not one of the available languages."
          return
        end
        if !File.exists?(path)
          STDERR.puts "#{path} does not exist."
          return
        end
        translate_and_write_pages(path, translate_tos, translate_from, overwrite)        
      end

      def translate_and_write_pages(path, tos, from, overwrite)
        Dir.glob("#{path}/*").each do |next_file|
          if File.directory?(next_file)
            translate_and_write_pages(next_file, language)
          else
            translate_and_write_page(next_file, tos, from, overwrite)
          end
        end
      end

      # Translate a single page from the language specified in 'from'
      # into the languages specified by 'tos'
      def translate_and_write_page(source_page, tos, from, overwrite)
        if File.exist?(source_page)
          STDERR.puts "Translating: #{source_page}"
        else
          STDERR.puts "Could not find file: #{source_page}"
          return
        end
        
        if !translate_file?(source_page)
          STDERR.puts "Not translating file: #{source_page}"
          return
        end
        
        text = IO.read(source_page)
        
        begins_with_html = text['<html>']
        
        # Pull out all the code blocks so Google doesn't mess with those
        pattern = /\<\%.+\%\>/
        holder = '{{---}}'
        replacements = text.scan(pattern)
        text.gsub!(pattern, holder)
        
        # Pull out all the new lines so Google doesn't mess with those
        pattern = /\n/
        newline_holder = '<brr />'
        newline_replacements = text.scan(pattern)
        text.gsub!(pattern, newline_holder)
        
        # Send to Google for translations
        translations = Babelphish::Translator.multiple_translate(text, tos, from)
        
        # Put the code back
        translations.each_key do |locale|
          replacements.each do |r|
            translations[locale].sub!(holder, r)
          end
        end

        # Put the newlines back in
        translations.each_key do |locale|
          newline_replacements.each do |r|
            translations[locale].sub!(newline_holder, r)
            if translations[locale]['<html>']
              # Google translate can insert '<html>' at the beginning of the result.  Remove it.
              translations[locale]['<html>']= '' unless begins_with_html
            end
          end
        end
        
        # Write the new file
        translations.each_key do |locale|
          translated_filename = get_translated_file(source_page, locale)
          if (locale != from) && (overwrite || !File.exists?(translated_filename))
            File.open(translated_filename, 'w') { |f| f.write(translations[locale]) }
          end
        end

      end

      # Generate a file name for the newly translated content
      def get_translated_file(page, to)
        new_page = page.gsub('.html', ".#{to}.html")
        new_page.gsub!('text.html', "text.#{to}.html")
        new_page.gsub!('text.plain', "text.#{to}.plain")
        new_page
      end
      
      # This is a hack but all the translated files live in the same directory
      # as the original file so we have to have some way of not translating the 
      # translated files.
      # this should return true for 
      # test.html.erb, test.text.html.erb and test.text.plain.erb
      # and false for
      # test.es.html.erb, test.text.es.html.erb and test.text.es.plain.erb
      def translate_file?(page)
        test = page
        test = test.gsub('./', '') if page[0..1] == './'
        test = test.gsub('.text.html.erb', '')
        test = test.gsub('.text.plain.erb', '')
        test = test.gsub('.html.erb', '')
        test.split('.').length == 1
      end
      
    end
  end
end