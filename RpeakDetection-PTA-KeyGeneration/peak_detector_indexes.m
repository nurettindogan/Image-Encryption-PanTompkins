% AIM: CLASSIFY THE INDEXES CORRESPONDING TO THE "R" PEAKS OF AN ECG SIGNAL. WITHOUT EXPLOITING THE SAMPLING FREQUENCY.

%% cleaning
clear all
close all
clc

%% data
x=load('second_peak_test.dat','-ascii');

%% hyper-parameters:
threshold_factor=0.7; %used to create the vector "i_above_th"

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


%% Algorithm Idea:
%idea: 
% I scan the signal. I store the region of CONTIGUOUS SAMPLES ABOTHE THE
% THRESHOLD. For each region I store the maximum. Those are the peaks.
% (If two regions are too close bacause of high frequency noise, so they
% must be merged because they actually belong to the same QRS complex).

max_abs=max(x_f);
i_above_th=find(x_f>threshold_factor*max_abs); % samples above the threshold

[v_min,i_min]=min(x_f);
i_peaks=ones(1,length(i_above_th)).*i_min;  %vector which will contain peak indexes
v_peaks=zeros(1,length(i_above_th)); %vector which will contain peak values

i=1;
j=1;
while i<length(i_above_th)
   
    if i_above_th(i+1)==i_above_th(i)+1  % if the indexes are contiguous:
       if x_f(i_above_th(i))>x_f(i_peaks(j)) % & if the value is bigger than the last registred maximum among the contiguous samples:          
           i_peaks(j)=i_above_th(i); %store the index 
           v_peaks(j)=x_f(i_above_th(i)); % store the value 
          
       
       end
       % problem: because of high frequency nois it's possible that samples belonging to the 
       % same QRS complex are not contiguous. So I need to merge the results of these intervals 
       % which have been revealed as separeted. To identify them I check the distance between the samples classified as peaks.
       % If the distance < min_dist then I save only the maximum among
       % them. The min dist is the distance between the onlt R peak which I
       % am sure to find (the mximum absolute of the signal) and the
       % isoelectric line (where the value=0). (this makes the algorithm
       % not robust in case od patient subject to fibrillation).
       
       min_dist=min(abs(find(x_f<0.1*i_peaks(1))-i_peaks(1)));
       
       if j>1 & i_peaks(j)<i_peaks(j-1)+ min_dist % if the peaks are two close:
           if x_f(i_peaks(j))>x_f(i_peaks(j-1)) % I save only the maximum between the two.
              i_peaks(j-1)=i_peaks(j);
              v_peaks(j-1)=x_f(i_peaks(j));
           end
           j=j-1; % trick to substitute in the next step the peak to be removed (or the copy of the one to keep).
          
       end
       
       
    else 
       j=j+1;
    
    end
    i=i+1;
end

%delete the elements present just because the creation a priori of the vector 
%(which was done to make the for more efficient):
i_peaks=i_peaks(i_peaks~=i_min);
v_peaks=v_peaks(v_peaks~=0);



%% results
plot(x_f)
hold on
plot(i_peaks,v_peaks,'r*')