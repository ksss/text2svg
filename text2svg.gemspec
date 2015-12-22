# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'text2svg/version'

Gem::Specification.new do |spec|
  spec.name          = 'text2svg'
  spec.version       = Text2svg::VERSION
  spec.authors       = ['ksss']
  spec.email         = ['co000ri@gmail.com']

  spec.summary       = 'Build svg path data from font file'
  spec.description   = 'Build svg path data from font file'
  spec.homepage      = 'https://github.com/ksss/text2svg'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'freetype', '>= 0.0.3'
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rgot'
end
