begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "babelphish"
    gem.summary = "Translate with Google like a fule => 'fool'"
    gem.email = "justinball@gmail.com"
    gem.homepage = "http://github.com/jbasdf/babelphish"
    gem.description = "Babelphish helps you make a quick translation of your application using Google Translate."
    gem.authors = ["Justin Ball"]
    gem.rubyforge_project = "babelphish"
    gem.add_dependency "ya2yaml"
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end


# TODO get rcov working
begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.libs << 'lib'
    t.pattern = 'test/*_test.rb'
    t.verbose = true
#    t.output_dir = 'coverage'
#    t.rcov_opts << '--exclude "gems/*"'
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end