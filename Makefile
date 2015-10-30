default:
	@echo "huh?"

MMCU = atmega328p
KBUILD_CFLAGS = -O2 -DF_CPU=16000000UL

CC=avr-gcc
OBJCOPY=avr-objcopy

AVRDUDE=avrdude
BOARD=arduino
CHIP=ATMEGA328P
PORT=/dev/ttyACM0
BAUD=115200

install:
	$(AVRDUDE) -F -V -c $(BOARD) -p $(CHIP) -P $(PORT) -b $(BAUD) -U flash:w:barduino.hex;

clean:
	rm -f barduino.o;
	rm -f barduino.hex;

mk_compile:
	$(CC) $(KBUILD_CFLAGS) -mmcu=$(MMCU) -c -o barduino.o $(SOURCE);
	$(OBJCOPY) -O ihex -R .eeprom barduino.o barduino.hex;
	@echo "make success! load with \`make install\`"

LED_SOURCE = blinky/led.c
led: clean
	@$(MAKE) -f Makefile --no-print-directory SOURCE=$(LED_SOURCE) mk_compile

BUZZER_SOURCE = buzzer/buzzer.c
buzzer: clean
	@$(MAKE) -f Makefile --no-print-directory SOURCE=$(BUZZER_SOURCE) mk_compile


SAMPLE_SOURCE = sample.c
sample: clean
	@SOURCE=$(SAMPLE_SOURCE)
	
