desc "Translate files via Google Translate."
task :babelphish do
  require 'babelphish/translator'
  options={}
  yml = ENV['yml']
  overwrite = ENV['overwrite'] == 'yes'
  translate_to = ENV['translate_to'] || nil
  
  if yml
    Babelphish::Translator.translate_yaml(yml, overwrite, translate_to)
  else
    STDERR.puts "Please specify the directory where your files live. i.e. babelphish -d ./my/locales"
  end
  
end