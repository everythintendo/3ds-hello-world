# 3ds-hello-world
A template you can use to generate a Visual Studio Code project for building
Nintendo 3DS applications using devkitARM and libctru.

## Notice
You need at least basic knowledge of C (and/or C++) in order to be able to
completely understand the code here. Take some
[free C courses](https://www.google.com/search?q=Free+C+courses+for+beginners)
if you need to, it's okay to not know, and we're glad if we made you take a
step into the IT. Know that everything you might learn can help you later...
not spoiling though. :)


## Basic usage (IntelliSense & building the app into an ELF & 3DSX)
- Install a Homebrew launcher for your 3DS by following
[this kind of guide](https://3ds.hacks.guide/).

- Download and install devkitARM and the 3DS development toolchains from the
[devkitPro website](https://devkitpro.org/wiki/Getting_Started).

- Install [the C/C++ extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools).

- Create your own repository from this one using the "Use this template" button
above the file list.

- Clone your freshly created repository and open the workspace (which should
have a folder named .vscode at its root) with Visual Studio Code.

- Browse the code, modify it...

- Build it using the `make` command from a Terminal opened in the workspace
root (where the "Makefile" file resides).


## Advanced usage
What falls under the 'advanced usage' is everything that needs an external tool
not (yet) included in the devkitPro kit.

As the following tools are not part of this bundle (as opposed to `libctru`
i.e.), we suggest creating a special folder just for user-installed tools and
adding it to your PATH. I personally created a `usertools` folder in the
devkitPro folder (`C:\devkitPro` by default on a Windows installation).

Also, some of these informations may not be up to date and the toolchain
authors may add some of these tools to their bundle. Check the
`(DEVKITPRO INSTALL FOLDER)/tools/bin` folder before each installation to make
sure you don't already have what we want you to add.


### Building an application into a CIA file
Basically, what happens is that the code is first compiled to a .ELF file
(Executable and Linkable Format, basically a universal executable type), then
into a .3DSX file (a Homebrew app, that *needs* Homebrew in order to be run)
using the `3dsxtool` (included in the devkitPro bundle). And that is what is
done (and described in the [first section](#Advanced_usage)) without the need
of any external tool after installing devkitPro.

But what we want here is a CIA (CTR Importable Archive) file, which represents
game content on a Nintendo 3DS handheld device. They are usually used for
installing gamecard updates and eShop content. It is what you would install
using a title manager, such as [FBI](https://github.com/Steveice10/FBI). It
makes your application completely runnable directly from the HOME menu, without
having to use a [Homebrew Launcher](https://github.com/fincs/new-hbmenu).

- Download the latest MAKEROM executable for your platform from [its GitHub releases](https://github.com/3DSGuy/Project_CTR/releases).

- Download the latest BANNERTOOL executable from [its GitHub releases](https://github.com/Steveice10/bannertool/releases).

- Use the `make cia` command to build your CIA file.


### Executing (and debugging) the 3DSX file in Citra
Citra is a Nintendo 3DS emulator. You should be able to debug your application
using that same tool.

- [Download their latest **Nightly** build](https://citra-emu.org/download/) and install it into a safe place (`C:\citra` or `/opt/citra` for example).

- Add `(YOUR CITRA INSTALLATION FOLDER)/nightly-mingw` to your PATH.

- Use the `make citra` command to build a 3DSX file and run it in Citra.


## Contributing
If you would like to add something to this template, you can
[fork it](https://github.com/everythintendo/3ds-hello-world/fork), edit what
you want to, and
[create a pull request](https://github.com/everythintendo/3ds-hello-world/pulls/new).

### Contributors
There are no other contributors for the moment. Why not [be the first one](#Contribute)?


## Troubleshooting
If you ever encounter an issue **with the base template** (we will not help you
debug your own application), you can
[open an issue](https://github.com/everythintendo/3ds-hello-world/issues/new)
if you need help setting up your base environment.


## Contacting us
You can reach us at [lambdagg@tuta.io](mailto:lambdagg@tuta.io). For the sake
of simpleness, please make your subject clear.
