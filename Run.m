function Run

close all;

%% 1. Select Input Calibration Image
prompt = 'Type filename = <from_current_folder_path> : ';
fileName = input( prompt, 's' );
DisplayorNot = 1; % display matched points

if ~isfile(fileName)
    disp('This is not a file. Check filename.');
    return; 
end

%% 2. Double size or not? This will resize your input image into double. ([Y] is prefered for accuracy)
prompt='Do you want to Doublesize? Y/N [Y]: ';
DoubleorNot = input( prompt, 's' );
if isempty(DoubleorNot)
    DoubleorNot = 'Y';
end

if(strcmp(DoubleorNot, 'Y'))
    temp = imread(fileName);
    image = imresize(temp,2);
else
    image = imread(fileName);
end

%% 3. Match image
[TemplatePoints, TargetPoints, TemplateLabel] = Image_Match_Crop(image);

% Change scale of double sized image
if(strcmp(DoubleorNot, 'Y'))
    TargetPoints = TargetPoints/2;
end

if isempty(TargetPoints)
   disp("No 2D points are selected! Please Save points.");
   return;
end

%Box size
BoxWidth= 480; BoxHeight = 385; BoxDepth = 350; TemplateSize = 131; % Scale : (mm)

[point3D] = Model(TemplatePoints, TemplateLabel, BoxWidth, BoxHeight, BoxDepth, TemplateSize);

%% 4. Display matched points
if(DisplayorNot)
    %Cutting by Templates
    TemplateName = ["A_up", "A_down", "B_up", "B_down", "C_up", "C_down", "D_up", "D_down", ...
        "G_up", "G_down", "H_up", "H_down", "I_up","I_down",  "J_up", "J_down", ...
        "K_up", "K_down", "L_up", "L_down", "M_up","M_down",  "N_up", "N_down", ...
        "O_up", "O_down", "P_up", "P_down", "Q_up","Q_down",  "R_up", "R_down"];


    %Template save
    temp = 0;
    count = 0;
    templist = [];
    Tclass = {};
    for t = 1: length(TemplateLabel)
        if( temp ~= TemplateLabel(t))
            temp = TemplateLabel(t);
            count = count + 1;
            Tclass{count} = [point3D(t, :)];
            templist=[templist, TemplateName(temp)];
        else
            Tclass{count} = [Tclass{count}; point3D(t, :)];
        end

    end

    figure(3)
    hold on
    for s = 1 : length(templist)
        color = rand(1, 3);
        x = Tclass{s}(:,1);
        y = Tclass{s}(:,2);
        z = Tclass{s}(:,3);
        scatter3(x, y, z, 20, color, 'filled')
    end
    hold off
    grid on
    xlabel('x');
    ylabel('y');
    legend(templist);
end

%% 5. Save corresponding 2D-3D points
save('2D&3DPoints.mat', 'TargetPoints', 'point3D');
disp('2D <-> 3D Correspondence is saved Successfully!');

end
