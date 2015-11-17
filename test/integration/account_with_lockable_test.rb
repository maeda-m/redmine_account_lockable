require File.expand_path('../../test_helper', __FILE__)

class AccountWithLockableTest < Redmine::IntegrationTest
  include AccountLockable::TestHelper

  fixtures :users, :email_addresses, :roles

  def test_active_account_of_password_login_user_locked_for_shortly
    with_settings(allow_failed_attempts_2) do
      user = User.active.find_by_login('jsmith')

      # 1st, 2nd, 3rd => Failed
      assert_try_login(user, times: 3, locked_times: :last)
      assert_mail_to_locked_account(user)
    end
  end

  def test_active_account_of_password_login_user_locked_finally
    with_settings(allow_failed_attempts_2) do
      user = User.active.find_by_login('jsmith')

      # 1st, 2nd => Failed
      assert_try_login(user, times: 2)
      # 3rd => Success
      assert_try_login(user, password: user.login)
      # 4th => Failed
      post '/logout'
      assert_try_login(user, times: 3, locked_times: :last)
      assert_mail_to_locked_account(user)
    end
  end

end
