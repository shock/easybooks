class ConvertInterestRateTo4Decimals < ActiveRecord::Migration
  def self.up
    Account.find_each do |a|
      a[:interest_rate]=a[:interest_rate]*100
      a.save!
    end
  end

  def self.down
    Account.find_each do |a|
      a[:interest_rate]=a[:interest_rate]/100
      a.save!
    end
  end
end
