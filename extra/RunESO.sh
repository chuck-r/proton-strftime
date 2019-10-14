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
  echo "Usage: $0 [launcher|game|install]"
  echo "  This script defaults to running the launcher."
  echo
  echo "  Options:"
  echo "    launcher:  Run the launcher"
  echo
  echo "    game:      Run the game"
  echo
  echo "    install [Install_ESO.exe]:"
  echo "               Automated install script."
  echo
  echo "Automated install script usage:"
  echo "  The automated install script downloads proton-strftime and installs it"
  echo "  into $installer_path by default. It also sets up"
  echo "  the Proton prefix and launches the ESO installer."
  echo
  echo "  To change the destination folder path, edit the installer_path variable in the"
  echo "  script."
  echo
  echo "  By default, the script assumes that the ESO installer is in the location"
  echo "  $HOME/Downloads/Install_ESO.exe. If it is in a different"
  echo "  location, specify it to the script by using:"
  echo "      $0 install /path/to/Install_ESO.exe"
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
    echo "Error: '$eso_path' doesn't exist. Maybe try '$0 install'?"
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
  if [ ! -z "$2" ]
  then
    if [ ! -f "$2" ]
    then
      echo "Cannot find ESO installer at $2"
      exit
    else
      installer_path="$2"
    fi
  fi

  if [ ! -f "$installer_path" ]
  then
    echo "Error: Cannot find ESO installer $installer_path. Place"
    echo "the installer at that location, or re-run the command"
    echo "specifying the installer path."
    echo "(i.e.: $0 install /path/to/Install_ESO.exe)"
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
      echo "Error: wget or curl not installed, cannot fetch the archive. Please intall wget or curl."
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
    echo "Error: Could not fetch $archive"
    rmdir "$eso_path" 2>/dev/null
    exit
  fi

  echo "Extracting $eso_path/$archive..."
  eval $archiver

  if [ $? -ne 0 ]
  then
    echo "Error: Could not extract $eso_path/$archive"
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

  echo "Running ESO installer..."
  STEAM_COMPAT_DATA_PATH="$eso_path" "$eso_path/proton/proton" waitforexitandrun "$installer_path"
fi
