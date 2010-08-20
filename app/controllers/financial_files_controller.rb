class FinancialFilesController < ApplicationController
  
  def new
  end
  
  def create
    @ofx = OfxFile.parse_file( params[:upload][:datafile] )
  end
end
