## <p align="center">**BTManager+**</p>

<p align="center">
<img src="https://img.shields.io/badge/Maintained-YES-green.svg?style=for-the-badge" align="center"></img>
<a href="https://paypal.me/beckettobrien">
<img src="https://img.shields.io/badge/Support_Me-PayPal-blue.svg?style=for-the-badge" align="center"></img>
</a>
<img src="https://img.shields.io/badge/Download-Coming_Soon-inactive.svg?style=for-the-badge" align="center"></img>
<!-- <a href="https://chariz.com">
<img src="https://img.shields.io/badge/Download-Chariz-orange.svg?style=for-the-badge" align="center"></img>
</a> -->
</p>

---

BTManager+ is an iOS tweak that attempts to give users more specific control over their bluetooth devices. A large problem with bluetooth devices is that they try to anticipate what the user wants. The goal of this tweak is to enable options that decide when bluetooth devices are allowed to do so. This tweak is written and maintained by Beckett O'Brien. It currently supports `arm64` and `arm64e` devices on iOS 13, with iOS 14 support hopefully on the way.


Features:
- [X] Renaming of Bluetooth Devices (for phone only)
- [X] Displaying a confirm alert when switching to specific devices
- [X] Configuring device priority for each application
- [ ] Renaming of Bluetooth Devices across all phones/devices
- [ ] Disabling the hijacking of audio on connection for specific devices
- [ ] Rearrange the order of devices in the routing menu
- [ ] Enable option to try reconnecting for a few seconds after loosing connection

---
### Building From Source:
Dependencies:
- [Theos](https://github.com/theos/theos) and its dependencies
- Valid iOS 13 sdk patched with Private Frameworks - 13.5 or latest recommended
- [RemoteLog](https://github.com/Muirey03/RemoteLog) - Optional for easier debugging

Instructions:
- Open a terminal to the project directory
- Open the Makefile and change `THEOS_DEVICE_IP` to the IP address of your device or leave blank if just building a package
- Run the command `make package` for a development build or use `make package FINALPACKAGE=1` for a distributable package
- The resulting package will be in the `packages/` directory and the latest built package can now be installed with `make install`

---
### Contributing:
To contribute to this tweak, fork the repository and make the first changes for your contribution. Then open a pull request and I will review your submission. If your pull request is merged and used in a release, your information will be added the the credits. If you would like to help maintain the project, please reach out to me. I always appreciate the help!

If you would like to create a fork of this repository as a new tweak, you are permitted to do so as long as the project is open-source and you credit the original author or authors as currently labeled.

---
### Credits:
- BTManager+ written by Beckett O'Brien
- [libSparkAppList](https://github.com/SparkDev97/libSparkAppList) written by SparkDev
- Special Thanks to everyone on the iOS Development Discord server for all the help

---
### License:
This project is licensed under the GNU General Public License 3.0. More information can be found in the LICENSE.txt file.