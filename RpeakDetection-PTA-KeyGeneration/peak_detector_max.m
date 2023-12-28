% AIM: CLASSIFY THE INDEXES CORRESPONDING TO THE "R" PEAKS OF AN ECG SIGNAL. WITHOUT EXPLOITING THE SAMPLING FREQUENCY.

%% cleaning
clear all
close all
clc
%% data
x=load('first_peak_test.dat','-ascii');

%% hyper-parameters:
threshold_factor=0.7; % used to create the vector "i_above_th"

%  set low_freq_noise == true for higly corrupted signals by low frequency
%  noise (just number 3 of the proposed signals):
low_freq_noise = true;
%% preprocessing.
if low_freq_noise 
    x=x-mean(x);
    % derivative filter (high pass):
    b=[1 -1];                            
    a=2; % to have unit gain             
    x_f=filter(b,a,x);
    
    % Moving Average Filters (low pass):
    N=32;                                
    b=ones(1,N);                         
    a=N;                                 
    x_f=filter(b,a,x_f); 
else
    x_f=x;
end


%% algorithm idea:
% This is an easy idea to understand, but is not efficient.
% The steps are these
% 1) Find the absolute maximum.
% 2) For sure this is a peak, so I store it.
% 3)Replace the sample of the peak and its neighbourhood with the
% isoelectric value, in order to find another peak at the next iteration.
% 4) Repeat from one, until the maximum is above a certain threshold.
%
% The neighbourhood is not a fixed value. It depends on the maximum of the current iteration.
% it's neighbourdood is defined by all the samples between it and the first left and right values
% below the threshold.

%% Implementation:
x_f_p=x_f; % Needed because the signal will be modified.

n_max_peaks=1000; %maximum number of peaks expected. 
i_peaks=zeros(1,n_max_peaks); % this will store the peak indexes
v_peaks=zeros(1,n_max_peaks); % this will store the peak values

i=1;
while i<=n_max_peaks     
    
    [v_p,i_p]=max(x_f); % v_p and i_p are the value and index of the current peak
    th=threshold_factor*v_peaks(1);
    if i~=1 && v_p< th
        break   % If there aren't values above the threshold exit.
    
    else        
         
         x_f(i_p)=0;
         i_peaks(i)=i_p;  
         v_peaks(i)=v_p;
         
         s=i_p+1; % successive index wrt the current peak
         p=i_p-1; % previous index wrt the current peak

          % put to zero the neighbourhood:
          while (x_f(p)>th || x_f(s)>th)    
                  x_f(p)=0;
                  x_f(s)=0;
                  p=p-1;
                  s=s+1;
                  if p==0 || s==length(x_f)+1 % to deal with the left and right end of the signal.
                     break
                  end
         end
    i=i+1;
    end
end

%delete the elements present just because the creation a priori of the vector 
%(which was done to make the for more efficient):
i_peaks=i_peaks(i_peaks>0);
v_peaks=v_peaks(v_peaks>0); 

%% results:
figure('Name','p_detector_max')
plot(x_f_p)
hold on
plot(i_peaks,v_peaks,'r*')
