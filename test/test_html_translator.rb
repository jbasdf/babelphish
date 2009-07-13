require File.dirname(__FILE__) + '/test_helper.rb'

class TestHtmlTranslator < Test::Unit::TestCase

  def test_html_translation
    overwrite = true
    translate_from = 'en'
    directory = File.join(File.dirname(__FILE__), 'html_translations')
    Babelphish::HtmlTranslator.translate(directory, Babelphish::GoogleTranslate::LANGUAGES, translate_from, overwrite)
    Babelphish::GoogleTranslate::LANGUAGES.each do |to|
      if to != translate_from
        # This will make sure the file was created
        translated_html = File.join(File.dirname(__FILE__), 'html_translations', "test.#{to}.html.erb")
        text = IO.read(translated_html)
        # Make sure the translation didn't remove code
        assert text.include?("<%= 'Some ruby code' %>")
        assert text.include?('<%= "test something else #{variable}" %>')
      end
    end
  end
  
end