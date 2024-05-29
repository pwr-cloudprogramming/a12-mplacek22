function getPoolData() {
    return {
        UserPoolId: "<COGNITO_USER_POOL_ID>",
        ClientId: "<COGNITO_CLIENT_ID>"
    };
}

var userPool;

function getUserPool() {
    if (userPool === undefined) {
        userPool = new AmazonCognitoIdentity.CognitoUserPool(getPoolData());
    }
    return userPool;
}

var cognitoUser;

function getUser(userName) {
    if (cognitoUser === undefined) {
        var userData = {
            Username: userName,
            Pool: getUserPool()
        };
        cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);
    }
    return cognitoUser;
}

async function uploadProfilePic(file, username) {
    const formData = new FormData();
    formData.append("file", file);

    const response = await fetch(`${url}/api/files/upload?username=${username}`, {
        method: 'POST',
        body: formData
    });

    if (response.ok) {
        const data = await response.json();
        return data.url;
    } else {
        const errorText = await response.text();
        console.error('Error uploading profile picture:', errorText);
        return null;
    }
}

function signUpUser(userName, userEmail, userPassword, profilePic, callback) {
    let dataEmail = {
        Name: 'email',
        Value: userEmail
    };
    let dataName = {
        Name: 'preferred_username',
        Value: userName
    };
    let attributeList = [
        new AmazonCognitoIdentity.CognitoUserAttribute(dataEmail),
        new AmazonCognitoIdentity.CognitoUserAttribute(dataName)
    ];

    let userPool = getUserPool();
    
    // Upload profile picture first
    uploadProfilePic(profilePic, userName)
        .then(profilePicUrl => {
            if (profilePicUrl) {
                // You may store the profilePicUrl in user attributes or separately as needed.
                userPool.signUp(userName, userPassword, attributeList, null, function (err, result) {
                    if (err) {
                        callback(err, null);
                    } else {
                        cognitoUser = result.user;
                        // Optionally save profilePicUrl to user attributes
                        callback(null, result);
                    }
                });
            } else {
                callback(new Error('Profile picture upload failed'), null);
            }
        })
        .catch(err => {
            callback(err, null);
        });
}

function confirmUser(userName, code, callback) {
    getUser(userName).confirmRegistration(code, true, callback);
}

function wrapCallback(callback) {
    return {
        onFailure: (err) => { callback(err, null); },
        onSuccess: (result) => { callback(null, result); }
    };
}

async function getProfilePicUrl(username) {
    const response = await fetch(`${url}/api/files/get-by-username?username=${username}`);
    if (response.ok) {
        const blob = await response.blob();
        return URL.createObjectURL(blob);
    } else {
        const errorText = await response.text();
        console.error('Error fetching profile picture URL:', errorText);
        return null;
    }
}

window.uploadProfilePic = uploadProfilePic;

function signInUser(userName, password, callback) {
    let authenticationData = {
        Username: userName,
        Password: password,
    };
    var authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);
    getUser(userName).authenticateUser(authenticationDetails, wrapCallback(async (err, result) => {
        if (err) {
            callback(err, null);
        } else {
            // Retrieve profile picture URL
            const profilePicUrl = await getProfilePicUrl(userName);
            if (profilePicUrl) {
                localStorage.setItem("profilePicUrl", profilePicUrl);
            }
            callback(null, result);
            updateSignedInUsername(userName); // Ensure the UI is updated after signing in
        }
    }));
}

function signOutUser(callback) {
    if (cognitoUser) {
        if (cognitoUser.signInUserSession) {
            cognitoUser.signOut();
            callback(null, {});
            return;
        }
    }
    callback({ name: "Error", message: "User is not signed in" }, null);
}

function deleteUser(callback) {
    if (cognitoUser) {
        cognitoUser.deleteUser((err, result) => {
            if (err) {
                callback(err, null);
                return;
            }
            cognitoUser = null;
            callback(null, result);
        });
        return;
    }
    callback({ name: "Error", message: "User is not signed in" }, null);
}

function changeUserPassword(oldPassword, newPassword, callback) {
    if (cognitoUser) {
        cognitoUser.changePassword(oldPassword, newPassword, callback);
        return;
    }
    callback({ name: "Error", message: "User is not signed in" }, null);
}

function sendPasswordResetCode(userName, callback) {
    getUser(userName).forgotPassword(wrapCallback(callback));
}

function confirmPasswordReset(username, code, newPassword, callback) {
    getUser(userName).confirmPassword(code, newPassword, wrapCallback(callback));
}

function userAttributes(updateCallback) {
    if (cognitoUser) {
        cognitoUser.getUserAttributes((err, result) => {
            if (err) {
                updateCallback({});
                return;
            } else {
                let userInfo = { name: cognitoUser.username };
                for (let k = 0; k < result.length; k++) {
                    userInfo[result[k].getName()] = result[k].getValue();
                }
                updateCallback(userInfo);
            }
        });
    } else {
        updateCallback({});
    }
}

function updateAttributes(attributes, callback) {
    var attributeList = [];
    for (key in attributes) {
        attributeList.push(new AmazonCognitoIdentity.CognitoUserAttribute({
            Name: key,
            Value: attributes[key]
        }));
    }

    cognitoUser.updateAttributes(attributeList, callback);
}

var user = {
    name: "",
    email: "",
    email_verified: "false",
    status: "",
    update: function (userInfo) {
        for (key in userInfo) {
            if (this[key] != undefined) {
                this[key] = userInfo[key];
            }
        }
    }
};

function visibility(divElementId, show = false) {
    let divElement = document.getElementById(divElementId);
    if (show) {
        divElement.style.display = "block";
    } else {
        divElement.style.display = "none";
    }
}

function closeAlertMessage() {
    $("#operationAlert span").remove();
    $("#operationAlert").hide();
}

function createCallback(successMessage, userName = "", email = "", confirmed = "", status = "") {
    return (err, result) => {
        if (err) {
            let message = err.name + err.message;
            alert(`Error: ${message}`);
        } else {
            user.update({
                name: userName,
                email: email,
                email_verified: confirmed,
                status: status
            });
            let message = "Success: " + successMessage;
            alert(message);

            if (status === "Signed In") {
                localStorage.setItem("loggedInUser", userName);
                // Store the tokens in local storage
                cognitoUser.getSession((err, session) => {
                    if (err) {
                        console.log(err);
                        return;
                    }
                    localStorage.setItem("idToken", session.getIdToken().getJwtToken());
                    localStorage.setItem("accessToken", session.getAccessToken().getJwtToken());
                });
                updateSignedInUsername(userName);
            } else if (status === "Signed Out") {
                localStorage.removeItem("loggedInUser");
                localStorage.removeItem("idToken");
                localStorage.removeItem("accessToken");
                updateSignedInUsername("");
            }
        }
    };
}



function updateSignedInUsername(userName) {
    document.getElementById("signedInUsername").innerText = userName ? `Signed in as: ${userName}` : "";
    const profilePicUrl = localStorage.getItem("profilePicUrl");
    if (profilePicUrl) {
        document.getElementById("signedInUserProfilePic").src = profilePicUrl;
    }
}

function modalFormEnter() {
    let buttonText = $("#modalFormButton").text();
    let username = $("#userName").val();
    let email = $("#userEmail").val();
    let code = $("#userConfirmationCode").val();
    let password = $("#userPassword").val();
    let newPassword = $("#newUserPassword").val();
    let profilePic = $("#userProfilePic")[0].files[0];

    let callback;
    let message;
    switch (buttonText) {
        case "Sign Up":
            message = `user ${username} added to the user pool`;
            callback = createCallback(message, username, email, "No", "Created");
            signUpUser(username, email, password, profilePic, callback);
            break;

        case "Confirm":
            message = `user ${username} confirmed email address ${email}`;
            callback = createCallback(message, username, user.email, "true", "Confirmed");
            confirmUser(username, code, callback);
            break;

        case "Sign In":
            message = `user ${username} signed in`;
            callback = createCallback(message, username, "", "true", "Signed In");
            signInUser(username, password, callback);
            break;
    }
    $("#addUserModal").modal('hide');
}

function updateModal(showName, showEmail, showProfilePic, showPassword, showNewPassword, showConfirm, buttonText, title) {
    visibility("userNameDiv", showName);
    visibility("userEmailDiv", showEmail);
    visibility("userProfilePicDiv", showProfilePic);
    if (showNewPassword) {
        visibility("userNewPasswordDiv", true);
        $("#passwordLabel").text("Current Password");
    } else {
        visibility("userNewPasswordDiv", false);
        $("#passwordLabel").text("Password");
    }
    visibility("userPasswordDiv", showPassword);
    visibility("confirmationCode", showConfirm);
    $("#modalFormButton").text(buttonText);
    $("#addUserModalLabel").text(title);
    $("#addUserModal").modal();
}

function toggleShowPassword(checkBoxId, inputId) {
    if ($("#" + checkBoxId).is(":checked")) {
        $("#" + inputId).prop("type", "text");
    } else {
        $("#" + inputId).prop("type", "password");
    }
}

function actionAddUser() {
    updateModal(true, true, true, true, false, false, "Sign Up", "Add a new user to the pool");
}

function actionConfirmUser() {
    updateModal(true, false, false, false, false, true, "Confirm", "Confirm a new user");
}

function actionSignInUser() {
    updateModal(true, false, false, true, false, false, "Sign In", "Authenticate user");
}

function signOutUser(callback) {
    if (cognitoUser) {
        if (cognitoUser.signInUserSession) {
            cognitoUser.signOut();
            localStorage.removeItem("loggedInUser");
            callback(null, {});
            return;
        }
    }
    callback({ name: "Error", message: "User is not signed in" }, null);
}

function getSessionToken() {
    return new Promise((resolve, reject) => {
        if (cognitoUser) {
            cognitoUser.getSession((err, session) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(session.getIdToken().getJwtToken());
                }
            });
        } else {
            reject(new Error("User is not signed in"));
        }
    });
}

window.getSessionToken = getSessionToken;