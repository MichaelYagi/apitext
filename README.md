This is one of my apps for the TidByt. You can pull info from an endpoint that serves text or a JSON feed. Things like news feeds are an ideal use.

Testing and staging area before things get pushed to https://github.com/tidbyt/community/tree/main/apps/apitext. Make sure to do an [advanced build of pixlet](https://tidbyt.dev/docs/build/advanced-installation) so you can run the commands below.

After making changes:

* Create a fork and run ```lint```,```format```, and ```check``` before commiting your changes for review
* Once review passes, create fork of https://github.com/tidbyt/community/tree/main
* Copy api_text.star file to forked apps/apitext/api_text, run formatter/linter and push changes to fork for review
* Create a PR if automated tests pass

Example usages:

-----

API URL: ```https://official-joke-api.appspot.com/random_joke```

JSON Response path for heading: ```setup```

JSON Response path for heading: ```punchline```

Body text color: ```#0000FF```

![Joke API](https://michaelyagi.github.io/images/api_text_1.gif)

-----

API URL: ```https://newsdata.io/api/1/latest?apikey=<api_key>&country=us&category=technology```

JSON Response path for heading: ```results,2,title"```

JSON Response path for heading: ```results,2,description```

![Tech news](https://michaelyagi.github.io/images/api_text_2.gif)

-----

API URL: ```https://nuthatch.lastelm.software/v2/birds``` 

Request headers: ```api-key:<api_key>```

JSON Response path for heading: ```entities,[rand],name```

JSON Response path for heading: ```entities,[rand],sciName```

JSON Response path for image URL: ```entities,[rand],images,0```

Keep same random number across paths: ```On```

* Note the [rand] keyword chooses from a random index according to the list length. Turning on ```Keep same random number across paths``` ensures you can use the same random number between the heading, body and image paths if the pull from the same parent.

![Bird pics](https://michaelyagi.github.io/images/api_text_3.gif)
