include("AutomataTools.jl")
using Images
using Statistics
using Random

function save_to_file(filename, A)
    save(filename, colorview(Gray, A))
end


function image_from_single_rule(rule_function, starting_row, dims)

    image_array = [false for i in 1:dims[1], j in 1:dims[2]]
    image_array[1, :] = starting_row
    for i in 2:dims[1]
        image_array[i, :] = get_next_row(rule_function, image_array[i - 1, :])
    end
    return image_array
end

function image_from_alternating_rules(rule_function_1, rule_function_2, starting_row, rule_swap_parity)
    dims = (5000, 500)
    image_array = [false for i in 1:dims[1], j in 1:dims[2]]
    image_array[1, :] = starting_row
    for i in 2:dims[1]
        image_array[i, :] = get_next_row(rule_function_1, image_array[i - 1, :])
        if i % rule_swap_parity == 0
            image_array[i, :] = get_next_row(rule_function_2, image_array[i - 1, :])
        end
    end
    return image_array
end

function image_with_enforced_density(rule_function, density_array, row_adjust_function, dims)
    starting_row = random_starting_row(dims[2], density_array[1])
    image_array = [false for i in 1:dims[1], j in 1:dims[2]]
    image_array[1, :] = starting_row
    for i in 2:dims[1]
        image_array[i, :] = get_next_row_wrap(rule_function, image_array[i - 1, :])
        deviation = mean(image_array[i, :]) - density_array[i]
        replacement_value = deviation <= 0
        shortfall = round(Int32, (abs(deviation * dims[2])))
        num_to_replace = row_adjust_function(shortfall)
        if num_to_replace > 0
            inds_to_replace = rand(findall(x->x == !replacement_value, image_array[i,:]), num_to_replace)
            image_array[i, inds_to_replace] .= replacement_value
        end
    end
    return image_array
end


function run_experiment_1()

    k = 5
    starting_row = [i % k == 0 for i in 1:500]
    rule = tuple_rule_function(152)
    dims = (5000, 500)
# A = image_from_single_rule(rule, starting_row, dims)
# img = colorview(Gray, A)

    densities = [0.9 for i in 1:dims[1]]
    raf = x->round(Int32, x * 0.75)

    B = image_with_enforced_density(rule, densities, raf, dims)
    img = colorview(Gray, B)
    save("boom5.png", img)

    dims = (500, 200)
    rule = tuple_rule_function(104)
    for j in 1:256
        rule = tuple_rule_function(j)
        mkdir("./images/experiment1" * string(j, pad = 4))
        for k in 1:200
            Random.seed!(100)
            densities = [k / 200 for i in 1:dims[1]]
            B = image_with_enforced_density(rule, densities, raf, dims)
            img = colorview(Gray, B)
            save("./images/experiment1" * string(j, pad = 4) * "/baw104b" * string(k, pad = 4) * ".png", img)
        end
    end

end



    
