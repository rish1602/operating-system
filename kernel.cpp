#include "types.h"

void printf(char* str)
{
	static uint16_t* VideoMemory= (uint16_t*)0xb8000; 
	static uint16_t colorAttribute= 0x07;

	while(*str!=0)
	{
		*VideoMemory= (*str & 0xFF) | (colorAttribute<<8);
		++VideoMemory; 
		++str; 
	}
}

typedef void (*constructor)();
extern "C" constructor start_ctors;
extern "C" constructor end_ctors; 
extern "C" void callConstructors()
{
	for(constructor* i=&start_ctors; i!=&end_ctors; ++i)
		(*i)(); 

}

extern "C" void kernelMain(void* multiboot_structure, uint32_t magicnumber)
{
	printf("Hello World from Rishabh");

	while(true);
}
