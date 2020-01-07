#!/bin/bash

# wish design:
#./draw_github_contributions.sh [data dates] [weeks offset] [number of commits per dot]
#./draw_github_contributions.sh  ./data.txt   1              50


do_dummy_thing() {
  declare -r FILENAME="dummy.txt"

  if [ -e "$FILENAME" ]; then
    rm $FILENAME
  else
    touch "$FILENAME"
    echo "dummy text" > "$FILENAME"
  fi
}

create_commits() {
  local date_to_commit=$1
  local number_of_commits=$2

  if [ ! date -d date_to_commit ]; then
    echo "Invalid date_to_commit: $date_to_commit"
    return

  elif [ ! number_of_commits ]; then
    echo "Invalid number_of_commits: $number_of_commits"
    return
  fi

    
  for ((i=0; i < number_of_commits; i++)); do

    do_dummy_thing
    git add .
    git commit -m "dummy commit"

    GIT_COMMITTER_DATE="$date_to_commit" git commit --amend --no-edit --date "$date_to_commit"
    echo "committed $(( i + 1 )) commits for $date_to_commit"

  done
}


file_data=$1
weeks_offset=${2:-0}
commits_per_day=${3:-50}

if [ -f "$file_data" ]; then
  #readarray is only available from bash 4.0
  readarray -t array_dates < $file_data

  if (( ${#array_dates[@]} )); then

    for date in ${array_dates[*]}; do

      # https://unix.stackexchange.com/questions/49053/linux-add-x-days-to-date-and-get-new-virtual-date
      date_to_commit=$( date -d "$date+$((weeks_offset * 7)) days" )

      if [ "$date_to_commit" ]; then
        create_commits "$date_to_commit" "$commits_per_day"
      else
        echo "invalid date: $date"
      fi

    done

  else
    echo "$file_data is empty"

  fi

else
  echo "File data not exist: $file_data"

fi