# https://github.com/TricksterGuy/3ds-template/blob/master/Makefile

#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------

ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

TOPDIR ?= $(CURDIR)
include $(DEVKITARM)/3ds_rules

#---------------------------------------------------------------------------------
# TARGET is the name of the output
# BUILD is the directory where object files & intermediate files will be placed
# SOURCES is a list of directories containing source code
# DATA is a list of directories containing data files
# INCLUDES is a list of directories containing header files
# RESOURCES is a list of directories containing resources
# OUTPUT is the directory where final executables will be placed
# GRAPHICS is a list of directories containing graphics files
# GFXBUILD is the directory where converted graphics files will be placed
#   If set to $(BUILD), it will statically link in the converted
#   files as if they were data files.
#
# NO_SMDH: if set to anything, no SMDH file is generated.
# ROMFS is the directory which contains the RomFS, relative to the Makefile (Optional)
# APP_TITLE is the name of the app stored in the SMDH file (Optional)
# APP_DESCRIPTION is the description of the app stored in the SMDH file (Optional)
# APP_AUTHOR is the author of the app stored in the SMDH file (Optional)
# ICON is the filename of the icon (.png), relative to the project folder.
#   If not set, it attempts to use one of the following (in this order):
#     - <Project name>.png
#     - icon.png
#     - <libctru folder>/default_icon.png
#---------------------------------------------------------------------------------
TARGET		:= $(notdir $(CURDIR))
BUILD		:= obj
SOURCES     := src
DATA        := data
INCLUDES    := inc
GRAPHICS    := gfx
OUTPUT      := bin
RESOURCES   := res
ROMFS       := romfs
GFXBUILD    := $(BUILD) # $(ROMFS)/gfx
#---------------------------------------------------------------------------------
# Resource Setup
#---------------------------------------------------------------------------------
APP_INFO        := $(RESOURCES)/AppInfo
BANNER			:= $(RESOURCES)/banner
ICON            := $(RESOURCES)/icon.png
RSF             := $(TOPDIR)/$(RESOURCES)/app.rsf

#---------------------------------------------------------------------------------
# options for code generation
#---------------------------------------------------------------------------------
ARCH        := -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft
COMMON      := -Wall -O2 -mword-relocations -fomit-frame-pointer -ffunction-sections $(ARCH) $(INCLUDE) -DARM11 -D_3DS
CFLAGS      := $(COMMON) -std=gnu17
CXXFLAGS    := $(COMMON) -fno-rtti -fno-exceptions -std=gnu++20
ASFLAGS     := $(ARCH)
LDFLAGS     = -specs=3dsx.specs $(ARCH) -Wl,-Map,$(notdir $*.map)

#---------------------------------------------------------------------------------
# Libraries needed to link into the executable.
#---------------------------------------------------------------------------------
LIBS := -lcitro2d -lcitro3d -lctru -lm

#---------------------------------------------------------------------------------
# list of directories containing libraries, this must be the top level containing
# include and lib
#---------------------------------------------------------------------------------
LIBDIRS	:= $(PORTLIBS) $(CTRULIB)

#---------------------------------------------------------------------------------
# no real need to edit anything past this point unless you need to add additional
# rules for different file extensions
#---------------------------------------------------------------------------------
ifneq ($(BUILD),$(notdir $(CURDIR)))
#---------------------------------------------------------------------------------

export TOPDIR      := $(CURDIR)
export OUTPUT_DIR  := $(TOPDIR)/$(OUTPUT)
export OUTPUT_FILE := $(OUTPUT_DIR)/$(TARGET)
export VPATH       := $(foreach dir,$(SOURCES),$(CURDIR)/$(dir)) \
                      $(foreach dir,$(GRAPHICS),$(CURDIR)/$(dir)) \
                      $(foreach dir,$(DATA),$(CURDIR)/$(dir))

export DEPSDIR     := $(CURDIR)/$(BUILD)

CFILES             := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
CPPFILES           := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.cpp)))
SFILES             := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.s)))
PICAFILES          := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.v.pica)))
SHLISTFILES        := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.shlist)))
GFXFILES           := $(foreach dir,$(GRAPHICS),$(notdir $(wildcard $(dir)/*.t3s)))
BINFILES           := $(foreach dir,$(DATA),$(notdir $(wildcard $(dir)/*.*)))

#---------------------------------------------------------------------------------
# use CXX for linking C++ projects, CC for standard C
#---------------------------------------------------------------------------------
ifeq ($(strip $(CPPFILES)),)
	export LD := $(CC)
else
	export LD := $(CXX)
endif
#---------------------------------------------------------------------------------
export T3XFILES	      := $(GFXFILES:.t3s=.t3x)

export OFILES_SOURCES := $(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)
export OFILES_BIN     := $(addsuffix .o,$(BINFILES)) \
                         $(PICAFILES:.v.pica=.shbin.o) $(SHLISTFILES:.shlist=.shbin.o) \
                         $(if $(filter $(BUILD),$(GFXBUILD)),$(addsuffix .o,$(T3XFILES)))
export OFILES         := $(OFILES_BIN) $(OFILES_SOURCES)
export HFILES         := $(PICAFILES:.v.pica=_shbin.h) $(SHLISTFILES:.shlist=_shbin.h) \
                         $(addsuffix .h,$(subst .,_,$(BINFILES))) \
                         $(GFXFILES:.t3s=.h)
export INCLUDE        := $(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir)) \
                         $(foreach dir,$(LIBDIRS),-I$(dir)/include) \
                         -I$(CURDIR)/$(BUILD)

export LIBPATHS       := $(foreach dir,$(LIBDIRS),-L$(dir)/lib)

export _3DSXDEPS      := $(if $(NO_SMDH),,$(OUTPUT_FILE).smdh)

#---------------------------------------------------------------------------------
# Inclusion of RomFS folder, App Icon, and building SMDH
#---------------------------------------------------------------------------------

ifeq ($(strip $(ICON)),)
	icons := $(wildcard *.png)
	ifneq (,$(findstring $(TARGET).png,$(icons)))
		export APP_ICON := $(TOPDIR)/$(TARGET).png
	else
		ifneq (,$(findstring icon.png,$(icons)))
			export APP_ICON := $(TOPDIR)/icon.png
		endif
	endif
else
	export APP_ICON := $(TOPDIR)/$(ICON)
endif
ifeq ($(strip $(NO_SMDH)),)
	export _3DSXFLAGS += --smdh=$(OUTPUT_FILE).smdh
endif

ifneq ($(ROMFS),)
	export _3DSXFLAGS += --romfs=$(CURDIR)/$(ROMFS)
endif

#---------------------------------------------------------------------------------
# First set of targets ensure the build/output directories are created and execute
# in the context of the BUILD directory.
#---------------------------------------------------------------------------------
.PHONY : clean all bootstrap 3dsx cia elf 3ds citra release

all : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

3dsx : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

cia : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

3ds : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

elf : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

citra : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

release : bootstrap
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile $@

bootstrap :
	@[ -d $(BUILD) ] || mkdir -p $(BUILD)
	@[ -d $(OUTPUT_DIR) ] || mkdir -p $(OUTPUT_DIR)
	@[ -d $(GFXBUILD) ] || mkdir -p $(GFXBUILD)

clean :
	@echo clean ...
	@rm -rf $(BUILD) $(OUTPUT)

#---------------------------------------------------------------------------------
else

DEPENDS	:=	$(OFILES:.o=.d)

include $(TOPDIR)/$(APP_INFO)
APP_TITLE         := $(shell echo "$(APP_TITLE)" | cut -c1-128)
APP_DESCRIPTION   := $(shell echo "$(APP_DESCRIPTION)" | cut -c1-256)
APP_AUTHOR        := $(shell echo "$(APP_AUTHOR)" | cut -c1-128)
APP_PRODUCT_CODE  := $(shell echo $(APP_PRODUCT_CODE) | cut -c1-16)
APP_UNIQUE_ID     := $(shell echo $(APP_UNIQUE_ID) | cut -c1-7)
APP_VERSION_MAJOR := $(shell echo $(APP_VERSION_MAJOR) | cut -c1-3)
APP_VERSION_MINOR := $(shell echo $(APP_VERSION_MINOR) | cut -c1-3)
APP_VERSION_MICRO := $(shell echo $(APP_VERSION_MICRO) | cut -c1-3)
APP_ROMFS         := $(TOPDIR)/$(ROMFS)

BANNER_IMAGE = $(BANNER)_img
BANNER_AUDIO = $(BANNER)_snd

ifneq ("$(wildcard $(TOPDIR)/$(BANNER_IMAGE).cgfx)","")
	BANNER_IMAGE_FILE := $(TOPDIR)/$(BANNER_IMAGE).cgfx
	BANNER_IMAGE_ARG  := -ci $(BANNER_IMAGE_FILE)
else
	BANNER_IMAGE_FILE := $(TOPDIR)/$(BANNER_IMAGE).png
	BANNER_IMAGE_ARG  := -i $(BANNER_IMAGE_FILE)
endif

ifneq ("$(wildcard $(TOPDIR)/$(BANNER_AUDIO).cwav)","")
	BANNER_AUDIO_FILE := $(TOPDIR)/$(BANNER_AUDIO).cwav
	BANNER_AUDIO_ARG  := -ca $(BANNER_AUDIO_FILE)
else
	BANNER_AUDIO_FILE := $(TOPDIR)/$(BANNER_AUDIO).wav
	BANNER_AUDIO_ARG  := -a $(BANNER_AUDIO_FILE)
endif

COMMON_MAKEROM_PARAMS := -rsf $(RSF) -target t -exefslogo -elf $(OUTPUT_FILE).elf -icon icon.icn \
-banner banner.bnr -DAPP_TITLE="$(APP_TITLE)" -DAPP_PRODUCT_CODE="$(APP_PRODUCT_CODE)" \
-DAPP_UNIQUE_ID="$(APP_UNIQUE_ID)" -DAPP_ROMFS="$(APP_ROMFS)" -DAPP_SYSTEM_MODE="64MB" \
-DAPP_SYSTEM_MODE_EXT="Legacy" -major "$(APP_VERSION_MAJOR)" -minor "$(APP_VERSION_MINOR)" \
-micro "$(APP_VERSION_MICRO)"

ifeq ($(OS),Windows_NT)
# External tools:
	MAKEROM = makerom.exe
	BANNERTOOL = bannertool.exe
	CITRA = citra.exe
# Tools already included in devkitPro:
	_3DSXTOOL = 3dsxtool.exe
	SMDHTOOL = smdhtool.exe
	TEX3DS = tex3ds.exe
else
# External tools:
	MAKEROM = makerom
	BANNERTOOL = bannertool
	CITRA = citra
# Tools already included in devkitPro:
	_3DSXTOOL = 3dsxtool
	SMDHTOOL = smdhtool
	TEX3DS = tex3ds
endif

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
.PHONY: all 3dsx cia elf 3ds citra release

$(OUTPUT_FILE).3dsx : $(OUTPUT_FILE).elf $(_3DSXDEPS)
	$(_3DSXTOOL) $< $@ $(_3DSXFLAGS)
	@echo built 3dsx: $(notdir $@)
	@echo

$(OUTPUT_FILE).smdh : $(APP_ICON)
	@$(SMDHTOOL) --create "$(APP_TITLE)" "$(APP_DESCRIPTION)" "$(APP_AUTHOR)" $(APP_ICON) $@
	@echo built smdh: $(notdir $@)
	@echo

$(OFILES_SOURCES) : $(HFILES)

$(OUTPUT_FILE).elf : $(OFILES)

$(OUTPUT_FILE).3ds : $(OUTPUT_FILE).elf banner.bnr icon.icn
	@$(MAKEROM) -f cci -o $(OUTPUT_FILE).3ds -DAPP_ENCRYPTED=true $(COMMON_MAKEROM_PARAMS)
	@echo "built 3ds: $(notdir $@)"
	@echo

$(OUTPUT_FILE).cia : $(OUTPUT_FILE).elf banner.bnr icon.icn
	@$(MAKEROM) -f cia -o $(OUTPUT_FILE).cia -DAPP_ENCRYPTED=false $(COMMON_MAKEROM_PARAMS)
	@echo "built cia: $(notdir $@)"
	@echo

$(OUTPUT_FILE).zip : $(OUTPUT_FILE).smdh $(OUTPUT_FILE).3dsx
	cd $(OUTPUT_DIR)
	@mkdir -p 3ds
	@cp $(OUTPUT_FILE).3dsx 3ds
	@cp $(OUTPUT_FILE).smdh 3ds
	7z a -r $(OUTPUT_FILE).zip 3ds > /dev/null
	@rm -r 3ds
	@echo zipped: $(notdir $@)
	@echo

banner.bnr : $(BANNER_IMAGE_FILE) $(BANNER_AUDIO_FILE)
	@$(BANNERTOOL) makebanner $(BANNER_IMAGE_ARG) $(BANNER_AUDIO_ARG) -o banner.bnr > /dev/null
	@echo built banner: $(notdir $@)
	@echo

icon.icn : $(APP_ICON)
	@$(BANNERTOOL) makesmdh -s "$(APP_TITLE)" -l "$(APP_TITLE)" -p "$(APP_AUTHOR)" -i $(APP_ICON) -o icon.icn > /dev/null
	@echo built icon: $(notdir $@)
	@echo

3dsx : $(OUTPUT_FILE).3dsx

cia : $(OUTPUT_FILE).cia

3ds : $(OUTPUT_FILE).3ds

elf : $(OUTPUT_FILE).elf

citra : 3dsx
	$(CITRA) $(OUTPUT_FILE).3dsx
	@echo

release : $(OUTPUT_FILE).zip cia 3ds

#---------------------------------------------------------------------------------
# Binary Data Rules
#---------------------------------------------------------------------------------
%.bin.o	%_bin.h : %.bin
#---------------------------------------------------------------------------------
	@echo $(notdir $<)
	@$(bin2o)
#---------------------------------------------------------------------------------
.PRECIOUS : %.t3x
%.t3x.o	%_t3x.h : %.t3x
#---------------------------------------------------------------------------------
	@$(bin2o)

#---------------------------------------------------------------------------------
# rules for assembling GPU shaders
#---------------------------------------------------------------------------------
define shader-as
	$(eval CURBIN := $*.shbin)
	$(eval DEPSFILE := $(DEPSDIR)/$*.shbin.d)
	echo "$(CURBIN).o: $< $1" > $(DEPSFILE)
	echo "extern const u8" `(echo $(CURBIN) | sed -e 's/^\([0-9]\)/_\1/' | tr . _)`"_end[];" > `(echo $(CURBIN) | tr . _)`.h
	echo "extern const u8" `(echo $(CURBIN) | sed -e 's/^\([0-9]\)/_\1/' | tr . _)`"[];" >> `(echo $(CURBIN) | tr . _)`.h
	echo "extern const u32" `(echo $(CURBIN) | sed -e 's/^\([0-9]\)/_\1/' | tr . _)`_size";" >> `(echo $(CURBIN) | tr . _)`.h
	picasso -o $(CURBIN) $1
	bin2s $(CURBIN) | $(AS) -o $*.shbin.o
endef

%.shbin.o %_shbin.h : %.v.pica %.g.pica
	@echo $(notdir $^)
	@$(call shader-as,$^)

%.shbin.o %_shbin.h : %.v.pica
	@echo $(notdir $<)
	@$(call shader-as,$<)

%.shbin.o %_shbin.h : %.shlist
	@echo $(notdir $<)
	@$(call shader-as,$(foreach file,$(shell cat $<),$(dir $<)$(file)))

#---------------------------------------------------------------------------------
%.t3x %.h :  %.t3s
#---------------------------------------------------------------------------------
	@echo $(notdir $<)
	@$(TEX3DS) -i $< -H $*.h -d $*.d -o $(TOPDIR)/$(GFXBUILD)/$*.t3x

-include $(DEPSDIR)/*.d

#---------------------------------------------------------------------------------------
endif
#---------------------------------------------------------------------------------------
