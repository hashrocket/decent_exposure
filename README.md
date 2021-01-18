![Decent Exposure](./doc/decent_exposure.png)

[![Gem Version](https://img.shields.io/gem/v/decent_exposure.svg)](https://rubygems.org/gems/decent_exposure)
[![Build Status](https://img.shields.io/github/workflow/status/hashrocket/decent_exposure/CI)](https://github.com/hashrocket/decent_exposure/actions?query=workflow%3ACI)

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'decent_exposure', '~> 3.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install decent_exposure

### API

The whole API consists of three methods so far: `expose`, `expose!`, and
`exposure_config`.

In the simplest scenario you'll just use it to expose a model in the
controller:

```ruby
class ThingsController < ApplicationController
  expose :thing
end
```

Now every time you call `thing` in your controller or view, it will look for an
ID and try to perform `Thing.find(id)`. If the ID isn't found, it will call
`Thing.new(thing_params)`. The result will be memoized in an `@exposed_thing`
instance variable.

#### Example Controller

Here's what a standard Rails 5 CRUD controller using Decent Exposure might look like:

```ruby
class ThingsController < ApplicationController
  expose :things, ->{ Thing.all }
  expose :thing

  def create
    if thing.save
      redirect_to thing_path(thing)
    else
      render :new
    end
  end

  def update
    if thing.update(thing_params)
      redirect_to thing_path(thing)
    else
      render :edit
    end
  end

  def destroy
    thing.destroy
    redirect_to things_path
  end

  private

  def thing_params
    params.require(:thing).permit(:foo, :bar)
  end
end
```

### Under the Hood

The default resolving workflow is pretty powerful and customizable. It could be
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
the method. To eliminate this laziness you can use the `expose!` macro instead,
which will try to resolve the exposure in a before filter.

It is possible to override each step with options. The acceptable options to the
`expose` macro are:

### `fetch`

This is the entry point. The `fetch` proc defines how to resolve your exposure
in the first place.

```ruby
expose :thing, fetch: ->{ get_thing_some_way_or_another }
```

Because the above behavior overrides the normal workflow, all other options
would be ignored. However, Decent Exposure is decent enough to actually blow
up with an error so you don't accidentally do this.

There are other less verbose ways to pass the `fetch` block, since you'll
probably be using it often:

```ruby
expose(:thing){ get_thing_some_way_or_another }
```

Or

```ruby
expose :thing, ->{ get_thing_some_way_or_another }
```

Or even shorter

```ruby
expose :thing, :get_thing_some_way_or_another
```

There is another shortcut that allows you to redefine the entire fetch block
with less code:

```ruby
expose :comments, from: :post
# equivalent to 
expose :comments, ->{ post.comments }
```

### `id`

The default fetch logic relies on the presence of an ID. And of course Decent
Exposure allows you to specify how exactly you want the ID to be extracted.

Default behavior could be expressed using following code:

```ruby
expose :thing, id: ->{ params[:thing_id] || params[:id] }
```

But nothing is stopping you from throwing in any arbitrary code:

```ruby
expose :thing, id: ->{ 42 }
```

Passing lambdas might not always be fun, so here are a couple of shortcuts that
could help make life easier.

```ruby
expose :thing, id: :custom_thing_id
# equivalent to
expose :thing, id: ->{ params[:custom_thing_id] }

expose :thing, id: [:try_this_id, :or_maybe_that_id]
# equivalent to
expose :thing, id: ->{ params[:try_this_id] || params[:or_maybe_that_id] }
```

### `find`

If an ID was provided, Decent Exposure will try to find the model using it.
Default behavior could be expressed with this configuration: 

```ruby
expose :thing, find: ->(id, scope){ scope.find(id) }
```

Where `scope` is a model scope, like `Thing` or `User.active` or
`Post.published`.

Now, if you're using FriendlyId or Stringex or something similar, you'd have to
customize your finding logic. Your code might look somewhat like this:

```ruby
expose :thing, find: ->(id, scope){ scope.find_by!(slug: id) }
```

Again, because this is likely to happen a lot, Decent Exposure gives you a
decent shortcut so you can get more done by typing less.

```ruby
expose :thing, find_by: :slug
```

### `build`

When an ID is not present, Decent Exposure tries to build an object for you.
By default, it behaves like this:

```ruby
expose :thing, build: ->(thing_params, scope){ scope.new(thing_params) }
```

### `build_params`

These options are responsible for calulating params before passing them to the
build step. The default behavior was modeled with Strong Parameters in mind and
is somewhat smart: it calls the `thing_params` controller method if it's
available and the request method is not `GET`. In all other cases it produces
an empty hash.

You can easily specify which controller method you want it to call instead of
`thing_params`, or just provide your own logic:

```ruby
expose :thing, build_params: :custom_thing_params
expose :other_thing, build_params: ->{ { foo: "bar" } }

private

def custom_thing_params
  # strong parameters stuff goes here
end
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
# equivalent to
expose :post, scope: ->{ Post.published }
```

and

```ruby
expose :thing, parent: :current_user
# equivalent to:
expose :thing, scope: ->{ current_user.things }
```

### `model`

Allows you to specify the model class to use. Pretty straightforward.

```ruby
expose :thing, model: ->{ AnotherThing }
expose :thing, model: AnotherThing
expose :thing, model: "AnotherThing"
expose :thing, model: :another_thing
```

### `decorate`

Before returning the thing, Decent Exposure will run it through the
decoration process. Initially, this does nothing, but you can obviously change
that:

```ruby
expose :things, ->{ Thing.all.map{ |thing| ThingDecorator.new(thing) } }
expose :thing, decorate: ->(thing){ ThingDecorator.new(thing) }
```

## `exposure_config`

You can pre-save some configuration with `exposure_config` method to reuse it
later.

```ruby
exposure_config :cool_find, find: ->{ very_cool_find_code }
exposure_config :cool_build, build: ->{ very_cool_build_code }

expose :thing, with: [:cool_find, :cool_build]
expose :another_thing, with: :cool_build
```

## Rails Mailers

Mailers and Controllers use the same decent_exposure dsl.

### Example Mailer

```ruby
class PostMailer < ApplicationMailer
  expose(:posts, -> { Post.last(10) })
  expose(:post)

  def top_posts
    @greeting = "Top Posts"
    mail to: "to@example.org"
  end

  def featured_post(id:)
    @greeting = "Featured Post"
    mail to: "to@example.org"
  end
end
```

## Rails Scaffold Templates

If you want to generate rails scaffold templates prepared for `decent_exposure` run:

```bash
rails generate decent_exposure:scaffold_templates [--template_engine erb|haml]
```

This will create the templates in your `lib/templates` folder.

Make sure you have configured your templates engine for generators in `config/application.rb`:

```ruby
# config/application.rb
config.generators do |g|
  g.template_engine :erb
end
```

Now you can run scaffold like:

```bash
rails generate scaffold post title description:text
```

## Contributing

1. Fork it (https://github.com/hashrocket/decent_exposure/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## About

[![Hashrocket logo](https://hashrocket.com/hashrocket_logo.svg)](https://hashrocket.com)

Decent Exposure is supported by the team at [Hashrocket](https://hashrocket.com), a multidisciplinary design & development consultancy. If you'd like to [work with us](https://hashrocket.com/contact) or [join our team](https://hashrocket.com/careers), don't hesitate to get in touch.
