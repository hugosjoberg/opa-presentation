# API Authorization with Open Policy Agent (OPA) Demo

This repository contains the files and setup necessary to run a live demonstration of API authorization using the Open Policy Agent (OPA).

## Prerequisites

To run this demo and presentation, you must have the following tools installed:
- Docker & Docker Compose: Required to run the OPA server instance.
- presenterm: The terminal-based presentation tool used to display the slides.
- curl and jq: Used to send requests to the OPA server and pretty-print the JSON responses.

## Setup and Running the Demo

Follow these steps to get the OPA server running and start the presentation.

1. Start the OPA Server
```bash
docker-compose up -d
```

2. Start the Presentation

Run the presenterm command. The -x flag is crucial as it enables the execution of the embedded bash +exec blocks in the slides.
```bash
presenterm presentation.md -x
```

3. Executing the Demos, press control+e on the command blocks to execute the curl requests live against the local OPA server.

4. Once the demo is complete, you can stop the OPA container:
```bash
docker-compose down
```
