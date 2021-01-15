=================
Fixed-Point Notes
=================

:Author: Rob Gaddi, Highland Technology
:Date: 12-Jan-2021

Basic Number Formats
====================

The Short Version
-----------------

Bit Weights:

+---------+----+---+---+---+-----+------+-------+--------+
| Bit #   |  3 | 2 | 1 | 0.| -1  |  -2  |  -3   |  -4    |
+=========+====+===+===+===+=====+======+=======+========+
| In U4.4 | 8  | 4 | 2 | 1 | 0.5 | 0.25 | 0.125 | 0.0625 |
+---------+----+---+---+---+-----+------+-------+--------+
| In S4.4 | -8 | 4 | 2 | 1 | 0.5 | 0.25 | 0.125 | 0.0625 |
+---------+----+---+---+---+-----+------+-------+--------+

How to interpret binary value ``1101.0011``:

+-----------+----+---+---+----+-----+------+-------+--------+---------+
|           |  1 | 1 | 0 | 1. | 0   | 0    | 1     | 1      | Total   |
+===========+====+===+===+====+=====+======+=======+========+=========+
| In U4.4   | 8  | 4 | 0 | 1  | 0   | 0    | 0.125 | 0.0625 | 13.1875 |
+-----------+----+---+---+----+-----+------+-------+--------+---------+
| In S4.4   | -8 | 4 | 0 | 1  | 0   | 0    | 0.125 | 0.0625 | -2.8125 |
+-----------+----+---+---+----+-----+------+-------+--------+---------+

How to interpret binary value ``0000.0001``:

+-----------+----+---+---+----+-----+------+---+--------+---------+
|           |  0 | 0 | 0 | 0. | 0   | 0    | 0 | 1      | Total   |
+===========+====+===+===+====+=====+======+===+========+=========+
| In U4.4   | 0  | 0 | 0 | 0  | 0   | 0    | 0 | 0.0625 | 0.0625  |
+-----------+----+---+---+----+-----+------+---+--------+---------+
| In S4.4   | 0  | 0 | 0 | 0  | 0   | 0    | 0 | 0.0625 | 0.0625  |
+-----------+----+---+---+----+-----+------+---+--------+---------+

How to interpret binary value ``1111.1111``:

+-----------+----+---+---+----+-----+------+-------+--------+---------+
|           |  1 | 1 | 1 | 1. | 1   | 1    | 1     | 1      | Total   |
+===========+====+===+===+====+=====+======+=======+========+=========+
| In U4.4   | 8  | 4 | 2 | 1  | 0.5 | 0.25 | 0.125 | 0.0625 | 15.9375 |
+-----------+----+---+---+----+-----+------+-------+--------+---------+
| In S4.4   | -8 | 4 | 2 | 1  | 0.5 | 0.25 | 0.125 | 0.0625 | -0.0625 |
+-----------+----+---+---+----+-----+------+-------+--------+---------+

Unsigned
--------

Unsigned numbers have a minimum value of zero.  Integers can be expressed
as unsigned values ``Ux`` where x is the number of bits used.

======      ==============  ========    =============
Format      C type          C99 type    Range
------      --------------  --------    -------------
U8          unsigned char   uint8_t     0..255
U16         unsigned short  uint16_t    0..65535
U32         unsigned long   uint32_t    0..4294967295
======      ==============  ========    =============

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

======      ==============  ========    =======================
Format      C type          C99 type    Range
------      --------------  --------    -----------------------
S8          signed char     int8_t      -128..127
S16         signed short    int16_t     -32768..32767
S32         signed long     int32_t     -2147483648..2147483647
======      ==============  ========    =======================

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

=======     ============    =====   ========    =========   ====================
Format      Resolution      Min     Max         Span        Extended
-------     ------------    -----   --------    ---------   --------------------
U8          1               0       255         255         U8.0 [0, 256)
S8          1               -128    127         255         S8.0 [-128, 128)
U8.2        0.25            0       255.75      255.75      U8.2 [0, 256)
S8.2        0.25            -128    127.75      255.75      S8.2 [-128, 128)
U0.3        0.125           0       0.875       0.875       U0.3 [0, 1)
U0.2        0.25            0       0.75        0.75        U0.2 [0, 1)
U1.2        0.25            0       1.75        1.75        U1.2 [0, 2)
S1.2        0.25            -1      0.75        1.75        S1.2 [-1, 1)
S1.15       3.052e-5        -1      0.999969    1.999969    S1.15 [-1, 1)
U0.16       1.526e-5        0       0.999985    0.999985    U0.16 [0, 1)
=======     ============    =====   ========    =========   ====================

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

Extended number formats are also extremely helpful when working on a processor,
where the fixed data widths mean that your data types will *always* be either
8, 16, 32, or 64 bits in total, so total data size is no longer an indication
of range.  You may be using a U32 value for efficiency, but the value in it
may be known to be in [1, 4]; there's certainly no reason to do the math as if
2 billion might magically sneak in unexpectedly.

Math
====

Resizing/Realigning
-------------------

The goal of resizing and realigning numbers in fixed-point notation is to change
the format of the number *without* changing its underlying meaning; usually prior
to performing addition or subtraction.

Additional fractional bits are provided by padding new bits on the right with 
zeros.  In VHDL, using ``signed`` or ``unsigned``, this takes the form of 
:code:`SHIFT_LEFT(RESIZE(data, new_size), new_size-old_size)` So for instace, 
the value 2.25 can be represented as::

    =   10.01                   U2.2
    =   10.0100                 U2.4
    =   10.01000000000000       U2.14

Unsigned numbers can be resized into signed numbers with one additional bit,
a ``0`` MSB to indicate a positive value.  In VHDL, this looks like
:code:`SIGNED('0' & uns_data)`::

    =     10.0100                U2.4
    =    010.0100                S3.4

A number that is known to be of less range than its current format requires can 
lose MSBs to reduce the data size.  In VHDL, this is simply
:code:`RESIZE(data, new_size)`.  If a signed value is known to be positive, 
for instance a number that is the square of a signed value, then the known 
``0`` sign bit can be dropped as well, and the number made unsigned.  In VHDL,
this should be done prior to resizing, :code:`RESIZE(UNSIGNED(sgn_data), new_size)`::

    =    00000010.01000000       U8.8 [-4, 4)
    =         010.01000000       U3.8 [-4, 4)
             
    =    0010.0100               S4.4 [0, 4)
    =      10.0100               U2.4 [0, 4)

Addition/Subtraction
--------------------

Addition and subtraction with fixed-point numbers requires that the numbers
first be aligned to have the same number of fractional bits, by right-extending
the one with fewer fractional bits::

    =        10.01      U2.2    NOT LIKE THIS
    = +  010110         U6.0
    = ------------
    
    =        10.01      U2.2    LIKE THIS
    = +  010110.00      U6.2
    = ------------
    =    011000.01
    
As such, the total number of fractional bits is the larger of the of fractional 
bits of either operand.  The total number of integer bits required is 1 more 
than the larger of the of the integer bits of either operand, to allow for 
overflow.  If the numbers are range-limited such that they cannot overflow to 
the next bit, this may not be necessary::

    =        10.01      U2.2    [0, 4)
    = +  111110.00      U6.2    [0, 64)
    = ---------------------------------
    =   1000000.01      U7.2    [0, 68)
    
    =        10.01      U2.2    [0, 4)
    = +  010110.00      U6.2    [0, 60)
    = ---------------------------------
    =    011000.01      U6.2    [0, 64)

In VHDL, performing addition or subtraction in a way that extends the sum by 
one bit requires that at least one operand be resized to the larger size before 
the operation, such as :code:`y := RESIZE(a, y'length) + b`

The rules are the same for two signed operands as they are for two unsigned 
operands.  When mixing signed and unsigned operands, the easiest thing to do is 
usually to extend the unsigned operand by 1 MSB to a signed.  Use of extended 
format ranges is **extremely** helpful in resolving the final result to fewer 
bits.

Multiplication
--------------

Multiplication of fixed-point numbers produces a product with as many total
bits as the operands.  Particularly, the product will have as many integer bits
as the total of both operands, and as many fractional bits as the total of
both operands::

    =        10.01      U2.2    [0, 4)
    = *  111110.10      U6.2    [0, 64)
    = ---------------------------------
    =  10001100.1010    U8.4    [0, 256)
    
This holds true for unsigned * unsigned, signed * signed, and unsigned * 
signed.  Note that if performing this math on the dedicated multipliers in an 
FPGA, the hardware usually requires that both operands be signed; as a result 
the available data width is 1 bit fewer with an unsigned operand, to allow for 
a '0' pad on the MSB.

Squaring is a special case of multiplication that will always produce a positive
result, even with a signed input.  As such, for a signed input, the MSB of the
output can be discarded::

    =        10.01      S2.2    [-2, 2)
    = *      10.01      S2.2    [-2, 2)
    = ---------------------------------
    =      0011.0001    S4.4    [0, 4]
    =       011.0001    U3.4    [0, 4]

This is another situation in which range limiting really shines; as just 
eliminating the single value of exactly -2 gets rid of another bit::

    =        10.01      S2.2    (-2, 2)
    = *      10.01      S2.2    (-2, 2)
    = ---------------------------------
    =      0011.0001    S4.4    [0, 4)
    =        11.0001    U2.4    [0, 4)


Summary
-------

==========  =====   ===========     =================================
Op 1        Oper    Op 2            Result
----------  -----   -----------     ---------------------------------
``Uax.ay``   +/-    ``Ubx.by``      ``U(1+max(ax, bx)).(max(ay.by))``
``Sax.ay``   +/-    ``Sbx.by``      ``S(1+max(ax, bx)).(max(ay.by))``
``Sax.ay``    *     ``Sbx.by``      ``S(ax+bx).(ay+by)``
``Sax.ay``    *     ``Ubx.by``      ``S(ax+bx).(ay+by)``
``Uax.ay``    *     ``Ubx.by``      ``U(ax+bx).(ay+by)``
==========  ======  ===========     =================================

