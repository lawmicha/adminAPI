
# Amplify iOS with Admin queries

Set up (https://docs.amplify.aws/cli/auth/admin#admin-queries-api)

1. `amplify init`, 

2. `amplify add auth` to enable admin queries

3. Restrict access to specific group. typed in "Admin"

4. `amplify push`

5. update `amplifyconfiguration.json`'s API auth mode to `AMAZON_COGNITO_USER_POOLS`

6. `pod install` and `xed .`

7. In the app, update the `email` and sign up a user

8. update the confirmation code and confirm the user

10. navigate to the cognito user pool, and create a new group called `Admin` with IAM role "AdminQueriesxxxxLambdaRole-dev". I don't think it matters which role is used here, since APIGateway is expecting a user pool authorization token.

11. Add the user to the Admin group.

12. Back in the app, sign in the user

13. Perform the "getUser" call to test things are working