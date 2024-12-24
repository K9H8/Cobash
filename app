#!/usr/bin/env python3

from openai import OpenAI
import subprocess
import sys
sys.path.append('/home/kali/Desktop/Documents/Projects/cobash/')

from vtt import mic_to_text_auto_stop

# Set API key in client
client = OpenAI(
    api_key="OpenAi-Key")
# set system message !TODO 
system_message = """
You are a assistant specialized in generating terminal commands and explanations for cybersecurity tasks using Kali Linux. When given a prompt, accurate terminal command or an explanation tailored for a cybersecurity.

- if im asking for a command, reply exactly with: $1=2<command>, example: (request: can you ping google reply: "$1=2ping 8.8.8.8)" 
- if you're short of info ask me instead.
- If i ask for an explanation, give two sentences.
"""

# Initialize conversation history
conversation_history = [
    {"role": "system", "content": system_message}
]


# Define the prompt using messages
def ask_gpt(query):
    # Add user query to conversation history
    conversation_history.append({"role": "user", "content": query})

    # Make the chat completion request
    response = client.chat.completions.create(
        model="gpt-4o",
        max_tokens=250,
        temperature=0.5,
        messages=conversation_history
    )

    # Add assistant response to conversation history
    assistant_response = response.choices[0].message.content
    conversation_history.append({"role": "assistant", "content": assistant_response})

    return assistant_response

# Main function to handle user input and processing
def main():
    if len(sys.argv) > 1:
        # Handle command-line arguments as a single query
        query = " ".join(sys.argv[1:])
        response = ask_gpt(query)
        handle_response(query, response)

    else:
        # Interactive mode
        while True:
            query = input("\n")
            if query == "v":
                query = mic_to_text_auto_stop()

            elif query.lower() in ["exit", "quit"]:
                subprocess.run("echo 'Goodbye!'", shell=True)
                break

            if query:
                response = ask_gpt(query)

                handle_response(query, response)
            else :
                print("Empty request\n")
# Function to handle the response from GPTa
def handle_response(query, response):
    if response.startswith("$1=2"):
        command = response[4:].strip()
        subprocess.run(f"echo 'Executing command: {command}'", shell=True)
        try:
            command_output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT, text=True)
            print(command_output)
            conversation_history.append({"role": "assistant", "content": f"Command output: {command_output}"}) 
        except:
            error_output = e.output
            print(f"Error executing command: {error_output}")
            conversation_history.append({"role": "assistant", "content": f"Error output: {error_output}"})

    else:

        # Output the explanation or any non-command response
        print(response)

if __name__ == "__main__":
    main()
