module utilities

function ensure_array(fields)
    if (typeof(fields) <: Array)
        fields = [fields]
    end
    fields
end

end
