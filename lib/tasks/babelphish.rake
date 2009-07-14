desc "Translate files via Google Translate."
task :babelphish do
  require 'babelphish/translator'
  options={}
  yml = ENV['yml']
  html = ENV['html']
  language = ENV['language']
  overwrite = ENV['overwrite'] == 'yes'
  translate_to = ENV['translate_to'] || nil
  
  if yml
    STDERR.puts "Translating #{yml}"
    Babelphish::YmlTranslator.translate(yml, overwrite, translate_to)
  elsif html
    if language.nil?
      STDERR.puts "No source language specified when using 'html' option.  Defaulting to 'en'"
      language = 'en'
    end
    STDERR.puts "Translating files in #{html}"
    Babelphish::HtmlTranslator.translate(html, Babelphish::GoogleTranslate::LANGUAGES, language, overwrite)
  else
    STDERR.puts "Please specify the directory where your files live. i.e. babelphish -y ./my/locales  or babelphish -h ./some/directory/with/erb_or_html/files"
  end
  
end