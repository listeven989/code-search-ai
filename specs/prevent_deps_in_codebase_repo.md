## human

```md
proof of concept:
summarize each file

summarize each folder

store the summarizations into a json

run cosine similarity search on it

implementation ideas
possibly could be done as a single typescript file in a codebase

has the logic for everything in "proof of concept"

runs through 5-10 queries as test cases on the search

user can just run ts-node code-search.ts to see if it works

would be great to do on a larger codebase
```

instead of typescript i want the best setup experience possible give me the programming language or framework to use

the reason typescript might not be ideal is because it'd require installing npm packages to an exising repo and that existing repo might not be a node/npm package e.g. what if its golang? i don't want unnecesary npm packages mucking it up

what are some other options? a modal runtime software? or something else?

## chat

Based on your requirements, I suggest using a standalone Python script. Python is a versatile language with a rich ecosystem of libraries, and it's easy to set up and run on most systems. You can use the following libraries for your proof of concept:

1. `os` and `os.path` for file and folder traversal.
2. `json` for storing summarizations into a JSON file.
3. `scikit-learn` for cosine similarity search.

Here's a high-level outline of the script:

```python
import os
import json
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def summarize_file(file_path):
    # Implement file summarization logic here
    pass

def summarize_folder(folder_path):
    # Implement folder summarization logic here
    pass

def store_summarizations(summarizations, output_file):
    with open(output_file, 'w') as f:
        json.dump(summar...
```
  
## human

but itd still install these python packages into the repo though right? what if its a node repo? or a golang repo? i don't want a bunch of 
python packages in there

## human

```
import sys
import os
import modal
import ast

stub = modal.Stub("smol-developer-v1")
generatedDir = "generated"
openai_image = modal.Image.debian_slim().pip_install("openai", "tiktoken")
openai_model = "gpt-4" # or 'gpt-3.5-turbo',
openai_model_max_tokens = 2000 # i wonder how to tweak this properly


@stub.function(
    image=openai_image,
    secret=modal.Secret.from_dotenv(),
    retries=modal.Retries(
        max_retries=3,
        backoff_coefficient=2.0,
        initial_delay=1.0,
    ),
    # concurrency_limit=5,
    # timeout=120,
)
def generate_response(system_prompt, user_prompt, *args):
    import openai
    import tiktoken

    def reportTokens(prompt):
        encoding = tiktoken.encoding_for_model(openai_model)
        # print number of tokens in light gray, with first 10 characters of prompt in green
        print("\033[37m" + str(len(encoding.encode(prompt))) + " tokens\033[0m" + " in prompt: " + "\033[92m" + prompt[:50] + "\033[0m")
        

    # Set up your OpenAI API credentials
    openai.api_key = os.environ["OPENAI_API_KEY"]

    messages = []
    messages.append({"role": "system", "content": system_prompt})
    reportTokens(system_prompt)
    messages.append({"role": "user", "content": user_prompt})
    reportTokens(user_prompt)
    # loop thru each arg and add it to messages alternating role between "assistant" and "user"
    role = "assistant"
    for value in args:
        messages.append({"role": role, "content": value})
        reportTokens(value)
        role = "user" if role == "assistant" else "assistant"

    params = {
        "model": openai_model,
        "messages": messages,
        "max_tokens": openai_model_max_tokens,
        "temperature": 0,
    }

    # Send the API request
    response = openai.ChatCompletion.create(**params)

    # Get the reply from the API response
    reply = response.choices[0]["message"]["content"]
    return reply


@stub.function()
def generate_file(filename, filepaths_string=None, shared_dependencies=None, prompt=None):
    # call openai api with this prompt
    filecode = generate_response.call(
        f"""You are an AI developer who is trying to write a program that will generate code for the user based on their intent.
        
    the app is: {prompt}

    the files we have decided to generate are: {filepaths_string}

    the shared dependencies (like filenames and variable names) we have decided on are: {shared_dependencies}
    
    only write valid code for the given filepath and file type, and return only the code.
    do not add any other explanation, only return valid code for that file type.
    """,
        f"""
    We have broken up the program into per-file generation. 
    Now your job is to generate only the code for the file {filename}. 
    Make sure to have consistent filenames if you reference other files we are also generating.
    
    Remember that you must obey 3 things: 
       - you are generating code for the file {filename}
       - do not stray from the names of the files and the shared dependencies we have decided on
       - MOST IMPORTANT OF ALL - the purpose of our app is {prompt} - every line of code you generate must be valid code. Do not include code fences in your response, for example
    
    Bad response:
    ```javascript 
    console.log("hello world")
    ```
    
    Good response:
    console.log("hello world")
    
    Begin generating the code now.

    """,
    )

    return filename, filecode


@stub.local_entrypoint()
def main(prompt, directory=generatedDir, file=None):
    # read file from prompt if it ends in a .md filetype
    if prompt.endswith(".md"):
        with open(prompt, "r") as promptfile:
            prompt = promptfile.read()

    print("hi its me, 🐣the smol developer🐣! you said you wanted:")
    # print the prompt in green color
    print("\033[92m" + prompt + "\033[0m")

    # example prompt:
    # a Chrome extension that, when clicked, opens a small window with a page where you can enter
    # a prompt for reading the currently open page and generating some response from openai

    # call openai api with this prompt
    filepaths_string = generate_response.call(
        """You are an AI developer who is trying to write a program that will generate code for the user based on their intent.
        
    When given their intent, create a complete, exhaustive list of filepaths that the user would write to make the program.
    
    only list the filepaths you would write, and return them as a python list of strings. 
    do not add any other explanation, only return a python list of strings.
    """,
        prompt,
    )
    print(filepaths_string)
    # parse the result into a python list
    list_actual = []
    try:
        list_actual = ast.literal_eval(filepaths_string)

        # if shared_dependencies.md is there, read it in, else set it to None
        shared_dependencies = None
        if os.path.exists("shared_dependencies.md"):
            with open("shared_dependencies.md", "r") as shared_dependencies_file:
                shared_dependencies = shared_dependencies_file.read()

        if file is not None:
            # check file
            print("file", file)
            filename, filecode = generate_file(file, filepaths_string=filepaths_string, shared_dependencies=shared_dependencies, prompt=prompt)
            write_file(filename, filecode, directory)
        else:
            clean_dir(directory)

            # understand shared dependencies
            shared_dependencies = generate_response.call(
                """You are an AI developer who is trying to write a program that will generate code for the user based on their intent.
                
            In response to the user's prompt:

            ---
            the app is: {prompt}
            ---
            
            the files we have decided to generate are: {filepaths_string}

            Now that we have a list of files, we need to understand what dependencies they share.
            Please name and briefly describe what is shared between the files we are generating, including exported variables, data schemas, id names of every DOM elements that javascript functions will use, message names, and function names.
            Exclusively focus on the names of the shared dependencies, and do not add any other explanation.
            """,
                prompt,
            )
            print(shared_dependencies)
            # write shared dependencies as a md file inside the generated directory
            write_file("shared_dependencies.md", shared_dependencies, directory)
            
            # Existing for loop
            for filename, filecode in generate_file.map(
                list_actual, order_outputs=False, kwargs=dict(filepaths_string=filepaths_string, shared_dependencies=shared_dependencies, prompt=prompt)
            ):
                write_file(filename, filecode, directory)


    except ValueError:
        print("Failed to parse result: " + result)


def write_file(filename, filecode, directory):
    # Output the filename in blue color
    print("\033[94m" + filename + "\033[0m")
    print(filecode)
    
    file_path = directory + "/" + filename
    dir = os.path.dirname(file_path)
    os.makedirs(dir, exist_ok=True)

    # Open the file in write mode
    with open(file_path, "w") as file:
        # Write content to the file
        file.write(filecode)


def clean_dir(directory):
    import shutil

    extensions_to_skip = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.svg', '.ico', '.tif', '.tiff']  # Add more extensions if needed

    # Check if the directory exists
    if os.path.exists(directory):
        # If it does, iterate over all files and directories
        for root, dirs, files in os.walk(directory):
            for file in files:
                _, extension = os.path.splitext(file)
                if extension not in extensions_to_skip:
                    os.remove(os.path.join(root, file))
    else:
        os.makedirs(directory, exist_ok=True)
``` 

how about using modal (self provisioning runtime?)

## chat

Yes, using Modal is a great choice for your use case. Modal is a self-provisioning runtime that allows you to run code in isolated environments, which means you won't have to worry about installing dependencies in your main project repository. The code you provided is a good example of how to use Modal to generate code based on user input and OpenAI API.

With Modal, you can create a standalone script that runs in an isolated environment, and you can use it with any project, regardless of whether it's a Node.js, Golang, or any other type of project. The dependencies will be installed and managed within the Modal environment, keeping your main project clean and free of unnecessary packages.

## chat

Here's the reworked Python script using Modal. Save this as `code_search_modal.py`:

```python
import os
import json
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import modal

stub = modal.Stub("code-search-modal-v1")
openai_image = modal.Image.debian_slim().pip_install("scikit-learn")

@stub.function(image=openai_image)
def summarize_file(file_path):
    # Implement file summarization logic here
    pass

@stub.function(image=openai_image)
def summarize_folder(folder_path):
    # Implement folder summarization logic here
    pass

@stub.function(image=openai_image)
def store_summarizations(summarizations, output_file):
    with open(output_file, 'w') as f:
        json.dump(summarizations, f)

@stub.local_entrypoint()
def main():
    # Traverse the codebase and summarize files and folders
    summarizations = {}
    for root, dirs, files in os.walk("."):
        for file in files:
            file_path = os.path.join(root, file)
            summarizations[file_path] = summarize_file(file_path)
        for folder in dirs:
            folder_path = os.path.join(root, folder)
            summarizations[folder_path] = summarize_folder(folder_path)

    # Store the summarizations into a JSON file
    store_summarizations(summarizations, "summarizations.json")

    # Run cosine similarity search on the summarizations
    # Implement cosine similarity search logic here
```

To use this script within the root of a large codebase, follow these steps:

1. Install the Modal CLI:

```bash
pip install modal-cli
```

2. Log in to your Modal account:

```bash
modal login
```

3. Create a new Modal project:

```bash
modal new code-search-modal
```

4. Replace the contents of the `main.py` file in the `code-search-modal` folder with the provided code.

5. Install the required dependencies in the `requirements.txt` file:

```
scikit-learn
```

6. Deploy your Modal project:

```bash
modal deploy
```

7. Change to the root directory of your large codebase:

```bash
cd /path/to/your/codebase
```

8. Run your Modal project:

```bash
modal run code-search-modal.main
```

By using Modal, you can run the code search script within the root of a large codebase without installing any dependencies directly in the codebase. The dependencies will be managed within the Modal environment.

https://github.com/smol-ai/developer/blob/main/main.py
