namespace :db_init do
  desc "Setup base records for Category and TransactionType"
  task :setup => :environment do
    Category.create!(:name=>"All")
    TransactionType.create(:id=>1,:name=>"DEB")
    TransactionType.create(:id=>2,:name=>"CRD")
  end

end

