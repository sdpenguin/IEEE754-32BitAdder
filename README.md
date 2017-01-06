# IEEE754-32BitAdder
A 32 bit adder in Assembly following the specification defined in the IEEE standard no. 754. A concise, but complete introduction to this is outlined in the link in this Readme, which should be sufficient for most, but if you require clarification on the finer points then I refer you to the standard itself.

http://steve.hollasch.net/cgindex/coding/ieeefloat.html

Notes:
According to the requirements, whenever 0 and infinity are multiplied 0xFFC00000 is the result.
According to the requirements, if either of the multiplicands are NaN, then the result wil be the same NaN. The second multiplicand takes presedence over the first for some reason.
