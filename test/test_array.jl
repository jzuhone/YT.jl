using Base.Test
using YT
import YT.array: YTUnitOperationError

u = YT.units
pc = YT.physical_constants

a = YTArray(rand(10), "cm")
b = YTArray(rand(10), "g")
x = YTQuantity(rand(), "m")
y = YTQuantity(rand(), "Msun")
z = rand()

c = rand(10)

@test eltype(a) == Float64

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

x*c
c*x
x./c
c/x
x\c
c.\x

a.*c
c.*a
a./c
c./a
a.\c
c.\a

@test a.*b == b.*a
@test x*y == y*x
@test a*y == y*a
@test a./b == b.\a
@test x/y == y\x
@test x./a == a.\x

@test -a == -1*a

@test_approx_eq a.value sqrt(a.*a).value
@test_approx_eq x.value sqrt(x*x).value

@test a.units == sqrt(a.*a).units
@test x.units == sqrt(x*x).units

@test a.units^2 == a.units*a.units
@test (a.*a).units == a.units*a.units

@test a.units/b.units == b.units\a.units

@test hypot(YTQuantity(3.,"cm"),YTQuantity(4.,"cm")) == YTQuantity(5.,"cm")

i = YTQuantity(1.0,"cm")
j = YTQuantity(2.0,"cm")
k = YTQuantity(3.0,"cm")

l = sqrt(i*i+j*j+k*k)

@test hypot(i,j,k) == l

# Conversions

@test_approx_eq in_cgs(x).value x.value*100.0
@test_approx_eq in_mks(b).value b.value/1000.0

@test_approx_eq in_cgs(in_units(a, "mile")).value a.value
@test_approx_eq in_cgs(in_units(b, "Msun")).value b.value

@test in_cgs(in_units(a, "mile")).units == a.units
@test in_cgs(in_units(b, "Msun")).units == b.units

@test_approx_eq in_mks(in_units(x, "ly")).value x.value

aa = copy(a)
xx = copy(x)

convert_to_mks(aa)
convert_to_cgs(xx)

@test in_mks(a) == aa
@test in_cgs(x) == xx

convert_to_units(aa, "ly")
@test_approx_eq aa.value in_units(a, "ly").value
@test aa.units == in_units(a, "ly").units

# These should fail

@test_throws YTUnitOperationError a+b
@test_throws YTUnitOperationError a-b
@test_throws YTUnitOperationError b+a
@test_throws YTUnitOperationError b-a

@test_throws YTUnitOperationError x+y
@test_throws YTUnitOperationError x-y
@test_throws YTUnitOperationError y+x
@test_throws YTUnitOperationError y-x

@test_throws YTUnitOperationError a+y
@test_throws YTUnitOperationError a-y
@test_throws YTUnitOperationError y+a
@test_throws YTUnitOperationError y-a

@test_throws YTUnitOperationError b+x
@test_throws YTUnitOperationError b-x
@test_throws YTUnitOperationError x+b
@test_throws YTUnitOperationError x-b

@test_throws YTUnitOperationError z+a
@test_throws YTUnitOperationError z-a
@test_throws YTUnitOperationError a+z
@test_throws YTUnitOperationError a-z
@test_throws YTUnitOperationError z+b
@test_throws YTUnitOperationError z-b
@test_throws YTUnitOperationError b+z
@test_throws YTUnitOperationError b-z

@test_throws YTUnitOperationError z+x
@test_throws YTUnitOperationError z-x
@test_throws YTUnitOperationError x+z
@test_throws YTUnitOperationError x-z
@test_throws YTUnitOperationError z+y
@test_throws YTUnitOperationError z-y
@test_throws YTUnitOperationError y+z
@test_throws YTUnitOperationError y-z

# Reading / writing from HDF5 files

myinfo = ["field"=>"velocity_magnitude", "source"=>"galaxy cluster"]
write_hdf5(a, "test.h5", dataset_name="cluster", info=myinfo)
b = from_hdf5("test.h5", dataset_name="cluster")
@test a == b
@test a.units == b.units

c = YTQuantity(1.0,"kpc")
d = YTQuantity(1.0,"ly")

@test middle(c,d) == 0.5*(c+d)

@test string((c/d).units) == "dimensionless"
@test string((c\d).units) == "dimensionless"

# Boolean stuff

@test YTQuantity(true)
@test !YTQuantity(false)
@test YTQuantity(true,"cm")
@test !YTQuantity(false,"cm")
@test YTQuantity(true,a.units)
@test !YTQuantity(false,a.units)
@test YTQuantity(true,a.units.unit_symbol)
@test !YTQuantity(false,a.units.unit_symbol)

# Ones, zeros, fill, linspace

oa = ones(a)
za = zeros(a)

@test sum(oa).value == 10.0
@test sum(za).value == 0.0

@test oa.units == a.units
@test za.units == a.units

# Unit equivalencies

kT = 5.0*u.keV

list_equivalencies(kT)

@test has_equivalent(kT, "spectral")
@test !has_equivalent(kT, "compton")

@test to_equivalent(kT,"K","thermal") == in_units(kT/pc.kboltz, "K")
