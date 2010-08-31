class TransactionsController < ApplicationController
#skip_before_filter :verify_authenticity_token
  # GET /transactions
  # GET /transactions.xml
  def index
    @transactions = Transaction.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @transactions }
    end
  end

  # GET /transactions/1
  # GET /transactions/1.xml
  def show
    @transaction = Transaction.find(params[:id])
    @category = Category.find(:first, :conditions => { :id => @transaction.category_id })
    @account = Account.find(:first, :conditions => { :id => @transaction.account_id })

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.xml
  def new
    @transaction = Transaction.new
    @all_categories = Category.sorted_find_all current_user.default_workgroup
    @all_accounts = Account.find(:all)
    @transaction_types = TransactionType.find(:all)
    if params[:account_id]
      @transaction.account_id = params[:account_id]
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/1/tedit
  def edit
    @transaction = Transaction.find(params[:id])
    @all_categories = Category.sorted_find_all current_user.default_workgroup
    @all_accounts = Account.find(:all)
    @transaction_types = TransactionType.find(:all)
  end

  # GET /transactions/1/tedit
  def remote_edit
    @transaction = Transaction.find(params[:id])
    @all_categories = Category.sorted_find_all current_user.default_workgroup
    @all_accounts = Account.find(:all)
    @transaction_types = TransactionType.find(:all)
  end

  # POST /transactions
  # POST /transactions.xml
  def create
    @transaction = Transaction.new(params[:transaction])
    @account = @transaction.account
    @all_categories = Category.sorted_find_all current_user.default_workgroup
    @all_accounts = Account.find(:all)
    @transaction_types = TransactionType.find(:all)

    respond_to do |format|
      if @transaction.save
        flash[:notice] = 'Transaction was successfully created.'
        rd_url = url_for(@account)+ "#" + @transaction.id.to_s()
        format.html { redirect_to(rd_url) }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        @all_categories = Category.sorted_find_all current_user.default_workgroup
        @all_accounts = Account.find(:all)
        format.html { render :action => "new" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.xml
  def update
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        flash[:notice] = 'Transaction was successfully updated.'
        format.html { redirect_to(@transaction.account) }
        format.xml  { head :ok }
      else
        @all_categories = Category.sorted_find_all current_user.default_workgroup
        @all_accounts = Account.find(:all)
        @transaction_types = TransactionType.find(:all)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /transactions/remote_update/1
  def remote_update
    @transaction = Transaction.find(params[:id])
#    debugger

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        @status_msg = "<span style='color:green'>Updated</span>"
      else
        @status_msg = "<span style='color:red'>Error</span>"
      end
      format.html { render :partial => "status" }
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.xml
  def destroy
    @transaction = Transaction.find(params[:id])
    @account = @transaction.account
    @transaction.destroy

    respond_to do |format|
      rd_url = url_for(@account)+ "#end"
      format.html { redirect_to(rd_url) }

      format.xml  { head :ok }
    end
  end
  

end
