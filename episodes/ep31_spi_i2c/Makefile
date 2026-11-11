# SPI & I2C masters - Episode 31. Needs Vivado 2023.2 on PATH (source settings64.sh).
.PHONY: sim build clean
sim:
	xvlog rtl/spi_master.v tb/tb_spi.v && xelab -debug off tb_spi -s sim_spi && xsim sim_spi -runall
	xvlog rtl/i2c_master.v tb/tb_i2c.v && xelab -debug off tb_i2c -s sim_i2c && xsim sim_i2c -runall
build:
	vivado -mode batch -source scripts/build.tcl
clean:
	rm -rf xsim.dir *.jou *.log *.pb *.wdb build
