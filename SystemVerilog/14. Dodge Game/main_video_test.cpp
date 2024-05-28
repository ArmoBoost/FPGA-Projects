/*****************************************************************//**
 * @file main_video_test.cpp
 *
 * @brief Basic test of 4 basic i/o cores
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

//#define _DEBUG
#include "chu_init.h"
#include "gpio_cores.h"
#include "vga_core.h"
#include "sseg_core.h"
#include "ps2_core.h"
#include "xadc_core.h"
#include <cstdlib> //for random num

void test_start(GpoCore *led_p) {
   int i;

   for (i = 0; i < 20; i++) {
      led_p->write(0xff00);
      sleep_ms(50);
      led_p->write(0x0000);
      sleep_ms(50);
   }
}

/**
 * check bar generator core
 * @param bar_p pointer to Gpv instance
 */
void bar_check(GpvCore *bar_p) {
   bar_p->bypass(0);
   sleep_ms(3000);
}

/**
 * check color-to-grayscale core
 * @param gray_p pointer to Gpv instance
 */
void gray_check(GpvCore *gray_p) {
   gray_p->bypass(0);
   sleep_ms(3000);
   gray_p->bypass(1);
}

/**
 * check osd core
 * @param osd_p pointer to osd instance
 */
void osd_check(OsdCore *osd_p) {
   osd_p->set_color(0x0f0, 0x001); // dark gray/green
   osd_p->bypass(0);
   osd_p->clr_screen();
   for (int i = 0; i < 64; i++) {
      osd_p->wr_char(8 + i, 0, i);
      osd_p->wr_char(8 + i, 1, 64 + i, 1);
      sleep_ms(100);
   }
   sleep_ms(3000);
}

/**
 * test frame buffer core
 * @param frame_p pointer to frame buffer instance
 */
void frame_check(FrameCore *frame_p) {
   int x, y, color;

   frame_p->bypass(0);
   for (int i = 0; i < 10; i++) {
      frame_p->clr_screen(0x008);  // dark green
      for (int j = 0; j < 20; j++) {
         x = rand() % 640;
         y = rand() % 480;
         color = rand() % 512;
         frame_p->plot_line(400, 200, x, y, color);
      }
      sleep_ms(300);
   }
   sleep_ms(3000);
}

/**
 * test ghost sprite
 * @param ghost_p pointer to mouse sprite instance
 */
void mouse_check(SpriteCore *mouse_p) {
   int x, y;

   mouse_p->bypass(0);
   // clear top and bottom lines
   for (int i = 0; i < 32; i++) {
      mouse_p->wr_mem(i, 0);
      mouse_p->wr_mem(31 * 32 + i, 0);
   }

   // slowly move mouse pointer
   x = 0;
   y = 0;
   for (int i = 0; i < 80; i++) {
      mouse_p->move_xy(x, y);
      sleep_ms(50);
      x = x + 4;
      y = y + 3;
   }
   sleep_ms(3000);
   // load top and bottom rows
   for (int i = 0; i < 32; i++) {
      sleep_ms(20);
      mouse_p->wr_mem(i, 0x00f);
      mouse_p->wr_mem(31 * 32 + i, 0xf00);
   }
   sleep_ms(3000);
}

/**
 * test ghost sprite
 * @param ghost_p pointer to ghost sprite instance
 */
void ghost_check(SpriteCore *ghost_p) {
   int x, y;

   // slowly move mouse pointer
   ghost_p->bypass(0);
   ghost_p->wr_ctrl(0x1c);  //animation; blue ghost
   x = 0;
   y = 100;
   for (int i = 0; i < 156; i++) {
      ghost_p->move_xy(x, y);
      sleep_ms(100);
      x = x + 4;
      if (i == 80) {
         // change to red ghost half way
         ghost_p->wr_ctrl(0x04);
      }
   }
   sleep_ms(3000);
}

//holds player1 and player2 x-cords
struct playerPos{
	int p1_x;
	int p2_x;
};

//controls both players movement. A&D buttons for P1. L&J for player2
playerPos playerMovement(SpriteCore *player1,SpriteCore *player2, Ps2Core *ps2, bool restart ){
	int y =460; //x=620 and y = 460 is bottom right of screen
	char ch;
	//y=460; // y can stay the same since there is no jumping
	static int x1 = 140; //starting positions for players
	static int x2 = 485;
	playerPos x_cords; //initalize struct that saves players x cords
	x_cords.p1_x=x1; //save x value for p1 in struct
	x_cords.p2_x=x2; //save x value for p2 in struct
	   // slowly move mouse pointer
	player1->bypass(0); //turns on the player sprite
    player2->bypass(0);
	player1->wr_ctrl(0x1c);  //animation; blue ghost
	if(restart){
		x1=140;
		x2=485;
	}

	if(ps2->get_kb_ch(&ch)){
		if(ch == 'd'){
			x1=x1+6;
		}

		else if(ch=='a'){
			x1=x1-6;
		}

		else if (ch =='l'){
			x2=x2+6;
		}

		else if (ch == 'j'){
			x2=x2-6;
		}


	 }

////Keep Players in Bounds
	 if(x1<140){
		 x1=140;
	 }

	 if(x1>485){
		 x1=485;
	 }

	 if(x2<140){
		 x2=140;
	 }

	 if(x2>485){
		 x2=485;
	 }
////

////Updated Player Position
	 player1->move_xy(x1, y);
	 player2->move_xy(x2, y);
////

	 return x_cords;

}


//struct holds barrels x and y cords
struct barrelPos{
	int x;
	int y;
};

//moves the barrel down
barrelPos barrelThrow(SpriteCore *barrel, bool restart, XadcCore *adc){
	static int y=0; //x=620 and y = 460 is bottom right of screen
	static double counter = 0;
	static int random_num =256;
	barrelPos barrel_pos;
	double barSpeed=adc->read_adc_in(0);
	//barSpeed=(barSpeed*1000)+100;
	barSpeed = 100;
	if(restart){
		y=0;
		counter = 0;
		random_num = 256;
	}

	barrel->bypass(0); //turns on the barrel sprite

	counter++;
	if(counter>barSpeed){ //increase counter value for slower speed // 2000 med speed
		y=y+6;
		counter=0;
	}

	if(y>480){
		y=0;
		random_num = 140 + rand() % (486-140);
	}

//	uart.disp("barrel Counter:");
//	      uart.disp(random_numer);
//	      uart.disp("\n\n\r");


	barrel_pos.x=random_num;
	barrel_pos.y=y;
	barrel->move_xy(random_num, y);
	return barrel_pos;



}

//Checks if players hit a barrel and prints on UART
int printHit(playerPos playerPos,barrelPos barrelPos){
	if(barrelPos.x >= playerPos.p1_x -20 && barrelPos.x <= playerPos.p1_x +20){
		if(barrelPos.y >=460){
//			uart.disp("HIT Player 1");
//			uart.disp("\n\n\r");
			return 1;
		}
	}

	if(barrelPos.x >= playerPos.p2_x -20 && barrelPos.x <= playerPos.p2_x +20){
		if(barrelPos.y >=460){
//			uart.disp("HIT Player 2");
//			uart.disp("\n\n\r");
			return 2;
		}
	}

	return 0;
}

bool start_menu (FrameCore *frame_p , OsdCore *osd_p, Ps2Core *ps2_p)
{
		char ch;

		frame_p->plot_line(220, 140, 420, 140, 300);         // Top line   x = 220 - 420  y = 140
		frame_p->plot_line(220, 340, 420, 340, 300);         // bottom line  x = 220 - 420 y = 340
		frame_p->plot_line(220, 140, 220, 340, 300);         // right line x = 220  y = 140 - 340
		frame_p->plot_line(420, 140, 420, 340, 300);         // left line x = 420 y = 140 - 340

		// ------------------------ display welcome message
		osd_p->set_color(0xf00, 0); //Text Color, Background Color

		// osd_p->wr_char(x , y, ch);
		osd_p->wr_char(35 , 10, 83);    // S      // START MENU
		osd_p->wr_char(36 , 10, 84);    // T
		osd_p->wr_char(37 , 10, 65);    // A
		osd_p->wr_char(38 , 10, 82);    // R
		osd_p->wr_char(39 , 10, 84);    // T

		osd_p->wr_char(41 , 10, 77);    // M
		osd_p->wr_char(42 , 10, 69);    // E
		osd_p->wr_char(43 , 10, 78);    // N
		osd_p->wr_char(44 , 10, 85);    // U

		osd_p->wr_char(32 , 12, 67);    // C        CLICK S TO START
		osd_p->wr_char(33 , 12, 76);    // L
		osd_p->wr_char(34 , 12, 73);    // I
		osd_p->wr_char(35 , 12, 67);    // C
		osd_p->wr_char(36 , 12, 75);    // K

		osd_p->wr_char(38 , 12, 83);    // S

		osd_p->wr_char(40 , 12, 84);    // T
		osd_p->wr_char(41 , 12, 79);    // O

		osd_p->wr_char(43 , 12, 83);    // S
		osd_p->wr_char(44 , 12, 84);    // T
		osd_p->wr_char(45 , 12, 65);    // A
		osd_p->wr_char(46 , 12, 82);    // R
		osd_p->wr_char(47 , 12, 84);    // T

		osd_p->wr_char(40 , 15, 83);    // S

		frame_p->plot_line(310, 230, 335, 230, 300);    // top                 x = 310 - 335  y = 230
		frame_p->plot_line(310, 260, 335, 260, 300);    // bottom              x = 310 - 335  y = 260
		frame_p->plot_line(310, 230, 310, 260, 300);    // right               x = 310        y = 230 - 260
		frame_p->plot_line(335, 230, 335, 260, 300);    // left                x = 335        y = 230 - 260

		if (ps2_p->get_kb_ch(&ch))
		{
			if(ch=='s' || ch == 'S'){
				return false;
			}

			else{
				return true;
			}
		}

		return true;
} // end function

int playerScore(OsdCore *osd,int hit, bool restart){
	static int p1_health =3;
	static int p2_health=3;
	static int p1Counter=0;
	static int p2Counter=0;

	if (restart){
		p1_health =3;
		p2_health=3;
		p1Counter=0;
		p2Counter=0;
	}

//////PLAYER 1 SECTION
	osd->wr_char(1,1,80);//P
	osd->wr_char(2,1,49);//1
	osd->wr_char(3,1,32);//space

	osd->wr_char(4,1,76);//L
	osd->wr_char(5,1,73);//I
	osd->wr_char(6,1,86);//V
	osd->wr_char(7,1,69);//E
	osd->wr_char(8,1,83);//S
	osd->wr_char(9,1,58);//:

	//While player is inside the barrel, subtract health and start counting p1Counter up
	//When the player is no longer inside the barrel bounds (hit ==0), and reset counter
	if(hit==1){//player 1 is hit
		if(p1Counter==0){
			p1_health--;
		}
		p1Counter++;

	}

	else if(hit==0){
		if (p1Counter > 0){
			p1Counter=0;
		}
	}

	if(p1_health == 3){
		osd->wr_char(10,1,51);//3
	}


	else if(p1_health == 2){
		osd->wr_char(10,1,50);//2
	}

	else if(p1_health ==1){
		osd->wr_char(10,1,49);//1
	}

	else if(p1_health == 0){
		osd->wr_char(10,1,48);//0
	}

	else{
		return 2;
	}
////////////END OF PLAYER 1 SECTION


//////PLAYER 2 SECTION
		osd->wr_char(69,1,80);//P
		osd->wr_char(70,1,50);//2
		osd->wr_char(71,1,32);//space

		osd->wr_char(72,1,76);//L
		osd->wr_char(73,1,73);//I
		osd->wr_char(74,1,86);//V
		osd->wr_char(75,1,69);//E
		osd->wr_char(76,1,83);//S
		osd->wr_char(77,1,58);//:

		//While player is inside the barrel, subtract health and start counting p1Counter up
		//When the player is no longer inside the barrel bounds (hit ==0), and reset counter
		if(hit==2){//player 2 is hit
			if(p2Counter==0){
				p2_health--;
			}
			p2Counter++;

		}

		else if(hit==0){
			if (p2Counter > 0){
				p2Counter=0;
			}
		}

		if(p2_health == 3){
			osd->wr_char(78,1,51);//3
		}


		else if(p2_health == 2){
			osd->wr_char(78,1,50);//2
		}

		else if(p2_health ==1){
			osd->wr_char(78,1,49);//1
		}

		else if(p2_health == 0){
			osd->wr_char(78,1,48);//0
		}

		else{
			return 1;
		}
	////////////END OF PLAYER 2 SECTION




	return 0;
}

void winGame(OsdCore *osd, int winner){
	if(winner==1){
		osd->wr_char(36,1,80);//P
		osd->wr_char(37,1,49);//1
		osd->wr_char(38,1,32);//space

		osd->wr_char(39,1,87);//W
		osd->wr_char(40,1,73);//I
		osd->wr_char(41,1,78);//N
		osd->wr_char(42,1,83);//S
		osd->wr_char(43,1,33);//!

	}

	else{
		osd->wr_char(36,1,80);//P
		osd->wr_char(37,1,50);//2
		osd->wr_char(38,1,32);//space

		osd->wr_char(39,1,87);//W
		osd->wr_char(40,1,73);//I
		osd->wr_char(41,1,78);//N
		osd->wr_char(42,1,83);//S
		osd->wr_char(43,1,33);//!
		}

	osd->wr_char(31,3,80);//P
	osd->wr_char(32,3,82);//R
	osd->wr_char(33,3,69);//E
	osd->wr_char(34,3,83);//S
	osd->wr_char(35,3,83);//S
	osd->wr_char(36,3,32);//space
	osd->wr_char(37,3,82);//R
	osd->wr_char(38,3,32);//space
	osd->wr_char(39,3,84);//T
	osd->wr_char(40,3,79);//O
	osd->wr_char(41,3,32);//space
	osd->wr_char(42,3,82);//R
	osd->wr_char(43,3,69);//E
	osd->wr_char(44,3,83);//S
	osd->wr_char(45,3,84);//T
	osd->wr_char(46,3,65);//A
	osd->wr_char(47,3,82);//R
	osd->wr_char(48,3,84);//T




}

// external core instantiation
GpoCore led(get_slot_addr(BRIDGE_BASE, S2_LED));
GpiCore sw(get_slot_addr(BRIDGE_BASE, S3_SW));
FrameCore frame(FRAME_BASE);
GpvCore bar(get_sprite_addr(BRIDGE_BASE, V7_BAR));
GpvCore gray(get_sprite_addr(BRIDGE_BASE, V6_GRAY));
SpriteCore ghost(get_sprite_addr(BRIDGE_BASE, V3_GHOST), 1024);
SpriteCore mouse(get_sprite_addr(BRIDGE_BASE, V1_MOUSE), 1024);
SpriteCore ghost2(get_sprite_addr(BRIDGE_BASE, V4_THROW), 1024);//NEW VGA CORE. Replaced USER4
OsdCore osd(get_sprite_addr(BRIDGE_BASE, V2_OSD));
SsegCore sseg(get_slot_addr(BRIDGE_BASE, S8_SSEG));
Ps2Core ps2(get_slot_addr(BRIDGE_BASE, S11_PS2));
XadcCore adc(get_slot_addr(BRIDGE_BASE, S5_XDAC));

int main() {
	ghost.bypass(1);
	ghost2.bypass(1);
    frame.bypass(1);
    bar.bypass(1);
    gray.bypass(1);
    osd.bypass(1);
    mouse.bypass(1);
	frame.bypass(0); //turn on background
	frame.clr_screen(0x0008);  // dark green
	osd.bypass(0);
	bool menu = true;
	bool gameStart =false;
	int playerHit;
	int winner=0;
	bool restart;
	char ch;
   while (1) {
	   if(menu){
		   menu=start_menu(&frame,&osd,&ps2);
	   }
	   else{
		   if(!gameStart){
			   //osd.bypass(1);
			   osd.clr_screen();
			   osd.set_color(0x0f0,0x001);
			   frame.clr_screen(0x00F); //blue
			   for(int i = 120;i<140;i++){
				   frame.plot_line(i, 0, i, 480, 0);         // Top line   x = 220 - 420  y = 140
			   }

			   for(int i = 520; i>500;i--){
				   frame.plot_line(i, 0, i, 480, 0);         // Top line   x = 220 - 420  y = 140
			   }
			   gameStart=true;
			   restart = true;
		   }
		   playerPos x_cords=playerMovement(&ghost,&ghost2,&ps2,restart);//playerMovement
		   barrelPos bar_cor = barrelThrow(&mouse,restart,&adc);//barrel movement
		   playerHit=printHit(x_cords,bar_cor);//hit detection
		   winner=playerScore(&osd,playerHit,restart);
		   restart =false;
		   while(!winner==0){
			   winGame(&osd,winner);
			   if(ps2.get_kb_ch(&ch)){
				   if(ch=='r' || ch == 'R'){
					   winner=0;
					   menu =true;
					   gameStart = false;
					   osd.clr_screen();
					   frame.clr_screen(0x0008);
					   ghost.bypass(1);
					   ghost2.bypass(1);
					   mouse.bypass(1);
				   }
			   }
		   }
	   }

//NOTE: Using UART in main or barrel throw function SIGNIFICANTLY SLOWS the drop rate of
//the barrel. If using UART, set barrelSpeed to 1. If not, set to 2000
//      uart.disp("x1:");
//      uart.disp(x_cords.p1_x); //displays player 1 x cords
//      uart.disp("\n\n\r");
//      uart.disp("x2:");
//      uart.disp(x_cords.p2_x); //displays player 2 y cords
//      uart.disp("\n\r");
   } // while
} //main
