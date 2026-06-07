#!/usr/bin/env zsh
# vim: set ft=zsh:
# =============================================================================
# aliases/action.zsh — ros2 action shortcuts
# Prefix: ra (ros2 action)
# =============================================================================

alias ral='ros2 action list'                   # List all actions
alias ralt='ros2 action list -t'               # List actions with types
alias rai='ros2 action info'                   # Action info (needs arg)
alias rat='ros2 action type'                   # Action type (needs arg)
alias rafind='ros2 action find'                # Find actions by type
alias rac='ros2 action call'                   # Call action (needs args)
