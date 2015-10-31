default:
	@echo "huh?"

ARDUINO_BASE = /home/thewisenerd/arduino-1.6.5-r5
BASE_DIR     = /home/thewisenerd/works/barduino
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

INCLUDES = \
-I$(ARDUINO_BASE)/hardware/arduino/avr/cores/arduino \
-I$(ARDUINO_BASE)/hardware/arduino/avr/variants/standard

install:
	$(AVRDUDE) -F -V -c $(BOARD) -p $(CHIP) -P $(PORT) -b $(BAUD) -U flash:w:barduino.hex;

clean:
	rm -f barduino.o;
	rm -f barduino.hex;


BASE_CPP_FILES = $(wildcard $(ARDUINO_BASE)/hardware/arduino/avr/cores/arduino/*.cpp)
BASE_ASM_FILES = $(wildcard $(ARDUINO_BASE)/hardware/arduino/avr/cores/arduino/*.S)

BASE_C_FILES   = $(wildcard $(ARDUINO_BASE)/hardware/arduino/avr/cores/arduino/*.c)
BASE_C_OBJ     = $(patsubst %.c, %.o, $(BASE_C_FILES))
%.o: %.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -mmcu=$(MMCU) $(DFLAGS) $(INCLUDES) $^ -o $(OUT_DIR)/$@
base_c: $(BASE_C_OBJ)

sketch:
	@mkdir -p $(OUT_DIR)
	@echo $(BASE_C_FILES)
	@$(MAKE) -f Makefile --no-print-directory base_c
