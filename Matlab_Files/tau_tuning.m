% =========================================================================
% MSc Project
% Face Super Resolution
% TAU Tuning
% MATLAB code
% =========================================================================

close all; clear all;
addpath /Users/sikansun/Desktop/MSc_project/new_img/Tuning
addpath /Users/sikansun/Desktop/MSc_project/new_img/Database
load tau_tunning_data.mat
ncol = 100;
nrow = 100;
upscale = 4;
nTuning = 20;
nTraining = 350;
patch_size = 12;
overlap = 4;

YH = zeros(nrow,ncol,nTraining); 
YL = zeros(nrow/upscale,ncol/upscale,nTraining); 

sr_psnr = zeros(1,10);
sr_ssim = zeros(1,10);
avg_sr_psnr = zeros(1,10);
avg_sr_ssim = zeros(1,10);

for L = 1:length(tau_data)
    tau = tau_data(L);
    fprintf('tau = %f \n', tau);

    % construct the HR and LR training pairs from database
for k = 1:nTuning
    strt = strcat('tune_',num2str(k,'%05d'),'.jpg');
    im_h    = imread(strt);
    im_l    = imresize(im_h,1/upscale);
for n = 1:nTraining
    % read HR images from the HR image training set
    strh = strcat('data_',num2str(n,'%05d'),'.jpg');
    HI = double(imread(strh));
    YH(:,:,n) = HI;
    
    % generate LR images from the HR image training set
    LI = imresize(HI,1/upscale);
    YL(:,:,n) = LI;
end

XH_sum = zeros(nrow,ncol);
overlap_flag = zeros(nrow,ncol);

U = ceil((nrow-overlap)/(patch_size-overlap)); 
V = ceil((ncol-overlap)/(patch_size-overlap));

% hallucinate the HR image patch by patch
for i = 1:U
    for j = 1:V
        block_size = CurrentBlockSize(nrow,ncol,patch_size,overlap,i,j);
        block_sizes = CurrentBlockSize(nrow/upscale,ncol/upscale,patch_size/upscale,overlap/upscale,i,j);
        % extract the patch at position (i,j) of the input LR image
        im_l_patch = im_l(block_sizes(1):block_sizes(2),block_sizes(3):block_sizes(4));
        % reshape 2D image patch into 1D column vectors
        im_l_patch = double(reshape(im_l_patch,patch_size*patch_size/(upscale*upscale),1));
        
        YH_s = ReshapeY(YH,block_size);     % reshape each patch of HR face to one column
        YL_s = ReshapeY(YL,block_sizes);    % reshape each patch of LR face to one column
        
        % represent the LR patch at position (i,j)
        nframe = size(im_l_patch',1);
        nbase = size(YL_s',1);
        XX = sum(im_l_patch'.*im_l_patch',2);
        YX = sum(YL_s'.*YL_s',2);
        D = repmat(XX,1,nbase)-2*im_l_patch'*YL_s+repmat(YX',nframe,1); % calculate the distance between input LR patch and the LR training patches at position (i,j)
        
        % compute the optimal weight numbers
        C = YL_s'-repmat(im_l_patch',nTraining,1);
        G = C*C';
        G = G+tau*diag(D);
        w = G\ones(nTraining,1);
        w = w/sum(w);  % set the sum of w equal to 1 to get the optimal w weight vector
        
        % reconstruct the HR patchs
        XH = YH_s*w;
        
        % integrate all the LR patches
        XH = reshape(XH,patch_size,patch_size);
        XH_sum(block_size(1):block_size(2),block_size(3):block_size(4)) = XH_sum(block_size(1):block_size(2),block_size(3):block_size(4))+XH;
        overlap_flag(block_size(1):block_size(2),block_size(3):block_size(4)) = overlap_flag(block_size(1):block_size(2),block_size(3):block_size(4))+1;
    end
end

% averaging pixel values in overlap areas
im_sr = XH_sum./overlap_flag;
im_sr = uint8(im_sr);

sr_psnr(k) = psnr(im_sr,im_h);
sr_ssim(k) = ssim(im_sr,im_h); 
end

% calculate average PSNR and SSIM
avg_sr_psnr(L) = sum(sr_psnr)/nTuning;
avg_sr_ssim(L) = sum(sr_ssim)/nTuning;

fprintf('Average PSNR: %f dB\n', avg_sr_psnr(L));
fprintf('Average SSIM: %f dB\n', avg_sr_ssim(L));
end

% plot the performance for different values of tau
figure; semilogx(tau_data, avg_sr_psnr,'*-'); xlabel('Regularisation Parameter \tau'); ylabel('PSNR (dB)');
figure; semilogx(tau_data, avg_sr_ssim,'o-'); xlabel('Regularisation Parameter \tau'); ylabel('SSIM (dB)');