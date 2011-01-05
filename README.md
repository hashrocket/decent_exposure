`decent_exposure` helps you program to an interface, rather than an implementation in
your Rails controllers.

Sharing state via instance variables in controllers promotes close coupling with
views. `decent_exposure` gives you a declarative manner of exposing an interface to the
state that controllers contain, thereby decreasing coupling and improving your
testability and overall design. I elaborate on this approach in [A Diatribe on
Maintaining State][diatribe].

Installation
------------

    gem install decent_exposure

Configure your Rails 2.X application to use it:

In `config/environment.rb`:

    config.gem 'decent_exposure'

When used in Rails 3:

In `Gemfile`:

    gem 'decent_exposure'


Examples
--------

### A full example

The wiki has a full example of [converting a classic-style Rails
controller][converting].

### In your controllers

When no block is given, `expose` attempts to determine which resource you want
to acquire. When `params` contains `:category_id` or `:id`, a call to:

    expose(:category)

Would result in the following `ActiveRecord#find`:

    Category.find(params[:category_id]||params[:id])

As the example shows, the symbol passed is used to guess the class name of the
object (and potentially the `params` key to find it with) you want an instance
of.

Should `params` not contain an identifiable `id`, a call to:

    expose(:category)

Will instead attempt to build a new instance of the object like so:

    Category.new(params[:category])

If you define a collection with a pluralized name of the singular resource,
`decent_exposure` will attempt to use it to scope its calls from. Let's take the
following scenario:

    class ProductsController < ApplicationController
      expose(:category)
      expose(:products) { category.products }
      expose(:product)
    end

The `product` resource would scope from the `products` collection via a
fully-expanded query equivalent to this:

    Category.find(params[:category_id]).products.find(params[:id])

or (depending on the contents of the `params` hash) this:

    Category.find(params[:category_id]).products.new(params[:product])

In the straightforward case, the three exposed resources above provide for
access to both the primary and ancestor resources in a way usable across all 7
actions in a typicall Rails-style RESTful controller.

#### A Note on Style

When the code has become complex enough to surpass a single line (and is not
appropriate to extract into a model method), use the `do...end` style of block:

    expose(:associated_products) do
      product.associated.tap do |associated_products|
        present(associated_products, :with => AssociatedProductPresenter)
      end
    end

### In your views

Use the product of those assignments like you would an instance variable or any
other method you might normally have access to:

    = render bread_crumbs_for(category)
    %h3#product_title= product.title
    = render product
    %h3 Associated Products
    %ul
      - associated_products.each do |associated_product|
      %li= link_to(associated_product.title,product_path(associated_product))

### Custom defaults

`decent_exposure` provides opinionated default logic when `expose` is invoked without
a block. It's possible, however, to override this with custom default logic by
passing a block accepting a single argument to the `default_exposure` method
inside of a controller. The argument will be the string or symbol passed in to
the `expose` call.

    class MyController < ApplicationController
      default_exposure do |name|
        ObjectCache.load(name.to_s)
      end
    end

The given block will be invoked in the context of a controller instance. It is
possible to provide a custom default for a descendant class without disturbing
its ancestor classes in an inheritance heirachy.

Beware
------

This is a simple tool, which provides a solitary solution. It must be used in
conjunction with solid design approaches ("Program to an interface, not an
implementation.") and accepted best practices (e.g. Fat Model, Skinny
Controller). In itself, it won't heal a bad design. It is meant only to be a
tool to use in improving the overall design of a Ruby on Rails system and
moreover to provide a standard implementation for an emerging best practice.

Development
-----------

### Running specs

`decent_exposure` has been developed with the philosophy that Ruby developers shouldn't
force their choice in RubyGems package managers on people consuming their code.
As a side effect of that, if you attempt to run the specs on this application,
you might get `no such file to load` errors.  The short answer is that you can
`export RUBYOPT='rubygems'` and be on about your way (for the long answer, see
Ryan Tomayko's [excellent treatise][treatise] on the subject).

[treatise]: http://tomayko.com/writings/require-rubygems-antipattern
[converting]: http://github.com/voxdolo/decent_exposure/wiki/Examples
[diatribe]: http://blog.voxdolo.me/a-diatribe-on-maintaining-state.html

Contributors
------------

Thanks to everyone that's helped out with `decent_exposure`! You can see a full
list here:

<http://github.com/voxdolo/decent_exposure/contributors>
