Testing and staging area before things get pushed to https://github.com/tidbyt/community/tree/main/apps/apiimage. Make sure to do an [advanced build of pixlet](https://tidbyt.dev/docs/build/advanced-installation) so you can run the commands below.

After making changes:

* Create a fork and run ```lint```,```format```, and ```check``` before commiting your changes
* Create fork of https://github.com/tidbyt/community/tree/main
* Copy api_image.star file to forked apps/apitext/api_text and push changes to fork for review
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

![Bird pics](https://michaelyagi.github.io/images/api_text_3.gif)
