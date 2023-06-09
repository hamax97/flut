# frozen_string_literal: true

task default: :ci

task ci: %i[lint specs]

task :lint do
  sh "bundle exec rubocop"
end

task :specs do
  sh "bundle exec rspec"
end
