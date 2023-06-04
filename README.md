# AI Code Search

Repo to explore approaches to code search

`/specs` 

contains ideas, implementation strategies, use cases, test cases, and more

`/chatcraft.org` 

tested some of the code search ideas to make a feature for [chatcraft.org's open sourced project](https://github.com/tarasglek/chatcraft.org), contains:

- script to generate a mermaid chart of the full codebase & files
- prompt to tell gpt to navigate to the correct files given a query & mermaid chart
- script to copy/format/truncate code files to feed back to gpt

demo:

[![Demo](https://img.youtube.com/vi/kZEBevvoPYM/0.jpg)](https://www.youtube.com/watch?v=kZEBevvoPYM)

## TODO
- test cosine similarity search on codefile summaries as a way to find the revelant code files faster 
- write some code that takes all the files from a codebase and store it in a codebase for usage on the above cosine similarity search retrieval
