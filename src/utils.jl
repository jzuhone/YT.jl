module utils

using PyCall

Axis = Union(String,Array,Integer)
FieldOrArray = Union(Field,Array{Field})
IntOrRange = Union(Int,Range,Range1)
RealOrArray = Union(Real,Array)
Field = Union(String,Tuple(String,String))
Length = Union(Real,Tuple(Real,String))
StringOrArray = Union(String,Array)

# Convert slices in Julia to Python slices

pyslice(i::Int) = i-1
function pyslice(idxs::Range1{Int})
    ib = idxs.start-1
    ie = idxs.start+idxs.len-1
    pyeval("slice(ib,ie)", ib=ib, ie=ie)
end
function pyslice(idxs::Range{Int})
    ib = idxs.start-1
    ie = idxs.start+idxs.step*idxs.len-1
    st = idxs.step
    pyeval("slice(ib,ie,st)", ib=ib, ie=ie, st=st)
end

end
