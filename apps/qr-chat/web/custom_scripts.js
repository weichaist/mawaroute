function fetchStream(url, method, headers, body, callback) {
    fetch(url, {
        method: method,
        headers: headers,
        body: body
    }).then(response => {
        const reader = response.body.getReader();
        return new ReadableStream({
            start(controller) {
                function push() {
                    reader.read().then(({done, value}) => {
                        if (done) {
                            controller.close();
                            return;
                        }
                        const data = new TextDecoder("utf-8").decode(value);
                        callback(data); // Send data to Dart
                        push();
                    }).catch(error => {
                        console.error("Stream reading error:", error);
                        controller.error(error);
                    });
                }
                push();
            }
        });
    }).catch(error => {
        console.error("Fetch error:", error);
        callback("[ERROR]"); // Send error indicator to Dart
    });
}