function test(input_img_path, output_img_path)
srcFile=dir('C:\MATLAB\MATLAB\R2015a\bin\test\*.jpg');

for i=1:length(srcFile)
    filename=strcat('C:\MATLAB\MATLAB\R2015a\bin\test\',srcFile(i).name);
    I=imread(filename);
    I = imresize(I, 0.95);
    
    path=strcat('C:\MATLAB\MATLAB\R2015a\bin\test\Save',srcFile(i).name);
     imwrite(I,path);
tic;
%Add VLFeat library for computing SIFT feature
addpath(genpath('./vlfeat-0.9.14/'))

if nargin < 2
    input_img_path =('./upload/13.jpg');
    output_img_path =('./output/.jpg');
end

if(isempty(input_img_path))
    input_img_path =('./upload/.jpg');
end
    
if(isempty(output_img_path))
    output_img_path =('./output/.jpg');
end

InputImg = imread(input_img_path);
InputImg = imresize(InputImg, 0.95);






 I = rgb2gray(I);
InputImg = rgb2gray(InputImg);






IPoints = detectSURFFeatures(I);
InputImgPoints = detectSURFFeatures(InputImg);




%figure;
imshow(I);
title('100 Strongest Feature Points from Box Image');
hold on;
plot(selectStrongest(IPoints, 100));

%figure;
imshow(input_img_path);
title('300 Strongest Feature Points from Scene Image');
hold on;
plot(selectStrongest(InputImgPoints, 300));



[IFeatures, IPoints] = extractFeatures( I, IPoints);
[InputImgFeatures, InputImgPoints] = extractFeatures(InputImg, InputImgPoints);

boxPairs = matchFeatures(IFeatures, InputImgFeatures);

matchedIPoints = IPoints(boxPairs(:, 1), :);
matchedInputImgPoints = InputImgPoints(boxPairs(:, 2), :);
%figure;
showMatchedFeatures( I, InputImg, matchedIPoints, ...
    matchedInputImgPoints, 'montage');
title('Putatively Matched Points (Including Outliers)');



[tform, inlierIPoints, inlierInputImgPoints] = ...
    estimateGeometricTransform(matchedIPoints, matchedInputImgPoints, 'affine');


   
%figure;
showMatchedFeatures( I, InputImg, inlierIPoints, ...
    inlierInputImgPoints, 'montage');
title('Matched Points (Inliers Only)');

boxPolygon = [1, 1;...                           % top-left
        size( I, 2), 1;...                 % top-right
        size( I, 2), size( I, 1);... % bottom-right
        1, size( I, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon
    

    
newBoxPolygon = transformPointsForward(tform, boxPolygon);
if any(newBoxPolygon <= 2)

   % figure;
     InputImg = insertText(InputImg, [100 150 ], 'Is illegal cosmetics');
    disp('Is illegal cosmetics')
imshow(InputImg);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
title('Detected Box');
fileID = fopen('C:\MATLAB\MATLAB\R2015a\bin\test\test.txt','w+')
fprintf(fileID, 'เป็นเครื่องสำอางผิดกฏหมาย');
fclose(fileID);
else
    %figure;
     InputImg= insertText(InputImg, [100 400 ], ' N0 illegal cosmetics ');
    disp('No illegal cosmetics')
    
imshow(InputImg);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
title('Detected Box');
fileID = fopen('C:\MATLAB\MATLAB\R2015a\bin\test\test.txt','w+')
fprintf(fileID, 'ไม่เป็นเครื่องสำอางผิดกฏหมาย');
fclose(fileID);
end
end