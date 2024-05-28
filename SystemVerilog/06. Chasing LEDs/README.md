# Chasing LEDs


1. The 16 discrete LEDs are used as output, one lit at a time.
2. The lit LED moves sequentially in either direction. It changes direction when reaching 
the rightmost or leftmost position.
3. The slide switch 0 (labeled sw0 on the Nexys 4 DDR board) is used to “initialize” the 
process. When it is 1, the lit LED is moved to the rightmost position.
4. The next five slide switches (sw1 to sw5) are used to control the chasing speed of the 
LED. The highest speed should be slow enough for visual inspection.
5. When the chasing speed changes, a one-line message is transmitted to the console via the 
UART core. The format of the message is “current speed: ddd”, where ddd is the value of 
five speed setting switches.
