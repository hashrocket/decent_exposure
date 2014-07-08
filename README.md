# Adequate Exposure
[![Gem Version](https://img.shields.io/gem/v/adequate_exposure.svg)](https://rubygems.org/gems/adequate_exposure)
[![Build Status](https://img.shields.io/travis/rwz/adequate_exposure.svg)](http://travis-ci.org/rwz/adequate_exposure)
[![Code Climate](https://img.shields.io/codeclimate/github/rwz/adequate_exposure.svg)](https://codeclimate.com/github/rwz/adequate_exposure)

Exposing things, adequately.

Adequate exposure is a lightweight alternative to [Decent
Exposure](https://github.com/voxdolo/decent_exposure). With its narrowly
focused api you can get exactly what you need without all the extra dressing.

*Note: It is not the intent of the author to imply that Decent Exposure is
inadequate.*

Installation is as simple as: `$ gem install adequate_exposure`. Once you have
that down we can start talking about the API.

## API

The whole API consists of two methods so far: `expose` and `expose!`.

In the simplest scenario you'll just use it to expose a model in the
controller:

```ruby
class ThingsController < ApplicationController
  expose :thing
end
```

Now every time you call `thing` in your controller or view, it'll look for an
ID and try to perform `Thing.find(id)`. If the ID isn't found, it'll call
`Thing.new(things_params)`. The result will be memoized in an `@exposed_thing`
instance variable.

The default resolving workflow if pretty powerful and customizable. It could be
expressed with the following pseudocode:

```ruby
def fetch(scope, id)
  instance = id ? find(id, scope) : build(build_params, scope)
  decorate(instance)
end

def id
  params[:thing_id] || params[:id]
end

def find(id, scope)
  scope.find(id)
end

def build(params, scope)
  scope.new(params) # Thing.new(params)
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

The exposure is also lazy, which means that it won't do anything until you call
the method. To eliminate this lazyness you can use `expose!` macro instead,
which will try to resolve the exposure in a before filter.

Each step could be overrided with options. The acceptable options to the
`expose` macro are:

### `fetch`

This is the entry point. The `fetch` proc defines how to resolve your exposure
in the first place.

```ruby
expose :thing, fetch: ->{ get_thing_some_way_or_another }
```

Because the above behavior overrides the normal workflow, all other options
would be ignored. However, Adequate Exposure is decent enough to actually blow
up with an error so you don't accidentally do this.

There are other less verbose ways to pass the `fetch` block, since you'll
probably be using it often:

```ruby
expose(:thing){ get_thing_some_way_or_another }
```

Or if you (like me) absolutely hate parens in side-effect methods:

```ruby
expose :thing, ->{ get_thing_some_way_or_another }
```

There is another shortcut that allows you to redefine entire fetch block with
less code:

```ruby
expose :comments, from: :post
# equivalent to 
expose :comments, ->{ post.comments }
```

### `id`

The default fetch logic relies on the presence of an ID. And of course Adequate
Exposure allows to to specify how exactly you want the ID to be extracted.

Default behavior could be expressed using following code:

```ruby
expose :thing, id: ->{ params[:thing_id] || params[:id] }
```

But nothing is stopping you from throwing in any arbitrary code:

```ruby
# id is always gonna be the answer to ultimate question of life, the universe,
# and everyting
expose :thing, id: ->{ 42 }
```

Passing lambdas might not always be fun, so here are couple shortcuts that could
help making life easier.

```ruby
# equivalent to id: ->{ params[:custom_thing_id] }
expose :thing, id: :custom_thing_id

# equivalent to id: ->{ params[:try_this_id] || params[:or_maybe_that_id] }
expose :thing, id: [:try_this_id, :or_maybe_that_id]
```

### `find`

If an ID was provided, Adequate Exposure will try to find the model using it.
Default behavior could be expressed with this configuration: 

```ruby
expose :thing, find: ->(id, scope){ scope.find(id) }
```

Where `scope` is a model scope, like `Thing` or `User.active` or
`Post.published`.

Now, if you're using FriendlyId or Stringex or something similar, you'd have to
customize your finding logic. You code might look somewhat like this:

```ruby
expose :thing, find: ->(id, scope){ scope.find_by!(slug: id) }
```

Again, because this is likely to happen a lot, Adequate Exposure gives you a
decent shortcut so you can get more done by typing less.

```ruby
expose :thing, find_by: :slug
```

### `build`

When an ID is not present, Adequate Exposure tries to build an object for you. By
default, it behaves like this:

```ruby
expose :thing, build: ->(thing_params, scope){ scope.new(thing_params) }
```

### `scope`

Defines the scope that's used in `find` and `build` steps.

```ruby
expose :thing, scope: ->{ current_user.things }
expose :user, scope: ->{ User.active }
expose :post, scope: ->{ Post.published }
```

Like before, shortcuts are there to make you happier:

```ruby
expose :post, scope: :published
# fully equivalent to
expose :post, scope: ->{ Post.published }
```

and

```ruby
expose :thing, parent: :current_user
# fully equivalent to:
expose :thing, scope: ->{ current_user.things }
```

### `model`

Allows to specify the model class to use. Pretty straightforward.

```ruby
expose :thing, model: ->{ AnotherThing }
expose :thing, model: AnotherThing
expose :thing, model: "AnotherThing"
expose :thing, model: :another_thing
```

### `decorate`

Before returning the thing, Adequate Exposure will run it through the
decoration process. Initially, this does nothing, but you can obviously change
that:

```ruby
expose :thing, decorate: ->(thing){ ThingDecorator.new(thing) }
```

## Contributing

1. Fork it (https://github.com/rwz/adequate_exposure/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
