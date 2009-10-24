# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{livecode}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Inge J\303\270rgensen"]
  s.date = %q{2009-10-24}
  s.default_executable = %q{livecode}
  s.description = %q{A toolkit for livecoding using Ruby and TextMate on OSX}
  s.email = %q{inge@elektronaut.no}
  s.executables = ["livecode"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/livecode",
     "ext/coremidi.c",
     "ext/extconf.rb",
     "extras/textmate/Ruby Livecode.tmbundle/Commands/Execute Document.tmCommand",
     "extras/textmate/Ruby Livecode.tmbundle/Commands/Execute Selection:Line.tmCommand",
     "extras/textmate/Ruby Livecode.tmbundle/Commands/Execute Selection:Scope.tmCommand",
     "extras/textmate/Ruby Livecode.tmbundle/Commands/Start.tmCommand",
     "extras/textmate/Ruby Livecode.tmbundle/Commands/Stop.tmCommand",
     "extras/textmate/Ruby Livecode.tmbundle/Syntaxes/Ruby Livecode.tmLanguage",
     "extras/textmate/Ruby Livecode.tmbundle/info.plist",
     "lib/livecode.rb",
     "lib/livecode/clock.rb",
     "lib/livecode/clock_recipients.rb",
     "lib/livecode/delay.rb",
     "lib/livecode/extensions/main.rb",
     "lib/livecode/extensions/numeric.rb",
     "lib/livecode/extensions/object.rb",
     "lib/livecode/extensions/string.rb",
     "lib/livecode/loader.rb",
     "lib/livecode/midi.rb",
     "lib/livecode/midi/client.rb",
     "lib/livecode/midi/coremidi.rb",
     "lib/livecode/silenceable.rb",
     "lib/livecode/timer.rb",
     "lib/livecode_server.rb",
     "lib/livecode_server/client.rb",
     "lib/livecode_server/command.rb",
     "lib/livecode_server/daemon.rb",
     "lib/livecode_server/scope.rb",
     "livecode.gemspec",
     "test/helper.rb",
     "test/test_livecode_server.rb"
  ]
  s.homepage = %q{http://github.com/elektronaut/livecode}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{OSX livecoding toolkit}
  s.test_files = [
    "test/helper.rb",
     "test/test_livecode_server.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<daemons>, [">= 0"])
    else
      s.add_dependency(%q<daemons>, [">= 0"])
    end
  else
    s.add_dependency(%q<daemons>, [">= 0"])
  end
end

