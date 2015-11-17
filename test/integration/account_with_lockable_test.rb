require File.expand_path('../../test_helper', __FILE__)

class AccountWithLockableTest < Redmine::IntegrationTest
  include AccountLockable::TestHelper

  fixtures :users, :email_addresses, :roles

  def test_active_account_of_password_login_user_locked_for_shortly
    normal_user = User.active.find_by_login('jsmith')
    admin_user1 = User.active.find_by_login('admin')
    admin_user2 = User.active.find_by_login('dlopper')
    # User.admin: protected attr
    admin_user2.update_attribute(:admin, true)

    addresses = [
      { to: [normal_user.mail], cc: [admin_user1.mail, admin_user2.mail] },
      { to: [admin_user1.mail], cc: [admin_user2.mail] },
      { to: [admin_user2.mail], cc: [] }
    ]

    [normal_user, admin_user1, admin_user2].each_with_index do |user, i|
      with_settings(allow_failed_attempts_2) do
        # 1st, 2nd, 3rd => Failed(Locked)
        assert_try_login(user, times: 3, locked_times: :last)
        assert_equal_mail_to_locked_account(user, addresses[i])
      end
    end
  end

  def test_active_account_of_password_login_user_locked_finally
    normal_user = User.active.find_by_login('jsmith')
    admin_user = User.active.find_by_login('admin')

    addresses = [
      { to: [normal_user.mail], cc: [admin_user.mail] },
      { to: [admin_user.mail], cc: [] }
    ]

    [normal_user, admin_user].each_with_index do |user, i|
      with_settings(allow_failed_attempts_2) do
        # 1st, 2nd => Failed
        assert_try_login(user, times: 2, locked_times: :none)
        # 3rd => Success
        assert_try_login(user, password: user.login)
        post '/logout'
        # 4th, 5th, 6th => Failed(Locked)
        assert_try_login(user, times: 3, locked_times: :last)
        assert_equal_mail_to_locked_account(user, addresses[i])
      end
    end
  end

  def test_registered_account_of_password_login_user_ignored
    registered_user = User.active.find_by_login('miscuser8')
    registered_user.update(status: User::STATUS_REGISTERED)

    with_settings(allow_failed_attempts_2) do
      # 1st, 2nd, 3rd => Failed(Ignored)
      assert_try_login(registered_user, times: 3, locked_times: :none)
      assert_not_equal_mail_to_locked_account(registered_user)
    end
  end

  def test_locked_account_of_password_login_user_ignored
    locked_user = User.active.find_by_login('miscuser9')
    locked_user.update(status: User::STATUS_LOCKED)

    with_settings(allow_failed_attempts_2) do
      # 1st, 2nd, 3rd => Failed(Ignored)
      assert_try_login(locked_user, times: 3, locked_times: :all)
      assert_not_equal_mail_to_locked_account(locked_user)
    end
  end

end
