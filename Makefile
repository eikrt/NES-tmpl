TARGET_ARCH := nes
ASM  := ca65
LINK := ld65

EXE := game.nes
SOURCES := game.s 
OBJECTS := $(SOURCES:%.s=%.o)

$(EXE): $(OBJECTS) Makefile
	$(LINK) $(OBJECTS) -o $@ -t $(TARGET_ARCH)

$(OBJECTS): $(SOURCES) Makefile
	$(ASM) $(SOURCES) -o $@ -t $(TARGET_ARCH)

.PHONY: all

all: $(EXE)
