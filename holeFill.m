function [output_image] = main(input_image_path,epsilon, window_size)
    input_image = double(imread(input_image_path));
   % input_image = input_image(1:20,1:20);
    top_left_r = randi(size(input_image, 1) - 32);
    top_left_c = randi(size(input_image, 2) - 32);
    input_image(top_left_r:top_left_r+20,top_left_c:top_left_c+20)=0;
    imagesc(input_image),colormap(gray),truesize;
    %% Image normalisation
    %input_imae = input_image - min(input_image(:)) + 1;
    output_image = input_image;
   % output_image(1:3, 1:3) = input_image(top_left_r:top_left_r + 2, top_left_c:top_left_c+2);
    pad_length = (window_size - 1)/2;
    padded_output = double(zeros(size(output_image) + window_size - 1));
    padded_output(pad_length + 1: size(output_image, 1) + pad_length,  pad_length + 1: size(output_image, 2) + pad_length) = output_image;   
    %% Collecting all windows
    windows = [];
    windows = im2col(input_image,[window_size,window_size],'sliding');
    size(windows);
    windows=windows';
%     nlfilter(input_image, [window_size, window_size], @add_windows);
%     function [o] = add_windows(current_window)
%         windows = [windows;current_window(:)'];
%         o = 1;
%     end
    
    function [distance_vector] = distfun(z1byn, zmbyn)
        gaussian = fspecial('gaussian', window_size, window_size/6.4);
        gaussian = gaussian(:)';
        distance_vector = [];
        for row = 1:size(zmbyn, 1)
            centerValue = zmbyn(row, :);
            centerValue = centerValue(ceil((window_size * window_size)/2));
            mask = (z1byn ~= 0) .* (zmbyn(row, :) ~= 0) .* gaussian .* (centerValue ~= 0);
            temp=mask .* (zmbyn(row, :) - z1byn);
            if(sum(mask(:)) == 0)
                distance_vector = [distance_vector; 1000000000];
            else
                distance_vector = [distance_vector;sqrt(sum(temp.*temp))/sqrt(sum(mask(:)))];
            end
        end
    end

    function [o] = giveValue(probe_image)
        if(sum(probe_image(:)) == 0) o = 100000;
        else
           % size(probe_image(:))
            [idx, d] = knnsearch(windows, probe_image(:)', 'Distance', @distfun, 'K', 200);
            idx = idx(d <= (1 + epsilon) * d(1));
            temp = windows(idx(randi(size(idx, 2))), :);
            o = temp(ceil((window_size * window_size)/2));
        end
    end
iters=0;
while(iters<1)
     [por, qor] = find(input_image == 0); 
     for ind = 1:size(por)
         p=por(ind);
         q = qor(ind);
         if(output_image(p,q)==0)
           val = giveValue(padded_output(p: p + 2*pad_length, q: q + 2*pad_length));
           %disp('val is');
           %val
           if(val==100000)
               continue;
           end
           output_image(p,q)=val;
           padded_output(p+pad_length,q+pad_length)=output_image(p,q);
         end
     end
     iters=iters+1;
     
end 
end