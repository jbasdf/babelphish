desc "Translate files via Google Translate."
task :babelphish do
  require 'babelphish/translator'
  options={}
  yml = ENV['yml']
  html = ENV['html']
  language = ENV['language']
  overwrite = ENV['overwrite'] == 'yes'
  translate_to = ENV['translate_to'] || nil
  translate_tos = ENV['translate_tos'] || nil
  
  if yml
    STDERR.puts "Translating #{yml}"
    translate_tos ||= Babelphish::GoogleTranslate::LANGUAGES
    Babelphish::YmlTranslator.translate(yml, overwrite, translate_to, translate_tos)
  elsif html
    if language.nil?
      STDERR.puts "No source language specified when using 'html' option.  Defaulting to 'en'"
      language = 'en'
    end
    STDERR.puts "Translating files in #{html}"
    translate_tos ||= Babelphish::GoogleTranslate::LANGUAGES
    Babelphish::HtmlTranslator.translate(html, translate_tos, language, overwrite)
  else
    STDERR.puts "Please specify the directory where your files live. i.e. babelphish -y ./my/locales  or babelphish -h ./some/directory/with/erb_or_html/files"
  end
  
end