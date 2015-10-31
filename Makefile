default:
	@echo "huh?"

ARDUINO_BASE = /home/thewisenerd/arduino-1.6.5-r5
BASE_DIR     = /home/thewisenerd/barduino
OUT_DIR      = $(BASE_DIR)/OBJ_FILES

CROSS_COMPILE ?= $(ARDUINO_BASE)/hardware/tools/avr/bin/avr-
CC=gcc
CPP=g++
AR=ar
OBJCOPY=objcopy

AVRDUDE=avrdude
BOARD=arduino
CHIP=ATMEGA328P
PORT ?= /dev/ttyACM0
BAUD=115200

MMCU = atmega328p
CFLAGS   = -c -g -Os -w -ffunction-sections -fdata-sections -MMD
CPPFLAGS = -c -g -Os -w -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD
SFLAGS = -c -g -x assembler-with-cpp
DFLAGS = -DF_CPU=16000000L -DARDUINO=10605 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR

ARFLAGS = rcs
LDFLAGS = -w -Os -Wl,--gc-sections

PWD = $(shell pwd)

INCLUDES = \
-I$(ARDUINO_BASE)/hardware/arduino/avr/cores/arduino \
-I$(ARDUINO_BASE)/hardware/arduino/avr/variants/standard

install:
	$(AVRDUDE) -F -V -c $(BOARD) -p $(CHIP) -P $(PORT) -b $(BAUD) -U flash:w:$(OUT_DIR)/barduino.hex;

clean:
	rm -f barduino.o;
	rm -f barduino.hex;
	rm -f $(OUT_DIR)/*

SOURCE_DIR = $(ARDUINO_BASE)/hardware/arduino/avr/cores/arduino

BASE_C_FILES   = $(wildcard $(SOURCE_DIR)/*.c)
BASE_C_OBJ     = $(BASE_C_FILES:%.c=%.c.o)
%.c.o: %.c
	@echo "cc --   c -- "$\SOURCE_DIR/$(notdir $^)
	@$(CROSS_COMPILE)$(CC) $(CFLAGS) -mmcu=$(MMCU) $(DFLAGS) $(INCLUDES) $^ -o $(addprefix $(OUT_DIR)/, $(notdir $@))
	@$(CROSS_COMPILE)$(AR) $(ARFLAGS) $(OUT_DIR)/core.a $(addprefix $(OUT_DIR)/, $(notdir $@))
base_c: $(BASE_C_OBJ)

BASE_ASM_FILES = $(wildcard $(SOURCE_DIR)/*.S)
BASE_ASM_OBJ   = $(BASE_ASM_FILES:%.S=%.S.o)
%.S.o: %.S
	@echo cc -- asm -- $\SOURCE_DIR/$(notdir $^)
	@$(CROSS_COMPILE)$(CC) $(SFLAGS) -mmcu=$(MMCU) $(DFLAGS) $(INCLUDES) $^ -o $(addprefix $(OUT_DIR)/, $(notdir $@))
	@$(CROSS_COMPILE)$(AR) $(ARFLAGS) $(OUT_DIR)/core.a $(addprefix $(OUT_DIR)/, $(notdir $@))
base_asm: $(BASE_ASM_OBJ)

BASE_CPP_FILES = $(wildcard $(SOURCE_DIR)/*.cpp)
BASE_CPP_OBJ   = $(BASE_CPP_FILES:%.cpp=%.cpp.o)
%.cpp.o: %.cpp
	@echo cc -- cpp -- $\SOURCE_DIR/$(notdir $^)
	@$(CROSS_COMPILE)$(CPP) $(CPPFLAGS) -mmcu=$(MMCU) $(DFLAGS) $(INCLUDES) $^ -o $(addprefix $(OUT_DIR)/, $(notdir $@))
	@$(CROSS_COMPILE)$(AR) $(ARFLAGS) $(OUT_DIR)/core.a $(addprefix $(OUT_DIR)/, $(notdir $@))
base_cpp: $(BASE_CPP_OBJ)

mk_out:
	@mkdir -p $(OUT_DIR)

SOURCE_CPP_FILES = sketch.cpp
SOURCE_INCLUDES  = \
#

mk_compile:
	@$(CROSS_COMPILE)$(CPP) $(CPPFLAGS) -mmcu=$(MMCU) $(DFLAGS) $(INCLUDES) $(SOURCE_INCLUDES) $(SOURCE_CPP_FILES) -o $(OUT_DIR)/source.o

sketch: clean mk_out base_asm base_c base_cpp
	@$(MAKE) -f Makefile --no-print-directory mk_compile
	$(CROSS_COMPILE)$(CC) $(LDFLAGS) -mmcu=$(MMCU) -o $(OUT_DIR)/barduino.elf $(OUT_DIR)/source.o $(OUT_DIR)/core.a -L$(OUT_DIR) -lm
	$(CROSS_COMPILE)$(OBJCOPY) -O ihex -R .eeprom $(OUT_DIR)/barduino.elf $(OUT_DIR)/barduino.hex
