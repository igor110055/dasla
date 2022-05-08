# -*- encoding : utf-8 -*-
# gem 'settingslogic'
class DasDatabaseConfig < Settingslogic
  source "#{Rails.root}/config/das_database.yml"
  namespace Rails.env
end


module DasDatabase
  mattr_accessor :establish

  @@establish = {
      :adapter => DasDatabaseConfig.adapter,
      :host => DasDatabaseConfig.host,
      :encoding => DasDatabaseConfig.encoding,
      :port => DasDatabaseConfig.port,
      :username => DasDatabaseConfig.username,
      :password => DasDatabaseConfig.password,
      :database => DasDatabaseConfig.database
  }
end