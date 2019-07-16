
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "xconsul/version"

Gem::Specification.new do |spec|
  spec.name          = "xconsul"
  spec.version       = Xconsul::VERSION
  spec.authors       = ["wangzc"]
  spec.email         = ["zhchsf@gmail.com"]

  spec.summary       = %q{consul 获取hosts + 负载均衡}
  spec.description   = %q{通过consul服务获取指定服务hosts，并且使用简单的负载均衡策略，返回一个host:port}
  spec.homepage      = "http://www.yimeijian.cn"
  spec.license       = "private"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'diplomat', '~> 2.2.5'

  spec.add_development_dependency "bundler", "> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'timecop'
end
