# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

module AccountLockable
  module TestHelper
    include Redmine::I18n

    def allow_failed_attempts_2
      {
        bcc_recipients: '0',
        default_language: 'en',
        plugin_redmine_account_lockable: {
          allow_failed_attempts: '2'
        }
      }
    end

    def assert_try_login(user, times: 1, locked_times: :none, password: nil)
      password ||= ('a'..'z').to_a.sample(12).join
      if locked_times.is_a?(Symbol)
        locked_times = case locked_times
          when :all
            (1..times).to_a
          when :last
            [ times ]
          when :none
            []
          end
      end

      times.times do |i|
        locked = locked_times.include?(i.next)

        post '/login', username: user.login, password: password
        assert_equal locked, user.reload.locked?
      end
    end

    def assert_equal_mail_to_locked_account(locked_user, address)
      mail = ActionMailer::Base.deliveries.last

      assert_not_nil mail
      assert_equal address[:to], mail.to
      assert_equal address[:cc], mail.cc
      assert_equal nil, mail.bcc
      assert_equal mail.subject, l(:text_account_locked_subject, user: locked_user.login)
    end

    def assert_not_equal_mail_to_locked_account(user)
      mail = ActionMailer::Base.deliveries.last
      assert_not_equal mail.try(:subject), l(:text_account_locked_subject, user: user.login)
    end

  end
end
