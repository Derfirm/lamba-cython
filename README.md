## npm details

### Install npm
```bash
npm init -y
```

### Install serverless

```bash
npm install -g serverless
```

### install npm package
```bash
npm install serverless-offline -g
```

```bash
npm install --save-dev
```

### Bundling dependencies

In case you would like to include third-party dependencies, you will need to use a plugin called `serverless-python-requirements`. You can set it up by running the following command:

```bash
serverless plugin install -n serverless-python-requirements
serverless plugin install -n serverless-offline
```

## Usage

### Deployment

In order to deploy the example, you need to run the following command:

```
$ serverless deploy
```

### Invocation

After successful deployment, you can invoke the deployed function by using the following command:

```bash
serverless invoke --function hello-python
```

Which should result in response similar to the following:

```json
{
    "statusCode": 200,
    "headers": {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": true
    },
    "body": {
        "message": {
            "text": "Hello!"
        }
    }
}
```

For check success cython

```bash
serverless invoke --function hello-cython
```

### Local development

You can invoke your function locally by using the following command:

```bash
serverless invoke local --function hello-cython
```

Which should result in response similar to the following:

```
{
    "statusCode": 200,
    "headers": {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": true
    },
    "body": {
        "message": {
            "text": "Hello!"
        }
    }
}}
```

### run offline

```bash
sls offline
```

### Profile code execution
```bash
poetry run python -m scalene --html --outfile prof1.html main.py
```



