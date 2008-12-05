class Account < ActiveRecord::Base
  belongs_to :institution
  has_many :transactions

  def institution
    i = Institution.find(:first, :conditions => { :id => institution_id })
  end
    
  def institution_name
    institution.name
  end


  def long_name
    institution_name + ":" + name
  end

  def balance
    transactions = Transaction.find(:all, :conditions => { :account_id => id})
    balance = 0.0
    for t in transactions
      if t.type.id == Global[:DEB]
        balance -= t.amount
      else
        balance += t.amount
      end
    end
    balance
  end

  def cleared_balance
    transactions = Transaction.find(:all, :conditions => { :account_id => id})
    balance = 0.0
    for t in transactions
      if t.registered == true
        if t.type.id == Global[:DEB]
          balance -= t.amount
        else
          balance += t.amount
        end
      end
    end
    balance
  end


end
