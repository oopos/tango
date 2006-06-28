/*
 * Author:
 *  Walter Bright
 * Copyright:
 *  Copyright (c) 2001-2005 by Digital Mars,
 *  All Rights Reserved,
 *  www.digitalmars.com
 * License:
 *  This software is provided 'as-is', without any express or implied
 *  warranty. In no event will the authors be held liable for any damages
 *  arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute it
 *  freely, subject to the following restrictions:
 *
 *  <ul>
 *  <li> The origin of this software must not be misrepresented; you must not
 *       claim that you wrote the original software. If you use this software
 *       in a product, an acknowledgment in the product documentation would be
 *       appreciated but is not required.
 *  </li>
 *  <li> Altered source versions must be plainly marked as such, and must not
 *       be misrepresented as being the original software.
 *  </li>
 *  <li> This notice may not be removed or altered from any source
 *       distribution.
 *  </li>
 *  </ul>
 */

/*
 *  Modified by Sean Kelly <sean@f4.ca> for use with the Ares project.
 */

module tango.math.ieee;

private import tango.stdc.math;
private import tango.math.core; // for sin and cos

// Returns true if equal to precision, false if not
// (This function is used in unit tests)
package bool mfeq(real x, real y, real precision)
{
    if (x == y)
	    return true;
    if (isnan(x) || isnan(y))
	    return false;
    return fabs(x - y) <= precision;
}

// Returns true if x is +0.0 (This function is used in unit tests)
package bool isPosZero(real x)
{
    return (x == 0) && (signbit(x) == 0);
}

// Returns true if x is -0.0 (This function is used in unit tests)
package bool isNegZero(real x)
{
    return (x == 0) && signbit(x);
}

/**
 * Returns x rounded to a long value using the FE_TONEAREST rounding mode.
 * If the integer value of x is
 * greater than long.max, the result is
 * indeterminate.
 */
extern (C) real rndtonl(real x);

/**
 * Separate floating point value into significand and exponent.
 *
 * Returns:
 *  Calculate and return <i>x</i> and exp such that
 *  value =<i>x</i>*2$(SUP exp) and
 *  .5 &lt;= |<i>x</i>| &lt; 1.0<br>
 *  <i>x</i> has same sign as value.
 *
 *  $(TABLE_SV
 *  <tr> <th> value          <th> returns        <th> exp
 *  <tr> <td> &plusmn;0.0    <td> &plusmn;0.0    <td> 0
 *  <tr> <td> +&infin;       <td> +&infin;       <td> int.max
 *  <tr> <td> -&infin;       <td> -&infin;       <td> int.min
 *  <tr> <td> &plusmn;$(NAN) <td> &plusmn;$(NAN) <td> int.min
 *  )
 */
real frexp(real value, out int exp)
{
    ushort* vu = cast(ushort*)&value;
    long* vl = cast(long*)&value;
    uint ex;

    // If exponent is non-zero
    ex = vu[4] & 0x7FFF;
    if (ex)
    {
    if (ex == 0x7FFF)
    {   // infinity or NaN
        if (*vl &  0x7FFFFFFFFFFFFFFF)  // if NaN
        {   *vl |= 0xC000000000000000;  // convert $(NAN)S to $(NAN)Q
        exp = int.min;
        }
        else if (vu[4] & 0x8000)
        {   // negative infinity
        exp = int.min;
        }
        else
        {   // positive infinity
        exp = int.max;
        }
    }
    else
    {
        exp = ex - 0x3FFE;
	    vu[4] = cast(ushort)((0x8000 & vu[4]) | 0x3FFE);
    }
    }
    else if (!*vl)
    {
    // value is +-0.0
    exp = 0;
    }
    else
    {   // denormal
    int i = -0x3FFD;

    do
    {
        i--;
        *vl <<= 1;
    } while (*vl > 0);
    exp = i;
        vu[4] = cast(ushort)((0x8000 & vu[4]) | 0x3FFE);
    }
    return value;
}

unittest
{
    static real vals[][3] = // x,frexp,exp
    [
    [0.0,   0.0,    0],
    [-0.0,  -0.0,   0],
    [1.0,   .5, 1],
    [-1.0,  -.5,    1],
    [2.0,   .5, 2],
    [155.67e20, 0x1.A5F1C2EB3FE4Fp-1,   74],    // normal
    [1.0e-320,  0.98829225,     -1063],
    [real.min,  .5,     -16381],
    [real.min/2.0L, .5,     -16382],    // denormal

    [real.infinity,real.infinity,int.max],
    [-real.infinity,-real.infinity,int.min],
    [real.nan,real.nan,int.min],
    [-real.nan,-real.nan,int.min],

    // Don't really support signalling nan's in D
    //[real.nans,real.nan,int.min],
    //[-real.nans,-real.nan,int.min],
    ];
    int i;

    for (i = 0; i < vals.length; i++)
    {
    real x = vals[i][0];
    real e = vals[i][1];
    int exp = cast(int)vals[i][2];
    int eptr;
    real v = frexp(x, eptr);

    //printf("frexp(%Lg) = %.8Lg, should be %.8Lg, eptr = %d, should be %d\n", x, v, e, eptr, exp);
    assert(mfeq(e, v, .0000001));
    assert(exp == eptr);
    }
}

/**
 * Compute n * 2$(SUP exp)
 * References: frexp
 */
real ldexp(real n, int exp) /* intrinsic */
{
    version(D_InlineAsm_X86)
    {
        asm
        {
            fild exp;
            fld n;
            fscale;
        }
    }
    else
    {
        return tango.stdc.math.ldexpl(n, exp);
    }
}

/**
 * Extracts the exponent of x as a signed integral value.
 *
 * If x is not a special value, the result is the same as
 * <tt>cast(int)logb(x)</tt>.
 *
 *  $(TABLE_SV
 *  <tr> <th> x               <th>ilogb(x)     <th> Range error?
 *  <tr> <td> 0               <td> FP_ILOGB0   <td> yes
 *  <tr> <td> &plusmn;&infin; <td> +&infin;    <td> no
 *  <tr> <td> $(NAN)          <td> FP_ILOGBNAN <td> no
 *  )
 */
int ilogb(real x)
{
    return tango.stdc.math.ilogbl(x);
}

alias tango.stdc.math.FP_ILOGB0   FP_ILOGB0;
alias tango.stdc.math.FP_ILOGBNAN FP_ILOGBNAN;

/**
 * Extracts the exponent of x as a signed integral value.
 *
 * If x is subnormal, it is treated as if it were normalized.
 * For a positive, finite x:
 *
 * -----
 * 1 <= $(I x) * FLT_RADIX$(SUP -logb(x)) < FLT_RADIX
 * -----
 *
 *  $(TABLE_SV
 *  <tr> <th> x               <th> logb(x)  <th> Divide by 0?
 *  <tr> <td> &plusmn;&infin; <td> +&infin; <td> no
 *  <tr> <td> &plusmn;0.0     <td> -&infin; <td> yes
 *  )
 */
real logb(real x)
{
    return tango.stdc.math.logbl(x);
}

/**
 * Efficiently calculates x * 2$(SUP n).
 *
 * scalbn handles underflow and overflow in
 * the same fashion as the basic arithmetic operators.
 *
 *  $(TABLE_SV
 *  <tr> <th> x                <th> scalb(x)
 *  <tr> <td> &plusmn;&infin; <td> &plusmn;&infin;
 *  <tr> <td> &plusmn;0.0      <td> &plusmn;0.0
 *  )
 */
real scalbn(real x, int n)
{
    // BUG: Not implemented in DMD
    return tango.stdc.math.scalbnl(x, n);
}

/**
 * Calculates the next representable value after x in the direction of y.
 *
 * If y > x, the result will be the next largest floating-point value;
 * if y < x, the result will be the next smallest value.
 * If x == y, the result is y.
 * The FE_INEXACT and FE_OVERFLOW exceptions will be raised if x is finite and
 * the function result is infinite. The FE_INEXACT and FE_UNDERFLOW
 * exceptions will be raised if the function value is subnormal, and x is
 * not equal to y.
 */
real nextafter(real x, real y)
{
    // BUG: Not implemented in DMD
    return tango.stdc.math.nextafterl(x, y);
}

/**
 * Creates a quiet NAN with the information from tagp[] embedded in it.
 */
real nan(char[] tagp)
{
    // NOTE: Should use toStringz
    char[] tmp = tagp ~ '\0';
    return tango.stdc.math.nanl(tmp);
}

/**
 * Returns the positive difference between x and y.
 * Returns:
 *  <table border=1 cellpadding=4 cellspacing=0>
 *  <tr> <th> x, y   <th> fdim(x, y)
 *  <tr> <td> x > y  <td> x - y
 *  <tr> <td> x <= y <td> +0.0
 *  </table>
 */
real fdim(real x, real y)
{
    return (x > y) ? x - y : +0.0;
}

/**
 * Returns |x|
 *
 *  $(TABLE_SV
 *  <tr> <th> x               <th> fabs(x)
 *  <tr> <td> &plusmn;0.0     <td> +0.0
 *  <tr> <td> &plusmn;&infin; <td> +&infin;
 *  )
 */
real fabs(real x) /* intrinsic */
{
    version(D_InlineAsm_X86)
    {
        asm
        {
            fld x;
            fabs;
        }
    }
    else
    {
        return tango.stdc.math.fabsl(x);
    }
}

/**
 * Returns (x * y) + z, rounding only once according to the
 * current rounding mode.
 */
real fma(real x, real y, real z)
{
    return (x * y) + z;
}

/**
 * Calculate cos(y) + i sin(y).
 *
 * On x86 CPUs, this is a very efficient operation;
 * almost twice as fast as calculating sin(y) and cos(y)
 * seperately, and is the preferred method when both are required.
 */
creal fcis(ireal y)
{
    version(D_InlineAsm_X86)
    {
        asm
        {
            fld y;
            fsincos;
            fxch st(1), st(0);
        }
    }
    else
    {
        return tango.math.core.cos(y.im) + tango.math.core.sin(y.im)*1i;
    }
}

unittest
{
    assert(fcis(1.3e5Li)==tango.math.core.cos(1.3e5L)+tango.math.core.sin(1.3e5L)*1i);
    assert(fcis(0.0Li)==1L+0.0Li);
}

/**
 * Returns !=0 if x is normalized.
 *
 * (Need one for each format because subnormal
 *  floats might be converted to normal reals)
 */
int isnormal(float x)
{
    uint *p = cast(uint *)&x;
    uint e;

    e = *p & 0x7F800000;
    //printf("e = x%x, *p = x%x\n", e, *p);
    return e && e != 0x7F800000;
}

/** ditto */
int isnormal(double d)
{
    uint *p = cast(uint *)&d;
    uint e;

    e = p[1] & 0x7FF00000;
    return e && e != 0x7FF00000;
}

/** ditto */
int isnormal(real e)
{
    ushort* pe = cast(ushort *)&e;
    long*   ps = cast(long *)&e;

    return (pe[4] & 0x7FFF) != 0x7FFF && *ps < 0;
}

unittest
{
    float f = 3;
    double d = 500;
    real e = 10e+48;

    assert(isnormal(f));
    assert(isnormal(d));
    assert(isnormal(e));
}
