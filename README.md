# FreeDOS Boot Disks

The FreeDOS Boot Disks repository contains bootable [FreeDOS](http://www.freedos.org/) diskette images and [boot sectors](https://en.wikipedia.org/wiki/Boot_sector) from those diskettes. The diskette images can be used to boot a simple DOS shell in a virtual machine such as [VirtualBox](https://www.virtualbox.org/) or [QEMU](https://www.qemu.org/), or in a browser with Fabian Hemmer's [v86 x86 emulator](https://github.com/copy/v86). 

This project also contains various utility scripts written for MacOS in bash. Details on those are provided below.

# Plans
  
  * Fix all links in this readme that have empty links
  * Make a script to extract / replace boot sectors
  * Make a script to change volume labels in a boot sector
  * Make a script to create empty image, copy boot sector in place, copy freedos files in place
  * Check in sample
  * Generate the dos images

# Demo

Fabian Hemmer hosts an excellent v86 Demo that demonstrates a number of OS installations such as versions of Windows, different Linux installations, and various DOS versions [here]().

A demo of one of the stripped down diskette images from this project running on v86 is hosted [here]().

# Images

The FreeDOS boot diskette images provided are minimal. They only contain the following: [KERNEL.SYS](http://help.fdos.org/en/hhstndrd/base/kernel.htm), [CONFIG.SYS](http://help.fdos.org/en/hhstndrd/cnfigsys/index.htm), and [COMMAND.COM](http://help.fdos.org/en/hhstndrd/base/command.htm), and they come in differing sizes in case you want to fill the image with a few more programs. 

The [v86 OS image library](https://github.com/copy/images) provides a more robust [720KB FreeDOS bootable image](https://github.com/copy/images/blob/master/freedos722.img) with additional utilities, drivers, and games.

The provided images boot well in v86. I have not taken the time to see if they boot well on other virtualized platforms or on real vintage hardware. 

The diskette images are provided in the src/images directory. They are currently available in these sizes: 160KB, 320KB, 720KB, 1.4MB, and 2.8MB.

If you want, you can customize these image files easily with the [xyz]() script provided in this project, or perhaps run through a virtualized FreeDOS, DOS, Windows, or Linux installation using [QEMU](https://www.qemu.org/) or [VirtualBox](https://www.virtualbox.org/). 

# Boot Sectors

[Boot sectors](https://en.wikipedia.org/wiki/Boot_sector) for each of the FreeDOS .img files mentioned above have been extracted and placed are available in the [boot_sector]() folder of this project.

# Booting in v86

If you're unfamiliar with [v86](https://github.com/copy/v86), it's a x86 javascript emulator that emulates a vintage PC in a browser. v86 provides hardware emulation of floppy disk drives, IDE hard disk drives, sound blaster 16, VGA, PCI and more. 

The author has various Linux, Windows, and DOS demo operating systems running on v86 on his personal host here:

https://copy.sh/v86/

It took a while for me to figure out how to run just his FreeDOS demo image locally without the big demo that requires downloading multiple OS images, here's my source for that:

    <!doctype html>
    <script>
    	//if you want v86 to log debug information, uncomment this line below
    	//var DEBUG = true;
    </script>
    <script src="libv86.js"></script>
    <script>
    	"use strict";
    
    	window.onload = function() {
	    	var emulator = window.emulator = new v86Starter({
	        	memory_size: 32 * 1024 * 1024,
	        	vga_memory_size: 2 * 1024 * 1024,
	        	screen_container: document.getElementById("screen_container"),
	        	bios: { url: "seabios.bin", },
	        	vga_bios: { url: "vgabios.bin", },
	        	fda: { "url": "myfloppy.img", },
	        	autostart: true,
    	    });
    	}
    </script>
    
    <div id="screen_container">
        <div style="white-space: pre; font: 14px monospace; line-height: 14px"></div>
        <canvas style="display: none"></canvas>
    </div>

A few notes on the sample shown above:

 * This sample, complete with the seabios.img, vgabios.img, libv86.js, and myfloppy.img is provided in the [sample]() directory of this project.
 * You won't be able to run the example above by simply opening the html file from disk in your browser. Instead, you will need to run a http webserver on your machine. The easiest way to run a server on your machine is to run the following python command in the directory you want to server the html and img files from:

    python -m SimpleHTTPServer 8070

 * The above example will host a [web server](https://en.wikipedia.org/wiki/Web_server) on your machine on port 8070. If you start the webserver in the [sample]() folder of this project, the url to fetch the sample.html will be:

     http://localhost:8080/sample.html

 * Other popular [web server](https://en.wikipedia.org/wiki/Web_server) options to consider are [Apache](https://httpd.apache.org/), [NGINX](https://www.nginx.com/), a [LAMP](https://en.wikipedia.org/wiki/LAMP_(software_bundle)) stack (which includes apache as the webserver portion of the stack), [Tomcat](http://tomcat.apache.org/), or [Geronimo](http://geronimo.apache.org/). More webserver options are listed [here](https://en.wikipedia.org/wiki/Comparison_of_web_server_software). 
 * The seabios.bin and vgabios.bin images came from the v86 github project [here](https://github.com/copy/v86/tree/master/bios).
 * If you prefer, you can build the libv86.js file by cloing the v86 project from github. And [building it](https://github.com/copy/v86#how-to-build-run-and-embed) yourself. 
 * Cloning the v86 library locally also contains non-minimalized debug run mode when if you run from the v86 source.
 * You can easily provide more images for emulated hard drives and cdroms using the v86 api with params such as "hda" and "cdrom". The cd-rom images can be (or must be?) in .iso format.
 * The v86 API has a bunch of other options, those are documented [here](https://github.com/copy/v86/blob/master/docs/api.md) and [here](https://github.com/copy/v86).

# Bugs / Possible Problems

I'm not a vintage hardware guru, so I would not be surprised if the images I've hacked together have issues in the boot sectors such as:

 * Sector sizes might be unrealistic for real diskettes. For example, all of the images and boot sectors here specify a sector size of 512 bytes. I have not done the research to figure out if a 160KB diskette had a different sector size than a 1.4MB diskette typically had. 

 * Sectors Per Track / Sectors Per Cylinder specifications may be unrealistic for real diskettes. The provided boot sectors and images have left these values in the original state from the source image provided by the v86 project. 

 If you want to edit sector sizes, sector counts, volume names, cylinder counts, or track counts, I recommend the following resources: 

  * [MS Dos 5.0 Boot Sector Reference](https://thestarman.pcministry.com/asm/mbr/DOS50FDB.htm)
  * [Decimal To Hex Converter](https://www.rapidtables.com/convert/number/decimal-to-hex.html?x=320)
  * [Hex Editor for MacOS]()

# Resources

Boot process resources: 

 * [Boot Records Reference - VERY good.](https://thestarman.pcministry.com/asm/mbr/index.html)
 * [MBR and VBR Specifics](https://superuser.com/questions/1149657/mbr-and-vbr-specifics)
 * [Overview of MBR boot process](https://neosmart.net/wiki/mbr-boot-process/)  
 * [MBR Fix Guide for Various Windows Versions](https://neosmart.net/wiki/fix-mbr/)
 * [More MBR Tools](https://thestarman.pcministry.com/asm/mbr/BootToolsRefs.htm)
 * [Boot Sector Tools for Windows](https://www.raymond.cc/blog/5-free-tools-to-backup-and-restore-master-boot-record-mbr/)
 * [Wikipedia's List Of Floppy Disk Formats](https://en.wikipedia.org/wiki/List_of_floppy_disk_formats)
 
 Open-source / Free DOS distributions:

* [DOSBox](https://www.dosbox.com/)
* [FreeDOS](http://www.freedos.org/)
* [MS-DOS 1.25 & 2.0](https://github.com/Microsoft/MS-DOS)
 
Tools: 

 * [FreeDOS](http://www.freedos.org/)
 * [NANSI.SYS](http://help.fdos.org/en/hhstndrd/base/nansi.htm) - Make your prompt different colors in FreeDOS.
 * [Ansi Color Guide](https://kb.iu.edu/d/aamm)
 * [VirtualBox](https://www.virtualbox.org/) - Free OS virtualization platform.
 * [QEMU](https://www.qemu.org/) - Another free OS virtualization platform.
 * [Win World](https://winworldpc.com/home) - Old OS (Windows 3.1, 9x, Dos, and more) installation files and old software (Turbo Pascal, WordStar, etc)
 * [Old Version](http://www.oldversion.com/) - Archive of many old versions for various retro and current software such as WinAmp, FireFox, and more.

Javascript x86 Emulation:

* [js-dos](https://js-dos.com/) - x86 javascript emulator tailored for converting and running dos games in browser.
* [em-dosbox](https://github.com/dreamlayers/em-dosbox)
* [v86](https://github.com/copy/v86)
* [asm.js](http://asmjs.org/)
* [WebAssembly](https://webassembly.org/)
* [emscripten](https://github.com/kripken/emscripten) - LLVM (C/C++) to JS compiler

Further Resources:

* [v86 image creation tips for QEMU](https://github.com/copy/v86/issues/128)
* [FreeDOS on QEMU Installation Guide](http://how-to.wikia.com/wiki/How_to_install_FreeDOS_in_QEMU)
* [Booting QEMU from a Floppy Image](https://stackoverflow.com/questions/19961095/os-development-booting-from-floppy-drive-using-qemu)
* [Creating A Minimal Boot Sector For v86](https://blog.benjdoherty.com/2017/08/07/Writing-a-minimal-boot-sector-for-the-v86-emulator/)
* [archive.org's free dos game library](https://archive.org/details/softwarelibrary_msdos_games?) - powered by em-dosbox
 
# Trivia

While building this project, I learned a lot about bootable diskettes. It was not trivial for me to piece together how a vintage bootable diskette is created on modern hardware, or how the boot process works in general. I'm providing these bits of trivia and details in hopes that it will help others looking for understanding:

A bootable hard drive has several parts to it. The very first sector on the disk is called a [boot sector](https://en.wikipedia.org/wiki/Boot_sector). The boot sector is 512 bytes long and contains the [Master Boot Record](https://en.wikipedia.org/wiki/Master_boot_record) (aka MBR). The drive itself contains one or more [partitions](https://en.wikipedia.org/wiki/Disk_partitioning), which is a section of the drive that is mapped to a logical drive on your computer. A drive can have multiple partitions on it, but there's usually just one partition. 

When you create a [file system](https://en.wikipedia.org/wiki/File_system) on a partition by formatting a partition on a drive with Windows Explorer or MacOs' Disk Utility, the tools will ask you how large you want a partition to be. For example, you could create a 50GB partition and a 150GB partition on a 200GB drive. 

Consumer laptops often ship with a drive that has multiple partitions on it, the first being a read-only "[recovery partition](https://computers.tutsplus.com/tutorials/the-os-x-recovery-partition-what-it-is-why-its-there-and-how-to-remove-it--mac-31796)" that's used to reinstall the OS, and the second being the main partition used to house the OS and your files. 

When someone dual-boots a machine, there can either be two (or more) physical hard disks in the system with one partition per drive, or two partitions on a single drive. [Boot Camp](https://en.wikipedia.org/wiki/Boot_Camp_(software)) for MacOS does just this, it creates a second partition on your hard drive and formats it in a format that Windows understands (such as [ExFAT](https://en.wikipedia.org/wiki/ExFAT)), while keeping the primary partition on the drive formatted in [APFS](https://en.wikipedia.org/wiki/Apple_File_System) or some other format that MacOS recognizes and boots from. When the machine boots, one of the partitions on the primary drive is marked as 'active', meaning that's the partition for the BIOS to jump to and start loading the OS from. Boot managers that help with dual booting a machine into multiple operating systems simply switch which partition is marked as active, then boots the machine to that partition (I think.. maybe the boot manager is actually on a third partition and the third partition is always marked as active, with the Boot Manager program tricking the OS into booting from another partition when the user selects which OS they want to boot).

When the computer boots, or a new drive is attached to the computer, partitions are mapped to [logical drives](https://en.wikipedia.org/wiki/Logical_disk), such as a "C:" or "D:" drive on a Windows Machine. On linux/MacOS systems the drive's partitions will be mapped to filesystem abstractions such as /dev/disk1s1 and dev/disk1s2. For linux/MacOS terminal fans, the logical volume versions of the the partitions will be mounted under the /Volumes directory, for example: /Volumes/MYDRIVE.

When an external drive, cdrom, usb stick, or sd card is plugged into the machine, the drive will popup in Finder (on Macos) or Explorer (on Windows) with the volume labels such as MYDRIVE mentioned above. Under the covers on a linux or MacOS system, the OS is automatically doing two operations to make the volume available: attaching and mounting the drive. 

When a drive is attached but not mounted, it can be fully erased, reformated, or byte-for-byte copied to another disk or an image file using the unix [dd](http://man7.org/linux/man-pages/man1/dd.1.html) command. The dd program differs from [cp](http://man7.org/linux/man-pages/man1/cp.1.html) in that it copies every single byte from the disk, meaning it will copy every sector from the disk, including boot sectors, partition information, FAT information, empty space, every file and folder in their current state (including their exact fragmentation across different sectors on disk, and even 'deleted' file data on the disk where the file has merely been removed from the FAT but the bytes of the file are not securely erased by writing zeros or random data over the file's contents on disk). The dd command is often used when attempting to recover a faulty or failing disk that's mounting incorrectly or has a corrupted FAT. 

The [df](https://linux.die.net/man/1/df) command on Linux and MacOS machines can be used to view information about the attached and mounted disks in your system. In this example below, I provide the -h switch to the df command, so the command prints out the drive capacity and free space in a human legible summarized format such as 1GB rather than 1073741824 bytes:

    jbmbpro2014:dist jason$ df -h
    
    Filesystem      Size   Used  Avail Capacity iused               ifree %iused  Mounted on
    /dev/disk1s1   234Gi  192Gi   39Gi    84% 1633783 9223372036853142024    0%   /
    /dev/disk1s4   234Gi  2.0Gi   39Gi     5%       2 9223372036854775805    0%   /private/var/vm
    /dev/disk1s3   234Gi  495Mi   39Gi     2%      14 9223372036854775793    0%   /Volumes/Recovery


The [dd](http://man7.org/linux/man-pages/man1/dd.1.html) command can also be used to create an empty zeroed-out .img file like so:

dd if=/dev/zero of=myimage.img bs=512 count=1440

With the example above, we're specify that the .img file is filled with zeroes (copied from /dev/zero, which when read, will always return zeros). The created .img file has 512 byte sectors, and it has 1440 sectors. A kilobyte is 1024 bytes, so two sectors form a kilobyte. When we divide 1440 by 2, we get 720 - so a 1440 sector 512 byte per sector disk is 720KB, which is one common disk size for floppy disks. 

Early [floppy disks came in sizes](https://en.wikipedia.org/wiki/Floppy_disk#Sizes) of 160KB and later disks regularly came in a 1.44MB size. v86 supports a few common floppy disk sizes, those are found in the [floppy.js](https://github.com/copy/v86/blob/master/src/floppy.js) file:

    var floppy_types = {
    	160  : { type: 1, tracks: 40, sectors: 8 , heads: 1 },
    	180  : { type: 1, tracks: 40, sectors: 9 , heads: 1 },
    	200  : { type: 1, tracks: 40, sectors: 10, heads: 1 },
    	320  : { type: 1, tracks: 40, sectors: 8 , heads: 2 },
    	360  : { type: 1, tracks: 40, sectors: 9 , heads: 2 },
    	400  : { type: 1, tracks: 40, sectors: 10, heads: 2 },
    	720  : { type: 3, tracks: 80, sectors: 9 , heads: 2 },
    	1200 : { type: 2, tracks: 80, sectors: 15, heads: 2 },
    	1440 : { type: 4, tracks: 80, sectors: 18, heads: 2 },
    	1722 : { type: 5, tracks: 82, sectors: 21, heads: 2 },
    	2880 : { type: 5, tracks: 80, sectors: 36, heads: 2 },
    };

More details on floppy disk formats are listed on [Wikipedia's List Of Floppy Disk Formats](https://en.wikipedia.org/wiki/List_of_floppy_disk_formats).

A floppy diskette does not have a MBR, but instead has a [Volume Boot Record](https://en.wikipedia.org/wiki/Volume_boot_record) (VBR). I'm a little confused on the difference between a MBR and a VBR, but my basic understanding is that a MBR is used on devices like hard disks that support partitions or multiple partitions, and a VBR is used on storage mediums without partitions (such as floppy diskettes). 

The bootable FreeDOS diskettes provided in this project are FAT12 format, because that's what the original v86 floppy image was formatted in. I think later boot disk formats for Windows, Linux, and other operating systems were not necessarily FAT12, as the MBR/VBR generally has a jump command that points to some x86 instructions to first run a disk driver, which is a program that reads FAT information from a drive and controls organizing, reading, and writing files and folders. 

There are a number of other useful commands for image creation, partitioning, and formatting in Linux/MacOS that can be used in a terminal: 

 * [Managing Linux Partitions With fdisk](https://www.tecmint.com/fdisk-commands-to-manage-linux-disk-partitions/)
 * [Another fdisk Reference](https://www.linkedin.com/pulse/how-create-partition-using-fdisk-man-linux-sanjay-kumar/)
 * [newfs_msdos](https://www.freebsd.org/cgi/man.cgi?query=newfs_msdos&apropos=0&sektion=0&manpath=FreeBSD+5.2-RELEASE&format=html)
 * [dd](http://man7.org/linux/man-pages/man1/dd.1.html)
 * [Using dd to save/restore a boot sector](https://unix.stackexchange.com/questions/252509/using-dd-in-order-to-save-and-restore-a-boot-sector)
 * [df](https://linux.die.net/man/1/df)
 * [hdiutil](https://ss64.com/osx/hdiutil.html)
 * [Disk Utility](https://en.wikipedia.org/wiki/Disk_Utility) and the terminal version [diskutil](https://ss64.com/osx/diskutil.html)


This is all my very high-level novice understanding of how MBRs, VBRs, boot sectors, partitions, and file system formats work. There are a number of resources listed above that go into much greater detail, with much greater authority than I possess. In particular, be sure to check out [Boot Records Revealed](https://thestarman.pcministry.com/asm/mbr/index.html) with extremely detailed information about the byte-level breakdown of various boot sector formats. 

Note that there's more trivia and gotchas document inside the script files contained within this project.

# Purpose

These images were created while working on a [book](http://www.happyacro.com) about vintage computing and the insanity associated with a software engineering career. While writing the book, emulated operating systems in a browser were in vogue, and I wanted to create a nostalgic browser-based DOS experience to advertise the book. I found the [v86 library](https://github.com/copy/v86). The sample FreeDOS image provided with v86 is a 720KB diskette that includes a few programs and tools that I was not interested in providing on my book's site, so I went on a quest to strip the diskette image file down in size. In that quest, I sought a way to recreate a bootable diskette with an arbitrary size via a script that would not require manually clicking through a FreeDOS installation wizard or changing the original source diskette image, and I realized there weren't any incredibly straight forward resources for creating a minimal bootable FreeDOS diskette image, so here we are. 


# Credit

 * Fabian Hemmer's [v86](https://github.com/copy/v86) and his original [FreeDOS diskette image](https://github.com/copy/images/blob/master/freedos722.img) that I used to seed this project's images. 
 * Thanks to [David Anderson](https://apple.stackexchange.com/users/107222/david-anderson) for helping me understand the difference between MBR and VBR, and providing example code to extract the boot sector from one image and stick it into another in [this Stack Overflow thread](https://apple.stackexchange.com/questions/338718/creating-bootable-freedos-dos-floppy-diskette-img-file-for-v86-on-osx).
 * [MS Dos 5.0 Boot Sector Reference](https://thestarman.pcministry.com/asm/mbr/DOS50FDB.htm)
 * [FreeDOS](http://www.freedos.org/)
 * The [Hex Fiend](https://ridiculousfish.com/hexfiend/) hex editor for MacOS was used to verify and troubleshoot this project's boot sectors.


# License

All scripts are licensed with the [Apache license](http://en.wikipedia.org/wiki/Apache_license), which is a great license because, essentially it:

* a) covers liability - my code should work, but I'm not liable if you do something stupid with it
* b) allows you to copy, fork, and use the code, even commercially
* c) is [non-viral](http://en.wikipedia.org/wiki/Viral_license), that is, your derivative code doesn't *have to be* open source to use it

Other great licensing options for your own code: [BSD License](https://en.wikipedia.org/wiki/BSD_licenses), [MIT License](https://en.wikipedia.org/wiki/MIT_License), or [Creative Commons](https://en.wikipedia.org/wiki/Creative_Commons_license).

Here's the license:

Copyright (c) 2018, Coder Cowboy, LLC. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* 1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
  
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied.
