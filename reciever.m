ip = '127.0.0.1';
port = '3753';
url = sprintf('http://%s:%s', ip, port);

minDelay = 1;
maxDelay = 10;


delay = round(minDelay + (maxDelay - minDelay) * rand());
fprintf('Delaying for %d seconds\n', delay);
% pause(delay); % Pause for the random duration to not DDOS the server.

data = webread(url);
if isfield(data, 'message')
    disp(data.message);
    !error.png
    return
end


fprintf('Recieved Data : \n\tID: %d\n', data.id);
fprintf('\tFunction: %s\n', data.func);
fprintf('\tPopulation Size: %s\n', strjoin(string(data.pop), " | "));
fprintf('\tNumber: %s\n', data.number);

index = 0;
for func = 1:height(data.func)
    for pop = 1:height(data.pop)
        for num = 1:height(data.number)
            index = index + 1;
            fprintf('Running attempt %d\n', index);
        end
    end
end
