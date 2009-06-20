Gem::Specification.new do |spec|
  spec.name = "clickclient_scrap"
  spec.version = "0.1.4"
  spec.summary = "click securities client library for ruby."
  spec.author = "Masaya Yamauchi"
  spec.email = "y-masaya@red.hot.co.jp"
  spec.homepage = "http://github.com/unageanu/clickclient_scrap/tree/master"
  spec.files = [
    "README",
    "ChangeLog",
    "lib/clickclient_scrap.rb",
    "lib/jiji_plugin.rb",
    "test/test_FxSession.rb",
    "test/test_jiji_plugin.rb"
  ]
  spec.test_files = [
     "test/test_FxSession.rb",
     "test/test_jiji_plugin.rb"
  ]
  spec.has_rdoc = true
  spec.rdoc_options << "--main" << "README"
  spec.add_dependency('mechanize', '= 0.9.0')
  spec.extra_rdoc_files = ["README"]
end
