## Environmental Awareness

Well, no it won't lessen your carbon footprint, but it does take a lot of
queues from what's going on around it...

`decent_exposure` will build the requested object in one of a couple of ways
depending on what the `params` (or your framework's equivalent) make available
to it. At its simplest, when an `id` is present in the `params` hash,
`decent_exposure` will attempt to find a record. In absence of `params[:id]`
`decent_exposure` will try to build a new record. Once the object has been
obtained, it attempts to set the attributes of the resulting object. So a
newly minted `person` instance will get any attributes set that've been passed
along in `params[:person]`.  When you interact with `person` in your create
action, just call save on it and handle the valid/invalid branch. e.g.:

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

Did you notice there's no `new` action? Yeah, that's because we don't need it.
More often than not actions that respond to `GET` requests are just setting up
state. Since we've declared an interface to our state and made it available to
the view (a.k.a. the place where we actually want to access it), we just let
Rails do it's magic and render the `new` view, lazily evaluating `person` when
we actually need it.

Caveat: Rails conveniently responds with a 404 if you get a record not found
in the controller. Since we don't find the object until we're in the view in
this paradigm, we get an ugly `ActionView::TemplateError` instead. If this is
problematic for you, consider using the `expose!` method to evaluate whilst
still in the controller.

## Usage

Obtaining an instance of an object:

    expose(:person)

| `person`   | Query Explanation             |
| new record | `Person.new(params[:person])` |
| existing   | `Person.find(params[:id])`    |

How about getting a collection of all of the Person objects in your system?

    expose(:people)

| Query Explanation |
| Person.scoped     |

### Scoping

Want to scope your queries to ensure object hierarchy? `decent_exposure`
automatically scopes singular forms of a resource from a plural form where
they're defined:

    expose(:people)
    expose(:person)

|            | Query Explanation                    |
| new record | `Person.scoped.new(params[:person])` |
| existing   | `Person.scoped.find(params[:id])`    |


How about a more realistic scenario where the object hierarchy specifies
something useful, like only finding people in a given company:

    expose(:company)
    expose(:people, scope: :company)
    expose(:person)

Now that same call to `person` yields the following query:

    Company.find(params[:company_id]).people.find(params[:id])

| `person`   | Query Explanation                                               |
| new record | `Company.find(params[:company_id]).people.new(params[:person])` |
| existing   | `Company.find(params[:company_id]).people.find(params[:id])`    |

### Taming your exposure

`decent_exposure` is a configurable beast. Let's take a look at some of the
things you can do:

Specify the model name:

    expose(:company, model: :enterprisey_company)

Specify the finder method:

    expose(:company, finder: :find_by_slug)

Specify the parameter accessor:

    expose(:company, params: :company_params)

### Getting your hands dirty

While we try to make things as easy for you as possible, sometimes you just
need to go off the beaten path. For those times, `expose` takes a block which
it lazily evaluates and returns the result of when called. So for instance:

    expose(:environment) { Rails.env }

Now houses the memoized result of that call to `Rails.env` that you can access
by calling `environment` anywhere in your controller or it's views.

### Custom exposures

For most things, you'll be able to pass a few configuration options and get
the desired behavior. For everything else, there's `decent_exposure`'s notion
of strategies:

    exposure(:example) do
      orm :mem_cache
      model { Thing }
      finder :find_by_thing
      scope { model.scoped.further }
    end

    expose(:foo, exposure: :example)

