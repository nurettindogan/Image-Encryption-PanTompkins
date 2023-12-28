%% AIM: CLASSIFY THE INDEXES CORRESPONDING TO THE "R" PEAKS OF AN ECG SIGNAL. WITHOUT EXPLOITING THE SAMPLING FREQUENCY.

%% initial cleaning
clear 
close all
clc

%% hyper-parameters:
min_dist=50; % used in "exploiting biological property1"
threshold_factor=0.65; % used in "exploiting biological property2"

%% data loading
x=load('first_peak_test.dat','-ascii');


%% preprocessing.
%  set low_freq_noise == true for higly corrupted signals by low frequency noise (just number 3 of the proposed signals) 
low_freq_noise = false;
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




%% Algorithm idea:
% I compute the signal derivative approximation and I classify as peaks the points satisfying these conditions: 
% derivative zero crossing & signal amplitude close to the absolute maximum value of the signal.


%% derivative approximation by derivative filter:
b=[1 -1];
a=2; % in order to have unit gain.
d_x=filter(b,a,x_f);

%% find indexes corresponding to zero crossing 
ind_d_x_positive=find(d_x>=0); 

ind_d_x_p_succ=ind_d_x_positive+1;

ind_d_x_p_succ=ind_d_x_p_succ(ind_d_x_p_succ<length(d_x)); % to deal with the right end of the signal.

ind_d_x_negative=find(d_x<0); 


i=1;

h=1;

ind_d_x_z_cross=zeros(1,length(ind_d_x_negative)); % indexes of the closest to left point the zero crossings.

while i<=length(ind_d_x_negative)
    
    j=1;
    
    while j<=length(ind_d_x_p_succ)
    
        if ind_d_x_negative(i)==ind_d_x_p_succ(j)
            
            ind_d_x_z_cross(h)=ind_d_x_negative(i)-1; % because the derivative filter is built in a way such that
            % the maximum value is before the sample with the negative derivative
            
            h=h+1;
        
        end
        j=j+1;
    
    end
    i=i+1;
end
ind_d_x_z_cross=ind_d_x_z_cross(ind_d_x_z_cross~=0); %delete the elements present just because the creation a priori of the vector 
%(which was done to make the for more efficient).

%% find peaks: check the amplitude.
% 
max_abs=max(x_f);

ind_max=find(x_f>0.65*max_abs);

% check points appearing in both ind_max and ind_d_x_z_cross:
i=1;
h=1;
ind_peaks=zeros(1,length(ind_max));
while i<=length(ind_d_x_z_cross)
    j=1;
    while j<=length(ind_max)
        if ind_d_x_z_cross(i)==ind_max(j)
            ind_peaks(h)=ind_max(j);
            h=h+1;
        end
        j=j+1;
    end
    i=i+1;
end
ind_peaks=ind_peaks(ind_peaks~=0);  %delete the elements present just because the creation a priori of the vector 
%(which was done to make the for more efficient).




% exploiting biological property1:
% to make it robust it must checked that there are not peaks too close (it's impossible to have a certain level of heart rate).
% but since this algorithm is supposed without the information about the sampling frequency of the signal, the minimum distance 
% between peaks must be tuned. min_dist=50 has been found to be a good value.
% It is set at the beginning of the code.


i=1;
while i<length(ind_peaks)
    if ind_peaks(i+1)<=ind_peaks(i)+ min_dist
        if x_f(ind_peaks(i))>x_f(ind_peaks(i+1))
            ind_peaks(i+1)=[];
            i=i-1;
        else
            ind_peaks(i)=[];
            i=i-1; 
        end
    end
    i=i+1;
end


% exploiting biological property2:
% to make it more robust I check that between two points classified as peaks the signal has gone below a certain threshold.
% the threshold must be tuned, it has been found to be a good value th=0.65*max_abs;
% It is set at the beginning of the code.
th= threshold_factor*max_abs;

i=1;
while i<length(ind_peaks)
    v=x_f(ind_peaks(i):ind_peaks(i+1));
    v=v<th;
    if sum(v)==0
        if x_f(ind_peaks(i))>x_f(ind_peaks(i+1))
            ind_peaks(i+1)=[];
            i=i-1;
        else
            ind_peaks(i)=[];
            i=i-1;
        end
    end
    i=i+1;
end
            
  

%% result:
 plot(x_f)
 hold on
 plot(ind_peaks,x_f(ind_peaks),'r*')
