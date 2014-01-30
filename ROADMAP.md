Decent Exposure 3.0 roadmap
===========================

## Support the latest and greatest

* Drop support for Rubies below 2.0
* Drop support for Rails below 4.0.x

## End the confusion with parameter assignment

* Extract parameter-assignment strategies to separate plugins
* To ease transition, include these separate plugins as deprecated
  dependencies, to be removed as gem dependencies in v3.1

## Other (low priority)

* Create a more convenient strategy registry (plain-old class names
  works fine, but symbols would be cool)
