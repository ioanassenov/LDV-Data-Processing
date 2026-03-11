% Filename: fit_sine.m
% Author: Ioan Assenov
% Date: 2026-03-09
% Desc: This is a script that estimates multiplicative coefficients to fit
% a sine function to another one. The form of the fitted function is
% c*A*sin(2*pi/(d*T) + phi) where c, d, and phi are the weights that the
% function optimizes for through gradient descent.

function [c,d,phi] = fit_sine(t, x, A, T, phi0, lr, n_iter)
    % t - Time vector
    % x - Actual displacement
    % A, T, phi0 - Estimated amplitude, period, & phase shift
    % lr - Learning rate
    % n_iter - Iterations (epochs)

    % We are optimizing c*A*sin(2*pi/(d*T) + phi) via gradient descent.

    % Initialization
    c = 1.0; 
    d = 1.0;
    phi = phi0;
    N = length(t);
    mse_history = zeros(1, n_iter);

    for i = 1:n_iter
        theta = (2*pi / (d*T)) .* t + phi;
        x_hat = (c*A) .* sin(theta);
        r     = x - x_hat; % residuals
        mse   = mean(r.^2);
        mse_history(i) = mse;
        
        % Gradients (NEED TO BE AUDITED)
        dL_dc   = -(2/N) * sum(r .* A .* sin(theta));
        dL_dd   =  (2/N) * sum(r .* (c*A) .* cos(theta) .* (2*pi.*t / (d^2 * T)));
        dL_dphi = -(2/N) * sum(r .* (c*A) .* cos(theta));

        % Adjust parameters to move against the gradient (hence negative sign)
        c   = c   - lr * dL_dc;
        d   = d   - lr * dL_dd;
        phi = phi - lr * dL_dphi;

        % Print status message every 100 iterations
        if mod(i, 100) == 0
            semilogy(1:i, mse_history(1:i), 'b-', 'LineWidth', 1.5);
            xlabel('Iteration');
            ylabel('MSE');
            title(sprintf('Iter %d | c: %.4f | d: %.4f | phi: %.4f', i, c, d, phi));
            grid on;
            drawnow;
        end
    end
end