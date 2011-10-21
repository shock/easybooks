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

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = Account.by_user(current_user).find(params[:id])
    @new_transaction = Transaction.new
    @new_transaction.account_id = @account.id
    @new_transaction.date = @account.transactions.last.date

    find_options = {:conditions=>{:account_id => @account.id}}
    find_options = get_sort_options(params, find_options)
    find_options = get_filter_options(params, find_options)
    find_options = get_paging_options(params, find_options)
    @institution = Institution.find(@account.institution_id)
    @all_categories = Category.sorted_find_all current_user.default_workgroup
    @transaction_types = TransactionType.all

    @transactions = Transaction.all(find_options)
    @starting_balance = @account.balance(@offset)

    update_action_params

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end

private

  # Sets the sort conditions according the input params
  # Returns an options hash to be passed to the AR find methods.
  #
  # +params+ - params supplied by the user form.
  # +find_options+ - an ActiveRecord find options hash to be extended with sort criteria.
  def get_sort_options( params, find_options )
    find_options[:order] = "date ASC"
    find_options
  end

  # Sets the filter conditions according the input params.
  # Returns an options hash to be passed to the AR find methods.
  #
  # +params+ - params supplied by the user form.
  # +find_options+ - an ActiveRecord find options hash to be extended with filter criteria.
  def get_filter_options( params, find_options )
    # check for category filter
    unless (category_name = params[:category]).blank?
      category = Category.find_by_workgroup_id_and_name(current_user.default_workgroup_id, category_name)
      if category
        find_options[:category_id]=category.id
      end
    end
    find_options
  end

  # determines paging options according to input params.
  # page start can be determined by start date
  # transaction ID, or transaction offset.
  # defaults to last full page if none is specified.
  #
  # +params+ - input params from the user form.  Can be as follows
  #
  #   :offset - direct offset to use.  if the number is negative, the offset is calculated to show the last full page of transactions.
  #   :start_date - sets the page whose first transaction is the first transaction with the start date
  #   :trans_id - sets the page that begins with this transaction id.
  #   :rpp - results per page.  Defaults to 10.
  #
  # +find_options+ - an ActiveRecord find options hash to be extended with paging criteria.  Must contain any filtering and sorting options prior to this method being called.
  def get_paging_options( params, find_options )
    # We need to turn the page defining parameters into an SQL limit and offset

    count_options = find_options.deep_dup
    count_options.delete(:order)

    # check for start_date options
    if !params[:offset].blank?
      @offset = params[:offset].to_i
    elsif !params[:trans_id].blank?
      count_options[:conditions].merge!(:id=>(nil..start_trans_id))
      @offset = Transaction.count(count_options)
    elsif !params[:start_date].blank?
      begin
        start_date = Date.parse(params[:start_date])
        count_options[:conditions].merge!(:date=>(nil..start_date))
        @offset = Transaction.count(count_options)
      rescue
        @offset = 0
      end
    else
      @offset = @account.transactions.count
    end

    @rpp = (params[:rpp] || Transaction.per_page).to_i
    count_options = find_options.deep_dup
    count_options.delete(:order)
    @transaction_count = Transaction.count(count_options)

    # ensure the offset is within appropriate bounds
    if @offset < 0
      @offset = 0
    end
    if @offset + @rpp > @transaction_count
      @offset = @transaction_count - @rpp
    end

    find_options[:limit] = @rpp
    find_options[:offset] = @offset
    find_options
  end

  # update the action params from the class instance variables
  def update_action_params
    params[:rpp] = @rpp
    params[:offset] = @offset
  end

  # # gets filter conditions using date range
  # # and category
  # # Obsolete.
  # def get_filter_conditions
  #   find_options={}
  #   filter_msgs = []
  #   # check for category filter
  #   unless (category_name = params[:category]).blank?
  #     category = Category.find_by_workgroup_id_and_name(current_user.default_workgroup_id, category_name)
  #     if category
  #       find_options[:category_id]=category.id
  #       filter_msgs << "Showing transactions from category '#{category_name}'"
  #     else
  #       filter_msgs << "Category '#{category_name}' does not exist."
  #     end
  #   end
  #
  #   # check for date filter
  #   unless params[:start_date].blank?
  #     begin
  #       @start_date = Date.parse(params[:start_date])
  #     rescue
  #       @start_date = Date.civil(1600,1,1)
  #     end
  #   else
  #     @start_date = Date.today-30.days
  #   end
  #   unless params[:end_date].blank?
  #     @end_date = Date.parse(params[:end_date])
  #   else
  #     @end_date = Date.today + 10.years
  #   end
  #
  #   filter_msgs << "Showing transactions on or before #{@end_date.to_s(:db)}"
  #   filter_msgs << "Showing transactions on or after #{@start_date.to_s(:db)}"
  #   find_options[:date] = (@start_date..@end_date)
  #
  #   flash.now[:notice] = filter_msgs * "<br/>"
  #   find_options
  # end

end
