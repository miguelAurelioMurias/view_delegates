<a href="https://codeclimate.com/github/coreSegmentFault/view_delegates/maintainability"><img src="https://api.codeclimate.com/v1/badges/a74e2a9f9198b29683a2/maintainability" /></a>
# ViewDelegates
ViewDelegates makes easy to write reusable view components with decoupled functionality from
the active record models

Create a ruby class implementing this gem base class 
ViewDelegates::ViewDelegate. I recommend to place the view delegates
under a folder on your applications app named '/view_delegates'. Then
just add your logic.
```ruby
 module Admin
   class AdminTestDelegate < ViewDelegates::ViewDelegate
     view_local :test_method
     property :my_property
     model :dummy, properties: [:a]
     cache true
     def test_method
       'test_method'
     end
   end
 end
```
- view_local executes a method of the class and adds it to the render as a local parameter.
- property creates an accessor to add extra variables to the view delegate
- model also creates an accessor but permits to reject other properties not wanted to have in your view. pass to to the properties array any properties you will need in your view
and the rest will be discarted
- cache is an optional parameter, pass a size: parameter to change the default size of the cache pool. Default: 50  

## Render views
Create an instance from the delegate you want to render

@delegate = Admin::AdminTestDelegate.new(dummy: @dummy, my_property: 'My property test')

And call render from that instance passing as a symbol the view you want to render
@delegate.render(:index)
If you want to use any extra params on one view
@delegate.render(:index, local_params: {optional_param: 'coreSegmentFault'

To know where your class will look for your view, open your console and call .view_path

```ruby
2.5.0 :004 > Admin::AdminTestDelegate.view_path
 => "admin/admin_test" 

```

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'view_delegates'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install view_delegates
```

## Contributing
Any contribution is accepted gladly. We only require two things:
- Add test cases for your added functionaly
- Add documentation
- Don't change any existing functionality for retro-compatibility

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
