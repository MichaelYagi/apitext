"""
Applet: API text
Summary: API text display
Description: Display text from an API endpoint.
Author: Michael Yagi
"""

load("encoding/json.star", "json")
load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")

def main(config):
    api_url = config.str("api_url", "")
    title_response_path = config.get("title_response_path", "")
    body_response_path = config.get("body_response_path", "")
    request_headers = config.get("request_headers", "")
    debug_output = config.bool("debug_output", False)
    ttl_seconds = config.get("ttl_seconds", 20)
    ttl_seconds = int(ttl_seconds)

    if debug_output:
        print("------------------------------")
        print("CONFIG - api_url: " + api_url)
        print("CONFIG - title_response_path: " + title_response_path)
        print("CONFIG - body_response_path: " + body_response_path)
        print("CONFIG - request_headers: " + request_headers)
        print("CONFIG - debug_output: " + str(debug_output))
        print("CONFIG - ttl_seconds: " + str(ttl_seconds))

    return get_text(api_url, title_response_path, body_response_path, request_headers, debug_output, ttl_seconds)

def get_text(api_url, title_response_path, body_response_path, request_headers, debug_output, ttl_seconds):
    failure = False
    message = ""

    if api_url == "":
        failure = True
        message = "API URL must not be blank"

        if debug_output:
            print(message)

    else:
        headerMap = {}
        if request_headers != "" or request_headers != {}:
            request_headers_array = request_headers.split(",")

            for app_header in request_headers_array:
                headerKeyValueArray = app_header.split(":")
                if len(headerKeyValueArray) > 1:
                    headerMap[headerKeyValueArray[0].strip()] = headerKeyValueArray[1].strip()

        output_body_map = get_data(api_url, debug_output, headerMap, ttl_seconds)
        output_body = output_body_map["data"]
        output_type = output_body_map["type"]

        if output_body != None and type(output_body) == "string":
            output = json.decode(output_body, None)
            output_title = ""
            output_body = ""

            if output_body != "":
                if debug_output:
                    outputStr = str(output)
                    outputLen = len(outputStr)
                    if outputLen >= 200:
                        outputLen = 200

                    outputStr = outputStr[0:outputLen]
                    if outputLen >= 200:
                        outputStr = outputStr + "..."
                        print("Decoded JSON truncated: " + outputStr)
                    else:
                        print("Decoded JSON: " + outputStr)

                if failure == False:
                    if output != None:
                        if body_response_path != "" and output_type == "json":
                            # Parse response path for JSON
                            response_path_data = parse_response_path(output, body_response_path, failure, debug_output)
                            output_body = response_path_data["output"]
                            failure = response_path_data["failure"]
                            message = response_path_data["message"]

                            if failure == False:
                                response_path_data = parse_response_path(output, title_response_path, failure, debug_output)
                                output_title = response_path_data["output"]
                                failure = response_path_data["failure"]
                                message = response_path_data["message"]

                            if debug_output:
                                print("Response content type JSON")

                            if type(output) != "string":
                                if message == "":
                                    message = "Bad response path for JSON. Must point to a valid text URL."
                                if debug_output:
                                    print(message)
                                failure = True
                        else:
                            message = "Missing response path for JSON"
                            if debug_output:
                                print(message)
                            failure = True

                    elif output_type == "text":
                        if debug_output:
                            print("Response content type text")

                        output_body = output_body.replace("\n", "").replace("\\", "")

                    if output_body != None:
                        children_content = [
                            render.Marquee(
                                height = 24,
                                scroll_direction = "vertical",
                                offset_start = 24,
                                child = render.Column(
                                    children = [
                                        render.WrappedText(
                                            content = output_body,
                                            width = 64,
                                            font = "tom-thumb",
                                        ),
                                    ],
                                ),
                            ),
                        ]

                        if output_title != "":
                            children_content = [
                                render.Box(
                                    width = 64,
                                    height = 8,
                                    padding = 0,
                                    child = render.Text(output_title, offset = 0),
                                ),
                                render.Marquee(
                                    height = 24,
                                    scroll_direction = "vertical",
                                    offset_start = 24,
                                    child = render.Column(
                                        children = [
                                            render.WrappedText(
                                                content = output_body,
                                                width = 64,
                                                font = "tom-thumb",
                                            ),
                                        ],
                                    ),
                                ),
                            ]

                            return render.Root(
                                delay = 100,
                                show_full_animation = True,
                                child = render.Column(
                                    children = children_content,
                                ),
                            )

            else:
                message = "Invalid URL"
                if debug_output:
                    print(message)
                    print(output)
                failure = True

        else:
            message = "Oops! Check URL and header values. URL must return JSON or text."
            if debug_output:
                print(message)
            failure = True

    if message == "":
        message = "Could not get text"

    row = render.Row(children = [])
    if debug_output == True:
        row = render.Row(
            main_align = "space_evenly",
            cross_align = "center",
            children = [
                render.WrappedText(content = message, font = "tom-thumb"),
            ],
        )

    return render.Root(
        child = render.Box(
            row,
        ),
    )

def parse_response_path(output, responsePathStr, failure, debug_output):
    message = ""

    if (len(responsePathStr) > 0):
        responsePathArray = responsePathStr.split(",")

        for item in responsePathArray:
            item = item.strip()
            if item.isdigit():
                item = int(item)

            if debug_output:
                print("path array item: " + str(item) + " - type " + str(type(output)))

            if output != None and type(output) == "dict" and type(item) == "string" and output.get(item) != None:
                output = output[item]
            elif output != None and type(output) == "list" and type(item) == "int" and item <= len(output) - 1 and output[item] != None:
                output = output[item]
            else:
                failure = True
                message = "Response path invalid. " + str(item) + " does not exist"
                if debug_output:
                    print("responsePathArray invalid. " + str(item) + " does not exist")
                break

    return {"output": output, "failure": failure, "message": message}

def get_data(url, debug_output, headerMap = {}, ttl_seconds = 20):
    if headerMap == {}:
        res = http.get(url, ttl_seconds = ttl_seconds)
    else:
        res = http.get(url, headers = headerMap, ttl_seconds = ttl_seconds)

    headers = res.headers
    isValidContentType = False

    headersStr = str(headers)
    headersStr = headersStr.lower()
    headers = json.decode(headersStr, None)
    contentType = ""
    if headers != None and headers.get("content-type") != None:
        contentType = headers.get("content-type")

        if contentType.find("json") != -1 or contentType.find("text/plain") != -1:
            if contentType.find("json") != -1:
                contentType = "json"
            else:
                contentType = "text"

            isValidContentType = True

    if debug_output:
        print("isValidContentType for " + url + " content type " + contentType + ": " + str(isValidContentType))

    if res.status_code != 200 or isValidContentType == False:
        if debug_output:
            print("status: " + str(res.status_code))
            print("Requested url: " + str(url))
    else:
        data = res.body()

        return {"data": data, "type": contentType}

    return {"data": None, "type": contentType}

def get_schema():
    ttl_options = [
        schema.Option(
            display = "5 sec",
            value = "5",
        ),
        schema.Option(
            display = "20 sec",
            value = "20",
        ),
        schema.Option(
            display = "1 min",
            value = "60",
        ),
        schema.Option(
            display = "15 min",
            value = "900",
        ),
        schema.Option(
            display = "1 hour",
            value = "3600",
        ),
        schema.Option(
            display = "24 hours",
            value = "86400",
        ),
    ]

    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "api_url",
                name = "API URL",
                desc = "The API URL. Supports JSON or text types.",
                icon = "",
                default = "",
            ),
            schema.Text(
                id = "title_response_path",
                name = "JSON response path for title",
                desc = "(Optional) A comma separated path to the title from the response JSON. eg. `json_key, 0, json_key_to_title`",
                icon = "",
                default = "",
            ),
            schema.Text(
                id = "body_response_path",
                name = "JSON response path for body",
                desc = "A comma separated path to the main body from the response JSON. eg. `json_key_1, 2, json_key_to_body`",
                icon = "",
                default = "",
            ),
            schema.Text(
                id = "request_headers",
                name = "Request headers",
                desc = "Comma separated key:value pairs to build the request headers. eg, `x-api-key:abc123,content-type:application/json`",
                icon = "",
                default = "",
            ),
            schema.Dropdown(
                id = "ttl_seconds",
                name = "Refresh rate",
                desc = "Refresh data at the specified interval. Useful for when an endpoint serves random texts.",
                icon = "",
                default = ttl_options[1].value,
                options = ttl_options,
            ),
            schema.Toggle(
                id = "debug_output",
                name = "Toggle debug messages",
                desc = "Toggle debug messages. Will display the messages on the display if enabled.",
                icon = "",
                default = False,
            ),
        ],
    )
