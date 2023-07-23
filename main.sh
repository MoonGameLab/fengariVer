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
__FENGARIV_LOVE_DIR="${__FENGARIV_DIR}/love"
__FENGARIV_LOVE_DEFLT_FILE="${__FENGARIV_DIR}/default_love"

_ARR_DIRS=( "${__FENGARIV_DIR}" "${__FENGARIV_SRC_DIR}" "${__FENGARIV_LUA_DIR}" "${__FENGARIV_LUA_DEFLT_FILE}" "${__FENGARIV_LUAJIT_DIR}" "${__FENGARIV_LUAJIT_DEFLT_FILE}" "${__FENGARIV_LUAROCKS_DIR}" "${__FENGARIV_LUAROCKS_DEFLT_FILE}" "${__FENGARIV_LOVE_DIR}" "${__FENGARIV_LOVE_DEFLT_FILE}")

declare -A __path_pkg
declare -A __path_pkg_cr
__path_pkg+=( ["lua"]=${__FENGARIV_LUA_DIR} ["luajit"]=${__FENGARIV_LUAJIT_DIR} ["luarocks"]=${__FENGARIV_LUAROCKS_DIR} ["love"]=${__FENGARIV_LOVE_DIR}  )

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

_GET_PATHS()
{

  for key in "${!__path_pkg[@]}"
  do
    if [ -v "__path_pkg_cr[${key}]" ]
    then
      __path_pkg_cr[${key}]=$(command -v ${key})
    else
      __path_pkg_cr+=( ["${key}"]="" )
      __path_pkg_cr[${key}]=$(command -v ${key})
    fi
  done

}

_EXISTS()
{
  _GET_PATHS
  
  for key in "${!__path_pkg_cr[@]}"
  do
    if [ "${1}" = "${key}" ]
    then
      local _path=${__path_pkg_cr[${key}]}
      local _DIR=${__path_pkg[${key}]}

      #The parameter expansion removes the prefix to see if the result is different from the original
      if [ "${_path#$_DIR}" != "${__path_pkg_cr[${key}]}" ]
      then
        return 0
      else
        return 1
      fi
    fi
  done
  
  type "${1}" > /dev/null 2>&1
}

_DOWNLOAD()
{
  local url=$1
  local filename=${url##*/}

  if _EXISTS "wget"
  then
    _EXEC_CMD wget -O "$filename" "${url}"
  elif _EXISTS "curl"
  then
    _EXEC_CMD curl -fLO "${url}"
  else
    _ERROR "'wget' or 'curl' must be installed."
  fi

}

_APPEND_PATH()
{
  export PATH="${1}:${PATH}"
}

_TAR_UNPACK()
{
  _PRINT_TEXT_FORMATTED "Unpacking ${1}"

  if _EXISTS "tar"
  then
    _EXEC_CMD tar xvzf "${1}"
  else
    _ERROR "'tar' must be installed."
  fi
}

_DOWNLOAD_UNPACK()
{
  local unpackDirName=$1
  local archiveName=$2
  local url=$3

  if [ -e "${unpackDirName}" ]
  then
    _PRINT_TEXT_FORMATTED "${unpackDirName} is already downloaded. Download again? [Y/n]:"
    read r choice
    case $choice in
      [yY][eE][sS] | [yY] )
        _EXEC_CMD rm -r "${unpackDirName}" ;;
    esac
  fi

  if [ ! -e "${unpackDirName}" ]
  then

    _PRINT_TEXT_FORMATTED "Downloading ${unpackDirName}"
    _DOWNLOAD "${url}"
    _PRINT_TEXT_FORMATTED "Extracting archive..."
    _TAR_UNPACK "${archiveName}"
    _EXEC_CMD rm "${archiveName}"

  fi

}

# Remove all occurrences of a specified prefix
_REMOVE_PREV_PATHS()
{

  local prefix=$1

  local newPath
  newPath=$(echo "${PATH}" | sed \
    -e "s#${prefix}/[^/]*/bin[^:]*:##g" \
    -e "s#:${prefix}/[^/]*/bin[^:]*##g" \
    -e "s#${prefix}/[^/]*/bin[^:]*##g")

  export PATH=$newPath
}


_GET_PLATFORM()
{
  case $(uname -s 2>/dev/null) in
    Linux )                    echo "linux" ;;
    CYGWIN* | MINGW* | MSYS* ) echo "mingw" ;;
    * )                        echo "unknown or unsupported."
  esac
}

_GET_URL()
{
  if curl -V >/dev/null 2>&1
  then
    curl -fsSL "$1"
  else
    wget -qO- "$1"
  fi
}

_GET_PKG_VERSION()
{
  local version
  
  if [ -v "__path_pkg["${1}"]" ]
  then
    version=$(command -v "${1}")

    if _EXISTS "${1}"
    then
      version=${version#$__path_pkg["${1}"]/}
      echo "${version%/bin/${1}}"
    else
      return 1
    fi
  else
    _ERROR "Package not supported :: See intructions on how to support a new package."
  fi
}




