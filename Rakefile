# frozen_string_literal: true

task default: :ci

task ci: %i[lint specs]

task :lint do
  sh "rubocop"
end

task :specs do
  sh "rspec"
end
