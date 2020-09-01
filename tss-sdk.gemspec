Gem::Specification.new do |s|
  s.name        = 'tss-sdk'
  s.version     = '0.0.1'
  s.date        = '2020-04-08'
  s.summary     = "tss-sdk"
  s.description = "The Thycotic TSS SDK for Ruby"
  s.authors     = ["John Poulin"]
  s.email       = 'john.m.poulin@gmail.com'
  s.files       = [
    "lib/tss.rb",
    "lib/tss/secret.rb"
  ]
  s.homepage    =
    'https://github.com/thycotic/tss-sdk-ruby'
  s.license       = 'Apache-2.0'

  s.add_dependency 'faraday'
  s.add_dependency 'logger'
  s.add_dependency 'json'
  s.add_development_dependency 'rspec', '~> 3.7'
end