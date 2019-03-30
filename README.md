# multjumpctrl
## What is it?
**multjumpctrl** allows you to control your retro motherboard CPU multiplier and FSB jumpers. It was born out of wanting additional control to slow down DOS games without cracking open the case every time I wanted to change a jumper.
## How does it work?
**multjumpctrl** uses an arduino compatible board to "pull down" motherboard jumpers via serial control. Simply connect arduino digital pins to motherboard multiplier and/or FSB headers, arduino TTL to a TTL to RS232 converter, RS232 converter to your motherboard serial header. The QuickBasic **MULTJUMP.bas** will send the commands to arduino to toggle the jumpers.
![alt text](https://github.com/lnxsrt/multjumpctrl/raw/master/multjump.png)
## How does MULTJUMP.bas work?
It sends the serial commands to the arduino, verifing that they are applied correctly. It also can reboot the computer to activate your new jumper settings. Additionally, it will report ERRORLEVEL so that you can add it to your game start batch file to automate jumper settings for various games.

Use the below syntax to set pins to a value (0 = pull down, 1 = pull up, 2 = float)

`multjump.exe 2,{pin number},{value};2,{pin number},{value};2,{pin number},{value}`

Pin 9 - float; Pin 10 - pull down; Pin 11 - float; Pin 12 - float

`multjump.exe 2,9,2;2,10,0;2,11,2;2,12,2`

Use the `/nr` flag to specify that you don't want to reboot or be asked to reboot if a change has to be made. This is useful for scripting since it will allow you check if a change has to be made to the current jumper configuration via ERRORLEVEL.

`multjump.exe /nr 2,9,2;2,10,0;2,11,2;2,12,2`

**MULTJUMP.bas** is a QuickBasic 4.5 application. It **MUST** be compiled to allow ERRORLEVEL and commandline arguments to work.

`bc MULTJUMP.bas`

`link MULTJUMP.obj`
## What hardware do I need?
- Arduino compatible board. Most motherboards use 3.3V logic for jumpers, so make sure it can handle 3.3V logic. I prefer the [Adafruit Metro Mini](https://www.adafruit.com/product/2590). It allows you to choose between 5V and 3.3V logic. It also is completely Arduino Uno compatible in a much smaller form factor.
- A TTL to RS232 converter. You can roll your own via various circuits available online. Many use a MAX232 or similar. If you want one ready to go, the [SparkFun MAX3232](https://www.sparkfun.com/products/11189) is a good option.
- Motherboard that uses jumpers to control CPU multipliers and FSB. You need to verify that it measures a pulled up pin. Typcially these a pulled up via a resistor to 3.3V. When the arduino pulls this down, the jumper is "shorted". The current needed to pull these down is typically very low. Mine was under 1mA. The arduino can handle [20mA per pin or 100mA total.](https://playground.arduino.cc/Main/ArduinoPinCurrentLimitations/)
## Can I contribute?
Absolutely, I am much more proficient in Python than C/C++ or QuickBasic. I am certain this code can be improved and extended.
