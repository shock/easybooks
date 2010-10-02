require 'rubygems'
require 'ofx-parser'

# This class handles parsing of Ofx files and creating EasyBooks transactions from them.
class Ofx < ImportData
  attr_accessor :transactions

  def self.parse_file file
    ofx = OfxParser::OfxParser.parse(file)
  end
  
  def initialize( file, options={} )
    @file, @options = file, options
    @ofx = Ofx.parse_file( file )
    parse_transactions( @ofx )
  end
  
  def account_number
    @ofx.bank_account.number
  end
  
  def account_balance
    FixedPoint.new(nil, @ofx.bank_account.balance_in_pennies)
  end
    
  private
  
    def parse_transactions ofx
      @transactions = []
      ofx.bank_account.statement.transactions.each do |t|
        transaction = Transaction.new({
          :amount => t.amount,
          :target => @options[:switch_target_and_description] ? t.memto : t.payee,
          :description => @options[:switch_target_and_description] ? t.payee : t.memo,
          :date => t.date,
          :transaction_id => t.fit_id,
          :check_num => t.check_number,
          :transaction_type => TransactionType.find_by_type(t.type)
        })
        @transactions << transaction
      end
    end
  
    def old_process_transactions ofx, user
      @account = Account.by_user(user).find_by_account_number(ofx.bank_account.number)
      raise "Could not find matching account with number #{ofx.bank_account.number}." unless account
      ofx.bank_account.statement.transactions.each do |t|
        transaction = Transaction.find_by_account_id_and_transaction_id( @account.id, t.fit_id )
        # transaction ||= Transaction.find_by_account_id_and_check_num( account.id, t.check_number
        unless transaction
          puts t.inspect
          transaction = Transaction.new({
            :account => @account,
            :amount => t.amount,
            :target => @account.switch_target_and_description? ? t.memto : t.payee,
            :description => @account.switch_target_and_description? ? t.payee : t.memo,
            :date => t.date,
            :transaction_id => t.fit_id,
            :check_num => t.check_number,
            :transaction_type => TransactionType.find_by_type(t.type)
          })
          transaction.save!
        end
      end
      @account
    end
  

end