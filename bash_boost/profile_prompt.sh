source ~/.bash_boost/bash_colors.sh

enter_directory(){
  if [ "$PWD" != "$PREV_PWD" ]; then
    PREV_PWD="$PWD";
    if [ -e ".nvmrc" ]; then
      nvm use;
    fi
  fi
}

function prompt {
    PROMPT_COMMAND="detect_vcs; enter_directory"
    PS1="$GREEN\${__vcs_prefix}$CYAN\${base_dir}\[\$(check_git_changes)\]\${__vcs_branch_tag}$CYAN\${__cwd}$NORMAL \$ "
  # PS2='> '
  # PS4='+ '
}
prompt
