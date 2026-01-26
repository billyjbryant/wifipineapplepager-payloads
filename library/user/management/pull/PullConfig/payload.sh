#!/bin/bash
# Title: Pull Config
# Description: Configure management_pull settings for PullPayload* payloads
# Author: billyjbryant
# Version: 1.0

CONFIG_NAME="management_pull"
PROMPT_REVIEW_KEY="prompt_review"
PROMPT_OVERWRITE_KEY="prompt_overwrite"

get_config() {
    PAYLOAD_GET_CONFIG "$CONFIG_NAME" "$1" 2>/dev/null
}

set_config() {
    PAYLOAD_SET_CONFIG "$CONFIG_NAME" "$1" "$2"
}

LED SETUP
LOG "Configuring management_pull settings..."

prompt_review=$(get_config "$PROMPT_REVIEW_KEY")
prompt_overwrite=$(get_config "$PROMPT_OVERWRITE_KEY")

if [ -z "$prompt_review" ]; then
    prompt_review="1"
fi

if [ -z "$prompt_overwrite" ]; then
    prompt_overwrite="1"
fi

while true; do
    LED SPECIAL
    
    current_review="Disabled"
    [ "$prompt_review" = "1" ] && current_review="Enabled"
    
    current_overwrite="Disabled"
    [ "$prompt_overwrite" = "1" ] && current_overwrite="Enabled"
    
    menu_msg="management_pull Configuration:\n\n"
    menu_msg+="1) Prompt to review each file: $current_review\n"
    menu_msg+="2) Prompt to overwrite original files: $current_overwrite\n"
    menu_msg+="3) Save and exit"
    
    ack=$(PROMPT "$menu_msg" "")
    case $? in
        $DUCKYSCRIPT_CANCELLED|$DUCKYSCRIPT_REJECTED|$DUCKYSCRIPT_ERROR)
            LED FAIL
            exit 1
            ;;
    esac
    
    choice=$(NUMBER_PICKER "Select option (1-3)" 1)
    case $? in
        $DUCKYSCRIPT_CANCELLED|$DUCKYSCRIPT_REJECTED|$DUCKYSCRIPT_ERROR)
            LED FAIL
            exit 1
            ;;
    esac
    
    case "$choice" in
        1)
            resp=$(CONFIRMATION_DIALOG "Enable prompt to review each file?")
            case $? in
                $DUCKYSCRIPT_USER_CONFIRMED)
                    prompt_review="1"
                    LOG "Prompt review: Enabled"
                    ;;
                $DUCKYSCRIPT_USER_DENIED)
                    prompt_review="0"
                    LOG "Prompt review: Disabled"
                    ;;
                $DUCKYSCRIPT_CANCELLED|$DUCKYSCRIPT_REJECTED|$DUCKYSCRIPT_ERROR)
                    continue
                    ;;
            esac
            ;;
        2)
            resp=$(CONFIRMATION_DIALOG "Enable prompt to overwrite original files?")
            case $? in
                $DUCKYSCRIPT_USER_CONFIRMED)
                    prompt_overwrite="1"
                    LOG "Prompt overwrite: Enabled"
                    ;;
                $DUCKYSCRIPT_USER_DENIED)
                    prompt_overwrite="0"
                    LOG "Prompt overwrite: Disabled"
                    ;;
                $DUCKYSCRIPT_CANCELLED|$DUCKYSCRIPT_REJECTED|$DUCKYSCRIPT_ERROR)
                    continue
                    ;;
            esac
            ;;
        3)
            break
            ;;
        *)
            ERROR_DIALOG "Invalid selection"
            continue
            ;;
    esac
done

LED SETUP
LOG "Saving configuration..."

set_config "$PROMPT_REVIEW_KEY" "$prompt_review"
set_config "$PROMPT_OVERWRITE_KEY" "$prompt_overwrite"

final_review="Disabled"
[ "$prompt_review" = "1" ] && final_review="Enabled"

final_overwrite="Disabled"
[ "$prompt_overwrite" = "1" ] && final_overwrite="Enabled"

LED FINISH
ALERT "Configuration saved:\n\nPrompt review: $final_review\nPrompt overwrite: $final_overwrite"
