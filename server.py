from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import time
import sys

# Server settings
host = "127.0.0.1"
port = 3753


data_array = []




data_index = 0


RED = "\033[31m"
GREEN = "\033[32m"
RESET = "\033[0m"


def display_colored_array(data_array, data_index):
    print("\033[2J\033[H", end="")

    for index, value in enumerate(data_array):
        if index < data_index:
            print(f"{GREEN}{index + 1}{RESET}", end=" ")
        else:
            print(f"{RED}{index + 1}{RESET}", end=" ")

    
    print(f"\n\n")
    # print(f"\n\nCurrent data index: {data_index}")


class MyRequestHandler(BaseHTTPRequestHandler):
    global data_index
    
    def do_GET(self):
        global data_index

        if data_index < len(data_array):
            response_data = data_array[data_index]
            data_index += 1
            display_colored_array(data_array, data_index)
        else:
            data_index += 1
            response_data = {"message": "No more data left."}
            print(f'Data Distribution is finished. Extra connections : ', (data_index - len(data_array)))

            # data_index = 0
            # response_data = data_array[data_index]
        
        response_json = json.dumps(response_data)
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(response_json.encode('utf-8'))



# ChatGPT generated this. When an input object with arrays for parameters is given in,
# It generates all combinations of those parameters as seperate objects.
def generate_combinations(input_obj):
    # Get the keys and values from the input object
    keys = list(input_obj.keys())
    values = list(input_obj.values())

    # Initialize the ID counter
    id_counter = 1

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
    
    return result



def display_object_attributes(arr):
    for obj in arr:
        print()
        for attribute, value in obj.items():
            print(f"  {attribute}: {value}")
        print()  # For spacing between objects



def run_server():
    server_address = (host, port)
    httpd = HTTPServer(server_address, MyRequestHandler)
    print(f"Server running on {host}:{port}")
    httpd.serve_forever()


all_params = {
    "algo": ["PSO"],
    "FE": [50000, 1000],
    "pop": [100, 200, 300]
}


if __name__ == "__main__":
    os.system("cls")
    if len(sys.argv) > 1:
        data_index = int(sys.argv[1])
    else:
        data_index = 0
    data_array = generate_combinations(all_params)
    display_colored_array(data_array, data_index)
    # display_object_attributes(data_array)
    run_server()
