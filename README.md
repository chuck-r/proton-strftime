---
[Original Proton README](https://github.com/ValveSoftware/Proton/README.md)
---

What is this?
=====

This is a custom build of Proton to fix some issues I found with ESO. Specifically, if any ESO AddOns use os.date()
with any of many substitions that are unimplemented by Wine, the result will be nil -- an unexpected outcome for any AddOn.
This causes any AddOns that uses these substitutions to crash, resulting in unexpected behaviour.

I submitted a patch to WineHQ (Bug #[47809](https://bugs.winehq.org/show_bug.cgi?id=47809)) with a fix for these issues,
but due to the politics of Wine development, they are probably unlikely to make it upstream. So, I opted instead to
apply my patch to Proton.

This repository's releases contains a build of Proton 4.11 with this patch applied.

-----
The Easy Way: Install Into Steam
=====

Using this method to install Proton is, by far, the easiest method providing that you have ESO installed in Steam.

**NOTE:** I do not have ESO installed with Steam, so if my instructions are not clear or are incorrect, please let me know.

1. Create the custom Proton directory (if it doesn't exist): `mkdir ~/.steam/root/compatibilitytools.d/`
2. Download [proton-strftime.7z](https://github.com/chuck-r/Proton/releases/latest/download/proton-strftime.7z) and extract the whole folder inside into ~/.steam/root/compatibilitytools.d
3. Restart the Steam client
4. Right-click 'The Elder Scrolls Online' in your game library and open `Properties...`
5. In the General tab, click the checkbox that says "Force the use of a specific Steam Play compatibility tool"
6. From the drop-down menu select "proton-4.11-6-strftime"
7. Run the game, and enjoy!

-----
Without Steam: The Easy Way
=====

I have provided an [automated installation and run script](https://raw.githubusercontent.com/chuck-r/Proton/proton_4.11/extra/RunESO.sh) in the `extra` folder in this repository. It automates
"The Hard Way" below.

To setup the ESO Proton folder and automatically install ESO use the following command:

    ./RunESO.sh install

This assumes that your ESO Installer (Install\_ESO.exe) is in ~/Downloads/Install_ESO.exe. If it is not, use the
alternative command:

    ./RunESO.sh install /path/to/Install_ESO.exe

By default, this installs Proton and ESO into the ~/.eso folder. To change this, modify the `eso_path` variable at the top of the script.

Afterwards, to run the launcher you can use the command:

    ./RunESO.sh

To skip the launcher you can use

    ./RunESO.sh game

If you already have an ESO data directory located elsewhere, change the variable `game_dir` within the script. The folder that
this variable points to should have a structure like this:

    game_dir
    |
    |__ Launcher
    |   |__ Bethesda.net_Launcher.exe
    |
    |__ The Elder Scrolls Online
    |   |__ game
    |       |__ client
    |           |__ eso64.exe
    |
    |__ uninstall
    |__ ZosSteamStarter.version

-----
The hard way: Run ESO from Proton directly (manual setup)
=====

If, like me, you haven't purchased ESO from Steam, then you have to set up Proton to run ESO outside of Wine. This
is a little difficult to understand (even from a seasoned Wine user's perspective), so I'm going to provide my own
scripts and methods for running ESO outside of Steam.

### 1. Create a Proton directory for ESO
In my case, I created a directory called ~/.eso. Make the directory and cd into it.

`mkdir ~/.eso`
`cd ~/.eso`

### 2. Extract proton-strftime to ~/.eso
Extract the folder from [proton-strftime.7z](https://github.com/chuck-r/Proton/releases/latest/download/proton-strftime.7z) to ~/.eso using your favorite archive manager with 7zip support.

For ease of future updates, create a symlink for ~/.eso/proton to ~/.eso/proton-4.11-6-strftime

`ln -s ~/.eso/proton-4.11-6-strftime ~/.eso/proton`

This way, you can keep multiple Proton versions in the folder and swap between them by simply changing where the symlink
points.

### 3. Copy the Proton prefix
`cp -R ~/.eso/proton-4.11-6-strftime/dist/share/default_pfx ~/.eso/pfx`

### 4. Install ESO
`STEAM_COMPAT_DATA_PATH=~/.eso ~/.eso/proton/proton waitforexitandrun /path/to/Install_ESO.exe`

### 5. Run manually or with the script
The command line I use to run ESO manually:

    STEAM_COMPAT_DATA_PATH=~/.eso PROTON_NO_ESYNC=1 mesa_glthread=true vblank_mode=0 ~/.eso/proton/proton waitforexitandrun "$HOME/.eso/pfx/drive_c/Program Files (x86)/Zenimax Online/launcher/Bethesda.net_Launcher.exe"

I have also provided a script in the `extra` folder that can be customized to most use cases. Once the variables are set to your needs, run:

    ./RunESO.sh launcher

or

    ./RunESO.sh game
