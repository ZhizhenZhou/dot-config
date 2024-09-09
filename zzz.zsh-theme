if [ "$USER" = "zhizhenzhou" ] || [ "$USER" = "zzz"]; then
  PROMPT=''
else
  PROMPT='%{$fg[green]%}%n%{$reset_color%}@%{$fg[blue]%}%m '
fi
PROMPT+='%{$fg_bold[cyan]%}%~%{$reset_color%} '
PROMPT+='$(git_prompt_info)'
PROMPT+='%(#,#%{$reset_color%},$%{$reset_color%}) '

RPROMPT='%(?,$FG[022][R-$?],$FG[130][R-$?])$FG[059][%D/%*]%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})%{$FG[130]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%}±%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})%{$fg[green]%}✓%{$reset_color%}"
