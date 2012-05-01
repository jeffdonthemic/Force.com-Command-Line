# databasedotcom info:
#   documentation: http://rubydoc.info/github/heroku/databasedotcom/master/frames
#   github: https://github.com/heroku/databasedotcom
# thor info: https://github.com/wycats/thor

require 'databasedotcom'

class Utils < Thor
  
  desc "query SOQL", "runs a soql query and displays the value of each record's 'name' field"
  method_option :config_file, :type => :string, :default => "databasedotcom.yml", 
    :aliases => "-c", :desc => "The name of the file containing the connection parameters."  
  def query(soql)
    client = authenticate(options[:config_file])
    # execute the soql and iterate over the results to output the name
	  client.query("#{soql}").each do |r|
	    puts r.Name
    end
  end
  
  desc "export SOQL FIELDS FILE", "runs a soql query and exports the specified 
    comma separated list of fields to a comma separated file"
  method_option :config_file, :type => :string, :default => "databasedotcom.yml", 
    :aliases => "-c", :desc => "The name of the file containing the connection parameters."
  def export(soql, fields, file)
    client = authenticate(options[:config_file])
    # query for records
    records = client.query("#{soql}")
    # open the file to write (probably local directory)
    File.open(file, 'w') do |f| 
      # interate over the records
      records.each do |r| 
        # create a single line with all field values specified
        line = ''
        fields.split(',').each do |field|
          line += "#{eval("r.#{field}")},"
        end 
        # write each line to the csv file       
        f.puts  "#{line}\n"
      end
    end 
  end
  
  desc "describe OBJECT", "displays the describe info for a particular object"
  method_option :config_file, :type => :string, :default => "databasedotcom.yml", 
    :aliases => "-c", :desc => "The name of the file containing the connection parameters."
  def describe(object)
    client = authenticate(options[:config_file])
    # call describe on the object by name
    sobject = client.describe_sobject(object)
    # output the results -- not very useful (frowny face)
    puts sobject
  end
  
  desc "get_token", "retreives an access token"
  method_option :config_file, :type => :string, :default => "databasedotcom.yml", 
    :aliases => "-c", :desc => "The name of the file containing the connection parameters."
  def get_token
    client = authenticate(options[:config_file]).oauth_token
    puts "Access token: #{client}"
  end

  desc "show_config", "display the salesforce connection properties"
  method_option :config_file, :type => :string, :default => "databasedotcom.yml", 
    :aliases => "-c", :desc => "The name of the file containing the connection parameters."
  def show_config
    config = YAML.load_file(options[:config_file])
    puts config
  end
  
  private 
  
    def authenticate(file_name)
      # load the configuration file with connection parameters
  	  config = YAML.load_file(file_name)
  	  # init the databasedotcom gem with the specified yml config file
      client = Databasedotcom::Client.new(file_name)    
  	  # pass the credentials to authenticate
  	  client.authenticate :username => config['username'], :password => config['password']
  	  return client
    end
  
end