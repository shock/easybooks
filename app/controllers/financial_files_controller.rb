class FinancialFilesController < ApplicationController
  
  def new
  end
  
  def create
    begin
      @ofx_import = OfxImport.new( params[:upload][:datafile] )
      @ofx = @ofx_import.ofx
    rescue
      flash[:error] = "Sorry.  The financial file you uploaded could not be understood."
      redirect_to "/"
    end
    @account = Account.by_user(current_user).find_by_account_number( @ofx_import.account_number )
    if @account
      @account.process_import_transactions( @ofx_import.transactions )
    else
      flash[:error] = "Sorry.  We could not find an account of your with account number #{@ofx.account_number}."
      redirect_to "/"
    end
  end
end
