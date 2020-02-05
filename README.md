# Xconsul

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/xconsul`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xconsul'
```

And then execute:

    $ bundle

## Usage

配置consul：
```ruby
# 统一配置consul，非必须（如果配置了acl此处就必须配置了，否则hosts取值会是空）
# 注意：consul配置会影响所有在同一项目的此gem配置，所有要求必须使用同一个consul集群
consul_config_options = {
  url: 'consul 地址，可以不传，Diplomat Gem会使用默认localhost:8500',
  config_options: {ssl: {version: :TLSv1_2}, headers: {"X-Consul-Token" => "xxxx"}
}
Xconsul.configure_consul_connection(consul_config_options)
```

使用consul动态服务：
```ruby
# 生成balancer，每个client gem自己维护一个balancer示例，后续都通过此示例调用
# cache_expired_seconds 暂时强制了必须5s以上
consul_service_options = {service_name: 'xxx', cache_expired_seconds: 60}
balance_options = {balance_algorithm: :round_robin} # 目前内部只有一种算法，此参数可以直接不传
balancer = Xconsul.gen_balancer(consul_service_options, balance_options)
# 获取host，如果没有可选host会raise异常
balancer.host
```

不使用consul，手工配置hosts，需要配置：use_fixed_hosts true & fixed_hosts:
```ruby
# 生成balancer，每个client gem自己维护一个balancer示例，后续都通过此示例调用
# cache_expired_seconds 暂时强制了必须5s以上
consul_service_options = {
  service_name: 'xxx', cache_expired_seconds: 60,
  use_fixed_hosts: true, fixed_hosts: ['10.10.116.249:8881', '10.10.116.249:8882']
}
balance_options = {balance_algorithm: :round_robin} # 目前内部只有一种算法，此参数可以直接不传
balancer = Xconsul.gen_balancer(consul_service_options, balance_options)
# 获取host，如果没有可选host会raise异常
balancer.host
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/xconsul. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Xconsul project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/xconsul/blob/master/CODE_OF_CONDUCT.md).
