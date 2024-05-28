/*****************************************************************//**
 * @file main_sampler_test.cpp
 *
 * @brief Basic test of nexys4 ddr mmio cores
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

// #define _DEBUG
#include "chu_init.h"
#include "gpio_cores.h"
#include "xadc_core.h"
#include "sseg_core.h"
#include "spi_core.h"
#include "i2c_core.h"
#include "ps2_core.h"
#include "ddfs_core.h"
#include "adsr_core.h"

#include "pmod_core.h"

/**
 * blink once per second for 5 times.
 * provide a sanity check for timer (based on SYS_CLK_FREQ)
 * @param led_p pointer to led instance
 */
void timer_check(GpoCore *led_p) {
   int i;

   for (i = 0; i < 5; i++) {
      led_p->write(0xffff);
      sleep_ms(500);
      led_p->write(0x0000);
      sleep_ms(500);
      debug("timer check - (loop #)/now: ", i, now_ms());
   }
}

/**
 * check individual led
 * @param led_p pointer to led instance
 * @param n number of led
 */
void led_check(GpoCore *led_p, int n) {
   int i;

   for (i = 0; i < n; i++) {
      led_p->write(1, i);
      sleep_ms(100);
      led_p->write(0, i);
      sleep_ms(100);
   }
}

/**
 * leds flash according to switch positions.
 * @param led_p pointer to led instance
 * @param sw_p pointer to switch instance
 */
void sw_check(GpoCore *led_p, GpiCore *sw_p) {
   int i, s;

   s = sw_p->read();
   for (i = 0; i < 30; i++) {
      led_p->write(s);
      sleep_ms(50);
      led_p->write(0);
      sleep_ms(50);
   }
}

/**
 * uart transmits test line.
 * @note uart instance is declared as global variable in chu_io_basic.h
 */
void uart_check() {
   static int loop = 0;

   uart.disp("uart test #");
   uart.disp(loop);
   uart.disp("\n\r");
   loop++;
}

/**
 * read FPGA internal voltage temperature
 * @param adc_p pointer to xadc instance
 */

void adc_check(XadcCore *adc_p, GpoCore *led_p) {
   double reading;
   int n, i;
   uint16_t raw;

   for (i = 0; i < 5; i++) {
      // display 12-bit channel 0 reading in LED
      raw = adc_p->read_raw(0);
      raw = raw >> 4;
      led_p->write(raw);
      // display on-chip sensor and 4 channels in console
      uart.disp("FPGA vcc/temp: ");
      reading = adc_p->read_fpga_vcc();
      uart.disp(reading, 3);
      uart.disp(" / ");
      reading = adc_p->read_fpga_temp();
      uart.disp(reading, 3);
      uart.disp("\n\r");
      for (n = 0; n < 4; n++) {
         uart.disp("analog channel/voltage: ");
         uart.disp(n);
         uart.disp(" / ");
         reading = adc_p->read_adc_in(n);
         uart.disp(reading, 3);
         uart.disp("\n\r");
      } // end for
      sleep_ms(200);
   }
}

/**
 * tri-color led dims gradually
 * @param led_p pointer to led instance
 * @param sw_p pointer to switch instance
 */

void pwm_3color_led_check(PwmCore *pwm_p) {
   int i, n;
   double bright, duty;
   const double P20 = 1.2589;  // P20=100^(1/20); i.e., P20^20=100

   pwm_p->set_freq(50);
   for (n = 0; n < 3; n++) {
      bright = 1.0;
      for (i = 0; i < 20; i++) {
         bright = bright * P20;
         duty = bright / 100.0;
         pwm_p->set_duty(duty, n);
         pwm_p->set_duty(duty, n + 3);
         sleep_ms(100);
      }
      sleep_ms(300);
      pwm_p->set_duty(0.0, n);
      pwm_p->set_duty(0.0, n + 3);
   }
}

/**
 * Test debounced buttons
 *   - count transitions of normal and debounced button
 * @param db_p pointer to debouceCore instance
 */

void debounce_check(DebounceCore *db_p, GpoCore *led_p) {
   long start_time;
   int btn_old, db_old, btn_new, db_new;
   int b = 0;
   int d = 0;
   uint32_t ptn;

   start_time = now_ms();
   btn_old = db_p->read();
   db_old = db_p->read_db();
   do {
      btn_new = db_p->read();
      db_new = db_p->read_db();
      if (btn_old != btn_new) {
         b = b + 1;
         btn_old = btn_new;
      }
      if (db_old != db_new) {
         d = d + 1;
         db_old = db_new;
      }
      ptn = d & 0x0000000f;
      ptn = ptn | (b & 0x0000000f) << 4;
      led_p->write(ptn);
   } while ((now_ms() - start_time) < 5000);
}

/**
 * Test pattern in 7-segment LEDs
 * @param sseg_p pointer to 7-seg LED instance
 */

void sseg_check(SsegCore *sseg_p) {
   int i, n;
   uint8_t dp;

   //turn off led
   for (i = 0; i < 8; i++) {
      sseg_p->write_1ptn(0xff, i);
   }
   //turn off all decimal points
   sseg_p->set_dp(0x00);

   // display 0x0 to 0xf in 4 epochs
   // upper 4  digits mirror the lower 4
   for (n = 0; n < 4; n++) {
      for (i = 0; i < 4; i++) {
         sseg_p->write_1ptn(sseg_p->h2s(i + n * 4), 3 - i);
         sseg_p->write_1ptn(sseg_p->h2s(i + n * 4), 7 - i);
         sleep_ms(300);
      } // for i
   }  // for n
      // shift a decimal point 4 times
   for (i = 0; i < 4; i++) {
      bit_set(dp, 3 - i);
      sseg_p->set_dp(1 << (3 - i));
      sleep_ms(300);
   }
   //turn off led
   for (i = 0; i < 8; i++) {
      sseg_p->write_1ptn(0xff, i);
   }
   //turn off all decimal points
   sseg_p->set_dp(0x00);

}

/**
 * Test adxl362 accelerometer using SPI
 */

void gsensor_check(SpiCore *spi_p, GpoCore *led_p) {
   const uint8_t RD_CMD = 0x0b;
   const uint8_t PART_ID_REG = 0x02;
   const uint8_t DATA_REG = 0x08;
   const float raw_max = 127.0 / 2.0;  //128 max 8-bit reading for +/-2g

   int8_t xraw, yraw, zraw;
   float x, y, z;
   int id;

   spi_p->set_freq(400000);
   spi_p->set_mode(0, 0);
   // check part id
   spi_p->assert_ss(0);    // activate
   spi_p->transfer(RD_CMD);  // for read operation
   spi_p->transfer(PART_ID_REG);  // part id address
   id = (int) spi_p->transfer(0x00);
   spi_p->deassert_ss(0);
   uart.disp("read ADXL362 id (should be 0xf2): ");
   uart.disp(id, 16);
   uart.disp("\n\r");
   // read 8-bit x/y/z g values once
   spi_p->assert_ss(0);    // activate
   spi_p->transfer(RD_CMD);  // for read operation
   spi_p->transfer(DATA_REG);  //
   xraw = spi_p->transfer(0x00);
   yraw = spi_p->transfer(0x00);
   zraw = spi_p->transfer(0x00);
   spi_p->deassert_ss(0);
   x = (float) xraw / raw_max;
   y = (float) yraw / raw_max;
   z = (float) zraw / raw_max;
   uart.disp("x/y/z axis g values: ");
   uart.disp(x, 3);
   uart.disp(" / ");
   uart.disp(y, 3);
   uart.disp(" / ");
   uart.disp(z, 3);
   uart.disp("\n\r");
}

/*
 * read temperature from adt7420
 * @param adt7420_p pointer to adt7420 instance
 */
void adt7420_check(I2cCore *adt7420_p, GpoCore *led_p) {
   const uint8_t DEV_ADDR = 0x4b;
   uint8_t wbytes[2], bytes[2];
   //int ack;
   uint16_t tmp;
   float tmpC;

   // read adt7420 id register to verify device existence
   // ack = adt7420_p->read_dev_reg_byte(DEV_ADDR, 0x0b, &id);

   wbytes[0] = 0x0b;
   adt7420_p->write_transaction(DEV_ADDR, wbytes, 1, 1);
   adt7420_p->read_transaction(DEV_ADDR, bytes, 1, 0);
   uart.disp("read ADT7420 id (should be 0xcb): ");
   uart.disp(bytes[0], 16);
   uart.disp("\n\r");
   //debug("ADT check ack/id: ", ack, bytes[0]);
   // read 2 bytes
   //ack = adt7420_p->read_dev_reg_bytes(DEV_ADDR, 0x0, bytes, 2);
   wbytes[0] = 0x00;
   adt7420_p->write_transaction(DEV_ADDR, wbytes, 1, 1);
   adt7420_p->read_transaction(DEV_ADDR, bytes, 2, 0);

   // conversion
   tmp = (uint16_t) bytes[0];
   tmp = (tmp << 8) + (uint16_t) bytes[1];
   if (tmp & 0x8000) {
      tmp = tmp >> 3;
      tmpC = (float) ((int) tmp - 8192) / 16;
   } else {
      tmp = tmp >> 3;
      tmpC = (float) tmp / 16;
   }
   uart.disp("temperature (C): ");
   uart.disp(tmpC);
   uart.disp("\n\r");
   led_p->write(tmp);
   sleep_ms(1000);
   led_p->write(0);
}

void ps2_check(Ps2Core *ps2_p) {
   int id;
   int lbtn, rbtn, xmov, ymov;
   char ch;
   unsigned long last;

   uart.disp("\n\rPS2 device (1-keyboard / 2-mouse): ");
   id = ps2_p->init();
   uart.disp(id);
   uart.disp("\n\r");
   last = now_ms();
   do {
      if (id == 2) {  // mouse
         if (ps2_p->get_mouse_activity(&lbtn, &rbtn, &xmov, &ymov)) {
            uart.disp("[");
            uart.disp(lbtn);
            uart.disp(", ");
            uart.disp(rbtn);
            uart.disp(", ");
            uart.disp(xmov);
            uart.disp(", ");
            uart.disp(ymov);
            uart.disp("] \r\n");
            last = now_ms();

         }   // end get_mouse_activitiy()
      } else {
         if (ps2_p->get_kb_ch(&ch)) {
            uart.disp(ch);
            uart.disp(" ");
            last = now_ms();
         } // end get_kb_ch()
      }  // end id==2
   } while (now_ms() - last < 5000);
   uart.disp("\n\rExit PS2 test \n\r");

}

/**
 * play primary notes with ddfs
 * @param ddfs_p pointer to ddfs core
 * @note: music tempo is defined as beats of quarter-note per minute.
 *        60 bpm is 1 sec per quarter note
 * @note "click" sound due to abrupt stop of a note
 *
 */
void ddfs_check(DdfsCore *ddfs_p, GpoCore *led_p) {
   int i, j;
   float env;

   //vol = (float)sw.read_pin()/(float)(1<<16),
   ddfs_p->set_env_source(0);  // select envelop source
   ddfs_p->set_env(0.0);   // set volume
   sleep_ms(500);
   ddfs_p->set_env(1.0);   // set volume
   ddfs_p->set_carrier_freq(262);
   sleep_ms(2000);
   ddfs_p->set_env(0.0);   // set volume
   sleep_ms(2000);
   // volume control (attenuation)
   ddfs_p->set_env(0.0);   // set volume
   env = 1.0;
   for (i = 0; i < 1000; i++) {
      ddfs_p->set_env(env);
      sleep_ms(10);
      env = env / 1.0109; //1.0109**1024=2**16
   }
   // frequency modulation 635-912 800 - 2000 siren sound
   ddfs_p->set_env(1.0);   // set volume
   ddfs_p->set_carrier_freq(635);
   for (i = 0; i < 5; i++) {               // 10 cycles
      for (j = 0; j < 30; j++) {           // sweep 30 steps
         ddfs_p->set_offset_freq(j * 10);  // 10 Hz increment
         sleep_ms(25);
      } // end j loop
   } // end i loop
   ddfs_p->set_offset_freq(0);
   ddfs_p->set_env(0.0);   // set volume
   sleep_ms(1000);
}

/**
 * play primary notes with ddfs
 * @param adsr_p pointer to adsr core
 * @param ddfs_p pointer to ddfs core
 * @note: music tempo is defined as beats of quarter-note per minute.
 *        60 bpm is 1 sec per quarter note
 *
 */
void adsr_check(AdsrCore *adsr_p, GpoCore *led_p, GpiCore *sw_p) {
   const int melody[] = { 0, 2, 4, 5, 7, 9, 11 };
   int i, oct;

   adsr_p->init();
   // no adsr envelop and  play one octave
   adsr_p->bypass();
   for (i = 0; i < 7; i++) {
      led_p->write(bit(i));
      adsr_p->play_note(melody[i], 3, 500);
      sleep_ms(500);
   }
   adsr_p->abort();
   sleep_ms(1000);
   // set and enable adsr envelop
   // play 4 octaves
   adsr_p->select_env(sw_p->read());
   for (oct = 3; oct < 6; oct++) {
      for (i = 0; i < 7; i++) {
         led_p->write(bit(i));
         adsr_p->play_note(melody[i], oct, 500);
         sleep_ms(500);
      }
   }
   led_p->write(0);
   // test duration
   sleep_ms(1000);
   for (i = 0; i < 4; i++) {
      adsr_p->play_note(0, 4, 500 * i);
      sleep_ms(500 * i + 1000);
   }
}

/**
 * core test
 * @param led_p pointer to led instance
 * @param sw_p pointer to switch instance
 */
void show_test_id(int n, GpoCore *led_p) {
   int i, ptn;

   ptn = n; //1 << n;
   for (i = 0; i < 20; i++) {
      led_p->write(ptn);
      sleep_ms(30);
      led_p->write(0);
      sleep_ms(30);
   }
}

//void led_pmod(GpoCore *led,PwmCore *pwm,SsegCore *sseg,PmodCore *enc){
//	int A = enc-> read(0);
//	int B = enc->read(1);
//
//	static double counter = 0;
//	if(counter>100){
//		counter=100;
//	}
//
//	else if(counter<0){
//		counter=0;
//	}
//
//	else{
//		if (A == 1){
//				A = 0;
//				counter = counter + 1;
//				sleep_ms(20);
//				A = 0;
//			}
//
//			if (B == 1){
//				B = 0;
//				counter = counter - 1;
//				sleep_ms(20);
//				B = 0;
//			}
//
//	}
//
//
//	int a,b,c;                                    //holds values of ones, tenths, and hundreths place
//	a = (int)counter %10;
//	b = (int)(counter/10)%10;
//	c = (int)(counter/100)%10;
//
//	sseg->set_dp(0); //sets decimal point to the third sseg
//	sseg->write_1ptn(sseg->h2s(a), 0);
//	sseg->write_1ptn(sseg->h2s(b), 1);
//	sseg->write_1ptn(sseg->h2s(c), 2);       //convert
//	//////////////////////////////END OF SSEG SECTION/////////////////////////////////////////////////////
//
//	double blue,green,red;
//	double csB,csG,csR;
//	static int colorCounter=0;
//	double counterB,counterG,counterR;
//	if(enc->read(2)){
//		colorCounter++;
//		sleep_ms(200);
//		if (colorCounter>2){
//			colorCounter=0;
//		}
//	}
//
//	if(colorCounter == 0){
//		csB=1.0;
//		csG=0.0;
//		csR =0.0;
//		blue=counter/100;
//		counterB=counter;
//	}
//
//	else if(colorCounter == 1){
//		csB=0.0;
//		csG=1.0;
//		csR =0.0;
//		green=counter/100;
//		counterG=counter;
//	}
//
//	else{
//		csB=0.0;
//		csG=0.0;
//		csR =1.0;
//		red=counter/100;
//		counterR=counter;
//	}
//
//
//
//	double bright = 0.2; //set brightness
//	pwm->set_freq(50); //sets freq of pwm
//
//	pwm->set_duty(csB * bright, 0);
//	pwm->set_duty(csG * bright, 1);
//	pwm->set_duty(csR * bright, 2);
//
//	pwm->set_duty(blue * bright, 3);
//	pwm->set_duty(green * bright, 4);
//	pwm->set_duty(red * bright, 5);
//}

void led_pmod(GpoCore *led,PwmCore *pwm,SsegCore *sseg,PmodCore *enc){
//	int A = enc-> read(0); //read right turn
//	int B = enc->read(1); //read left turn
	int a,b,c;        //holds values of ones, tenths, and hundreths place

	int A= enc->readR();
	int B= enc->readL();
	double blue,green,red; //color value 0.0 to 1.0 (This is the actual value that changes the left LED)
	double csB,csG,csR; //color select (select what colors
	static int colorCounter=0;
	static double counterB,counterG,counterR; //color counter

	double bright = 0.2; //set brightness

	if(enc->readBTN()){
		colorCounter++;
		sleep_ms(200);
		if (colorCounter>2){
			colorCounter=0;
		}
	}

	if(colorCounter == 0){ //BLUE
		csB=1.0;
		csG=0.0;
		csR =0.0;

		if (A == 1){
			A = 0;
			counterB = counterB + 1;
			sleep_ms(20);
			A = 0;
		}

		if (B == 1){
			B = 0;
			counterB = counterB - 1;
			sleep_ms(20);
			B = 0;
		}

		blue=counterB/100;

		if(counterB>100){
			counterB=100;
		}
		else if(counterB<0){
			counterB=0;
		}

		a = (int)counterB %10;
		b = (int)(counterB/10)%10;
		c = (int)(counterB/100)%10;
	}

	else if(colorCounter == 1){ //GREEN
		csB=0.0;
		csG=1.0;
		csR =0.0;

		if (A == 1){
			A = 0;
			counterG = counterG + 1;
			sleep_ms(20);
			A = 0;
		}

		if (B == 1){
			B = 0;
			counterG = counterG - 1;
			sleep_ms(20);
			B = 0;
		}

		green=counterG/100;
		if(counterG>100){
			counterG=100;
		}
		else if(counterG<0){
			counterG=0;
		}

		a = (int)counterG %10;
		b = (int)(counterG/10)%10;
		c = (int)(counterG/100)%10;
	}

	else{ //RED
		csB=0.0;
		csG=0.0;
		csR =1.0;
		if (A == 1){
			A = 0;
			counterR = counterR + 1;
			sleep_ms(20);
			A = 0;
		}

		if (B == 1){
			B = 0;
			counterR = counterR - 1;
			sleep_ms(20);
			B = 0;
		}

		red=counterR/100;
		if(counterR>100){
			counterR=100;
		}
		else if(counterR<0){
			counterR=0;
		}

		a = (int)counterR %10;
		b = (int)(counterR/10)%10;
		c = (int)(counterR/100)%10;
	}



	sseg->set_dp(0); //sets decimal point to the third sseg
	sseg->write_1ptn(sseg->h2s(a), 0);
	sseg->write_1ptn(sseg->h2s(b), 1);
	sseg->write_1ptn(sseg->h2s(c), 2);       //convert




	pwm->set_freq(50); //sets freq of pwm

	pwm->set_duty(csB * bright, 0);//0,1,2 control the right LED. This one will only show Blue, Green, and Red one by one
	pwm->set_duty(csG * bright, 1);
	pwm->set_duty(csR * bright, 2);

	pwm->set_duty(blue * bright, 3); //3,4,5 control
	pwm->set_duty(green * bright, 4);
	pwm->set_duty(red * bright, 5);
}


void pmod_test(GpoCore *led_p,PmodCore *enc, SsegCore *sseg_p)
{
//	int data;
//	data=enc->read(0);
//	uart.disp(data);
//	uart.disp("\n\r");
//	sleep_ms(100);

		// ------------- Initialize the pins:
		int A = enc->read(0);
		int B = enc->read(1);
		int btn = enc->read(2);
		int sw = enc->read(3);


		// ------------------------- LEDs indicators
		if (A == 1)
		{
			led_p->write(1,0);
		}
		if (B == 1)
		{
			led_p->write(1,1);
		}
		if(sw == 1)
		{
			led_p->write(1,14);
		}
		if (btn == 1)
		{
			led_p->write(1,15);

		}

		//-------------------------- counter
		static double counter = 0;
		if (A == 1)
		{
			A = 0;
			counter = counter + 1;
			sleep_ms(20);
			A = 0;
		}
		if (B == 1)
		{
			B = 0;
			counter = counter - 1;
			sleep_ms(20);
			B = 0;
		}
		if (btn == 1)                                   // btn = reset the counter
		{
			counter = 0;
		}


		int a,b,c;                                    //holds values of ones, tenths, and hundreths place
		a = (int)counter %10;
		b = (int)(counter/10)%10;
		c = (int)(counter/100)%10;

		sseg_p->set_dp(0); //sets decimal point to the third sseg
		sseg_p->write_1ptn(sseg_p->h2s(a), 0);
		sseg_p->write_1ptn(sseg_p->h2s(b), 1);
		sseg_p->write_1ptn(sseg_p->h2s(c), 2);       //convert hex to sseg values and display in sseg 2







		sleep_ms(40);
		led_p->write(0,0);
		led_p->write(0,1);
		led_p->write(0,14);
		led_p->write(0,15);






		//led_p->write(counter);
		//uart.disp(A);
		//uart.disp("\n\r");
		//sleep_ms(100);


/*		int A_flag = 0;
		int B_flag = 0;
		static int counter = 0;

		int A = enc->read(0);
		int B = enc->read(1);

		if (A == 1)
		{
			A_flag = 1;
		}
		if (B == 1)
		{
			B_flag = 1;
		}

		// -------------------------- flags
		if (A_flag == 1)
		{
			counter += 1;
			A_flag = 0;
		}
		if (B_flag == 1)
		{
			counter -= 1;
			B_flag = 0;
		}



		led_p->write(counter);

		uart.disp(A);
		uart.disp("\n\r");
		sleep_ms(100);*/

/*	    static int lastA = 0;
	    static int lastB = 0;




	    // Only count on changes
	    if (A != lastA || B != lastB)
	    {
	        if (A == 1 && lastA == 0)
	        {
	            counter += 1;
	        }
	        if (B == 1 && lastB == 0) {
	            counter -= 1;
	        }

	        lastA = A;
	        lastB = B;
	    }

	    if (counter == 1)
	    	{
	    		led_p->write(1, 0);
	    	}
	    	if (counter == 2)
	    	{
	    		led_p->write(1, 1);
	    	}
	    	if (counter == 3)
	    	{
	    		led_p->write(1, 2);
	    	}*/





/*	int A = enc->read(0);
	int B = enc->read(1);
	int btn = enc->read(2);
	int SW = enc->read(3);


	//--------------------------- testing A and B
	static int counter = 0;
	if (A == 1)
	{
		counter = counter + 1;
	}
	if (B == 1)
	{
		counter = counter - 1;
	}

	if (counter == 1)
	{
		led_p->write(1, 0);
	}
	if (counter == 2)
	{
		led_p->write(1, 1);
	}
	if (counter == 3)
	{
		led_p->write(1, 2);
	}*/

	//led_p->write(counter);


	//---------------------------- testing the btn and sw --> this works perfectly
/*	if (SW == 1)
	{
		led_p->write(1, 0);
	}

	if (btn == 1)
	{
		led_p->write(1, 1);
	}*/





/*	if(enc->readSW()==1){
		led->write(1,0);
	}
	else{
		led->write(0,0);
	}

	if(enc->readBTN()==1){
		led->write(1,1);
	}

	else{
		led->write(0,1);
	}


	if(enc->readL()==1){
		led->write(1,7);
	}

	else{
		led->write(0,7);
	}

	if(enc->readR()==1){
			led->write(1,8);
	}

	else{
		led->write(0,8);
	}*/

}// end function

GpoCore led(get_slot_addr(BRIDGE_BASE, S2_LED));
GpiCore sw(get_slot_addr(BRIDGE_BASE, S3_SW));
XadcCore adc(get_slot_addr(BRIDGE_BASE, S5_XDAC));
PwmCore pwm(get_slot_addr(BRIDGE_BASE, S6_PWM));
DebounceCore btn(get_slot_addr(BRIDGE_BASE, S7_BTN));
SsegCore sseg(get_slot_addr(BRIDGE_BASE, S8_SSEG));
SpiCore spi(get_slot_addr(BRIDGE_BASE, S9_SPI));
I2cCore adt7420(get_slot_addr(BRIDGE_BASE, S10_I2C));
Ps2Core ps2(get_slot_addr(BRIDGE_BASE, S11_PS2));
DdfsCore ddfs(get_slot_addr(BRIDGE_BASE, S12_DDFS));
AdsrCore adsr(get_slot_addr(BRIDGE_BASE, S13_ADSR), &ddfs);

PmodCore enc(get_slot_addr(BRIDGE_BASE,S4_PMOD));


int main() {
   //uint8_t id, ;

   timer_check(&led);
   while (1) {
	   led_pmod(&led,&pwm,&sseg,&enc);
//	   pmod_test(&led,&enc,&sseg);
//      show_test_id(1, &led);
//      led_check(&led, 16);
//      sw_check(&led, &sw);
//      show_test_id(3, &led);
//      uart_check();
//      debug("main - switch value / up time : ", sw.read(), now_ms());
//      show_test_id(5, &led);
//      adc_check(&adc, &led);
//      show_test_id(6, &led);
//      pwm_3color_led_check(&pwm);
//      show_test_id(7, &led);
//      debounce_check(&btn, &led);
//      show_test_id(8, &led);
//      sseg_check(&sseg);
//      show_test_id(9, &led);
//      gsensor_check(&spi, &led);
//      show_test_id(10, &led);
//      adt7420_check(&adt7420, &led);
//      show_test_id(11, &led);
//      ps2_check(&ps2);
//      show_test_id(12, &led);
//      ddfs_check(&ddfs, &led);
//      show_test_id(13, &led);
//      adsr_check(&adsr, &led, &sw);
   } //while
} //main

