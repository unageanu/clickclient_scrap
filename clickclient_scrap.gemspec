Gem::Specification.new do |spec|
  spec.name = "clickclient_scrap"
  spec.version = "0.1.10"
  spec.summary = "click securities client library for ruby."
  spec.author = "Masaya Yamauchi"
  spec.email = "y-masaya@red.hot.co.jp"
  spec.homepage = "http://github.com/unageanu/clickclient_scrap/tree/master"
  spec.test_files = Dir.glob( "specs/**/*" )
  spec.files = [
    "README",
    "ChangeLog",
    "lib/clickclient_scrap.rb",
    "lib/jiji_plugin.rb"
  ] + spec.test_files + Dir.glob( "sample/**/*" )
  spec.has_rdoc = true
  spec.rdoc_options << "--main" << "README"
  spec.add_dependency('mechanize', '>= 0.9.3')
  spec.extra_rdoc_files = ["README"]
end
