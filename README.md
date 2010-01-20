LetItBe
=======

_Copying over instance variables is bad, mmm-kay?_

LetItBe helps you program to an interface, rather than an implementation in
your Rails controllers.

The fact of the matter is that sharing state via instance variables in
controllers promotes close coupling with views. LetItBe gives you a declarative
manner of exposing an interface to the state that controllers contain, thereby
decreasing coupling and improving your testability and overall design.

Installation
------------

    gem install let-it-be

Configure your application to use it:

In `config/environment.rb`:

    config.gem 'let-it-be', :lib => 'let_it_be'

In controllers which wish to take advantage of `LetItBe`:

    class CandidateController < Application
      extend LetItBe
      ...
    end

If you want to have access to `let` everywhere, `extend LetItBe` in your
`ApplicationController`.

The Particulars
---------------

`let` creates a method with the given name, evaluates the provided block (or
intuits a value when no block is passed) and memoizes the result. This method is
then declared as a `helper_method` so that views may have access to it and is
made unroutable as an action with `hide_action`.

Examples
--------

### In your controllers

When no block is given, `let` attempts to intuit which resource you want to
acquire:

    # Category.find(params[:category_id] || params[:id])
    let(:category)

As the example shows, the symbol passed is used to guess the class name of the
object you want an instance of. Almost every controller has one of these. In the
RESTful controller paradigm, you might use this in `#show`, `#edit`, `#update`
or `#destroy`.

In the slightly more complicated scenario, you need to find an instance of an
object which doesn't map cleanly to `Object#find`:

    let(:product){ category.products.find(params[:id]) }

In the RESTful controller paradigm, you'll again find yourself using this in
`#show`, `#edit`, `#update` or `#destroy`.

When the code has become complex enough to surpass a single line (and is not
appropriate to extract into a model method), use the `do...end` style of block:

    let(:associated_products) do
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

Beware
------

This is an exceptionally simple tool, which provides a solitary solution. It
must be used in conjunction with solid design approaches ("Program to an
interface, not an implementation.") and accepted best practices (e.g. Fat Model,
Skinny Controller). In itself, it won't heal a bad design. It is meant only to
be a tool to use in improving the overall design of a Ruby on Rails system and
moreover to provide a standard implementation for an emerging best practice.

Documentation TODO
------------------

* walk-through explanation of the actual implementation (using an existing,
popular OSS Rails app as an example for the refactor).
