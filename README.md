- Joseph Attieh
- Clara Akiki


# Simon-Game-Assembly

_Submitted on Dec 2017 for the course COE 324 - Microprocessors Lab_

# Requirements:

In this project, we are required to implement a SIMON GAME.
Simon is an electronic game of memory skill invented by Ralph H. Baer and Howard J. Morrison with software programming by Lenny Cope. The device creates a series of tones and lights and requires a user to repeat the series. If the user succeeds, the series becomes progressively longer and more complex. Once the user fails, the game is over. This game is to be implemented on a Microprocessor board (MCU). 

# Implementation 

First, two messages are printed on the screen: a “Simon Game ” scrolling to the right for 3 seconds and a “Pick the level of difficulty ” scrolling to the left. 
Then, the user can select the level of difficulty of the game by pressing on the three push buttons connected to the MCU. 
Then, a random generator subroutine generates a random sequence that lights up the LEDs.
Finally, the user can enter the sequence of lights by enterring the value on the keyboard of the PC, connected through putty.

# Challenges

- Challenge 1: Making the random generator fully randomized
  -  Solution: Created a subroutine that only generates one random value and contains a customized delay. In the main code, we jumped to that subroutine to create the sequence of numbers.

- Challenge 2: Displaying Simon Game and Welcome for only 3 seconds without using interrupts
  - Solution: Tried  to vary the delay using trial and error and determined the value to load in the register  to display for exactly 3 seconds.

- Challenge 3: Changing the sequence of random numbers every time it is increased when the player wins (it repeats the same sequence then it adds a number)
  - Solution:  Clearing the offset after generating the sequence

- Challenge 4: Entering a sequence of values in putty instead of entering value per value
  - Solution: Cleared the SCI status register 1 and SCI data register



