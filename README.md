# tss-sdk-ruby

![Tests](https://github.com/thycotic/tss-sdk-ruby/workflows/Tests/badge.svg)
![Documentation](https://github.com/thycotic/tss-sdk-ruby/workflows/Documentation/badge.svg)
![RubyGems](https://github.com/thycotic/tss-sdk-ruby/workflows/RubyGems/badge.svg)
![GitHub](https://github.com/thycotic/tss-sdk-ruby/workflows/GitHub/badge.svg)

# Installation

# Usage

## Initialize via env variables (best practice)

Vault will initialize easily if the following environment variables are defined:

* `TSS_USERNAME`
* `TSS_PASSWORD`
* `TSS_TENANT`

```ruby
require 'vault'
# initialize from ENV variables
server = Server.new({
    username: ENV['TSS_USERNAME'].to_s,
    password: ENV['TSS_PASSWORD'],
    tenant: ENV['TSS_TENANT']
})

begin
    secret = Server::Secret.fetch(@server, 1)
rescue AccessDeniedException
    puts "Whoops, looks like we're unauthorized"
rescue  Exception => e
    puts "Something went wrong: #{e.to_s}"
end

puts "The password is: #{secret["data"]["password"]}"
```
