# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{shorturl}
  s.version = "0.8.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Robby Russell"]
  s.autorequire = %q{shorturl}
  s.date = %q{2009-10-09}
  s.default_executable = %q{shorturl}
  s.email = %q{robby@planetargon.com}
  s.executables = ["shorturl"]
  s.extra_rdoc_files = ["README", "TODO", "MIT-LICENSE", "ChangeLog"]
  s.files = ["bin/shorturl", "lib/shorturl.rb", "doc/classes/InvalidService.html", "doc/classes/Service.html", "doc/classes/Service.src/M000003.html", "doc/classes/Service.src/M000004.html", "doc/classes/ShortURL.html", "doc/classes/ShortURL.src/M000001.html", "doc/classes/ShortURL.src/M000002.html", "doc/created.rid", "doc/files/ChangeLog.html", "doc/files/lib/shorturl_rb.html", "doc/files/MIT-LICENSE.html", "doc/files/README.html", "doc/files/TODO.html", "doc/fr_class_index.html", "doc/fr_file_index.html", "doc/fr_method_index.html", "doc/index.html", "doc/rdoc-style.css", "test/tc_service.rb", "test/tc_shorturl.rb", "test/ts_all.rb", "examples/shorten.rb", "README", "TODO", "MIT-LICENSE", "ChangeLog"]
  s.homepage = %q{http://github.com/robbyrussell/shorturl/}
  s.rdoc_options = ["--title", "ShortURL Documentation", "--main", "README", "-S", "-N", "--all"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Shortens URLs using services such as RubyURL, urlTea, bit.ly, moourl.com, and TinyURL}
  s.test_files = ["test/ts_all.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
