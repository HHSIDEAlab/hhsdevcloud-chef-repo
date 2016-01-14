#!/usr/bin/env bats

# To verify LDAP auth, run something like this:
# ldapsearch -x -D "uid=karldavis,ou=people,dc=hhsdevcloud,dc=us" -W -H ldapi:/// -b "dc=hhsdevcloud,dc=us"

@test "LDAP directory query works" {
  run ldapsearch -x -D "cn=admin,dc=hhsdevcloud,dc=us" -w hhs_secret -H ldapi:/// -b "dc=hhsdevcloud,dc=us"
  [ "$status" -eq 0 ]
  [[ $output =~ "numEntries: " ]]
}

@test "LDAP directory has 'people' OU" {
  run ldapsearch -x -D "cn=admin,dc=hhsdevcloud,dc=us" -w hhs_secret -H ldapi:/// -b "dc=hhsdevcloud,dc=us" "(ou=people)"
  [ "$status" -eq 0 ]
  [[ $output =~ "numEntries: 1" ]]
}

@test "LDAP auth works" {
  skip "Need a test user and the ability to store its passwor as a secret"
  run ldapsearch -x -D "uid=testuser,ou=people,dc=hhsdevcloud,dc=us" -w "secret_password" -H ldapi:/// -b "dc=hhsdevcloud,dc=us"
  [ "$status" -eq 0 ]
  [[ $output =~ "numEntries: " ]]
}

