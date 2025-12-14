#!/bin/sh

# Wait for X / NVIDIA to finish initializing
sleep 1

# Disable HDMI for greeter
xrandr --output HDMI-0 --off

# Enable DP-4 and make it primary
xrandr --output DP-4 --auto --primary#!/bin/sh

# Give X a moment to settle (important for NVIDIA)
sleep 1

# Set monitor layout
xrandr \
  --output DP-4   --primary --mode 1920x1080 --pos 0x0 --rotate normal \
  --output HDMI-0 --mode 1920x1200 --pos 1920x0 --rotate normal

# Force cursor onto DP-4 (GTK greeter follows cursor!)
xdotool mousemove 960 540
