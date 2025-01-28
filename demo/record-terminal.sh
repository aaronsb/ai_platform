#!/bin/bash

# Function to display usage
show_help() {
    echo "Terminal Recording Script"
    echo "Usage:"
    echo "  ./record-terminal.sh record                        # Start a new recording"
    echo "  ./record-terminal.sh gif <cast-file> <output.gif> # Convert recording to gif"
    echo "  ./record-terminal.sh video <cast-file>            # Convert recording to MP4 video"
    echo "  ./record-terminal.sh help                         # Show this help message"
}

# Record function
record() {
    echo "Starting terminal recording..."
    echo "Press Ctrl+D to stop recording when finished"
    asciinema rec "terminal-recording-$(date +%Y%m%d-%H%M%S).cast"
}

# Convert to gif function
convert_to_gif() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Error: Please provide both input .cast file and output .gif file"
        exit 1
    fi
    
    if [ ! -f "$1" ]; then
        echo "Error: File $1 not found"
        exit 1
    fi
    
    echo "Converting recording to gif..."
    agg "$1" "$2"
    echo "Conversion complete! GIF saved as: $2"
}

# Convert to video function
convert_to_video() {
    if [ -z "$1" ]; then
        echo "Error: Please provide a .cast file to convert"
        exit 1
    fi
    
    if [ ! -f "$1" ]; then
        echo "Error: File $1 not found"
        exit 1
    fi
    
    echo "Converting recording to MP4 video..."
    output_file="${1%.*}.mp4"
    agg --output-format video "$1" -o "$output_file"
    echo "Conversion complete! Video saved as: $output_file"
}

# Main script logic
case "$1" in
    "record")
        record
        ;;
    "gif")
        convert_to_gif "$2" "$3"
        ;;
    "video")
        convert_to_video "$2"
        ;;
    "help"|*)
        show_help
        ;;
esac
