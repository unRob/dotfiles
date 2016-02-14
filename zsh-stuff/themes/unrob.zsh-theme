prompt_git() {
  local ref dirty mode repo_path status_bg status_fg
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      status_bg="$fg[yellow]"
      # status_fg="$bg[cyan]"
    else
      status_bg="$fg[cyan]"
      # status_bg="$bg[cyan]"
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode="<B> "
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=">M< "
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=">R> "
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:git:*' unstagedstr '𝚫'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    print -Pr "%{${status_bg}%}:${mode}${ref/refs\/heads\//}${vcs_info_msg_0_%% } %{${reset_color}%}"
  fi
}

prompt_end() {
  echo "%B%{$fg[cyan]%}→%b%{${reset_color}%}"
}

build_rprompt () {
  prompt_status
}

precmd() {
  RETVAL=$?

  setopt promptsubst
  echo ""

  local status_color
  if [[ $RETVAL -ne 0 ]]; then
    status_color="$fg[red]"
  else
    status_color="$fg[green]"
  fi

  print -Pr "%{${status_color}%}• %B%{$fg[cyan]%}%3~%b$(prompt_git)"
}

#
preexec() { print "" }
# setopt PROMPT_SUBST
PROMPT='$(prompt_end) '
# PROMPT='$(prompt_end) '
