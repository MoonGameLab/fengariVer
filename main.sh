#!/bin/sh


_d_present_dir=""

_VERSION="0.1"

#verbose lvl
_LUA_VER=0


# DIRS && FILES
__FENGARIV_DIR="${HOME}/.fengariv"
__FENGARIV_SRC_DIR="${__FENGARIV_DIR}/src"
__FENGARIV_LUA_DIR="${__FENGARIV_DIR}/lua"
__FENGARIV_LUA_DEFLT_FILE="${__FENGARIV_DIR}/default_lua"
__FENGARIV_LUAJIT_DIR="${__FENGARIV_DIR}/luajit"
__FENGARIV_LUAJIT_DEFLT_FILE="${__FENGARIV_DIR}/default_luajit"
__FENGARIV_LUAROCKS_DIR="${__FENGARIV_DIR}/luarocks"
__FENGARIV_LUAROCKS_DEFLT_FILE="${__FENGARIV_DIR}/default_luarocks"


_ARR_DIRS=( "${__FENGARIV_DIR}" "${__FENGARIV_SRC_DIR}" "${__FENGARIV_LUA_DIR}" "${__FENGARIV_LUA_DEFLT_FILE}" "${__FENGARIV_LUAJIT_DIR}" "${__FENGARIV_LUAJIT_DEFLT_FILE}" "${__FENGARIV_LUAROCKS_DIR}" "${__FENGARIV_LUAROCKS_DEFLT_FILE}" )


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


# Prints bold text.
_PRINT_BOLD()
{
  if [ ! $_LUA_VER = 0 ]
  then
    tput bold
    printf "==> %b\n" "${1}"
    tput sgr0
  fi
}

_PRINT_TEXT_FORMATTED()
{
  printf "%b\n" "${1}"
}

_INIT_FENGARI()
{
  _LUA_VER=1
  
  _d_present_dir=$(pwd)

  for path in "${_ARR_DIRS[@]}"
  do
    _PRINT_BOLD "Creating directory at path : ${path}"
    if [ ! -e "${path}" ]
    then
      _EXEC_CMD mkdir "${path}"
    fi
  done

  _EXEC_CMD cd "${_d_present_dir}"

}

_EXISTS()
{
  local luaPath
  local luajitPath
  local luarocksPath

  # see if paths exist
  luaPath=$(command -v lua)
  luajitPath=$(command -v luajit)
  luarocksPath=$(command -v luarocks)
  
  if [ "${1}" = "lua" ]
  then
    #The parameter expansion removes the prefix to see if the result is different from the original
    if [ "${luaPath#$__FENGARIV_LUA_DIR}" != "${luaPath}" ]
    then
      return 0
    else
      return 1
    fi
  fi

  if [ "${1}" = "luajit" ]
  then
    if [ "${luajitPath#$__FENGARIV_LUAJIT_DIR}" != "${luajitPath}" ]
    then
      return 0
    else
      return 1
    fi
  fi

  if [ "${1}" = "luarocks" ]
  then
    if [ "${luarocksPath#$__FENGARIV_LUAROCKS_DIR}" != "${luarocksPath}" ]
    then
      return 0
    else
      return 1
    fi
  fi

  type "${1}" > /dev/null 2>&1
}


_DOWNLOAD()
{
  local url=$1
  local filename=${url##*/}



}




