require File.expand_path('../../test_helper', __FILE__)

class AccountWithLockableTest < Redmine::IntegrationTest
  fixtures :users, :email_addresses, :roles

  def test_active_account_of_password_login_user_locked_for_shortly
    Setting.plugin_redmine_account_lockable[:allow_failed_attempts] = '2'

    user = User.find_by_login('jsmith')
    # 1st => Failed
    post '/login', username: user.login, password: '1234567'
    assert_equal false, user.reload.locked?
    # 2nd => Failed
    post '/login', username: user.login, password: 'abcedfg'
    assert_equal false, user.reload.locked?
    # 3rd => Failed
    post '/login', username: user.login, password: 'hogehoge'
    assert_equal true, user.reload.locked?
  end

  def test_active_account_of_password_login_user_locked_finally
    Setting.plugin_redmine_account_lockable[:allow_failed_attempts] = '2'

    user = User.find_by_login('jsmith')
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
  end

end
