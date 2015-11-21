function [output_image] = main(input_image_path, orows, ocols, epsilon, window_size)
    input_image = double(imread(input_image_path));
   % input_image = input_image(1:20,1:20);
    
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

    pad_length = (window_size - 1)/2;

    padded_output = double(zeros(size(output_image) + window_size - 1));
    padded_output(pad_length + 1: size(output_image, 1) + pad_length,  pad_length + 1: size(output_image, 2) + pad_length) = output_image;

   
    %% Collecting all windows
    windows = [];
    nlfilter(input_image, [window_size, window_size], @add_windows);
    function [o] = add_windows(current_window)
        windows = [windows;current_window(:)'];
        o = 1;
    end
    
    function [distance_vector] = distfun(z1byn, zmbyn)
        gaussian = fspecial('gaussian', window_size, window_size/6.4);
        gaussian = gaussian(:)';
        distance_vector = [];
        for row = 1:size(zmbyn, 1)
            mask = (z1byn ~= 0) .* (zmbyn(row, :) ~= 0).*gaussian;
            temp=mask .* (zmbyn(row, :) - z1byn);
            distance_vector = [distance_vector;sqrt(sum(temp.*temp))/sqrt(sum(mask(:)))];
        end
    end

    function [o] = giveValue(probe_image)
        if(sum(probe_image(:)) == 0) o = 100000;
        else
            [idx, d] = knnsearch(windows, probe_image(:)', 'Distance', @distfun, 'K', 20);
            idx = idx(d <= (1 + epsilon) * d(1));
            temp = windows(idx(randi(size(idx, 2))), :);
            o = temp(ceil((window_size * window_size)/2));
        end
    end
    %% Step 1 - FIll up the box
    for i = 4:window_size % i is column index here
        for j = 1:i
           output_image(j,i) = giveValue(padded_output(j + pad_length - pad_length : j + pad_length + pad_length,i + pad_length - pad_length : i + pad_length + pad_length));
            padded_output(j + pad_length, i + pad_length) = output_image(j, i);
        end
        for j = i-1:-1:1
            output_image(i, j) = giveValue(padded_output(i + pad_length - pad_length : i + pad_length + pad_length,j + pad_length - pad_length : j + pad_length + pad_length));
        padded_output(i + pad_length, j + pad_length) = output_image(i, j);
        end
    end
    disp('out of first');
    %% STEP 2 - The first window_size row
    for i = window_size + 1 : ocols % i is the column index here
        for j = 1:window_size
            output_image(j, i) = giveValue(padded_output(j + pad_length - pad_length : j + pad_length + pad_length,i + pad_length - pad_length : i + pad_length + pad_length));
            padded_output(j + pad_length, i + pad_length) = output_image(j, i);
        end
    end
    disp('out of second');
    %% STEP 3
    for i = window_size + 1: orows
        for j = 1:ocols
            output_image(i, j) = giveValue(padded_output(i + pad_length - pad_length : i + pad_length + pad_length,j + pad_length - pad_length : j + pad_length + pad_length));
            padded_output(i + pad_length, j + pad_length) = output_image(i, j);
        end
        i
    end
end



% function [outputValue] = giveValue(input_image, probe_image, windowSize, epsilon)
%  %% Output image padding
%     errorImage = nlfilter(input_image, [windowSize, windowSize], @intermediate);
%     function [o] = intermediate(given_image)
%         mask = (probe_image ~= 0) .* (given_image ~= 0) .* fspecial('gaussian', windowSize, sqrt(windowSize));
%         temp_matrix = (probe_image -  given_image) .* mask;
%         if sum(mask(:)) == 0
%             o = 100000;
%         else
%             o = rms(temp_matrix(:))/sum(mask(:));
%         end
%     end
%     closestOnes = input_image .* (errorImage <= (1 + epsilon) * min(errorImage(:)));
%     closestOnes = nonzeros(closestOnes);
%     outputValue = 0;
%     outputValue = closestOnes(randi(size(closestOnes, 1)));
% end