LetItBe
=======

_Copying over instance variables is bad, mmm-kay?_

LetItBe helps you program to an interface, rather than an implementation in
your Rails controllers.

The fact of the matter is that sharing state via instance variables in
controllers promotes close coupling with views. LetItBe gives you a
declarative manner of exposing an interface to the state that controllers
contain and thereby decreasing coupling and improving your testability and
overall design.

Documentation TODO
------------------

* Explain how Rails copies controller instance variables to the view.
* Example of block-style usage
* Example of default find behavior when no block passed
* Explain how default find behavior works.
* Gotchas
* FAQ (if enough anticipated questions)
* Add an open-source license
* Possible walk-through explanation of the actual implementation.