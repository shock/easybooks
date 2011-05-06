  class AccountsController < ApplicationController
  # GET /accounts
  # GET /accounts.xml
  def index
    @accounts = Account.by_user(current_user).all

    @net_value = FixedPoint.new(0)
    for account in @accounts
      @net_value += account.balance
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = Account.by_user(current_user).find(params[:id])
    @new_transaction = Transaction.new
    @new_transaction.account_id = @account.id

    find_conditions = {:account_id => @account.id}
    find_conditions.merge!(get_filter_conditions)
    @institution = Institution.find(@account.institution_id)
    @all_categories = Category.sorted_find_all current_user.default_workgroup
    @transaction_types = TransactionType.all
    @starting_balance = @account.balance(find_conditions[:date].first)
    
    @transactions = Transaction.all(:conditions => find_conditions, :order => "date" )

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = Account.new
    @all_institutions = Institution.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.by_user(current_user).find(params[:id])
    @all_institutions = Institution.all
  end

  # POST /accounts
  # POST /accounts.xml
  def create
    @account = Account.new(params[:account])
    respond_to do |format|
      if @account.save
        flash[:notice] = 'Account was successfully created.'
        format.html { redirect_to(@account) }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        @all_institutions = Institution.all
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = Account.by_user(current_user).find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        flash[:notice] = 'Account was successfully updated.'
        format.html { redirect_to(@account) }
        format.xml  { head :ok }
      else
        @all_institutions = Institution.all
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = Account.by_user(current_user).find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end
  
  def show_reconcile_batch
    @account = Account.by_user(current_user).find(params[:id])
    @transactions = @account.transactions
    @batch_transactions = @account.batch_transactions
  end
  
  def reconcile_batch
    @account = Account.by_user(current_user).find(params[:id])
  end
  
private
  def get_filter_conditions
    find_conditions={}
    filter_msgs = []
    # check for category filter
    unless (category_name = params[:category]).blank?
      category = Category.find_by_workgroup_id_and_name(current_user.default_workgroup_id, category_name)
      if category
        find_conditions[:category_id]=category.id
        filter_msgs << "Showing transactions from category '#{category_name}'"
      else
        filter_msgs << "Category '#{category_name}' does not exist."
      end
    end
    
    # check for date filter
    unless params[:start_date].blank?
      begin
        @start_date = Date.parse(params[:start_date])
      rescue
        @start_date = Date.civil(1600,1,1)
      end
    else
      @start_date = Date.today-30.days
    end
    unless params[:end_date].blank?
      @end_date = Date.parse(params[:end_date])
    else
      @end_date = Date.today + 10.years
    end
    
    filter_msgs << "Showing transactions on or before #{@end_date.to_s(:db)}"
    filter_msgs << "Showing transactions on or after #{@start_date.to_s(:db)}"
    find_conditions[:date] = (@start_date..@end_date)
  
    flash.now[:notice] = filter_msgs * "<br/>"
    find_conditions
  end
  
end
