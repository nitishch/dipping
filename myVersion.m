function [output_image] = main(input_image_path, orows, ocols, window_size)
epsilon=0.1;
MaxErrorThreshold=0.3;
input_image = double(imread(input_image_path));
input_image=input_image(1:20,1:20);
filled = false(20,20);
filledSoFar = 0;
while filledSoFar<400
    progress=0;
    PixelList = GetUnfilledNeighbours(filled,input_image);
    for i = 1:size(PixelList,1)
        for j = 1:size(PixelList,2)
           Template = GetNeighbourhoodWindow(Pixel);
           BestMatches=FindMatches(Template,SampleImage);
           BestMatch=RandomPick(BestMatches);
           if (BestMatch.error < MaxErrorThreshold)
               Pixel.value = Best.value;
               progress==1;
               nfilled=nfilled+1;
           end
           if progress==0
               MaxErrorThreshold=MaxErrorThreshold*1.1;
           end
        end
    end
end
end
function [template] = GetUnfilledNeighbours(fillled,input_image)
border = bwmorph(filled,'dilate')-filled;
template=find(border);
l=template

end