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
  
  def test_single_yml_translation
    overwrite = true
    translate_to = 'es'
    yml = File.join(File.dirname(__FILE__), 'translations', 'en.yml')
    Babelphish::Translator.translate_yaml(yml, overwrite, translate_to)
    translated_yml = File.join(File.dirname(__FILE__), 'translations', "#{translate_to}.yml")
    translation = YAML.load_file(translated_yml)
    assert translation['es']
    assert translation['es']['babelphish']
    assert_equal "Este es un nivel más bajo", translation['es']['babelphish']['more']['test_more']
    assert_equal "Esto es una prueba de cadenas", translation['es']['babelphish']['test']
    assert_equal "Esta es una cadena con la incorporación {{insert}}", translation['es']['babelphish']['test_embedded']
  end
  
  def test_multiple_yml_translation
    overwrite = true
    yml = File.join(File.dirname(__FILE__), 'translations', 'en.yml')
    Babelphish::Translator.translate_yaml(yml, overwrite)
    Babelphish::GoogleTranslate::LANGUAGES.each do |to|
      translated_yml = File.join(File.dirname(__FILE__), 'translations', "#{to}.yml")
      translation = YAML.load_file(translated_yml)
      assert translation[to]
      assert translation[to]['babelphish']['test_embedded'].include?("{{insert}}")
    end
  end
  
end
