# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{babelphish}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Justin Ball"]
  s.date = %q{2009-07-13}
  s.default_executable = %q{babelphish}
  s.description = %q{Babelphish helps you make a quick translation of your application using Google Translate.}
  s.email = ["justinball@gmail.com"]
  s.executables = ["babelphish"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["LICENSE", "History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "bin/babelphish", "lib/babelphish.rb", "lib/babelphish/languages.rb", "lib/babelphish/translator.rb", "lib/babelphish/exceptions.rb", "lib/tasks/babelphish.rake", "script/console", "script/destroy", "script/generate", "test/test_babelphish.rb", "test/test_helper.rb", "test/test_html_translator.rb", "test/test_yml_translator.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jbasdf/babelphish}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{babelphish}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Translate with Google like a fule => 'fool'}
  s.test_files = ["test/test_babelphish.rb", "test/test_helper.rb", "test/test_html_translator.rb", "test/test_yml_translator.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ya2yaml>, [">= 0.26"])
      s.add_development_dependency(%q<newgem>, [">= 1.4.1"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<ya2yaml>, [">= 0.26"])
      s.add_dependency(%q<newgem>, [">= 1.4.1"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<ya2yaml>, [">= 0.26"])
    s.add_dependency(%q<newgem>, [">= 1.4.1"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
