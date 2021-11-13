class RecommandList < ApplicationRecord

  def self.recommand_content(domains)
    "🚀 Register your favourite DAS accounts  #domains  #NFTs
🔥 Recommended list:
#{domains.join('\n')}
👉 Register & Get more: https://das.la/"
  end

  def self.check_domains
    domains = RecommandList.where(is_reg: false, is_recommand: false).order('random()').limit(5).pluck(:domain)
    $twitter_client.update(RecommandList.recommand_content(domains))
  end
  
end
