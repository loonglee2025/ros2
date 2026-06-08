#!/usr/bin/env zsh
# vim: set ft=zsh:
# =============================================================================
# aliases/bag.zsh — ros2 bag shortcuts
# Prefix: rb (ros2 bag)
# WARNING: These are safe read-only by default. Record commands require explicit args.
# =============================================================================
# Foxy compatibility: all bag verbs exist in Foxy.
# =============================================================================

alias rbi='ros2 bag info'                      # Show bag info (needs arg)
alias rbp='ros2 bag play'                      # Play a bag (needs arg)
alias rbl='ros2 bag list'                      # List bags in a directory

# Jazzy+: service recording aliases (also in jazzy-compat.zsh)
# These are duplicated here for discoverability when jazzy-compat is not loaded
if _ros2_distro_at_least "jazzy" 2>/dev/null; then
  alias rbsr='ros2 bag record --service'       # Record specific services
  alias rbsa='ros2 bag record --all-services'  # Record all services
  alias rbps='ros2 bag play --publish-service-requests'  # Play with service requests
fi
