# frozen_string_literal: true

task default: :ci

task ci: %i[lint specs]

task cd: %i[acceptance_specs]

task :lint do
  sh "bundle exec rubocop"
end

task :specs do
  sh "bundle exec rspec --pattern spec/unit/**/*_spec.rb"
end

task :acceptance_specs do
  sh "bundle exec rspec --pattern spec/acceptance/**/*_spec.rb"
end
