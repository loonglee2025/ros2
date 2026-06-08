#!/usr/bin/env zsh
# vim: set ft=zsh:
# =============================================================================
# aliases/service.zsh — ros2 service shortcuts
# Prefix: rs (ros2 service)
# =============================================================================
# Foxy compatibility: all core service verbs exist in Foxy.
# =============================================================================

alias rsl='ros2 service list'                  # List all services
alias rslt='ros2 service list -t'              # List services with types
alias rsi='ros2 service info'                  # Service info (needs arg)
alias rst='ros2 service type'                  # Service type (needs arg)
alias rsfind='ros2 service find'               # Find services by type
alias rsc='ros2 service call'                  # Call service (needs args)

# Jazzy+: service echo (service introspection)
if _ros2_distro_at_least "jazzy" 2>/dev/null; then
  alias rse='ros2 service echo'                # Echo service traffic
  alias rsef='ros2 service echo --flow-style'  # Echo with flow-style output
fi
