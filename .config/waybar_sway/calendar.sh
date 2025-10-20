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
    EVENT_TS=0

    # Find the first upcoming event and its timestamp from the cache file
    while IFS= read -r line || [[ -n "$line" ]]; do
        START_DATETIME_STR=$(echo "$line" | awk '{print $1}')
        START_DATETIME_FORMATTED=$(echo "$START_DATETIME_STR" | sed 's/:/ /')
        
        if ! TEMP_TS=$(date -d "$START_DATETIME_FORMATTED" +%s 2>/dev/null); then
            continue
        fi

        if (( TEMP_TS > NOW_TS )); then
            NEXT_EVENT_LINE="$line"
            EVENT_TS=$TEMP_TS
            break
        fi
    done < "$CACHE_FILE"

    if [ -z "$NEXT_EVENT_LINE" ]; then
        echo '{"text": "󰃭 No upcoming events", "tooltip": "No events for today"}'
        exit 0
    fi

    DIFF_SEC=$((EVENT_TS - NOW_TS))
    if (( DIFF_SEC < 60 )); then
        TIME_UNTIL="< 1m"
    else
        TOTAL_MINUTES=$((DIFF_SEC / 60))
        HOURS=$((TOTAL_MINUTES / 60))
        MINUTES=$((TOTAL_MINUTES % 60))

        if (( HOURS > 0 )); then
            TIME_UNTIL="${HOURS}h ${MINUTES}m"
        else
            TIME_UNTIL="${MINUTES}m"
        fi
    fi

    DATETIME_PART=$(echo "$NEXT_EVENT_LINE" | awk -F'\t' '{print $1}')
    TITLE=$(echo "$NEXT_EVENT_LINE" | awk -F'\t' '{print $2}' | sed 's/&/&amp;/g')
    LOCATION=$(echo "$NEXT_EVENT_LINE" | awk -F'\t' '{print $3}' | sed 's/&/&amp;/g')

    START_STR=$(echo "$DATETIME_PART" | awk '{print $1}')
    END_STR=$(echo "$DATETIME_PART" | awk '{print $3}')
    
    START_DATETIME_FORMATTED=$(echo "$START_STR" | sed 's/:/ /')
    END_DATETIME_FORMATTED=$(echo "$END_STR" | sed 's/:/ /')

    START_TIME=$(date -d "$START_DATETIME_FORMATTED" "+%I:%M %p")
    END_TIME=$(date -d "$END_DATETIME_FORMATTED" "+%I:%M %p")
    
    START_TS=$(date -d "$START_DATETIME_FORMATTED" +%s)
    END_TS=$(date -d "$END_DATETIME_FORMATTED" +%s)
    DURATION_MIN=$(((END_TS - START_TS) / 60))
    DURATION_STR="$((DURATION_MIN / 60))h $((DURATION_MIN % 60))m"

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
    
    TEXT="󰃭 in $TIME_UNTIL - $TRUNCATED_TITLE"

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
        end_dt_raw = dt_parts[2];
        
        start_dt_fmt = start_dt_raw;
        sub(/:/, " ", start_dt_fmt);
        
        end_dt_fmt = end_dt_raw;
        sub(/:/, " ", end_dt_fmt);
        
        cmd = "date -d \"" start_dt_fmt "\" +%s";
        if ((cmd | getline event_ts) > 0) {
            close(cmd);
            
            if (event_ts > now && event_ts < end_ts) {
                cmd_start_fmt = "date -d \"" start_dt_fmt "\" \"+%I:%M %p\"";
                cmd_start_fmt | getline start_time_str;
                close(cmd_start_fmt);

                cmd_end_fmt = "date -d \"" end_dt_fmt "\" \"+%I:%M %p\"";
                cmd_end_fmt | getline end_time_str;
                close(cmd_end_fmt);

                cmd_day_fmt = "date -d \"" start_dt_fmt "\" \"+%a\"";
                cmd_day_fmt | getline day_str;
                close(cmd_day_fmt);
                
                title = $2;
                gsub(/&/, "&amp;", title);
                gsub(/</, "&lt;", title);
                gsub(/>/, "&gt;", title);
                
                location = $3;
                gsub(/&/, "&amp;", location);
                gsub(/</, "&lt;", location);
                gsub(/>/, "&gt;", location);

                # *** THE DEFINITIVE FIX ***
                # Check if the title contains Arabic characters.
                is_rtl = (title ~ /[\u0600-\u06FF]/);

                if (is_rtl) {
                    # For RTL titles, wrap the title in Directional Isolates.
                    # This lets the Arabic render correctly as RTL, but contains its
                    # directional influence so it does not affect the LTR location.
                    # The \u202d at the start ensures the components (date, title, loc)
                    # are ordered correctly left-to-right overall.
                    printf "\u202d%s (%s - %s) - \u2067%s\u2069", day_str, start_time_str, end_time_str, title;
                } else {
                    # For standard LTR titles, print normally.
                    printf "%s (%s - %s) - %s", day_str, start_time_str, end_time_str, title;
                }
                
                if (location != "") {
                    # A Left-to-Right Mark (\u200e) creates a strong LTR boundary
                    # that protects the span from the preceding RTL text.
                    printf "\u200e <span size=\"small\" font_style=\"italic\" weight=\"light\">| 📍 %s</span>", location;
                }
                printf "\n";
            }
        } else {
            close(cmd);
        }
    }' "$CACHE_FILE")

    echo -e "$EVENTS_LIST" | rofi -dmenu -markup-rows -p "Upcoming Events" -case-smart -config ~/.config/rofi/rose-pine.rasi
}

# --- Argument parser ---
if [ "$1" == "--onclick" ]; then
    show_upcoming_list
else
    display_waybar
fi
