# Makefile for ghdl fast sim

GHDL=ghdl
STD=--std=08
WAVE=wave.ghw
TB=uart_tb


# compile
SRC_RTL= \
  ../rtl/u_baudgen.vhd \
  ../rtl/u_rx.vhd \
  ../rtl/u_tx.vhd \
  ../rtl/u_ctrl.vhd \
  ../rtl/rx_shiftreg.vhd \
  ../rtl/u_fifo.vhd \
  ../rtl/uart.vhd

SRC_TB=uart_tb.vhd

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

