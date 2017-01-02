// FloatData.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include <stdio.h>



float  i2f(unsigned int x)
{
	unsigned int f[1];
	f[0] = x;
	return *(float *)(void *)f;
}

unsigned f2i(float f)
{
	float x[1];
	x[0] = f;
	return *(unsigned int *)(void *)x;
}

float doFop(char ch, float f1, float f2)
{
	switch (ch) {
	case '+': return f1 + f2;
	case '-': return f1 - f2;
	case '*': return f1 * f2;
	case '/': return f1 / f2;
	default: return 0.0;
	}

}

float make754(unsigned s, unsigned exp, unsigned frac)
{
	return i2f((s << 31) + ((exp + 127) << 23) + frac);
}

int parseIEEE(char *s, float *f)
{
	unsigned int sgn, exp, frac, n;
	char st[100];
	char dummy[1023];
	if (s == 0) return 0;
	n = sscanf_s(s, "%d.%d.%d%s", &sgn, &exp, &frac, dummy, (unsigned) sizeof dummy);
	if ((n == 3) && (sgn < 2) && (exp < 256) && frac < (1 << 23))
	{
		*f = make754(sgn, exp - 127, frac);
		return 1;
	}
	if (sscanf_s(s, "%x %s", &n, &st, (unsigned) sizeof st) == 1)
	{
		*f = i2f(n);
		return 1;
	}
	printf("'%s' is not recognised as a hex integer (0xhhhh) or s.e.f format coding the IEEE-754 code for a floating point number where sgn = 0 or 1, 0 <= e < 256, 0 <= f < 2^23, sgn,e,f are all decimal\n",s);
	printf("valid examples: 0x23a10000, 1.127.234005\n");
	return 0;
}

float getNumber(char *s)
{
	char buff[100];
	float f;
	int done = 0;
	char *r;
	while (done == 0)
	{
		printf("\n\n%s", s);
		r = fgets(buff, sizeof(buff), stdin);
		if (r != 0) done = parseIEEE(buff, &f);
		if (done == 0) printf("\nNot a valid floating point number, try again.\n");
	}
	return f;

}

void doMultiply( float f1, float f2)
{
	float fx = f1*f2;
	printf("IEEE754 Code 0x%X (%g) = f1*f2 where\n f1 = IEEE754 Code 0x%X (%g)\n f2 = IEEE754 Code 0x%X (%g)\n", f2i(fx), fx, f2i(f1), f1, f2i(f2), f2);
}


int main(int argc, char *argv[])
{
	float f1, f2;
	int r;
	if (argc != 3)
	{
		printf("Wrong number (%d) of command line parameters: 2 parameters are needed\n\n", argc - 1);
		printf("floatdata.exe f1 f2\n\nOutputs the IEEE-754 code for f1*f2\
\nf1 and f2 can be specified as integers or as s.e.f \
\nwhere s,e,f are the corresponding IEEE-754 bit fields represented as unsigned decimal integers\n\n\
Use examples\n floatdata.exe 0xC8000000 0x46000000\n floatdata.exe 1.127.324760 0.120.4311525\n\nInteractive Mode entered\n");
		while (1) {
			f1 = getNumber("Enter first floating point number (f1):");
			f2 = getNumber("Enter second floating point number (f2):");
			doMultiply(f1, f2);
		}
	}
	else {
		r = parseIEEE(argv[1], &f1) && parseIEEE(argv[2], &f2);
	}
	if (r) {
		doMultiply(f1, f2);
	}
	else {
		printf("Invalid floating point format\n");
	}
	return getchar();
}

