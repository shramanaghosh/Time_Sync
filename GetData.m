% Imports standard text files exported by force plate and motion capture system
% and creates two workspace variables which conatin the relevant data.
% 
% 
% For synchronization the time of capture of the 2nd frame of the motion
% tracking is set to zero and the force plates capture times are modified
% to reflect the same.
%
%%

clear;
clc;

tic;
% Enter name of text file exported by Bioware
Filename_BW = 'DataFile_BW_5.txt';

% Enter name of text file exported by VZSoft
Filename_VZ = 'DataFile_VZ_5.txt';

% Get Force plate data
[FP] = load_fp_file(Filename_BW, Filename_VZ);

% Get Motion Capture data
[marker] = load_mocap_file(Filename_VZ);

toc;