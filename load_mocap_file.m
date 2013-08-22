function [marker] = load_mocap_file(Filename_VZ)



%read file
fp = fopen(Filename_VZ);
no_frames = 0;

while(~feof(fp))
    
    c = fgetl(fp);
    
    if strncmp(c, '%Frame#', 5)
        no_frames = no_frames+1;
        
        data(:,:,no_frames) = fscanf(fp, '%f %f %f %f %f %f %f', [7, inf]);        
    end
    
end

[~,no_markers,~] = size(data);

fclose(fp);

%Read original capture times

a = no_frames*no_markers;
time_orig = zeros(length(a),1);
time_new = zeros(length(a),1);

m = 1;
for i = 1:no_frames
    
    for j = 1:no_markers
        time_orig(m,1) = data(7,j,i);
        m = m+1;
    end
    
end

%Set time of first marker capture of Frame 2 to be t=0

for i = 1:a
    time_new(i,1) = time_orig(i)-time_orig(no_markers+1);    
end

time_mod = time_new/10^6;

%Seperate all marker data

for i = 1:no_markers
    marker_names{i} = sprintf('markerID_%d_%d',data(2,i,1),data(3,i,1));
end


for i = 1:length(marker_names)
    marker.(marker_names{i}).time_orig = [];
    marker.(marker_names{i}).time_mod = [];
    marker.(marker_names{i}).coord = [];
end


for m = 1:no_markers
    j = 1;
    
    for i = m:no_markers:a
        marker.(marker_names{m}).time_orig(j,1) = time_orig(i,1);
        marker.(marker_names{m}).time_mod(j,1) = time_mod(i,1);
        j = j+1;
    end
    
end

for m = 1:no_markers
    
    i = 1;
    for j = 1:no_frames

      marker.(marker_names{m}).coord(i,1) = data(4,m,j);
      marker.(marker_names{m}).coord(i,2) = data(5,m,j);
      marker.(marker_names{m}).coord(i,3) = data(6,m,j);
           i = i+1;       
    end

end
    

