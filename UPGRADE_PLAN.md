# Upgrade Plan: Ruby 4.0.9 + Rails 8.1 + green RSpec suite

> Self-contained plan. A fresh session should be able to read this file, verify the
> baseline, and execute the phases in order without re-doing the investigation.

## Goal

1. Upgrade the Ruby interpreter to the **latest stable MRI available through RVM**:
   **Ruby 4.0.9** (4.1.0-preview1 exists but is a preview; do not target prereleases).
2. Upgrade to the **latest stable Ruby on Rails**: **Rails 8.1.4.1**, including
   adopting the **new framework defaults** (`config.load_defaults 8.1`).
3. Fix the **RSpec suite** so all examples pass.

## Baseline (verified 2026-11-07)

| Item                    | Current value                                             |
|-------------------------|-----------------------------------------------------------|
| Ruby                    | 3.2.2, pinned in `Gemfile` (`ruby '3.2.2'`); no `.ruby-version` file |
| Rails                   | 7.2.3 (Gemfile: `gem 'rails', '~> 7'`)                    |
| Framework defaults      | `config.load_defaults 6.1` in `config/application.rb`; orphaned `config/initializers/new_framework_defaults_7_0.rb` (7.0 defaults never adopted) |
| rspec-rails             | 5.0.3 (dev/test group, pinned `~> 5.0.0`)                 |
| Test suite result       | 0 examples run, 6 load errors: `NoMethodError: undefined method 'fixture_path=' for <example group>:Class` in every spec file |
| Working tree            | `db/schema.rb` is modified and uncommitted                  |
| Other rubies installed  | 3.2.2 (project), 3.3.13 (RVM default), 3.3.11             |
| Legacy test tree        | `test/` (Minitest) exists; out of scope, keep as is      |

**Root cause of the RSpec failures:** rspec-rails 5.0.3 assigns
`ActiveSupport::TestCase#fixture_path=`, which Rails 7.1+ removed, so every spec
file dies at load time. Fixing this requires rspec-rails >= 6; we target 8.1.0.

### Environment gotcha: RVM

The user's RVM was installed years ago and its known-rubies list is stale. To see
Ruby 4.x entries you MUST refresh RVM first with `rvm get master`. Two gotchas:

- `rvm get master` requires a TTY. In non-interactive shells (e.g. a sandboxed
  agent shell) it fails with a descriptor error and silently leaves the list
  stale. Workaround used successfully:
  `script -qec "rvm get master" /dev/null`
- Verify with `rvm list known`: it must show `[ruby-]4[.0.9]` before installing.

Target versions confirmed via ruby-lang.org and rubygems.org (2026-11-07):
Ruby 4.0.9 (latest stable MRI), Rails 8.1.4.1 (latest stable, `ruby >= 3.2.0`),
rspec-rails 8.1.0 (latest stable).

## Phase 1 — Safety and branch

1. Check `git status`. Commit the pending `db/schema.rb` change on `master`
   (message like "Regenerate schema"). Do not discard it.
2. Create and switch to a branch: `git switch -c upgrade/rails-8.1-ruby-4.0.9`
3. Keep one commit per phase (see Phase 5) so every step is revertible.

## Phase 2 — Ruby 4.0.9 via RVM

1. Refresh RVM and install (TTY workaround if needed):
   ```sh
   script -qec "rvm get master" /dev/null   # or plain `rvm get master` in a terminal
   rvm list known                           # must list 4.0.9
   rvm install 4.0.9
   rvm use 4.0.9 --default
   ```
2. Edit `Gemfile`: replace `ruby '3.2.2'` with `ruby '4.0.9'`.
   Create `.ruby-version` at the repo root containing: `ruby-4.0.9`
3. Install tooling and re-resolve dependencies:
   ```sh
   gem update --system
   gem install bundler
   bundle install
   ```
4. **Native-extension audit** — Ruby 4.0 is a major version; expect deprecated
   C-API removals. Gems to check, highest risk first:
   - `scrypt` 3.1.0 (used by authlogic for password crypto). If it will not build
     on 4.0 or no compatible release exists, switch authlogic to a different
     crypto provider (e.g. bcrypt via the `bcrypt` gem) — this changes
     `config/initializers` / User model setup and existing password hashes.
   - `sassc` 2.4.0 / `sass-rails` 6 (unmaintained libsass chain). If broken on 4.0,
     migrate stylesheets to plain CSS or `dartsass-rails`.
   - `sqlite3` (bump to `~> 2.2` anyway in Phase 3), `nokogiri`, `puma`,
     `bootsnap` — usually have current releases; bump as needed.
   - `byebug` — replace with the `debug` gem (Rails 8 default) if it fails.
5. Sanity check before touching Rails (still 7.2.3 at this point):
   ```sh
   bundle exec rails runner 'puts Rails.version'
   ```
   It must boot under Ruby 4.0.9. Full test run is NOT expected to work yet
   (rspec-rails 5 is broken regardless); validation happens in Phase 4.
6. Commit: "Upgrade Ruby to 4.0.9 via RVM".

## Phase 3 — Rails 8.1 and new framework defaults

### 3.1 Gemfile edits

- `gem 'rails', '~> 7'` → `gem 'rails', '~> 8.1'`
- dev/test group: `gem 'rspec', '~> 3.0'` → `~> 3.13`;
  `gem 'rspec-rails', '~> 5.0.0'` → `~> 8.0`
- `gem 'sqlite3', '~> 1.5'` → `~> 2.2` (Rails 8 uses sqlite3 2.x)
- Remove `gem 'spring'` (dead project), plus `config/spring.rb` and any
  spring references in `bin/`.
- Remove `gem 'webdrivers'` (deprecated; selenium-webdriver >= 4.11 manages
  drivers itself via Selenium Manager).
- Replace `gem 'byebug'` with `gem 'debug'` if it was problematic on 4.0.
- Bump `gem 'importmap-rails', '~> 1.1'` → `~> 2.0`.
- Keep `puma '~> 6'` (compatible with Rails 8), `sass-rails`, `turbolinks`,
  `jbuilder`, `authlogic` for now.

### 3.2 Resolve and update

```sh
bundle update rails rspec-rails sqlite3 importmap-rails selenium-webdriver
bundle install   # then a full `bundle update` only if still needed
```

### 3.3 app:update

Run `bin/rails app:update` and resolve every config diff interactively:
- Keep local choices where the app deviates intentionally (authlogic setup,
  `routes.rb` content, `config/database.yml` sqlite paths).
- Adopt upstream otherwise. Pay attention to `config/environments/*.rb`,
  `config/puma.rb`, `config/importmap.rb`, `bin/` stubs.

### 3.4 Framework defaults

The app is four defaults generations behind (6.1 → 7.0 → 7.1 → 7.2 → 8.0 → 8.1).
Go straight to the final state:

1. In `config/application.rb`: `config.load_defaults 6.1` → `config.load_defaults 8.1`.
2. Delete `config/initializers/new_framework_defaults_7_0.rb` (its contents are
   superseded by load_defaults 8.1; if it contains hand-edits, review them first).
3. Audit the app against the changed defaults from every skipped generation.
   Minimum review list:
   - 7.1: `config.active_support.cache_format_version = 7.1` / new cache format;
     `ActiveSupport::Deprecation.warn` behaviors; `params` API changes;
     `ActiveRecord::Base.normalizes`; encryption defaults.
   - 7.2: `config.action_dispatch.debug_exceptions_limit`, Active Storage
     preview processing changes, `config.active_support.isolation_level`.
   - 8.0: new Active Storage video/image variation defaults, `params.expect`
     over `params.require`, Strong Parameters API changes, HTTPS/assume_ssl in
     production, `config.active_record.default_column_serializer`.
   - 8.1: review the 8.1 release notes for actionable defaults.
   The controllers (`expenses_controller.rb`, `user_sessions_controller.rb`) use
   `params.require`-style code — check whether they trigger deprecations and
   migrate to `params.expect` where warranted.

### 3.5 Database

```sh
bin/rails db:prepare      # dev + test with sqlite3 2.x
```
`db/schema.rb` / migrations otherwise unchanged for this app.

## Phase 4 — RSpec green

1. Update `spec/rails_helper.rb`:
   - Replace `config.fixture_path = "#{::Rails.root}/spec/fixtures"` with
     `config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]`
     (or remove it entirely — the app has no `spec/fixtures` directory).
   - Keep `config.use_transactional_fixtures = true` and
     `config.infer_spec_type_from_file_location!`.
   - The custom in-memory sqlite hack at the bottom of rails_helper
     (`establish_connection(:memory:)` + `load db/schema.rb`) should still work;
     verify, and simplify if it fights with Rails 8.
2. Run `bundle exec rspec`. The six `fixture_path=` load errors must disappear
   with rspec-rails 8. Then fix remaining behavioral failures. Known spec files:
   - `spec/models/couple_spec.rb`, `expense_spec.rb`, `user_spec.rb`
     (use `attributes` key checks and `respond_to` — likely fine;
     watch authlogic-backed `user_spec` under Rails 8).
   - `spec/helpers/expenses_helper_spec.rb`.
   - `spec/requests/expenses_spec.rb`, `user_sessions_spec.rb` — these are
     **empty generator stubs** containing only pending examples. Implement basic
     CRUD / login flows there, since the controllers exist; this exercises the
     new defaults end to end. If left as stubs they trivially "pass" but test nothing.
3. Watch for authlogic 6.6 deprecation warnings under Rails 8 (session handling,
  `UserSession` API). Bump authlogic if a newer release supports Rails 8.
4. Out of scope: the legacy `test/` (Minitest) tree is not part of this task;
   leave it or remove it only with explicit user approval.

## Phase 5 — Verification and commits

Acceptance criteria — all must hold:

- `bundle exec rspec` → 0 failures, examples actually run (not all pending).
- `bin/rails zeitwerk:check` → no errors.
- `bin/rails runner 'puts Rails.version'` → `8.1.4.1` (or latest 8.1.x).
- `ruby -v` → `4.0.9` when the project directory is the CWD (`.ruby-version`).
- App boots with `bin/rails server`; smoke-test login and an expense page.
- No new deprecation warnings specific to this app's code in the test run
  (framework-internal noise tolerable).

Commit sequence (one per phase, plus fixes):

1. "Upgrade Ruby to 4.0.9 via RVM"
2. "Upgrade Rails to 8.1 with new framework defaults"
3. "Fix RSpec suite for Rails 8.1"

## Risks and fallback

| Risk                                            | Mitigation                                                                 |
|-------------------------------------------------|----------------------------------------------------------------------------|
| `scrypt` 3.1.0 will not build/run on Ruby 4.0    | Switch authlogic crypto provider (bcrypt); requires migration plan for existing password hashes |
| `sassc`/`sass-rails` chain dead on Ruby 4.0      | Migrate to plain CSS or `dartsass-rails`                                    |
| Rails 8.1.4.1 or a blocking gem fails on Ruby 4.0 | **Fallback clause:** split delivery — first land Ruby 3.4.12 (latest stable 3.x) + Rails 8.1 + green RSpec as one known-good state, then bump to 4.0.9 as a final standalone commit |
| Behavior changes from four skipped defaults generations | The direct-to-8.1 jump relies on the small app surface (3 models, 3 controllers); request specs in Phase 4.2 are the safety net |
| Ruby 4.1 / 3.5 previews                         | Never target prereleases; 4.1.0 stable later would be a minor bump          |

## Historical note (why this plan targets 4.0.9)

Ruby 4.x is a newer major line than 3.4 (`rvm get master` is required for RVM to
even list it — stale bundled lists top out at 3.4.12 / 3.5.0-preview1).
4.0.9 is the latest stable release in the 4.0 series; 4.1.0 is at preview1.
"Latest stable MRI" therefore means **Ruby 4.0.9**.
