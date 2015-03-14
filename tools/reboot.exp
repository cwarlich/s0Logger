#!/usr/bin/expect
# Assume $remote_server, $my_user_id, $my_password, and $my_command were read in earlier
# in the script.
# Open a telnet session to a remote server, and wait for a username prompt.
spawn telnet 192.168.1.1
expect "username:"
# Send the username, and then wait for a password prompt.
send "admin\r"
expect "password:"
# Send the password, and then wait for a shell prompt.
send "RouterinRoth\r"
expect "#"
# Send the prebuilt command, and then wait for another shell prompt.
send "reboot\r"
expect "#"
# Capture the results of the command into a variable. This can be displayed, or written to disk.
#set results $expect_out(buffer)
#puts "$results"
# Exit the telnet session, and wait for a special end-of-file character.
#send "exit\r"
#expect eof
