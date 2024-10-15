% MATLAB Code to Send GET Request and Extract 'id' and 'test'

% Define the IP address and port
ip = '127.0.0.1';
port = '3753';
url = sprintf('http://%s:%s', ip, port);

% Send a GET request to the server
data = webread(url);

if(isfield(data, 'message'))
    disp(data.message);
    return
end
fprintf('ID: %d\n', data.id);
fprintf('Function: %s\n', data.func);
fprintf('Population Size: %s\n', data.pop);
fprintf('Number: %s\n', data.number);