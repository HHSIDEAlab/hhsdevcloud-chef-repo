#!/usr/bin/env bats

@test "JIRA running" {
  run pgrep --full "java.*jira"
  [ "$status" -eq 0 ]
}

