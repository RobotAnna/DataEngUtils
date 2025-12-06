# AWS secrets
## 1-cli usage
### 1.1-How to create a secret a from a file using cli?
Assume that you have a file in your working directory called mycreds.json then you can just use the following command.
```
aws secretsmanager create-secret --name production/MyAwesomeAppSecret --secret-string file://mycreds.json
```
### 1.2-How to update a secret using cli?
Let&#39;s say that you have a new json with the new credentials, you can use put-secret-value command to update
the secret.
```
$ aws secretsmanager put-secret-value --secret-id prodtest/nldataintelligence/emr/some_database --secret-
string file://mynewcreds.json
```
## 2-python boto api usage
### How to return secrets using python boto api?
Assuming you&#39;ve already created a secret called MyAwesomeAppSecret you can get the secret as follows.
```
python get_secrets.py --secret_name MyAwesomeAppSecret
```
In your applications copy the get_secrets.py modify the code to access the secret programatically.