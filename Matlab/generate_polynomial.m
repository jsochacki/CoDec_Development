function [polynomial_vector] = generate_polynomial(array)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % This function takes in a cell array of generator polynomials
    % where each cell in the cell array is a different generator polynomial
    % in the form of a single row vector.
    % The multiplication of the polynomials in all of the different cells
    % is what forms the final polynomial that the user wants to use to
    % create.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Example %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [1 1 1 1 0 1] = (1*X^5 + 1*X^4 + 1*X^3 + 1*X^2 + 0*X + 1*1)
    %
    %  = (X^5+X^4+X^3+X^2+1) or [X5,X4,X3,X2,0,X0]
    %
    % [0 0 0 1 1 1] = (0*X^5 + 0*X^4 + 0*X^3 + 1*X^2 + 1*X + 1*1)
    %
    %  = (X^2+X+1)           or [0,0,0,X2,X1,X0]
    %
    % [0 0 0 0 1 1] = (0*X^5 + 0*X^4 + 0*X^3 + 0*X^2 + 1*X + 1*1)
    %
    %  = (X+1)               or [0,0,0,0,X1,X0]
    %
    % This means that we want to make a polynomial that is egual to
    % the multiplication of (X^5+X^4+X^3+X^2+1)*(X^2+X+1)*(X+1) and
    %
    % (X^5+X^4+X^3+X^2+1)*(X^2+X+1)*(X+1) = (X^8+X^7+X^6+X^4+X^2+1)
    %
    %  = [1 1 1 0 1 0 1 0 1] or [X8,X7,X6,0,X4,0,X2,0,X0]
    %
    % If this were the desired math then the user would do the following
    % 
    % array = {};
    % array{1} = [1 1 1 1 0 1];
    % array{2} = [1 1 1];
    % array{3} = [1 1];
    % result = generate_polynomial(array);
    %
    % Note the the user does not have to omit zero values of the polynomial
    % but can choose to
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Find the max order being used
    MaxLength = 0;
    for i = 1:size(array,2)
        if MaxLength < length(array{i})
            MaxLength = length(array{i});
        end
    end
    
    %zero pad all other vectors to that length so convolution result is
    %correct
    for i = 1:size(array,2)
        array{i} = [zeros(1,(MaxLength - length(array{i}))) array{i}];
    end
    
    %Generate the polynomial
    result = array{1};
    for i = 2:(size(array,2))
        result = conv(result, array{i});
    end
    result = mod(result, 2);
    
    %Truncate the polynomial to the highest order non-zero value
    i = 1;
    while result(i) == 0
        i = i + 1;
    end
    
    %Return result
    polynomial_vector = result(i:end);
end