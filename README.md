# Adequate Exposure
[![Gem Version](https://img.shields.io/gem/v/adequate_exposure.svg)](https://rubygems.org/gems/adequate_exposure)
[![Build Status](https://img.shields.io/travis/rwz/adequate_exposure.svg)](http://travis-ci.org/rwz/adequate_exposure)
[![Code Climate](https://img.shields.io/codeclimate/github/rwz/adequate_exposure.svg)](https://codeclimate.com/github/rwz/adequate_exposure)

This is WIP. Please don't send pull requests yet, I'm still actively rewriting things.

Exposing things, adequately.

Adequate exposure is a lightweight alternative to [Decent
Exposure](https://github.com/voxdolo/decent_exposure). With it's narrowly
focused api you can get exactly what you need without all the extra dressing.

*Note: It is not the intent of the author to imply that Decent Exposure is
inadequate.)*

Installation is as simple as: `$ gem install adequate_exposure`. Once you have
that down we can start talking about the API.

## API

The whole API consists of one `expose` method.

In the simplest scenario you'll just use it to expose a model in the
controller:

```ruby
class ThingsController < ApplicationController
  expose :thing
end
```

Now every time you call `thing` in your controller or view, it'll look for an
id and try to perform `Thing.find(id)` or `Thing.new` if the id is not found.
It'll also memoize the result in `@exposed_thing` instance variable.

The default resolving workflow if pretty powerful and customizable. It could be
expressed with the following pseudocode:

```ruby
def fetch(scope, id)
  instance = id ? find(id, scope) : build(scope)
  decorate(instance)
end

def id
  params[:id] || params[:thing_id]
end

def find(id, scope)
  scope.find(id) # Thing.find(id)
end

def build(scope)
  scope.new(build_params) # Thing.new(thing_params)
end

def scope
  model # Thing
end

def model
  exposure_name.classify.constantize # :thing -> Thing
end

def build_params
  if respond_to?(:thing_params, true) && !request.get?
    thing_params
  else
    {}
  end
end

def decorate(thing)
  thing
end
```

Each step could be overrided with options. The acceptable options to the
`expose` macro are:

**fetch**

This is the entry point. Fetch proc defines how to resolve your exposure in the
first place.

```ruby
expose :thing, fetch: ->{ get_thing_some_way_or_another }
```

**find**

Defines how to perform the finding. Could be useful if you don't want to use standard
Rails finder.

```ruby
expose :thing, find: ->(id, scope){ scope.find_by(slug: id) }
```

**build**

Allows to override the build process that takes place when id is not provided.

```ruby
expose :thing, build: ->(scope){ Thing.build_with_defaults }
```

**id**

Specifies how to extract id from parameters hash.

```ruby
# default
expose :thing, id: ->{ params[:thing_id] || params[:id] }

# id is always goona be 42
expose :thing, id: ->{ 42 }

# equivalent to id: ->{ params[:custom_thing_id] }
expose :thing, id: :custom_thing_id

# equivalent to id: ->{ params[:try_this_id] || params[:or_maybe_that_id] }
expose :thing, id: %i[try_this_id or_maybe_that_id]
```

**scope**

Defines the scope that's used in `find` and `build` steps.

```ruby
expose :thing, scope: ->{ current_user.things }
```

**model**

Specify the model class to use.

```ruby
expose :thing, model: ->{ AnotherThing }
expose :thing, model: AnotherThing
expose :thing, model: :another_thing
```


**decorate**

Allows to define a block that wraps an instance before it's returned. Useful for decorators.

```ruby
expose :thing, decorate: ->(thing){ ThingDecorator.new(thing) }
```

## Contributing

1. Fork it (https://github.com/rwz/adequate_exposure/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
