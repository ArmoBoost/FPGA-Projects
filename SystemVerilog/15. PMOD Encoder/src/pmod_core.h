#pragma once

#include "chu_init.h"

class PmodCore{
public:
	enum{
		DATA_REG =0
	};
	PmodCore(uint32_t core_base_addr);
	~PmodCore();

	uint32_t read();

	int read(int bit_pos);

	int readSW();

	int readBTN();

	int readL();

	int readR();

private:
	uint32_t base_addr;

};
