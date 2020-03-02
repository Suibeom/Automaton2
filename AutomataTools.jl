
function rule_dictionary(n)::Dict{Int64,Bool}
    dict = Dict{Int64,Bool}()
    bits = bitstring(n)
    for i in 0:7
        dict[i] = bits[end - i] == '1'
    end
    return dict
end
  
function bools2int(a)
    n = 0
    for i in 1:length(a)
        n += a[i] * 2^(length(a) - i)
    end
    return n
end
  
function tuple_rule_function(n)
    dict = rule_dictionary(n)
    return x::Tuple{Bool,Bool,Bool}->dict[bools2int(x)]::Bool
end

function bools_rule_function(n)
    dict = rule_dictionary(n)
    return (a::Bool, b::Bool, c::Bool)->dict[bools2int([a,b,c])]::Bool
end

function get_next_row_left_right(left_rule_function, right_rule_function, row, edge_rule)
    next_row = Array{Bool,1}(undef, length(row))
    next_row[1] = edge_rule(row[1])
    next_row[end] = edge_rule(row[end])
    center_point = length(row) / 2
    for i in 2:center_point
        next_row[i] = left_rule_function((row[i - 1], row[i], row[i + 1]))
    end
    for i in center_point:length(row) - 1
        next_row[i] = right_rule_function((row[i - 1], row[i], row[i + 1]))
    end
    return next_row
end


function get_next_row(rule_function, row, edge_rule)
    next_row = Array{Bool,1}(undef, length(row))
    next_row[1] = edge_rule(row[1])
    next_row[end] = edge_rule(row[end])
    for i in 2:length(row) - 1
        next_row[i] = rule_function((row[i - 1], row[i], row[i + 1]))
    end
    return next_row
end

function get_next_row_wrap(rule_function, row)
    next_row = Array{Bool,1}(undef, length(row))
    next_row[1] = rule_function((row[end - 1], row[1], row[2]))
    next_row[end] =  rule_function((row[end - 1], row[1], row[2]))
    for i in 2:length(row) - 1
        next_row[i] = rule_function((row[i - 1], row[i], row[i + 1]))
    end
    return next_row
end





function get_next_row(rule_function, row)
    return get_next_row(rule_function, row, x->x)
end

function random_starting_row(dim, density)
    starting_row = [false for i in 1:dim]
    starting_row[2:end - 1] = [rand() < density for i in 2:dim - 1]
    return starting_row
end