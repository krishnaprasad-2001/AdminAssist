#!/bin/bash

_mycommand_completion() {
    COMPREPLY=( $(compgen -W "check_health dbDetails deb tdeb db upgrade plugin theme fix_db wpinstall apache add_custom_rule uninstall nginx ipcheck dockertest dockerforktest" "${COMP_WORDS[1]}") )
}

complete -F _mycommand_completion BK
