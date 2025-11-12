<thought>
The user wants a Python program that reads a number and checks its sign.
I need to use `input()` to read the number, convert it to an integer or float, and then use if/elif/else to check its value against 0.

Steps:
1. Read input using `input()`.
2. Convert the input string to a number (e.g., `int()` or `float()`). `float()` is safer as it handles both integers and decimals.
3. Use an `if` condition to check if the number is greater than 0. If true, print 'POSITIVE'.
4. Use an `elif` condition to check if the number is less than 0. If true, print 'NEGATIVE'.
5. Use an `else` condition, which implies the number must be 0. If true, print 'ZERO'.
</thought>
num = float(input())

if num > 0:
    print('POSITIVE')
elif num < 0:
    print('NEGATIVE')
else:
    print('ZERO')