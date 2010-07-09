DecentExposure
==============

_Copying over instance variables is bad, mmm-kay?_

DecentExposure helps you program to an interface, rather than an implementation in
your Rails controllers.

Sharing state via instance variables in controllers promotes close coupling with
views. DecentExposure gives you a declarative manner of exposing an interface to the
state that controllers contain, thereby decreasing coupling and improving your
testability and overall design.

Installation
------------

    gem install decent_exposure

Configure your Rails 2.X application to use it:

In `config/environment.rb`:

    config.gem 'decent_exposure'

When used in Rails 3:

In `Gemfile`:

    gem 'decent_exposure'


The Particulars
---------------

`expose` creates a method with the given name, evaluates the provided block (or
intuits a value when no block is passed) and memoizes the result. This method is
then declared as a `helper_method` so that views may have access to it and is
made unroutable as an action.

Examples
--------

### In your controllers

When no block is given, `expose` attempts to intuit which resource you want to
acquire:

    # Category.find(params[:category_id] || params[:id])
    expose(:category)

As the example shows, the symbol passed is used to guess the class name of the
object you want an instance of. Almost every controller has one of these. In the
RESTful controller paradigm, you might use this in `#show`, `#edit`, `#update`
or `#destroy`.

In the slightly more complicated scenario, you need to find an instance of an
object which doesn't map cleanly to `Object#find`:

    expose(:product){ category.products.find(params[:id]) }

In the RESTful controller paradigm, you'll again find yourself using this in
`#show`, `#edit`, `#update` or `#destroy`.

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

DecentExposure provides opinionated default logic when `expose` is invoked without
a block. It's possible, however, to override this with your own custom default
logic by passing a block accepting a single argument to the `default_exposure`
method inside of a controller. The argument will be the string or symbol passed
in to the `expose` call.

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

This is an exceptionally simple tool, which provides a solitary solution. It
must be used in conjunction with solid design approaches ("Program to an
interface, not an implementation.") and accepted best practices (e.g. Fat Model,
Skinny Controller). In itself, it won't heal a bad design. It is meant only to
be a tool to use in improving the overall design of a Ruby on Rails system and
moreover to provide a standard implementation for an emerging best practice.

Development
-----------

### Running specs

`DecentExposure` has been developed with the philosophy that Ruby developers shouldn't
force their choice in RubyGems package managers on people consuming their code.
As a side effect of that, if you attempt to run the specs on this application,
you might get `no such file to load` errors.  The short answer is that you can
`export RUBYOPT='rubygems'` and be on about your way (for the long answer, see
Ryan Tomayko's [excellent
treatise](http://tomayko.com/writings/require-rubygems-antipattern) on the
subject).

### Documentation TODO

* walk-through of an actual implementation (using an existing, popular OSS Rails
app as an example refactor).
