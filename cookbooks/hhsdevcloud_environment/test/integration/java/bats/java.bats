#!/usr/bin/env bats

@test "JRE 8 on path" {
  run java -version
  [ "$status" -eq 0 ]
  [[ $output =~ "java version \"1.8." ]]
  [[ $output =~ "Java HotSpot(TM) 64-Bit Server VM" ]]
}

@test "JDK 8 on path" {
  run javac -version
  [ "$status" -eq 0 ]
  [[ $output =~ "javac 1.8." ]]
}

