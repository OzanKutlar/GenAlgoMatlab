from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import time
import sys
import threading
import base64

# Server settings
host = "0.0.0.0"
port = 3753


data_array = []
completed_array = []
givenToPC = []

data_index = []

RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
Blue = "\033[34m"
Magenta = "\033[35m"
Cyan = "\033[36m"
RESET = "\033[0m"


ROWS_PER_COLUMN = 40  # Number of rows that fit into a single terminal column
COLUMN_DIST = 30

def display_colored_array(data_array):
    print("\033[2J\033[H", end="")  # Clear the screen

    # Determine number of columns needed
    total_rows = len(data_array)
    num_columns = (total_rows + ROWS_PER_COLUMN - 1) // ROWS_PER_COLUMN

    # Prepare table data
    columns = [[] for _ in range(num_columns)]
    for index, value in enumerate(data_array):
        column_index = index // ROWS_PER_COLUMN
        row_index = index % ROWS_PER_COLUMN

        # Determine status color and format value
        status_color = (GREEN if (completed_array[index] == True) else (RED if givenToPC[index] == '' else Magenta)) if index < len(givenToPC) else RED
        status = f"{status_color}{index + 1}{RESET}"
        pc_value = f"{YELLOW}({givenToPC[index]}){RESET}" if index < len(givenToPC) else f"{YELLOW}(N/A){RESET}"

        # Append row to the appropriate column
        columns[column_index].append(f"{status} {pc_value}")

    # Print the data in columns
    for row in range(ROWS_PER_COLUMN):
        for col in range(num_columns):
            if row < len(columns[col]):  # Check if this row exists in the column
                print(f"{columns[col][row]:<{COLUMN_DIST}}", end="")  # Adjust padding for alignment
        print()  # Newline for the next row
        
    print("Enter command (type 'quit' to stop): ")


class MyRequestHandler(BaseHTTPRequestHandler):
    global data_index
    
    def do_GET(self):
        global data_index
        
        computer_name = self.headers.get('ComputerName', '%ComputerName%')
        last = data_index.pop()
        if not data_index:
            data_index.append(last + 1)
        if last < len(data_array):
            response_data = data_array[last]
            if last == len(givenToPC):
                givenToPC.append(computer_name)
            else:
                givenToPC[last] = computer_name
            if last == len(completed_array):
                completed_array.append(False)
            else:
                completed_array[last] = False
            display_colored_array(data_array)
            print(f"Data {last+1} has been sent to {computer_name}")
        else:
            response_data = {"message": "No more data left."}
            print(f'Data Distribution is finished. Extra connections : ', (last - len(data_array)))
        
        response_json = json.dumps(response_data)
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(response_json.encode('utf-8'))

    def do_POST(self):
        # try:
            ID = self.headers.get('ID', '-1')
            if(ID != '-1'):
                print("ID " + ID + " is finished.")
                completed_array[int(ID) - 1] = True
                
            content_length = int(self.headers['Content-Length'])
            if content_length <= 0:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b"No content received.")
                return
            # Get the content length from headers

            # Read the incoming JSON payload
            post_data = self.rfile.read(content_length).decode('utf-8')

            # Parse JSON data
            json_data = json.loads(post_data)

            # Extract file data and name
            file_name = json_data.get('file_name')
            file_content_base64 = json_data.get('file')
            
            if not os.path.exists("data"):
                os.makedirs("data")

            if not file_name or not file_content_base64:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b"Missing 'file_name' or 'file' in JSON payload")
                return

            # Decode the Base64-encoded file content
            try:
                file_content = base64.b64decode(file_content_base64)
            except Exception as e:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b"Invalid Base64 content in 'file'")
                return

            # Save the file to disk
            with open("data/" + file_name, 'wb') as f:
                f.write(file_content)

            # Send a success response
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"File uploaded and saved successfully")



# ChatGPT generated this. When an input object with arrays for parameters is given in,
# It generates all combinations of those parameters as seperate objects.
def generate_combinations(input_obj, id_counter):
    # Get the keys and values from the input object
    keys = list(input_obj.keys())
    values = list(input_obj.values())


    # Recursive function to generate combinations
    def combine(index, current_combination):
        nonlocal id_counter  # To modify the outer variable inside the inner function
        
        # Base case: when the index reaches the end of the keys
        if index == len(keys):
            # Add the current ID to the combination
            current_combination['id'] = id_counter
            result.append(current_combination.copy())
            id_counter += 1  # Increment the ID for the next combination
            return

        # Iterate over all values for the current key
        for value in values[index]:
            current_combination[keys[index]] = value
            combine(index + 1, current_combination)
    
    # List to store all combinations
    result = []

    combine(0, {})
    
    return [result, id_counter]



def display_object_attributes(arr):
    for obj in arr:
        print()
        for attribute, value in obj.items():
            print(f"  {attribute}: {value}")
        print()  # For spacing between objects



def merge_objects(dict1, dict2): 
    merged = dict1.copy() 
    merged.update(dict2) 
    return merged
    

shared_params = {
    "task":["DTLZ1", "secondTask", "thirdTask"],
    "FE": [50000, 1000],
    "pop": [100, 200, 300]
}

ga_params = {
    "algo": ["ga"],
    "mut": [-1.0, 0.2, 0.4, 0.6],
    "cross": [0.5, 0.419, 0.381],
    "elitist": ["elitist_full", "non-elitist"]

}

de_params = {
    "algo": ["de"],
    "variant": [1, 2, 3, 4, 5, 6],
    "scalingFactor": [0.5, 0.75, 1.0]
    
}

pso_params = {
    "algo": ["pso"],
    "omega": [0.6, 0.8, 1.0],
    "cognitiveConstant": [0.5, 2.5, 5.0],
    "socialConstant": [0.5, 2.5, 5.0]

}

bbbc_params = {
    "algo": ["bbbc"]

}

def print_list_as_json(lst): 
    json_str = json.dumps(lst, indent=4) 
    print(json_str)
   
def start_server(server):
    print(f"Server running on {server.server_address[0]}:{server.server_address[1]}")
    server.serve_forever()

if __name__ == "__main__":
    os.system("cls")
    if len(sys.argv) > 1:
        data_index.append(int(sys.argv[1]) - 1)
        if(data_index[-1] < 0):
            data_index[-1] = 0
        for i in range(data_index[-1]):
            givenToPC.append("PRE")
            completed_array.append(True)
    else:
        data_index.append(0)
    # print(data_index[-1])
    id_counter = 1
    [data_arrayGA, id_counter] = generate_combinations(merge_objects(shared_params, ga_params), id_counter)
    [data_arrayDE, id_counter] = generate_combinations(merge_objects(shared_params, de_params), id_counter)
    [data_arrayPSO, id_counter] = generate_combinations(merge_objects(shared_params, pso_params), id_counter)
    [data_arrayBBBC, id_counter] = generate_combinations(merge_objects(shared_params, bbbc_params), id_counter)
    data_array = data_arrayGA + data_arrayDE + data_arrayPSO + data_arrayBBBC
    # print_list_as_json(data_array)
    # display_object_attributes(data_array)
    # exit()
    server = HTTPServer((host, port), MyRequestHandler)

    server_thread = threading.Thread(target=start_server, args=(server,), daemon=True)
    server_thread.start()

    try:
        while True:
            display_colored_array(data_array)
            user_input = input()
            if user_input.lower() == 'quit':
                print("Shutting down the server...")
                server.shutdown()
                server.server_close()
                server_thread.join()
                print("Server stopped.")
                break
            elif user_input.startswith('print '):
                try:
                    # Extract index from the command
                    index = int(user_input.split()[1]) - 1
                    if 0 <= index < len(data_array):
                        # Convert the data at index to JSON and print it
                        print(json.dumps(data_array[index], indent=2))
                        input()
                    else:
                        print(f"Index {index+1} is out of bounds. Array length is 1-{len(data_array)}.")
                except (IndexError, ValueError):
                    print("Invalid command format. Use 'print x', where x is a valid index.")
            elif user_input.startswith('reset '):
                try:
                    # Extract index from the command
                    index = int(user_input.split()[1]) - 1
                    if 0 <= index < len(givenToPC):
                        # print(json.dumps(data_array[index], indent=2))
                        data_index.append(index)
                        givenToPC[index] = ''
                        completed_array[index] = False
                        display_colored_array(data_array)
                    else:
                        print(f"Index {index+1} is out of bounds. Array length is 1-{len(givenToPC)}.")
                except (IndexError, ValueError):
                    print("Invalid command format. Use 'list x', where x is a valid index.")
    except KeyboardInterrupt:
        print("\nKeyboardInterrupt detected. Shutting down the server...")
        server.shutdown()
        server.server_close()
        server_thread.join()
        print("Server stopped.")