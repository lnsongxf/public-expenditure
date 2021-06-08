%=======================================================================
% transform the array from monthly frequency to quarterly frequency.
% assumes always starts in january and finishes in december (number of observations can be divided by 3)
% observation must be in columns
%=======================================================================

function result=quarterly(data)

[row,column]=size(data);
L=reshape(data,3,row/3,column);
M=mean(L,1);
result=shiftdim(M);