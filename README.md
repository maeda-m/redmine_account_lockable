# Redmine Account Lockable

Redmine plugin for locking of account at failed login.

## Usage

Set the count of allow failed logins in the setting of Redmine administrator.

## Supported versions

Redmine 3.1.x

## Install

`git clone` to `plugins/redmine_account_lockable` on your Redmine path.

```
$ git clone https://github.com/maeda-m/redmine_account_lockable.git /path/to/your-redmine/plugins/redmine_account_lockable
```

Then, migrate:

```
$ cd /path/to/your-redmine
$ rake redmine:plugins:migrate NAME=redmine_account_lockable RAILS_ENV=production
```

That's all.

## Uninstall

At first, rollback schema:

```
$ cd /path/to/your-redmine
$ rake redmine:plugins:migrate NAME=redmine_account_lockable VERSION=0 RAILS_ENV=production
```

Then, remove `plugins/redmine_account_lockable` directory.

## Contribute

### How to test

TODO

### Pull Request

  1. Fork it
  2. Create your feature branch: `git checkout -b new-feature`
  3. Commit your changes: `git commit -am 'add some new feature'`
  4. Push to the branch: `git push origin new-feature`
  5. Create new Pull Request

### Report bugs

Please report from [here](https://github.com/maeda-m/redmine_account_lockable/issues/new).

## Copyright

See MIT-LICENSE for further details.