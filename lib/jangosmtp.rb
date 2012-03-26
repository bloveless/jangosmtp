require 'jangosmtp/version'

module Jangosmtp
  
  class << self
    attr_accessor :username, :password, :max_attempts, :click_tracking, :open_tracking, :auto_generate_plain
    BASE_URL = 'http://api.jangomail.com/api.asmx/'
    
    def options( hash )
      @username = hash[:username] if !hash[:username].nil?
      @password = hash[:password] if !hash[:password].nil?
      @max_attempts = hash[:max_attempts] ||= 1
      @click_tracking = hash[:click_tracking] ||= true
      @open_tracking = hash[:open_tracking] ||= true
      @auto_generate_plain = hash[:open_tracking] ||= true
    end
    
    # Get a group if the group exists, otherwise create a group using a group name and return it's id
    # group_name: group name that the user wants to get the id for, should only contain alphanumeric ( and spaces )
    #   will be cleaned if an incorrect name is used
    def get_create_group( group_name )
      check_user_pass
      existing_group_id = get_group_id( group_name )
      if existing_group_id == nil
        new_group_id = create_group( group_name )
        return new_group_id
      end
      return existing_group_id
    end
    
    # Get the id of a requested group
    # group_name: group name that the user wants to get the id for, should only contain alphanumeric ( and spaces )
    #   will be cleaned if an incorrect name is used
    def get_group_id( group_name )
      check_user_pass
      # First we need to clean the group_name since jangosmtp only allows alphanumeric characters
      group_name.tr!('^A-Za-z0-9 ', '')
      options = {
        'Username' => @username,
        'Password' => @password,
        'GroupName' => group_name
      }
    
      # First we are going to check the existing groups to make sure that the current group doesn't already exist.
      found_group = false
      existing_group_id = nil
      response = post_with_attempts( "GetTransactionalGroupID", options )
      if response != false
        existing_group_id = Nokogiri::XML.parse(response.body).xpath("*").first.content.split("\n")[2]
        found_group = true
      end
    
      return existing_group_id
    end
    
    # Create a group and return the successfull value
    # group_name: group name that the user wants to get the id for, should only contain alphanumeric ( and spaces )
    #   will be cleaned if an incorrect name is used
    def create_group( group_name )
      check_user_pass
      # First we need to clean the group_name since jangosmtp only allows alphanumeric characters
      group_name.tr!('^A-Za-z0-9 ', '')
      options = {
        'Username' => @username,
        'Password' => @password,
        'GroupName' => group_name
      }
      
      response = post_with_attempts( 'AddTransactionalGroup', options )
      if response != false
        new_group_id = Nokogiri::XML.parse(response.body).xpath("*").first.content.split("\n")[2]
      end
      return new_group_id
    end
    
    # Send an email and get/create a requested group
    # group_name: group name that the user wants the email to be applied to, should only contain alphanumeric
    #   ( and spaces ) will be cleaned if an incorrect name is used
    # subject: the subject of the email to be sent
    # to_email: the single email address that the email will be sent to
    # from_email: the email address that the email will be coming from
    # from_name: the name that the email address will be coming from
    # html: the html of the email message to be sent
    #
    # IMPORTANT: This function will attempt to get or create a group for each email that is sent. If you will
    #   be sending a lot of emails to the same group I would recommend you create the group first and use
    #   the send_email_with_group_id function since that takes a group_id and won't attempt to create the
    #   group with each email that is sent
    def send_email( group_name, subject, to_email, from_email, from_name, html )
      check_user_pass
      group_id = get_create_group( group_name )
      unless group_id.nil?
        return send_email_with_group_id( group_id, subject, to_email, from_email, from_name, html )
      end
    end
    
    # Send an email using a pre-existing group
    # group_id: the id of the group that this email will be applied to
    # subject: the subject of the email to be sent
    # to_email: the single email address that the email will be sent to
    # from_email: the email address that the email will be coming from
    # from_name: the name that the email address will be coming from
    # html: the html of the email message to be sent
    def send_email_with_group_id( group_id, subject, to_email, from_email, from_name, html )
      check_user_pass
      options = {
        'Username' => @username,
        'Password' => @password,
        'FromEmail' => from_email,
        'FromName' => from_name,
        'ToEmailAddress' => to_email,
        'Subject' => subject,
        'MessagePlain' => 'auto-generate',
        'MessageHTML' => html,
        'Options' => 'OpenTrack=' + @open_tracking.to_s + ',ClickTrack=' + @click_tracking.to_s + ',TransactionalGroupID=' + group_id
      }
      return post_with_attempts( 'SendTransactionalEmail', options )
    end
    
    private
    # Will verify that the username and password exist for each request
    def check_user_pass
      if @username.nil? || @password.nil?
        raise 'Jangosmtp username and password are required'
      end
    end
    
    # Will attempt to post to the jangosmtp action requested using the options hash passed in
    def post_with_attempts( action, options )
      agent = Mechanize.new
      attempt = 0
      response = false
      # Try max_attempts times before skipping
      while((attempt < max_attempts) && !response)
        begin
          response = agent.post( BASE_URL + action, options )
        rescue StandardError => e
          # If there was an error set success to false and try again in 3 seconds
          response = false
          attempt += 1
          sleep 3
        end
      end
      return response
    end
    
    # Get either the Rails logger or the a logger to STDOUT
    def logger
      if !Rails.nil?
        return Rails.logger
      else
        return Logger.new( STDOUT )
      end
    end
  end
end
