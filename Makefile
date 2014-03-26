# If AutoFind is not the empty string, EasyMake searches for source
# files with known extensions by itself.
AutoFind:=true
# Needed to define Linkerflags.
Comma=,
# To quote spaces, e.g. from $(addprefix )
Space:= 
Space+=
# To ensure that we use bash's builtin echo.
SHELL=/bin/bash
################
# GMSL macros. #
################
# Function:  tr
# Arguments: 1: The list of characters to translate from
#            2: The list of characters to translate to
#            3: The text to translate
# Returns:   Returns the text after translating characters
##########################################################
tr=$(strip $(eval __gmsl_t := $3)\
   $(foreach c,$(join $(addsuffix :,$1),$2),\
       $(eval __gmsl_t:=                                               \
           $(subst $(word 1,$(subst :, ,$c)),$(word 2,$(subst :, ,$c)), \
               $(__gmsl_t)))\
   )$(__gmsl_t))
# Common character classes for use with the tr function.  Each of
# these is actually a variable declaration and must be wrapped with
# $() or ${} to be used.
[A-Z] := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z #
[a-z] := a b c d e f g h i j k l m n o p q r s t u v w x y z #
# Function:  uc
# Arguments: 1: Text to upper case
# Returns:   Returns the text in upper case
###########################################
uc = $(call tr,$([a-z]),$([A-Z]),$1)
# Finds files in a smart way: It omits any directories that contain
# a Makefile themselves, thus ensuring that both directories containing
# prerequisites and directories containing derived files are ommitted.
# Parameters: extension directory
define Find
    $(eval _Find1=$(filter-out $2,$(shell find $(2) -name Makefile -exec dirname {} \;)))
    $(eval _Find2=$(shell find $(2) -type f -name "$1"))
    $(basename $(filter-out $(addsuffix %,$(_Find1)),$(_Find2)))
endef
# Switch off any implicit rules.
.SUFFIXES:
# Paranoia, just in case if this was set in the environment.
SourceDirectory:=
# The if-branch is evaluated when Make is called in the source
# directory ...
ifeq (,$(SourceDirectory))
    .PHONY: all
    all: _all ;
    # Prevent make from remaking Makefile or any .mk files
    # through the "match anything" rule above.
    Makefile : ;
    %.mk :: ;
    SourceDirectory:=$(CURDIR)
    # Default directory for all derived (i.e. generated) files.
    DerivedDirectory=../derived
    # The default prerequisites to be build before running this build.
    # This must be a list of directories that themselves contain
    # (EasyMake) Makefiles.
    Prerequisites=
    # No prerequisites for objects by default.
    ObjectPrerequisites=
    # This is needed for both initialization and check of the
    # platforms.
    _Platforms:=$(patsubst %.mk,%,$(filter-out User.mk,$(wildcard *.mk)))
    # The default platforms to be built.
    Platforms=$(_Platforms)
    # Reset variables from the environment. This is needed
    # in prerequisites, if the parent Make has e.g. defined new
    # source extensions.
    $(foreach _j,$(filter Linker% Compiler% Sources%\
                          LDFLAGS LINKERFLAGS LIBRARIES LIBDIRS\
                          CFLAGS CXXFLAGS DEFINES INCLUDES,\
                          $(.VARIABLES)\
                 ),\
        $(eval export $(_j)=)\
    )
    # Default tools.
    export AR=ar
    export ARFLAGS=-rcs
    export CC=gcc
    export CXX=g++
    # Default extension for object files.
    export ObjectExtension=.o
    # The default values for Targets, Compiler and Sources ...
    export Targets=$(if $(notdir $(CURDIR)),$(notdir $(CURDIR)),root)
    # Default compilers.
    Compiler.sx=$(CC) -MD -c $(AFLAGS) $(addprefix -D,$(DEFINES)) $(addprefix -I,$(INCLUDES)) -o $$@ $$<
    Compiler.c=$(CC) -MD -c $(CFLAGS) $(addprefix -D,$(DEFINES)) $(addprefix -I,$(INCLUDES)) -o $$@ $$<
    Compiler.cc=$(CXX) -MD -c $(CXXFLAGS) $(addprefix -D,$(DEFINES)) $(addprefix -I,$(INCLUDES)) -o $$@ $$<
    Compiler.cpp=$(CXX) -MD -c $(CXXFLAGS) $(addprefix -D,$(DEFINES)) $(addprefix -I,$(INCLUDES)) -o $$@ $$<
    # Default linkers.
    Linker=$(CXX) $(LDFLAGS)\
                  $(addprefix -Wl$(COMMA),$(LINKERFLAGS))\
                  $(addprefix -l,$(LIBRARIES))\
                  $(addprefix -L,$(LIBDIRS))\
                  -o $$@ $$^
    Linker.so=$(CXX) -shared\
                     -fPIC\
                     $(LDFLAGS)\
                     $(addprefix -Wl$(COMMA),$(LINKERFLAGS))\
                     $(addprefix -l,$(LIBRARIES))\
                     $(addprefix -L,$(LIBDIRS))\
                     -o $$@ $$^
    Linker.dll=$(CXX) -shared\
                      -fPIC\
                      $(LDFLAGS)\
                      $(addprefix -Wl$(COMMA),$(LINKERFLAGS))\
                      $(addprefix -l,$(LIBRARIES))\
                      $(addprefix -L,$(LIBDIRS))\
                      -o $$@ $$^
    Linker.a=$(AR) $(ARFLAGS) $$@ $$^
    # The default is all source files.
    $(if $(AutoFind),\
         $(foreach _j,\
                   *.sx *.c *.cc *.cpp,\
                   $(eval Sources$(subst *,,$(_j))=$(strip $(call Find,$(_j),$(SourceDirectory))))\
         )\
    )
    # Save variables using two underscores.
    $(foreach _j,$(filter ObjectExtension Targets Linker% Compiler% Sources% ObjectPrerequisites,\
                          $(.VARIABLES)\
                 ),\
        $(eval export __$(_j)=$(subst $$,$$$$$$$$,$($(_j))))\
    )
    # ... and may then be modified.
    -include User.mk
    # As platforms may have been changed in User.mk, we
    # check if it still contains valid platforms only.
    _InvalidPlatforms:=\
        $(filter-out $(_Platforms),\
                     $(Platforms)\
        )
    $(if $(_InvalidPlatforms),\
        $(error Invalid platform(s):\
                $(_InvalidPlatforms)\
        )\
    )
    # At least one platform must be in the list of platforms
    # if platform .mk files exist.
    $(if $(_Platforms),\
        $(if $(Platforms),\
        ,\
             $(error At least one valid platform must be listed\
                     if platform .mk files exist)\
        )\
    )
    OnceGoals:=distclean help quick manual example todo license
    # Match (almost) anything rule. Ensures that the submake is run for _any target.
    $(foreach _i,$(Platforms),$(eval $(_i)/% :: all ; ))
    ifeq (,$(filter-out 0 1,$(words $(Platforms)))$x)
        # Initial variable setup.
        define _PlatformVariableSetup
            $(foreach _l,$(patsubst Targets%,%,$(filter Targets%,$(.VARIABLES))),\
                $(eval Targets+=$(addsuffix $(_l),$(Targets$(_l))))\
            )
            # Check if Targets still contains something.
            $(if $(filter 0,$(words $(Targets))),\
                $(error At least one target must be defined.)\
            )
            # Pass platform specific targets, compiler and sources to sub-Make
            # by exporting their related platform-specific counterparts (same
            # name, but prepended with an underscore and the platform's name).
            $(foreach _j,$(filter Targets ObjectExtension Linker% Compiler% Sources% ObjectPrerequisites,\
                                  $(.VARIABLES)\
                         ),\
                $(eval export _$1$(_j)=$(subst $$,$$$$$$$$,$($(_j))))\
            )
        endef
        # Set platform specific defaults and variables.
        _Targets.save:=$(Targets)
        $(if $(Platforms),\
            $(foreach _i,$(Platforms),\
                $(eval include $(_i).mk)\
                $(eval Targets:=$(_Targets.save))\
                $(eval $(call _PlatformVariableSetup,$(_i)))\
            )\
        ,\
            $(eval $(call _PlatformVariableSetup))\
        )
        $(foreach _j,$(filter Compiler% Linker% Sources%,$(.VARIABLES)),\
            $(eval export $(_j))\
        )
        # The usual default Goal.
        .PHONY: _all
        # We depend on the derived directory to exist, so we define it as
        # an order-only dependency.
        # The Makefile dependency takes care that source files are not found
        # twice by the default find and that the derived directory is created.
        _all: $(DerivedDirectory)/Makefile
	    @# We build for all platforms of the sub-Make, regardless of
	    @# the parent platform. This makes sense as the sub-Make platforms
	    @# may be different from the related parent pltatforms, e.g.
	    @# because the sub-Make platform is common to all parent
	    @# platforms. Being seen from this view, it is also no real
	    @# restriction that Prerequisites cannot be set per
	    @# platform.
	    @for _i in $(Prerequisites); do\
	        echo -e "\E[1mMaking prerequisite \"$$_i\":\E[0m";\
	        if ! $(MAKE) -C $$_i\
	                     --no-print-dir\
	                     $(MAKECMDGOALS); then\
	            exit 1;\
	        fi;\
	    done;
	    @# Likewise, the derived directory can only be set
	    @# globally, i.e. not per platform. Each platform's
	    @# derived files will be stored in a subdirectory of
	    @# DerivedDirectory that has the platform's
	    @# name. Similarly, this is no real restriction, as
	    @# arbitrary directories per platform would only cause
	    @# more confusion than enhanced flexibility.
	    @# It may be interesting to note that setting
	    @# derived directory to the empty string
	    @# causes EasyMake to do nothing but building its
	    @# prerequisites. This may be useful to use EasyMake
	    @# to just "call" several sub-(EasyMake) Makefiles.
	    @if [ -n "$(DerivedDirectory)" ]; then\
	        for _i in $(Platforms) ""; do\
	            if [ "$$_i" = "" -a\
	                 "$(_Platforms)" != ""\
	               ]; then\
	                break;\
	            fi;\
	            if [ "$(MAKELEVEL)" = "0" ]; then\
	                echo -e "\E[1mMaking toplevel build:\E[0m";\
	            fi;\
	            echo -e "\E[4mMaking platform \"$$_i\":\E[0m";\
	            if ! $(MAKE) --no-print-dir\
	                         -C $(DerivedDirectory)\
	                         -f $(CURDIR)/Makefile\
	                         SourceDirectory=$(SourceDirectory)\
	                         Platform=$$_i\
	                         $(addprefix --include-dir=,$(abspath $(sort $(dir $(MAKEFILE_LIST)))))\
	                         $(MAKECMDGOALS); then\
	                exit 1;\
	            fi;\
	        done;\
	    fi
        # The rule to create the derived directory if needed.
        ifneq (,$(DerivedDirectory))
            $(DerivedDirectory)/Makefile: Makefile | $(DerivedDirectory)
	        @echo '.PHONY: all $$(MAKECMDGOALS)' > $@
	        @echo -n '$$(if $$(MAKECMDGOALS),$$(MAKECMDGOALS),all): ;' >> $@
	        @echo -n '@$$(MAKE) -C $(CURDIR) --no-print-dir' >> $@
	        @echo ' $$(MAKECMDGOALS)' >> $@
            $(DerivedDirectory): ; @+mkdir -p $@
        else
            $(DerivedDirectory)/Makefile: ;
        endif
        # The usual clean Goal.
        .PHONY: clean
        # Warning, cleanup is rigorous: It mercyless deletes
        # the derived directory including its content!
        clean:
	    @# Similar to making prerequisites, we alwas delete
	    @# all prerequisites for all (sub-Make) platforms.
	    @for _i in $(Prerequisites); do\
	        _Temp="";\
	        for _j in $$_i/*.mk; do\
	            if [ "$$_j" != "$$_i/User.mk" -a\
	                 "$$_j" != "$$_i/*.mk"\
	               ]; then\
	                _Temp="$$_Temp `basename $$_j .mk`";\
	            fi;\
	        done;\
	        echo -n "cd $$_i; ";\
	        $(MAKE) -C $$_i\
	                --no-print-dir\
	                Platforms="$$_Temp"\
	                $(MAKECMDGOALS);\
	    done;
	    @# If only a subset of platforms is given, we only
	    @# delete those, i.e. not touching the others.
	    @#$(if $(filter-out $(Platforms),$(_Platforms)),\
	    @#    rm -rf $(addprefix $(DerivedDirectory)/,$(Platforms))\
	    @#,\
	    @#    rm -rf $(DerivedDirectory)\
	    @#)
	    $(if $(Platforms),\
                 $(foreach _i,\
                           $(Platforms),\
	                   rm -rf $(addprefix $(DerivedDirectory)/,$(_i));\
                 )\
            ,\
                 rm -rf $(DerivedDirectory)\
	    )
        $(foreach i,$(OnceGoals),$(eval .PHONY: $i)) 
        $(foreach i,$(OnceGoals),$(eval $i: ; @$(MAKE) --no-print-dir x=true $i)) 
    else
        _MAKECMDGOALS:=$(filter-out $(OnceGoals),$(MAKECMDGOALS))
        .PHONY: _all $(_MAKECMDGOALS)
        $(eval $(if $(_MAKECMDGOALS),\
                   $(_MAKECMDGOALS)\
               ,\
                   _all\
               ): ; @$(foreach i,$(Platforms),$(MAKE) --no-print-dir Platforms=$i $(_MAKECMDGOALS) &&) true\
        )
        .PHONY: distclean
        distclean:
	    @# Similar to making prerequisites, we alwas delete
	    @# all prerequisites for all (sub-Make) platforms.
	    @for _i in $(Prerequisites); do\
	        _Temp="";\
	        for _j in $$_i/*.mk; do\
	            if [ "$$_j" != "$$_i/User.mk" -a\
	                 "$$_j" != "$$_i/*.mk"\
	               ]; then\
	                _Temp="$$_Temp `basename $$_j .mk`";\
	            fi;\
	        done;\
	        echo -n "cd $$_i; ";\
	        $(MAKE) -C $$_i\
	                --no-print-dir\
	                Platforms="$$_Temp"\
	                $(MAKECMDGOALS);\
	    done;
	    rm -rf $(DerivedDirectory)
        # EasyMake Documentation.
        .PHONY: help
        help:
	    @echo -e "                           \E[1m\E[4mOverview\E[0m\n"\
	             "This is EasyMake, a fully configurable multi-architecture and\n"\
	             "multi-target Makefile that automatically respects dependencies.\n"\
	             "\n"\
	             "The core idea behind EasyMake is to make its usage as simple as\n"\
	             "possible to build for typical scenarios, while still allowing to\n"\
	             "configure any detail to accomondate for more complex and / or more\n"\
	             "specific demands, again in the most easy and straight forward way.\n"\
	             "This may be achieved without ever needing to change the EasyMake\n"\
	             "Makefile, as any configuration is done in an optional global\n"\
                     "User.mk file and platform specific <platform>.mk-files.\n"\
	             "\n"\
	             "Furthermore, the entire EasyMake distribution consists of just one\n"\
	             "file: The Makefile itself. Besides its core functionality (i.e. to\n"\
	             "build a project), it comprises its own and rather comprehensive\n"\
	             "documentation, including a manual and a example project.\n"\
	             "\n"\
	             "Here is a list of EasyMake's buildtin help Goals apart from\n"\
	             "the Goal \"help\" that you have just used to print this text:\n"\
	             "\n"\
	             "\E[2mquick\E[0m:    Prints EasyMake's quick start guide.\n"\
	             "\E[2mmanual\E[0m:   Prints the EasyMake manual.\E[0m\n"\
	             "\E[2mexample\E[0m: Creates a small example project in the current\n"\
	             "          directory that documents itself in its .mk files.\n"\
	             "\E[2mtodo\E[0m:     Prints a list of possible improvements to"\
	             "EasyMake.\E[0m\n"\
	             "\E[2mlicense\E[0m:  Prints EasyMake's license terms, contact\n"\
	             "          information and credits.\E[0m" | less -R
        .PHONY: quick
        quick:
	    @echo -e "                           \E[1m\E[4mQuickstart\E[0m\n"\
	             "First of all please note that this quickstart guide can only describe a\n"\
	             "very small and rather specific set of EasyMake's capabilities. Most\n"\
	             "notably, the defaults being chosen by EasyMake (which is what's described\n"\
	             "here) are geared towards the build procedures that are usually needed\n"\
	             "for a common software development process. But EasyMake is flexible enough\n"\
	             "to cater almost any type of build procedure. Thus, the inclined reader\n"\
	             "is kindly asked to refer to the EasyMake manual to understand EasyMake's\n"\
	             "full feature set. You may however read on here for now to get a smooth start.\n"\
	             "\n"\
	             "In some rather common cases, EasyMake may be ready to build your project\n"\
	             "right away without any need for configuration: Everything that is needed\n"\
	             "under such conditions is having GNU Make properly installed on your system\n"\
	             "and  a copy of EasyMake's Makefile in the root directory of your project.\n"\
	             "Building the project is then just a matter of calling Make from the\n"\
	             "project's root directory.\n"\
	             "\n"\
	             "That may sound a bit too easy, or even simple-minded, as it immediately poses\n"\
	             "the question what EasyMake is going to build from, and where it puts the\n"\
	             "resulting target(s) from that build.\n"\
	             "\n"\
	             "Ok, let's see which defaults would make most sense here: As EasyMake\n"\
	             "has not been told any specific instructions on which target(s) are to be\n"\
	             "build from which sources, it just assumes that it needs to build one\n"\
	             "target that has the name of the project's root directory. To build that\n"\
	             "target, it translates all files in and below the project's root directory\n"\
	             "with \"known extensions\" (I will explain what this means in a\n"\
	             "minute) with the translator related to these files' extensions and binds\n"\
	             "the resulting translation results into the common target. Both the target\n"\
	             "and the intermediate files are stored in the directory \"../derived\"\n"\
	             "relative to the project's root directory.\n"\
	             "\n"\
	             "Having read the description so far probably induces the next questions: What\n"\
	             "is meant by \"known extensions\", \"translating\" and \"binding\"?\n"\
	             "\n"\
	             "The most general (but at that point in time admittedly not very illuminating)\n"\
	             "answer to these questions: This is up to the user's configuration. But as\n"\
	             "this is the quick start guide and we therefore want to stick to a project\n"\
	             "that doen't need a specific EasyMake configuration, we will look again at the\n"\
	             "defaults provided by EasyMake.\n"\
	             "\n"\
	             "Beginning with the \"known extensions\", EasyMake's default is \".c\n"\
	             ".cc .cpp\". A dedicated default tanslator is defined for each of the \"known\n"\
	             "extensions\". Here they are:\n"\
	             "\n"\
	             "- \"cc -MD -c -o\" for all \".c\"-files\n"\
	             "- \"g++ -MD -c -o\" for all \".cc\"- and \"cpp\"-files\n"\
	             "\n"\
	             "You may have noticed the -MD switch: It tells the compiler to create properly\n"\
	             "formatted dependency lists which EasyMake reads to know the header files that\n"\
	             "each source file depends on. EasyMake allows to plug in your own dependency\n"\
	             "generation tool if you need to use a compiler does not offer this capability,\n"\
	             "but it is left to the manual to describe how to do this.\n"\
	             "\n"\
	             "Finally, we need to have a look at EasyMake's default for binding: As the\n"\
	             "list of files that are to be bound to form the target may consist of both C\n"\
	             "and C++ files and the g++ frontend of the gcc compiler collection is capable of\n"\
	             "binding objects for both types of these languages, EasyMake chooses g++ as the\n"\
	             "default binder to either build an executable or a shared library. Furthermore,\n"\
	             "EasyMake's default to bind statically linked libraries is the archiver ar.\n"\
	             "\n"\
	             "By default, EasyMake determines which of these default binders to be\n"\
	             "employed to create the target from the target's name (which in turn is, as\n"\
	             "you may remember, by default the name of the project's root directory).\n"\
	             "Thus, EasyMake's binder defaults to:\n"\
	             "\n"\
	             "- \"g++ -shared -fPIC -o\" if the target name ends with \".so\" \n"\
	             "- \"ar -rc\" if the target name ends with \".a\"\n"\
	             "- \"g++ -o\" for any other target names\n"\
	             "\n"\
	             "To sum up, the defaults being used by EasyMake are rather C / C++ centric:\n"\
	             "It translates all .c, .cc and .cpp files in and below the project's root\n"\
	             "directory using the appropriate (C or C++) compiler. Then it binds the\n"\
	             "resulting object files to either create a static library, a shared library or\n"\
	             "an executable depending on the target's extension (.a, .so or anything else).\n"\
	             "As the default target name is the same as the name of the project's root\n"\
	             "directory when no configuration is present, its extension controls the type\n"\
	             "of target (static library, shared library or executable) being built."\
	             "\E[0m" | less -R
        .PHONY: manual
        manual:
	    @echo -e "                           \E[1m\E[4mManual\E[0m\n"\
	             "Before starting to read the EasyMake manual, you may want to look at\n"\
	             "the EasyMake quickstart guide to understand the basics w.r.t. EasyMake's\n"\
	             "default behaviour. Futhermore, the example project (which may easily\n"\
	             "be created in an empty directory by calling Make with the Goal \"example\"\n"\
	             "(i.e. calling \"make example\") may give you more detailed information and hands\n"\
	             "on guidance beyond the scope of this manual. The best way to work through the\n"\
	             "manual would be to create the example project and try things out right away as\n"\
	             "you read about them here.\n"\
	             "\n"\
	             "While the quickstart guide had its focus on EasyMake's defaults and its\n"\
	                 "behaviour without any configuration, the manual covers EasyMake's ability\n"\
	             "to be configured to almost any build requirements possible. But this does\n"\
	             "not mean that we may completely abandon the default topic here. This is\n"\
	             "because EasyMake's configuration facilities are organized in a hierarchy:\n"\
	             "Inferiour hierachy elements inherit their defaults from superiour hierarchy\n"\
	             "elements. We will soon see what that exactly means. For now, let's just\n"\
	             "start with the most basic configuration options.\n"\
	             "\n"\
	             "The core EasyMake configuration may be done in the file \"User.mk\", which\n"\
	             "must reside in the same directory as the EasyMake Makefile, i.e. in the\n"\
	             "project's root directory. As this file is read by the EasyMake Makefile\n"\
	             "if it is present, it must contain valid Gnu Make syntax. But there is\n"\
	             "no need to know much about Gnu Make syntax, as almost all configuration\n"\
	             "may be done by merely setting EasyMake variables to values that differ\n"\
	             "from their initial defaults.\n"\
	             "\n"\
	             "As a supplement to defining variables in User.mk, one may pass variables\n"\
	             "on the command line when calling Make. As these command line definitions\n"\
	             "superseed the definitions in the configuration files, this allows to\n"\
	             "(temporarily) change EasyMake's configuration for the current invocation.\n"\
	             "\n"\
	             "\E[1m1) EasyMake variables on hierarchy level 0\E[0m\n"\
	             "We start from the top most hierarchy levels, as any upper hierarchy level\n"\
	             "controls the defaults of the variables on the inferiour hierarchy levels.\n"\
	             "Hierarchy level 0 is a virtual hierarchy level that any EasyMake variable\n"\
	             "belongs to as long as it has not been changed from its initial default value.\n"\
	             "\n"\
	             "\E[1m1) EasyMake variables on hierarchy level 1\E[0m\n"\
	             "The variables on hierarcy level 1 may only be used in the User.mk file, i.e.\n"\
	             "they may not be used in any of the platform .mk files.\n"\
	             "\n"\
	             "\E[4mDerivedDirectory\E[0m:\n"\
	             "You may set this variable to any absolute or relative path (relative to the\n"\
	             "project's root directory) where all the derived objects from a build are\n"\
	             "going to be stored. If the given directory does not yet exist, EasyMake\n"\
	             "creates it during its first build.\n"\
	             "\E[2m\E[4mDefault\E[0m:\n"\
	             "The default for \"DerivedDirectory\" is ../derived.\n"\
	             "\E[2m\E[4mExamples\E[0m:\n"\
	             "DerivedDirectory:=objects # put all derived objects into the \"objetcts\"\n"\
	             "                          # subdirectory of the project's root directory\n"\
	             "\E[2m\E[4mNotes\E[0m:\n"\
	             "Danger: You should select this directory very careful, making sure that\n"\
	             "it doesn't yet exist or that it does at least not contain any valuable\n"\
	             "content, as a \"make clean\" will mercyless delete this directory with an\n"\
	             "rm -rf \$$(DerivedDirectory) without further inquiry.\n"\
	             "\n"\
	             "\E[4mPrerequisites\E[0m:\n"\
	             "This variable may be set to a (space separated) list of absolute or\n"\
	             "relative paths (relative to the project's root directory) that themselves\n"\
	             "contain an (EasyMake) Makefile. EasyMake will build any of these subprojects\n"\
	             "before starting to build the current project.\n"\
	             "\E[2m\E[4mDefault\E[0m:\n"\
	             "The default for \"Prerequisites\" is the empty string.\n"\
	             "\E[2m\E[4mExamples\E[0m:\n"\
	             "Prerequisites:=subProject ../otherProject # run Make with the current Goals\n"\
	             "                                          # in these directories first\n"\
	             "\E[2m\E[4mNotes\E[0m:\n"\
	             "Any Make Goals that have been passed to Make will also be passed to the Makes\n"\
	             "that are being referred to by the Prerequisites variable. Furthermore, this\n"\
	             "applies to Make variables and command line switches according to the Gnu Make\n"\
	             "manual (see http://www.gnu.org/software/make/manual/make.html#Recursion).\n"\
	             "\n"\
	             "\E[4mPlatforms\E[0m:\n"\
	             "Setting this variable allows to build for more than one target platform. It\n"\
	             "may comprise a list of user defined platform names, separated by spaces. For\n"\
	             "each of these names, EasyMake expects to find a .mk file in the project's\n"\
	             "root directory that may contain any platform specific configuration. EasyMake\n"\
	             "reports an error if no .mk file is found for a given platform name.\n"\
	             "  To separate the targets and intermediate files belonging to different\n"\
	             "platforms, EasyMake creates a subdirectory below \$$(DerivedDirectory) for\n"\
	             "each platform having the platform's name. The targets and the intermediate\n"\
	             "files are then put under that subdirectory.\n" \
	             "\E[2m\E[4mDefault\E[0m:\n"\
	             "The default for \"Platforms\" is the empty string.\n"\
	             "\E[2m\E[4mExamples\E[0m:\n"\
	             "Platforms:=linux-i386 linux-mipsel solaris-sparc\n"\
	             "\E[2m\E[4mNotes\E[0m:\n"\
	             "None of the EasyMake variables described so far are allowed to be defined in\n"\
	             "a platform .mk file.\n"\
	             "\n"\
	             "\E[1m2) EasyMake variables on hierarchy level 2\E[0m\n"\
	             "Any of the variables described in the following sections may be located\n"\
	             "in either the User.mk file or any of the platform .mk files, depending on\n"\
	             "whether their scope shall be applied globally to all platforms or just to\n"\
	             "a selected platfoms only.\n"\
	             "\n"\
	             "\E[4mTargets\E[0m:\n"\
	             "This variable allows to tell EasyMake to build more than one target for either\n"\
	             "all (if defined in User.mk) or a specific (if defined in a platform .mk file)\n"\
	             "platform(s). You will see step by step while reading the descriptions of the\n"\
	             "following variables how different build conditions may be defined for each\n"\
	             "of these targets.\n"\
	             "\E[2m\E[4mDefault\E[0m:\n"\
	             "The default for \$$(Targets) is the curret directory or \"root\" if the\n"\
	             "current directory happens to be the root directory.\n"\
	             "\E[2m\E[4mExamples\E[0m:\n"\
	             "Targets:=myStaticLibrary.a mySharedLibrary.so myExecutable anotherExecutable\n"\
	             "# A more complex example may exploit the fact that the target is set\n"\
	             "# to the project's root directory by default already. Assuming that this\n"\
	             "# directory does neither have the extension \".so\" nor \".a\", EasyMake\n"\
	             "# would build an executable by default. If you now want EasyMake to build\n"\
	             "# a static library and a shared library in addition to that executable,\n"\
	             "# you may want to set \$$(Targets) as follows (note the += instead of the :=\n"\
	             "# to not overwrite EasyMake's default):\n"\
	             "Targets+=\$$(Targets).so \$$(Targets).a\n"\
	             "\E[2m\E[4mNotes\E[0m:\n"\
	             "None."\
	             "\n\n"\
	             "\E[4mCompiler*\E[0m:\n"\
	             "This set of variables allows to both change the translators for the \"known\n"\
	             "extensions\" (\"Compiler.c\", \"Compiler.cc\" and \"Compiler.cpp\") as\n"\
	             "well as to define new translators. As long as the names of these new\n"\
	             "translators start with \"Compiler\", they may have any name made up of letters,\n"\
	             "numbers, underscores and dots. Please refer to the \"Souces*\" section to\n"\
	             "see how newly defined translators may be used.\n"\
	             "\E[2m\E[4mDefaults\E[0m:\n"\
	             "While the defaults of translator variables for any \"unknown extensions\"\n"\
	             "is the empty string, the translator variables for the \"known extensions\"\n"\
	             "have the following values:\n"\
	             "Compiler.c:=\$$\$$(CC) -MD -c \$$\$$(CFLAGS) \$$\$$(addprefix -D,\$$\$$(DEFINES))\\\\\n"\
	             "                   \$$\$$(addprefix -I,\$$\$$(INCLUDES)) -o \$$\$$@ \$$\$$<\n"\
	             "Compiler.cc:=\$$\$$(CXX) -MD -c \$$\$$(CXXFLAGS) \$$\$$(addprefix -D,\$$\$$(DEFINES))\\\\\n"\
	             "                     \$$\$$(addprefix -I,\$$\$$(INCLUDES)) -o \$$\$$@ \$$\$$<\n"\
	             "Compiler.cpp:=\$$\$$(CXX) -MD -c \$$\$$(CXXFLAGS) \$$\$$(addprefix -D,\$$\$$(DEFINES))\\\\\n"\
	             "                      \$$\$$(addprefix -I,\$$\$$(INCLUDES)) -o \$$\$$@ \$$\$$<\n"\
	             "As you may have noticed, I did not tell the entire truth w.r.t. these\n"\
	             "variables in the quick start guide. The real defaults allow to also change\n"\
	             "only parts of the translators' command lines by setting the related variables,\n"\
	             "\"CC\", \"CXX\", \"CFLAGS\", \"CXXFLAGS\", \"DEFINES\", \"INCLUDES\"). With the\n"\
	             "exception of \"CC\" and \"CXX\", which are set to the default values \"gcc\" and\n"\
	             "\"g++\" respectively, the default value of the other variables is the empty\n"\
	             "string.\n"\
	             "\E[2m\E[4mExamples\E[0m:\n"\
	             "# This is an example on how to use a preprocessor to generate proper\n"\
	             "# dependencies for a compiler that cannot do that itself. Please refer\n"\
	             "# to http://mad-scientist.net/make/autodep.html to learn the shell hackery\n"\
	             "# details.\n"\
	             "Compiler.c:=cc -c -o \$$\$$@ \$$\$$< && cpp \$$\$$< |\\\\\n"\
	             "            sed -n 's%^\\# *[0-9][0-9]* *\"\\([^\"]*\\)\".*%\$$\$$@: \1%p' |\\\\\n"\
	             "            sed -e '/<built-in>/d' -e '/<command-line>/d' |\\\\\n"\
	             "            sort -u >\$$\$$(basename \$$\$$@).d\\\\\n"\
	             "# The following example adds a new translator, that just copies files to the\n"\
	             "# derived directory, for the \"unknown extension\" \"Backup\".\n"\
	             "CompilerBackup:=cp \$$\$$< \$$\$$@\n"\
	             "\E[2m\E[4mNotes\E[0m:\n"\
	             "You may have noticed the double dollar characters in front of the Make\n."\
	             "variables: They ensure that these variables are evaluated only when they\n"\
	             "are going to be used (i.e. when doing a translation). This allows\n"\
	             "to use automatic variables (i.e. variables that get their values when\n"\
	             "executing a rule) like \$$<, \$$^ and \$$@. Furthermore, it allows\n"\
	             "to change ordinary variables like \$$(INCLUDES) to be changed _after_\n"\
	             "the translator that uses them has been defined, allowing that modifying\n"\
	             "the defaults of these variables to take effect on the default definitions\n"\
	             "of the translators for \"known extensions\".\n"\
	             "\n"\
	             "\E[4mSources*\E[0m:\n"\
	             "The set of these variables allow to tell EasyMake which source files are\n"\
	             "to be translated with which translator. The logic behind this is rather\n"\
	             "simple: Each of these variables may comprise an arbitrary list of source files\n"\
	             "which are going to be translated with the translator that has the same\n"\
	             "extension as the related \"Sources\" variable.\n"\
	             "\E[2m\E[4mDefaults\E[0m:\n"\
	             "By default, the \"Sources\" variables for the \"known extensions\" do already\n"\
	             "contain a list of all files in and below the project's root directory having\n"\
	             "that extension (e.g. \"Sources.c\" contains all files having the extension\n"\
	             "\".c\"). All user defined \"Sources\" variables are initially empty.\n"\
	             "\E[2m\E[4mExamples\E[0m:\n"\
	             "# While the \"Sources\" variables for the default extensions contain only\n"\
	             "# files with that extension by default, one may well add or replace files with\n"\
	             "# other extensions to the list if these files should be translated with the\n"\
	             "# same translator. The example below adds a .cxx file to the list of .cpp\n"\
	             "# files and removes all files that end with \"unused.cpp\":\n"\
	             "Sources.cpp:=\$$\$$(filter-out %unused.cpp,\$$\$$(Sources.cpp) dir/new.cxx\n"\
	             "# Referring back to our previous example where we have defined a new\n"\
	             "# translator named \"CompilerBackup\", we now need to tell EasyMake which\n"\
	             "# files to \"back up\". While we may list each of these files individually,\n"\
	             "# this may quickly become a very tedious job for big sets of files. But\n"\
	             "# fortunately, EasyMake provides a convinience function called \"Find\",\n"\
	             "# which just takes a search pattern and the root directory tree to search\n"\
	             "# as its argumets.\n"\
	             "SourcesBackup:=\$$(call Find *.txt,/my/documents/directory)\n"\
	             "\E[2m\E[4mNotes\E[0m:\n"\
	             "If the directory given as the second argument to \"Find\" is a relative path,\n"\
	             "it is important to note that this is relative to the derived directory and\n"\
	             "not to the project's root directory as one may expect. This behaviour may\n"\
	             "change in future versions of EasyMake. The EasyMake variable \"SourceDirectory\"\n"\
	             "may be helpful to make a path relative to the project's root directory an\n"\
	             "absolute path, as it contains the absolute path to the project's root\n"\
	             "directory.\n"\
	             "  Furthermore, it is worth to note that \"Find\" ignores any subdirectories\n"\
	             "that themselves contain a file named \"Makefile\". This allows to store other\n"\
	             "projects (that may e.g. serve as prerequisites for the current project)\n"\
	             "anywhere below the current project's root directory without having EasyMake\n"\
	             "adding their content to the list of files to be translated, as long as these\n"\
	             "(sub) projects have their own Makefile. Furthermore, it is absoluely fine to\n"\
	             "also locate the derived directory below the current project's root directory\n"\
	             "regardless of the derived files' extensions, as EasyMake will always create a\n"\
	             "Makefile there.\n"\
	             "  As an additional desirabe side effect, the Makefile in the derived directory\n"\
	             "allows to run Make in the same way from the derived directory as it may be run\n"\
	             "from the project's root directory.)\n"\
	             "\n"\
	             "\E[4mLinker*\E[0m:\n"\
	             "Now that we know how EasyMake's default behaviour may be changed w.r.t which\n"\
	             "files are translated how, we look into how Easymake's default behaviour w.r.t.\n"\
	             "binding the results of the translation may be modified.\n"\
	             "\E[2m\E[4mDefaults\E[0m:\n"\
	             "As already indicated in the quick start guide, EasyMake's choice regarding the\n"\
	             "default binder to be used depends on the name of the target or, more acurately,\n"\
	             "on the target name's extension. The following default linkers are defined\n"\
	             "according to these target extensions:\n"\
	             "Linker=\$$\$$(CXX) \$$\$$(LDFLAGS)\\\\\n"\
	             "               \$$\$$(addprefix -Wl\$$\$$(COMMA),\$$\$$(LINKERFLAGS))\\\\\n"\
	             "               \$$\$$(addprefix -l,\$$\$$(LIBRARIES))\\\\\n"\
	             "               \$$\$$(addprefix -L,\$$\$$(LIBDIRS))\\\\\n"\
	             "               -o \$$\$$@ \$$\$$^\n"\
	             "Linker.so=\$$\$$(CXX) -shared -fPIC \$$\$$(LDFLAGS)\\\\\n"\
	             "                  \$$\$$(addprefix -Wl\$$\$$(COMMA),\$$\$$(LINKERFLAGS))\\\\\n"\
	             "                  \$$\$$(addprefix -l,\$$\$$(LIBRARIES))\\\\\n"\
	             "                  \$$\$$(addprefix -L,\$$\$$(LIBDIRS))\\\\\n"\
	             "                  -o \$$\$$@ \$$\$$^\n"\
	             "Linker.dll=\$$\$$(CXX) -shared -fPIC \$$\$$(LDFLAGS)\\\\\n"\
	             "                  \$$\$$(addprefix -Wl\$$\$$(COMMA),\$$\$$(LINKERFLAGS))\\\\\n"\
	             "                  \$$\$$(addprefix -l,\$$\$$(LIBRARIES))\\\\\n"\
	             "                  \$$\$$(addprefix -L,\$$\$$(LIBDIRS))\\\\\n"\
	             "                  -o \$$\$$@ \$$\$$^\n"\
	             "Linker.a=\$$\$$(AR) \$$\$$(ARFLAGS) \$$\$$@ \$$\$$^\n"\
	             "Similar to the default translators, the default binders allow that parts\n"\
	             "of the binding commands may be chaned through variables. Again, the defaults\n"\
	             "for all these variables is the empty string, except for \"CXX\" (defaults to\n"\
	             "\"g++\"), \"AR\" (defaults to \"ar\") and \"ARFLAGS\" (defaults to \"-rc\".\n"\
	             "\E[2m\E[4mExamples\E[0m:\n"\
	             "# Directly use ld to bind executables.\n"\
	             "Linker:=ld -o \$$\$$@ \$$\$$^\n"\
	             "This line adds a new linker that will be used whenever a target has the\n"\
	             "the extension \".tar\".\n"\
	             "Linker.tar:=tar cvf \$$\$$@ \$$\$$\n"\
	             "\E[2m\E[4mNotes\E[0m:\n"\
	             "You may have noticed the \"COMMA\" variable in the defaults for both\n"\
	             "\"Linker\" and \"Linker.so\". Here, we just want to pass flags directly\n"\
	             "to the \"ld\" backend of \"g++\", which has to be done in the form\n"\
	             "\"-Wl,flags\". But Make's \$$(addprefix ) function would misinterpret\n"\
	             "this comma to be a parameter separator. The \"COMMA\" variable solves\n"\
	             "this problem, causing a comma to be put at the proper place on the linker\n"\
	             "command line.\n"\
	             "\n"\
	             "\E[4mObjectExtension\E[0m:\n"\
	             "This variable just allows to change the extension being used for the\n"\
	             "intermediate object files.\n"\
	             "\E[2m\E[4mDefaults\E[0m:\n"\
	             "The default extension for object files is \".o\".\n"\
	             "\E[2m\E[4mExamples\E[0m:\n"\
	             "ObjectExtension:=.obj\n"\
	             "\E[2m\E[4mNotes\E[0m:\n"\
	             "Note that \"ObjectExtension\" does not replace the source file extension,\n"\
	             "but is appended to the source file name. Thus the default behaviour of\n"\
	             "EasyMake when compiling \"test.c\" is to produce an object file named\n"\
	             "\"test.c.o\". This allows source files that only differ by their extension,\n"\
	             "e.g. \"test.c\" and \"test.cpp to be linked into the same target.\"\n"\
	             "\n"\
	             "\E[1m2) EasyMake variables on hierarchy level 3\E[0m\n"\
	             "Up until now, all configuration options that were described apply to all\n"\
	             "targets of a specific platform. Thus, so far we only could configure\n"\
	             "different behaviour for different platforms by putting the described\n"\
	             "configuration variables into the related platform .mk files, but we couldn't\n"\
	             "configure a different behaviour for different targets belonging to the same\n"\
	             "platform, with the minor exception that we could already make the binding\n"\
	             "depend on each target's name. But we need much more: We may also want to use\n"\
	             "different compilers and different sets of source files to contribute to a\n"\
	             "target, and the intermediate files may need to have different\n"\
	             "\"ObjectExtension\"s depending on the specific translators and binders being\n"\
	             "used.\n"\
	             "  Fortunately, the desired per target configuration is rather easy to\n"\
	             "accomplish: Each of the EasyMake variables from hierarchy level 2\n"\
	             "except for the \"Targets\" variable) exists a set of related target specific\n"\
	             "variables, namely one for each target and hierarchy leve1 1 variable type.\n"\
	             "By default, these target specific variables inherit their content from their\n"\
	             "related hierarchy level 2 variables, regardless whether they still contain\n"\
	             "their initial default values or have been set to different values. An it's\n"\
	             "these target specific variables that are finally consulted by EasyMake to\n"\
	             "build its targets. This allows us to reconfigure these variables on a per\n"\
	             "target level.\n"\
	             "  A final example may make things even clearer, particularly w.r.t. the\n"\
	             "interaction of the hierarchy levels. Let us assume we want to build a C /\n"\
	             "C++ project for tree platforms, say \"i386\", \"x64\" and \"mips\", and we\n"\
	             "need to create targets \"t1\", \"t2\" and \"t3\" for platform \"i386\"\n"\
	             "and targets \"t1\" and \"t2\" for platforms \"x64\" and \"mips\".\n"\
	             "Furthermore, we assume that the default C compiler is fine for \"most\n"\
	             "of the platforms and targets we are about to build for, but that we need\n"\
	             "the latest prerelease version of the C++ compiler which is located in a\n"\
	             "non-standard location on our build machine, say\n"\
	             "\"/usr/local/gcc-5.0-pre/bin/g++\". Finally, we assume that the \"mips\"\n"\
	             "platform needs a cross compiler located in \"/usr/local/mips/bin/gcc\"\n"\
	             "and \"/usr/local/mips/bin/g++\" and that target \"t2\" is a Windoze\n"\
	             "tool that needs to be built with the M$-compiler.\n"\
	             "  As we need to build (and configure) for three different platforms,\n"\
	             "we need three platform .mk files besided the User.mk containing any\n"\
	             "common configuration items. Thus, here are the four files, each of\n"\
	             "them equipped with detailed comments:\n"\
	             "\n"\
	             "\E[4mUser.mk\E[0m:\n"\
	             "######################### Level 0 configuration ##########################\n"\
	             "# Level 0 \"configuration\" just means leaving the defaults where they\n"\
	             "# are. Thus, we don't see anything w.r.t. the fact that we are fine with\n"\
	             "# the default setting of \"Cpmpiler.c\" and the other variables taht we just\n"\
	             "# touch.\n"\
	             "\n"\
	             "######################### Level 1 configuration ##########################\n"\
	             "# Here, we may define the platforms that we want to build for by default.\n"\
	             "# But be aware that this variable may be changed by passing it on the\n"\
	             "# command line when running Make, e.g. to only build for a subset of the\n"\
	             "# available pltatforms, and that one can only build for platforms that\n"\
	             "# have a corresponding platform .mk file.\n"\
	             "Platforms:=i386 x64 mips\n"\
	             "\n"\
	             "######################### Level 2 configuration ##########################\n"\
	             "# The targets \"t1\" and \"t2\" must be build for all platforms.\n"\
	             "Targets:=t1 t2\n"\
	             "# We assumed that we need the latest version of the version of g++, so\n"\
	             "# we override the default for \"Compiler.cpp\" and \"Compiler.cc\" for all\n"\
	             "platforms and targets.\n"\
	             "Compiler.cpp:=/usr/local/gcc-5.0-pre/bin/g++ \$$\$$(ANY_FLAGS) -c -MD -o \$$\$$@ \$$\$$<\n"\
	             "Compiler.cc:=\$$\$$(Compiler.cpp)\n"\
	             "\E[0m" | less -R
        .PHONY: example
        example:
	             @echo "Sorry, to be done!"
        .PHONY: todo
        todo:
	    @echo -e "                   \E[1m\E[4mToDo List\E[0m\n"\
	             "This is a list of possible improvements that may become part of\n"\
	             "EasyMake in the future if I find the time and / or if they may be\n"\
	             "needed:\n"\
	             "\n"\
	             "- Extend the default compiler list to support other typical\n"\
	             "  extensions like lex and yacc, other compilers, Tex, ...\n"\
	             "- Test EasyMake on Windows and with VisualC.\n"\
	             "- Add generic postprocessing support.\n"\
	             "- Automatically find source files for unknown, but configured compilers\n"\
	             "- Make relative paths in \"Find\" relative to the project's root directory\n"\
	             "- Proper handling of environment variables as defaults\n"\
	             "\E[0m" | less -R
        .PHONY: license
        license:
	    @echo -e "                   \E[1m\E[4mTerms and Conditions\E[0m\n"\
	             "EasyMake may be distributed and used under the terms and conditions\n"\
	             "of the GPL Version 3 (see http://www.gnu.org/copyleft/gpl.html).\n"\
	             "\n"\
	             "Please report any bugs or improvement suggestions to\n"\
	             "Christof.Warlich@siemens.com.\n"\
	             "\n"\
	             "Credits for EasyMake's multi-architecture part and the dependency\n"\
	             "generation belong to the maintainer of GNU Make, Paul Smith\n"\
	             "(see http://mad-scientist.net/make/multi-arch.html and\n"\
	             "http://mad-scientist.net/make/autodep.html to grasp the ideas)."\
	             "\E[0m" | less -R
    endif
# ... while the else-branch is evaluated when Make repawns
# itself for a specific platform.
else
    # Avoids incomplete or corrupt targets. Every Makefile
    # should contain this line!
    .DELETE_ON_ERROR:
    # To avoid a leading slash if $(Platform) is empty.
    $(if $(Platform),$(eval _PlatformSlash=$(Platform)/),$(eval _PlatformSlash=))
    # Again, the usual default Goal, but now we really build
    # for a specific platform.
    .PHONY: all
    # Default Goal needs to be defined before including anything that may
    # define additonal rules.
    all: _all
    # This takes care that we still find our sources while
    # being in the target directory. Futhermore, it allows
    # to find "generated sources" locally, i.e in the derived
    # directory.
    VPATH:=$(SourceDirectory)
    # Where to store intermediate files.
    IntermediateDirectory=intermediate
    # Now we set the default values for target specific ObjectExtension,
    # ObjectPrerequisites, Compiler and Sources ...
    $(foreach _i,$(_$(Platform)Targets),\
        $(foreach _j,$(filter _$(Platform)ObjectExtension\
                              _$(Platform)ObjectPrerequisites\
                              _$(Platform)Compiler%\
                              _$(Platform)Sources%,\
                              $(.VARIABLES)\
                     ),\
            $(eval $(patsubst _$(Platform)%,\
                              $(_i)%,\
                              $(_j)\
                   )=$(subst $$,$$$$,$($(_j))))\
        )\
    )
    # We are a bit smarter w.r.t the target specific Linker, letting it depend
    # on the target name's extension. If the extension of a given Linker
    # matches more than one extension, the longest one is used.
    # Note that we cannot deduce the Linker depending on the Sources though
    # (e.g. to find out if we should use gcc or g++), as they may still be
    # modified.
    $(foreach _i,$(_$(Platform)Targets),\
        $(eval _extension=)\
        $(foreach _j,$(patsubst _$(Platform)Linker%,\
                                %,\
                                $(filter _$(Platform)Linker%,\
                                         $(.VARIABLES)\
                                )\
                     ),\
            $(if $(filter %$(_j),$(_i)),\
                $(if $(filter $(_j)%,$(_extension)),\
            ,\
                $(eval _extension=$(_j))\
            )\
            )\
        )\
        $(eval $(_i)Linker=$(subst $$,$$$$,$(_$(Platform)Linker$(_extension))))\
    )
    # Restore Targets, Linker, Compiler and Sources to their defaults before
    # reincluding.
    $(foreach _j,$(filter Targets ObjectExtension Linker Compiler% Sources%,\
                          $(.VARIABLES)\
                 ),\
        $(eval $(_j)=$(subst $$,$$$$,$(__$(_j))))\
    )
    # ... which may be modified here, being prepended with the target's name.
    -include User.mk
    ifneq (,$(Platform))
        include $(Platform).mk
    endif
    # Pretty prints command. Also works always fine with the -j option.
    define _PrettyPrint
	@if [ -n '$(subst ',,$1)' ]; then\
	    echo -ne "\E[2m$2 target \"$(_i)\": \E[0m";\
	fi
	$1
    endef
    # Dependency calculation. Note the tab in front of the reciepe and
    # the spaces in front of the include statement.
    define _Dependencies
	    @if [ -e "$1.d" ]; then\
	        cp $1.d $(1).tmp &&\
	        sed -e 's/#.*//' -e '0,/^[^:]*: */s///' -e 's/ *\\$$$$//' \
	            -e '/^$$$$/ d' -e 's/$$$$/ :/' < $(1).tmp >>$1.d; \
	    fi
        -include $1.d
    endef
    define _PrettyDep
	$(call _PrettyPrint,$1,$2)
	$(call _Dependencies,$(strip $3))
    endef
    # Set up the list of objects for each list of sources:
    # For the variable names, we replace Sources by Objects. Then we prepend
    # the relative path of the contained file names (to the source directory)
    # with the relative path of the derived directory (i.e. platform/target,
    # relative to $(DerivedDirectory).
    $(foreach _i,$(_$(Platform)Targets),\
        $(eval $(_i)Objects:=)\
        $(foreach _j,$(filter $(_i)Sources%,$(.VARIABLES)),\
            $(eval $(_j)=$(patsubst $(SourceDirectory)/%,%,$($(_j))))\
            $(eval $(_j)=$(addsuffix $(patsubst $(_i)Sources%,%,$(_j)),$($(_j))))\
            $(eval $(patsubst $(_i)Sources%,\
                              $(_i)Objects%,\
                              $(_j)\
                   )=$(addsuffix $($(_i)ObjectExtension),\
                                 $(addprefix $(_PlatformSlash)$(IntermediateDirectory)/$(_i)/,\
                                             $($(_j))\
                                 )\
                     )\
            )\
            $(eval $(_i)Objects+=$($(patsubst $(_i)Sources%,$(_i)Objects%,$(_j))))\
            $(foreach _k,$($(_j)),\
                $(eval $(_PlatformSlash)$(IntermediateDirectory)/$(_i)/$(_k)$($(_i)ObjectExtension):\
                       $(_k) $($(_i)ObjectPrerequisites) |\
                       $(dir $(_PlatformSlash)$(IntermediateDirectory)/$(_i)/$(_k)) ;\
                           $(call _PrettyDep,$($(_i)Compiler$(suffix $(patsubst $(_i)%,%,$(_j)))),Compiling for,\
                                             $(_PlatformSlash)$(IntermediateDirectory)/$(_i)/$(_k)\
                           )\
                )\
            )\
        )\
        $(if $(strip $($(_i)Objects)),\
            $(if $(filter-out false,$(DontDependOnMakefiles)),,\
                $(eval $($(_i)Objects): $(addprefix $(SourceDirectory)/,\
                                                    Makefile\
                                                    $(if $(Platform),\
                                                        $(wildcard $(Platform).mk)\
                                                    )\
                                        )\
                                        $(wildcard $(SourceDirectory)/User.mk)\
                )\
            )\
            $(eval $(filter-out ./,$(sort $(dir $($(_i)Objects)))): ; @mkdir -p $$@)\
            $(eval $(_PlatformSlash)$(_i): $($(_i)Objects) ; $(call _PrettyPrint,$($(_i)Linker),Linking))\
        ,\
            $(eval _$(Platform)Targets:=$(filter-out $(_i),$(_$(Platform)Targets)))\
        )\
    )
    .PHONY: _all
    # We want to build all targets by default.
    _all: $(addprefix $(_PlatformSlash),$(_$(Platform)Targets))
endif
