# freedosbootdisks

The FreeDos Boot Disks repository contains bootable FreeDOS diskette images and boot sectors from those diskettes. The diskette images can be used to boot a simple DOS shell in a virtual machine such as VirtualBox or QEMU, or in a browser with V86. 

This project also contains various utility scripts written for MacOS (OSX) in bash. Details on those are provided below.

# Images

The images provided are minimal. They only contain the following: KERNEL.SYS, CONFIG.SYS, and COMMAND.COM, and they come in differing sizes in case you want to fill the image with a few more programs. 

The V86 image library provides a more robust 720KB FreeDOS bootable image with additional utilities, drivers, and games.

//TODO: All images contain FreeDOS vx.y.z.

The provided images boot well in V86. I have not taken the time to see if they boot well on other virtualized platforms or on real vintage hardware. 

The diskette images are provided in the src/images directory. They are currently available in these sizes:

//TODO: 

If you want, you can customize these image files easily with the xyz script provided in this project, or perhaps run through a virtualized FreeDOS, DOS, Windows, or Linux installation using QEMU or VirtualBox. 

# Boot Sectors

# Booting in V86

If you're unfamiliar with V86, it's a x86 javascript emulator that emulates a vintage PC in a browser. V86 provides hardware emulation of floppy disk drives, IDE hard disk drives, sound blaster 16, VGA, PCI and more. 

The author has various Linux, Windows, and DOS demo operating systems running on v86 on his personal host here:

https://copy.sh/v86/

It took a while for me to figure out how to run just his FreeDOS demo image locally without the big demo that requires downloading multiple OS images, here's my source for that:

    <!doctype html>
    <script>
    	//if you want V86 to log debug information, uncomment this line below
    	//var DEBUG = true;
    </script>
    <script src="libv86.js"></script>
    <script>
    	"use strict";
    
    	window.onload = function() {
    	    	var emulator = window.emulator = new V86Starter({
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

 * You won't be able to run the example above by simply opening the html file from disk in your browser. Instead, you will need to run a http webserver on your machine. The easiest way to run a server on your machine is to run the following python command in the directory you want to server the html and img files from:

//TODO

 * The above example will host a webserver on your machine on port 8070, and the url to fetch the sample.html will be:

//TODO

 * Other popular webserver options to consider are apache, nginx, a LAMP stack (which includes apache, tomcat, geronimo. More webserver options are listed here. 
 * This sample, complete with the seabios.img, vgabios.img, libv86.js, and myfloppy.img is provided in the [sample]() directory of this project.
 * The bios and vga_bios images came from the V86 github [here]().
 * If you prefer, you can build the libv86.js file by cloing the v86 project from github. And building it yourself. 
 * Cloning the V86 library locally also contains non-minimalized debug run mode when if you run from the V86 source.
 * You can easily provide more images for emulated hard drives and cdroms using the V86 api with params such as "hda" and "cdrom". The cd-rom images can be (or must be?) in .iso format.
 * The V86 API has a bunch of other options, those are documented here and here.


The original FreeDOS .img was fetched from here:

https://github.com/copy/images/

# Bugs / Possible Problems

I'm not a vintage hardware guru, so I would not be surprised if the images I've hacked together have issues in the boot sectors such as:

 * Sector sizes might be unrealistic for the real diskettes. For example, all of the images and boot sectors here specify a sector size of 512 bytes. I have not done the research to figure out if say a 160KB diskette had a different sector size than a 1.4MB diskette typically had. 

 * Sectors Per Track / Sectors Per Cylinder specifications. The provided boot sectors and images have left these values in the original state from the source image provided by the V86 project. 

# Resources

Nansi

FreeDos

v86

virtualbox
qemu

other links i found

winworld

oldversions

# Trivia

While building this project, I learned a lot about bootable diskettes. It was not trivial for me to piece together how a vintage bootable diskette is created on modern hardware, or how the boot process works in general. I'm providing these bits of trivia and details in hopes that it will help others looking for understanding:

A bootable hard drive has several parts to it. The very first sector on the disk is 512 bytes long and contains the Master Boot Record (aka MBR). The drive itself contains one or more partitions, which is a section of the drive that is mapped to a logical drive on your computer. A drive can have multiple partitions on it, but there's usually just one partition. When you format a drive with Windows Explorer or MacOs' Disk Utility, the tools will ask you how large you want a partition to be. For example, you could create a 50GB partition and a 150GB partition on a 200GB drive. Consumer laptops often ship with a drive that has multiple partitions on it, the first being a read-only "recovery" partition that can be used to reinstall the OS, and the second being the main partition used to house the OS and your files. When someone dual-boots a machine, there can either be two (or more) physical hard disks in the system with one partition per drive, or two partitions on a single drive. Boot Camp for MacOS does just this, it creates a second partition on your hard drive and formats it in a format that Windows understands (such as ExFAT, or earlier, FAT32), while keeping the primary partition on the drive formatted in HFS+ or some other format that MacOs recognizes and boots from. When the machine boots, one of the partitions on the primary drive is marked as 'active', meaning that's the partition for the BIOS to jump to and start loading the OS from. Boot managers that help with dual booting a machine into multiple operating systems simply switch which partition is marked as active, then boots the machine to that partition (I think.. maybe the boot manager is actually on a third partition and the third partition is always marked as active, with the Boot Manager program tricking the OS into booting from another partition when the user selects which OS they want to boot).

//TODO: explain different file system formats such as Fat12/16/32/NTFS/ExFat. 

For example, a hard drive could have 3 partitions that in a Microsoft system could be mapped to drives such as C: D: and E:. On a linux system these drives would be mapped to something like /dev/disk1s1, /dev/disk1s2 and /dev/disk1s3. 

On a MacOS system these same logical drives will also be nicely available in finder based on the partition's volume label such as "MYDRIVE" or "USB4TBRED" that you'll see in finder, where these labels are the labels you provide in the Disk Utility application when performing Erase Disk or Partition actions. For terminal fans, the logical volume versions of the the partitions get mounted in the /Volumes directory generall, such as /Volumes/MYDRIVE.

When you plug in an external drive, cdrom, usb stick, sd card, you'll see them popup in Finder (on Macos) or Explorer (on Windows) with the volume labels such as MYDRIVE mentioned above. Under the covers on a linux or MacOS system, the OS is automatically doing two operations to make the volume available: attaching and mounting the drive. You can attach and/or mount an .img, .iso, or other disk image files yourself using the Disk Utility app or using the hdiutil command in Terminal. When a drive is merely attached, it can't be read or written to, but it can be partitioned and formatted. Mounting the drive causes the OS to read the partition's File Allocation Table (FAT) and place the disk or image file in a mode to read from and/or write to. 

In MacOS, an .iso image file can be created from a folder with the following command:

    hdiutil makehybrid -iso -joliet -o image.iso /path/to/folder

Disk Utility can also be used to create .iso, .cdr, and other images from folders and disks. 

When a drive is attached but not mounted, it can be fully erased, reformated, or byte-for-byte copied to another disk or an image file using the unix dd command. The dd program differs from cp in that it copies every single byte from the disk, meaning it will copy every sector from the disk, including boot sectors, partition information, FAT information, empty space, every file and folder in their current state (including their exact fragmentation across different sectors on disk, and even 'deleted' file data on the disk where the file has merely been removed from the FAT but the bytes of the file are not securely erased by writing zeros or random data over the file's contents on disk). The dd command is often used when attempting to recover a faulty or failing disk that's mounting incorrectly or has a corrupted FAT. 

The df command on linux and MacOS machines can be used to view information about the attached and mounted disks in your system. In this example below, I provide the -h switch to the df command, so the command prints out the drive capacity and free space in a human legible summarized format such as 1GB free rather than xyz bytes free:

//TODO:


The dd command can also be used to create a .img file like so:

//TODO: 

With the example above, we're specify that the .img file is filled with zeroes (copied from /dev/null, which when read, will always return zeros), and the file has 512 byte sectors, and it has 1440 sectors. A kilobyte is 1024 bytes, so two sectors is a kilobyte. When we divide 1440 by 2, we get 720 - so a 1440 sector 512 byte per sector disk is 720KB, which is one common disk size for floppy disks. 

Early floppy disks came in sizes of 160KB and later disks regularly came in a 1.44MB size. V86 supports a few common floppy disk sizes, those are found in this section of the xyz file:

//TODO show copy/paste of the sizes here.

A floppy diskette does not have a MBR, but instead has a Volume Boot Sector (VBR). I'm a little confused on the difference between a MBR and a VBR, but my basic understanding is that an MBR is used on devices like hard disks that support partitions or multiple partitions, and a VBR is used on storage mediums without partitions (such as floppy diskettes). 

//TODO: link to example boot that the one guy wrote while working with v86. 

The bootable FreeDOS diskettes provided in this project are FAT12 format, because that's what the original V86 floppy image was formatted in. I think later boot disk formats for Windows, Linux, and other operating systems were not necessarily FAT12, as the MBR/VBR generally has a jump command that points to some x86 instructions to first run a disk driver, which is a program that reads FAT information from a drive and controls organizing, reading, and writing files and folders. 

There are a number of other useful commands in Linux/MacOS that can be used in a terminal: 

fdisk

newfs_msdos

dd

hdiutil

diskutil

This is all my very high-level novice understanding of how MBRs, VBRs, boot sectors, partitions, file system formats, and such work. There are a number of resources listed above that go into much greater detail, with much greater authority than I possess. In particular, be sure to check out the xyz site with extremely detailed information about the byte-level breakdown of various boot sector formats. 

Note that there's more trivia and gotchas document inside the script files contained within this project.

# Purpose

These images were created while working on a [book](http://www.happyacro.com) about vintage computing and the insanity associated with a software engineering career. While writing the book, emulated operating systems in a browser were in vogue, and I wanted to create a nostalgic browser-based DOS experience to advertise the book. I found the [V86 library](https://github.com/copy/v86). The sample FreeDOS image provided with V86 is a 720KB diskette that includes a few programs and tools that I was not interested in providing on my book's site, so I went on a quest to strip the diskette image file down in size. In that quest, I sought a way to recreate a bootable diskette with an arbitrary size via a script that would not require manually clicking through a FreeDOS installation wizard or changing the original source diskette image, and I realized there weren't any incredibly straight forward resources for creating a minimal bootable FreeDOS diskette image, so here we are. 


# Credit

FreeDOS

v86

Stack overflow thread

Boot Sector page

HEx editor

# License