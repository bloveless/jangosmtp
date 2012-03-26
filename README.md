# Jangosmtp

This gem will allow a user to easily incorporate jangosmtp into their existing rails project. This gem uses the jangosmtp api rather than the jangosmtp smtp relay since, according to the jangosmtp docs, the api is faster and more reliable than using the jangosmtp relay. Currently at our company we are only using the send and transaction group functions, but if you would like, feel free to make a request for more functions as well as forking this repo and submitting a new pull request. Please enjoy and I do apologize for not having any tests at this very moment.

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

* `username` __is required__ and is the same username you use to login to jangosmtp.
* `password` __is required__ and is the same password you use to login to jangosmtp.
* `max_attempts` is __not required__, but if there is a failed call to jangosmtp the gem will attempt the try again every three seconds until max_attempts is reached. There is a catch here, jangosmtp relies on 500 internal server errors even when a value is listed incorrectly, so this will slow down your application. For example: when creating a groups this gem tries to get the group first. If jangosmtp does not find the requested group then it will throw a 500 internal server error. Which will cause the system to try again until the max number of attempts are reached before attempting to create the group. I'm working with jangosmtp for a fix to this issue.
* `click_tracking` is __not required__ but will default to true which enables tracking for whenever anyone clicks on any link that is included in your email.
* `open_tracking` is __not required__ but will default to true which enables tracking for whenever anyone opens an email you sent, this is done by jangosmtp including a transparent image in your email so they can monitor when the image is downloaded from their server.
* `auto_generate_plain` is __not required__ but will default to true which tells jangosmtp that you are sending html content for your email and that jangosmtp should generate the plain text version of the email to be sent along with your email, this is recommended since this gem doesn't currently have the ability to send plain text emails

## Usage

### Get and/or create group
Get a group if the group exists, otherwise create a group using a group name and return it's id  
`group_name`: group name that the user wants to get the id for, should only contain alphanumeric ( and spaces ) will be cleaned if an incorrect name is used
    
    get_create_group( group_name )
    
### Get group id
Get the id of a requested group  
`group_name`: group name that the user wants to get the id for, should only contain alphanumeric ( and spaces ) will be cleaned if an incorrect name is used

    get_group_id( group_name )

### Create group
Create a group and return the successfull value  
`group_name`: group name that the user wants to get the id for, should only contain alphanumeric ( and spaces ) will be cleaned if an incorrect name is used

    create_group( group_name )

### Send an email using group name
Send an email and get/create a requested group  
`group_name`: group name that the user wants the email to be applied to, should only contain alphanumeric ( and spaces ) will be cleaned if an incorrect name is used  
`subject`: the subject of the email to be sent
`to_email`: the single email address that the email will be sent to  
`from_email`: the email address that the email will be coming from  
`from_name`: the name that the email address will be coming from  
`html`: the html of the email message to be sent  
  
___IMPORTANT___: This function will attempt to get or create a group for each email that is sent. If you will be sending a lot of emails to the same group I would recommend you create the group first and use the `send_email_with_group_id` function since that takes a group_id and won't attempt to create the group with each email that is sent

    send_email( group_name, subject, to_email, from_email, from_name, html )

### Send an email using group id
Send an email using a pre-existing group  
`group_id`: the id of the group that this email will be applied to  
`subject`: the subject of the email to be sent
`to_email`: the single email address that the email will be sent to  
`from_email`: the email address that the email will be coming from  
`from_name`: the name that the email address will be coming from  
`html`: the html of the email message to be sent  

    send_email_with_group_id( group_id, subject, to_email, from_email, from_name, html )

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
