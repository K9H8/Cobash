import os
from openai import OpenAI

# Set api key in client.
api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(
    api_key=api_key
)

# Initialize conversation history
conversation_history = [
    {"role": "system", "content": "You are an assistant."}
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
    conversation_history.append({"role": "system", "content": assistant_response})

    # Print the response
    print(assistant_response)

# Get user input and ask GPT
while True:
    query = input("You: ")
    if query.lower() in ["exit", "quit"]:
        print(conversation_history)
        break
    ask_gpt(query)

