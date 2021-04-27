#########################################################################################################
# Bash completion for analytics
#
# On Redhat/Centos/Fedora install the bash-completion package.
# Does currently not work on macOS.
#
# Link this file to ~/.bash_completion (this is a file, not a directory) for local install or
# into /etc/bash_completion.d/ for system-wide install:
#   ln -s /path-to-this-dir/analytics_bash_completion.bash /etc/bash_completion.d/.bash_completion
# Make sure that the analytics binary is on your search path (required for autocompletion).
# Open a new shell so that the new completion configuration is active.
#########################################################################################################
_analytics()
{
    # To understand what this does, and what these variables mean, see the definition of
    # the _init_completion function in /usr/share/bash-completion/bash_completion
    local cur prev words cword
    _init_completion || return

    COMPREPLY=()

    # directory this script is located in
    my_dir="$( cd "$( dirname $(readlink -f "${BASH_SOURCE[0]}") )" && pwd )"

    # read auto-generated completion information
    source $my_dir/_analytics_bash_completion_data.bash

    # COMP_CWORD contains the position of the completion word. (not necessarily the length of COMP_WORDS)
    # When we are at position 1, we are completing the name of the analytics sub-command.
    if [ $COMP_CWORD -eq 1 ]; then
        opts="$(analytics_commands)"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
} &&
complete -F _analytics analytics

