class FinancialFilesController < ApplicationController
  
  def new
  end
  
  def create
    @ofx = Ofx.parse_file( params[:upload][:datafile] )
    Ofx.process_transactions( @ofx, current_user )
  end
end
