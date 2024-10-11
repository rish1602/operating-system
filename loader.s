.set MAGIC, 0x1badb002			# from below section we define MAGIC as hexadecimal address and this address is assigned to kernel bin file so that bootloader can find it	
.set FLAGS, (1<<0 | 1<<1)		# define another variable FLAGS, his FLAG=3
.set CHECKSUM, -(MAGIC+FLAGS)		# define CHECKSUM which is MAGIC + FLAGS and then take 2's complement. This CHECKSUM is for error-checking, should equals 0, ensures all headers in kernel bin file are not corrupted


.section .multiboot			# so here we define a section namely .multiboot. this section gives a name to the kernel-bin file, so that its easy for bootloader to find this file from hard disk & load it
	.long MAGIC			# declare a variable MAGIC
	.long FLAGS			# declare variable FLAGS
	.long CHECKSUM			# declare variable CHECKSUM
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

.section .text   			# this is the start of the text section where the executable code resides. The linker will link these functions present in this section
	.extern kernelMain 		# specifies that externally a function kernelMain() has been defined
	.extern callConstructors
	.global loader

loader:				        # now here we have defined a loader function. In above section .text, we declared it as global function that will be accessible to all the files. Below is the function definition
	mov $kernel_stack, %esp		# move the address of the kernel stack to the stack pointer. MOVE FROM SOURCE---->DESTINATION. This is done so that stack pointer points to the kernel object at stack memory
	call callConstructors
	push %eax			# eax register will store the MAGIC number from above. eax will be pushed in the stack 	
	push %ebx			# ebx register stores pointer to "boot information structure". This boor info structure holds info about the state of the system when kernel starts. ebx will be pushed in the stack  
	call kernelMain			# after pointing to the kernel obj, call kernelMain function @ kernel.cpp

_stop:					# so our kernelMain() in kernel.cpp will run for INFINITE time, but just in case for precaution we declare _STOP section. This section is not necessary to be written
	cli 				# if there are any interrupts, cli will disable them
	hlt				# halt the CPU
	jmp _stop			# again jump to stop and continue. 
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

.section .bss				# this is the start of section bss. This section is used to declare variables. Remember , just to declare them and not initialize them yet.
.space 2*1024*1024			# this will leave space of 2 MB between every stack in memory
kernel_stack:
