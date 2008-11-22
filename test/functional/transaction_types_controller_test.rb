require 'test_helper'

class TransactionTypesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:transaction_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_transaction_type
    assert_difference('TransactionType.count') do
      post :create, :transaction_type => { }
    end

    assert_redirected_to transaction_type_path(assigns(:transaction_type))
  end

  def test_should_show_transaction_type
    get :show, :id => transaction_types(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => transaction_types(:one).id
    assert_response :success
  end

  def test_should_update_transaction_type
    put :update, :id => transaction_types(:one).id, :transaction_type => { }
    assert_redirected_to transaction_type_path(assigns(:transaction_type))
  end

  def test_should_destroy_transaction_type
    assert_difference('TransactionType.count', -1) do
      delete :destroy, :id => transaction_types(:one).id
    end

    assert_redirected_to transaction_types_path
  end
end
