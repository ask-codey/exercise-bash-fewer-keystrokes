#!/usr/bin/env bats
# Checks fast.bashrc, the backup folder and your answers in answers.txt.
# Answers are worked out from the photo-show folder itself, so this file never holds them.
# Run it from this folder with:  bats check.bats
# You don't need to change this file.

setup() {
  cd "$BATS_TEST_DIRNAME"
}

BEACH='photo-show/edited/2026/05-may/beach'

# The answer written after "N)" in answers.txt, without spaces or quotes at either end.
answer() {
  grep -E "^$1\)" answers.txt | head -n 1 | sed -E "s/^$1\)[[:space:]]*//; s/[[:space:]]+\$//; s/^[\"']//; s/[\"']\$//"
}

# The same, with any quotes left as they are: for an answer that is a whole command line.
answer_line() {
  grep -E "^$1\)" answers.txt | head -n 1 | sed -E "s/^$1\)[[:space:]]*//; s/[[:space:]]+\$//"
}

# Fails with a message when question N has no answer yet.
need() {
  if [[ -z "$(answer "$1")" ]]; then
    echo "Question $1 has no answer yet. Write it after \"$1)\" in answers.txt."
    return 1
  fi
}

# Loads fast.bashrc into a fresh bash, with no settings of its own, and runs the command after it.
with_settings() {
  bash --norc --noprofile -c "source ./fast.bashrc >/dev/null 2>&1; $1"
}

@test "the photo-show folder is still here" {
  for f in photo-show/notes.txt "$BEACH/IMG_0501-edit.jpg" photo-show/raw/2026/06-june/lake/IMG_0601.jpg; do
    if [[ ! -s "$f" ]]; then
      echo "$f is missing or empty. Download the exercise again to get it back."
      return 1
    fi
  done
}

@test "fast.bashrc loads without errors" {
  if [[ ! -f fast.bashrc ]]; then
    echo "There's no fast.bashrc in this folder. Download the exercise again to get it back."
    return 1
  fi
  errors="$(bash --norc --noprofile -c 'source ./fast.bashrc' 2>&1 >/dev/null)"
  if [[ -n "$errors" ]]; then
    echo "Loading fast.bashrc printed an error: $errors"
    echo "Look at the line it names: a typo in a setting's name, or a space around an = sign, is the usual cause."
    return 1
  fi
}

@test "fast.bashrc: a longer history, 10000 commands in memory and 20000 in the file" {
  size="$(with_settings 'echo "$HISTSIZE"')"
  filesize="$(with_settings 'echo "$HISTFILESIZE"')"
  if ! [[ "$size" =~ ^[0-9]+$ ]] || (( size < 10000 )); then
    echo "HISTSIZE is \"$size\" after loading fast.bashrc; it needs to be at least 10000. Write it as HISTSIZE=10000, with no spaces around the =."
    return 1
  fi
  if ! [[ "$filesize" =~ ^[0-9]+$ ]] || (( filesize < 20000 )); then
    echo "HISTFILESIZE is \"$filesize\" after loading fast.bashrc; it needs to be at least 20000. Write it as HISTFILESIZE=20000."
    return 1
  fi
}

@test "fast.bashrc: every terminal adds to the history file, as soon as each command runs" {
  if ! with_settings 'shopt -q histappend'; then
    echo "histappend isn't on after loading fast.bashrc. The line is shopt -s histappend."
    return 1
  fi
  if [[ "$(with_settings 'declare -p PROMPT_COMMAND 2>/dev/null')" != *"history -a"* ]]; then
    echo "PROMPT_COMMAND doesn't run history -a after loading fast.bashrc. The line is PROMPT_COMMAND='history -a', with the quotes, because the value has a space in it."
    return 1
  fi
}

@test "fast.bashrc: ** reaches every folder below" {
  if ! with_settings 'shopt -q globstar'; then
    echo "globstar isn't on after loading fast.bashrc. The line is shopt -s globstar."
    return 1
  fi
}

@test "fast.bashrc: CDPATH looks here first, then in photo-show, and isn't exported" {
  cdpath="$(with_settings 'echo "$CDPATH"')"
  if [[ -z "$cdpath" ]]; then
    echo "CDPATH is empty after loading fast.bashrc. Write CDPATH= with a . first, then a : and photo-show's full path."
    return 1
  fi
  IFS=: read -r -a entries <<< "$cdpath"
  if [[ "${entries[0]}" != "." && -n "${entries[0]}" ]]; then
    echo "CDPATH starts with ${entries[0]}. Put a . first (CDPATH=.:…), so cd looks in the folder you're in before anywhere else."
    return 1
  fi
  found=no
  for entry in "${entries[@]:1}"; do
    entry="${entry%/}"
    if [[ "$entry" == /* && "$entry" == */photo-show ]]; then
      found=yes
    fi
  done
  if [[ "$found" != yes ]]; then
    echo "CDPATH is \"$cdpath\". After the ., it needs photo-show's full path, starting with / (or \$HOME), such as $(pwd)/photo-show."
    return 1
  fi
  if [[ "$(with_settings 'declare -p CDPATH')" == "declare -x"* ]]; then
    echo "CDPATH is exported. Take export off the line: scripts would get CDPATH too, and their cd could go somewhere you didn't mean."
    return 1
  fi
}

@test "1) how many raw photos" {
  need 1
  want="$(find photo-show/raw -type f -name '*.jpg' | wc -l | tr -cd '0-9')"
  got="$(answer 1 | tr -cd '0-9')"
  if [[ "$got" != "$want" ]]; then
    echo "Question 1: \"$(answer 1)\" isn't it yet. After shopt -s globstar, ls photo-show/raw/**/*.jpg lists every .jpg below raw, and wc -l counts the lines. Count only .jpg files."
    return 1
  fi
}

@test "2) how many edited photos" {
  need 2
  want="$(find photo-show -type f -name '*-edit.jpg' | wc -l | tr -cd '0-9')"
  got="$(answer 2 | tr -cd '0-9')"
  if [[ "$got" != "$want" ]]; then
    echo "Question 2: \"$(answer 2)\" isn't it yet. With globstar on, photo-show/**/*-edit.jpg matches every edited photo, in every folder."
    return 1
  fi
}

@test "3) the exit code when grep finds nothing" {
  need 3
  want="$(grep -q IMG_0999 photo-show/notes.txt; echo $?)"
  got="$(answer 3 | tr -cd '0-9')"
  if [[ "$got" != "$want" ]]; then
    echo "Question 3: \"$(answer 3)\" isn't it yet. Run the command, then echo \$? straight after it, before any other command."
    return 1
  fi
}

@test "4) the exit code when the file isn't there" {
  need 4
  want="$(grep -q IMG_0401 photo-show/no-such-file.txt 2>/dev/null; echo $?)"
  got="$(answer 4 | tr -cd '0-9')"
  if [[ "$got" != "$want" ]]; then
    echo "Question 4: \"$(answer 4)\" isn't it yet. Run the command, then echo \$? straight after it. grep uses different numbers for \"not found\" and \"couldn't read the file\"."
    return 1
  fi
}

@test "5) the backup line copies the beach photos and says Backup done" {
  need 5
  line="$(answer_line 5)"
  if [[ "$line" == *"rm "* ]]; then
    echo "Question 5: your line has rm in it. The job only makes a folder and copies photos, so nothing needs deleting."
    return 1
  fi
  work="$BATS_TEST_TMPDIR/works"
  mkdir -p "$work" && cp -r photo-show "$work/"
  out="$(cd "$work" && bash -c "$line" 2>&1)" || true
  for photo in "$BEACH"/*.jpg; do
    if [[ ! -f "$work/backup/$(basename "$photo")" ]]; then
      echo "Question 5: in a fresh copy of this folder, your line didn't put $(basename "$photo") into backup/. It printed: $out"
      echo "Make the folder with mkdir -p backup, then copy $BEACH/*.jpg into backup/."
      return 1
    fi
  done
  if [[ "$out" != *"Backup done"* ]]; then
    echo "Question 5: your line copied the photos but didn't print Backup done. Add && echo \"Backup done\" at the end."
    return 1
  fi
}

@test "5) the backup line stays quiet when the copy fails" {
  need 5
  line="$(answer_line 5)"
  if [[ "$line" == *"rm "* ]]; then
    echo "Question 5: your line has rm in it. The job only makes a folder and copies photos."
    return 1
  fi
  work="$BATS_TEST_TMPDIR/fails"
  mkdir -p "$work" && cp -r photo-show "$work/"
  rm -r "${work:?}/$BEACH"
  out="$(cd "$work" && bash -c "$line" 2>&1)" || true
  if [[ "$out" == *"Backup done"* ]]; then
    echo "Question 5: with the beach folder gone, the copy failed, but your line still printed Backup done. Join the steps with && (\"and then, if it worked\"), not ;."
    return 1
  fi
}

@test "the backup folder holds the beach photos" {
  if [[ ! -d backup ]]; then
    echo "There's no backup folder here yet. Run your line from question 5 in this folder."
    return 1
  fi
  for photo in "$BEACH"/*.jpg; do
    if [[ ! -f "backup/$(basename "$photo")" ]]; then
      echo "backup/ doesn't have $(basename "$photo") in it. Run your line from question 5 again in this folder."
      return 1
    fi
  done
}

@test "6) going into the folder the last command made" {
  need 6
  got="$(answer 6 | tr -s ' ')"
  if [[ "$got" != 'cd !$' && "$got" != 'cd !$/' ]]; then
    echo "Question 6: \"$got\" isn't it yet. One history shortcut stands for the last argument of the last command: try it after a mkdir -p of your own."
    return 1
  fi
}
