Gem::Specification.new do |s|
  s.name        = 'tss-sdk'
  s.version     = '0.0.0'
  s.date        = '2020-04-08'
  s.summary     = "tss-sdk"
  s.description = "The Thycotic TSS SDK for Ruby"
  s.authors     = ["John Poulin"]
  s.email       = 'john.m.poulin@gmail.com'
  s.files       = [
    "lib/server.rb",
    "lib/server/server.rb",
    "lib/server/secret.rb"
  ]
  s.homepage    =
    'https://rubygems.org/gems/hola'
  s.license       = 'Apache-2.0'

  s.add_development_dependency 'rspec', '~> 3.7'
end