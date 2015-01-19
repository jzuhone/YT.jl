module units

import PyCall: @pyimport
import YT.array: YTQuantity

@pyimport yt.units.unit_lookup_table as lut

base_units = collect(keys(lut.default_unit_symbol_lut))
prefixes = collect(keys(lut.unit_prefixes))
prefixable_units = lut.prefixable_units

for unit in base_units
    u = symbol(unit)
    @eval $u = YTQuantity(1.0, $unit)
    if unit in lut.prefixable_units
        for prefix in prefixes
            pu = string(prefix*unit)
            if pu != "as"
                u = symbol(pu)
                @eval $u = YTQuantity(1.0, $pu)
            end
        end
    end
end

end
