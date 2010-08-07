require 'rubygems'
require 'spork'

# --- Spork Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - To see if an application is somehow getting loaded in the prefork block, run 'spork -d' from the CLI

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  

  # This file is copied to ~/spec when you run 'ruby script/generate rspec'
  # from the project root directory.
  ENV["RAILS_ENV"] ||= 'test'
  require File.dirname(__FILE__) + "/../config/environment" 
  require 'spec/autorun'
  require 'spec/rails'
  require 'spec/runner/formatter/text_mate_formatter'


  Spec::Runner.configure do |config|
    # If you're not using ActiveRecord you should remove these
    # lines, delete config/database.yml and disable :active_record
    # in your config/boot.rb
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  end


end

Spork.each_run do
  # This code will be run each time you run your specs.
  require File.dirname(__FILE__) + "/spec_helpers/auth_logic_helper.rb"
  require File.dirname(__FILE__) + '/spec_helpers/rspec_helper'
  require File.dirname(__FILE__) + '/spec_helpers/factory_helper'
  require File.dirname(__FILE__) + "/factory/main_factory.rb"
  
end



