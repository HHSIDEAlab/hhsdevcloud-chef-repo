#!/usr/bin/env bats

@test "JIRA running" {
  run java -version
  [ "$status" -eq 0 ]
  [[ $output =~ "java version "1.8." ]]
  [[ $output =~ "Java HotSpot(TM) 64-Bit Server VM" ]]
}

