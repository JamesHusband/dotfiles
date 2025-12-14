#!/bin/sh

# Wait for greeter to finish initializing
sleep 0.5

# Force HDMI off AGAIN (GTK greeter may re-enable it)
xrandr --output HDMI-0 --off

# Ensure DP-4 stays primary
xrandr --output DP-4 --primary

