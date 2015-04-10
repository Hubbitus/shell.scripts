
# From http://wiki.bash-hackers.org/commands/builtin/caller
backtrace(){
  local frame=0
  while caller $frame; do
   ((frame++));
  done
 echo "$*"
}
