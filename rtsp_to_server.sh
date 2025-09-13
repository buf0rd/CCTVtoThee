#!/bin/bash

# ==== Configuration ====
RTSP_URL="rtsp://"
OUTPUT_DIR="/home/thor/cctv_backup"
REMOTE_USER="root"
REMOTE_HOST="YOUR-SERVER-HOSTNAME"
REMOTE_DIR="/var/www/html/zipcode/YOUR-ZIPCODE-DIR"
LOGFILE="/var/log/rtsp_recorder.log"

mkdir -p "$OUTPUT_DIR"

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    OUTPUT_FILE="$OUTPUT_DIR/recording_${TIMESTAMP}.mp4"

    echo "$(date) - Starting recording: $OUTPUT_FILE" >> "$LOGFILE"

    # Record for 36 seconds (adjust -t for duration) into MP4
    ffmpeg -rtsp_transport tcp -fflags +genpts -use_wallclock_as_timestamps 1 \
       -i "$RTSP_URL" -t 36 -c:v libx264 -preset ultrafast -c:a aac -b:a 128k "$OUTPUT_FILE"

    if [ $? -eq 0 ]; then
        echo "$(date) - Finished recording: $OUTPUT_FILE" >> "$LOGFILE"

        # Copy file to remote server
        scp "$OUTPUT_FILE" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"
        if [ $? -eq 0 ]; then
            echo "$(date) - File successfully copied to remote server" >> "$LOGFILE"
            rm -f "$OUTPUT_FILE"  # delete local file after upload
        else
            echo "$(date) - ERROR: Failed to copy file" >> "$LOGFILE"
        fi
    else
        echo "$(date) - ERROR: Recording failed" >> "$LOGFILE"
    fi
done
