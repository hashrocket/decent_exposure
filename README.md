## NOTICE OF WORK IN PROGRESS

This README represents planned functionality. Much of it is implemented. Still
more is yet to be implemented. We've endeavored to note where the functionality
has yet to be implemented by tagging it ***#NOTIMPLEMENTED*** and indicating
different ways of achieving the same effect where possible.

## Mad Decent

Rails controllers are the sweaty armpit of every rails app. This is due, in
large part, to the fact that they expose their instance variables directly to
their views. This means that your instance variables are your interface... and
that you've broken encapsulation. Instance variables are meant to be private,
for Science's sake!

What `decent_exposure` proposes is that you go from this:

```ruby
class Controller
  def new
    @person = Person.new(params[:person])
  end

  def create
    @person = Person.new(params[:person])
    if @person.save
      redirect_to(@person)
    else
      render :new
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
    if @person.update_attributes(params[:person])
      redirect_to(@person)
    else
      render :edit
    end
  end
end
```

To something like this:

```ruby
class Controller
  expose(:person)

  def create
    if person.save
      redirect_to(person)
    else
      render :new
    end
  end

  def update
    if person.save
      redirect_to(person)
    else
      render :edit
    end
  end
end
```

`decent_exposure` makes it easy to define named methods that are made available
to your views and which memoize the resultant values. It also tucks away the
details of the common fetching, initializing and updating of resources and
their parameters.

That's neat and all, but the real advantage comes when it's time to refactor
(because you've encapsulated now). What happens when you need to scope your
`Person` resource from a `Company`? Which implementation isolates those changes
better? In that particular example, `decent_exposure` goes one step farther and
will handle the scoping for you (with a smidge of configuration) while still
handling all that repetitive initialization, as we'll see next.

Even if you decide not to use `decent_exposure`, do yourself a favor and stop
using instance variables in your views. Your code will be cleaner and easier to
refactor as a result. If you want to learn more about his approach, I've
expanded on my thoughts in the article [A Diatribe on Maintaining State][1].

## Environmental Awareness

Well, no it won't lessen your carbon footprint, but it does take a lot of
queues from what's going on around it...

`decent_exposure` will build the requested object in one of a couple of ways
depending on what the `params` make available to it. At its simplest, when an
`id` is present in the `params` hash, `decent_exposure` will attempt to find a
record. In absence of `params[:id]` `decent_exposure` will try to build a new
record.

Once the object has been obtained, it attempts to set the attributes of the
resulting object. Thus, a newly minted `person` instance will get any
attributes set that've been passed along in `params[:person]`.  When you
interact with `person` in your create action, just call save on it and handle
the valid/invalid branch. Let's revisit our previous example:

```ruby
class Controller
  expose(:person)

  def create
    if person.save
      redirect_to(person)
    else
      render :new
    end
  end
end
```

Behind the scenes, `decent_exposure` has essentially done this:

```ruby
person.attributes = params[:person]
```

In Rails, this assignment is actually a merge with the current attributes and
it marks attributes as dirty as you would expect. This is why you're simply
able to call `save` on the `person` instance in the create action, rather than
the typical `update_attributes(params[:person])`.

**An Aside**

Did you notice there's no `new` action? Yeah, that's because we don't need it.
More often than not actions that respond to `GET` requests are just setting up
state. Since we've declared an interface to our state and made it available to
the view (a.k.a. the place where we actually want to access it), we just let
Rails do it's magic and render the `new` view, lazily evaluating `person` when
we actually need it.

**A Caveat**

Rails conveniently responds with a 404 if you get a record not found in the
controller. Since we don't find the object until we're in the view in this
paradigm, we get an ugly `ActionView::TemplateError` instead. If this is
problematic for you, consider using the `expose!` (`expose!` is ***#NOTIMPLEMENTED***,
instead use a `before_filter` to call the exposed method and eagerly evaluate)
method to circumvent lazy evaluation and eagerly evaluate whilst still in the
controller.

## Usage

In an effort to make the examples below a bit less magical, we'll offer a
simplified explanation for how the exposed resource would be queried for
(assuming you are using `ActiveRecord`).

### Obtaining an instance of an object:

```ruby
expose(:person)
```

**Query Explanation**

<table>
  <tr>
    <td><code>id</code> present?</td>
    <td>Query</td>
  </tr>
  <tr>
    <td><code>true</code></td>
    <td><code>Person.find(params[:id])</code></td>
  </tr>
  <tr>
    <td><code>false</code></td>
    <td><code>Person.new(params[:person])</code></td>
  </tr>
</table>

### Obtaining a collection of objects (***#NOTIMPLEMENTED***):

```ruby
expose(:people)
```

**Query Explanation**

<table>
  <tr>
    <td>Query</td>
  </tr>
  <tr>
    <td><code>Person.scoped</code></td>
  </tr>
</table>

### Scoping your object queries

Want to scope your queries to ensure object hierarchy? `decent_exposure`
automatically scopes singular forms of a resource from a plural form where
they're defined:

```ruby
expose(:people)
expose(:person)
```

**Query Explanation**

<table>
  <tr>
    <td><code>id</code> present?</td>
    <td>Query</td>
  </tr>
  <tr>
    <td><code>true</code></td>
    <td><code>Person.scoped.find(params[:id])</code></td>
  </tr>
  <tr>
    <td><code>false</code></td>
    <td><code>Person.scoped.new(params[:person])</code></td>
  </tr>
</table>

How about a more realistic scenario where the object hierarchy specifies
something useful, like only finding people in a given company (the `scope:`
configuration option is ***#NOTIMPLEMENTED***, pass a block instead):

```ruby
expose(:company)
expose(:people, scope: :company)
expose(:person)
```

**Query Explanation**

<table>
  <tr>
    <td>person <code>id</code> present?</td>
    <td>Query</td>
  </tr>
  <tr>
    <td><code>true</code></td>
    <td><code>Company.find(params[:company_id]).people.find(params[:id])</code></td>
  </tr>
  <tr>
    <td><code>false</code></td>
    <td><code>Company.find(params[:company_id]).people.new(params[:person])</code></td>
  </tr>
</table>

### Further configuration

`decent_exposure` is a configurable beast. Let's take a look at some of the
things you can do:

**Specify the model name (***#NOTIMPLEMENTED***, use a custom strategy):**

```ruby
expose(:company, model: :enterprisey_company)
```

**Specify the finder method (***#NOTIMPLEMENTED***, use a custom strategy):**

```ruby
expose(:company, finder: :find_by_slug)
```

**Specify the parameter accessor (***#NOTIMPLEMENTED***, use a custom strategy):**

```ruby
expose(:company, params: :company_params)
```

### Getting your hands dirty

While we try to make things as easy for you as possible, sometimes you just
need to go off the beaten path. For those times, `expose` takes a block which
it lazily evaluates and returns the result of when called. So for instance:

```ruby
expose(:environment) { Rails.env }
```

This block is evaluated and the memoized result is returned whenever you call
`environment`.

### Custom strategies

For the times when custom behavior is needed for resource finding,
`decent_exposure` provides a base class for extending. For example, if
scoping a resource from `current_user` is not and option, but you'd like
to verify a resource's relationship to the `current_user`, you can use a
custom strategy like the following:

```ruby
class VerifiableStrategy < DecentExposure::Strategy
  delegate :current_user, :to => :controller

  def resource
    instance = model.find(params[:id])
    if current_user != instance.user
      raise ActiveRecord::RecordNotFound
    end
    instance
  end
end
```

You would then use your custom strategy in your controller:

```ruby
expose(:post, strategy: VerifiableStrategy)
```

The API only necessitates you to define `resource`, but provides some
common helpers to access common things, such as the `params` hash. For
everything else, you can delegate to `controller`, which is the same as
`self` in the context of a normal controller action.

### Customizing your exposures (***#NOTIMPLEMENTED***, use a custom strategy)

For most things, you'll be able to pass a few configuration options and get
the desired behavior. For changes you want to affect every call to `expose` in
a controller or controllers inheriting from it (e.g. `ApplicationController`,
if you need to change the behavior for all your controllers), you can define
an `exposure` configuration block:

```ruby
exposure(:example) do
  orm :mem_cache
  model { Thing }
  finder :find_by_thing
  scope { model.scoped.further }
end
```

If you only want to use that exposure in one call to `expose`, you can do so
like this:

```ruby
expose(:foo, exposure: :example)
```

[1]: http://blog.voxdolo.me/a-diatribe-on-maintaining-state.html
