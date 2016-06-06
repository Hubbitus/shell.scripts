#!/bin/bash

# http://stackoverflow.com/a/25942100/307525
printf -v command '%q ' date +'%F %X'
printf -v outer_command '%q ' sudo -u root bash -c "$command"
printf -v ssh_command '%q ' ssh localhost "$outer_command"
eval "$ssh_command"
