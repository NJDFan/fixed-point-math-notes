=================
Fixed-Point Notes
=================

:Author: Rob Gaddi, Highland Technology
:Date: 12-Jan-2021

Basic Number Formats
====================

Unsigned
--------

Unsigned numbers have a minimum value of zero.  Integers can be expressed
as unsigned values ``Ux`` where x is the number of bits used.

======		==============	========	=============
Format		C type			C99 type	Range
------		--------------	--------	-------------
U8			unsigned char	uint8_t		0..255
U16			unsigned short	uint16_t	0..65535
U32			unsigned long	uint32_t	0..4294967295
======		==============	========	=============

In addition to these base types generally found in microprocessors, in an FPGA
the choice of number of bits is entirely arbitrary, so U5 and U15 are just as
valid of sizes as U8 and U16.

Going back to basic number theory, an unsigned integer can be represented in 
binary as the sum of the weighted values of its bits.  So the binary
representation in U4 of decimal value 10 would be ``1010``.  The rightmost bit
is bit 0 and :math:`2^0=1`, and the leftmost bit is bit 3 and :math:`2^3=8`.
So the value is calculated:

.. math::

	\sum_{i=0}^{x-1}{2^i b_i}
		= (2^3 \cdot 1) + (2^2 \cdot 0 ) + (2^1 \cdot 1) + (2^0 \cdot 0)
		= 8 + 2 = 10

Expanding from integers into the realm of fixed point, the format becomes
``Ux.y``, where the . is a *binary point* which serves exactly the same purpose
as a decimal point; digits to the left of it have integer values, and digits
to the right have fractional values.

So bit 0 has a value of 1.  If you walk left from it, you get bits 1 and 2, with
values of 2 and 4.  If instead you walk right from it, you get bits -1 and -2,
with values :math:`2^{-1}=\frac{1}{2}` and :math:`2^{-2}=\frac{1}{4}`.

So the same binary value of ``1010``, if it were a U2.2 number rather than U4,
would be ``10.10``, or:

.. math::

	\sum_{i=-y}^{x-1}{2^i b_i}
		= (2^1 \cdot 1) + (2^0 \cdot 0 ) + (2^{-1} \cdot 1) + (2^{-2} \cdot 0)
		= 2 + \frac{1}{2} = 2.5

This means that shifting the binary point left by two places, from U4.0 to
U2.2, made 10 into 2.5, meaning that it divided by 4, exactly as moving a
decimal left by two places would turn 1000.0 into 10.000, and divide it by 100.

For an unsigned number ``Ux.y``, the total number of bits is x+y, the
resolution  R is :math:`\frac{1}{2^y}`, the minimum is zero, and the maximum is
:math:`2^x - R`

Signed
------

Signed numbers are represented in two's compliment, and therefore have a value 
that extends 1 further into the negative than they do into the positive. 
Integers can be expressed as signed values ``Sx`` where x is the number of bits 
used.

======		==============	========	=======================
Format		C type			C99 type	Range
------		--------------	--------	-----------------------
S8			signed char		int8_t		-128..127
S16			signed short	int16_t		-32768..32767
S32			signed long		int32_t		-2147483648..2147483647
======		==============	========	=======================

Again, outside a microprocessor context with its hardwired data paths, S19 is
just as valid a number of bits as S16.

The only difference between a signed number and an unsigned number is that the
leftmost bit has a negative value.  All the other bits represent the same thing
regardless of whether the data is signed or unsigned.  Back to our good friend
value ``1010``, the math goes:

.. math::

	{-2^{x-1} b_{x-1}} + \sum_{i=0}^{x-2}{2^i b_i}
		= (-2^3 \cdot 1) + (2^2 \cdot 0 ) + (2^1 \cdot 1) + (2^0 \cdot 0)
		= -8 + 2 = -6
		
This formula is nearly same as the unsigned formula, and in fact the lower 3
bits can be treated as a U3 number.  The leftmost bit, however, has a value of
-8 rather than 8.

The range of a number of ``Sx`` and ``Ux`` bits is the same.  S8 and U8 both
have 256 possible values between their minimum and maximum; they just distribute
them differently.

Returning to fixed-point we do the same as we did before and declare ``Sx.y``.
So an S2.2 format for ``10.10`` is -2 + 0.5 = -1.5, which is 6 / 4, and so
the meaning of shifting the binary point left two places remains unchanged.

For an signed number ``Sx.y``, the total number of bits is x+y, the
resolution R is :math:`\frac{1}{2^y}`, the minimum is :math:`-2^{x-1}`,
and the maximum is :math:`2^{x-1} - R`

Examples
--------

The extended columns is the implicit range of the format in
Extended Number Formats, described in the next section.

=======		============	=====	========	=========	====================
Format		Resolution		Min		Max			Span		Extended
-------		------------	-----	--------	---------	--------------------
U8			1				0		255			255			U8.0 [0, 256)
S8			1				-128	127			255			S8.0 [-128, 128)
U8.2		0.25			0		255.75		255.75		U8.2 [0, 256)
S8.2		0.25			-128	127.75		255.75		S8.2 [-128, 128)
U0.3		0.125			0		0.875		0.875		U0.3 [0, 1)
U0.2		0.25			0		0.75		0.75		U0.2 [0, 1)
U1.2		0.25			0		1.75		1.75		U1.2 [0, 2)
S1.2		0.25			-1		0.75		1.75		S1.2 [-1, 1)
S1.15		3.052e-5		-1		0.999969	1.999969	S1.15 [-1, 1)
U0.16		1.526e-5		0		0.999985	0.999985	U0.16 [0, 1)
=======		============	=====	========	=========	====================

Extended Number Formats
=======================

The two basic formats, ``Ux.y`` and ``Sx.y``, provide all the necessary 
information for how to understand the underlying data; i.e. how to relate the 
physical "These bits are these ones and zeros" to the actual number 
they represent.  However, they can lead to overcomplication with real-world
data, because often we know more about the data than just its representation.

For instance, if a given ADC has an electrical range of ±1V, but we know that
we are using only ±0.8V of it to allow for calibration margin, then we will
never have the extremal values.  This may simplify downstream math.

To keep track of this, we lightly cheat a notation from real-number set theory. 
A number R that can be anywhere from -1 to 1, including exactly -1 and 1, is 
denoted as [-1, 1].  If that range were -1 to 1 **exclusive** of the end 
values, it's denoted as (-1, 1).  And if -1 were included but 1 were not, it 
would be [-1, 1).

With real numbers, the difference between ] and ) is whether you can get 
exactly to that number, or merely infinitely close to it.  For our notation, we 
will simply have a relaxed definition of infinity, and instead be one bit away 
from that value.  So a U8.0 number, with values 0..255, would be more formally 
defined as U8 [0, 256).  The use of the "almost-but-not-quite" round 
parenthesis saves a lot of typing once the terms become fractional.  The 
inherent range of a U8.8 number is from 0 to 255.99609375, i.e. the highest 
possible value is :math:`256 - \frac{1}{256}`.  Expressing this range as
U8.8 [0, 256), the same as for U8.0, simplifies things.  In both cases, the
range gets as close to 256 as the resolution of the number allows, but in the
U8.8 case the resolution of the number is better by 256-fold.

So the extended format is the basic format, with additional range information
added.  We can leave the range information off when we really do have a full-range
signal, but should attach it when we know a priori that not the whole number 
range will be used::

	S1.15  =  S1.15 [-1, 1)
	      =/= S1.15 (-1, 1)
	      =/= S1.15 [-0.95, 0.95]

Tracking the ranges becomes more important when values can't extend through
the full range.  As a basic example: to store the product of an S1.7 * S1.7 
multiply, you need 16 bits, an S2.14 value.  The reason you need all 16 bits
is because if both values were -1.0, the product is +1.0, or to express it in
binary::

	1.0000000 * 1.0000000 = 01.00000000000000
	
+1 is the only possible result of this multiply that requires the additional 
integer bit.  If either value were prohibited from being exactly -1, then the 
value of the multiply could never be +1.  Or to notate it::

	S1.7 [-1, 1) * S1.7 [-1, 1) = S2.14 [-1, 1]
	S1.7 [-1, 1) * S1.7 (-1, 1) = S2.14 [-1, 1)
	
And the range [-1, 1) only requires S1 to accommodate it, so the MSB of the
result can be thrown away, i.e. bit 2 will always have the same value as bit 1,
and this is redundant.

All arithmatic operations performed on fixed-point numbers wind up needing more 
bits on the output than the input if all possible values of inputs are legal. 
As a result, large math pipelines can spiral out of control in terms of number 
of bits if you keep all of them.  Range-limiting based on the practical values 
available allows you to throw away unnecessary MSBs to tamp this down.
