#!/bin/bash

#################
# CONFIGURABLES #
#################

installer_path="$HOME/Downloads/Install_ESO.exe"
eso_path="$HOME/.eso"
extra_proton_env="STEAM_COMPAT_DATA_PATH=$eso_path PROTON_NO_ESYNC=1 mesa_glthread=true vblank_mode=0"
game_dir="$eso_path/pfx/drive_c/Program Files (x86)/Zenimax Online"

########################
# END OF CONFIGURABLES #
#######################@

function printusage()
{
  echo "Usage: $0 [launcher|game|install [Install_ESO.exe|--prefix-only]]"
  echo "  This script defaults to running the launcher."
  echo
  echo "  Options:"
  echo -e "    \e[1mlauncher\e[0m:  Run the launcher"
  echo
  echo -e "    \e[1mgame\e[0m:      Run the game"
  echo
  echo -e "    \e[1minstall [Install_ESO.exe]\e[0m:"
  echo "               Automated install script"
  echo
  echo -e "\e[1mAutomated install script usage\e[0m:"
  echo "  The automated install script downloads proton-strftime and installs it"
  echo "  into $eso_path by default. It also sets up the Proton prefix"
  echo "  and launches the ESO installer."
  echo
  echo "  If you already have the game installed elsewhere, use the command"
  echo -e "  '\e[1m$0 install --prefix-only\e[0m' to skip running the installer."
  echo -e "  Then, modify the \e[1mgame_dir\e[0m variable at the top of this script to set"
  echo "  the game files location."
  echo
  echo -e "  To change the prefix path, edit the \e[1minstaller_path\e[0m variable in the"
  echo "  script."
  echo
  echo "  By default, the script assumes that the ESO installer is in the location"
  echo "  $HOME/Downloads/Install_ESO.exe. If it is in a different"
  echo "  location, specify it to the script by using:"
  echo -e "      \e[1m$0 install /path/to/Install_ESO.exe\e[0m"
}

arg="launcher"

if [ ! -z "$1" ]
then
  if [ "$1" != "launcher" ] && [ "$1" != "game" ] && [ "$1" != "install" ]
  then
    printusage
    exit
  fi
  arg="$1"
fi

if [ "$arg" == "launcher" ]
then
  if [ ! -d "$eso_path" ]
  then
    echo -e "\e[1mError: '$eso_path' doesn't exist. Maybe try '$0 install'?\e[0m"
    echo
    printusage
    exit
  fi
  eval env $extra_proton_env $eso_path/proton/proton waitforexitandrun "\"$game_dir/Launcher/Bethesda.net_Launcher.exe\""
elif [ "$arg" == "game" ]
then
  eval env $extra_proton_env $eso_path/proton/proton waitforexitandrun "\"$game_dir/The Elder Scrolls Online/game/client/eso64.exe\""
elif [ "$arg" == "install" ]
then
  prefixonly=0
  if [ ! -z "$2" ]
  then
    if [ "$2" == "--prefix-only" ]
    then
      prefixonly=1
    elif [ ! -f "$2" ]
    then
      echo "Cannot find ESO installer at $2"
      exit
    else
      installer_path="$2"
    fi
  fi

  if [ ! -f "$installer_path" ]
  then
    echo -e "\e[1mError: Cannot find ESO installer $installer_path. Place"
    echo -e "the installer at that location, or re-run the command"
    echo -e "specifying the installer path."
    echo -e "(i.e.: $0 install /path/to/Install_ESO.exe)\e[0m"
    echo
    printusage
    exit
  fi

  echo -n "Creating ESO directory..."
  mkdir -p "$eso_path"
  echo " Done."

  archive="proton-strftime.tar.xz"
  archiver="$(which tar) -C \"$eso_path\" -xJf \"$eso_path/$archive\""

  fetcher="$(which wget)"
  if [ -z "$fetcher" ]
  then
    fetcher="$(which curl)"
    if [ -z "$fetcher" ]
    then
      echo -e "\e[1mError: wget or curl not installed, cannot fetch the archive. Please intall wget or curl.\e[0m"
      exit
    fi
    fetcher="$fetcher -LR -o \"$eso_path/$archive\""
    if [ -f "$eso_path/$archive" ]
    then
      fetcher="$fetcher -z \"$eso_path/$archive\""
    fi
  else
    fetcher="$fetcher -P \"$eso_path\" -N"
  fi

  fetcher="$fetcher https://github.com/chuck-r/Proton/releases/latest/download/$archive"
  echo "Downloading $archive..."
  eval $fetcher

  if [ $? -ne 0 ]
  then
    echo -e "\e[1mError: Could not fetch $archive\e[0m"
    rmdir "$eso_path" 2>/dev/null
    exit
  fi

  echo "Extracting $eso_path/$archive..."
  eval $archiver

  if [ $? -ne 0 ]
  then
    echo -e "\e[1mError: Could not extract $eso_path/$archive\e[0m"
    rm "$eso_path/$archive"
    exit
  fi

  if [ -L "$eso_path/proton" ]
  then
    echo -n "Removing old symlink..."
    rm "$eso_path/proton"
    echo " Done."
  fi
  echo -n "Creating $eso_path/proton symlink..."
  ln -s $(ls -dt --group-directories-first "$eso_path"/proton-* | head -n 1) "$eso_path/proton"
  echo " Done."

  echo -n "Copying Proton prefix to $eso_path..."
  cp -R "$eso_path/proton/dist/share/default_pfx" "$eso_path/pfx"
  echo " Done."

  if [ $prefixonly -eq 0 ]
  then
    echo "Running ESO installer..."
    STEAM_COMPAT_DATA_PATH="$eso_path" "$eso_path/proton/proton" waitforexitandrun "$installer_path"
  fi
fi
