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

  end
end
