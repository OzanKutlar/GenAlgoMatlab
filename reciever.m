function data = reciever(ip, maxDelay)
    url = sprintf('http://%s:%s', ip, "3753");


    % computerName = getenv('COMPUTERNAME');
    % numbers = regexp(computerName, '\d+', 'match');
    % 
    % if ~isempty(numbers)
    %     computerNumber = str2double(numbers{1});
    % else
    %     disp("Invalid Computer Name");
    % end


    minDelay = 1;
    
    
    delay = round(minDelay + (maxDelay - minDelay) * rand());
    fprintf('Delaying for %d seconds\n', delay);
    pause(delay); % Pause for the random duration to not DDOS the server.
    
    
    % options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json');
    % payload = struct('computerNo', computerNo);
    % data = webwrite(url, payload, options);
    
    data = webread(url);
    if isfield(data, 'message')
        return
    end
    
    
    % fprintf('Recieved Data : \n\tID: %d\n', data.id);
    % fprintf('\tFunction: F%d\n', data.func);
    % fprintf('\tPopulation Size: %s\n', strjoin(string(data.pop), " | "));
    % fprintf('\tNumber: %d\n', data.number);
    
    % index = 0;
    % for func = 1:height(data.func)
    %     for pop = 1:height(data.pop)
    %         for num = 1:height(data.number)
    %             index = index + 1;
    %             fprintf('Running attempt %d\n', index);
    %         end
    %     end
    % end
end