# Memory Testing
Did this after overclocking the memory in the BIOS


## Background
BIOS was heavily outdated so I walked through the process of updating the BIOS with claude. Claude recommended changing the BIOS setting to take full advantage of my memory which supports up to 6400mhz.


## Process
1. **Press Del at boot**, then **F7** to open Advanced Mode.
2. **Go to the Ai Tweaker tab** (called Extreme Tweaker on some BIOS versions).
3. **Set Ai Overclock Tuner to XMP I.** This loads your kit's rated profile, the default was DDR5-6400.
4. **Find the option DRAM Frequency** Change the memory speed to DDR5-6000.
5. **Press F10 to save and reboot.** The first boot can take 1–3 minutes while the memory trains, so don't power off.
6. **Confirm it worked.** In Windows, Task Manager → Performance → Memory should show a speed of 6000 MT/s.
7. **Run a quick stability test**, OCCT's memory test, for an hour or so. Verify that is has no errors. 
