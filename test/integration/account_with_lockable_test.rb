require File.expand_path('../../test_helper', __FILE__)

class AccountWithLockableTest < Redmine::IntegrationTest
  include AccountLockable::TestHelper

  fixtures :users, :email_addresses, :roles

  def test_active_account_of_password_login_user_locked_for_shortly
    normal_user = User.active.find_by_login('jsmith')
    admin_user = User.active.find_by_login('admin')

    [normal_user, admin_user].each do |user|
      with_settings(allow_failed_attempts_2) do
        # 1st, 2nd, 3rd => Failed
        assert_try_login(user, times: 3, locked_times: :last)
        assert_mail_to_locked_account(user)
      end
    end
  end

  def test_active_account_of_password_login_user_locked_finally
    normal_user = User.active.find_by_login('jsmith')
    admin_user = User.active.find_by_login('admin')

    [normal_user, admin_user].each do |user|
      with_settings(allow_failed_attempts_2) do
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

end
