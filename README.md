# Web Scraper AWS Lambda

A basic web scraper using `Playwright` that can be deployed to `AWS Lambda`.

## Setup

### Prerequisites

- Node.js
- NPM

### Environment Setup

**Install packages:**

```bash
npm install
```

## Local Testing

A script can be run to locally test the scraper.

### Prerequisites

- Docker
- Docker Desktop

### Commands

**Run shell script**

```bash
bash scripts/build_and_run.sh <image-name>
```

- `Docker Desktop` must be opened for the script to work.
- Press `Ctrl` + `C` in your terminal to stop the container.

## Upstream Push

After conducting testing, another script can be run to push the Docker image to AWS ECR.

Setting the pushed image as the Lambda function image has not been implemented, and must be done manually.

### Prerequisites

- Docker Desktop
- AWS Account
    - Existing ECR repository

### Commands

**Run shell script**

```bash
bash scripts/push_to_ecr.sh <image-name> <aws-account-id> login
```

- `Docker Desktop` must be opened for the script to work.
- The third argument is optional, and should only be included the first time the script is run.

## Lambda Function Create / Update

### Prerequisites

- AWS Account
    - Existing Lambda function

### Steps

**Create**

1. In the Lambda dashboard, click `Create function`.
2. Select `Container image` as the function creation option.
3. Enter the container name and image URI (the one you pushed to ECR).
4. Click `Create function` (leave architecture as `x86_64` and other config settings untouched).
5. In the function page, click the `Configuration` tab and select `General configuration`.
6. Edit the memory to be `3000 MB` and the timeout to be `3 min 0 sec`, then save your changes.
7. Click the `Configuration` tab, then the `Test` button in the `Test event` panel to test your Lambda function.

**Update**

1. In the function page, click the `Deploy new image` button in the `Image` tab.
2. Click the `Browse images` button and find the SHA of the image you want the function to use.
3. Click the `Save` button to update your Lambda function.
4. Click the `Configuration` tab, then the `Test` button in the `Test event` panel to test your Lambda function.