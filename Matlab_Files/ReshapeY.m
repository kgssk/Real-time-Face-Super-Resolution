function X = ReshapeY(Y,block_size)

patch_size = block_size(2)-block_size(1)+1;
Y_patch = Y(block_size(1):block_size(2),block_size(3):block_size(4),:);
X = reshape(Y_patch,patch_size*patch_size,size(Y,3));