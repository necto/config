# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                             #
#    Copyright (C) 2014-2020 Chuan Ji <chuan@jichu4n.com>                     #
#                                                                             #
#    Licensed under the Apache License, Version 2.0 (the "License");          #
#    you may not use this file except in compliance with the License.         #
#    You may obtain a copy of the License at                                  #
#                                                                             #
#     http://www.apache.org/licenses/LICENSE-2.0                              #
#                                                                             #
#    Unless required by applicable law or agreed to in writing, software      #
#    distributed under the License is distributed on an "AS IS" BASIS,        #
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
#    See the License for the specific language governing permissions and      #
#    limitations under the License.                                           #
#                                                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# Added a GUI notification for long commands taken from:
# https://gitlab.com/victor-engmark/tilde/-/commit/1fc8b9f6ab0586499c7921b1452c43c394cd1e39

# A simple Bash script for printing timing information for each command line
# executed.
#
# For the most up-to-date version, as well as further information and
# installation instructions, please visit the GitHub project page at
#     https://github.com/jichu4n/bash-command-timer



# SETTINGS
# ========
#
# Whether to enable the command timer by default.
#
# To temporarily disable the printing of timing information, type the following
# in a session:
#     BCT_ENABLE=0
# To re-enable:
#     BCT_ENABLE=1
BCT_ENABLE=1

# The color of the output for successful and failed commands respectively.
#
# They should be a color string usable in a VT100 escape sequence (see
# http://en.wikipedia.org/wiki/ANSI_escape_code#Colors), without the
# escape sequence prefix and suffix. For example, bold red would be '1;31'.
#
# The color of the output is set in the function BCTPreCommand
#
# If empty, disable colored output. Set them to empty if your terminal does not
# support VT100 escape sequences.
BCT_SUCCESS_COLOR='32'
BCT_ERROR_COLOR='31'

# The display format of the current time.
#
# This is a strftime format string (see http://strftime.org/). To tweak the
# display format of the current time, change the following line to your desired
# pattern.
#
# If empty, disables printing of current time.
BCT_TIME_FORMAT='%b %d %I:%M%p'

# Whether to print command timings up to millisecond precision.
#
# If set to 0, will print up to seconds precision.
BCT_MILLIS=1

# Wheter to wrap to the next line if the output string would overlap with
# characters of last command's output
BCT_WRAP=0



# IMPLEMENTATION
# ==============

# BCTTime:
#
# Command to print out the current time in nanoseconds. This is required
# because the "date" command in OS X and BSD do not support the %N sequence.
#
# BCTPrintTime:
#
# Command to print out a timestamp using BCT_TIME_FORMAT. The timestamp should
# be in seconds. This is required because the "date" command in Linux and OS X
# use different arguments to specify the timestamp to print.
if date +'%N' | grep -qv 'N'; then
  BCTTime="date '+%s%N'"
  function BCTPrintTime() {
    date --date="@$1" +"$BCT_TIME_FORMAT"
  }
elif hash gdate 2>/dev/null && gdate +'%N' | grep -qv 'N'; then
  BCTTime="gdate '+%s%N'"
  function BCTPrintTime() {
    gdate --date="@$1" +"$BCT_TIME_FORMAT"
  }
elif hash perl 2>/dev/null; then
  BCTTime="perl -MTime::HiRes -e 'printf(\"%d\",Time::HiRes::time()*1000000000)'"
  function BCTPrintTime() {
    date -r "$1" +"$BCT_TIME_FORMAT"
  }
else
  echo 'No compatible date, gdate or perl commands found, aborting'
  exit 1
fi


# BCTPreCommand is trapped to the DEBUG trap, directly or through bash-preexec.
# The debug trap is invoked before the execution of each command typed by the
# user (once for every command in a composite command) and again before the
# execution of PROMPT_COMMAND after the user's command finishes. Thus, to be
# able to preserve the timestamp before the execution of the first command, we
# set the BCT_AT_PROMPT flag in PROMPT_COMMAND, only set the start time if the
# flag is set and clear it after the first execution.
BCT_AT_PROMPT=1
function BCTPreCommand() {
  local EXIT="$?"
  if [ -z "$FIRST_AFTER_PROMPT" ];
  then
    # This is not the first invocation of BCTPreCommand after a previous command finished
    # so the exit code is not preserved, and there changing the colors would be misleading
    :
  else
    unset FIRST_AFTER_PROMPT
    if [ $EXIT == 0 ];
    then
      # colour for exit without error
      BCT_COLOR=$BCT_SUCCESS_COLOR
    else
      # colour for exit with error
      BCT_COLOR=$BCT_ERROR_COLOR
    fi
  fi
  if [ -z "$BCT_AT_PROMPT" ]; then
    return
  fi
  unset BCT_AT_PROMPT
  # Note for the next invocation of BCTPreCommand that it will be
  # the time to collect the exit code of the previous command
  FIRST_AFTER_PROMPT=1
  BCT_COMMAND_START_TIME=$(eval $BCTTime)
  BCT_COMMAND_LINE=$(history 1 | sed "s/^[ ]*[0-9]*[ ]*//g")
}


# Bash will automatically set COLUMNS to the current terminal width.
export COLUMNS


# Flag to prevent printing out the time upon first login.
BCT_FIRST_PROMPT=1
# This is executed before printing out the prompt.
function BCTPostCommand() {
  BCT_AT_PROMPT=1

  if [ -n "$BCT_FIRST_PROMPT" ]; then
    unset BCT_FIRST_PROMPT
    return
  fi

  if [ -z "$BCT_ENABLE" ] || [ $BCT_ENABLE -ne 1 ]; then
    return
  fi

  # BCTTime prints out time in nanoseconds.
  local MSEC=1000000
  local SEC=$(($MSEC * 1000))
  local MIN=$((60 * $SEC))
  local HOUR=$((60 * $MIN))
  local DAY=$((24 * $HOUR))

  local command_start_time=$BCT_COMMAND_START_TIME
  local command_end_time=$(eval $BCTTime)
  local command_time=$(($command_end_time - $command_start_time))
  local num_days=$(($command_time / $DAY))
  local num_hours=$(($command_time % $DAY / $HOUR))
  local num_mins=$(($command_time % $HOUR / $MIN))
  local num_secs=$(($command_time % $MIN / $SEC))
  local num_msecs=$(($command_time % $SEC / $MSEC))
  local time_str=""
  if [ $num_days -gt 0 ]; then
    time_str="${time_str}${num_days}d "
  fi
  if [ $num_hours -gt 0 ]; then
    time_str="${time_str}${num_hours}h "
  fi
  if [ $num_mins -gt 0 ]; then
    time_str="${time_str}${num_mins}m "
  fi
  local num_msecs_pretty=''
  if [ -n "$BCT_MILLIS" ] && [ $BCT_MILLIS -eq 1 ]; then
    local num_msecs_pretty=$(printf '%03d' $num_msecs)
  fi
  time_str="${time_str}${num_secs}s${num_msecs_pretty}"
  now_str=$(BCTPrintTime $(($command_end_time / $SEC)))
  if [ -n "$now_str" ]; then
    local output_str="[ $time_str | $now_str ]"
  else
    local output_str="[ $time_str ]"
  fi
  if [ -n "$BCT_COLOR" ]; then
    local output_str_colored="\033[${BCT_COLOR}m${output_str}\033[0m"
  else
    local output_str_colored="${output_str}"
  fi
  # Trick to make sure the output wraps to the next line if there is not
  # enough room for the string (only when BCT_WRAP == 1)
  if [ -n "$BCT_WRAP" ] && [ $BCT_WRAP -eq 1 ]; then
    # we'll print as many spaces as characters exist in output_str, plus 2
    local wrap_space_prefix="${output_str//?/ }  "
  else
    local wrap_space_prefix=""
  fi

  # Move to the end of the line. This will NOT wrap to the next line
  # unless you have BCT_WRAP == 1
  echo -ne "$wrap_space_prefix\033[${COLUMNS}C"
  # Move back (length of output_str) columns.
  echo -ne "\033[${#output_str}D"
  # Finally, print output.
  echo -e "${output_str_colored}"

  # Send a notification if the command took long time (> 10 minutes)
  local tot_secs=$(($command_time / $SEC))
  local notify_path=$(which notify-send 2> /dev/null)
  if [ $tot_secs -gt 600 ] && [ -x "$notify_path" ]; then
      notify-send "Finished in: $time_str" "$BCT_COMMAND_LINE"
  fi
}

