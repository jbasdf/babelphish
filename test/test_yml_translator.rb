require File.dirname(__FILE__) + '/test_helper.rb'

class TestYmlTranslator < Test::Unit::TestCase
  
  def test_single_yml_translation
    Babelphish.set_settings(nil) # Make sure the .babelphish.yml settings are used
    overwrite = true
    translate_to = 'es'
    yml = File.join(File.dirname(__FILE__), 'translations', 'en.yml')
    Babelphish::YmlTranslator.translate(yml, overwrite, translate_to)
    translated_yml = File.join(File.dirname(__FILE__), 'translations', "#{translate_to}.yml")
    translation = YAML.load_file(translated_yml)
    assert translation['es']
    assert translation['es']['babelphish']
    assert_equal "Se trata de un nivel inferior", translation['es']['babelphish']['more']['test_more']
    assert_equal "Esta es una cadena de prueba", translation['es']['babelphish']['test']
    assert_equal "Esto es una cadena con incrustación {{insert}}", translation['es']['babelphish']['test_embedded']
  end
  
  def test_multiple_yml_translation
    Babelphish.set_settings(nil) # Make sure the .babelphish.yml settings are used
    overwrite = true
    yml = File.join(File.dirname(__FILE__), 'translations', 'en.yml')
    tos = ['es']
    Babelphish::YmlTranslator.translate(yml, overwrite, nil, tos)
    tos.each do |to|
      translated_yml = File.join(File.dirname(__FILE__), 'translations', "#{to}.yml")
      translation = YAML.load_file(translated_yml)
      assert translation[to]
      assert translation[to]['babelphish']['test_embedded'].include?("{{insert}}")
    end
  end
  
  
  # run same tests with v1 of the api
  def test_single_yml_translation_v1
    Babelphish.set_settings({"api_key"=>"", "version"=>"v1"})
    overwrite = true
    translate_to = 'es'
    yml = File.join(File.dirname(__FILE__), 'translations', 'en.yml')
    Babelphish::YmlTranslator.translate(yml, overwrite, translate_to)
    translated_yml = File.join(File.dirname(__FILE__), 'translations', "#{translate_to}.yml")
    translation = YAML.load_file(translated_yml)
    assert translation['es']
    assert translation['es']['babelphish']
    assert_equal "Se trata de un nivel inferior", translation['es']['babelphish']['more']['test_more']
    assert_equal "Esta es una cadena de prueba", translation['es']['babelphish']['test']
    assert_equal "Esto es una cadena con incrustación {{insert}}", translation['es']['babelphish']['test_embedded']
  end
  
  def test_multiple_yml_translation_v1
    Babelphish.set_settings({"api_key"=>"", "version"=>"v1"})
    overwrite = true
    yml = File.join(File.dirname(__FILE__), 'translations', 'en.yml')
    tos = ['es']
    Babelphish::YmlTranslator.translate(yml, overwrite, nil, tos)
    tos.each do |to|
      translated_yml = File.join(File.dirname(__FILE__), 'translations', "#{to}.yml")
      translation = YAML.load_file(translated_yml)
      assert translation[to]
      assert translation[to]['babelphish']['test_embedded'].include?("{{insert}}")
    end
  end
  
end
