# Wine Mega
**Wine-mega** is a fork of wine combined with latest staging patches, vkd3d and other useful things, to be all-in-one bleeding-edge bundle.

It will be maintained in buildable state and kept up-to-date with latest wine and additions.

! See README for generic information about **wine** !

Current version of **wine-mega** runs Cyberpunk 2077 smoothly out-of-the-box, no additional configuration or external libraries (such as d3d12.dll) needed!

# Build instructions

1) clone:

git clone https://github.com/nr77123/wine-mega.git

2) run build script (sudo needed only if you're installing into system prefix)

cd wine-mega ; sudo ./build_all.sh /opt/wine-mega

3) sit back and relax

p.s. build_all.sh script has reasonable defaults but it's good idea to visually inspect it and adapt as needed. currently it's configured for amd64 systems, builds are incremenental so just run it again after pulling updates and it will do everything
