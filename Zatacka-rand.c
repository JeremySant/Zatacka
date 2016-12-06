#include <stdlib.h>
#include <time.h>

/*
By Jeremy Sant
UTORid: santjere
Station 94
*/

//Used to generate the random gaps in P1's line
int random_P1(){
	int r = rand() % 20; //rand from 0 - 19
	if(r == 1){
		return 0;
	}
	return 0xF000;
}

//Used to generate the random gaps in P2's line
int random_P2(){
	int r = rand() % 20; //rand from 0 - 19
	if(r == 1){
		return 0;
	}
	return 0x00FF;
}

//Get a random starting location
int random_start(){
	
	int r = 0x08000804;
	int rX = rand() % 300;
	int rY = rand() % 200;
	r += rX * (0x02);
	r += rY * (0x400);
	return r;
}

//Get a random starting direction (1-4)
int random_start_d(){
	
	int r = rand() % 4;
	
	return r + 1;
}

