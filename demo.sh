#!/usr/bin/env bash
set -eu

function SQL {
  echo "$@;"
  echo -e "sql> \e[32m$@;\e[39m" > /dev/stderr
}

function EXECUTE {
  psql demo -U demo
}

function QUERY {
  SQL "$@" | EXECUTE
}

: "Prepare tables" && {
  : "Create a table in public schema" && {
    QUERY "CREATE TABLE IF NOT EXISTS bar (name text NOT NULL)"
  }
  : "Create a new schema: foo" && {
    QUERY "CREATE SCHEMA IF NOT EXISTS foo"
  }
  : "Create a table in the foo schema" && {
    QUERY "CREATE TABLE IF NOT EXISTS foo.bar (name text NOT NULL)"
  }
  : "Delete data" && {
    QUERY "TRUNCATE TABLE bar"
    QUERY "TRUNCATE TABLE foo.bar"
  }
}

: "Demo: transaction across two schemas" && {
  : "Begin and commit" && {
    SQL "BEGIN"
    SQL "INSERT INTO bar (name) VALUES ('#1 add to public.bar')"
    SQL "INSERT INTO foo.bar (name) VALUES ('#1 add to foo.bar')"
    SQL "COMMIT"
    SQL "SELECT * FROM bar UNION ALL SELECT * FROM foo.bar"
  } | EXECUTE

  : "Begin and rollback" && {
    SQL "BEGIN"
    SQL "INSERT INTO bar (name) VALUES ('#2 add to public.bar')"
    SQL "INSERT INTO foo.bar (name) VALUES ('#2 add to foo.bar')"
    SQL "SELECT * FROM bar UNION ALL SELECT * FROM foo.bar"
    SQL "ROLLBACK"
    SQL "SELECT * FROM bar UNION ALL SELECT * FROM foo.bar"
  } | EXECUTE
}
