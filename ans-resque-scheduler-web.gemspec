# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ans/resque/scheduler/web/version'

Gem::Specification.new do |spec|
  spec.name          = "ans-resque-scheduler-web"
  spec.version       = Ans::Resque::Scheduler::Web::VERSION
  spec.authors       = ["sakai shunsuke"]
  spec.email         = ["sakai@ans-web.co.jp"]
  spec.description   = %q{resque-scheduler 用の動的スケジュール変更 web 画面を提供する}
  spec.summary       = %q{resque-scheduler 用スケジュール変更 web}
  spec.homepage      = "https://github.com/perfect-freeze/ans-resque-scheduler-web"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
