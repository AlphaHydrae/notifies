# notifies

**Simple notifications with Growl and OS X Notification Center.**

[![Gem Version](https://badge.fury.io/rb/notifies.png)](http://badge.fury.io/rb/notifies)
[![Dependency Status](https://gemnasium.com/AlphaHydrae/notifies.png)](https://gemnasium.com/AlphaHydrae/notifies)
[![Build Status](https://secure.travis-ci.org/AlphaHydrae/notifies.png)](http://travis-ci.org/AlphaHydrae/notifies)
[![Coverage Status](https://coveralls.io/repos/AlphaHydrae/notifies/badge.png?branch=master)](https://coveralls.io/r/AlphaHydrae/notifies?branch=master)

## Installation

In your Gemfile:

```rb
gem 'notifies', '~> 0.1.0'
```

Manually:

    gem install notifies

## Usage

It's as simple as:

```rb
Notifies.notify 'Hello World!'
```

This will automatically select and use the first available notifier.

The method returns:

* `true` if everything worked;
* `nil` if no notifier is available on your system;
* `false` if the notifier failed.

### Notification Options

The following options are available:

* `:type` - The type of notification. With some notifiers this changes the icon.
            This must be either `:ok`, `:info`, `:warning` or `:error`. By default, `:info` is selected.
* `:title` - The title of the notification. This is set by the notifier by default (e.g. "growlnotify" for the Growl notifier).
* `:subtitle` - An optional subtitle.
* `:icon` - Custom icon. Only supported with Growl, see [the documentation](https://github.com/visionmedia/growl#normaized-icons).

```rb
Notifies.notify 'Hello World!', type: :ok, title: 'My App', subtitle: 'Notifications'
```

### Aliases

You can uses these aliases instead of passing the `:type` option:

```rb
Notifies.notify_ok 'It works!'
Notifies.notify_info 'Useful information'
Notifies.notify_warning 'Beware'
Notifies.notify_error 'Broken'
```

## Contributing

* [Fork](https://help.github.com/articles/fork-a-repo)
* Create a topic branch - `git checkout -b my_branch`
* Push to your branch - `git push origin my_branch`
* Create a [pull request](http://help.github.com/pull-requests/) from your branch

Please add a changelog entry for new features and bug fixes.
Writing specs will get your code pulled faster.

## Meta

* **Author:** Simon Oulevay (Alpha Hydrae)
* **License:** MIT (see [LICENSE.txt](https://raw.github.com/AlphaHydrae/notifies/master/LICENSE.txt))
