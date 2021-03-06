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

    # config/initializer/ans-resque-scheduler-web.rb
    Ans::Resque::Scheduler::Web.configure do |config|
      config.root = Rails.root.to_s
      config.schedules = {
        main: Rails.root.join("config/resque/schedule.yml"),
      }
    end

resque-server の画面に Edit-Schedule タブが追加される  
そこで job name を打ち込んで編集、追加が可能

スケジュール変更時、 `config.schedules` に列挙されたファイルが同期される  
スケジュールの同期は job 名によって行われ、 interval 設定を個別に行うことが可能  
個別の設定は cron と every のみ

`config.root` の設定は、 `config.schedules` に列挙したファイルのうち、どのパスが自分の物であるかを判定するもの  
間違った設定をした場合、変更時にスケジュールがリロードされない  
`config.schedules` に前方一致するものを指定すること

変更された場合、 `.reload` の接尾辞をつけて新しいファイルが生成される  
それぞれ、スケジュールを読み直す job を every: 1s で置いておき、 reload がついたファイルが存在する場合に読みなおす、という処理を書いておくことを想定している

capistrano 等でリリースする際は、 config/resque 等を shared へリンクとして逃しておくこと

## Spec

* Edit-Schedule 画面で job 名を入力すると  
  job が登録されている場合、編集  
  job が登録されていない場合、その名前で新規作成
* 新規作成時のデフォルトは  
  class: job 名  
  description: job の @description クラスインスタンス変数から取得 or job 名  
  queue: job の @queue クラスインスタンス変数が定義されている場合、省略可能
* クラスが適切にロードできない場合、例外が発生  
  MyJobClass を指定、だが実際のクラス名は MyJOBClass (JOB が全部大文字) とかの場合、例外  
* その他、指定できる項目は resque-scheduler の README を参照
* Reset ボタンを押すと、  
  新規作成の場合、デフォルトの内容にリセット  
  編集の場合、現在の設定値にリセット
* 編集の場合、 Remove-Confirm ボタンが表示  
  押すと、設定が空白になり、 Remove ボタンが表示  
  Remove-Confirm ボタンではなく、テキストエリアを空白にして Confirm 、でも Remove ボタンが表示
* Remove ボタンを押すと、スケジュールが削除

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
