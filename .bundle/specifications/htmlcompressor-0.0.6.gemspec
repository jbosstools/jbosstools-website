# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "htmlcompressor"
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paolo Chiodi"]
  s.date = "2013-04-19"
  s.description = "Put your html on a diet"
  s.email = ["chiodi84@gmail.com"]
  s.homepage = ""
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "htmlcompressor provides a class and a rack middleware to minify html pages"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<yui-compressor>, ["~> 0.9.6"])
      s.add_development_dependency(%q<closure-compiler>, ["~> 1.1.5"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
    else
      s.add_dependency(%q<yui-compressor>, ["~> 0.9.6"])
      s.add_dependency(%q<closure-compiler>, ["~> 1.1.5"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
    end
  else
    s.add_dependency(%q<yui-compressor>, ["~> 0.9.6"])
    s.add_dependency(%q<closure-compiler>, ["~> 1.1.5"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
  end
end
