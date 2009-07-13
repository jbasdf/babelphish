require File.dirname(__FILE__) + '/test_helper.rb'

class TestBabelphish < Test::Unit::TestCase

  def test_translate
    translation = Babelphish::Translator.translate('hello', 'es', 'en')
    assert_equal 'hola', translation
  end
  
  def test_run_each_language
    Babelphish::GoogleTranslate::LANGUAGES.each do |language|
      begin
        translation = Babelphish::Translator.translate('hello', language)
      rescue => ex
        puts "There was a problem translating to #{language}:  #{ex}"
      end
    end
  end
  
  def test_multiple_translate
    translations = Babelphish::Translator.multiple_translate('hello', Babelphish::GoogleTranslate::LANGUAGES, 'en')
    assert_equal 'hola', translations[Babelphish::GoogleTranslate::SPANISH]
    assert_equal 'hallo', translations[Babelphish::GoogleTranslate::GERMAN]
    assert_equal 'ciao', translations[Babelphish::GoogleTranslate::ITALIAN]
    assert_equal 'salut', translations[Babelphish::GoogleTranslate::ROMANIAN]
    assert_equal 'こんにちは', translations[Babelphish::GoogleTranslate::JAPANESE]
  end
  
  def test_detect_language    
    success, result = Babelphish::Translator.detect_language('hello world')
    assert success, "Failed to detect language"
    assert_equal Babelphish::GoogleTranslate::ENGLISH, result['language']
  end
  
  def test_supported_languages
    assert_equal Babelphish::Translator.supported_languages, Babelphish::GoogleTranslate::LANGUAGES
  end
  
end
