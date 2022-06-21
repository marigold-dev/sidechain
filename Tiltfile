# Setup configurations
config.define_string("nodes", False, "specify number of deku nodes to run")
config.define_string("mode", False, "specify what mode to run in, 'local' (default) or 'docker'")

if config.tilt_subcommand == "down":
  local("nix run .#sandbox tear-down")

cfg = config.parse()

no_of_deku_nodes = int(cfg.get('nodes', "3"))
mode = cfg.get('mode', 'local')

def load_config ():
  if mode == "docker" :
    return load_dynamic('./tilt/Tiltfile.docker')
  else:
    return load_dynamic('./tilt/Tiltfile.local')

symbols = load_config()

add_sandbox = symbols['add_sandbox']
load_deku_services = symbols['load_deku_services']
make_deku_yaml = symbols['make_deku_yaml']

deku_yaml = make_deku_yaml(no_of_deku_nodes)

# Run docker-compose
docker_compose(["./docker-compose.yml", deku_yaml])

dc_resource("db", labels=["tezos"])
dc_resource("elastic", labels=["tezos"])
dc_resource("flextesa", labels=["tezos"])
dc_resource("gui", labels=["tezos"])
dc_resource("api", labels=["tezos"])
dc_resource("metrics", labels=["tezos"])
dc_resource("indexer", labels=["tezos"])

dc_resource("prometheus", labels=["infra"])

load_deku_services(deku_yaml)

add_sandbox(no_of_deku_nodes)

# action to manually trigger a teardown, this should almost never be needed
local_resource(
  "deku-tear-down",
  "nix run .#sandbox tear-down",
  auto_init=False,
  trigger_mode=TRIGGER_MODE_MANUAL,
  labels=["scripts"],
  )
