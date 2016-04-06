function block_size = CurrentBlockSize(nrow,ncol,patch_size,overlap,i,j)

U = ceil((nrow-overlap)/(patch_size-overlap)); 
V = ceil((ncol-overlap)/(patch_size-overlap));

if i == U && j == V
    block_size = [nrow-patch_size+1 nrow ncol-patch_size+1 ncol];
elseif i == U
    block_size = [nrow-patch_size+1 nrow ((patch_size-overlap)*j-(patch_size-overlap-1)) ((patch_size-overlap)*j+overlap)];
elseif j == V
    block_size = [((patch_size-overlap)*i-(patch_size-overlap-1)) (patch_size-overlap)*i+overlap ncol-patch_size+1 ncol];
else
    block_size = [((patch_size-overlap)*i-(patch_size-overlap-1)) (patch_size-overlap)*i+overlap ((patch_size-overlap)*j-(patch_size-overlap-1)) ((patch_size-overlap)*j+overlap)];
end