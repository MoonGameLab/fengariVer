source ../main.sh


_EXEC_CMD ls "../" #s

_PRINT_BOLD "Hello bold" #s


# {
#     _PRINT_TEXT_FORMATTED "formatted 1"
#     _PRINT_TEXT_FORMATTED "formatted 2"
#     _PRINT_TEXT_FORMATTED "formatted 3"
# } #s

# # { # Dir paths
# #     _PRINT_TEXT_FORMATTED ${__FENGARIV_DIR}
# #     _PRINT_TEXT_FORMATTED ${__FENGARIV_SRC_DIR}
# #     _PRINT_TEXT_FORMATTED ${__FENGARIV_LUA_DIR}
# #     _PRINT_TEXT_FORMATTED ${__FENGARIV_LUA_DEFLT_DIR}
# #     _PRINT_TEXT_FORMATTED ${__FENGARIV_LUAJIT_DIR}
# #     _PRINT_TEXT_FORMATTED ${__FENGARIV_LUAJIT_DEFLT_DIR}
# #     _PRINT_TEXT_FORMATTED ${__FENGARIV_LUAROCKS_DIR}
# #     _PRINT_TEXT_FORMATTED ${__FENGARIV_LUAROCKS_DEFLT_DIR}
# # } #s


# _INIT_FENGARI #s

if _EXISTS "lua"
then  
    _PRINT_TEXT_FORMATTED "EXISTS"
else
    _PRINT_TEXT_FORMATTED "Does not EXIST"
fi

# _GET_PLATFORM


_EXISTS "lua"

# _GET_PKG_VERSION "lua"

#_DOWNLOAD "https://www.lua.org/ftp/lua-5.4.6.tar.gz" #OK

_ERROR "\nError printing test." #s

