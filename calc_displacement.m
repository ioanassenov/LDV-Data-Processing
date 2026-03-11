function x = calc_displacement(data)
    % data - Data table with columns: Time | V_in | V_LDV
    time = data.Time;
    vldv = data.V_LDV;

    gain = 0.125;
    t = seconds(time); % Convert duration type into float
    norm_V_LDV = vldv - mean(vldv);
    
    % Define bandpass filter
    GHPF = tf([180000 0],[1 2*pi*100]); % High pass frequency
    GLPF = tf([0 1], [1 2*pi*30e3]);    % Low pass frequency
    
    % Filter velocity
    % velocity = norm_V_LDV;
    velocity = lsim(GHPF*GLPF, norm_V_LDV, t);
    
    % velocity = bandpass(norm_V_LDV,[100 30e3],fs); % The built-in bandpass is strange
    velocity = velocity*gain;
    % velocity = norm_V_LDV*gain;
    time_step = 1e-5;
    prev_x = 0;
    x = zeros(1, length(velocity));
    
    for i = 1:length(velocity)
        x(i) = velocity(i)*time_step + prev_x;
        prev_x = x(i);
    end
end