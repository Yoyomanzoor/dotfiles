#!/bin/bash
# ~/.config/waybar_sway/calendar.sh

# Path to the cache file
CACHE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/waybar/calendar.cache"

# --- Function to update cache if it's old or doesn't exist ---
update_cache() {
    # Ensure the cache directory exists before writing to it
    mkdir -p "$(dirname "$CACHE_FILE")"

    # Update cache if it doesn't exist or is from a previous day
    if [ ! -f "$CACHE_FILE" ] || [ "$(date -r "$CACHE_FILE" +%F)" != "$(date +%F)" ]; then
        gcalendar > "$CACHE_FILE"
    fi
}

# --- Function to get a time-of-day icon ---
get_tod_icon() {
    local hour=$1
    if (( hour >= 5 && hour < 12 )); then
        echo "🌄" # Morning
    elif (( hour >= 12 && hour < 18 )); then
        echo "☀️" # Day
    elif (( hour >= 18 && hour < 21 )); then
        echo "🌇" # Evening
    else
        echo "🌙" # Night
    fi
}

# --- Main logic to display the next event in Waybar ---
display_waybar() {
    update_cache
    
    NOW_TS=$(date +%s)
    NEXT_EVENT_LINE=""

    # Find the first upcoming event from the cache file
    while IFS= read -r line || [[ -n "$line" ]]; do
        START_DATETIME_STR=$(echo "$line" | awk '{print $1}')
        START_DATETIME_FORMATTED=$(echo "$START_DATETIME_STR" | sed 's/:/ /')
        
        if ! EVENT_TS=$(date -d "$START_DATETIME_FORMATTED" +%s 2>/dev/null); then
            continue
        fi

        if (( EVENT_TS > NOW_TS )); then
            NEXT_EVENT_LINE="$line"
            break
        fi
    done < "$CACHE_FILE"

    if [ -z "$NEXT_EVENT_LINE" ]; then
        echo '{"text": "󰃭 No upcoming events", "tooltip": "No events for today"}'
        exit 0
    fi

    DATETIME_PART=$(echo "$NEXT_EVENT_LINE" | awk -F'\t' '{print $1}')
    TITLE=$(echo "$NEXT_EVENT_LINE" | awk -F'\t' '{print $2}' | sed 's/&/&amp;/g')
    LOCATION=$(echo "$NEXT_EVENT_LINE" | awk -F'\t' '{print $3}' | sed 's/&/&amp;/g')

    START_STR=$(echo "$DATETIME_PART" | awk '{print $1}')
    END_STR=$(echo "$DATETIME_PART" | awk '{print $3}')
    
    # Get full formatted datetime strings
    START_DATETIME_FORMATTED=$(echo "$START_STR" | sed 's/:/ /')
    END_DATETIME_FORMATTED=$(echo "$END_STR" | sed 's/:/ /')

    # *** UPDATE: Format times with AM/PM for display ***
    START_TIME=$(date -d "$START_DATETIME_FORMATTED" "+%I:%M %p")
    END_TIME=$(date -d "$END_DATETIME_FORMATTED" "+%I:%M %p")
    
    # Calculate duration
    START_TS=$(date -d "$START_DATETIME_FORMATTED" +%s)
    END_TS=$(date -d "$END_DATETIME_FORMATTED" +%s)
    DURATION_MIN=$(((END_TS - START_TS) / 60))
    DURATION_STR="$((DURATION_MIN / 60))h $((DURATION_MIN % 60))m"

    # Get the 24-hour start hour for the icon
    START_HOUR=$(date -d "$START_DATETIME_FORMATTED" "+%H")
    TOD_ICON=$(get_tod_icon "$START_HOUR")

    TOOLTIP="<b>$TITLE</b>\n"
    TOOLTIP+="$TOD_ICON  $START_TIME - $END_TIME ($DURATION_STR)\n"
    if [ -n "$LOCATION" ]; then
        TOOLTIP+="📍  $LOCATION"
    fi
    
    TRUNCATED_TITLE="$TITLE"
    if (( ${#TITLE} > 20 )); then
        TRUNCATED_TITLE="${TITLE:0:20}..."
    fi
    
    TEXT="󰃭 $START_TIME - $TRUNCATED_TITLE"

    printf '{"text": "%s", "tooltip": "%s"}\n' "$TEXT" "$TOOLTIP"
}

# --- On-click logic to show a list of upcoming events ---
show_upcoming_list() {
    update_cache

    END_DATE_TS=$(date -d "+3 days" +%s)
    NOW_TS=$(date +%s)
    
    EVENTS_LIST=$(awk -v now="$NOW_TS" -v end_ts="$END_DATE_TS" -F'\t' '
    {
        split($1, dt_parts, " - ");
        start_dt_raw = dt_parts[1];
        
        start_dt_fmt = start_dt_raw;
        sub(/:/, " ", start_dt_fmt);
        
        cmd = "date -d \"" start_dt_fmt "\" +%s";
        if ((cmd | getline event_ts) > 0) {
            close(cmd);
            
            if (event_ts > now && event_ts < end_ts) {
                cmd_fmt = "date -d \"" start_dt_fmt "\" \"+%a %I:%M %p\"";
                cmd_fmt | getline start_time_fmt;
                close(cmd_fmt);

                if ($3 != "") {
                    printf "%s - %s (📍 %s)\n", start_time_fmt, $2, $3;
                } else {
                    printf "%s - %s\n", start_time_fmt, $2;
                }
            }
        } else {
            close(cmd);
        }
    }' "$CACHE_FILE")

    echo -e "$EVENTS_LIST" | rofi -dmenu -p "Upcoming Events" -case-smart -config ~/.config/rofi/rose-pine.rasi
}

# --- Argument parser ---
if [ "$1" == "--onclick" ]; then
    show_upcoming_list
else
    display_waybar
fi
