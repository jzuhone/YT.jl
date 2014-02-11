using PyCall

import ..yt_array: YTArray, YTQuantity
@pyimport numpy as np

a = randn(100)
b = randn(100)
numpy_a = pycall(np.array, PyArray, a)
numpy_b = pycall(np.array, PyArray, b)
a_arr = YTArray(a, "cm")
b_arr = YTArray(b, "m")
bb_arr = YTArray(b, "g")

x = randn(1)
y = randn(1)
x_quan = YTQuantity(x, "s")
y_quan = YTQuantity(y, "yr")
yy_quan = YTQuantity(y, "eV")

function test_units_multiply

end

function test_units_add

end

function test_arrays_sqrt

end

function test_arrays_cbrt

end

function test_arrays_add
    # Test adding same dimension
    c_arr = a_arr+b_arr
    # Test adding different dimension
    c_arr = a_arr+bb_arr
end

function test_arrays_subtract
    # Test subtracting same dimension
    c_arr = a_arr-b_arr
    # Test subtracting different dimension
    c_arr = a_arr-bb_arr
end

function test_arrays_multiply
    # Test multiplying same dimension
    c_arr = a_arr.*b_arr
    # Test multiplying different dimension
    c_arr = a_arr.*bb_arr
end

function test_arrays_divide
    # Test dividing same dimension
    c_arr = a_arr./b_arr
    # Test dividing different dimension
    c_arr = a_arr./bb_arr
    # Test dividing same dimension
    c_arr = a_arr.\b_arr
    # Test dividing different dimension
    c_arr = a_arr.\bb_arr
end

function test_arrays_slice

end
