function [syn_mat ] = sampler( opts, config, net_cpu, iter, z )
%Used to visulize the images generated by generator network

% set up initial z
net = vl_simplenn_move(net_cpu, 'gpu');
fz = vl_simplenn(net, gpuArray(z), [], [], ...
    'accumulate', false, ...
    'disableDropout', true, ...
    'conserveMemory', opts.conserveMemory, ...
    'backPropDepth', opts.backPropDepth, ...
    'sync', opts.sync, ...
    'cudnn', opts.cudnn);
syn_mat = gather(fz(end).x);
draw_figures(config, syn_mat, iter);

if iter == config.nIteration && config.is_texture == false
    % we draw the interpolation result
    Z = zeros(1, 1, config.z_dim, config.interp_dim*config.interp_dim, 'single');
    z1 = linspace(-2, 2, config.interp_dim);
    z2 = linspace(-2, 2, config.interp_dim);
    [X,Y] = meshgrid(z1,z2);
    Z(1,1,1,:) = X(:);
    Z(1,2,1,:) = Y(:);
    %Z(1,1,1,:) = X(:);
    %Z(1,1,2,:) = Y(:);
    fz_interp = vl_simplenn(net, gpuArray(Z), [], [], ...
        'accumulate', false, ...
        'disableDropout', true, ...
        'conserveMemory', opts.conserveMemory, ...
        'backPropDepth', opts.backPropDepth, ...
        'sync', opts.sync, ...
        'cudnn', opts.cudnn);
    syn_mat_interp = gather(fz_interp(end).x);
    [I_syn_interp, syn_mat_norm_interp] = convert_syns_mat(config, syn_mat_interp);
    imwrite(I_syn_interp,[config.Synfolder,  num2str(iter, 'dense_interpolation_%04d'), '.png']);
end



end
