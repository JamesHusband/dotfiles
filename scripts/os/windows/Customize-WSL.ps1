using module SendMessage
using module RegistryEntry

#
# ██╗    ██╗███████╗██╗     
# ██║    ██║██╔════╝██║     
# ██║ █╗ ██║███████╗██║     
# ██║███╗██║╚════██║██║     
# ╚███╔███╔╝███████║███████╗
#

##
# Update Windows Taskbar
##

wsl -d Ubuntu -e sudo apt update
wsl -d Ubuntu -e sudo apt upgrade -y