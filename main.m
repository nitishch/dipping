function [output_image] = main(input_image_path, orows, ocols, epsilon, window_size)
    input_image = double(imread(input_image_path));
    %input_image=input_image(1:20,1:20);
   output_image=main2(input_image, orows, ocols, epsilon, window_size);
end
function [output_image] = main2(input_image, orows, ocols, epsilon, window_size)
    
    %input_image = input_image(1:40,1:40);
    
    %% Image normalisation
    input_image = input_image - min(input_image(:)) + 1;
    
    %% Input image padding
    pad_length = (window_size - 1)/2;
   % padded_input = double(zeros(size(input_image) + window_size - 1));
    %padded_input(pad_length + 1: size(input_image, 1) + pad_length,  pad_length + 1: size(input_image, 2) + pad_length) = input_image;
     
    %% Getting seed
    top_left_r = randi(size(input_image, 1) - 2);
    top_left_c = randi(size(input_image, 2) - 2);
    %top_left_r=1;
    %top_left_c=1;
    %% Adding seed
    output_image = double(zeros(orows, ocols));
   % output_image(1:3,1:3)=input_image(top_left_r:top_left_r + 2, top_left_c:top_left_c+2);
    output_image(ceil(orows/2)-1:ceil(orows/2)+1,ceil(ocols/2)-1:ceil(ocols/2)+1) = input_image(top_left_r:top_left_r + 2, top_left_c:top_left_c+2);
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
    gaussian = fspecial('gaussian', window_size, window_size/6.4);
    gaussian=gaussian(:)'
    function [distance_vector] = distfun(z1byn, zmbyn)
        distance_vector = [];
        for row = 1:size(zmbyn, 1)
            mask = (z1byn ~= 0) .* (zmbyn(row, :) ~= 0).*gaussian;
            distance_vector = [distance_vector; rms(mask .* (zmbyn(row, :) - z1byn))/sum(mask(:))];
        end
    end
    size(gaussian)
    size(windows)
    distMat = pdist(windows,@distfun);
    distMat = squareform(distMat);
    function [o] = giveValue(probe_image)
        if(sum(probe_image(:)) == 0) o = 100000;
        else
            [idx, d] = knnsearch(distMat,probe_image(:)','K', 50);
           % [idx, d] = knnsearch(windows, probe_image(:)', 'Distance', @distfun, 'K', 50);
           %[idx, d] = knnsearchtemp,probe_image(:)', 'Distance', @distfun, 'K', 50);
            idx = idx(d <= (1 + epsilon) * d(1));
            temp = windows(idx(randi(size(idx, 2))), :);
            o = temp(ceil((window_size * window_size)/2));
        end
    end
    %Spiralling out
      x=0;
      y=0;
      dx=1;
      dy=0;
      for i = 1:(orows*ocols)
          %i
         disp(x);
         disp(y);
          %pause(5)
          if((abs(x)==abs(y) && (~(dx==1) || ~(dy==0))) || (x>0 && y==1-x))
              tem=dx;
              dx=-1*dy;
              dy=tem;
          end
          if(abs(y)>orows/2 || abs(x)>ocols/2)
              tem=dx;
              dx=-1*dy;
              dy=tem;
              tem=x;
              x=-1*y+dx;
              y=tem+dy;
          end
          if(abs(x)<2 && abs(y)<2)
             % x,y
               x=x+dx;
               y=y+dy;
              continue
          end
          output_image(ceil(orows/2)+y,ceil(ocols/2)+x) = giveValue(padded_output(ceil(orows/2)+y:ceil(orows/2)+y+2*pad_length,ceil(ocols/2)+x:ceil(ocols/2)+x+2*pad_length));
          padded_output(ceil(orows/2)+y+pad_length,ceil(ocols/2)+x+pad_length)=output_image(ceil(orows/2)+y,ceil(ocols/2)+x);
         x=x+dx;
         y=y+dy;
      end
end

