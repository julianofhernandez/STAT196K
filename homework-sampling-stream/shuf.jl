# Default value for reservoir_size
reservoir_size = 100
input = readlines()

# Check if there is an arg value
if size(ARGS)[1] == 1
	if parse(Int64, ARGS[1]) < size(input)[1]
		reservoir_size = parse(Int64, ARGS[1])
	else
		reservoir_size = size(input)[1]
	end
elseif size(ARGS)[1] > 1
	print("This program does not support more than 1 option")
else
	if reservoir_size > size(input)[1]
		reservoir_size = size(input)[1]
	end
end
# Sets up reservoir
reservoir = Array{String,1}(undef, reservoir_size)
for index in eachindex(reservoir)
	reservoir[index] = input[index]
end
for i=size(reservoir)[1]+1:size(input)[1]
	random_number = rand(1:i,1)[1]
	if random_number <= size(reservoir)[1]
		reservoir[random_number] = input[i]
	end
end
for line in reservoir
	println(line)
end

