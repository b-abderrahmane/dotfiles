#!/usr/bin/env bash
# Helper for the tmux status bar. Usage: statusbar.sh <segment>
# Segments: battery | cpu | ram | disk | ip | dns. Portable across macOS and
# Linux; each prints a short string (or "—" when unavailable) and never errors
# out, so a missing tool can't break the whole status line.
#
# ram/disk are "used/total"; cpu is "load/cores" (load average over core count —
# the meaningful x/y for CPU, since >cores means the machine is saturated).

os=$(uname -s)

# bytes -> compact human size (e.g. 940M, 12G, 1.2T)
human() {
  awk -v b="$1" 'BEGIN{
    split("B K M G T P", u, " "); i = 1
    while (b >= 1024 && i < 6) { b /= 1024; i++ }
    if (b >= 10) printf "%.0f%s", b, u[i]; else printf "%.1f%s", b, u[i]
  }'
}

battery() {
  if [ "$os" = Darwin ]; then
    raw=$(pmset -g batt 2>/dev/null)
    pct=$(printf '%s' "$raw" | grep -Eo '[0-9]+%' | head -1)
    [ -z "$pct" ] && { printf 'AC'; return; }
    printf '%s' "$raw" | grep -q 'AC Power' && printf '⚡'
    printf '%s' "$pct"
  else
    bat=$(ls /sys/class/power_supply/ 2>/dev/null | grep -m1 '^BAT')
    [ -z "$bat" ] && { printf 'AC'; return; }
    cap=$(cat "/sys/class/power_supply/$bat/capacity" 2>/dev/null)
    [ "$(cat "/sys/class/power_supply/$bat/status" 2>/dev/null)" = Charging ] && printf '⚡'
    printf '%s%%' "${cap:-?}"
  fi
}

cpu() {
  if [ "$os" = Darwin ]; then
    load=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}')
    cores=$(sysctl -n hw.ncpu 2>/dev/null)
  else
    load=$(awk '{print $1}' /proc/loadavg 2>/dev/null)
    cores=$(nproc 2>/dev/null || awk '/^processor/{n++} END{print n}' /proc/cpuinfo)
  fi
  [ -z "$load" ] || [ -z "$cores" ] && { printf '—'; return; }
  awk -v l="$load" -v c="$cores" 'BEGIN{ printf "%.1f/%d", l, c }'
}

ram() {
  if [ "$os" = Darwin ]; then
    total=$(sysctl -n hw.memsize 2>/dev/null)
    ps=$(sysctl -n hw.pagesize 2>/dev/null)
    read -r active wired comp < <(vm_stat 2>/dev/null | awk '
      /Pages active/                 { gsub(/[^0-9]/,"",$NF); a=$NF }
      /Pages wired down/             { gsub(/[^0-9]/,"",$NF); w=$NF }
      /Pages occupied by compressor/ { gsub(/[^0-9]/,"",$NF); c=$NF }
      END { print a+0, w+0, c+0 }')
    [ -z "$total" ] || [ -z "$ps" ] && { printf '—'; return; }
    used=$(( (active + wired + comp) * ps ))
  else
    read -r total used < <(awk '
      /^MemTotal:/     { t=$2 }
      /^MemAvailable:/ { a=$2 }
      END { print t*1024, (t-a)*1024 }' /proc/meminfo 2>/dev/null)
    [ -z "$total" ] && { printf '—'; return; }
  fi
  printf '%s/%s' "$(human "$used")" "$(human "$total")"
}

disk() {
  # Volume backing $HOME, used/total. -P forces single-line POSIX output.
  read -r size_kb used_kb < <(df -Pk "$HOME" 2>/dev/null | awk 'NR==2{print $2, $3}')
  [ -z "$size_kb" ] && { printf '—'; return; }
  printf '%s/%s' "$(human "$((used_kb * 1024))")" "$(human "$((size_kb * 1024))")"
}

ip_addr() {
  if [ "$os" = Darwin ]; then
    for i in en0 en1 en2; do
      a=$(ipconfig getifaddr "$i" 2>/dev/null)
      [ -n "$a" ] && { printf '%s' "$a"; return; }
    done
    printf '—'
  else
    ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++)if($i=="src")print $(i+1)}' | head -1 | grep . || printf '—'
  fi
}

dns() {
  if [ "$os" = Darwin ]; then
    scutil --dns 2>/dev/null | awk '/nameserver\[0\]/{print $3; exit}' | grep . || printf '—'
  else
    { resolvectl dns 2>/dev/null | awk '{print $NF; exit}' \
      || awk '/^nameserver/{print $2; exit}' /etc/resolv.conf 2>/dev/null; } | grep . || printf '—'
  fi
}

case "${1:-}" in
  battery) battery ;;
  cpu)     cpu ;;
  ram)     ram ;;
  disk)    disk ;;
  ip)      ip_addr ;;
  dns)     dns ;;
  *) echo "usage: statusbar.sh {battery|cpu|ram|disk|ip|dns}" >&2; exit 1 ;;
esac
