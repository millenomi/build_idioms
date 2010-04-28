require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s| 
  s.name = "BuildIdioms"
  s.version = "0.0.2"
  s.author = "Emanuele Vulcano"
  s.email = "me@infinite-labs.net"
  s.homepage = "http://infinite-labs.net/blog"
  s.platform = Gem::Platform::RUBY
  s.summary = "This is a library of 'build idioms', allowing Rakefiles to be easily written for a variety of targets -- webOS applications, Xcode builds, more."
  s.files = FileList["{bin,lib}/**/*"].to_a
  s.require_path = "lib"
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
  s.add_dependency("rake", ">= 0.8.4")
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end
