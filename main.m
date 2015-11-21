function [output_image] = main(input_image_path, orows, ocols, epsilon, window_size)
    input_image = double(imread(input_image_path));
    input_image=input_image(1:50,1:50);    
    
    %% Image normalisation
    input_image = input_image - min(input_image(:)) + 1;
     
    %% Getting seed
    top_left_r = randi(size(input_image, 1) - 2);
    top_left_c = randi(size(input_image, 2) - 2);
    
    %% Adding seed
    output_image = double(zeros(orows, ocols));
    output_image(ceil(orows/2)-1:ceil(orows/2)+1,ceil(ocols/2)-1:ceil(ocols/2)+1)...
        = input_image(top_left_r:top_left_r + 2, top_left_c:top_left_c+2);
    
    pad_length = (window_size - 1)/2;

    padded_output = double(zeros(size(output_image) + window_size - 1));
    padded_output(pad_length + 1: size(output_image, 1) + pad_length, ...
        pad_length + 1: size(output_image, 2) + pad_length) = output_image;

   
    %% Collecting all windows    
    windows = im2col(input_image, [window_size window_size], 'sliding');
    windows = windows';
    disp('Windows added')

    %% Distance Function
    gaussian = fspecial('gaussian', window_size, window_size/6.4);
    gaussian = gaussian(:)';
    %gaussian = repmat(gaussian, size(windows, 1), 1);
    
    
    function [distance_vector] = distfun(z1byn, zmbyn)
        
        z1byne = repmat(z1byn, size(zmbyn, 1), 1);
        gaussian_repeated = repmat(gaussian, size(zmbyn, 1), 1); 
        mask = (z1byne ~= 0) .* (zmbyn ~= 0).*gaussian_repeated;
        temp = mask .* (zmbyn - z1byne);
        temp = temp .^ 2;
        distance_vector = sqrt(sum(temp, 2))./sqrt(sum(mask, 2));
        
%          distance_vector = zeros(size(zmbyn, 1), 1);
%          for row = 1:size(zmbyn, 1)
%             mask = (z1byn ~= 0) .* (zmbyn(row, :) ~= 0).*gaussian;
%             tempVar = mask .* (zmbyn(row, :) - z1byn);
%             if(sum(mask(:)) ~= 0)
%                 distance_vector(row) = sqrt(sum(tempVar.^2))/sqrt(sum(mask(:)));
%             else
%                 distance_vector(row) = 10000000000;
%             end
%          end
    end
    

    %% Function calling
    function [o] = giveValue(probe_image)
        [idx, d] = knnsearch(windows, probe_image(:)', 'Distance', @distfun, 'K', 150);
        idx = idx(d <= (1 + epsilon) * d(1));
        temp = windows(idx(randi(size(idx, 2))), :);
        o = temp(ceil((window_size * window_size)/2));
    end

    %% Spiralling out
    x=2; y=0; dx=0; dy=1;

    for i = 1:(orows*ocols)-9   
        clc;
        disp(x);
        disp(y);
        %pause(2);
      
        if abs(x)==abs(y)
            tem=dx;
            dx=-1*dy;
            dy=tem;
        end
        
        value = giveValue(padded_output(ceil(orows/2)-y:ceil(orows/2)-y+2*pad_length,...
                ceil(ocols/2)+x:ceil(ocols/2)+x+2*pad_length));
        
        output_image(ceil(orows/2)-y,ceil(ocols/2)+x) = value;        
        padded_output(ceil(orows/2)-y+pad_length,ceil(ocols/2)+x+pad_length)=value;
        
        
        x=x+dx;
        y=y+dy;
        
        if y == 0 && x > 0
            x = x + 1;
        end
    end
end