name "server"
description "example web server role"

run_list(
  "recipe[zendserver::server]"
)

default_attributes()
override_attributes()

