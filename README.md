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

Since 1.6 we will move to Swift 3. Please make sure you compile with Xcode >= 8.0.

## Maintainers

Currently, this project is mainly maintained by:

1. [Chase Zhang](github.com/shanzi)
2. [Anakin(Yancheng) Zheng](https://github.com/AnakinMac)

More developers are wanted!

# LICENSE

Main code of this project is licensed under GPLv3. For more details refer to [LICENSE](./LICENSE).
All codes under [extern](./extern) are external dependencies and are still licensed under their original licenses.
