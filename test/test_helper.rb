# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

module AccountLockable
  module TestHelper
    include Redmine::I18n

    def default_redmine_settings
      {
        bcc_recipients: '0',
        default_language: 'en'
      }
    end

    def allow_failed_attempts_2
      default_redmine_settings.merge(
        plugin_redmine_account_lockable: {
          allow_failed_attempts: '2'
        })
    end

    def assert_try_login(user, times: 1, locked_times: nil, password: nil)
      password ||= ('a'..'z').to_a.sample(12).join
      if locked_times.is_a?(Symbol)
        locked_times = times if :last == locked_times
      end

      times.times do |i|
        locked = i.next == locked_times

        post '/login', username: user.login, password: password
        assert_equal locked, user.reload.locked?
      end
    end

    def assert_mail_to_locked_account(locked_user)
      mail = ActionMailer::Base.deliveries.last

      to_address = [ locked_user.mail ]
      cc_address = User.active.where(admin: true).map(&:mail)
      bcc_address = nil

      if Setting.bcc_recipients?
        bcc_address = (to_address + cc_address).uniq
        to_address = nil
        cc_address = nil
      end

      assert_not_nil mail
      assert_equal to_address, mail.to
      assert_equal cc_address, mail.cc
      assert_equal bcc_address, mail.bcc
      assert_equal mail.subject, l(:text_account_locked_subject, user: locked_user.login)
    end

  end
end
