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
    heading_response_path = config.get("heading_response_path", "")
    body_response_path = config.get("body_response_path", "")
    image_response_path = config.get("image_response_path", "")
    request_headers = config.get("request_headers", "")
    heading_font_color = config.get("heading_font_color", "#FFA500")
    body_font_color = config.get("body_font_color", "#FFFFFF")
    debug_output = config.bool("debug_output", False)
    image_placement = config.get("image_placement", 2)
    image_placement = int(image_placement)
    ttl_seconds = config.get("ttl_seconds", 20)
    ttl_seconds = int(ttl_seconds)

    if debug_output:
        print("------------------------------")
        print("CONFIG - api_url: " + api_url)
        print("CONFIG - heading_response_path: " + heading_response_path)
        print("CONFIG - body_response_path: " + body_response_path)
        print("CONFIG - image_response_path: " + image_response_path)
        print("CONFIG - image_placement: " + str(image_placement))
        print("CONFIG - request_headers: " + request_headers)
        print("CONFIG - heading_font_color: " + heading_font_color)
        print("CONFIG - body_font_color: " + body_font_color)
        print("CONFIG - debug_output: " + str(debug_output))
        print("CONFIG - ttl_seconds: " + str(ttl_seconds))

    return get_text(api_url, heading_response_path, body_response_path, image_response_path, request_headers, debug_output, ttl_seconds, heading_font_color, body_font_color, image_placement)

def get_text(api_url, heading_response_path, body_response_path, image_response_path, request_headers, debug_output, ttl_seconds, heading_font_color, body_font_color, image_placement):
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
            output_heading = None
            output_image = None

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
                            if debug_output:
                                print("Getting text body. Pass: " + str(failure == False))

                            # Get heading
                            if failure == False:
                                response_path_data = parse_response_path(output, heading_response_path, failure, debug_output)
                                output_heading = response_path_data["output"]
                                failure = response_path_data["failure"]
                                message = response_path_data["message"]
                                if debug_output:
                                    print("Getting text heading. Pass: " + str(failure == False))

                            # Get image
                            if failure == False:
                                response_path_data = parse_response_path(output, image_response_path, failure, debug_output)
                                output_image = response_path_data["output"]

                                # failure = response_path_data["failure"]
                                message = response_path_data["message"]
                                if debug_output:
                                    print("Getting image. Pass: " + str(failure == False))

                            if failure == False:
                                if debug_output:
                                    print("Response content type JSON")

                                if type(output) != "dict":
                                    if message == "":
                                        message = "Bad response path for JSON. Must point to a valid text URL."
                                    if debug_output:
                                        print(message)
                                    failure = True
                        else:
                            output_body = None
                            message = "Missing response path for JSON"
                            if debug_output:
                                print(message)
                            failure = True

                    elif output_type == "text":
                        if debug_output:
                            print("Response content type text")

                    if failure == False:
                        if type(output_body) == "string":
                            output_body = output_body.replace("\n", "").replace("\\", "")
                        if type(output_heading) == "string":
                            output_heading = output_heading.replace("\n", "").replace("\\", "")

                        children = []
                        img = None

                        if output_image != None and type(output_image) == "string" and output_image.startswith("http"):
                            output_image_map = get_data(output_image, debug_output, {}, ttl_seconds)
                            img = output_image_map["data"]
                            output_type = output_image_map["type"]

                            if img == None and debug_output:
                                print("Could not retrieve image")

                        if output_heading == None and output_body == None and img == None:
                            message = "No data available"
                        else:
                            # Append heading
                            if output_heading != None and type(output_heading) == "string":
                                children.append(render.WrappedText(content = output_heading, font = "tom-thumb", color = heading_font_color))

                            # Append body
                            if output_body != None and type(output_body) == "string":
                                children.append(render.WrappedText(content = output_body, font = "tom-thumb", color = body_font_color))

                            # Insert image according to placement
                            if img != None:
                                row = render.Row(
                                    expanded = True,
                                    children = [render.Image(src = img, width = 64)],
                                )

                                if image_placement == 1:
                                    children.insert(0, row)
                                elif image_placement == 3:
                                    children.append(row)
                                elif len(children) > 0:
                                    children.insert(len(children) - 1, row)
                            elif len(image_response_path) > 0 and output_image == None and debug_output:
                                print("Image URL found but failed to render")

                            children_content = [
                                render.Marquee(
                                    offset_start = 32,
                                    offset_end = 32,
                                    height = 32,
                                    scroll_direction = "vertical",
                                    width = 64,
                                    child = render.Column(
                                        children = children,
                                    ),
                                ),
                            ]

                            return render.Root(
                                delay = 100,
                                show_full_animation = True,
                                child = render.Row(
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

            if output != None and type(output) == "dict" and type(item) == "string":
                valid_keys = []
                if output != None and type(output) == "dict":
                    valid_keys = output.keys()

                has_item = False
                for valid_key in valid_keys:
                    if valid_key == item:
                        has_item = True
                        break

                if has_item:
                    output = output[item]
                else:
                    failure = True
                    message = "Response path invalid. " + str(item) + " does not exist"
                    if debug_output:
                        print("responsePathArray invalid. " + str(item) + " does not exist")
                    break
            elif output != None and type(output) == "list" and type(item) == "int" and item <= len(output) - 1:
                output = output[item]
            else:
                failure = True
                message = "Response path invalid. " + str(item) + " does not exist"
                if debug_output:
                    print("responsePathArray invalid. " + str(item) + " does not exist")
                break
    else:
        output = None

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

        if contentType.find("json") != -1 or contentType.find("text/plain") != -1 or contentType.find("image") != -1:
            if contentType.find("json") != -1:
                contentType = "json"
            elif contentType.find("image") != -1:
                contentType = "image"
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

    image_placement_options = [
        schema.Option(
            display = "First",
            value = "1",
        ),
        schema.Option(
            display = "Before body",
            value = "2",
        ),
        schema.Option(
            display = "Last",
            value = "3",
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
                id = "request_headers",
                name = "Request headers",
                desc = "Comma separated key:value pairs to build the request headers. eg, `x-api-key:abc123,content-type:application/json`",
                icon = "",
                default = "",
            ),
            schema.Text(
                id = "heading_response_path",
                name = "JSON response path for heading",
                desc = "A comma separated path to the heading from the response JSON. eg. `json_key, 0, json_key_to_heading`",
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
                id = "image_response_path",
                name = "JSON response path for image URL",
                desc = "A comma separated path to an image from the response JSON. eg. `json_key_1, 2, json_key_to_image_url`",
                icon = "",
                default = "",
            ),
            schema.Dropdown(
                id = "image_placement",
                name = "Set the image placement.",
                desc = "Determine where you see the image during scrolling.",
                icon = "",
                default = image_placement_options[1].value,
                options = image_placement_options,
            ),
            schema.Text(
                id = "heading_font_color",
                name = "Heading text color",
                desc = "Heading text color using Hex color codes. eg, `#FFA500`",
                icon = "",
                default = "#FFA500",
            ),
            schema.Text(
                id = "body_font_color",
                name = "Body text color",
                desc = "Body text color using Hex color codes. eg, `#FFFFFF`",
                icon = "",
                default = "#FFFFFF",
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
