require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:transactions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_transaction
    assert_difference('Transaction.count') do
      post :create, :transaction => { }
    end

    assert_redirected_to transaction_path(assigns(:transaction))
  end

  def test_should_show_transaction
    get :show, :id => transactions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => transactions(:one).id
    assert_response :success
  end

  def test_should_update_transaction
    put :update, :id => transactions(:one).id, :transaction => { }
    assert_redirected_to transaction_path(assigns(:transaction))
  end

  def test_should_destroy_transaction
    assert_difference('Transaction.count', -1) do
      delete :destroy, :id => transactions(:one).id
    end

    assert_redirected_to transactions_path
  end
end
