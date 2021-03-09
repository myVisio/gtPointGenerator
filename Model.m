function [point3D] =  Model(point2D, TemplateLabel, BoxWidth, BoxHeight, BoxDepth, TemplateSize)

%multiply /2 using halfsize
BoxWidth = BoxWidth/2;
BoxHeight = BoxHeight/2;
BoxDepth = BoxDepth/2;

Ang = -2 * atan2(BoxHeight, BoxWidth);

% pointNum = size(point2D,1);
TemplateSize = TemplateSize - 1;
for i = 1 : size(point2D,1) 
    
    % Texture Classing
    PlaneType = mod(TemplateLabel(i)-1, 8) + 1;
    FloorType = 4 - floor((TemplateLabel(i)-1)/8);
    
    u = (TemplateSize + 1) * point2D(i, 1)/128 - 1;
    v = (TemplateSize + 1) * point2D(i, 2)/128 - 1;
    
    X = 1;
    Y = 1;
    Z = 1;

    % Create or Load Texture
    if(PlaneType == 1)
        X = -BoxHeight;
        Y = BoxWidth - u;
        Z = BoxDepth - v;
    elseif(PlaneType == 2)
        X = -BoxHeight;
        Y = -BoxWidth + TemplateSize - u; 
        Z = -BoxDepth + TemplateSize - v; 

    elseif(PlaneType == 3)
        X = -BoxHeight + u;
        Y = -BoxWidth;
        Z = BoxDepth - v;
    elseif(PlaneType == 4)
        X = BoxHeight - TemplateSize + u;
        Y = -BoxWidth;
        Z = -BoxDepth + TemplateSize - v;

    elseif(PlaneType == 5)
        X = BoxHeight;
        Y = -BoxWidth + u;
        Z = BoxDepth - v;
    elseif(PlaneType == 6)
        X = BoxHeight;
        Y = BoxWidth - TemplateSize + u;
        Z = -BoxDepth + TemplateSize - v;

    elseif(PlaneType == 7)
        X = BoxHeight - u;
        Y = BoxWidth;
        Z = BoxDepth - v;
    elseif(PlaneType == 8)
        X = -BoxHeight + TemplateSize - u;
        Y = BoxWidth;
        Z = -BoxDepth + TemplateSize - v;
    else
         disp('Error on PlaneType! Check Box Plane and Marker Up or Down!')
         break
    end

    % Ridge Body Transformation

    RZ = 0;
    T = [0; 0; 0];

    if(FloorType == 1)

    elseif(FloorType == 2)
        RZ = Ang;
        T = [0; 0; 2*BoxDepth];
    elseif(FloorType == 3)
        RZ = 2 * Ang;
        T = [0; 0; 4*BoxDepth];
    elseif(FloorType == 4)
        RZ = 3 * Ang;
        T = [0; 0; 6*BoxDepth];
    else
        disp('Error on FloorType! Check Box Floor!')
        break
    end

    R = [cos(RZ), -sin(RZ), 0; sin(RZ), cos(RZ), 0; 0, 0, 1]; 
    point3D(i,:) = transpose([R T]*[X; Y; Z; 1]);

end

end