# frozen_string_literal: true

task default: :ci

task ci: %i[lint specs]

task :lint do
  sh "bundle exec rubocop -d"
end

task :specs do
  sh "bundle exec rspec"
end
