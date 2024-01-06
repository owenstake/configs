
# FZF key binding {{{
    # what we expect is `   sort -t\| -gr -k2 /home/z/.z | awk -F\| "{print \$1}"   `
    # Because here the cmd will be subtituded twice, so we need to take care of escape.
    # Double quote can be nest while single quote cant. we must use escape to take care of quote matching
    # https://stackoverflow.com/questions/6697753/difference-between-single-and-double-quotes-in-bash/42082956#42082956
    # FZF
export FZF_CTRL_T_OPTS="
    --prompt 'All> '
    --border
    --reverse
    --height 60%
    --preview '
    (
        ~/.config/fzf/fzf-scope.sh {} ||
        tree -ahpCL 3 -I '.git' -I '__pycache__' {}  ||
        echo preview {} fail
    ) 2>/dev/null | head -n 100
    '
    --header 'CTRL-D: Directories / CTRL-F: Files / CTRL-T: Zlua'
    --bind 'ctrl-d:change-prompt(Directories> )+reload(find * -type d)'
    --bind 'ctrl-f:change-prompt(Files> )+reload(find * -type f)'
    --bind 'ctrl-t:change-prompt(Zlua> )+reload(sort -t\| -gr -k2 ~/.zlua | awk -F\| \"{print \\\$1}\")'
    "
# CTRL-/ to toggle small preview window to see the full command
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
    --header 'Press CTRL-Y to copy command into clipboard'
    --reverse
    --preview 'echo {}' --preview-window up:3:hidden:wrap
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
    "

function _fzf_complete_ping () {
    _fzf_complete +m -- "$@" < <(
        command grep -v '^\s*\(#\|$\)' /etc/hosts | command grep -Fv '0.0.0.0' |
            awk '{if (length($2) > 0) {print $2}}' | sort -u
        )
}

# FZF - https://github.com/junegunn/fzf#using-git {{{
test -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.${SHELL##*/} && source $_

