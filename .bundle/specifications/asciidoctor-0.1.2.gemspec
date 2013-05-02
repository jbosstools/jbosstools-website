# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "asciidoctor"
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Waldron", "Dan Allen", "Jeremy McAnally", "Jason Porter"]
  s.date = "2013-04-25"
  s.description = "An open source text processor and publishing toolchain, written entirely in Ruby, for converting AsciiDoc markup into HTML 5, DocBook 4.5 and other formats. \n"
  s.email = ["rew@erebor.com", "dan.j.allen@gmail.com"]
  s.executables = ["asciidoctor", "asciidoctor-safe"]
  s.extra_rdoc_files = ["LICENSE"]
  s.files = ["bin/asciidoctor", "bin/asciidoctor-safe", "LICENSE"]
  s.homepage = "http://asciidoctor.org"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "asciidoctor"
  s.rubygems_version = "1.8.24"
  s.summary = "A native Ruby AsciiDoc syntax processor and publishing toolchain"

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<coderay>, [">= 0"])
      s.add_development_dependency(%q<erubis>, [">= 0"])
      s.add_development_dependency(%q<htmlentities>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<nokogiri>, [">= 0"])
      s.add_development_dependency(%q<pending>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<tilt>, [">= 0"])
    else
      s.add_dependency(%q<coderay>, [">= 0"])
      s.add_dependency(%q<erubis>, [">= 0"])
      s.add_dependency(%q<htmlentities>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<pending>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<tilt>, [">= 0"])
    end
  else
    s.add_dependency(%q<coderay>, [">= 0"])
    s.add_dependency(%q<erubis>, [">= 0"])
    s.add_dependency(%q<htmlentities>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<pending>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<tilt>, [">= 0"])
  end
end
