using Random, FileIO, Images, ImageView, ImageMagick

"""Compute the similarity score between two pixels."""
function compare_pixels(p1, p2)
	r1, g1, b1 = red(p1), green(p1), blue(p1)
	r2, g2, b2 = red(p2), green(p2), blue(p2)
	return abs(r1-r2) + abs(g1-g2) + abs(b1-b2)
end

"""Compute the similarity score between two columns of pixels in an image."""
function compare_columns(col1, col2)
	score = 0
	nb_row = length(col1)
	for row = 1 : nb_row - 1
		score += compare_pixels(col1[row], col2[row])
	end
	return score
end

"""Compute the overall similarity score of a PNG image."""
function score_picture(filename::String)
	picture = load(filename)
	nb_col = size(picture, 2)
	score = 0
	for col = 1 : nb_col - 1
		score += compare_columns(picture[:,col], picture[:,col+1])
	end
	return score
end

"""Write a tour in TSPLIB format."""
function write_tour(filename::String, tour::Array{Int}, cost::Float32)
	file = open(filename, "w")
	length_tour = length(tour)
	write(file,"NAME : $filename\n")
	write(file,"COMMENT : LENGHT = $cost\n")
	write(file,"TYPE : TOUR\n")
	write(file,"DIMENSION : $length_tour\n")
	write(file,"TOUR_SECTION\n")
	for node in tour
		write(file, "$(node + 1)\n")
	end
	write(file, "-1\nEOF\n")
	close(file)
end

"""Shuffle the columns of an image randomly or using a given permutation."""
function shuffle_picture(input_name::String, output_name::String; view::Bool=false, permutation=[])
	picture = load(input_name)
	nb_row, nb_col = size(picture)
	shuffled_picture = similar(picture)
    if permutation == []
    	permutation = shuffle(1:nb_col)
    end
	for col = 1 : nb_col
		shuffled_picture[:,col] = picture[:,permutation[col]]
	end
	view && imshow(shuffled_picture)
	save(output_name, shuffled_picture)
end

"""Read a tour file and a shuffle image, and output the image reconstructed using the tour."""
function reconstruct_picture(tour_filename::String, input_name::String, output_name::String; view::Bool=false)
	tour = Int[]
	file = open(tour_filename, "r")
	in_tour_section = false
	for line in eachline(file)
		line = strip(line)
		if line == "TOUR_SECTION"
			in_tour_section = true
		elseif in_tour_section
			node = parse(Int, line)
			if node == -1
				break
			else
				push!(tour, node - 1)
			end
		end
	end
	close(file)
	shuffled_picture = load(input_name)
	reconstructed_picture = shuffled_picture[:,tour[2:end]]
	view && imshow(reconstructed_picture)
	save(output_name, reconstructed_picture)
end
