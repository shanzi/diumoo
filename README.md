# Diumoo

Third party client of [Douban.FM](http://douban.fm) for Mac.
For more details, refer to our [Homepage](http://diumoo.net).

## Why?

1. NO Flash, NO web broswer
2. Native code, battery friendly
3. Silently rest in your status bar
4. More features (Time Machine, Search, etc.)

## Installation

Download [precompiled version](https://github.com/shanzi/diumoo/releases) 
or install from [Mac App Store](https://itunes.apple.com/us/app/diumoo/id562734497)

**NOTE**: due to limitations of Mac App Store, some features can not be enabled
in Mac App Store version, ex. use media keys on the keyboard (F7, F8, F9) to control playback.


## Develop

To contribute or compile diumoo by yourself, follow instructions below:

```
git clone git@github.com:shanzi/diumoo.git

git submodule init # Initialize dependencies

brew install libxml2 # Ensure libxml2 is installed
```

Then you can open `diumoo.xcodeproj` and modify the code or compile it.

Pull requests are extremely welcomed. Fork and conforms to [GitHub workflow](https://guides.github.com/introduction/flow/index.html)
before contribution :)

## Maintainers

Currently, this project is mainly maintained by:

1. [Chase Zhang](github.com/shanzi)
2. [Yancheng Zheng](https://github.com/AnakinMac)

More developers are wanted!

# LICENSE

Main code of this project is licensed under GPLv3. For more details refer to [LICENSE](./LICENSE).
All codes under [extern](./extern) are external dependencies and are still licensed under their original licenses.
