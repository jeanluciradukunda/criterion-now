#!/usr/bin/env bash
# Fails when a workflow uses a third-party action by tag or branch instead of a full commit SHA.
set -u
cd "$(dirname "$0")/../.."
ruby -ryaml -e '
  bad = []
  Dir[".github/workflows/*.{yml,yaml}"].sort.each do |file|
    jobs = (YAML.load_file(file) || {})["jobs"] || {}
    jobs.each do |name, job|
      refs = [job["uses"]] + (job["steps"] || []).map { |step| step["uses"] }
      refs.compact.each do |ref|
        next if ref.start_with?("./", "docker://")
        bad << "#{file} (#{name}): #{ref}" unless ref =~ /@[0-9a-f]{40}\z/
      end
    end
  end
  if bad.empty?
    puts "ok: every action is pinned to a commit SHA"
  else
    puts "Actions not pinned to a commit SHA:", bad
    exit 1
  end
'
