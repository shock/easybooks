require 'rubygems'
require 'ofx-parser'

class Ofx
  def self.parse_file file
    ofx = OfxParser::OfxParser.parse(file)
  end
  
  def self.process_transactions ofx, user
    account = Account.by_user(user).find_by_account_number(ofx.bank_account.number)
    raise "Could not find matching account with number #{ofx.bank_account.number}." unless account
    ofx.bank_account.statement.transactions.each do |t|
      batch_transaction = BatchTransaction.new({
        :account => account,
        :amount => t.amount,
        :target => t.payee,
        :date => t.date,
        :description => t.memo,
        :transaction_id => t.fit_id,
        :transaction_type => TransactionType.find_by_type(t.type)
      })
      batch_transaction.save!
    end
  end
end