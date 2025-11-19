# Makefile for ghdl fast sim

GHDL=ghdl
STD=--std=08
WAVE=wave.ghw
TB=u_fifo_tb


# compile
SRC_RTL=../rtl/u_fifo.vhd


SRC_TB=u_fifo_tb.vhd

all: run

analyze:
	$(GHDL) -a $(STD) $(SRC_RTL) $(SRC_TB)

elab: analyze
	$(GHDL) -e $(STD) $(TB)

run: elab
	$(GHDL) -r $(STD) $(TB) --wave=$(WAVE)

view:
	gtkwave $(WAVE)

clean:
	$(GHDL) --clean
	rm -f $(WAVE)

