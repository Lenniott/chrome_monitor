#!/bin/bash

# Log file to record focus changes
LOG_FILE="$HOME/Desktop/Desktop - Benjamin’s MacBook Pro/CODE/Scripts/broswerTimeMonitor/chrome_focus_log.csv"
MONITORING_FILE="$HOME/Desktop/Desktop - Benjamin’s MacBook Pro/CODE/Scripts/broswerTimeMonitor/isMonitoring.txt"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Add a header if the log file does not exist
if [[ ! -f "$LOG_FILE" ]]; then
  echo "id,timestamp,event,url,title,duration" > "$LOG_FILE"
fi

# Initialize variables
previous_state="inactive"
chrome_opened=false
previous_url=""
previous_title=""
start_time=$(date +%s)
log_id=0

# Function to generate a consistent ID for each URL
generate_id() {
  local url=$1
  echo -n "$url" | md5 | cut -c1-8  # Generate an 8-character unique ID from the URL hash
}

# Function to sanitize title by removing non-word characters
sanitize_title() {
  local title=$1
  # Remove all non-alphanumeric characters except spaces, then trim extra spaces
  title=$(echo "$title" | sed 's/[^a-zA-Z0-9 ]/ /g' | sed 's/  */ /g')
  echo "$title"
}

# Function to log events
log_event() {
  local event=$1
  local url=$2
  local title=$3
  local duration=$4
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local id=$(generate_id "$url")  # Generate the consistent ID
  local sanitized_title=$(sanitize_title "$title")  # Sanitize title for CSV
  echo "$id,$timestamp,$event,\"$url\",\"$sanitized_title\",$duration" >> "$LOG_FILE"
}

# Continuous monitoring loop
while true; do
  # Check if monitoring is enabled by reading the content of isMonitoring.txt
  if [[ $(cat "$MONITORING_FILE") != "true" ]]; then
    echo "Monitoring disabled. Exiting."
    exit 0
  fi

  # Check if Chrome is running
  if pgrep -x "Google Chrome" > /dev/null; then
    # If Chrome has just opened, log it as active the first time
    if [[ "$chrome_opened" == false ]]; then
      start_time=$(date +%s)
      previous_url=$(osascript -e 'tell application "Google Chrome" to get URL of active tab of front window')
      previous_title=$(osascript -e 'tell application "Google Chrome" to get title of active tab of front window')
      log_event 1 "$previous_url" "$previous_title" 0  # Log with duration 0 as it's the start of active session
      chrome_opened=true
      previous_state="active"
    fi

    # Get the name of the active application
    active_app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

    if [[ "$active_app" == "Google Chrome" ]]; then
      # Get the active tab URL and title
      current_url=$(osascript -e 'tell application "Google Chrome" to get URL of active tab of front window')
      current_title=$(osascript -e 'tell application "Google Chrome" to get title of active tab of front window')

      # If Chrome was previously inactive, log focus gain with duration 0
      if [[ "$previous_state" == "inactive" ]]; then
        start_time=$(date +%s)
        log_event 1 "$current_url" "$current_title" 0  # Start with duration 0 for new focus
        previous_state="active"
        previous_url="$current_url"
        previous_title="$current_title"
      elif [[ "$current_url" != "$previous_url" ]]; then
        # Log a tab change with duration calculated for time spent on the previous tab
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        log_event 2 "$previous_url" "$previous_title" "$duration"  # Log time spent on previous tab
        # Reset for new tab but do not log event 1 immediately
        start_time=$(date +%s)
        previous_url="$current_url"
        previous_title="$current_title"
      fi
    else
      # If Chrome was active and now inactive, log the inactive state with duration
      if [[ "$previous_state" == "active" ]]; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        log_event 0 "$previous_url" "$previous_title" "$duration"  # Log time spent on last active tab
        previous_state="inactive"
      fi
    fi
  else
    # If Chrome has closed and was previously active, log it as inactive with duration
    if [[ "$chrome_opened" == true ]]; then
      end_time=$(date +%s)
      duration=$((end_time - start_time))
      log_event 0 "$previous_url" "$previous_title" "$duration"  # Log time spent on last active tab before close
      chrome_opened=false
      previous_state="inactive"
    fi
  fi

  # Wait for a short interval before checking again
  sleep 1
done