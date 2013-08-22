function [FP] = load_fp_file(Filename_BW, Filename_VZ)

% open file
fid = fopen(Filename_BW, 'r');

% import numeric data
row  = 0;

while(~feof(fid))
    
    c = fgetl(fid);
    row = row+1;
    if strncmp(c, 'abs time', 5)
        end_hdr_row = row;                   %end_hdr_row identifies end of  header 
    end
    
    if strncmp(c, 'Rate (Hz):', 9)
        rate_row = row;                   %rate_row identifies header row with frame rate info 
    end
    
    if strncmp(c, 'Device:', 7)
        device_row = row;                   %device_row identifies header row with device number info 
    end
    
end
fclose(fid);

DataArray = dlmread (Filename_BW,'\t',(end_hdr_row+1),0);	   

% Load header data

fid = fopen(Filename_BW);

lines_endhdr = textscan(fid,'%s','Delimiter','\t','HeaderLines',(end_hdr_row-1));
lines_endhdr = lines_endhdr{1};

fclose(fid);

fid = fopen(Filename_BW);

lines_rate = textscan(fid,'%s','Delimiter','\t','HeaderLines',(rate_row-1));
lines_rate = lines_rate{1};

fclose(fid);

fid = fopen(Filename_BW);

lines_device = textscan(fid,'%s','Delimiter','\t','HeaderLines',(device_row-1));
lines_device = lines_device{1};

fclose(fid);

% identify frame rate

freq = str2num(char(lines_rate(2)));

% identify columns that correspond to time, Fx, Fy and Fz data
k = 1;
l = 1;
m = 1;
for j = 1:length(lines_endhdr)
    if strncmp(lines_endhdr(j), 'abs time', 8)
        n = j;
    end
    
    if strncmp(lines_endhdr(j), 'Fx', 2)
        no_Fx(k) = j;
        k = k+1;
    end
    
    if strncmp(lines_endhdr(j), 'Fy', 2)
        no_Fy(l) = j;
        l = l+1;
    end
    
    if strncmp(lines_endhdr(j), 'Fz', 2)
        no_Fz(m) = j;
        m = m+1;
    end
end

% Initialize structure to contain force plate data

% Find force plate names

for i = 1:length(no_Fx)
    
name(i) = (lines_device(no_Fx(i)));

end

FPname = char(name);

for i = 1:length(no_Fz)
    
   FP_name{i} = sprintf('FP_%s', FPname(i,4));
   
end

% Initialize fieldnames

for i = 1:length(FP_name)
    FP.(FP_name{i}).time_orig = [];
    FP.(FP_name{i}).time_mod = [];
    FP.(FP_name{i}).coord = [];
end

for i = 1:length(FP_name)
    
    FP.(FP_name{i}).time_orig = DataArray(:,n);
    
    FP.(FP_name{i}).coord(:,1) = DataArray(:,no_Fx(i)); 
    FP.(FP_name{i}).coord(:,2) = DataArray(:,no_Fy(i)); 
    FP.(FP_name{i}).coord(:,3) = DataArray(:,no_Fz(i)); 
    
end


Abs_time = DataArray(:,n);
FZ7 = DataArray(:,no_Fz(m-1));


% Get 1st Rising edge of EOF after capture starts
m = 1;
for i = 1:(length(FZ7)-1)
    
    if FZ7(i+1) > 100
        if FZ7(i+1)-FZ7(i) > freq
            base_t(m,1) = i/freq;
            m = m+1;
        end
    end
end

% Get two adjustment factors

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
time_mocap = zeros(length(a),1);

m = 1;
for i = 1:no_frames
    
    for j = 1:no_markers
        time_mocap(m,1) = data(7,j,i);
        m = m+1;
    end
    
end


% Adjustment factors

fact_a = time_mocap(no_markers*2) - time_mocap(no_markers+1);
%fact_b = time_mocap(no_markers*2) - time_mocap((no_markers*2)-1);

time_zero = base_t(1) - (fact_a)/10^6;

% Modify FP Times

for i = 1:length(Abs_time)
    FP_data.time_new(i,1) = Abs_time(i,1) - time_zero;
end

for i = 1:length(FP_name)
    
    FP.(FP_name{i}).time_mod = FP_data.time_new(:,1);
    
end
