var turns = [["#", "#", "#"], ["#", "#", "#"], ["#", "#", "#"]];
var turn = "";
var gameOn = false;

const url = 'http://<ALB_DNS_NAME>:8080';

let gameId;
let playerType;

let connection;

function connectToSocket(gameId) {
    connection = new signalR.HubConnectionBuilder().withUrl(url + "/gameplay").build(); // Ensure this URL matches your SignalR Hub route

    connection.on("ReceiveGameUpdate", function (gameData) {
        console.log(gameData);
        displayResponse(gameData);
    });

    connection.on("JoinedGame", async function (gameData) {
        console.log(gameData);
        if (playerType == 1 && gameData.player2.login != undefined) {
            $("#oponentLogin").text(gameData.player2.login);
            const profilePicUrl = await getProfilePicUrl(gameData.player2.login);
            if (profilePicUrl) {
                $("#oponentProfilePic").attr("src", profilePicUrl);
            }
            alert("Player 2 entered game: " + gameData.player2.login);
            gameOn = true;
        }
    });

    connection.start().then(function () {
        console.log("connected to the game hub");
        connection.invoke("SubscribeToGame", gameId).catch(function (err) {
            return console.error(err.toString());
        });
    }).catch(function (err) {
        console.error("SignalR Connection Error: ", err);
    });
}

function makeAuthenticatedRequest(settings) {
    return window.getSessionToken().then(token => {
        settings.headers = {
            ...settings.headers,
            'Authorization': 'Bearer ' + token,
            'Content-Type': 'application/json'
        };
        return $.ajax(settings);
    }).catch(err => {
        alert('Failed to get session token: ' + err.message);
    });
}


async function createGame() {
    let login = localStorage.getItem("loggedInUser");
    if (login == null || login === '') {
        alert("Please sign in first");
    } else {
        makeAuthenticatedRequest({
            url: url + "/game/start",
            type: 'POST',
            dataType: "json",
            contentType: "application/json",
            data: JSON.stringify({
                "login": login
            }),
            success: function (data) {
                gameId = data.id;
                playerType = 1;
                $("#playerTicToe").text("X");
                reset();
                connectToSocket(gameId);
                alert("You created a game. Game id is: " + gameId);
            },
            error: function (error) {
                alert(error.responseText);
                console.log(error);
            }
        });
    }
}

async function updateOponentData(oponentLogin){
    $("#oponentLogin").text(oponentLogin);
    const profilePicUrl = await getProfilePicUrl(oponentLogin);
    if (profilePicUrl) {
        $("#oponentProfilePic").attr("src", profilePicUrl);
    }
}

function connectToRandom() {
    let login = localStorage.getItem("loggedInUser");
    if (login == null || login === '') {
        alert("Please sign in first");
    } else {
        makeAuthenticatedRequest({
            url: url + "/game/connect/random",
            type: 'POST',
            dataType: "json",
            contentType: "application/json",
            data: JSON.stringify({
                "login": login
            }),
            success: function (data) {
                gameId = data.id;
                playerType = 2;
                $("#playerTicToe").text("O");
                reset();
                connectToSocket(gameId);
                updateOponentData(data.player1.login);
                alert("Congrats you're playing with: " + data.player1.login);
            },
            error: function (error) {
                alert(error.responseText);
                console.log(error);
            }
        });
    }
}


function connectToSpecificGame() {
    let login = localStorage.getItem("loggedInUser");
    let enteredGameId = document.getElementById("game_id").value;
    if (login == null || login === '') {
        alert("Please sign in first");
    }
    else if (enteredGameId == null || enteredGameId === '') {
        alert("Please enter game id");
    }
    else {
        makeAuthenticatedRequest({
            url: url + "/game/connect",
            type: 'POST',
            dataType: "json",
            contentType: "application/json",
            data: JSON.stringify({
                "player": {
                    "login": login
                },
                "gameId": enteredGameId
            }),
            success: function (data) {
                gameId = data.id;
                playerType = 2;
                $("#playerTicToe").text("O");
                reset();
                connectToSocket(gameId);
                updateOponentData(data.player1.login);
                alert("Congrats you're playing with: " + data.player1.login);
            },
            error: function (error) {
                alert(error.responseText);
                console.log(error);
            }
        });
    }
}


function playerTurn(turn, id) {
    if (gameOn) {
        var spotTaken = $("#" + id).text();
        if (spotTaken === "#") {
            makeAMove(playerType, id.split("_")[0], id.split("_")[1]);
        }
    }
}

function makeAMove(type, xCoordinate, yCoordinate) {
    makeAuthenticatedRequest({
        url: url + "/game/gameplay",
        type: 'POST',
        dataType: "json",
        contentType: "application/json",
        data: JSON.stringify({
            "type": type,
            "coordinateX": xCoordinate,
            "coordinateY": yCoordinate,
            "gameId": gameId
        }),
        success: function (data) {
            gameOn = false;
            displayResponse(data);
        },
        error: function (xhr, textStatus, errorThrown) {
            alert(xhr.responseText);
        }
    });
}


function displayResponse(data) {

    let board = data.board;
    for (let i = 0; i < board.length; i++) {
        for (let j = 0; j < board[i].length; j++) {
            if (board[i][j] === 1) {
                turns[i][j] = 'X'
            } else if (board[i][j] === 2) {
                turns[i][j] = 'O';
            }
            let id = i + "_" + j;
            $("#" + id).text(turns[i][j]);
        }
    }
    if (data.status == 2) {
        if (data.winner == 0) {
            alert("It's a draw!")
        }
        else if (data.winner == 1) {
            alert("Winner is X");
        }
        else if (data.winner == 2) {
            alert("Winner is O");
        }
    }
    gameOn = true;
}

$(".tic").click(function () {
    var slot = $(this).attr('id');
    playerTurn(turn, slot);
});

function reset() {
    turns = [["#", "#", "#"], ["#", "#", "#"], ["#", "#", "#"]];
    $(".tic").text("#");
}

$("#reset").click(function () {
    reset();
});

