#!/usr/bin/env python3

from openai import OpenAI
import subprocess
import sys

# Set API key in client
client = OpenAI(
    api_key="OpenAI-API-Key"
)
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
            if query.lower() in ["exit", "quit"]:
                subprocess.run("echo 'Goodbye!'", shell=True)
                break
            response = ask_gpt(query)
            handle_response(query, response)

# Function to handle the response from GPT
def handle_response(query, response):
    if response.startswith("$1=2"):
        command = response[4:].strip()
        subprocess.run(f"echo 'Executing command: {command}'", shell=True)
        try:
            subprocess.run(command, shell=True, check=True)
        except:
            subprocess.run(["echo", f"Error executing command"])
    else:
        # Output the explanation or any non-command response
        subprocess.run(f"echo '{response}'", shell=True)

if __name__ == "__main__":
    main()
