module utils

Axis = Union(String,Array,Integer)
Field = Union(String,Tuple)
FieldOrArray = Union(Field,Array)
IntOrRange = Union(Int,Range,Range1,Array{Int,1})
RealOrArray = Union(Real,Array)
Length = Union(Real,Tuple)
StringOrArray = Union(String,Array)

end
