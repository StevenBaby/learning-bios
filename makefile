
SRC:=src
BUILD:=build
NASM:=nasm

$(BUILD)/%.bin: $(SRC)/%.asm
	$(NASM) -f bin $< -o $@

$(BUILD)/floppya.img: $(BUILD)/boot.bin
ifeq ("$(wildcard build/floppya.img)", "")
	bximage -q -fd=1.44M -mode=create -sectsize=512 -imgmode=flat $@
endif
	dd if=$(BUILD)/boot.bin of=$@ bs=512 count=1 conv=notrunc

.PHONY: image
image: $(BUILD)/floppya.img
	-

.PHONY: bochs
bochs: $(BUILD)/floppya.img
	cd $(BUILD) && bochs -q -unlock

.PHONY: clean
clean:
	rm -rf $(BUILD)/*.bin
	rm -rf $(BUILD)/*.img
