# frozen_string_literal: true
namespace :das do

  desc "cloud word"
  task cloud_word: :environment do
    Das::AccountInfo.set_cloud_word_num
  end
end

