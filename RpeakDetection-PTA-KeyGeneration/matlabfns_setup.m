function matlabfns_setup
% matlabfns_setup add the library to Matlab path

basedir = fileparts(mfilename('fullpath'));

addpath(basedir);    
addpath(fullfile(basedir, 'Blender'));
addpath(fullfile(basedir, 'Colourmaps'));
addpath(fullfile(basedir, 'FingerPrints'));
addpath(fullfile(basedir, 'FrequencyFilt'));
addpath(fullfile(basedir, 'Geosci'));
addpath(fullfile(basedir, 'GreyTrans'));
addpath(fullfile(basedir, 'LineSegments'));
addpath(fullfile(basedir, 'Match'));
addpath(fullfile(basedir, 'Misc'));
addpath(fullfile(basedir, 'PhaseCongruency'));
addpath(fullfile(basedir, 'Projective'));
addpath(fullfile(basedir, 'Robust'));
addpath(fullfile(basedir, 'Rotations'));
addpath(fullfile(basedir, 'Shapelet'));
addpath(fullfile(basedir, 'Shapes'));
addpath(fullfile(basedir, 'Spatial'));
    