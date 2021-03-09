function [TemplatePoints, TargetPoints, TemplateLabel] = Image_Match_Crop(Target)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Template Directories
% This is feature dictionaries for AR Markers.
% If you want to use a customized AR Markers, you must create your own
% dictionary.
load('TemplateDictionary.mat');

%Template Name
TemplateName = ["A_up", "A_down", "B_up", "B_down", "C_up", "C_down", "D_up", "D_down", ...
    "G_up", "G_down", "H_up", "H_down", "I_up","I_down",  "J_up", "J_down", ...
    "K_up", "K_down", "L_up", "L_down", "M_up","M_down",  "N_up", "N_down", ...
    "O_up", "O_down", "P_up", "P_down", "Q_up","Q_down",  "R_up", "R_down"];


%% Parameters
% Continue Matching Parameter
ContinueorEnd = 'Y';
% Matching Parameter
TemplatePoints = [];
TargetPoints = [];
TemplateLabel = [];
SavedTemplateCategory = [];

while(strcmp(ContinueorEnd, 'Y'))
    
    %% Crop on Image
    disp('please crop image for detection region');
    
    figure(1);
    [croppedimage, roi] = imcrop(Target);
    disp(roi);
    
    %% Detect and Extract SURF features in Target ROI Image
    % SURF is used as feature detection. You can use other feature. 
    % But beware, you should create feature dictionary for the selected feature.
    Targetblobs = detectSURFFeatures(rgb2gray(Target), 'MetricThreshold', 100, 'ROI', roi);
    [Target_features, validBlobs] = extractFeatures(rgb2gray(Target), Targetblobs);
    
    
    imshow(Target); hold on; plot(Targetblobs.selectStrongest(10));
    
    %% Dictionary Matching

    MatchSize = 1; % matching threshold
    TemplateCategory = [];

    LPoints = [];
    RPoints = [];
    
    Success = 0;
    for i = 1 : 32
        % Template Match
        Temp = Dictionary(i);
        indexPairs = matchFeatures(Temp.Descriptor,Target_features,  'Unique', true);


        if(MatchSize<size(indexPairs,1))
            Success = 1;

            MatchSize = size(indexPairs,1); % Compare Matched Number
            SavedType = i; %Save Template Name

            matchedPoints_blob1 = Temp.Location;       
            matchedPoints_blob2 = validBlobs.Location;
            LPoints = matchedPoints_blob1(indexPairs(:,1),:);
            RPoints = matchedPoints_blob2(indexPairs(:,2),:);
            
        end
    end
    
    %if Matching Success
    if(Success)
        TemplateCategory = TemplateName(SavedType);
        ImName = sprintf('./AR_Markers/%d.tiff', SavedType);
        TemplateImage = imread(ImName);
        
        %% Show matched points and Saved Points
        figure(2); % Show Candidate Points
        showMatchedFeatures(TemplateImage,Target,LPoints,RPoints,'montage');
        title('Candidate point matches');
        legend('Matched points 1','Matched points 2');

        % Template name
        sprintf('%s is Matched', TemplateCategory)

        prompt = 'Do you want to Save? Y/N [N]: ';

        % Save Data Parameter
        SaveorNot = input(prompt,'s');
        if isempty(SaveorNot)
            SaveorNot = 'N';
        end

        if(strcmp(SaveorNot, 'Y'))
            TemplateLabel = [TemplateLabel, SavedType*ones(1, MatchSize)];
            TemplatePoints = [TemplatePoints; LPoints];
            TargetPoints = [TargetPoints; RPoints];
            SavedTemplateCategory = [SavedTemplateCategory, TemplateCategory];
        end

        %Show Saved Points
        if(size(TemplatePoints, 1)>0)
            disp(SavedTemplateCategory);
        end
    
    else
        disp('Matching Failed');
    end
    
    prompt = 'Do you want to Continue? Y/N [Y]: ';
    ContinueorEnd = input(prompt,'s');
    if(~strcmp(ContinueorEnd, 'N'))
        ContinueorEnd = 'Y';
    end
  
end

save('Matched2DPoints.mat', 'TemplatePoints', 'TargetPoints', 'TemplateLabel');
disp('Matching Done and Saved Successfully!')

end
