desc "Translate files via Google Translate."
task :babelphish do
  require 'babelphish/translator'
  options={}
#  directory = ENV['directory']
#  language = ENV['language'] || 'en'
  yml = ENV['yml']
  overwrite = ENV['overwrite'] || false
  
  if yml
    Babelphish::Translator.translate_yaml(yml, overwrite)
  else
    STDERR.puts "Please specify the directory where your files live. i.e. babelphish -d ./my/locales"
  end
  
end