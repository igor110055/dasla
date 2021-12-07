# frozen_string_literal: true
namespace :yok do

  desc "yok价差"
  task binance_yok: :environment do
    print "binance_yok begin\n"
    begin
      RecommandList.check_ckb_price
    rescue Exception => e
      print e
    end
    print "binance_yok end\n"
  end
end

