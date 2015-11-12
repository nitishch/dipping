function [output_image] = main(input_image_path, orows, ocols, epsilon, window_size)
    input_image = double(imread(input_image_path));
    
    %% Image normalisation
    input_image = input_image - min(input_image(:)) + 1;
    
    %% Input image padding
    pad_length = (window_size - 1)/2;
    padded_input = double(zeros(size(input_image) + window_size - 1));
    padded_input(pad_length + 1: size(input_image, 1) + pad_length,  pad_length + 1: size(input_image, 2) + pad_length) = input_image;
     
    %% Getting seed
    top_left_r = randi(size(input_image, 1) - 2);
    top_left_c = randi(size(input_image, 2) - 2);
    
    %% Adding seed
    output_image = double(zeros(orows, ocols));
    output_image(1:3, 1:3) = input_image(top_left_r:top_left_r + 2, top_left_c:top_left_c+2);


   
    %% Step 1 - FIll up the box
    for i = 4:window_size
        for j = 1:i
           output_image(j,i) = giveValue(input_image, output_image, window_size, epsilon, j, i);
        end
        for j = i-1:-1:1
            output_image(i, j) = giveValue(input_image, output_image, window_size, epsilon, i, j);
        end
    end
    
    %% STEP 2 - The first window_size row
    for i = window_size + 1 : orows
        for j = 1:window_size
            output_image(j, i) = giveValue(input_image, output_image, window_size, epsilon, j , i);
        end
    end
    
    %% STEP 3
    for i = window_size + 1: orows
        for j = 1:ocols
            output_image(i, j) = giveValue(input_image, output_image, window_size, epsilon, i, j);
        end
    end

end



function [outputValue] = giveValue(input_image, output_image, windowSize, epsilon, row, col)
   
 %% Output image padding
    pad_length = (windowSize - 1)/2;
    padded_output = double(zeros(size(output_image) + windowSize - 1));
    padded_output(pad_length + 1: size(output_image, 1) + pad_length,  pad_length + 1: size(output_image, 2) + pad_length) = output_image;
    %output_image  = padded_output;
    
    probe_image = padded_output(row + pad_length - pad_length:row + pad_length + pad_length, col + pad_length - pad_length:col + pad_length + pad_length);

    padLength = (windowSize - 1)/2;
    errorImage = nlfilter(input_image, [windowSize, windowSize], @intermediate);
    function [o] = intermediate(given_image)
        temp_matrix = (probe_image -  given_image) .* (probe_image ~= 0) .* (given_image ~= 0);
        o = rms(temp_matrix(:));
    end
    closestOnes = input_image .* (errorImage <= (1 + epsilon) * min(errorImage(:)));
    closestOnes = nonzeros(closestOnes);
    closestOnes
    size(closestOnes)
    outputValue = closestOnes(randi(size(closestOnes, 1)));
end