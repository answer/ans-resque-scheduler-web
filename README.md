# Ans::Resque::Scheduler::Web

resque-scheduler のスケジュールを動的に変更する resque-server プラグイン

resque-web に分離したが、古い方の resque-server 用のプラグインになっているのは、新しい gem 用の resque-scheduler の画面がなかったから

## Installation

Add this line to your application's Gemfile:

    gem 'ans-resque-scheduler-web'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ans-resque-scheduler-web

## Usage

    # config/initializer/resque-scheduler.rb
    Resque::Scheduler.dynamic = true

resque-server の画面に Edit-Schedule タブが追加される  
そこで job name を打ち込んで編集、追加が可能

config/resque/schedule.yml に変更されたスケジュールが書き込まれる  
capistrano 等でリリースする際は、 config/resque を shared へリンクとして逃しておくこと

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
