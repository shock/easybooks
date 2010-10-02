## User

Factory.define :user do |i|
  i.login "#{String.random}"
  i.email {|i| "#{i.login}@#{i.login}.com"}
  passwd = String.random
  i.password passwd
  i.password_confirmation passwd
end

## Workgroup

Factory.define :workgroup do |i|
  i.name "Workgroup #{String.random}"
end

## Institution

Factory.define :institution do |i|
  i.name {|i| "Institution #{String.random}"}
  i.association :workgroup, :factory=>:workgroup
end

## Account

Factory.define :account do |i|
  i.name {|i| "Account #{String.random}"}
  i.institution Factory(:institution)
  i.workgroup {|i| i.institution ? i.institution.workgroup : i.association(:workgroup)}
  i.opening_date Date.today
end

## Transaction

Factory.define :transaction do |i|
  i.association :account, :factory=>:account
  i.target {|i| "Target for Transaction #{String.random}"}
  i.description {|i| "Transaction Description for #{String.random}"}
  i.amount 3.33
  i.date Date.today
  i.transaction_id {"TID_#{Factory.next(:counter)}"}
  i.transaction_type TransactionType.find(TransactionType::IDS.first)
end

## Batch Transaction

Factory.define :batch_transaction do |i|
  i.association :account, :factory=>:account
  i.target {|i| "Target for Batch Transaction #{String.random}"}
  i.description {|i| "Batch Transaction Description for #{String.random}"}
  i.amount 3.33
  i.date Date.today
  i.transaction_type TransactionType.find(TransactionType::IDS.first)
end

## Category

Factory.define :category do |i|
  i.name {|i| "Category #{String.random}"}
  i.association :workgroup, :factory=>:workgroup
  i.parent_id -1
end

Factory.sequence :counter do |n|
  n
end
