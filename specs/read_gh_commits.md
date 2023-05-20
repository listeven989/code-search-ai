## idea

still an idea in the air

what if some way to read all the commits (like a human does) and convert that to a data structure that could be utilized by an llm during search?

could also do the same for github issues convos etc to get more context from people

## uses 

llm reads user question "what files should i change to add a dogecoin price endpoint to the this crypto prices server?"

past commit: add bitcoin price endpoint

llm reviews the changes and loads it into the context

possible prompt

```
HUMAN:

out of this file changes pull out the possible code snippets that might be helpful to the query <ABOVE-QUERY>

format your output like so

--code block--
FILEPATH: src/somefile.ts

// imports

// ...other code

app.get("prices/:crypto", () => {

// ...some logic

return axios.get(`coingecko.com/${:crypto}`)
})

// ... other code
--code block---

CHAT:
```
