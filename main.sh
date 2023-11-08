#!/bin/sh


_d_present_dir=""

_VERSION="0.1"

#verbose lvl
_LUA_VER=0


# FENGARIV Location
__FENGARIV_DIR="${HOME}/.fengariv"


_PACKAGES=(
  "lua"
  "luajit"
  "luarocks"
  "love"
  # "moon" Use luarocks for that
)

declare -A _ARR_DIRS

_INIT_DIRS()
{
  for pkg in "${_PACKAGES[@]}"
  do    
    _ARR_DIRS+=( ["${pkg}_dir"]="${__FENGARIV_DIR}/${pkg}" )
    _ARR_DIRS+=( ["${pkg}_default"]="${__FENGARIV_DIR}/default_${pkg}" )    
  done
}
_INIT_DIRS

SRC_DIR="${__FENGARIV_DIR}/src"

declare -A __path_pkg
declare -A __path_pkg_cr

__path_pkg+=( # TODO: Should be refactored later to be dynamic.
    ["lua"]=${_ARR_DIRS["lua_dir"]} 
    ["luajit"]=${_ARR_DIRS["luajit_dir"]} 
    ["luarocks"]=${_ARR_DIRS["luarocks_dir"]} 
    ["love"]=${_ARR_DIRS["love_dir"]} 
    ["moon"]=${_ARR_DIRS["moon_dir"]} 
  )

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

  _PRINT_BOLD "Creating directory at path : ${SRC_DIR}"
  if [ ! -e "${path}" ]
  then
    _EXEC_CMD mkdir "${SRC_DIR}"
  fi

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
    _PRINT_TEXT_FORMATTED "loool " "${filename}" "${url}"
    _PRINT_TEXT_FORMATTED "${filename}" 
    _PRINT_TEXT_FORMATTED "${url}" 
    _EXEC_CMD wget -O "${filename}" "${url}"
  elif _EXISTS "curl"
  then
    _EXEC_CMD curl -fLO "${url}"
  else
    _ERROR "'wget' or 'curl' must be installed."
  fi

}

_APPEND_PATH()
{
  _PRINT_TEXT_FORMATTED "IN APPEND PATH"
  _PRINT_TEXT_FORMATTED "${1}" 
  export PATH="${1}:${PATH}"
  _PRINT_TEXT_FORMATTED "${PATH}"
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
    read -r choice
    case $choice in
      [yY][eE][sS] | [yY] )
        _EXEC_CMD rm -r "${unpackDirName}"
        ;;
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

_GET_PKG_VERSION_SHORT()
{
  local version=""

  if [ -v "__path_pkg["${1}"]" ]
  then
    version=$(command -v "${1}")

    if _EXISTS "${1}"
    then
      version=$("${1}" -e 'print(_VERSION:sub(5))')
      echo "${version}"
    fi
  else
    _ERROR "Package not supported :: See intructions on how to support a new package."
  fi

}


_FENGARIV_UNINSTALL()
{
  local pkgName=$1
  local pkgPath=$1
  local pkgDir=$1

  _PRINT_TEXT_FORMATTED "Uninstalling ${pkgName}"

  _EXEC_CMD cd "${pkgPath}"
  if [ ! -e "${pkgDir}" ]
  then
    _ERROR "${pkgName} is not installed. You got baited."
  fi

  _EXEC_CMD rm -r "${pkgDir}"
  _PRINT_TEXT_FORMATTED "${pkgName} was successfully unistalled."
}



# LUA

GET_LUA_VERSION_LUAROCKS()
{
  local version
  version=$(command -v luarocks)

  if _EXISTS "luarocks"
  then
    version=${version#${_ARR_DIRS["luarocks_dir"]}}
    version=${version%/bin/luarocks}
    echo "${version#*_}"
  else
    return 1
  fi
}


INSTALL_LUA()
{

  local version=$1
  local luaDirName="lua-${version}"
  local archiveName="${luaDirName}.tar.gz"
  local url="http://www.lua.org/ftp/${archiveName}"

  _PRINT_TEXT_FORMATTED "Installing ${luaDirName}"
  local luaDir=${_ARR_DIRS["lua_dir"]}
  _EXEC_CMD cd "${SRC_DIR}"
  _DOWNLOAD_UNPACK "${luaDirName}" "${archiveName}" "${url}"

  _PRINT_TEXT_FORMATTED "Detecting Platform..."
  
  platform=$(_GET_PLATFORM)
  if [ "${platform}" = "unknown" ]
  then
    _PRINT_TEXT_FORMATTED "Unable to detect platform :: Using default 'posix'"
    platform=posix
  else
    _PRINT_TEXT_FORMATTED "Installing for ${platform}"
  fi

  _EXEC_CMD cd "${luaDirName}"
  _PRINT_TEXT_FORMATTED "Compiling ${luaDirName}"
  _EXEC_CMD make "${platform}" install INSTALL_TOP="${luaDir}/${version}"

  _PRINT_TEXT_FORMATTED "${luaDirName} successfully installed."

}

USE_LUA()
{
  local version=$1
  local luaName="lua-${version}"
  local luaDir=${_ARR_DIRS["lua_dir"]}

  _EXEC_CMD cd "${luaDir}"

  if [ ! -e "${version}" ]
  then
    _PRINT_TEXT_FORMATTED "${luaName} is not installed, Do you want to install it? [Y/n]:"
    read -r choice
    case choice in
      [yY][eE][sS] | [yY] )
          INSTALL_LUA "${version}"
          ;;
      * )
          _ERROR "Unable to use ${luaName}"
    esac
    return
  fi

  _REMOVE_PREV_PATHS "${luaDir}"
  _PRINT_TEXT_FORMATTED "${luaDir}/${version}/bin"
  _APPEND_PATH "${luaDir}/${version}/bin"

  _PRINT_TEXT_FORMATTED "Switched to ${luaName} successfully."
}


# LUAROCKS

USE_LUAROCKS()
{
  local version=$1
  local luarocks_name="luarocks-${version}"

  lua_version=$(_GET_PKG_VERSION_SHORT "lua")

  if [ "${lua_version}" = "" ]
  then
    _ERROR "You need to switch to a Lua installer version first."
  fi

  _PRINT_TEXT_FORMATTED "Switching to ${luarocks_name} with lua version: ${lua_version}"

  _EXEC_CMD cd "${_ARR_DIRS["luarocks_dir"]}"

  if [ ! -e "${version}_${lua_version}" ]
  then
    _PRINT_TEXT_FORMATTED "${luarocks_name} is not installed with lua version ${lua_version}. Want to install it? [Y/n]: "
    read -r choice

    case $choice in
      [yY][eE][sS] | [yY] )
        INSTALL_LUAROCKS "${version}"
        ;;
      * )
        _ERROR "Unable to use ${luarocks_name}"
    esac
    return
  fi

  _REMOVE_PREV_PATHS "${_ARR_DIRS["luarocks_dir"]}"
  _APPEND_PATH "${_ARR_DIRS["luarocks_dir"]}/${version}_${lua_version}/bin"

  eval "$(luarocks path)"

  _PRINT_TEXT_FORMATTED "Successfully switched to ${luarocks_name}"

}

INSTALL_LUAROCKS()
{

  lua_version=$(_GET_PKG_VERSION "lua")
  # if [ "" = "${lua_version}" ]
  # then
  #   _ERROR "No lua version."
  # fi

  lua_version_short=$(_GET_PKG_VERSION_SHORT "lua")

  local version=$1
  local luarocks_dir_name="luarocks-${version}"
  local archive_name="${luarocks_dir_name}.tar.gz"
  local url="http://luarocks.org/releases/${archive_name}"

  _PRINT_TEXT_FORMATTED "Installing ${luarocks_dir_name} for lua version ${lua_version}"
  
  local luarocksDir=${_ARR_DIRS["luarocks_dir"]}
  local luaDir=${_ARR_DIRS["lua_dir"]}
  _EXEC_CMD cd "${SRC_DIR}"

  _DOWNLOAD_UNPACK "${luarocks_dir_name}" "${archive_name}" "${url}"

  _EXEC_CMD cd "${luarocks_dir_name}"

  _PRINT_TEXT_FORMATTED "Compiling ${luarocks_dir_name}"
  
  _EXEC_CMD ./configure \
    --prefix="${luarocksDir}/${version}_${lua_version_short}" \
    --with-lua="${luaDir}/${lua_version}" \
    --with-lua-bin="${luaDir}/${lua_version}/bin" \
    --with-lua-include="${luaDir}/${lua_version}/include" \
    --with-lua-lib="${luaDir}/${lua_version}/lib" \
    --versioned-rocks-dir

  _EXEC_CMD make build
  _EXEC_CMD make install

  _PRINT_TEXT_FORMATTED "${luarocks_dir_name} successfully installer. Switch to this version ? [Y/n]:"
  read -r choice
  case $choice in
    [yY][eE][sS] | [yY] )
      USE_LUAROCKS "${version}"
      ;;
  esac
}


USAGE()
{
  _PRINT_TEXT_FORMATTED "MGL Lua Version Manager : ${_VERSION}"
  


}



RUN()
{
  _d_present_dir=$(pwd)

  local cmd="${1}"

  if [ ${#} -gt 0 ]
  then
    shift
  fi

  case $cmd in
    "help") USAGE;;
    
    "install-lua" ) INSTALL_LUA "${@}";;
    "use-lua" ) USE_LUA "${@}";;
    
    "install-luarocks" ) INSTALL_LUAROCKS "${@}";;
    "install-luarks" ) INSTALL_LUAROCKS "${@}";;
    "use-luarks" ) USE_LUA "${@}";;
    "use-luarocks" ) USE_LUA "${@}";;
    *) USAGE;;
  esac

}


# [ -n "$1" ] && RUN "$@"