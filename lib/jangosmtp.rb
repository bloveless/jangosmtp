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
    
    def get_create_group( group_name )
      check_user_pass
      existing_group_id = get_group_id( group_name )
      if existing_group_id == nil
        new_group_id = create_group( group_name )
        return new_group_id
      end
      return existing_group_id
    end
    
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
    
    def send_email( group_name, to_email, from_email, from_name, html )
      check_user_pass
      group_id = get_create_group( group_name )
      unless group_id.nil?
        return send_email_with_group_id( group_id, to_email, from_email, from_name, html )
      end
    end
    
    def send_email_with_group_id( group_id, to_email, from_email, from_name, html )
      check_user_pass
      # Send the email using Jango
      options = {
        'Username' => @username,
        'Password' => @password,
        'FromEmail' => from_email,
        'FromName' => from_name,
        'ToEmailAddress' => to_email,
        'Subject' => 'SOCO Authorization Request',
        'MessagePlain' => 'auto-generate',
        'MessageHTML' => html,
        'Options' => 'OpenTrack=' + @open_tracking.to_s + ',ClickTrack=' + @click_tracking.to_s + ',TransactionalGroupID=' + group_id
      }
      return post_with_attempts( 'SendTransactionalEmail', options )
    end
    
    private
    def check_user_pass
      if @username.nil? || @password.nil?
        raise 'Jangosmtp username and password are required'
      end
    end
    
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
    
    def logger
      if !Rails.nil?
        return Rails.logger
      else
        return Logger.new( STDOUT )
      end
    end
  end
end
