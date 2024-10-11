GPPPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore       			
                                                # parameter defined as 32 bit. Also -no-use-atexit means compiler shouldn't use standard library functions. -fnostdlib means compiler shouldnt use startup files for linking, 
						# -fno-builtin prevents compiler from identifying inbuilt functions like strlen etc, -fno-rtti means operations like dynamic_casting, 
						#  -fno-exceptions disables exception handling of c++, -fno-leading-underscore prevents the compiler from adding an underscore before global symbols
                                                      
ASPARAMS = --32     				# parameter defined as 32 bit
LDPARAMS = -melf_i386 				# this parameter specifies that the file will be in "machine executable and linkable format melf" for intel X386 processor

objects = loader.o kernel.o

%.o: %.cpp                              	# it states to convert cpp file to object file i.e. TARGET FILE <--------- SOURCE FILE
	g++ $(GPPPARAMS) -m32 -o $@ -c $<     	# it means that when encountering the cpp file, g++ compiler should convert to 32 bits output -o object file $@ from source file $< without linking it.
	                 			# The symbol -c means compiling without linking 


%.o: %.s  					# it states to convert the .s assembly file to object file i.e. TARGET FILE <----- SOURCE FILE 
	as $(ASPARAMS) -o $@ $< 		# so when encountering the .s assembly file, assembler "as" compiler should convert into 32 bits -o output object file $@ from source file $<
	                                

mykernel.bin: linker.ld $(objects)		# mykernel.bin file be created using linker.ld file and other object files. linker.ld is linker that takes both above object files to merge into single object file mykernel.bin 
	ld $(LDPARAMS) -T $< -o $@ $(objects)   # link to create linkabbe &executable file from source $< and produce target object file -o as $@. "objects" specifies 2 object files created- loader.o and kernel.o  


install: mykernel.bin
	sudo cp $< /boot/mykernel.bin  		# now here we will save mykernel.bin file at location at boot. Sudo for starting any linux command, "cp" for copy. So command states to copy from source to destination _x_y_z_
	 			

mykernel.iso: mykernel.bin
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp $< iso/boot/
	echo 'set timeout=0' > iso/boot/grub/grub.cfg
	echo 'set default=0' >> iso/boot/grub/grub.cfg
	echo '' >> iso/boot/grub/grub.cfg
	echo 'menuentry "My Operating System"' >> iso/boot/grub/grub.cfg
	echo '{' >> iso/boot/grub/grub.cfg
	echo '	multiboot /boot/mykernel.bin' >> iso/boot/grub/grub.cfg
	echo '	boot' >> iso/boot/grub/grub.cfg
	echo '}' >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=$@ iso
	rm -rf iso

run: mykernel.iso
	(killall VirtualBox && sleep 1) || true
	VirtualBox --startvm "My Operating System" &

