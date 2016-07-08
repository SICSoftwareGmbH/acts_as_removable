# acts_as_removable

This gem allows you to easily manage ActiveRecord objects that are pseudo destroyed a.k.a. removed.

## Installation

Add this line to your application's Gemfile:

    gem 'acts_as_removable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_as_removable

## Usage

```ruby
# a column removed_at of type timestamp is required
class MyModel < ActiveRecord::Base
  acts_as_removable
end

record = MyModel.create
record.removed? # => false
record.remove
record.removed? # => true
```

You can also specify the column to use:
```ruby
class MyModel < ActiveRecord::Base
  acts_as_removable column_name: :some_column
end
```

And you can use callbacks:
```ruby
class MyModel < ActiveRecord::Base
  acts_as_removable

  before_remove do |r|
    puts "Before removing record"
  end

  after_remove :after_remove_method
  def after_remove_method
    puts "After removing record"
  end

  before_unremove do |r|
    puts "Before unremoving record"
  end

  after_unremove :after_unremove_method
  def after_unremove_method
    puts "After unremoving record"
  end
end
```

## Code Status

* [![Build Status](https://api.travis-ci.org/SICSoftwareGmbH/acts_as_removable.png)](https://travis-ci.org/SICSoftwareGmbH/acts_as_removable)
* [![Dependencies](https://gemnasium.com/SICSoftwareGmbH/acts_as_removable.png?travis)](https://gemnasium.com/SICSoftwareGmbH/acts_as_removable)
* [![Code Climate](https://codeclimate.com/github/SICSoftwareGmbH/acts_as_removable.png)](https://codeclimate.com/github/SICSoftwareGmbH/acts_as_removable)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
