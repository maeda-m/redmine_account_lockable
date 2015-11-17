require File.expand_path('../../test_helper', __FILE__)

class AccountWithLockableTest < Redmine::IntegrationTest
  include AccountLockable::TestHelper

  fixtures :users, :email_addresses, :roles

  def test_active_account_of_password_login_user_locked_for_shortly
    with_settings(allow_failed_attempts_2) do
      default_admin = User.active.find_by_login('admin')
      user = User.active.find_by_login('jsmith')

      # 1st => Failed
      post '/login', username: user.login, password: '1234567'
      assert_equal false, user.reload.locked?
      # 2nd => Failed
      post '/login', username: user.login, password: 'abcedfg'
      assert_equal false, user.reload.locked?
      # 3rd => Failed
      post '/login', username: user.login, password: 'hogehoge'
      assert_equal true, user.reload.locked?

      mail = ActionMailer::Base.deliveries.last
      assert_not_nil mail
      assert_equal [user.mail], mail.to
      assert_equal [default_admin.mail], mail.cc
      assert_equal mail.subject, l(:text_account_locked_subject, user: user.login)
    end
  end

  def test_active_account_of_password_login_user_locked_finally
    with_settings(allow_failed_attempts_2) do
      default_admin = User.active.find_by_login('admin')
      user = User.active.find_by_login('jsmith')

      # 1st => Failed
      post '/login', username: user.login, password: '1234567'
      assert_equal false, user.reload.locked?
      # 2nd => Failed
      post '/login', username: user.login, password: 'abcedfg'
      assert_equal false, user.reload.locked?
      # 3rd => Success
      post '/login', username: user.login, password: user.login
      assert_equal false, user.reload.locked?

      # 4th => Failed
      post '/logout'
      post '/login', username: user.login, password: ''
      assert_equal false, user.reload.locked?
      # 5th => Failed
      post '/login', username: user.login, password: '1234567'
      assert_equal false, user.reload.locked?
      # 6th => Failed
      post '/login', username: user.login, password: 'abcedfg'
      assert_equal true, user.reload.locked?

      mail = ActionMailer::Base.deliveries.last
      assert_not_nil mail
      assert_equal [user.mail], mail.to
      assert_equal [default_admin.mail], mail.cc
      assert_equal mail.subject, l(:text_account_locked_subject, user: user.login)
    end
  end

end
