# frozen_string_literal: true
namespace :twitter do

  desc "推荐account"
  task recommand_account: :environment do
    print "recommand_account begin\n"
    begin
      RecommandList.check_domains
    rescue Exception => e
      print e
    end
    print "recommand_account end\n"
  end
end

