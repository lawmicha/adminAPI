
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

13. Perform the "getUser" call to test things are working.

14. Add the following to the app step 3: https://github.com/aws-amplify/amplify-ios/issues/1103#issuecomment-809815828

they are the following:

AdminQueriesxxx-cloudformation-tempalte.json
```
"cognito-idp:AdminCreateUser"
```

app.js
```
// at the top
const {
  addUserToGroup,
  removeUserFromGroup,
  confirmUserSignUp,
  disableUser,
  enableUser,
  getUser,
  listUsers,
  listGroups,
  listGroupsForUser,
  listUsersInGroup,
  signUserOut,
  createUser, // add this
} = require('./cognitoActions');

// at the bottom
app.post('/createUser', async (req, res, next) => {
  if (!req.body.username || !req.body.name) {
    const err = new Error('username and name are required');
    err.statusCode = 400;
    return next(err);
  }

  try {
    const response = await createUser(req.body.username, req.body.name);
    res.status(200).json(response);
  } catch (err) {
    next(err);
  }
});
```

cognitoActions.js
```
// at the bottom
async function createUser(username, name) {
  const params = {
    UserPoolId: userPoolId,
    Username: username,
    DesiredDeliveryMediums: ["EMAIL"],
    UserAttributes: [
      {"Name": "given_name", "Value": name},
      {"Name": "email_verified", "Value": "true"},
      {"Name": "email", "Value": username}
    ]
  }

  try {
    const result = await cognitoIdentityServiceProvider.adminCreateUser(params).promise();
    console.log(`Confirmed ${username} has been created`);
    return {
      message: `Confirmed ${username} has been created`
    };
  } catch (err) {
    console.log(err)
    throw err;
  }
}

module.exports = {
  addUserToGroup,
  removeUserFromGroup,
  confirmUserSignUp,
  disableUser,
  enableUser,
  getUser,
  listUsers,
  listGroups,
  listGroupsForUser,
  listUsersInGroup,
  createUser, // add this
  signUserOut,
};

```

15. `amplify push` and once it is done, update `amplifyconfiguration.json`'s API auth mode to `AMAZON_COGNITO_USER_POOLS`

16. click on `createUser` and the response should be 
```
Success {"message":"Confirmed test@email.com has been created"}
```

17. `amplify add api`, choose GraphQL, CUP for auth, Todo schema.

18. `amplify update api` and choose Enable DataStore for entire API
