#!/bin/sh


_d_present_dir=""

_VERSION="0.1"


# Prints whats supposed to be an error.
_ERROR()
{
   printf "%b\n" "${1}" 1>&2
   kill -INT $$
}


# Exec command if error print it.
_EXEC_CMD()
{
   if ! "${@}"
   then
      _ERROR "Unable to exec the following command:\n${1}\nExiting..."
   fi
}

# _PRINT_BOLD()
# {

# }




