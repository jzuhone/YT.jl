a = YTArray(randn(10), "cm")
b = YTArray(randn(10), "g")
x = YTQuantity(randn(1)[1], "m")
y = YTQuantity(randn(1)[1], "Msun")
z = randn(1)[1]

# These should pass

a.*b
a./b
a.\b
b.*a
b./a
b.\a

a*x
a*y
b*x
b*y
x*a
x*b
y*a
y*b

a/x
a/y
b/x
b/y
x./a
x./b
y./a
y./b

a.\x
a.\y
b.\x
b.\y
x\a
x\b
y\a
y\b

x*y
y*x
x/y
y/x
x\y
y\x

a*z
b*z
x*z
y*z
z*a
z*b
z*x
z*y

a/z
b/z
x/z
y/z
z./a
z./b
z/x
z/y

a.\z
b.\z
x\z
y\z
z\a
z\b
z\x
z\y

a.*b == b.*a
x*y == y*x
a*y == y*a
a./b == b.\a
x/y == y\x
x./a == a.\x

abs(a) == sqrt(a.*a)
abs(x) == sqrt(x*x)
abs(a) == cbrt(a.^3)
abs(x) == cbrt(x^3)

# These should fail

@test_throws a+b
@test_throws a-b
@test_throws b+a
@test_throws b-a

@test_throws x+y
@test_throws x-y
@test_throws y+x
@test_throws y-x

@test_throws a+y
@test_throws a-y
@test_throws y+a
@test_throws y-a

@test_throws b+x
@test_throws b-x
@test_throws x+b
@test_throws x-b

@test_throws z+a
@test_throws z-a
@test_throws a+z
@test_throws a-z
@test_throws z+b
@test_throws z-b
@test_throws b+z
@test_throws b-z

@test_throws z+x
@test_throws z-x
@test_throws x+z
@test_throws x-z
@test_throws z+y
@test_throws z-y
@test_throws y+z
@test_throws y-z
