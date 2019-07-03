classdef upsamplingLayer < nnet.layer.Layer

    properties
        % (Optional) Layer properties.
%         name = ("upsamplingLayer");
%         description = ("It simply doubles the dimention of the Input.");
        % Layer properties go here.
    end

    properties (Learnable)
        % (Optional) Layer learnable parameters.
        % I DONT NEED THIS
        % Layer learnable parameters go here.
    end
    
    methods
        function layer = upsamplingLayer(name)
            % (Optional) Create a myLayer.
            % This function must have the same name as the layer.
            layer.Name = name;
            
            % Layer constructor function goes here.
        end
        
        function Z = predict(layer, X)
            % Forward input data through the layer at prediction time and
            % output the result.
            %
            % Inputs:
            %         layer    -    Layer to forward propagate through
            %         X        -    Input data
            % Output:
            %         Z        -    Output of layer forward function
%             X = double(X);
            Z = zeros(size(X,1)*2,size(X,2)*2,size(X,3),size(X,4));
            Idx = (1:2:2*size(X,1));
           
            Z(Idx,Idx,:,:) = X;
            Z(Idx+1,Idx,:,:) = X;
            Z(Idx,Idx+1,:,:) = X;
            Z(Idx+1,Idx+1,:,:) = X;
            Z = single(Z);
            
            % Layer forward function for prediction goes here.
        end

%         function [Z, memory] = forward(layer, X)
            % (Optional) Forward input data through the layer at training
            % time and output the result and a memory value.
            %
            % Inputs:
            %         layer  - Layer to forward propagate through
            %         X      - Input data
            % Outputs:
            %         Z      - Output of layer forward function
            %         memory - Memory value for backward propagation

            % Layer forward function for training goes here.
%         end

function [dLdX] = backward(layer, X, Z, dLdZ, memory)
    dLdX = zeros(size(X,1),size(X,2),size(X,3),size(X,4));
    Idx = (1:2:2*size(X,1));
    dLdX = dLdX + dLdZ(Idx,Idx,:,:) +dLdZ(Idx+1,Idx,:,:) + ...
        dLdZ(Idx,Idx+1,:,:) +dLdZ(Idx+1,Idx+1,:,:);
%     dLdX = dLdX./4;
            % [dLdX, dLdW1, dLdWn] = backward(layer, X, Z, dLdZ, memory)
            % Backward propagate the derivative of the loss function through 
            % the layer.
            %
            % Inputs:
            %         layer             - Layer to backward propagate through
            %         X                 - Input data
            %         Z                 - Output of layer forward function            
            %         dLdZ              - Gradient propagated from the deeper layer
            %         memory            - Memory value from forward function
            % Outputs:
            %         dLdX              - Derivative of the loss with respect to the
            %                             input data
            %         dLdW1, ..., dLdWn - Derivatives of the loss with respect to each
            %                             learnable parameter
            
            % Layer backward function goes here.
        end
    end
end