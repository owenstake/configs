import os
import subprocess

import ranger.api.commands as ranger

# [cjbassi/ranger-fzf: Ranger plugin that allows navigation with fzf](https://github.com/cjbassi/ranger-fzf )

class fzf(ranger.Command):
    """
    :fzf_select

    Find a file using fzf.

    With a prefix argument select only directories.
    """

    def execute(self):
        if self.quantifier:
            # match only directories
            command = "find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -type d -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"
        else:
            # match files and directories
            command = "find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"

        env = os.environ.copy()
        env['FZF_DEFAULT_COMMAND'] = "fzf"
        # env['FZF_DEFAULT_COMMAND'] = "fzf-tmux"

        #env['FZF_DEFAULT_OPTS'] = '--height=100% --layout=reverse --ansi        \
        #    --prompt "All> "                                                    \
        #    --header "CTRL-D: Directories / CTRL-F: Files"                      \
        #    --bind "ctrl-d:change-prompt(Directories> )+reload(find * -type d)" \
        #    --bind "ctrl-f:change-prompt(Files> )+reload(find * -type f)"       \
        #    --bind                                                           \
        #    --preview="{}"'.format('''
        #       (
        #           ~/.config/fzf/fzf-scope.sh {} ||
        #           #batcat --color=always {} ||
        #           #bat --color=always {} ||
        #           #cat {} ||
        #           tree -ahpCL 3 -I '.git' -I '*.py[co]' -I '__pycache__' {}
        #       ) 2>/dev/null | head -n 100
        #    ''')

        env['FZF_DEFAULT_OPTS'] = env['FZF_CTRL_T_OPTS'] + '--reverse --height 50%'

        fzf = self.fm.execute_command(command, env=env, stdout=subprocess.PIPE)
        stdout, _ = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.decode('utf-8').rstrip('\n'))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)
