lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chores_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'chores_kit'
  spec.version       = ChoresKit::VERSION
  spec.authors       = ['Lennard Timm']
  spec.email         = ['hi@lenn4rd.io']

  spec.summary       = 'An opinionated micro-framework for running tasks'
  spec.homepage      = 'https://github.com/lenn4rd/chores_kit'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_dependency 'as-duration', '~> 0.1.1'
  spec.add_dependency 'dag', '~> 0.0.9'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'byebug', '~> 10.0.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.53.0'
end
