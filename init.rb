Redmine::Plugin.register :redmine_account_lockable do
  name 'Redmine Account Lockable plugin'
  author 'maeda-m'
  description 'Plug-in that automatically lock the account in the count of failed logins.'
  version '1.0.0'
  requires_redmine version_or_higher: '3.1.0'
  url 'https://github.com/maeda-m/redmine_account_lockable'
  author_url 'https://github.com/maeda-m'

  settings(partial: 'settings/form',
    default: {
      allow_failed_attempts: 5
    })
end

require_relative 'lib/account_lockable'
