module unit_symbols

import PyCall: pyimport_conda, PyNULL
import YT.array: YTQuantity

const lut = PyNULL()

function __init__()
    copy!(lut, pyimport_conda("yt.units.unit_lookup_table", "yt"))
end

base_units = collect(keys(lut.default_unit_symbol_lut))
prefixes = collect(keys(lut.unit_prefixes))
prefixable_units = lut.prefixable_units

for unit in base_units
    u = Symbol(unit)
    @eval $u = YTQuantity(1.0, String($unit))
    if unit in lut.prefixable_units
        for prefix in prefixes
            pu = String(prefix*unit)
            if pu != "as"
                u = Symbol(pu)
                @eval $u = YTQuantity(1.0, $pu)
            end
        end
    end
end

end
