# Jangosmtp

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'jangosmtp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jangosmtp

## Configuration

In your environment file there are a few options that you can pass to Jangosmtp as follows:

After the gem is installed you will need to add your jango configuration to your environment file. Using the following lines of code. Pay close attention to the comments here.

    Jangosmtp.options({
      username: 'username',
      password: 'password',
      max_attempts: 1,
      click_tracking: true,
      open_tracking: true,
      auto_generate_plain: true
    })

* username is required and is the same username you use to login to jangosmtp.
* password is required and is the same password you use to login to jangosmtp.
* max_attempts is _not_ required, but if there is a failed call to jangosmtp the gem will attempt the try again every three seconds until max_attempts is reached. There is a catch here, jangosmtp relies on 500 internal server errors even when a value is listed incorrectly, so this will slow down your application. For example: when creating a groups this gem tries to get the group first. If jangosmtp does not find the requested group then it will throw a 500 internal server error. Which will cause the system to try again until the max number of attempts are reached before attempting to create the group. I'm working with jangosmtp for a fix to this issue.
* click_tracking is _not_ required but will default to true which enables tracking for whenever anyone clicks on any link that is included in your email.
* open_tracking is _not_ required but will default to true which enables tracking for whenever anyone opens an email you sent, this is done by jangosmtp including a transparent image in your email so they can monitor when the image is downloaded from their server.
* auto_generate_plain is _not_ required but will default to true which tells jangosmtp that you are sending html content for your email and that jangosmtp should generate the plain text version of the email to be sent along with your email, this is recommended since this gem doesn't currently have the ability to send plain text emails

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
