# AGENTS.md — noskvabbel

Guidance for AI coding agents working in this repository. Inspired by the
AGENTS.md files of public Rails-ecosystem projects (rails/rails, Shopify's
ruby-lsp) and the 37signals development philosophy (vanilla Rails first,
rich models, thin controllers, minimal gems).

## Project overview

Noskvabbel is a small Ruby on Rails app for tracking shared expenses between
the two people in a "couple".

- **Stack**: Ruby 4.0.10 (pinned in `Gemfile` and `.ruby-version`), Rails 8.1
  (`config.load_defaults 8.1`), SQLite, Puma, importmap-rails + Turbo,
  ERB views.
- **Auth**: Authlogic (`acts_as_authentic`) with SCrypt — see `User` and
  `UserSession`.
- **Domain model**: `User` belongs to an optional `Couple`; a `Couple` has
  exactly zero or two users; an `Expense` belongs to a `user` (who it is for)
  and a `created_by` user. Plain `app/services` classes exist for import/parsing
  helpers (`ExpenseAttributesPreparator`, `QueryResultParser`).
- **Routes**: RESTful `resources :expenses, :user_sessions` plus
  `login`/`logout`/`account`; root is `expenses#index`.

## Commands

```bash
bin/setup                 # fresh-clone setup (bundle, prepare DBs)
bin/dev                   # start the app (server + asset watching)
bin/rails console         # console

bin/rspec                 # run the whole RSpec suite
bin/rspec spec/models/expense_spec.rb        # one file
bin/rspec spec/models/expense_spec.rb:12     # one example by line
bin/rubocop               # lint (rubocop + rubocop-rails + rubocop-rspec)
bin/rubocop -a            # lint with safe auto-fixes
bin/importmap audit       # JS dependency vulnerability audit
bundle exec brakeman      # static security analysis (no binstub; not part of bin/ci)
bin/ci                    # full local CI: setup, rubocop, importmap audit, tests, seed replant
```

Test-database gotcha: Authlogic inspects the `users` table when `User` first
loads, so on a fresh clone the test DB must exist **before** the app boots.
`spec/rails_helper.rb` handles this automatically; if you boot the app or
console manually on a fresh clone, run `bin/rails db:test:prepare` first.

## Testing conventions

- The primary suite is **RSpec** under `spec/` (models, requests, helpers),
  with `factory_bot` factories in `spec/factories`, Faker for fake data, and
  Capybara/Selenium available for system specs. Spec types are inferred from
  file location; transactional fixtures are on; `maintain_test_schema!` keeps
  the test schema in sync.
- Prefer request specs for controller behavior and model specs for domain
  rules (e.g. the couple-must-have-zero-or-two-users validation).
- Every behavior change should come with a spec. Run `bin/rspec` before
  considering a task done.

## Code conventions

- Every Ruby file starts with `# frozen_string_literal: true`. Single quotes
  for strings unless interpolation is needed. Two-space indent. Run
  `bin/rubocop` and keep the tree clean.
- Follow Rails conventions and "vanilla Rails is plenty": use what the
  framework provides before reaching for a gem or a custom abstraction.
  Do not add dependencies without a clear need — discuss first.
- Keep controllers thin and CRUD-shaped; put domain logic, validations, and
  queries in models (use concerns in `app/models/concerns` and
  `app/controllers/concerns` for horizontal sharing). Match the existing
  style of each file you touch; make minimal diffs.
- Views are ERB with Turbo; JavaScript is managed through importmap
  (`config/importmap.rb`) — `package.json`/webpacker are legacy leftovers,
  do not build on them. The jQuery/RJS era is fully cleaned up: there are no
  `.js.rjs` templates left, so new remote behavior should use plain
  Turbo-driven ERB.
- If a prebuilt Tailwind/DaisyUI CSS file is vendored into
  `app/assets/stylesheets` (built once with the Tailwind CLI run from the repo
  root — there is no watcher), keep `config.assets.css_compressor = nil`: the
  sassc-rails default CSS compressor cannot parse Tailwind v4 output (range
  media queries, `oklch`, …) and fails every page that links the stylesheet.
  Re-run the CLI from the repo root whenever classes in `app/views` change so
  the new classes get compiled in.
- Keep native HTML form validation in sync with the model validations
  (`required`, `min`, `step`): invalid input should be rejected by the browser
  instead of after a server round trip. Beware silent model-side defaults —
  `Expense#spent_on` falls back to today when submitted empty.
- Icon-only buttons (e.g. the navbar hamburger) need an accessible name:
  `aria-label` backed by an i18n key. And chrome that only makes sense when
  logged in (Account/Logout dropdown) must be wrapped in
  `<% if current_user %>` — check the logged-out rendering of every page
  against the mockups, not just the happy path.
- Migrations: one change per migration, timestamped files in `db/migrate`,
  update `db/schema.rb` by running them; never edit old migrations.

## Security and data boundaries

- **Scope everything to the current user's couple.** `ExpensesController`
  already guards with `verify_the_user_is_in_couple`, and `destroy` already
  loads through `current_user.couple.expenses`, but the `show`, `edit`, and
  `update` actions still use bare `Expense.find` (see the TODOs there). When
  touching those actions, load through `current_user.couple.expenses` instead
  of `Expense.find(params[:id])`.
- Never commit secrets or local data: `db/*.sqlite3`, `log/`, `tmp/`,
  `config/master.key`, credentials, and `public/assets/` are gitignored —
  keep them that way. Run `bin/importmap audit` after touching JS dependencies
  and `bundle exec brakeman` for security recommendations.

## Git workflow

- Short, imperative commit subjects (see history: "Bump puma…", "Upgrade to
  Ruby 4.0.10…"). Group related changes in one commit; do not commit generated
  or local files.
- Keep changes reviewable and incremental — one logical change per commit.

## Boundaries (do not)

- Do not restructure the app, rename the module (`Newskvabbel`), or replace
  Authlogic/RSpec/SQLite/importmap.
- Do not add gems, background-job infrastructure, or new frontend frameworks.
- Do not "fix" unrelated style across the codebase; only touch what the task
  requires.
