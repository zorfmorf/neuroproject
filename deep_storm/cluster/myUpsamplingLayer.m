classdef myUpsamplingLayer < nnet.layer.Layer

    properties
        % empty
    end

    properties (Learnable)
        % empty
    end
    
    methods
        function layer = myUpsamplingLayer(name)
            layer.Name = name;
        end
        
        function Z = predict(layer, X)
            %Z = zeros(size(X,1)*2,size(X,2)*2,size(X,3),size(X,4));
            Idx = (1:2:2*size(X,1));
           
            Z(Idx,Idx,:,:) = X;     % Only purpose:
            Z(Idx+1,Idx,:,:) = X;   % To double the dimensions of the 
            Z(Idx,Idx+1,:,:) = X;   % input-data
            Z(Idx+1,Idx+1,:,:) = X; % 8x8 becomes 16x16 eg
            %Z = single(Z);
        end

        function [dLdX] = backward(layer, X, Z, dLdZ, memory)
            dLdX = zeros(size(X,1),size(X,2),size(X,3),size(X,4));
            Idx = (1:2:2*size(X,1));
            dLdX = dLdX + dLdZ(Idx,Idx,:,:) +dLdZ(Idx+1,Idx,:,:) + ...
                dLdZ(Idx,Idx+1,:,:) +dLdZ(Idx+1,Idx+1,:,:);
        end
    end
end