This is one of my apps for the TidByt. You can pull info from an endpoint that serves text or JSON. Things like news feeds are an ideal use.

This repo is intended as a testing and staging area before things get pushed to https://github.com/tidbyt/community/tree/main/apps/apitext.

https://github.com/public-apis/public-apis is a great resource for APIs you can use for this app.

Example usages:

-----

API URL: ```http://<plex_server_url>/library/sections/1/all```

Request headers: ```accept:application/json,X-Plex-Token:<plex_token>```

JSON Response path for heading: ```MediaContainer,Metadata,[rand1],title```

JSON Response path for body: ```MediaContainer,Metadata,[rand1],summary```

JSON Response path for image: ```MediaContainer,Metadata,[rand1],thumb```

Set the image placement: ```Left```

Base URL: ```http://<plex_server_url>```

![Akira_movie](https://github.com/MichaelYagi/apitext/blob/main/api_text.gif?raw=true)

-----

API URL: ```https://official-joke-api.appspot.com/random_joke```

JSON Response path for heading: ```setup```

JSON Response path for body: ```punchline```

Body text color: ```#0000FF```

![Joke API](https://michaelyagi.github.io/images/api_text_1.gif)

-----

API URL: ```https://newsdata.io/api/1/latest?country=us&category=technology```

Request headers: ```Content-Type:application/json,X-ACCESS-KEY:<api_key>```

JSON Response path for heading: ```results,2,title```

JSON Response path for body: ```results,2,description```

JSON Response path for image: ```results,2,image_url```

![Tech news](https://michaelyagi.github.io/images/api_text_2.gif)

-----

API URL: ```https://nuthatch.lastelm.software/v2/birds``` 

Request headers: ```api-key:<api_key>```

JSON Response path for heading: ```entities,[rand1],name```

JSON Response path for body: ```entities,[rand1],sciName```

JSON Response path for image: ```entities,[rand1],images,[rand]```

* Note the [rand] keyword chooses from a random index each time it's called according to the list length. However, calling ```[randX]```, where ```X``` is a number between 0-9, ensures you can use the same random number between the heading, body and image paths. Ideal if the paths have the same parent, as demonstrated in the example above.

![Bird pics](https://michaelyagi.github.io/images/api_text_3.gif)
