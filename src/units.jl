module units

import ..array: YTQuantity

prefixes = [
    "Y",  # yotta
    "Z",  # zetta
    "E",  # exa
    "P",  # peta
    "T",  # tera
    "G",  # giga
    "M",  # mega
    "k",  # kilo
    "d",  # deci
    "c",  # centi
    "m",  # milli
    "u",  # micro
    "n",  # nano
    "p",  # pico
    "f",  # femto
    "a",  # atto
    "z",  # zepto
    "y",  # yocto
    "",   # nothing
]

prefixable_units = [
    "m",
    "pc",
    "g",
    "eV",
    "s",
    "yr",
    "K",
    "dyne",
    "erg",
    "esu",
    "J",
    "Hz",
    "W",
    "gauss",
    "G",
    "Jy",
    "N",
    "T",
    "A",
    "C",
]

for unit in prefixable_units
    for prefix in prefixes
        u = symbol(prefix * unit)
        @eval $u = YTQuantity(1.0,$unit)
    end
end

end
