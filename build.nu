#!/usr/bin/env nu

# Determine the container engine to use
# Available options: docker, podman
#
# Environment Variables:
#   $env.CONTAINER_ENGINE (string, optional) specified preferred container engine
export def "get container-engine" [] : nothing -> string {
  let configured_engine = ($env.CONTAINER_ENGINE? | default "")
  let container_engine = if not ($configured_engine | is-empty) {
    $configured_engine
  } else if (which podman | is-not-empty) {
    "podman"
  } else if (which docker | is-not-empty) {
    "docker"
  } else {
    error make {msg: "neither podman nor docker is available"}
  }

  if (which $container_engine | is-empty) {
    error make {msg: $"container engine '($container_engine)' is not available"}
  }

  $container_engine
}

# Build a Dash docset for Rocq
#
# Environment Variables:
#   $env.CONTAINER_ENGINE (string, optional) specified preferred container engine
def main [rocq_ver: string = "9.2.0"] {
  let version_tag = ($rocq_ver | str replace -a "+" "-")
  let image = $"rocq-docset-dash-image:($version_tag)"
  let container = $"rocq-docset-dash-container-($version_tag)"
  let target = (["build" $"dash-docset-rocq-($version_tag)"] | path join)
  let docset = ([$target "Rocq.docset"] | path join)

  let container_engine = get container-engine

  cd ($env.FILE_PWD? | default $env.PWD)

  let exists = (do -i { ^$container_engine container exists $container } | complete)
  if $exists.exit_code == 0 {
    error make {msg: $"container '($container)' already exists"}
  }

  ^$container_engine build -t $image --build-arg $"ROCQ_VER=($rocq_ver)" .
  ^$container_engine create --name $container $image /bin/sh

  try {
    mkdir $target
    rm -rf $docset
    ^$container_engine cp $"($container):/rocq/Rocq.docset" $target

    {
      name: "Rocq"
      revision: "0"
      title: "Rocq"
      version: $rocq_ver
    } | to json | save -f ([$docset "meta.json"] | path join)

    ^python3 tools/edit_info_plist.py ([$docset "Contents" "Info.plist"] | path join) $rocq_ver
    ^python3 tools/remove_absent_link.py $docset
  } catch { |err|
    try {
      ^$container_engine rm -f $container | ignore
    }

    error make $err
  }

  ^$container_engine rm -f $container | ignore
  print $"Success: docset saved to ($target)"
  print "Note: this script does not delete the container image"
  print $"Execute '($container_engine) rmi ($image)' manually to remove it"
}
