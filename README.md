# Exercise: Fewer Keystrokes

Exercise code for the lesson **Exercise: Fewer Keystrokes** in Bash in Depth on [ask-codey.com](https://www.ask-codey.com).

A spring photo show is coming, and its photos sit four folders deep. Write the settings that make your shell faster into `fast.bashrc`, count the photos with `**`, read two exit codes, and write one line that backs up the beach photos and says so only if it worked. A check script tells you what's done.

## Before you start

You need a terminal (the Terminal app on a Mac, Ubuntu on Linux or in WSL on Windows) and **bats**, the tool that runs the check. If `bats --version` doesn't print a version yet, install it:

```bash
sudo apt install bats       # Ubuntu, and Ubuntu in WSL
brew install bats-core      # a Mac, with Homebrew
```

On a Mac, the check loads `fast.bashrc` in bash 5, the bash you installed with Homebrew, even though your Terminal runs zsh.

## What's here

- `photo-show/`: the project. `raw/2026/` holds the original photos by month and place, `edited/2026/` the edited copies (their names end in `-edit.jpg`), `exports/` the finished ones, and `notes.txt` the plan. The photos are short text files with photo names.
- `fast.bashrc`: six settings to write, one under each comment. For you to finish.
- `answers.txt`: six questions, each with a numbered line for your answer. For you to finish.
- `check.bats`: checks `fast.bashrc`, the `backup` folder and your answers. You don't need to change it.

Unzip or clone the exercise into `~/terminal-practice/exercise-bash-fewer-keystrokes`, so its folder is in the same place as everyone's.

## Run it

Open a terminal in this folder (the one with `answers.txt` in it), then:

1. **Write the settings.** Open `fast.bashrc` in nano and write one line under each comment. Load it with `source fast.bashrc`, and try each setting: `echo $HISTSIZE`, `ls photo-show/raw/**/*.jpg`, `cd ~` and then `cd edited`.
2. **Answer questions 1 to 4** in `answers.txt`, with `**`, `wc -l` and `echo $?`.
3. **Write the backup line** for question 5, then run it here, so the `backup` folder is really made.
4. **Answer question 6.**

The check can't see your keystrokes, so practice them as you go: Alt+. to bring back a path, Ctrl+A and Ctrl+E to fix a line, Ctrl+R to find a command again, `pushd` and `popd` for a trip into `photo-show/raw` and back.

## Check your work

From this folder:

```bash
bats check.bats
```

At first most checks fail: that is expected. Each job you finish turns its check into a ✓. A failing check's message says what to look at.

## The rules

- Write `fast.bashrc` as settings only, one per comment, with no spaces around any `=`.
- `CDPATH` starts with `.`, then photo-show's full path, and isn't exported.
- Answer 5 is one line, and it doesn't delete anything.
- Write each answer on its numbered line, after the `)`, like the example: `0) 3`.

## Tips

- `HISTSIZE` and `HISTFILESIZE` are plain `NAME=value` lines. `histappend` and `globstar` are turned on with `shopt -s`.
- `PROMPT_COMMAND` needs quotes around `history -a`, because of the space.
- `cd photo-show`, then `pwd`, prints photo-show's full path for `CDPATH`. `$HOME` can stand for the start of it.
- After `shopt -s globstar`, `photo-show/raw/**/*.jpg` matches every `.jpg` below `raw`. Pipe `ls` into `wc -l` to count them.
- `echo $?` must come straight after the command you're asking about.
- `&&` runs the next command only if the last one worked; `;` runs it either way.

## Hand it in

When it works, push your solution to a public repo of your own on GitHub, then paste that repo's address into **Submit your exercise** on the lesson page at [ask-codey.com](https://www.ask-codey.com). That's what completes the lesson. The lesson page shows the Git commands, step by step.
