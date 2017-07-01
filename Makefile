# (C) Copyleft 2011 2012 2013 2014 2015 2016 2017
# Late Lee from http://www.latelee.org
# 
# A simple Makefile for *ONE* project(c or/and cpp file) in *ONE* or *MORE* directory
#
# note: 
# you can put head file(s) in 'include' directory, so it looks 
# a little neat.
#
# usage: 
#        $ make
#        $ make V=1     # verbose ouput
#        $ make CROSS_COMPILE=arm-arago-linux-gnueabi-  # cross compile for ARM, etc.
#        $ make debug=y # debug
#        $ make SRC_DIR1=foo SRC_DIR2=bar SRC_DIR3=crc
#
# log
#       2013-05-14 sth about debug...
#       2016-02-29 sth for c/c++ multi diretory
#       2017-04-17 -s for .a/.so if no debug
#       2017-05-05 Add V for verbose ouput
###############################################################################

# !!!=== cross compile...
CROSS_COMPILE ?= 

CC  = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++
AR  = $(CROSS_COMPILE)ar

ARFLAGS = -cr
RM     = -rm -rf
MAKE   = make

CFLAGS  = 
LDFLAGS = 
DEFS    =
LIBS    =

# !!!===
# target executable file or .a or .so
# target = libucosiii.a
target = app

# !!!===
# compile flags
CFLAGS += -Wall -Wfatal-errors

#****************************************************************************
# debug can be set to y to include debugging info, or n otherwise
debug  = y

#****************************************************************************

ifeq ($(debug), y)
    CFLAGS += -ggdb -rdynamic
else
    CFLAGS += -O2 -s
endif

# !!!===
DEFS    += -DFUCK

CFLAGS  += $(DEFS)

# LIBS    += ./hello/libhello.a

LDFLAGS += $(LIBS)

#t !!!===
INC1 = ./Software/uC-CPU
INC5 = ./Software/uC-CPU/Posix/GNU
INC2 = ./Software/uC-LIB
INC3 = ./Software/uCOS-III/Source
INC4 = ./Software/uCOS-III/Ports/POSIX/GNU

INC6 = ./Examples/POSIX/GNU/OS3
INCDIRS := -I$(INC5) -I$(INC1) -I$(INC2) -I$(INC3) -I$(INC4) -I$(INC6) 

# !!!===
CFLAGS += $(INCDIRS)

# !!!===
LDFLAGS += -lpthread -lrt

DYNC_FLAGS += -fpic -shared

# !!!===
# source file(s), including c file(s) or cpp file(s)
# you can also use $(wildcard *.c), etc.
SRC_DIR  = ./Software/uC-CPU
SRC_DIR1 = ./Software/uC-LIB
SRC_DIR2 = ./Software/uCOS-III/Source
SRC_DIR3 = ./Software/uCOS-III/Ports/POSIX/GNU
SRC_DIR4 = ./Software/uC-CPU/Posix/GNU

SRC_DIR5 = ./Examples/POSIX/GNU/OS3

# ok for c/c++
SRC = $(wildcard $(SRC_DIR)/*.c $(SRC_DIR)/*.cpp)
SRC+=$(wildcard $(SRC_DIR1)/*.c $(SRC_DIR1)/*.cpp)
SRC+=$(wildcard $(SRC_DIR2)/*.c $(SRC_DIR2)/*.cpp)
SRC+=$(wildcard $(SRC_DIR3)/*.c $(SRC_DIR3)/*.cpp)
SRC+=$(wildcard $(SRC_DIR4)/*.c $(SRC_DIR4)/*.cpp)
SRC+=$(wildcard $(SRC_DIR5)/*.c $(SRC_DIR5)/*.cpp)
# ok for c/c++
OBJ = $(patsubst %.c,%.o, $(patsubst %.cpp,%.o, $(SRC))) 


# !!!===
# in case all .c/.cpp need g++...
# CC = $(CXX)

ifeq ($(V),1)
Q=
NQ=true
else
Q=@
NQ=echo
endif

###############################################################################

all: $(target)

var: 
	@echo "src list:" $(SRC)

$(target): $(LIBS) $(OBJ)

ifeq ($(suffix $(target)), .so)
	@$(NQ) "Generating dynamic lib file..." $(notdir $(target))
	$(Q)$(CXX) $(CFLAGS) $^ -o $(target) $(LDFLAGS) $(DYNC_FLAGS)
else ifeq ($(suffix $(target)), .a)
	@$(NQ) "Generating static lib file..." $(notdir $(target))
	$(Q)$(AR) $(ARFLAGS) -o $(target) $^
else
	@$(NQ) "Generating executable file..." $(notdir $(target))
	$(Q)$(CXX) $(CFLAGS) $^ -o $(target) $(LDFLAGS)
endif

# make all .c or .cpp
%.o: %.c
	@$(NQ) "Compiling: " $(addsuffix .c, $(basename $(notdir $@)))
	$(Q)$(CC) $(CFLAGS) -c $< -o $@

%.o: %.cpp
	@$(NQ) "Compiling: " $(addsuffix .cpp, $(basename $(notdir $@)))
	$(Q)$(CXX) $(CFLAGS) -c $< -o $@

clean:
	@$(NQ) "Cleaning..."
	$(Q)$(RM) $(target) $(OBJ)

# use 'grep -v soapC.o' to skip the file
	@find . -iname '*.o' -o -iname '*.bak' -o -iname '*.d' | xargs rm -f

.PHONY: all clean

