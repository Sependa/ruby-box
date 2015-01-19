require 'yaml'

begin
  ACCOUNT = YAML.load_file(File.dirname(__FILE__) + '/account.yml')
rescue
  ACCOUNT = {}
  p "create an account.yml file with your credentials to run integration tests."
end
