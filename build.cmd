echo off
setlocal
set root=%cd%
set srcd=%root%\src
set intd=%root%\build\int
set outd=%root%\build\bin

set in=-I inc -I vendor/rapidjson/include/rapidjson
set cc=-c -Wmain -Wimplicit -Wparentheses -Wmissing-braces -Wformat -Wcomment       ^
          -Wchar-subscripts -Wsequence-point -Wreturn-type -Wunused -Wuninitialized ^
          -DDISCORD_DYNAMIC_LIB -DDISCORD_BUILDING_SDK -fPIC --std=c++17 
set ld=

if ["%1"]==["debug"] (
  goto :debug
)

if ["%1"]==["release"] (
  goto :release
)

goto :ship

:debug
  set intd=%intd%\debug
  set cc=%cc% -pg -gdwarf -fno-pie -O0
  set ld=%ld% -pg
  goto :build
:release
  set intd=%intd%\release
  set cc=%cc% -pg -gdwarf -fno-pie -O2
  set ld=%ld% -pg
  goto :build
:ship
  set intd=%intd%\ship
  set cc=%cc% -fno-pie -O2
  set ld=%ld%

:build
if not exist %outd% (
  mkdir %outd%
)

if not exist %intd% (
  mkdir %intd%
)

call g++.exe %cc% %in% %srcd%\connection.cpp ^
                    -o %intd%\connection.o

call g++.exe %cc% %in% %srcd%\discord_register.cpp ^
                    -o %intd%\discord_register.o

call g++.exe %cc% %in% %srcd%\discord_rpc.cpp ^
                    -o %intd%\discord_rpc.o

call g++.exe %cc% %in% %srcd%\rpc_connection.cpp ^
                    -o %intd%\rpc_connection.o

call g++.exe %cc% %in% %srcd%\serialization.cpp ^
                    -o %intd%\serialization.o

call g++.exe %ld% -o %outd%\discord-rpc.dll %intd%\* ^
             -s -shared -Wl,--out-implib,%outd%\discord-rpc.lib