
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "webview/version"

Gem::Specification.new do |spec|
  spec.name          = "webview"
  spec.version       = Webview::VERSION
  spec.authors       = ["jiangzhi.xie"]
  spec.email         = ["xiejiangzhi@gmail.com"]

  spec.summary       = %q{Ruby api for zserge/webview project}
  spec.description   = %q{Ruby api for zserge/webview project}
  spec.homepage      = "https://github.com/xiejiangzhi/webview"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.extensions    = ['ext/extconf.rb']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
