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
      transaction = Transaction.find_by_account_id_and_transaction_id( account.id, t.fit_id )
      unless transaction
        puts t.inspect
        transaction = Transaction.new({
          :account => account,
          :amount => t.amount,
          :target => account.switch_target_and_description? ? t.memo : t.payee,
          :description => account.switch_target_and_description? ? t.payee : t.memo,
          :date => t.date,
          :transaction_id => t.fit_id,
          :check_num => t.check_number,
          :transaction_type => TransactionType.find_by_type(t.type)
        })
        transaction.save!
      end
    end
    account
  end
end