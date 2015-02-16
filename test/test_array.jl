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
@test ndims(a) == 1
@test size(a)[1] == 10
@test size(a,1) == 10

# Arithmetic

# These just are supposed to go without erroring out

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

# Check inverse/commutative operations

@test a.*b == b.*a
@test x*y == y*x
@test a*y == y*a
@test a./b == b.\a
@test x/y == y\x
@test x./a == a.\x

@test -a == -1*a

# sqrt, abs, etc.

@test_approx_eq a.value sqrt(a.*a).value
@test_approx_eq a.value sqrt(a.^2).value
@test_approx_eq x.value sqrt(x*x).value
@test_approx_eq x.value sqrt(x^2).value
@test_approx_eq sqrt(x).value (x^0.5).value


# Various unit tests

@test a.units == sqrt(a.*a).units
@test a.units == sqrt(a.^2).units
@test x.units == sqrt(x*x).units
@test x.units == sqrt(x^2).units
@test a.units^2 == a.units*a.units
@test (a.*a).units == a.units*a.units
@test a.units/b.units == b.units\a.units

@test a.units.dimensions == x.units.dimensions
@test a.units != x.units

# math function tests

@test hypot(YTQuantity(3.,"cm"),YTQuantity(4.,"cm")) == YTQuantity(5.,"cm")

i = YTQuantity(1.0,"cm")
j = YTQuantity(2.0,"cm")
k = YTQuantity(3.0,"cm")

l = sqrt(i*i+j*j+k*k)

@test hypot(i,j,k) == l

@test sum(a).value == sum(a.value)
@test sum(a).units == a.units

@test sum(a).value == sum(a.value)
@test sum(a).units == a.units

@test sum_kbn(a).value == sum_kbn(a.value)
@test sum_kbn(a).units == a.units

@test mean(a).value == mean(a.value)
@test mean(a).units == a.units

@test std(a).value == std(a.value)
@test std(a).units == a.units

@test var(a).value == var(a.value)
@test var(a).units == a.units

@test median(a).value == median(a.value)
@test median(a).units == a.units

@test middle(a).value == middle(a.value)
@test middle(a).units == a.units

@test_approx_eq cumsum(a).value cumsum(a.value)
@test cumsum(a).units == a.units

@test_approx_eq cumsum_kbn(a).value cumsum_kbn(a.value)
@test cumsum_kbn(a).units == a.units

@test abs(a).value == abs(a.value)
@test abs(a).units == a.units

@test abs2(a).value == abs2(a.value)
@test abs2(a).units == a.units*a.units

c = YTQuantity(1.0,"kpc")
d = YTQuantity(1.0,"ly")

@test middle(c,d) == 0.5*(c+d)
@test middle(c) == c

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

@test in_units(x, a.units) == in_units(x, string(a.units))
@test in_units(x, a.units.unit_symbol) == in_units(x, string(a.units))
@test in_units(x, a) == in_units(x, string(a.units))

xx = copy(x)
convert_to_units(xx, a.units)
@test xx == in_units(x, string(a.units))

xx = copy(x)
convert_to_units(xx, a.units.unit_symbol)
@test xx == in_units(x, string(a.units))

xx = copy(x)
convert_to_units(xx, a)
@test xx == in_units(x, string(a.units))

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

# Boolean stuff

@test YTQuantity(true)
@test !YTQuantity(false)
@test YTQuantity(true,"cm")
@test !YTQuantity(false,"cm")
@test YTQuantity(true,a.units)
@test !YTQuantity(false,a.units)
@test YTQuantity(true,a.units.unit_symbol)
@test !YTQuantity(false,a.units.unit_symbol)

bb = rand(10) .< rand(10)

@test YTArray(bb,"cm") == bb
@test YTArray(bb,a.units) == bb
@test YTArray(bb,a.units.unit_symbol) == bb

# Ones, zeros, fill, linspace, eye

j = rand(10,10)*u.kg

i = eye(j)

@test sum(i) == 10*u.kg

oa = ones(a)
za = zeros(a)

@test sum(oa).value == 10.0
@test sum(za).value == 0.0

@test oa.units == a.units
@test za.units == a.units

w = fill(x, 12)
@test_approx_eq sum(w).value x.value*12.
@test w.units == x.units

v = fill(x, (4,4,4))
@test_approx_eq sum(v).value x.value*64.
@test v.units == x.units

xlin1 = linspace(x, 10*x, 100)
xlin2 = linspace(x.value, 10*x.value, 100)

@test xlin1.value == xlin2
@test xlin1.units == x.units

ylin1 = linspace(y, 5*y)
ylin2 = linspace(y.value, 5*y.value)

@test ylin1.value == ylin2
@test ylin1.units == y.units

# Unit equivalencies

kT = 5.0*u.keV

list_equivalencies(kT)

@test has_equivalent(kT, "spectral")
@test !has_equivalent(kT, "compton")

@test to_equivalent(kT,"K","thermal") == in_units(kT/pc.kboltz, "K")
@test_approx_eq to_equivalent(a,"g","schwarzschild").value in_cgs(0.5*a*pc.clight^2/pc.G).value

# Dimensionless

h = YTQuantity(5.0)
@test string(h.units) == "dimensionless"

w = YTArray(rand(10))
@test string(w.units) == "dimensionless"

v = YTArray(5.0)
@test string(v.units) == "dimensionless"

@test string((c/d).units) == "dimensionless"
@test string((c\d).units) == "dimensionless"

# Indexing

aa = copy(a)
aa[2] = 2.0
@test aa[2].value == 2.0
@test string(aa[2].units) == "cm"
bb = rand(8)
aa[3:end] = bb
@test sum(aa[3:end]) == sum(bb)*u.cm

# Misc YTArray/YTQuantity

@test YTArray(5.0,"kpc") == 5.0*u.kpc

# Just make sure these don't throw errors

summary(a)
show(a)
show(STDOUT, a.units)
print(a)
println(a)
show(x)
show(STDOUT, x)
print(x)
println(x)
display(a)

for aa in a
    @test aa.units == a.units
end
